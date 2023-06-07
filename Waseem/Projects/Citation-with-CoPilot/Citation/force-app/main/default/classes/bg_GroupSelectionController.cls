/********************************************************************
* bg_GroupSelectionController:
*
* Custom controller for the Group Selection page, allows the user to 
* select the Option/Group of Products the customer would like to purchase
*
* Created By: Kash Hussain (BrightGen)
* Created Date: 20-05-2017 
*
* Changes:
********************************************************************/

public with sharing class bg_GroupSelectionController
{   

    public class selectionWrapper
    {
        public SBQQ__QuoteLineGroup__c qGroup {get; set;}
        public Boolean selected {get; set;}
        public Decimal suggestedInitialPayment {get; set;}
        
        public selectionWrapper(SBQQ__QuoteLineGroup__c qG, Decimal payment)
        {
            qGroup = qG;
            selected = false;
            suggestedInitialPayment = payment;
        }
    }

    public List<selectionWrapper> groupOptions {get; set;}
    public Id quoteID;
    public SBQQ__Quote__c customerQuote {get;set;}
    public Decimal calculatedInitialPayment  {get; set;}
    public boolean AGroupISSelected {get;set;} 

    public ApexPages.StandardController stdController;

    public bg_GroupSelectionController(ApexPages.StandardController standardController)
    {
        stdController = standardController;
        quoteID = stdController.getId();
        customerQuote = getQuoteForId(quoteID);
        calculatedInitialPayment = 0;
        decimal foc = 0 ;/* FOC tweak */
        integer i = 0 ;
        Boolean SelectGroup = false ;

        if(customerQuote.SBQQ__Opportunity2__c == null )
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This Quote is not linked to an Opportunity.'));
        }
        else
        {
            List<SBQQ__QuoteLineGroup__c> options = [SELECT Id, SBQQ__Number__c, Name, SBQQ__Quote__c, SBQQ__Optional__c, SBQQ__Description__c, Opportunity_ID__c, SBQQ__SubscriptionTerm__c, 
                                                        (SELECT Id, sbqq__product__r.business_Type__c,Sub_Lines_Total_Monthly_Payment__c,SBQQ__ProductCode__c, Name, SBQQ__Quantity__c, SBQQ__Description__c, Price_per_Billing_Frequency__c, Term__c, SBQQ__ProductName__c, SBQQ__ProductFamily__c, SBQQ__SubscriptionTerm__c,
                                                        SBQQ__CustomerTotal__c, SBQQ__StartDate__c, Service_Start_Date__c ,billing_start_date__c, Initial_Payment__c, FOC_Months__c, PRICE__c,sbqq__product__r.SBQQ__BillingFrequency__c, Billing_Frequency__c, regular_payment__c,SBQQ__RequiredBy__c 
                                                        FROM SBQQ__LineItems__r where (sbqq__product__r.business_type__c != 'QMS') or (sbqq__product__r.business_type__c = 'QMS' and sbqq__requiredby__c = null))
                                                        , SBQQ__Quote__r.SBQQ__StartDate__c 
                                                        , SBQQ__Quote__r.Initial_Payment_Date__c /* added for recalc total initial by date */ 
                                                        , SBQQ__Quote__r.Quotelines_Max_Term__c
                                                    FROM SBQQ__QuoteLineGroup__c 
                                                    WHERE SBQQ__Quote__c = : quoteID];
                                                     /* extra field added to query */
                                                     
            if (Options.size() == 1) {
                SelectGroup = true ;
            }
            groupOptions = new List<selectionWrapper>();

            for (SBQQ__QuoteLineGroup__c quoteGroup : options)
            {
                Decimal initialPayment = 0;
                foc = 0.0 ;/* FOC tweak*/
                i = 0 ;
                for(SBQQ__QuoteLine__c quoteLine : quoteGroup.SBQQ__LineItems__r)
                {
                    
                    if(quoteline.SBQQ__ProductName__c == 'Free Month') {/* FOC tweak*/
                        foc = quoteline.SBQQ__Quantity__c ;/*FOC tweak*/
                        system.debug('CNC HERE!!!') ;
                        quoteGroup.SBQQ__LineItems__r.remove(i) ; /*FOC tweak */
                    }/*FOC tweak */
                    i++ ;
                }

                for(SBQQ__QuoteLine__c quoteLine : quoteGroup.SBQQ__LineItems__r)
                {
                    if (quoteline.foc_months__c == null || quoteline.foc_months__c == 0)
                    {
                    //quoteline.foc_months__c = foc ; 
                    
                        /* quoteLine.SBQQ__StartDate__c previously used below*/
                        if (quoteLine.billing_Start_Date__c == customerQuote.SBQQ__StartDate__c && quoteLine.Price_per_Billing_Frequency__c != null)
                        {
                            if(QuoteLine.sbqq__product__r.business_type__c == 'QMS') {
                                if(quoteline.Sub_Lines_Total_Monthly_Payment__c >0) {
                                    initialPayment += quoteline.Sub_Lines_Total_Monthly_Payment__c ;
                                }
                                
                            }
                            else {
                                 initialPayment += quoteLine.Price_per_Billing_Frequency__c;
                            }
                        }
                    }
                }   

                selectionWrapper wrap = new selectionWrapper(quoteGroup, initialPayment);
                if(SelectGroup == true) {
                    wrap.selected = true ;
                }
                groupOptions.add(wrap);
            }
        }
        
    }

    public void quickSave()
    {
        for (selectionWrapper quoteGroup : groupOptions)    
        {           
            quoteGroup.suggestedInitialPayment = 0;
            for(SBQQ__QuoteLine__c quoteLine : quoteGroup.qGroup.SBQQ__LineItems__r)
            {
                if (quoteline.foc_months__c == null || quoteline.foc_months__c == 0)
                    {
                    system.debug('**Start Date**: ' + quoteLine.SBQQ__StartDate__c);
               // if (quoteLine.SBQQ__StartDate__c == customerQuote.SBQQ__StartDate__c && quoteLine.Price_per_Billing_Frequency__c != null)
                            if ( quoteLine.Regular_Payment__c!= 0)
                            {
                                if(quoteline.sbqq__product__r.business_type__c == 'QMS') {
                                    if(quoteline.Sub_Lines_Total_Monthly_Payment__c >0) {
                                        quoteline.initial_payment__c = quoteline.Sub_Lines_Total_Monthly_Payment__c ;
                                    }   
                                }
                                else {
                                    quoteline.Initial_Payment__c = quoteLine.Regular_Payment__c;
                                }
                              
                                system.debug('reg != 0------->'+ quoteLine.SBQQ__ProductCode__c + quoteLine.initial_payment__c) ;
                                quoteGroup.suggestedInitialPayment += quoteLine.Regular_Payment__c;
                            }
                            else
                            {
                                 system.debug('reg == 0------->'+ quoteLine.SBQQ__ProductCode__c + quoteLine.initial_payment__c) ;
                                 quoteGroup.suggestedInitialPayment += quoteLine.Regular_Payment__c;
                            }
                }   
            }
        }
    }

    public void calculateProposedInitialPayment()
    {
        calculatedInitialPayment = 0;
        for (selectionWrapper quoteGroup : groupOptions)    
        {
            if (quoteGroup.selected)
            {
                quoteGroup.suggestedInitialPayment = 0;
                for(SBQQ__QuoteLine__c quoteLine : quoteGroup.qGroup.SBQQ__LineItems__r)
                {
                    system.debug(quoteLine.initial_payment__c + ' ' + quoteline.Billing_Start_Date__c + ' ' + customerQuote.Initial_Payment_Date__c) ;
                   // if (quoteLine.SBQQ__StartDate__c == customerQuote.SBQQ__StartDate__c)
                  //  {
                       // calculatedInitialPayment += quoteLine.Price_per_Billing_Frequency__c;
                       // line below used to use quoteline.SBQQ__StartDate__c 
                        if(quoteLine.initial_payment__c != null && quoteline.Billing_Start_Date__c == customerQuote.Initial_Payment_Date__c) { /* extra condition added to match data against initial payment date on quote to cope with FOC motnhs and offest billign start*/
                                 calculatedInitialPayment += quoteLine.Initial_Payment__c;
                                 }
                   // }  
                   system.debug( calculatedInitialPayment );
                }
            }
        }
    }

    public PageReference save()
    {
       
        AGroupISSelected = false ;
        try
        {
            
            list<Date> contractCSDate = new list<Date>();
            List<SBQQ__QuoteLineGroup__c> quoteGroupsToUpdate = new List<SBQQ__QuoteLineGroup__c>();
            List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
            SBQQ__Quote__c parentQuote = new SBQQ__Quote__c();
            set<id> ProdId = new set<id>();
            map<id,SBQQ__QuoteLine__c> mapProdQuoteLine = new map<id,SBQQ__QuoteLine__c>();
            Decimal summedInitialPayment = 0;
            decimal summedQuoteInitialPayment = 0 ;
            for (selectionWrapper quoteGroup : groupOptions)    
            {
                if (!quoteGroup.selected)
                {
                    SBQQ__QuoteLineGroup__c lineGroup = new SBQQ__QuoteLineGroup__c();
                    lineGroup.Id = quoteGroup.qGroup.Id;
                    linegroup.sbqq__Subscriptionterm__c = quotegroup.qgroup.SBQQ__Subscriptionterm__c ;
                    lineGroup.SBQQ__Optional__c = true;
                    
                    quoteGroupsToUpdate.add(lineGroup);
                }
                else
                {
                    AGroupISSelected = true ;
                    SBQQ__QuoteLineGroup__c lineGroup = new SBQQ__QuoteLineGroup__c();
                    lineGroup.Id = quoteGroup.qGroup.Id;
                    lineGroup.SBQQ__Optional__c = false;
                    quoteGroupsToUpdate.add(lineGroup);

                    for(SBQQ__QuoteLine__c quoteLine : quoteGroup.qGroup.SBQQ__LineItems__r)
                    {
                        SBQQ__QuoteLine__c newLine = new SBQQ__QuoteLine__c();
                        newLine.SBQQ__StartDate__c = quoteLine.SBQQ__StartDate__c;
                        
                        if(quoteLine.SBQQ__ProductCode__c != 'Free-Month'){
                            contractCSDate.add(quoteLine.SBQQ__StartDate__c);
                        }
                        
                        if(quoteLine.service_start_date__c != null) {
                            newline.service_start_date__c = quoteLine.service_start_date__c ;
                        }
                        
                        /* new criteria added here for sdt180*/
                        if(quoteLine.billing_start_date__c != null) {
                            newline.billing_start_date__c = quoteLine.billing_start_date__c ;
                        }
                        
                        newLine.Id = quoteLine.Id;
                        newLine.SBQQ__Optional__c =  false;
                        /* line added by Chris C */
                        newLine.Initial_payment__c = quoteline.Initial_payment__c ;
                        newLine.SBQQ__Product__c = quoteline.SBQQ__Product__c ;
                        
                        
                        newLine.FOC_Months__c = quoteline.FOC_Months__c ;
                        if(quoteLine.SBQQ__ProductCode__c == 'CB1' || quoteLine.SBQQ__ProductCode__c == 'HS-Compliance' || quoteLine.SBQQ__ProductCode__c == 'PEL'){
                            system.debug('+++CB1'+quoteLine);
                            ProdId.add(quoteline.SBQQ__Product__c);
                            mapProdQuoteLine.put(quoteline.SBQQ__Product__c,quoteline);
                            system.debug('ProdId+MapProdIdQuoteLine'+ProdId+mapProdQuoteLine);
                        }
                        quoteLinesToUpdate.add(newLine);
                        system.debug('QuoteLine here!! ' + quoteline) ;
                        system.debug('Startdate here!! ' + quotegroup.qGroup.SBQQ__Quote__r.SBQQ__StartDate__c) ;
                        system.debug('quoteline startdate here!! ' + quoteLine.SBQQ__StartDate__c) ;
                        system.debug('quoteline initial payment here!! ' + quoteline.Initial_payment__c) ;
                        /* line added by Chris C */
                        if (quotegroup.qGroup.SBQQ__Quote__r.SBQQ__StartDate__c != null &&
                            quoteLine.SBQQ__StartDate__c!= null
                            /* does the croteria below need to be in??!!! */
                           // &&  quoteGroup.qGroup.SBQQ__Quote__r.SBQQ__StartDate__c == quoteLine.SBQQ__StartDate__c
                           ) {
                            if(quoteline.Initial_payment__c != null) {
                                summedQuoteInitialPayment += quoteline.Initial_payment__c ;
                            }
                        }
                        
                        
                    }
 
                    summedInitialPayment += quoteGroup.suggestedInitialPayment;
                    system.debug('summedInitialPayment here!! ' + summedInitialPayment) ;                   
                    system.debug('summedQuoteInitialPayment here!! ' + summedQuoteInitialPayment) ;
                    
                }
            }

            if(!AGroupISSelected) {
                string GroupErrorMessage = System.label.CPQ_Group_Selection_Error;
                 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, GroupErrorMessage));
                 return null;
                
            }

            if (!quoteGroupsToUpdate.isEmpty())
            {
                update quoteGroupsToUpdate;
            }

           /* if (!quoteLinesToUpdate.isEmpty())
            {
                system.debug('quoteLinesToUpdate+++'+quoteLinesToUpdate);  
                update quoteLinesToUpdate;
                system.debug('after+UpquoteLinesToUpdate+++'+quoteLinesToUpdate);
            }*/

            //SBQQ__Quote__c parentQuote = new SBQQ__Quote__c();
            parentQuote.Id = quoteID;
            parentQuote.SBQQ__ContractingMethod__c = 'Single Contract';
            parentQuote.Contract_Generated__c = true;
            contractCSDate.sort();
            parentQuote.Custom_Contract_Date__c = !contractCSDate.isempty()?contractCSDate.get(0):null;
          //parentQuote.Initial_Payment__c = summedInitialPayment;
          //  parentQuote.Initial_Payment__c = summedQuoteInitialPayment;
             parentQuote.Initial_Payment__c = calculatedInitialPayment ;


            /*if (customerQuote.Record_Type_Name__c == 'Quote_Standard')
            {
                Map<String,Id> contractTemplateMap = new Map<String,Id>();
                for(SBQQ__QuoteTemplate__c objQuoteTemp: [SELECT Id,Name FROM SBQQ__QuoteTemplate__c WHERE Business_Type__c = 'CitationBDM' AND Template_Type__c = 'Contract']){
                    contractTemplateMap.put(objQuoteTemp.Name, objQuoteTemp.Id);
                }
                if(System.Label.Partnership_Standard_Contract_Template_Access.split(',').contains(UserInfo.getUserId())){
                    parentQuote.SBQQ__QuoteTemplateId__c = contractTemplateMap.get('Partnerships Standard Contract'); 
                }else{
                   parentQuote.SBQQ__QuoteTemplateId__c = contractTemplateMap.get('Citation Standard Contract'); 
                }
            }
            else*/ if (customerQuote.Record_Type_Name__c == 'QMS_Quote_Approved')
            {
                SBQQ__QuoteTemplate__c qTemplate;
                if (customerQuote.SBQQ__BillingFrequency__c == 'Direct Debit' )
                {
                    qTemplate = [SELECT Id FROM SBQQ__QuoteTemplate__c WHERE Business_Type__c = 'QMS' AND Template_Type__c = 'Contract' AND Template_Sub_Type__c = 'DD' LIMIT 1];
                    parentQuote.SBQQ__QuoteTemplateId__c = qTemplate.Id;
                }
                else
                {
                    qTemplate = [SELECT Id FROM SBQQ__QuoteTemplate__c WHERE Business_Type__c = 'QMS' AND Template_Type__c = 'Contract' AND Template_Sub_Type__c = 'Non DD' LIMIT 1];
                    parentQuote.SBQQ__QuoteTemplateId__c = qTemplate.Id;
                }
            }
            
                 
            update parentQuote;
            
            system.debug('parent quote here!! ' + parentQuote) ;
            list<SBQQ__ProductOption__c> productOptionList = [select SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,id from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c In: ProdId];
            map<id,SBQQ__ProductOption__c> mapPrdOption = new map<id,SBQQ__ProductOption__c>();
            for(SBQQ__ProductOption__c SPO:productOptionList ){
                    mapPrdOption.put(SPO.SBQQ__OptionalSKU__c,SPO);
            }
            if (!quoteLinesToUpdate.isEmpty())
            {
                for(SBQQ__QuoteLine__c qt:quoteLinesToUpdate){
                    if(mapPrdOption.containsKey(qt.SBQQ__Product__c)){
                        
                        qt.SBQQ__StartDate__c = mapProdQuoteLine.get(mapPrdOption.get(qt.SBQQ__Product__c).SBQQ__ConfiguredSKU__c).SBQQ__StartDate__c;
                        system.debug('Inside of for'+qt);
                    }
                    
                }
                system.debug('quoteLinesToUpdate+++'+quoteLinesToUpdate);  
                update quoteLinesToUpdate;
                system.debug('after+UpquoteLinesToUpdate+++'+quoteLinesToUpdate);
            }
            Opportunity opp = new Opportunity();
            opp.Id = customerQuote.SBQQ__Opportunity2__c;
            opp.SBQQ__Contracted__c = true;
            update opp;

            return new PageReference('/'+quoteID);
        }
        catch (Exception e)
        {
            system.debug('**e**: ' + e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            //return null;
            throw e;
        }
    }

    private SBQQ__Quote__c getQuoteForId(Id quoteId)
    {
        List<SBQQ__Quote__c> quotesReturned = [Select Id, Name, Record_Type_Name__c, SBQQ__Account__r.Name, Initial_Payment__c, SBQQ__Opportunity2__c, SBQQ__StartDate__c, SBQQ__Opportunity2__r.SBQQ__Contracted__c, Owner_Department__c, Initial_Payment_Date__c, Preferred_Payment_Date__c, Payment_Period__c, SBQQ__BillingFrequency__c From SBQQ__Quote__c Where Id = :quoteId];

        if(quotesReturned.size() == 1)
        {
            return quotesReturned[0];
        }
        else
        {
            return null;
        }
    }
}