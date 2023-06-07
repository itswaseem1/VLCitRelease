/**********************************************************
*
* bg_PricingCalculatorControllerTest:
*
* Custom pricing calculator tests 
*
* Created By: Michael Fleming / Tom Morris (BrightGen)
* Created Date: 27-04-2017 
*
* Changes: KH 22/09/2017 (UAT Feedback)
* Changes: KH 01/10/2017 (Dev Completion Fixes)
***********************************************************/

@isTest
public with sharing class bg_PricingCalculatorControllerTest 
{
    private static final string PROFESSIONAL_SERVICES = 'Professional Services';

    private static final Decimal COMBINED_1_10_BEST = 500;
    private static final Decimal COMBINED_1_10_LOWEST = 300;

    private static final Decimal COMBINED_11_30_BEST = 600;
    private static final Decimal COMBINED_11_30_LOWEST = 400;

    private static final Decimal COMBINED_31_100_BEST = 700;
    private static final Decimal COMBINED_31_100_LOWEST = 500;

    private static final Decimal HEALTH_SAFETY_1_10_BEST = 300;
    private static final Decimal HEALTH_SAFETY_1_10_LOWEST = 200;

    private static final Decimal HEALTH_SAFETY_11_30_BEST = 400;
    private static final Decimal HEALTH_SAFETY_11_30_LOWEST = 250;

    private static final Decimal HEALTH_SAFETY_31_100_BEST = 500;
    private static final Decimal HEALTH_SAFETY_31_100_LOWEST = 300;

    private static final Decimal EMPLOYMENT_LAW_1_10_BEST = 250;
    private static final Decimal EMPLOYMENT_LAW_1_10_LOWEST = 150;

    private static final Decimal EMPLOYMENT_LAW_11_30_BEST = 300;
    private static final Decimal EMPLOYMENT_LAW_11_30_LOWEST = 200;

    private static final Decimal EMPLOYMENT_LAW_31_100_BEST = 400;
    private static final Decimal EMPLOYMENT_LAW_31_100_LOWEST = 250;

    private static final Decimal TERM_COEFFICIENT_3_YEAR = 1.12;
    private static final Decimal TERM_COEFFICIENT_5_YEAR = 1;
    private static final Decimal TERM_COEFFICIENT_7_YEAR = 0.95;

    @testSetup static void setup()
    {
        //create custom settings

            //Consultancy days
            List<CPQ_Included_Consultancy_Days__c> daysSettings = new List<CPQ_Included_Consultancy_Days__c>();
            daysSettings.add(createConsultancyDaysSetting(1,10,1));
            daysSettings.add(createConsultancyDaysSetting(11,30,2));
            daysSettings.add(createConsultancyDaysSetting(31,100,3));

            insert daysSettings;

            //terms
            List<CPQ_Term_Coefficient__c> termSettings = new List<CPQ_Term_Coefficient__c>();
            termSettings.add(createTermCoefficient(3, 36,  TERM_COEFFICIENT_3_YEAR));
            termSettings.add(createTermCoefficient(5, 60, TERM_COEFFICIENT_5_YEAR));
            termSettings.add(createTermCoefficient(7, 64, TERM_COEFFICIENT_7_YEAR));

            insert termSettings;

            //sector mappings   
            List<CPQ_Client_Sector__c> sectorSettings = new List<CPQ_Client_Sector__c>();
            sectorSettings.add(createSectorSetting('PROFESSIONAL ACTIVITIES', PROFESSIONAL_SERVICES));

            insert sectorSettings;

        //Create products
        List<Product2> products = new List<Product2>();
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        products.add(combinedProduct);
        Product2 healthAndSafetyProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, 'Consultation', 'Premium');
        products.add(healthAndSafetyProduct);
        Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
        products.add(employementLawProduct);
        Product2 consultancyProduct = bg_Product_TestUtils.createProduct('Consultancy Day', 'Consultation', 'Premium');
        products.add(consultancyProduct);

        insert products;

        //create price matrix 
        List<Pricing_Matrix__c> productPrices = new List<Pricing_Matrix__c>();

        productPrices.add(createPriceMatrix(combinedProduct, consultancyProduct, 1,10,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_COMBINED_SERVICE, COMBINED_1_10_BEST, COMBINED_1_10_LOWEST));
        productPrices.add(createPriceMatrix(combinedProduct, consultancyProduct, 11,30,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_COMBINED_SERVICE, COMBINED_11_30_BEST, COMBINED_11_30_LOWEST));
        productPrices.add(createPriceMatrix(combinedProduct, consultancyProduct, 31,100,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_COMBINED_SERVICE, COMBINED_31_100_BEST, COMBINED_31_100_LOWEST));

        productPrices.add(createPriceMatrix(healthAndSafetyProduct, consultancyProduct, 1,10,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, HEALTH_SAFETY_1_10_BEST, HEALTH_SAFETY_1_10_LOWEST));
        productPrices.add(createPriceMatrix(healthAndSafetyProduct, consultancyProduct, 11,30,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, HEALTH_SAFETY_11_30_BEST, HEALTH_SAFETY_11_30_LOWEST));
        productPrices.add(createPriceMatrix(healthAndSafetyProduct, consultancyProduct, 31,100,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, HEALTH_SAFETY_31_100_BEST, HEALTH_SAFETY_31_100_LOWEST));

        productPrices.add(createPriceMatrix(employementLawProduct, consultancyProduct, 1,10,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_EMPLOYMENT_LAW, EMPLOYMENT_LAW_1_10_BEST, EMPLOYMENT_LAW_1_10_LOWEST));
        productPrices.add(createPriceMatrix(employementLawProduct, consultancyProduct, 11,30,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_EMPLOYMENT_LAW, EMPLOYMENT_LAW_11_30_BEST, EMPLOYMENT_LAW_11_30_LOWEST));
        productPrices.add(createPriceMatrix(employementLawProduct, consultancyProduct, 31,100,PROFESSIONAL_SERVICES, Bg_Constants.PRODUCT_EMPLOYMENT_LAW, EMPLOYMENT_LAW_31_100_BEST, EMPLOYMENT_LAW_31_100_LOWEST));

        insert productPrices;
    }

    /*
    *   For all test methods the basic setup data that would exist in the org has been setup in @testSetup
    *   All other data, accounts, opps quotes etc will be created per method with differing variables
    */
    @isTest static void testBasicControllerProperties() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        Test.startTest();
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 0;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 0;
        testController.termSelected = '5 Years';
        testController.termSelectedMonths = 60;
        //testController.additionalConsultancyDaysMonthlyCost =;

       Test.stopTest();
        // 6 + ( part time / 3 ).roundUP() = 7 employees
        System.assertEquals(7,testController.numberOfFTE, 'the number of calculated employees is incorrect');
        System.assertEquals(2, testController.numberOfSites, 'only one site should be calculated ');
        System.assertEquals(1, testController.includedConsultancyDays, '1 day of consultancy should be included by the custom setting and therefore be counted as included');
        System.assertEquals(1, testController.additionalConsultancyDays, 'only 1 site was entered therefore only 1 day is required and this is included.');
        System.assertEquals(72.92, testController.additionalConsultancyDaysMonthlyCost);
        System.assertEquals(COMBINED_1_10_BEST, testController.combinedBestPrice, ' the combined best price should be the default in this scenario.');

        testController.cancel();
    }

    @isTest static void testGetCombinedPrices_1_10_ProfServices_NoAnswers()
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        Test.startTest();
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 0;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 0;
        testController.termSelected = '5 Years';

        Test.stopTest();

        System.assertEquals(7,testController.numberOfFTE, 'the number of calculated employees is incorrect');

        /*
        *   Testing prices calculations   - COMBINED 
        *   Best = 500
        *   Lowest = lowest + ( ( (best - lowest) * (questionScore / constant ) ) / 2 )
        *   therefore:
        *   Lowest = 300 + ( ( (200) * ( 0 / 75 ) )  / 2 )
        *          = 300 + ( ( 0 ) / 2 )
        *          = 300                    
        */
        System.assertEquals(COMBINED_1_10_BEST, testController.combinedBestPrice, ' the combined best price should be the default in this scenario.');
        System.assertEquals(COMBINED_1_10_LOWEST, testController.combinedLowestPrice, ' the combined lowest price should be the default in this scenario.');
        /*
        *   Increments should be:  Best - Lowest / 4
        *   these increments should be subtracted from the best price
        *   the increments should be rounded to the nearest whole number 
        *   after each increment is subtracted.
        *   Increments should be 50 in this case.
        */
        System.assertEquals(450, testController.combined4thPrice);
        System.assertEquals(400, testController.combined3rdPrice);
        System.assertEquals(300, testController.combined2ndPrice);

        /*
        *   Testing prices calculations   - HEALTH AND SAFETY
        *   Best = 300
        *   Lowest = 200
        */
        System.assertEquals(HEALTH_SAFETY_1_10_BEST, testController.healthAndSafetyBestPrice, ' the health and safety best price should be the default in this scenario.');
        System.assertEquals(HEALTH_SAFETY_1_10_LOWEST, testController.healthAndSafetyLowestPrice, ' the health and safety lowest price should be the default in this scenario.');
        /*
        *   Increments should be: 25
        */
        System.assertEquals(275, testController.healthAndSafety4thPrice);
        System.assertEquals(250, testController.healthAndSafety3rdPrice);
        System.assertEquals(200, testController.healthAndSafety2ndPrice);

        /*
        *   Testing prices calculations   - EMPLOYMENT LAW
        *   Best = 250
        *   Lowest = 150
        */
        System.assertEquals(EMPLOYMENT_LAW_1_10_BEST, testController.employmentLawBestPrice, ' the employment law best price should be the default in this scenario.');
        System.assertEquals(EMPLOYMENT_LAW_1_10_LOWEST, testController.employmentLawLowestPrice, ' the employment law lowest price should be the default in this scenario.');
        /*
        *   Increments should be: 25
        */
        System.assertEquals(225, testController.employmentLaw4thPrice);
        System.assertEquals(200, testController.employmentLaw3rdPrice);
        System.assertEquals(150, testController.employmentLaw2ndPrice);
    }

    @isTest static void testEndToEndForQuoteGeneration_CombinedServiceSingle5Years() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 0;
        testController.CustomerQuote.Number_of_Full_Time_Employees__c = 20 ;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 0;
        testController.termSelected = '5 Years';
        testController.termSelectedMonths = 60;
        /*
        *   Testing prices calculations   - COMBINED 
        *   Best = 500
        *   Lowest = 300    
        *   Increments = 50         
        */
        System.assertEquals(COMBINED_11_30_BEST, testController.combinedBestPrice, ' the combined best price should be the default in this scenario.');
        System.assertEquals(550, testController.combined4thPrice);
        System.assertEquals(500, testController.combined3rdPrice);
        System.assertEquals(450, testController.combined2ndPrice);
        System.assertEquals(COMBINED_11_30_LOWEST, testController.combinedLowestPrice, ' the combined lowest price should be the default in this scenario.');

        testController.combinedServiceSelected = true;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = false;
        testController.combinedServiceRate = 423.5;
        Test.startTest();
        testController.saveQuoteAndExit();
        Test.stopTest();
        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(2, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 consultancy line.');
    }

    

    @isTest static void testEndToEndForQuoteGeneration_CombinedServiceSingle3YearsMultiple() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);
	
        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 0;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 0;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.multipleLinesSelected = true;
        testController.combinedServiceSelected = true;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = false;
        testController.combinedServiceRate = 423.5;
        Test.startTest();
        testController.saveQuoteAndExit();
        Test.stopTest();
        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(9, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 consultancy line.');
    }

    @isTest static void testEndToEndForQuoteGeneration_CombinedServiceSingle7YearsMultiple() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 0;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 0;
        testController.termSelected = '7 Years';
        testController.termSelectedMonths = 84;
        testController.multipleLinesSelected = true;
        testController.combinedServiceSelected = true;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = false;
        testController.combinedServiceRate = 423.5;
        Test.startTest();
        testController.saveQuoteAndExit();
        Test.stopTest();
        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(9, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 consultancy line.');
    }

    @isTest static void testEndToEndForQuoteGeneration_HealthAndSafety5YearsSingle() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

       
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '5 Years';
        testController.termSelectedMonths = 60;

        /*
        *   Testing prices calculations   - HEALTH AND SAFETY 
        *   Best = 300
        *   Lowest = 200    
        *   Increments = 25         
        */
        System.assertEquals(HEALTH_SAFETY_1_10_BEST, testController.healthAndSafetyBestPrice, ' the health and safety best price should be the default in this scenario.');
        System.assertEquals(275, testController.healthAndSafety4thPrice);
        System.assertEquals(250, testController.healthAndSafety3rdPrice);
        System.assertEquals(200, testController.healthAndSafety2ndPrice);
        System.assertEquals(HEALTH_SAFETY_1_10_LOWEST, testController.healthAndSafetyLowestPrice, ' the health and safety lowest price should be the default in this scenario.');

        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
         Test.startTest();
        testController.saveQuoteAndExit();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        System.assert(quotesCreated[0].Requires_Approval__c,'the quote should require approval in this scenario as the price is outside lowest bound.');
        //System.assertEquals(3, quotesCreated[0].SBQQ__LineItems__r.size(), 'Approval required, so consultancy days should not have been added automatically');
   
    }

    @isTest static void testEndToEndForQuoteGeneration_HealthAndSafety7YearsMulti() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '7 Years';
        testController.termSelectedMonths = 84;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = true;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndExit();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(9, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

    @isTest static void testEndToEndForQuoteGeneration_HealthAndSafety5YearsMulti() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '5 Years';
        testController.termSelectedMonths = 60;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = true;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndExit();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(9, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

     @isTest static void testEndToEndForQuoteGeneration_HealthAndSafety3YearsMulti() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = true;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndExit();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(9, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

    @isTest static void testEndToEndForQuoteGeneration_EmploymentLaw7Years() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',35,18);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '7 Years';
        testController.termSelectedMonths = 84;

        /*
        *   Testing prices calculations   - EMPLOYMENT LAW (31-100)
        *   Best = 400
        *   Lowest = 250    
        *   Increments = 37.5   
        *
        *   Term 7 years = 0.95 multiplier
        *
        *   Values calculated are rounded AFTER subtracting each increment AND AFTER multiplying by the term.       
        */

        //400 * 0.95 = 380
        System.assertEquals(380, testController.employmentLawBestPrice);
        //363 (362.5 rounded to 363) * 0.95 = 344.85 = 345 (rounded)
        System.assertEquals(345, testController.employmentLaw4thPrice);
        //326 * 0.95 = 309.7 = 310
        System.assertEquals(310, testController.employmentLaw3rdPrice);
        //289 * 0.95 = 274.55 = 275
        System.assertEquals(275, testController.employmentLaw2ndPrice);
        //250 * 0.95 = 237.5 = 238
        System.assertEquals(238, testController.employmentLawLowestPrice);

        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = true;
        //Price below the lowest price will require approval
        testController.employmentLawRate = 399;
        Test.startTest();
        testController.saveQuoteAndAddMore();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(2, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

    @isTest static void testEndToEndForQuoteGeneration_EmploymentLaw7YearsMulti() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',35,18);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '7 Years';
        testController.termSelectedMonths = 84;
        testcontroller.multipleLinesSelected = true ;

        /*
        *   Testing prices calculations   - EMPLOYMENT LAW (31-100)
        *   Best = 400
        *   Lowest = 250    
        *   Increments = 37.5   
        *
        *   Term 7 years = 0.95 multiplier
        *
        *   Values calculated are rounded AFTER subtracting each increment AND AFTER multiplying by the term.       
        */

        //400 * 0.95 = 380
        System.assertEquals(380, testController.employmentLawBestPrice);
        //363 (362.5 rounded to 363) * 0.95 = 344.85 = 345 (rounded)
        System.assertEquals(345, testController.employmentLaw4thPrice);
        //326 * 0.95 = 309.7 = 310
        System.assertEquals(310, testController.employmentLaw3rdPrice);
        //289 * 0.95 = 274.55 = 275
        System.assertEquals(275, testController.employmentLaw2ndPrice);
        //250 * 0.95 = 237.5 = 238
        System.assertEquals(238, testController.employmentLawLowestPrice);

        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = true;
        //Price below the lowest price will require approval
        testController.employmentLawRate = 399;
        Test.startTest();
        testController.saveQuoteAndAddMore();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(6, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }


    @isTest static void testEndToEndForQuoteGeneration_EmploymentLaw3Years() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',35,18);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.multipleLinesSelected = true;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = true;
        //Price below the lowest price will require approval
        testController.employmentLawRate = 399;
        Test.startTest();
        testController.saveQuoteAndAddMore();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(6, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

    @isTest static void testEndToEndForQuoteGeneration_EmploymentLaw5Years() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',35,18);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 4;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 5;
        testController.termSelected = '5 Years';
        testController.termSelectedMonths = 60;
        testController.multipleLinesSelected = true;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = false;
        testController.employmentLawSelected = true;
        //Price below the lowest price will require approval
        testController.employmentLawRate = 399;
        Test.startTest();
        testController.saveQuoteAndAddMore();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(6, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

    /*
    *   Helper methods for creating data for tests
    *       Account
    *       Opportunity
    *       Quote
    */
    private static Account createAccount(String accName, String sector, Decimal fullTimeEmployees, Decimal partTimeEmployees)
    {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        insert pricebook;

        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 5000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
        acc.Sites__c = 2;
        //acc.AnnualRevenue = 123;
        
        insert acc;
        return acc;     
    }

    private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc)
    {
        bg_RecordTypeMap opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');         
        Opportunity o = new Opportunity();
        o.Name = opportunityName;
        if (recordtype == 'Default Citation Opportunity') {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Default Citation Opportunity'); 
        } else {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Small Business Package');
        } 
        o.AccountId = acc.id;
        o.Type = 'New Business';
        o.CloseDate = system.now().addMonths(1).date();
        o.Deal_Type__c = 'Combined';
        o.StageName = 'Provisional Approval';

        insert(o);
        return o;
    }

    /*
    *   Test setup helper methods
    */
    private static CPQ_Included_Consultancy_Days__c createConsultancyDaysSetting(Integer minEmployees, Integer maxEmployees, Integer freeConsultancyDays)
    {
        CPQ_Included_Consultancy_Days__c daysSetting = new CPQ_Included_Consultancy_Days__c();
        daysSetting.Name = minEmployees+'-'+maxEmployees;
        daysSetting.Number_of_Employees_Min__c = minEmployees;
        daysSetting.Number_of_Employees_Max__c = maxEmployees;
        daysSetting.Included_Consultancy_Days__c = freeConsultancyDays;

        return daysSetting;
    }

    private static CPQ_Term_Coefficient__c createTermCoefficient(Integer years, Integer months, Decimal coefficient)
    {
        CPQ_Term_Coefficient__c termSetting = new CPQ_Term_Coefficient__c();
        termSetting.Name = years+' Years';
        termSetting.Term__c = years;
        termSetting.Term_Months__c = months;
        termSetting.Coefficient__c = coefficient;
        termSetting.Requires_Approval__c = false;

        return termSetting;
    }

    private static CPQ_Client_Sector__c createSectorSetting(String sector, String sectorGroup)
    {
        CPQ_Client_Sector__c sectorSetting = new CPQ_Client_Sector__c();
        sectorSetting.Name = sector;
        sectorSetting.Client_Sector__c = sector;
        sectorSetting.Sector_Grouping__c = sectorGroup;

        return sectorSetting;
    }

    private static Pricing_Matrix__c createPriceMatrix(Product2 productPriced, Product2 consultancyProduct, Integer minEmployees, Integer maxEmployees, String sector, String serviceType, Decimal bestPrice, Decimal lowestPrice)
    {
        Pricing_Matrix__c priceRecord = new Pricing_Matrix__c();
        priceRecord.Name = serviceType+'-'+sector+'-'+minEmployees+'-'+maxEmployees;
        priceRecord.Best_Price__c = bestPrice;
        priceRecord.Lowest_Price__c = lowestPrice;
        priceRecord.Sector_Grouping__c = sector;
        priceRecord.Number_of_Employees_Min__c = minEmployees; 
        priceRecord.Number_of_Employees_Max__c = maxEmployees;
        priceRecord.Service_Type__c = serviceType;
        priceRecord.Product__c = productPriced.Id;
        priceRecord.Included_Consultancy_Product__c = consultancyProduct.Id;
        priceRecord.Additional_Consultancy_Product__c = consultancyProduct.Id;

        return priceRecord;
    }

    @isTest static void testEndToEndForQuoteGeneration_AllCoreServices() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 0;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 0;
        testController.termSelected = '5 Years';
        testController.termSelectedMonths = 60;

        testController.combinedServiceSelected = true;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = true;
        testController.multipleLinesSelected = true;
        testController.combinedServiceRate = 423.5;
        testController.employmentLawRate = 222.5;
        testController.healthAndSafetyRate = 210;
        Test.startTest();
        testController.saveQuoteAndExit();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(27, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 consultancy line.');
    }
    
     @isTest static void testEndToEndForQuoteGeneration_QLI() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 2;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 2;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = false;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndAddOthers();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(3, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }
    
    
    
    @isTest static void testEndToEndForQuoteGeneration_ExistingQLI_EmploymentLaw() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
         testQuote.Proximity_of_sites__c = 'Isolated';
        testQuote.Incident_HSE_and_insurance_claim_history__c = 'Evidence of some issues';
        testQuote.Staff_turnover_starters_and_leavers__c = 'High turnover, above 20%';
        testQuote.Tribunal_and_claim_history__c = 'Evidence of some issues';
		insert testQuote;

        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
		
        Product2 employementLawProduct = [SELECT id , Pricing_Calculator_Product_Type__c from Product2 WHERE Name  = 'Employment Law'];
        employementLawProduct.Pricing_Calculator_Product_Type__c = 'Employment Law';
        update employementLawProduct;
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = employementLawProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        insert quoteLine;

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('qlid', quoteLine.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 2;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 2;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = false;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndAddOthers();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(1, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }
    
    @isTest static void testEndToEndForQuoteGeneration_ExistingQLI_HS() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
        testQuote.Number_of_Complex_Sites__c =2;
		insert testQuote;

        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
		
        Product2 employementLawProduct = [SELECT id , Pricing_Calculator_Product_Type__c from Product2 WHERE Name  = 'Employment Law'];
        employementLawProduct.Pricing_Calculator_Product_Type__c = 'Health & Safety';
        update employementLawProduct;
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = employementLawProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        insert quoteLine;

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('qlid', quoteLine.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 2;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 2;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = true;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = true;
        testController.multipleLinesSelected = true;
        testController.combinedServiceRate = 4;
        testController.employmentLawRate = 5;
        testController.healthAndSafetyRate = 9;
        //Price below the lowest price will require approval
        Test.startTest();
        testController.saveQuoteAndAddOthers();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(1, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }
    
    @isTest static void testEndToEndForQuoteGeneration_ExistingQLI_CS() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
		insert testQuote;

        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
		
        Product2 employementLawProduct = [SELECT id , Pricing_Calculator_Product_Type__c from Product2 WHERE Name  = 'Employment Law'];
        employementLawProduct.Pricing_Calculator_Product_Type__c = 'Combined Service';
        update employementLawProduct;
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = employementLawProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        insert quoteLine;

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('qlid', quoteLine.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 2;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 2;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = false;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndAddOthers();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(1, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

	@isTest static void testEndToEndForQuoteGeneration_ExistingQLI_CD() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
		insert testQuote;

        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
        
        Product2 cd = [SELECT id , Pricing_Calculator_Product_Type__c from Product2 WHERE Name  = 'Consultancy Day'];
        cd.Pricing_Calculator_Product_Type__c = 'Consultancy Day';
        update cd;
        
		//Insert a SBQQ__QuoteLine__c record with SBQQ__Product__c as cd.Id and SBQQ__Quote__c as testQuote.Id
        TestDataFactory.getQuoteLines(testQuote.Id,cd.Id,testGroup.Id);
        List<SBQQ__QuoteLine__c> SBQQQuoteLineRecords1=[Select Id From SBQQ__QuoteLine__c Where
                                                       SBQQ__Product__c=:cd.Id AND 
                                                       SBQQ__Quote__c=:testQuote.Id];
        
        Product2 employementLawProduct = [SELECT id , Pricing_Calculator_Product_Type__c from Product2 WHERE Name  = 'Employment Law'];
        employementLawProduct.Pricing_Calculator_Product_Type__c = 'Employment Law';
        update employementLawProduct;
        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('qlid', SBQQQuoteLineRecords1[0].Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 2;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 2;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = false;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = false;
        testController.multipleLinesSelected = false;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 195;
        Test.startTest();
        testController.saveQuoteAndAddOthers();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(2, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }    
    
    @isTest static void testEndToEndForQuoteGeneration_ExistingQLI_ScoreChanges() 
    {
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        //Initialise page variables
        PageReference customPricingPage = Page.bg_PricingCalculator;
        Test.setCurrentPage(customPricingPage);
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
        testQuote.Proximity_of_sites__c = 'Isolated';
        testQuote.Incident_HSE_and_insurance_claim_history__c = 'Evidence of some issues';
        testQuote.Staff_turnover_starters_and_leavers__c = 'High turnover, above 20%';
        testQuote.Tribunal_and_claim_history__c = 'Evidence of some issues';
		insert testQuote;

        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
		
        Product2 employementLawProduct = [SELECT id , Pricing_Calculator_Product_Type__c from Product2 WHERE Name  = 'Employment Law'];
        employementLawProduct.Pricing_Calculator_Product_Type__c = 'Employment Law';
        update employementLawProduct;
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = employementLawProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        insert quoteLine;

        ApexPages.currentPage().getParameters().put('oid', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('qlid', quoteLine.Id);

        
        //Load controller
        bg_PricingCalculatorController testController = new bg_PricingCalculatorController();
        testController.customerQuoteLine.Number_of_Standard_Sites__c = 1;
        testController.customerQuoteLine.Number_of_Complex_Sites__c = 2;
        testController.customerQuoteLine.Number_of_Complex_Site_Days__c = 2;
        testController.termSelected = '3 Years';
        testController.termSelectedMonths = 36;
        testController.combinedServiceSelected = true;
        testController.healthAndSafetySelected = true;
        testController.employmentLawSelected = true;
        testController.multipleLinesSelected = true;
        //Price below the lowest price will require approval
        testController.healthAndSafetyRate = 5;
        Test.startTest();
        testController.saveQuoteAndAddOthers();

        Test.stopTest();

        List<SBQQ__Quote__c> quotesCreated = [Select
                                                    Id, 
                                                    Name, 
                                                    Proximity_of_sites__c, 
                                                    Incident_HSE_and_insurance_claim_history__c, 
                                                    Staff_turnover_starters_and_leavers__c, 
                                                    Tribunal_and_claim_history__c, 
                                                    SBQQ__Opportunity2__c,
                                                    Requires_Approval__c,
                                                    (Select 
                                                        Id,
                                                        Name,
                                                        SBQQ__SubscriptionTerm__c, 
                                                        SBQQ__Product__c,
                                                        SBQQ__Number__c
                                                    From
                                                        SBQQ__LineItems__r)
                                                From 
                                                    SBQQ__Quote__c];
        System.assertEquals(1, quotesCreated.size(), 'Only 1 quote should have been created.');
        //System.assertEquals(1, quotesCreated[0].SBQQ__LineItems__r.size(), 'Two quote lines should have been created, one product line + 1 included consultancy line + 0 additional consultancy line.');
    }

}