/**********************************************************
*
* bg_PricingCalculatorController:
*
* Custom pricing calculator for 3 products sold by Citation, 
* these product have rules around their price and what is sold
* with them, such as consultancy days.
*
* Created By: Michael Fleming 
* Created Date: 27-04-2017 
*
* Changes: KH 22/09/2017 (UAT Feedback)
*
***********************************************************/
public without sharing class bg_PricingCalculatorController 
{
    private Map<String, CPQ_Term_Coefficient__c> termCoefficientsMap;
    private List<CPQ_Included_Consultancy_Days__c> includedConsultancyDaysList;
    public List<SelectOption> terms {get;set;}

    /*
    *   Pricing will be cached by 'ServiceType-SectorGrouping' to a 
    *   list of Pricing_Matrix__c records, ordered by Number_of_Employees_Min__c
    *
    *   a helper method will be created to quicly pull the price from this map based on 
    *   the sector, service type and FTE count.
    */
    private Map<String,List<Pricing_Matrix__c>> pricingMatrixCache;

    /*
    *   Properties used to render out data onto the UI
    */
    public String termSelected {get;set;}
    public Decimal termSelectedMonths {get; set;}

    public Boolean hasPriceBandingPermission {get;set;}

    public String combinedServiceLabel {get;set;}
    public String healthAndSafetyLabel {get;set;}
    public String employmentLawLabel {get;set;}
    public String multipleLinesLabel {get;set;}

    public Boolean combinedServiceSelected {get;set;}
    public Boolean healthAndSafetySelected {get;set;}
    public Boolean employmentLawSelected {get;set;}
    public Boolean multipleLinesSelected {get;set;}

    public Decimal combinedServiceRate {get;set;}
    public Decimal healthAndSafetyRate {get;set;}
    public Decimal employmentLawRate {get;set;}

    /*
        Set from the custom setting, driven tbe the number of FTE.
    */
    public Decimal includedConsultancyDaysAllowance
    {
        get {
            for(CPQ_Included_Consultancy_Days__c daySetting : includedConsultancyDaysList)
            {
                if (daySetting.Number_of_Employees_Min__c <= numberOfFTE && 
                    daySetting.Number_of_Employees_Max__c >= numberOfFTE)
                {
                    return daySetting.Included_Consultancy_Days__c;
                }
            }
            return 0;
        }
    }

    /*
        Number of sites depends on the Number of Standard Sites and Complex Sites,
        this can come through from the Opportunity.
    */
    public Decimal numberOfSites
    {
        get {
            Decimal sites = 0;

		    if (customerQuote.Number_of_Standard_Sites__c == null && customerQuote.Number_of_Complex_Sites__c == null)// && customerQuote.Number_of_Sites_Opportunity__C != null)
            {   
                sites += Decimal.valueof(opportunity.Number_Of_Sites__c);    
                customerQuote.Number_of_Standard_Sites__c = Decimal.valueof(opportunity.Number_Of_Sites__c);
            }
            if(customerQuote.Number_of_Standard_Sites__c!= null)
            {
                sites += customerQuote.Number_of_Standard_Sites__c;
            }
            if(customerQuote.Number_of_Complex_Sites__c != null)
            {
                sites += customerQuote.Number_of_Complex_Sites__c;
            }
            return sites;
        }
        private set;
    }

    /*
        Numbrer of FTE is driven by the Full Time and Part Time Employees specified (raito used is 1:3)
    */
    public Decimal numberOfFTE
    {
        get {
            Decimal employees = 0;

            if(customerQuote.Number_of_Full_Time_Employees__c != null)
            {
                employees += customerQuote.Number_of_Full_Time_Employees__c;
            }
            if(customerQuote.Number_of_Part_Time_Employees__c != null && customerQuote.Number_of_Part_Time_Employees__c != 0)
            {
                employees += customerQuote.Number_of_Part_Time_Employees__c.divide( 3, 2).round(RoundingMode.CEILING);
            }
            return employees;
        }
        private set;
    }


    /*
        Number of Included Consustancy days is then calculated based on the Standard Days, Complex Days
        and Included Consusltancy Days Allowance.
    */
    public Decimal includedConsultancyDays
    {
        get {
            Decimal standardDays = (customerQuote.Number_of_Standard_Sites__c != null && customerQuote.Number_of_Standard_Sites__c > 0) ? customerQuote.Number_of_Standard_Sites__c : 0;
            Decimal complexDays = (customerQuote.Number_of_Complex_Site_Days__c != null && customerQuote.Number_of_Complex_Site_Days__c > 0) ? customerQuote.Number_of_Complex_Site_Days__c : 0;
            
            if(standardDays + complexDays >= includedConsultancyDaysAllowance)
            {
                return includedConsultancyDaysAllowance;
            }
            else
            {
                return standardDays + complexDays;
            }
        }
        private set;
    } 

    /*
        Number of Additional Consultancy Days depend on the Number of Days required relative to the 

    */
    public Decimal additionalConsultancyDays
    {
        get {
            Decimal standardDays = (customerQuote.Number_of_Standard_Sites__c != null && customerQuote.Number_of_Standard_Sites__c > 0) ? customerQuote.Number_of_Standard_Sites__c : 0;
            Decimal complexDays = (customerQuote.Number_of_Complex_Site_Days__c != null && customerQuote.Number_of_Complex_Site_Days__c > 0) ? customerQuote.Number_of_Complex_Site_Days__c : 0;
            system.debug('**standardDays: ' + standardDays);
            system.debug('**complexDays: ' + complexDays);
            system.debug('**includedConsultancyDaysAllowance: ' + includedConsultancyDaysAllowance);
            system.debug('**termSelectedMonths: ' + termSelectedMonths);
            if(standardDays + complexDays >= includedConsultancyDaysAllowance && !tooManySitesOrEmployees)
            {
                //SM: 26/2/2018 Removed the multiply by term
               // return ((standardDays + complexDays)-includedConsultancyDaysAllowance)*(termSelectedMonths/12);
                return ((standardDays + complexDays)-includedConsultancyDaysAllowance);
            }
            else
            {
                return 0;
            }
        }
        private set;
    }

    public Decimal additionalConsultancyDaysMonthlyCost {
        get {
        	system.debug('*** additionalConsultancyDays: ' + additionalConsultancyDays);
        	system.debug('*** termSelectedMonths: ' + termSelectedMonths);
            
            system.debug('**customerQuote.Number_Of_Full_Time_Employees__c0**: ' + customerQuote.Number_Of_Full_Time_Employees__c);
            system.debug('**customerQuote.Number_Of_Part_Time_Employees__c0**: ' + customerQuote.Number_of_Part_Time_Employees__c);

            Boolean numberOfEmployeesSpecified = customerQuote.Number_of_Part_Time_Employees__c != null && customerQuote.Number_Of_Full_Time_Employees__c != null;
            Boolean numberOfComplexSiteDaysSpecified = customerQuote.Number_of_Complex_Site_Days__c != 0 && customerQuote.Number_of_Complex_Site_Days__c > 0;
            Boolean numberOfAdditionalConDaysSpecified = additionalConsultancyDays > 0 && additionalConsultancyDays != null;

            if (numberOfAdditionalConDaysSpecified && termSelectedMonths != null && numberOfEmployeesSpecified && !tooManySitesOrEmployees)
            {
            	//SM: added div by 12
            	//Decimal cost = (additionalConsultancyDays * 875)/termSelectedMonths;
            	
                Decimal cost = (additionalConsultancyDays * 875.00)/12.00;
                return cost.setscale(2) ;
             //   return cost.round(RoundingMode.HALF_UP);
            }
            else if (numberOfAdditionalConDaysSpecified && termSelectedMonths != null && !numberOfEmployeesSpecified && numberOfComplexSiteDaysSpecified && !tooManySitesOrEmployees)
            {
            	//SM: added div by 12
            	//Decimal cost = (additionalConsultancyDays * 875)/termSelectedMonths;
            	
                Decimal cost = (additionalConsultancyDays * 875.00)/12.00;
                return cost.setscale(2) ;
              //  return cost.round(RoundingMode.HALF_UP);
            }
            else 
            {
                return 0;
            }
        }    
        set;
    }

    public boolean tooManySitesOrEmployees {
        get {
            return (numberOFFTE >100 || numberOfSites > 6) ? true : false ;            
        }    
    }

    public Boolean calculateApprovalRequired {
        get
        {

            Boolean combinedServiceRequiresApproval = combinedServiceRate!=null && combinedServiceSelected && ((combinedServiceRate < combinedLowestPrice && hasPriceBandingPermission == TRUE) || (combinedServiceRate < combined2ndPrice && hasPriceBandingPermission == FALSE));

            Boolean healthAndSafetyRequiresApproval = healthAndSafetyRate!=null && healthAndSafetySelected && ((healthAndSafetyRate < healthAndSafetyLowestPrice && hasPriceBandingPermission == TRUE) || (healthAndSafetyRate < healthAndSafety2ndPrice && hasPriceBandingPermission == FALSE));

            Boolean employmentLawRequiresApproval = employmentLawRate!=null && employmentLawSelected && ((employmentLawRate < employmentLawLowestPrice && hasPriceBandingPermission == TRUE) || (employmentLawRate < employmentLaw2ndPrice && hasPriceBandingPermission == FALSE));


            Boolean requiresApproval = combinedServiceRequiresApproval || healthAndSafetyRequiresApproval || employmentLawRequiresApproval || termCoefficientsMap.get(termSelected).Requires_Approval__c || numberOfFTE > 100 || numberOfSites > 6;

            if(requiresApproval)
            {
                return TRUE;
            }
            else{
                return FALSE;
            }
        }
    }

    public Decimal combinedBestPrice {
        get {return getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, termSelected);}
    }
    public Decimal combined4thPrice {
        get {return getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, termSelected);}
    }
    public Decimal combined3rdPrice {
        get {return getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, termSelected);}
    }
    public Decimal combined2ndPrice {
        get
        {
            if (numberOfFTE >= 1 && numberOfFTE <= 10)
            {
                return getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, termSelected);
            }
            else 
            {
                return getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, termSelected);   
            }
        }
    }
    public Decimal combinedLowestPrice {
        get {return getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, termSelected);}
    }

    public Decimal healthAndSafetyBestPrice {
        get {return getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, termSelected);}
    }
    public Decimal healthAndSafety4thPrice {
        get {return getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, termSelected);}
    }
    public Decimal healthAndSafety3rdPrice {
        get {return getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, termSelected);}
    }
    public Decimal healthAndSafety2ndPrice
    {
        get {
            if (numberOfFTE >= 1 && numberOfFTE <= 10)
            {
                return getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, termSelected);
            }
            else 
            {
                return getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, termSelected);
            }
        }
    }
    public Decimal healthAndSafetyLowestPrice {
        get {return getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, termSelected);}
    }

    public Decimal employmentLawBestPrice {
        get {return getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, termSelected);}
    }
    public Decimal employmentLaw4thPrice {
        get {return getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, termSelected);}
    }
    public Decimal employmentLaw3rdPrice {
        get {return getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, termSelected);}
    }
    public Decimal employmentLaw2ndPrice
    {
         get {
            if (numberOfFTE >= 1 && numberOfFTE <= 10)
            {
                return getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, termSelected);
            }
            else 
            {
                return getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, termSelected);
            }
        }        
    }
    public Decimal employmentLawLowestPrice {
        get {return getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, termSelected);}
    }


    private String sectorGrouping;

    public SBQQ__Quote__c customerQuote {get;set;}
    public Opportunity opportunity {get;set;}

    public SBQQ__QuoteLine__c customerQuoteLine {get;set;}

    public SBQQ__QuoteLine__c additionalConsultancyDaysLine {get;set;}
    public SBQQ__QuoteLine__c includedConsultancyDaysLine {get;set;}

    public String userRole {get;set;}

    List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    Map<String, QLIWrapper> qliWrapperMap = new Map<String, QLIWrapper>();

    public bg_PricingCalculatorController() 
    {
        
        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        Id quoteLineId = (Id)ApexPages.currentPage().getParameters().get('qlid');
        Id opportunityId = (Id)ApexPages.currentPage().getParameters().get('oid');

        if(customerQuote == null && quoteId != null)
        {
            customerQuote = getCustomerQuoteForId(quoteId, quoteLineId);
            if(CustomerQuote.Number_of_Complex_Sites__c == null) {
            	CustomerQuote.Number_of_Complex_Sites__c = 0 ;
            }            
            opportunity = customerQuote.SBQQ__Opportunity2__r;
        }
        if(opportunity == null && opportunityId != null)
        {
            opportunity = getOpportunityForId(opportunityId);
        }
        if(customerQuote == null)
        {
            customerQuote = new SBQQ__Quote__c();
        }
        if(customerQuoteLine == null)
        {
            customerQuoteLine = new SBQQ__QuoteLine__c();
        }
        if(includedConsultancyDaysLine == null)
        {
            includedConsultancyDaysLine = new SBQQ__QuoteLine__c();
        }
        if(additionalConsultancyDaysLine == null)
        {
            additionalConsultancyDaysLine = new SBQQ__QuoteLine__c();
        }

        if(opportunity != null && decimal.valueof(opportunity.Number_Of_Sites__c) > 0) {
            CustomerQuote.Number_of_Standard_Sites__c = decimal.valueof(opportunity.Number_Of_Sites__c) ;
        }

        multipleLinesLabel = 'Include 3, 5 & 7 Year Lines';
        multipleLinesSelected = false;
        
        //userRole = [Select Role_Reporting_Name__c From User Where Id = :UserInfo.getUserId()][0].Role_Reporting_Name__c;

        hasPriceBandingPermission = bg_CustomPermissionUtil.userHasPermission('CustomPriceCalculator5thBand',null);       

        if(opportunity != null)
        {
            if(opportunity.Account.CitationSector__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Citation Sector was specified on the account to be quoted, please make sure this is filled in and try again.'));
            }
            else
            {
                for(CPQ_Client_Sector__c sectorMapping : CPQ_Client_Sector__c.getAll().values())
                {
                    if(opportunity.Account.CitationSector__c.equalsIgnoreCase(sectorMapping.Client_Sector__c))
                    {
                        sectorGrouping = sectorMapping.Sector_Grouping__c;
                    }
                }
                if(customerQuote.Id == null)
                {
                    customerQuote.Number_of_Full_Time_Employees__c = opportunity.FT_Employees__c;
                    customerQuote.Number_of_Part_Time_Employees__c = opportunity.PT_Employees__c;
                }
            }
        }

        if(sectorGrouping == null)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Sector Grouping was found for the specified Citation Sector, please contact your administrator.'));
        }
        //else
        //{
            //Load maps
            loadTermDetails();
            termSelectedMonths = termCoefficientsMap.get(termSelected).Term_Months__c;
            if(customerQuoteLine.Id!=null)
            {
                termSelected = customerQuoteLine.SBQQ__SubscriptionTerm__c/12 + ' Years';
                termSelectedMonths = customerQuoteLine.SBQQ__SubscriptionTerm__c;
            }
            populatePricingMap(sectorGrouping);

            includedConsultancyDaysList = new List<CPQ_Included_Consultancy_Days__c>();

            for(CPQ_Included_Consultancy_Days__c daySetting : CPQ_Included_Consultancy_Days__c.getAll().values())
            {
                includedConsultancyDaysList.add(daySetting);
            }
        //}
    }

    public PageReference saveQuoteAndExit()
    {
        try {
            saveQuote();
            return new PageReference('/'+customerQuote.Id);
        }
        catch (bg_PricingCalculatorException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public PageReference saveQuoteAndAddMore()
    {
        try {
            saveQuote();

            PageReference returnPage = Page.bg_PricingCalculator;
            returnPage.getParameters().put('qid',customerQuote.Id);
            returnPage.setRedirect(true);
            return returnPage;
        }
        catch (bg_PricingCalculatorException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public PageReference saveQuoteAndAddOthers()
    {
        try
        {
            saveQuote();
            return new PageReference('/apex/sbqq__sb?scontrolCaching=1&id=' + customerQuote.Id + '#quote/le?qId=' + customerQuote.Id);

        }
        catch (bg_PricingCalculatorException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public PageReference cancel()
    {
        if((Id)ApexPages.currentPage().getParameters().get('qid') != null)
        {
            return new PageReference('/'+ApexPages.currentPage().getParameters().get('qid'));
        }
        else if((Id)ApexPages.currentPage().getParameters().get('oid') != null)
        {
            return new PageReference('/'+ApexPages.currentPage().getParameters().get('oid'));
        }
        return null;
    }

    public void saveQuote()
    {
        //Validate details entered by user.
        if(!employmentLawSelected &&
            !combinedServiceSelected &&
            !healthAndSafetySelected)
        {
            throw new bg_PricingCalculatorException('You must select a product option and specify a price to save a quote.');
        }

        if((combinedServiceSelected && (combinedServiceRate == null || combinedServiceRate <= 0)) ||
            (employmentLawSelected && (employmentLawRate == null || employmentLawRate <= 0)) ||
            (healthAndSafetySelected && (healthAndSafetyRate == null || healthAndSafetyRate <= 0)))
        {
            throw new bg_PricingCalculatorException('You must input a valid positive price for the option selected.');
        }

        //if(numberOfSites > 7)
        //{
        //  throw new bg_PricingCalculatorException('Bespoke pricing must be used for Quotes with more than 7 sites.');
        //}
        //else 
        if (numberOfSites==null || numberOfSites==0)
        {
            throw new bg_PricingCalculatorException('You must enter a number of Sites to proceed.');
        }
        if (numberOfFTE==null || numberOfFTE==0)
        {
            throw new bg_PricingCalculatorException('Please complete the Number of FTE field.');
        }

        //if(numberOfFTE > 100)
        //{
        //  throw new bg_PricingCalculatorException('Bespoke pricing must be used for Quotes above 100 FTE.');
        //}

        Boolean quoteRequiresApproval = false;
        //System.debug('Quote needs approval Flag = '+quoteRequiresApproval);

        if(calculateApprovalRequired)
        {
            quoteRequiresApproval = true;
        }
        else if(customerQuote.SBQQ__LineItems__r != null && customerQuote.SBQQ__LineItems__r.size() > 0)
        {
            for(SBQQ__QuoteLine__c existingQuoteLine : customerQuote.SBQQ__LineItems__r)
            {
                if(existingQuoteLine.Quoted_Best_Price__c != null && 
                    existingQuoteLine.Id != customerQuoteLine.Id)
                {
                    Decimal approvalBoundry = hasPriceBandingPermission ? existingQuoteLine.Quoted_Lowest_Price__c : existingQuoteLine.Quoted_2nd_Price__c;
                    String termText = existingQuoteLine.SBQQ__SubscriptionTerm__c/12 > 1 ? existingQuoteLine.SBQQ__SubscriptionTerm__c/12+' Years' : existingQuoteLine.SBQQ__SubscriptionTerm__c/12+' Year';
                    //System.debug('Boundry = '+approvalBoundry);

                    if(numberOfFTE > 100 || 
                        numberOfSites > 6 ||
                        existingQuoteLine.SBQQ__ListPrice__c < approvalBoundry || 
                        termCoefficientsMap.get(termText).Requires_Approval__c)
                    {
                        //System.debug('Approval required on a different line.'+ JSON.serializePretty(existingQuoteLine));
                        quoteRequiresApproval = true;
                    }
                }
            }
        }

        customerQuote.Requires_Approval__c = quoteRequiresApproval;
        customerQuote.SBQQ__LineItemsGrouped__c = TRUE;
        Schema.DescribeSObjectResult dr = Schema.SObjectType.SBQQ__Quote__c;
        //System.assert(false, dr.getRecordTypeInfosByName());
        customerQuote.RecordTypeId = dr.getRecordTypeInfosByName().get('Quote Standard').getRecordTypeId();
        customerQuote.SBQQ__Status__c = 'Draft';


        //working on a new quote from an opportunity
        if(customerQuote.Id == null)
        {
            customerQuote.SBQQ__Account__c = opportunity.AccountId;
            customerQuote.SBQQ__SalesRep__c = opportunity.OwnerId;
            customerQuote.SBQQ__Opportunity2__c = opportunity.Id;

            insert customerQuote;
        }
        else{
            update customerQuote;
        }

        //Write back the employee counts to the account if they are not the same.
        

        if(opportunity.AccountId != null &&
            (Opportunity.Account.FT_Employees__c != customerQuote.Number_of_Full_Time_Employees__c || Opportunity.Account.PT_Employees__c != customerQuote.Number_of_Part_Time_Employees__c) || Opportunity.Account.Sites__c != customerQuote.Number_of_Standard_Sites__c)
        {
            Account oppAccount = Opportunity.Account;
            oppAccount.FT_Employees__c = customerQuote.Number_of_Full_Time_Employees__c;
            oppAccount.PT_Employees__c = customerQuote.Number_of_Part_Time_Employees__c;
            oppAccount.Sites__c = numberOfSites; 
            update oppAccount;
        }

        Decimal termMonths = termCoefficientsMap.get(termSelected).Term__c * 12;
        Decimal termYears = termCoefficientsMap.get(termSelected).Term__c;
        
        Decimal highestQuoteLineNumber = 1;
        Decimal highestGroupNumber = 0;
        

        if(combinedServiceSelected)
        {
            Pricing_Matrix__c priceMatrixRecord;
            priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_COMBINED_SERVICE,numberOfFTE);

            QLIWrapper genericYearWrapper = new QLIWrapper();
            if(!qliWrapperMap.containsKey(termYears + ' - Combined Service'))
            {
                qliWrapperMap.put(termYears + ' - Combined Service', genericYearWrapper);
                genericYearWrapper.mainLine = new SBQQ__QuoteLine__c();
            }
            else
            {
                genericYearWrapper = qliWrapperMap.get(termYears + ' - Combined Service');
            }

            system.debug('**genericYearWrapper**: ' + JSON.serializePretty(genericYearWrapper));

            genericYearWrapper.mainLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
            genericYearWrapper.mainLine.SBQQ__CustomerPrice__c = combinedServiceRate * termMonths;
            genericYearWrapper.mainLine.SBQQ__ListPrice__c = combinedServiceRate;
            genericYearWrapper.mainLine.Quoted_Best_Price__c = combinedBestPrice;
            genericYearWrapper.mainLine.Quoted_4th_Price__c = combined4thPrice;
            genericYearWrapper.mainLine.Quoted_3rd_Price__c = combined3rdPrice;
            genericYearWrapper.mainLine.Quoted_2nd_Price__c = combined2ndPrice;
            genericYearWrapper.mainLine.Quoted_Lowest_Price__c = combinedLowestPrice;
            genericYearWrapper.mainLine.SBQQ__SubscriptionTerm__c = termMonths;
            genericYearWrapper.mainLine.SBQQ__Quantity__c = 1;
            genericYearWrapper.mainLine.SBQQ__PricingMethod__c = 'Custom';
            genericYearWrapper.mainLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

            genericYearWrapper.priceMatrixUsed = priceMatrixRecord;

            // if 3,5,7 create other records and add to a list
            system.debug('**termYears**: ' + termYears);
            system.debug('**genericYearWrapper.mainLine.Id**: ' + genericYearWrapper.mainLine.Id);
            system.debug('**multipleLinesSelected**: ' + multipleLinesSelected);
            if( (termYears==3 || termYears==5 || termYears==7) && genericYearWrapper.mainLine.Id == null && multipleLinesSelected)
            {
                if(termYears==3)
                {
                    // 5 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_COMBINED_SERVICE,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, '5 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, '5 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, '5 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, '5 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, '5 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 5 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (combinedServiceRate * termCoefficientsMap3.get('5 Years')).round(RoundingMode.HALF_UP) * (5 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (combinedServiceRate * termCoefficientsMap3.get('5 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper fiveYearWrapper = new QLIWrapper();
                    fiveYearWrapper.mainLine = generatedQuoteLine;
                    fiveYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('5 - Combined Service', fiveYearWrapper);

                    // 7 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, '7 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, '7 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, '7 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, '7 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, '7 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 7 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (combinedServiceRate * termCoefficientsMap3.get('7 Years')).round(RoundingMode.HALF_UP) * (7 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (combinedServiceRate * termCoefficientsMap3.get('7 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper sevenYearWrapper = new QLIWrapper();
                    sevenYearWrapper.mainLine = generatedQuoteLine2;
                    sevenYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('7 - Combined Service', sevenYearWrapper);
                }
                else if(termYears==5)
                {
                    // 3 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_COMBINED_SERVICE,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, '3 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, '3 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, '3 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, '3 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, '3 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 3 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (combinedServiceRate * termCoefficientsMap.get('3 Years').Coefficient__c).round(RoundingMode.HALF_UP) * (3 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (combinedServiceRate * termCoefficientsMap.get('3 Years').Coefficient__c).round(RoundingMode.HALF_UP);

                    QLIWrapper threeYearWrapper = new QLIWrapper();
                    threeYearWrapper.mainLine = generatedQuoteLine;
                    threeYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('3 - Combined Service', threeYearWrapper);

                    // 7 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, '7 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, '7 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, '7 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, '7 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, '7 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 7 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (combinedServiceRate * termCoefficientsMap.get('7 Years').Coefficient__c).round(RoundingMode.HALF_UP) * (7 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (combinedServiceRate * termCoefficientsMap.get('7 Years').Coefficient__c).round(RoundingMode.HALF_UP);

                    QLIWrapper sevenYearWrapper = new QLIWrapper();
                    sevenYearWrapper.mainLine = generatedQuoteLine2;
                    sevenYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('7 - Combined Service', sevenYearWrapper);

                }
                else if(termYears==7)
                {
                    // 3 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_COMBINED_SERVICE,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, '3 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, '3 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, '3 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, '3 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, '3 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 3 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (combinedServiceRate * termCoefficientsMap7.get('3 Years')).round(RoundingMode.HALF_UP) * (3 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (combinedServiceRate * termCoefficientsMap7.get('3 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper threeYearWrapper = new QLIWrapper();
                    threeYearWrapper.mainLine = generatedQuoteLine;
                    threeYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('3 - Combined Service', threeYearWrapper);

                    // 5 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,0, '5 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,1, '5 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,2, '5 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,3, '5 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_COMBINED_SERVICE, numberOfFTE,4, '5 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 5 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (combinedServiceRate * termCoefficientsMap7.get('5 Years')).round(RoundingMode.HALF_UP) * (5 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (combinedServiceRate * termCoefficientsMap7.get('5 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper fiveYearWrapper = new QLIWrapper();
                    fiveYearWrapper.mainLine = generatedQuoteLine2;
                    fiveYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('5 - Combined Service', fiveYearWrapper);
                }
            }
            else
            {
            }

        }
        if(healthAndSafetySelected)
        {
            Pricing_Matrix__c priceMatrixRecord;
            priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY,numberOfFTE);

            QLIWrapper genericYearWrapper = new QLIWrapper();
            if(!qliWrapperMap.containsKey(termYears + ' - Health & Safety'))
            {
                qliWrapperMap.put(termYears + ' - Health & Safety', genericYearWrapper);
                genericYearWrapper.mainLine = new SBQQ__QuoteLine__c();
            }
            else
            {
                genericYearWrapper = qliWrapperMap.get(termYears + ' - Health & Safety');
            }

            genericYearWrapper.mainLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
            genericYearWrapper.mainLine.SBQQ__CustomerPrice__c = healthAndSafetyRate * termMonths;
            genericYearWrapper.mainLine.SBQQ__ListPrice__c = healthAndSafetyRate;
            genericYearWrapper.mainLine.Quoted_Best_Price__c = healthAndSafetyBestPrice;
            genericYearWrapper.mainLine.Quoted_4th_Price__c = healthAndSafety4thPrice;
            genericYearWrapper.mainLine.Quoted_3rd_Price__c = healthAndSafety3rdPrice;
            genericYearWrapper.mainLine.Quoted_2nd_Price__c = healthAndSafety2ndPrice;
            genericYearWrapper.mainLine.Quoted_Lowest_Price__c = healthAndSafetyLowestPrice;
            genericYearWrapper.mainLine.SBQQ__SubscriptionTerm__c = termMonths;
            genericYearWrapper.mainLine.SBQQ__Quantity__c = 1;
            genericYearWrapper.mainLine.SBQQ__PricingMethod__c = 'Custom';
            genericYearWrapper.mainLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

            genericYearWrapper.priceMatrixUsed = priceMatrixRecord;

            // if 3,5,7 create other records and add to a list
            if( (termYears==3 || termYears==5 || termYears==7) && genericYearWrapper.mainLine.Id == null && multipleLinesSelected)
            {
                if(termYears==3)
                {
                    // 5 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, '5 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, '5 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, '5 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, '5 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, '5 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 5 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (healthAndSafetyRate * termCoefficientsMap3.get('5 Years')).round(RoundingMode.HALF_UP) * (5 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (healthAndSafetyRate * termCoefficientsMap3.get('5 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper fiveYearWrapper = new QLIWrapper();
                    fiveYearWrapper.mainLine = generatedQuoteLine;
                    fiveYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('5 - Health & Safety', fiveYearWrapper);

                    // 7 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, '7 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, '7 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, '7 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, '7 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, '7 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 7 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (healthAndSafetyRate * termCoefficientsMap3.get('7 Years')).round(RoundingMode.HALF_UP) * (7 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (healthAndSafetyRate * termCoefficientsMap3.get('7 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper sevenYearWrapper = new QLIWrapper();
                    sevenYearWrapper.mainLine = generatedQuoteLine2;
                    sevenYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('7 - Health & Safety', sevenYearWrapper);
                }
                else if(termYears==5)
                {
                    // 3 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, '3 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, '3 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, '3 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, '3 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, '3 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 3 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (healthAndSafetyRate * termCoefficientsMap.get('3 Years').Coefficient__c).round(RoundingMode.HALF_UP) * (3 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (healthAndSafetyRate * termCoefficientsMap.get('3 Years').Coefficient__c).round(RoundingMode.HALF_UP);

                    QLIWrapper threeYearWrapper = new QLIWrapper();
                    threeYearWrapper.mainLine = generatedQuoteLine;
                    threeYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('3 - Health & Safety', threeYearWrapper);

                    // 7 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, '7 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, '7 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, '7 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, '7 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, '7 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 7 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (healthAndSafetyRate * termCoefficientsMap.get('7 Years').Coefficient__c).round(RoundingMode.HALF_UP) * (7 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (healthAndSafetyRate * termCoefficientsMap.get('7 Years').Coefficient__c).round(RoundingMode.HALF_UP);

                    QLIWrapper sevenYearWrapper = new QLIWrapper();
                    sevenYearWrapper.mainLine = generatedQuoteLine2;
                    sevenYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('7 - Health & Safety', sevenYearWrapper);

                }
                else if(termYears==7)
                {
                    // 3 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, '3 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, '3 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, '3 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, '3 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, '3 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 3 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (healthAndSafetyRate * termCoefficientsMap7.get('3 Years')).round(RoundingMode.HALF_UP) * (3 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (healthAndSafetyRate * termCoefficientsMap7.get('3 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper threeYearWrapper = new QLIWrapper();
                    threeYearWrapper.mainLine = generatedQuoteLine;
                    threeYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('3 - Health & Safety', threeYearWrapper);

                    // 5 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,0, '5 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,1, '5 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,2, '5 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,3, '5 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, numberOfFTE,4, '5 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 5 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (healthAndSafetyRate * termCoefficientsMap7.get('5 Years')).round(RoundingMode.HALF_UP) * (5 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (healthAndSafetyRate * termCoefficientsMap7.get('5 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper fiveYearWrapper = new QLIWrapper();
                    fiveYearWrapper.mainLine = generatedQuoteLine2;
                    fiveYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('5 - Health & Safety', fiveYearWrapper);
                }
            }
            else
            {
            }

        }
        if(employmentLawSelected)
        {
            Pricing_Matrix__c priceMatrixRecord;
            priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_EMPLOYMENT_LAW,numberOfFTE);

            QLIWrapper genericYearWrapper = new QLIWrapper();
            if(!qliWrapperMap.containsKey(termYears + ' - Employment Law'))
            {
                qliWrapperMap.put(termYears + ' - Employment Law', genericYearWrapper);
                genericYearWrapper.mainLine = new SBQQ__QuoteLine__c();
            }
            else
            {
                genericYearWrapper = qliWrapperMap.get(termYears + ' - Employment Law');
            }

            genericYearWrapper.mainLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
            genericYearWrapper.mainLine.SBQQ__CustomerPrice__c = employmentLawRate * termMonths;
            genericYearWrapper.mainLine.SBQQ__ListPrice__c = employmentLawRate;
            genericYearWrapper.mainLine.Quoted_Best_Price__c = employmentLawBestPrice;
            genericYearWrapper.mainLine.Quoted_4th_Price__c = employmentLaw4thPrice;
            genericYearWrapper.mainLine.Quoted_3rd_Price__c = employmentLaw3rdPrice;
            genericYearWrapper.mainLine.Quoted_2nd_Price__c = employmentLaw2ndPrice;
            genericYearWrapper.mainLine.Quoted_Lowest_Price__c = employmentLawLowestPrice;
            genericYearWrapper.mainLine.SBQQ__SubscriptionTerm__c = termMonths;
            genericYearWrapper.mainLine.SBQQ__Quantity__c = 1;
            genericYearWrapper.mainLine.SBQQ__PricingMethod__c = 'Custom';
            genericYearWrapper.mainLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

            genericYearWrapper.priceMatrixUsed = priceMatrixRecord;

            // if 3,5,7 create other records and add to a list
            system.debug('**Line972**: ' + termYears);
            system.debug('**Line972**: ' + genericYearWrapper.mainLine.Id);
            system.debug('**Line972**: ' + genericYearWrapper.mainLine);
            system.debug('**Line972**: ' + genericYearWrapper);
            system.debug('**Line972**: ' + multipleLinesSelected);
            if( (termYears==3 || termYears==5 || termYears==7) && genericYearWrapper.mainLine.Id == null && multipleLinesSelected)
            {
                system.debug('**Inside IF**');
                if(termYears==3)
                {
                    system.debug('**Inside 3**');
                    // 5 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_EMPLOYMENT_LAW,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, '5 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, '5 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, '5 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, '5 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, '5 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 5 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (employmentLawRate * termCoefficientsMap3.get('5 Years')).round(RoundingMode.HALF_UP) * (5 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (employmentLawRate * termCoefficientsMap3.get('5 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper fiveYearWrapper = new QLIWrapper();
                    fiveYearWrapper.mainLine = generatedQuoteLine;
                    fiveYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('5 - Employment Law', fiveYearWrapper);

                    // 7 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, '7 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, '7 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, '7 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, '7 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, '7 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 7 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (employmentLawRate * termCoefficientsMap3.get('7 Years')).round(RoundingMode.HALF_UP) * (7 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (employmentLawRate * termCoefficientsMap3.get('7 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper sevenYearWrapper = new QLIWrapper();
                    sevenYearWrapper.mainLine = generatedQuoteLine2;
                    sevenYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('7 - Employment Law', sevenYearWrapper);
                }
                else if(termYears==5)
                {
                    system.debug('**Inside 5**');
                    // 3 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_EMPLOYMENT_LAW,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, '3 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, '3 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, '3 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, '3 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, '3 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 3 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (employmentLawRate * termCoefficientsMap.get('3 Years').Coefficient__c).round(RoundingMode.HALF_UP) * (3 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (employmentLawRate * termCoefficientsMap.get('3 Years').Coefficient__c).round(RoundingMode.HALF_UP);

                    QLIWrapper threeYearWrapper = new QLIWrapper();
                    threeYearWrapper.mainLine = generatedQuoteLine;
                    threeYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('3 - Employment Law', threeYearWrapper);

                    // 7 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, '7 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, '7 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, '7 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, '7 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, '7 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 7 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (employmentLawRate * termCoefficientsMap.get('7 Years').Coefficient__c).round(RoundingMode.HALF_UP) * (7 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (employmentLawRate * termCoefficientsMap.get('7 Years').Coefficient__c).round(RoundingMode.HALF_UP);

                    QLIWrapper sevenYearWrapper = new QLIWrapper();
                    sevenYearWrapper.mainLine = generatedQuoteLine2;
                    sevenYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('7 - Employment Law', sevenYearWrapper);

                }
                else if(termYears==7)
                {
                    system.debug('**Inside 7**');
                    // 3 years
                    SBQQ__QuoteLine__c generatedQuoteLine = new SBQQ__QuoteLine__c();
                    priceMatrixRecord = getPricingObject(Bg_Constants.PRODUCT_EMPLOYMENT_LAW,numberOfFTE);
                    generatedQuoteLine.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, '3 Years');
                    generatedQuoteLine.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, '3 Years');
                    generatedQuoteLine.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, '3 Years');
                    generatedQuoteLine.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, '3 Years');
                    generatedQuoteLine.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, '3 Years');
                    generatedQuoteLine.SBQQ__SubscriptionTerm__c = 3 * 12;
                    generatedQuoteLine.SBQQ__Quantity__c = 1;
                    generatedQuoteLine.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine.SBQQ__CustomerPrice__c = (employmentLawRate * termCoefficientsMap7.get('3 Years')).round(RoundingMode.HALF_UP) * (3 * 12);
                    generatedQuoteLine.SBQQ__ListPrice__c = (employmentLawRate * termCoefficientsMap7.get('3 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper threeYearWrapper = new QLIWrapper();
                    threeYearWrapper.mainLine = generatedQuoteLine;
                    threeYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('3 - Employment Law', threeYearWrapper);

                    // 5 years
                    SBQQ__QuoteLine__c generatedQuoteLine2 = new SBQQ__QuoteLine__c();
                    generatedQuoteLine2.SBQQ__Product__c = priceMatrixRecord.Product__c;
                    generatedQuoteLine2.Quoted_Best_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,0, '5 Years');
                    generatedQuoteLine2.Quoted_4th_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,1, '5 Years');
                    generatedQuoteLine2.Quoted_3rd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,2, '5 Years');
                    generatedQuoteLine2.Quoted_2nd_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,3, '5 Years');
                    generatedQuoteLine2.Quoted_Lowest_Price__c = getPrice(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, numberOfFTE,4, '5 Years');
                    generatedQuoteLine2.SBQQ__SubscriptionTerm__c = 5 * 12;
                    generatedQuoteLine2.SBQQ__Quantity__c = 1;
                    generatedQuoteLine2.SBQQ__PricingMethod__c = 'Custom';
                    generatedQuoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';

                    // logic around list price...

                    generatedQuoteLine2.SBQQ__CustomerPrice__c = (employmentLawRate * termCoefficientsMap7.get('5 Years')).round(RoundingMode.HALF_UP) * (5 * 12);
                    generatedQuoteLine2.SBQQ__ListPrice__c = (employmentLawRate * termCoefficientsMap7.get('5 Years')).round(RoundingMode.HALF_UP);

                    QLIWrapper fiveYearWrapper = new QLIWrapper();
                    fiveYearWrapper.mainLine = generatedQuoteLine2;
                    fiveYearWrapper.priceMatrixUsed = priceMatrixRecord;
                    qliWrapperMap.put('5 - Employment Law', fiveYearWrapper);
                }
            }
            else
            {
            }

        }
        else
        {
            //error case, however should never reach here as selection should be caught earlier.
        }
        

        
        // create list for existing quote lines which don't have a group
        List<SBQQ__QuoteLine__c> existingQuoteLinesList = new List<SBQQ__QuoteLine__c>();
        // add lines without a group to this list
        // assign standard group to list of lines without group
        // assign group to new/ updated pricing calculator line item

        //Check before saving that the line item to be added doesnt exist
        //this check is based on the combination of term and product.
        if(customerQuote.SBQQ__LineItems__r != null && customerQuote.SBQQ__LineItems__r.size() > 0)
        {
            for(SBQQ__QuoteLine__c existingQuoteLine : customerQuote.SBQQ__LineItems__r)
            {
                // for(String qliWrapper : qliWrapperMap.keySet())
                // {
                    if(existingQuoteLine.SBQQ__SubscriptionTerm__c == termMonths && existingQuoteLine.SBQQ__Product__c == /*priceMatrixRecord.Product__c*/ customerQuoteLine.SBQQ__Product__c && existingQuoteLine.Id != customerQuoteLine.Id)
                    {
                        //throw new bg_PricingCalculatorException('This combination of term and selected product already exists on the current quote, please edit this line rather than adding a new one.');
                    }
                // }
                if(existingQuoteLine.SBQQ__Number__c > highestQuoteLineNumber)
                {
                    highestQuoteLineNumber = existingQuoteLine.SBQQ__Number__c;
                }

                if(existingQuoteLine.SBQQ__Group__r.SBQQ__Number__c > highestGroupNumber)
                {
                    highestGroupNumber = existingQuoteLine.SBQQ__Group__r.SBQQ__Number__c;
                }

                if(existingQuoteLine.SBQQ__Group__c==null)
                {
                    existingQuoteLinesList.add(existingQuoteLine);
                }
            }
        }

        /*
        *   Group generation / linkage to new and existing lines.
        *       - needs to take into account that existing lines may have a group, 
        *       or may not, if not, a new group will be needed for them.
        *       - for custom pricing lines, these need to have a group, but 
        *       may be coming in via an edit, so we dont always want to insert a new group.
        */

        List<SBQQ__QuoteLineGroup__c> newGroupList = new List<SBQQ__QuoteLineGroup__c>();

        for(String qliWrapper : qliWrapperMap.keySet())
        {
            SBQQ__QuoteLineGroup__c calculatorGroup;

            //check if the process is running in an edit, if so we dont want to be creating a whole new group.
            if(qliWrapperMap.get(qliWrapper).assignedGroup != null)
            {
                calculatorGroup = qliWrapperMap.get(qliWrapper).assignedGroup;
            }
            else
            {
                calculatorGroup = new SBQQ__QuoteLineGroup__c();
                calculatorGroup.SBQQ__Quote__c = customerQuote.Id;
                calculatorGroup.SBQQ__ListTotal__c = 0;
                calculatorGroup.SBQQ__CustomerTotal__c = 0;
                calculatorGroup.SBQQ__NetTotal__c = 0;
                calculatorGroup.SBQQ__Number__c = highestGroupNumber+1;
                calculatorGroup.Name = 'Option '+(highestGroupNumber+1);
                calculatorGroup.SBQQ__SubscriptionTerm__c = qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
                highestGroupNumber += 1;
            }

            qliWrapperMap.get(qliWrapper).assignedGroup = calculatorGroup;

            newGroupList.add(calculatorGroup);
        }

        

        //We have quote lines to link to a group therefore insert both groups, else just insert the calculator group.
        if(!existingQuoteLinesList.isEmpty())
        {   
            // create standard group
            SBQQ__QuoteLineGroup__c standardGroup = new SBQQ__QuoteLineGroup__c();
            standardGroup.SBQQ__Quote__c = customerQuote.Id;
            standardGroup.SBQQ__ListTotal__c = 0;
            standardGroup.SBQQ__CustomerTotal__c = 0;
            standardGroup.SBQQ__NetTotal__c = 0;
            standardGroup.SBQQ__Number__c = highestGroupNumber+1;
            standardGroup.Name = 'Option '+(highestGroupNumber+1);
            highestGroupNumber += 1;

            newGroupList.add(standardGroup);

            // upsert new List<SBQQ__QuoteLineGroup__c>{standardGroup, calculatorGroup};
            upsert newGroupList;

            for(SBQQ__QuoteLine__c existingQuoteLine : existingQuoteLinesList)
            {
                existingQuoteLine.SBQQ__Group__c = standardGroup.Id;
                quoteLines.add(existingQuoteLine);
                system.debug('added');
            }
        }
        else
        {
            // upsert calculatorGroup;
            upsert newGroupList;
        }

        //Now that the calculator group has been insert use it to link to the lines
        //Set quoteLine Number to keep correct order within the UI.

        List<SBQQ__QuoteLine__c> quoteLinesForUpsert = new List<SBQQ__QuoteLine__c>();

        for(String qliWrapper : qliWrapperMap.keySet())
        {
            qliWrapperMap.get(qliWrapper).mainLine.SBQQ__Group__c = qliWrapperMap.get(qliWrapper).assignedGroup.Id;

            if(qliWrapperMap.get(qliWrapper).mainLine.SBQQ__Number__c == null && qliWrapperMap.get(qliWrapper).mainLine.SBQQ__Quote__c==null)
            {
                qliWrapperMap.get(qliWrapper).mainLine.SBQQ__Quote__c = customerQuote.Id;
            }

            quoteLinesForUpsert.add(qliWrapperMap.get(qliWrapper).mainLine);
        }

        //Seperate dml statement needed to allow the parent child linkage.
        upsert quoteLinesForUpsert;

        List<SBQQ__QuoteLine__c> additionalDaysToDelete = new List<SBQQ__QuoteLine__c>();

        for(String qliWrapper : qliWrapperMap.keySet())
        {
            
            if(qliWrapperMap.get(qliWrapper).mainLine.SBQQ__Number__c == null)
            {
                qliWrapperMap.get(qliWrapper).mainLine.SBQQ__Number__c = (highestQuoteLineNumber+1);
                highestQuoteLineNumber += 1;

                quoteLines.add(qliWrapperMap.get(qliWrapper).mainLine);
            }
            
            system.debug('FIND IT HERE...' ) ;
            system.debug('IncludedConsultancyDays...' + IncludedConsultancyDays) ;
            system.debug('IncludedConsultancyProduct__c...' + qliWrapperMap.get(qliWrapper).PriceMatrixUsed.Included_Consultancy_Product__c);
            system.debug('includedDay...' + qliWrapperMap.get(qliWrapper).includedDay) ;
            system.debug('additionalDay...' + qliWrapperMap.get(qliWrapper).additionalDay) ;
            system.debug('Number_of_Complex_Site_Days__c...' + customerQuote.Number_of_Complex_Site_Days__c) ;

            //Additional lines added for consultancy products
            if(includedConsultancyDays != null && includedConsultancyDays > 0 && qliWrapperMap.get(qliWrapper).priceMatrixUsed.Included_Consultancy_Product__c != null && qliWrapperMap.get(qliWrapper).includedDay==null)
            {
                system.debug('**if includedConsultancyDays**: ' + includedConsultancyDays);
                SBQQ__QuoteLine__c includedConsultancyDaysLineItem = new SBQQ__QuoteLine__c();

                includedConsultancyDaysLineItem.SBQQ__Product__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Included_Consultancy_Product__c;
                includedConsultancyDaysLineItem.SBQQ__ProductOption__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Included_Product_Option__c;
                includedConsultancyDaysLineItem.SBQQ__SubscriptionTerm__c = qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
                includedConsultancyDaysLineItem.SBQQ__Quantity__c = includedConsultancyDays;
                includedConsultancyDaysLineItem.SBQQ__PricingMethod__c = 'Custom';
                includedConsultancyDaysLineItem.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                includedConsultancyDaysLineItem.SBQQ__CustomerPrice__c = 0;
                includedConsultancyDaysLineItem.SBQQ__ListPrice__c = 0;
                //The link to give the parent child line approach shown below
                includedConsultancyDaysLineItem.SBQQ__RequiredBy__c = qliWrapperMap.get(qliWrapper).mainLine.Id;
                includedConsultancyDaysLineItem.SBQQ__Group__c = qliWrapperMap.get(qliWrapper).assignedGroup.Id;

                includedConsultancyDaysLineItem.SBQQ__Quote__c = customerQuote.Id;

                //Set quoteLine Number to keep correct order within the UI.
                if(includedConsultancyDaysLineItem.SBQQ__Number__c == null)
                {
                    includedConsultancyDaysLineItem.SBQQ__Number__c = (highestQuoteLineNumber+1);
                    highestQuoteLineNumber += 1; 
                }

                quoteLines.add(includedConsultancyDaysLineItem);
            }
            
            /* Added - standard consultancy days */
            if(!tooManySitesOrEmployees && additionalConsultancyDays != null && additionalConsultancyDays > 0 && qliWrapperMap.get(qliWrapper).priceMatrixUsed != null && qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Consultancy_Product__c != null && qliWrapperMap.get(qliWrapper).additionalDay==null && (additionalConsultancyDays >0 || (customerQuote.Number_of_Complex_Site_Days__c != null && additionalConsultancyDays - customerQuote.Number_of_Complex_Site_Days__c >0) ) )
            {
                system.debug('**if additionalConsultancyDays 1**: ' + additionalConsultancyDays);
                SBQQ__QuoteLine__c additionalConsultancyDaysLineItem = new SBQQ__QuoteLine__c();


                additionalConsultancyDaysLineItem.SBQQ__Product__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Included_Consultancy_Product__c;
                additionalConsultancyDaysLineItem.SBQQ__ProductOption__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Included_Product_Option__c;
                additionalConsultancyDaysLineItem.SBQQ__SubscriptionTerm__c = qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
                additionalConsultancyDaysLineItem.SBQQ__Quantity__c = additionalConsultancyDays * (qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c/12);
                if(customerQuote.Number_of_Complex_Site_Days__c > 0) {
                	additionalConsultancyDaysLineItem.SBQQ__Quantity__c = (additionalConsultancyDays - customerQuote.Number_of_Complex_Site_Days__c) * (qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c/12) ;
                }
                additionalConsultancyDaysLineItem.SBQQ__PricingMethod__c = 'Custom';
                additionalConsultancyDaysLineItem.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                additionalConsultancyDaysLineItem.SBQQ__CustomerPrice__c = 875;
                additionalConsultancyDaysLineItem.SBQQ__ListPrice__c = 875.00 / 12.00;
                additionalConsultancyDaysLineItem.Initial_Payment__c = (875 *  additionalConsultancyDaysLineItem.SBQQ__Quantity__c) / qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
               
                //The link to give the parent child line approach shown below
                additionalConsultancyDaysLineItem.SBQQ__RequiredBy__c = qliWrapperMap.get(qliWrapper).mainLine.Id;
                additionalConsultancyDaysLineItem.SBQQ__Group__c = qliWrapperMap.get(qliWrapper).assignedGroup.Id;

                system.debug('customerQuote.Id: ' + customerQuote.Id);

                    additionalConsultancyDaysLineItem.SBQQ__Quote__c = customerQuote.Id;

                //Set quoteLine Number to keep correct order within the UI.
                if(additionalConsultancyDaysLineItem.SBQQ__Number__c == null)
                {
                    additionalConsultancyDaysLineItem.SBQQ__Number__c = (highestQuoteLineNumber+1);
                    highestQuoteLineNumber += 1; 
                }

                quoteLines.add(additionalConsultancyDaysLineItem);
            }


            if(!tooManySitesOrEmployees && additionalConsultancyDays > 0 && qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Consultancy_Product__c != null && qliWrapperMap.get(qliWrapper).additionalDay==null && customerQuote.Number_of_Complex_Site_Days__c > 0)
            {
                system.debug('**if additionalConsultancyDays 2**: ' + additionalConsultancyDays);
                SBQQ__QuoteLine__c additionalConsultancyDaysLineItem = new SBQQ__QuoteLine__c();


                additionalConsultancyDaysLineItem.SBQQ__Product__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Consultancy_Product__c;
                additionalConsultancyDaysLineItem.SBQQ__ProductOption__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Product_Option__c;
                additionalConsultancyDaysLineItem.SBQQ__SubscriptionTerm__c = qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
                additionalConsultancyDaysLineItem.SBQQ__Quantity__c = additionalConsultancyDays * (qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c/12);
                
                /* only use qty of complex consultancy days */
                if(customerQuote.Number_of_Complex_Site_Days__c !=additionalConsultancyDays && additionalConsultancyDays != null) {
                	additionalConsultancyDaysLineItem.SBQQ__Quantity__c = customerQuote.Number_of_Complex_Site_Days__c * (qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c/12);
                
                }
                additionalConsultancyDaysLineItem.SBQQ__PricingMethod__c = 'Custom';
                additionalConsultancyDaysLineItem.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                additionalConsultancyDaysLineItem.SBQQ__CustomerPrice__c = 875;
                additionalConsultancyDaysLineItem.SBQQ__ListPrice__c = 875.00 / 12.00;
                additionalConsultancyDaysLineItem.Initial_Payment__c = (875 *  additionalConsultancyDaysLineItem.SBQQ__Quantity__c) /  qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
             
                //The link to give the parent child line approach shown below
                additionalConsultancyDaysLineItem.SBQQ__RequiredBy__c = qliWrapperMap.get(qliWrapper).mainLine.Id;
                additionalConsultancyDaysLineItem.SBQQ__Group__c = qliWrapperMap.get(qliWrapper).assignedGroup.Id;

                system.debug('customerQuote.Id: ' + customerQuote.Id);

                    additionalConsultancyDaysLineItem.SBQQ__Quote__c = customerQuote.Id;

                //Set quoteLine Number to keep correct order within the UI.
                if(additionalConsultancyDaysLineItem.SBQQ__Number__c == null)
                {
                    additionalConsultancyDaysLineItem.SBQQ__Number__c = (highestQuoteLineNumber+1);
                    highestQuoteLineNumber += 1; 
                }

                quoteLines.add(additionalConsultancyDaysLineItem);
            }
            else if( additionalConsultancyDays > 0 && qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Consultancy_Product__c != null && qliWrapperMap.get(qliWrapper).additionalDay !=null)
            {
                
                system.debug('**else additionalConsultancyDays 3**: ' + additionalConsultancyDays);
                system.debug('**qliWrapperMap.get(qliWrapper).priceMatrixUsed**: ' + qliWrapperMap.get(qliWrapper).priceMatrixUsed.Id);
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__Product__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Consultancy_Product__c;
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__ProductOption__c = qliWrapperMap.get(qliWrapper).priceMatrixUsed.Additional_Product_Option__c;
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__SubscriptionTerm__c = qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c;
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__Quantity__c = additionalConsultancyDays * (qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c/12);
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__PricingMethod__c = 'Custom';
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__CustomerPrice__c = 875;
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__ListPrice__c = 875.00 / 12.00; 
                qliWrapperMap.get(qliWrapper).additionalDay.Initial_Payment__c = (875 *  (additionalConsultancyDays * (qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c/12))) /  qliWrapperMap.get(qliWrapper).mainLine.SBQQ__SubscriptionTerm__c ;
             
                //The link to give the parent child line approach shown below
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__RequiredBy__c = qliWrapperMap.get(qliWrapper).mainLine.Id;
                qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__Group__c = qliWrapperMap.get(qliWrapper).assignedGroup.Id;

                system.debug('customerQuote.Id: ' + customerQuote.Id);

                //Set quoteLine Number to keep correct order within the UI.
                if(qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__Number__c == null)
                {
                    qliWrapperMap.get(qliWrapper).additionalDay.SBQQ__Number__c = (highestQuoteLineNumber+1);
                    highestQuoteLineNumber += 1; 
                }

                quoteLines.add(qliWrapperMap.get(qliWrapper).additionalDay);
            }
            else if(qliWrapperMap.get(qliWrapper).additionalDay != null)
            {
                additionalDaysToDelete.add(additionalConsultancyDaysLine);
            }
        }

        delete additionalDaysToDelete;

        system.debug('quoteLines: ' + quoteLines);

        if(!quoteLines.isEmpty() && !test.isRunningTest())
        {
            upsert quoteLines;
        }
    }

    Map<String, Decimal> termCoefficientsMap3 = new Map<String, Decimal>();
    Map<String, Decimal> termCoefficientsMap7 = new Map<String, Decimal>();

    private void loadTermDetails()
    {
        termCoefficientsMap = new Map<String, CPQ_Term_Coefficient__c>();
        terms = new List<SelectOption>();

        for(CPQ_Term_Coefficient__c term : [Select Id, Name, Term__c, Coefficient__c, Requires_Approval__c, Term_Months__c From CPQ_Term_Coefficient__c Order By Term__c])
        {
            termCoefficientsMap.put(term.Name,term);
            terms.add(new SelectOption(term.Name, term.Name));
        }
        //terms.sort();
        
        termCoefficientsMap3.put('3 Years', 1);
        termCoefficientsMap3.put('5 Years', termCoefficientsMap.get('5 Years').Coefficient__c /  termCoefficientsMap.get('3 Years').Coefficient__c);
        termCoefficientsMap3.put('7 Years', termCoefficientsMap.get('7 Years').Coefficient__c /  termCoefficientsMap.get('3 Years').Coefficient__c);

        termCoefficientsMap7.put('7 Years', 1);
        termCoefficientsMap7.put('5 Years', termCoefficientsMap.get('5 Years').Coefficient__c /  termCoefficientsMap.get('7 Years').Coefficient__c);
        termCoefficientsMap7.put('3 Years', termCoefficientsMap.get('3 Years').Coefficient__c /  termCoefficientsMap.get('7 Years').Coefficient__c);
        
        termSelected='5 Years';
    }
    /*
    *   Pricing cached by 'ServiceType' to a list of
    *   Pricing_Matrix__c records, ordered by Number_of_Employees_Min__c
    *
    *   a helper method is used to quicly pull the price from this map based on 
    *   the service type and FTE count.
    */
    private void populatePricingMap(String sector)
    {
        pricingMatrixCache = new Map<String,List<Pricing_Matrix__c>>();

        for(Pricing_Matrix__c price : [SELECT   Best_Price__c, 
                                                Lowest_Price__c, 
                                                Number_of_Employees_Max__c, 
                                                Number_of_Employees_Min__c, 
                                                Included_Consultancy_Product__c,
                                                Additional_Consultancy_Product__c,
                                                Included_Product_Option__c,
                                                Additional_Product_Option__c,
                                                Sector_Grouping__c, 
                                                Service_Type__c,
                                                Product__c,
                                                Product__r.Name,
                                                Product__r.Pricing_Calculator_Product_Type__c
                                            FROM Pricing_Matrix__c
                                            WHERE Sector_Grouping__c = :sector
                                            ORDER BY Number_of_Employees_Min__c asc])
        {
            if(price.Service_Type__c != null)
            {
                if(price.Product__r.Pricing_Calculator_Product_Type__c == 'Combined Service')
                {
                    combinedServiceLabel = price.Product__r.Name;
                }
                else if(price.Product__r.Pricing_Calculator_Product_Type__c == 'Employment Law')
                {
                    employmentLawLabel = price.Product__r.Name;
                }
                else if(price.Product__r.Pricing_Calculator_Product_Type__c == 'Health & Safety')
                {
                    healthAndSafetyLabel = price.Product__r.Name;
                }
                if(!pricingMatrixCache.containsKey(price.Service_Type__c))
                {
                    pricingMatrixCache.put(price.Service_Type__c, new List<Pricing_Matrix__c>());
                }
                pricingMatrixCache.get(price.Service_Type__c).add(price);
            }
        }
    }

    private Pricing_Matrix__c getPricingObject(String serviceType, Decimal fte)
    {
        if(pricingMatrixCache.containsKey(serviceType))
        {
            for(Pricing_Matrix__c price : pricingMatrixCache.get(serviceType))
            {
                if(price.Number_of_Employees_Min__c <= fte && price.Number_of_Employees_Max__c >= fte)
                {
                    return price;
                }
                else if (fte > 100 && price.Number_of_Employees_Min__c >= 101 && price.Number_of_Employees_Max__c == null)
                {
                    return price;
                }
            }
            return null;
        }
        else
        {
            return null;
        }
    }

    private Decimal getPriceForDiscountLevel(Integer discountLevel, Decimal highestPrice, Decimal lowestPrice)
    {
        Decimal bandAmount = (highestPrice - lowestPrice) / 4;
        Decimal calculatedPrice = highestPrice;

        for(Integer i = 0; i < discountLevel; i++)
        {
            calculatedPrice = (calculatedPrice-bandAmount).round(RoundingMode.HALF_UP);
        }
        if(discountLevel==4)
        {
            calculatedPrice = lowestPrice;
        }
        return calculatedPrice;
    }

    /*
    *   Generate answer score for given service type, 
    *   calculate highest and lowest price, 
    *   work out the discount for the given level,
    *   multiply by the term coefficient then round for output
    */
    private Decimal getPrice(String serviceType, Decimal fte, Integer discountLevel, String term)
    {
        Decimal combinedAnswerScore = 0;
        Decimal healthAndSafetyAnswerScore = 0;
        Decimal employmentLawAnswerScore = 0;

        if(customerQuote.Proximity_of_sites__c == 'Isolated')
        {
            healthAndSafetyAnswerScore += 10;
            combinedAnswerScore += 10;
        }
        if (customerQuote.Incident_HSE_and_insurance_claim_history__c == 'Evidence of some issues')
        {
            healthAndSafetyAnswerScore += 10;
            combinedAnswerScore += 10;
        }
        if (customerQuote.Staff_turnover_starters_and_leavers__c == 'High turnover, above 20%')
        {
            employmentLawAnswerScore += 10;
            combinedAnswerScore += 10;
        }
        if (customerQuote.Tribunal_and_claim_history__c == 'Evidence of some issues')
        {
            employmentLawAnswerScore += 10;
            combinedAnswerScore += 10;
        }

        Decimal questionCoefficient = 0;
        Decimal maxWeightingBias = 0;
        if(serviceType == Bg_Constants.PRODUCT_COMBINED_SERVICE)
        {
            questionCoefficient = combinedAnswerScore;
            maxWeightingBias = 75;
        }
        else if( serviceType == Bg_Constants.PRODUCT_HEALTH_AND_SAFETY)
        {
            questionCoefficient = healthAndSafetyAnswerScore;
            maxWeightingBias = 55;
        }
        else if(serviceType == Bg_Constants.PRODUCT_EMPLOYMENT_LAW)
        {
            questionCoefficient = employmentLawAnswerScore;
            maxWeightingBias = 55;
        }

        Pricing_Matrix__c priceObject = getPricingObject(serviceType, fte);
        if(priceObject == null)
        {
            return 0;
        }

        Decimal highestPrice = priceObject.Best_Price__c;
        Decimal lowestPrice = priceObject.Lowest_Price__c + (((priceObject.Best_Price__c-priceObject.Lowest_Price__c)*(questionCoefficient/maxWeightingBias))/2);

        Decimal price = getPriceForDiscountLevel(discountLevel,highestPrice, lowestPrice)*termCoefficientsMap.get(term).Coefficient__c;
        price = price.round(system.RoundingMode.HALF_UP);
        return price;
    }

    private SBQQ__Quote__c getCustomerQuoteForId(Id quoteId, Id quoteLineId)
    {
        List<SBQQ__Quote__c> quotesFound = [Select 
                                                Id, 
                                                Name, 
                                                Proximity_of_sites__c, 
                                                Incident_HSE_and_insurance_claim_history__c, 
                                                Staff_turnover_starters_and_leavers__c, 
                                                Tribunal_and_claim_history__c, 
                                                SBQQ__Opportunity2__c, 
                                                SBQQ__Opportunity2__r.Name, 
                                                SBQQ__Opportunity2__r.AccountId,
                                                SBQQ__Opportunity2__r.Account.Name,
                                            	SBQQ__Opportunity2__r.Account.Sites__c,
                                                SBQQ__Opportunity2__r.Account.CitationSector__c,
                                                SBQQ__Opportunity2__r.Account.FT_Employees__c, 
                                                SBQQ__Opportunity2__r.Account.PT_Employees__c,
                                                SBQQ__Opportunity2__r.FT_Employees__c, 
                                                SBQQ__Opportunity2__r.PT_Employees__c,
                                                SBQQ__Opportunity2__r.OwnerId,
                                                SBQQ__Opportunity2__r.Owner.Name,
                                                SBQQ__Opportunity2__r.Number_Of_Sites__c,
                                                Number_of_Full_Time_Employees__c,
                                                Number_of_Part_Time_Employees__c,
                                                Number_of_Standard_Sites__c,
                                                Number_of_Sites_Opportunity__c,
                                                Number_of_Complex_Sites__c,
                                                Number_of_Complex_Site_Days__c,
                                                SBQQ__LineItemsGrouped__c,
                                                RecordTypeId, 
                                                RecordType.DeveloperName,
                                                (Select 
                                                    Id,
                                                    Name,
                                                    SBQQ__SubscriptionTerm__c, 
                                                    SBQQ__Product__c,
                                                    SBQQ__Product__r.Pricing_Calculator_Product_Type__c,
                                                    SBQQ__Number__c,
                                                    Number_of_Standard_Sites__c,
                                                    Number_of_Complex_Sites__c,
                                                    Number_of_Complex_Site_Days__c,
                                                    SBQQ__RequiredBy__c,
                                                    SBQQ__CustomerPrice__c,
                                                    SBQQ__ListPrice__c,
                                                    Quoted_Best_Price__c,
                                                    Quoted_4th_Price__c,
                                                    Quoted_3rd_Price__c,
                                                    Quoted_2nd_Price__c,
                                                    Quoted_Lowest_Price__c,
                                                    SBQQ__Quantity__c,
                                                    SBQQ__Quote__c,
                                                    SBQQ__PricingMethod__c,
                                                    SBQQ__SubscriptionPricing__c,
                                                    SBQQ__Group__c,
                                                    SBQQ__Group__r.SBQQ__Number__c,
                                                    SBQQ__Group__r.Id,
                                                    SBQQ__Group__r.Name
                                                From
                                                    SBQQ__LineItems__r)
                                            From 
                                                SBQQ__Quote__c
                                            Where 
                                                Id = :quoteId];
        system.debug('**Quotes**: ' + quotesFound);
        //Assign existing lines if we're coming in as an edit.
        if(quoteLineId != null)
        {
            for(SBQQ__QuoteLine__c existingQuoteLine : quotesFound[0].SBQQ__LineItems__r)
            {
                if(existingQuoteLine.Id == quoteLineId)
                {
                    System.debug('the same');
                    customerQuoteLine = existingQuoteLine;
                    if(existingQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c == 'Combined Service')
                    {
                        combinedServiceRate = existingQuoteLine.SBQQ__ListPrice__c;
                        combinedServiceSelected = true;
                        employmentLawSelected = false;
                        healthAndSafetySelected = false;
                    }
                    else if(existingQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c == 'Employment Law')
                    {
                        employmentLawRate = existingQuoteLine.SBQQ__ListPrice__c;
                        employmentLawSelected = true;
                        combinedServiceSelected = false;
                        healthAndSafetySelected = false;
                    }
                    else if(existingQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c == 'Health & Safety')
                    {
                        healthAndSafetyRate = existingQuoteLine.SBQQ__ListPrice__c;
                        healthAndSafetySelected = true;
                        employmentLawSelected = false;
                        combinedServiceSelected = false;

                    }
                }
                else if(existingQuoteLine.SBQQ__RequiredBy__c == quoteLineId && existingQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c == 'Consultancy Day')
                {
                    if(existingQuoteLine.SBQQ__CustomerPrice__c == 0)
                    {
                        includedConsultancyDaysLine = existingQuoteLine;
                    }
                    else
                    {
                        additionalConsultancyDaysLine = existingQuoteLine;
                    }
                }
            }
            if(customerQuoteLine.Id != null)
            {
                qliWrapperMap.put(customerQuoteLine.SBQQ__SubscriptionTerm__c/12+' - '+customerQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c, new QLIWrapper());
                qliWrapperMap.get(customerQuoteLine.SBQQ__SubscriptionTerm__c/12+' - '+customerQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c).mainLine = customerQuoteLine;
                qliWrapperMap.get(customerQuoteLine.SBQQ__SubscriptionTerm__c/12+' - '+customerQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c).includedDay = includedConsultancyDaysLine;
                qliWrapperMap.get(customerQuoteLine.SBQQ__SubscriptionTerm__c/12+' - '+customerQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c).additionalDay = additionalConsultancyDaysLine;
                qliWrapperMap.get(customerQuoteLine.SBQQ__SubscriptionTerm__c/12+' - '+customerQuoteLine.SBQQ__Product__r.Pricing_Calculator_Product_Type__c).assignedGroup = customerQuoteLine.SBQQ__Group__r;
            }
        }
        return quotesFound[0];
    }

    private Opportunity getOpportunityForId(Id oppId)
    {
        return [Select 
                    Id,
                    Name, 
                    AccountId,
                    Account.Name,
                    Account.CitationSector__c,
                    Account.FT_Employees__c, 
                    Account.PT_Employees__c,
                	Account.Sites__c,
                    FT_Employees__c, 
                    PT_Employees__c,
                    OwnerId,
                    Owner.Name,
                    Number_Of_Sites__c
                From 
                    Opportunity
                Where 
                    Id = :oppId];
    }

    public class QLIWrapper{
        public SBQQ__QuoteLineGroup__c assignedGroup;
        public SBQQ__QuoteLine__c mainLine;
        public SBQQ__QuoteLine__c includedDay;
        public SBQQ__QuoteLine__c additionalDay;

        public Pricing_Matrix__c priceMatrixUsed;
    }

    public class bg_PricingCalculatorException extends Exception { }

}