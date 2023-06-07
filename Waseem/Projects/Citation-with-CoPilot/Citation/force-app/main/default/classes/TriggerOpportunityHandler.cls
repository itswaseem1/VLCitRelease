/**
* @author Nimil Christopher
* @date 29 July 2013
* @description Event trigger handler 
*/

public with sharing class TriggerOpportunityHandler
{     
    public static void DoReferralChecks(list<id> idList) {
        
        //list<Opportunity> opportunityList = [select Referral_Lead_Paid__c,Referral_Deal_Paid__c,Interested_Products__c, id,Yearly_Total_Opportunity_Amount__c, leadpaid__c, referralpaid__c, referral_lead_payment__c, referral_deal_payment__c,amount,(select id, pricebookentry.product2.name, pricebookentry.product2.productcode from opportunitylineitems) from opportunity  where id in :idList and isclosed = false and Interested_Products__c <> null and Interested_Products__c <> '' ] ;
        list<Opportunity> opportunityList = [select leadSource,Referral_Lead_Paid__c,Referral_Deal_Paid__c,Interested_Products__c, id,Yearly_Total_Opportunity_Amount__c, leadpaid__c, referralpaid__c, referral_lead_payment__c, referral_deal_payment__c,amount,(select id, pricebookentry.product2.name, pricebookentry.product2.productcode, SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c from opportunitylineitems where SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c != 'CB-HRHS') from opportunity  where id in :idList and isclosed = false and (LeadSource like 'Ref_Employee%' ) and recordtype.name <> 'QMS' ] ;
    
        system.debug('RECORDS HERE ----> ' + Opportunitylist) ;
        //ReferringEmployeelookup__c
        boolean oppUpdate = false ;
        Referral_payment__c ref = new referral_payment__c() ;
            
        list<string> lstOppProducts = new list<string>() ;
        
        string ACVCode = '' ;
        List<opportunity> OppList = new list<Opportunity>() ;
        string OppProductList = '' ;
        
        decimal LeadPayment  ;
        decimal DealPayment  ;
        
        boolean HasReferralItems  ;
        opportunity oppreset = new opportunity() ;
         
        for(Opportunity o : OpportunityList) {
            lstOppProducts.clear() ;
            oppreset = new opportunity(id=o.id)  ;
            OppProductList = '' ;
            HasReferralItems = false ;
            
            system.debug('put list of opp product codes products into string so the rest can work as is ') ;
                for(OpportunityLineItem oli : o.OpportunityLineItems) {
                    OppProductList += oli.pricebookentry.product2.productcode  + ',';
                }
                
                system.debug('List of Products : ' + OppProductList) ;
                
                if(OppProductList != '') {
                    lstOppProducts = OppProductList.split(',') ;
                    LeadPayment = null ;
                    DealPayment = null ;
                    
                    for (string s : lstOppProducts) {
                        system.debug('Product code : ' + s) ;
                        ACVCode = '' ;
                        
                                
                                    try {
                                        ref = Referral_Payment__c.getvalues(s) ;
                                        system.debug('Payment amounts : ' + ref) ;
                                        if(Ref != null) {
                                            if(LeadPayment == null) {LeadPayment = 0;} 
                                            if(DealPayment == null) {DealPayment = 0;} 
                                            
                                            HasReferralItems = true ;
                                            system.debug('NEED TO POINT TO THE RIGHT PICKLIST/CHECKBOX FIELDS!') ;
                                            
                                            system.debug('Opportunity here -----------> ' + o) ;
                                            if((o.Referral_lead_Paid__c == 'No' ||o.Referral_lead_Paid__c == null ) /*&& ref.lead_payment__c >0 */  && (LeadPayment == 0 || ref.lead_payment__c > LeadPayment)) {
                                                
                                                                                                
                                                        LeadPayment = ref.lead_payment__c ;
                                                        system.debug('Do Lead Update' + ref.lead_payment__c + ' to ' + LeadPayment) ;   
                                                        oppupdate = true ;
                                                        
                                            }
                                            
                                            if((o.Referral_Deal_Paid__c == 'No' || o.Referral_Deal_Paid__c == null)/*&& ref.deal_payment__C > 0 */ && (DealPayment == 0 ||ref.deal_payment__C > DealPayment)) {
                                                
                                                        
                                                        DealPayment = ref.deal_payment__C ;
                                                        system.debug('Do Deal Update' + ref.deal_payment__C + ' to '  + DealPayment) ;
                                                        oppupdate = true ;
                                            }
                                        }
                                        if(o.Yearly_Total_Opportunity_Amount__c <= 1000){
                                            if(s.contains('CB1')){
                                                ACVCode = s + '.0';
                                            }else{
                                                ACVCode = s + '1.0';
                                            }                                               
                                        }
                                        
                                        if(o.Yearly_Total_Opportunity_Amount__c > 1000 && o.Yearly_Total_Opportunity_Amount__c <= 2000){
                                                ACVCode = s;
                                        }
                                        
                                        if(o.Yearly_Total_Opportunity_Amount__c  > 2000 && o.Yearly_Total_Opportunity_Amount__c <= 3000) {
                                                ACVCode = s + '2' ;
                                        }
                                             
                                        if(o.Yearly_Total_Opportunity_Amount__c > 3000 && o.Yearly_Total_Opportunity_Amount__c <= 4000) {
                                                ACVCode = s + '3' ;
                                        } 
                                            
                                        if(o.Yearly_Total_Opportunity_Amount__c > 4000)   {
                                                ACVCode = s + '4' ;
                                        }
                                        System.debug('ACVCode Value:::'+ACVCode);
                                        if(ACVCode != '')
                                             {
                                                    try {
                                                        ref = Referral_Payment__c.getValues(ACVCode);
                                                        system.debug('Finding ACV Value for : ' + ACVCode) ;
                                                                                            
                                                        if(ref != null ) {
                                                            HasReferralItems = true ;
                                                            if((o.Referral_lead_Paid__c == 'No'|| o.Referral_lead_Paid__c == null) && (LeadPayment == null || LeadPayment == 0||ref.lead_payment__C > LeadPayment)) {
                                                                LeadPayment = ref.lead_payment__C ;
                                                                oppupdate = true ;
                                                                system.debug('Do Lead ACV Payment of ' + ref.Lead_Payment__c) ;
                                                            } else  
                                                            system.debug('Deal Paid : ' + o.Referral_Deal_PAid__c) ;
                                                            System.debug('DealPayment after re:::'+DealPayment+' :::ref.deal_payment__c::: '+ref.deal_payment__c);
                                                            System.debug('Referral Deal::::'+o.Referral_Deal_Paid__c+':::DealPayment:::'+DealPayment);
                                                            if((o.Referral_Deal_Paid__c == 'No' || o.Referral_Deal_Paid__c == null  )&& (DealPayment == null || DealPayment == 0 || ref.deal_payment__c > DealPayment)) {
                                                                DealPayment = ref.deal_payment__c ;
                                                                oppupdate = true ;
                                                                system.debug('Do Deal ACV Payment of ' + ref.Deal_Payment__c);
                                                            }
                                                            if(ACVCode == 'CB1.0' || ACVCode == 'HS-Compliance1.0' || ACVCode == 'PEL1.0'){
                                                                DealPayment = ref.deal_payment__c ;
                                                                oppupdate = true;
                                                        }
                                                    }
                                                    }
                                                    catch (Exception ex) {
                                                        
                                                    }
                                                }   
                                        
                                    }
                                    
                                    catch (Exception ex) {
                                        
                                    }
                    } // end for prosuct list
                    
                    
                
                } // end if product list
                else {
                    if(((o.referral_Deal_Payment__c != null && (o.referral_Deal_Paid__c == 'No' || o.referral_Deal_Paid__c == null))|| (o.referral_Lead_Payment__C != null && (o.referral_Lead_Paid__c == 'No' || o.referral_Lead_Paid__c == null)))) {
                        
                        if(o.referral_Deal_Paid__c == 'No' || o.referral_Deal_Paid__c == null ) {
                            OppReset.referral_Deal_Payment__c = null ;
                        }
                        if(o.referral_Lead_Paid__c == 'No' || o.referral_Lead_Paid__c == null) {
                            OppReset.referral_Lead_Payment__c = null ;
                        }
                        OppList.add(OppReset) ;
                    } 
                }
                
                    
                    
                    
                    // if 
                    //if(oppupdate ==false && (o.referral_lead_payment__c != null || o.referral_deal_payment__C != null ) && (o.Referral_Deal_Paid__c != 'Not Required' || o.Referral_lead_Paid__c != 'Not Required')) {
                    //  OppList.add(new opportunity(id=o.id, referral_lead_payment__c = null, referral_deal_payment__C = null )) ;
                    //}
                
                    if(o.Referral_LEad_Paid__c == 'Not Required' || o.Referral_LEad_Paid__c == 'YES') {
                        LeadPayment = o.Referral_Lead_Payment__c ;
                    }
                    
                    if(o.Referral_Deal_Paid__c == 'Not Required' || o.Referral_Deal_Paid__c == 'YES') {
                        DealPayment = o.Referral_Deal_Payment__c ;  
                    }
                    
                    if(oppupdate == true && HasReferralItems == true &&  (LeadPayment <> o.referral_lead_payment__c || DealPayment <> o.referral_deal_payment__C)) {                    
                        system.debug('OppUpdate is true') ;
                        OppList.add(new opportunity(id=o.id, referral_lead_payment__c = LEadPayment, referral_deal_payment__C = DealPayment )) ;
                    }
                    
                    // if there are no referral items, then the payment fields need to be blank.
                    if(HasReferralItems == false && OppProductList != '' && (o.referral_lead_payment__c != null || o.referral_deal_payment__C != null )) {
                        system.debug('OppUpdate is false') ;
                        
                        OppList.add(new opportunity(id=o.id, referral_lead_payment__c = null, referral_deal_payment__C = null )) ;
                    }
                }  // end for
                
                if(OppList.size() > 0) {
                    system.debug('Opps to be updated' + OppList) ;
                    update OppList ;
                }
                
        } // end method

    /**
    * @author Raghunath Utpala
    * @date August 8th 2019
    * @description fired on Opportunity update
    * @return void
    * @param newObjects: trigger.new - list of all new records being inserted/updated
    * @param newObjectsMap: trigger.new - map of all new records that being inserted/updated
    * @param oldObjectsMap: trigger.old - map of all old records that being inserted/updated
    * @param isInsert : boolean variable to identify insert /update operation
    */
    public static void updateSalesMarketingChannel(List<Opportunity> newobjects,final Map<Id, Opportunity> newObjectsMap,final Map<Id, Opportunity> oldObjectsMap,boolean isInsert) {
        Map<String,String> prospectToMarketingChannel=new Map<String,String>();
        Map<String,String> ProspectToSalesChannel=new Map<String,String>();
        Set<String> channels=new Set<String>();
        Map<String,String> mapCampaignToOpportunity=new Map<String,String>();
        list<Group_Configuration__mdt> gcm = [select masterlabel,DeveloperName,Keywords__c from Group_Configuration__mdt];
        //system.debug(gcm);
        map<string,string> keyMap = new map<string,string>();
        for(Group_Configuration__mdt gm: gcm){
            if(gm.Keywords__c.containsAny(',')){
                
                list<string> kstring = gm.Keywords__c.split(',');
                for(string str: kstring){
                    keyMap.put(str,gm.masterLabel);
                }
            }
            else{
                keyMap.put(gm.Keywords__c,gm.masterLabel);
            }
           
        }
        //system.debug(keyMap.keySet());
        for(Opportunity opp:newobjects){
            if(opp.campaignId!=null){
             mapCampaignToOpportunity.put(opp.Id,opp.CampaignId);
            }
        }
        Map<Id,Campaign> mapCampaigns=new Map<Id,Campaign>([SELECT Id,Name from Campaign WHERE Id IN :mapCampaignToOpportunity.values()]);
        List<Prospect_Source_Data__mdt> prospectSourceMDT=new List<Prospect_Source_Data__mdt>();
        prospectSourceMDT=[SELECT Label,Marketing_Channel__c,Sales_Channel__c from Prospect_Source_Data__mdt];
        for(Prospect_Source_Data__mdt pmdt:prospectSourceMDT){
            prospectToMarketingChannel.put(pmdt.Label,pmdt.Marketing_Channel__c);
            ProspectToSalesChannel.put(pmdt.Label,pmdt.Sales_Channel__c);
            channels.add(pmdt.Sales_Channel__c);
        }
        for(Opportunity opp:newobjects){
            boolean scupdated=false;
            if(opp.LeadSource!=null && prospectToMarketingChannel.containsKey(opp.LeadSource)){
                opp.Marketing_Channel__c=prospectToMarketingChannel.get(opp.LeadSource);
            }
            if(opp.LeadSource==null || opp.LeadSource==''|| (opp.LeadSource!=null && !prospectToMarketingChannel.containsKey(opp.LeadSource))){
                opp.Marketing_Channel__c='';
            }
            
                for(string strMap: keyMap.keySet()){
                    if(opp.CampaignId!=null && mapCampaignToOpportunity.containsKey(opp.Id)){
                    	String campaignName=mapCampaigns.get(mapCampaignToOpportunity.get(opp.Id)).Name;
                    	if(campaignName.containsIgnoreCase(strMap)){
                            opp.Sales_Channel__c='Cross Sell';
                            scupdated=true;
                		}
                    }
                    if(opp.LeadSource!=null && opp.LeadSource.containsIgnoreCase(strMap) && !scupdated){
		                opp.Sales_Channel__c='Cross Sell';
        		        scupdated=true;
            		}
            		if(opp.Referred_By_Citation_Company__c!=null && opp.Referred_By_Citation_Company__c.containsIgnoreCase(strMap) && !scupdated){
                		opp.Sales_Channel__c='Cross Sell';
                		scupdated=true;
            		}
                    if(opp.Source__c !=null && opp.Source__c.containsIgnoreCase(strMap) && !scupdated){
                		opp.Sales_Channel__c='Cross Sell';
                		scupdated=true;
            		}
                    if(opp.Data_Supplier__c!=null && opp.Data_Supplier__c.containsIgnoreCase(strMap) && !scupdated){
                		opp.Sales_Channel__c='Cross Sell';
                		scupdated=true;
            		}
                    
            	}
            if(opp.LeadSource!=null && (opp.LeadSource.contains('SEM') || opp.LeadSource.contains('Seminar')) && !scupdated){
                opp.Sales_Channel__c='Seminar';
                scupdated=true;
            }
            if(opp.LeadSource!=null && opp.Sales_Criterion__c!=null && ProspectToSalesChannel.containsKey(opp.LeadSource) 
                && ProspectToSalesChannel.get(opp.LeadSource).equals('Outbound or Inbound') && !scupdated){
                opp.Sales_Channel__c=opp.Sales_Criterion__c;
                scupdated=true;
            }
            if(opp.LeadSource!=null && ProspectToSalesChannel.containsKey(opp.LeadSource) && !scupdated ){
                opp.Sales_Channel__c=ProspectToSalesChannel.get(opp.LeadSource);
                scupdated=true;
            }
            if(!scupdated){
                opp.Sales_Channel__c='Data Incomplete';
            }
        }
    }
    /**
    * @author Raghunath Utpala
    * @date August 8th 2019
    * @description fired on Renewal Opportunity creation
    * @return void
    **/
    public static void createQuotes(List<Opportunity> oppties){
        List<SBQQ__Quote__c> cpqQuotes=new List<SBQQ__Quote__c>();
        Id quoteRTID=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Client Relations Quote Standard').getRecordTypeId();
        Set<Id> acctIds=new Set<Id>();
        Set<Id> contractIds=new Set<Id>();
        for(Opportunity opp:oppties){
            acctIds.add(opp.AccountId);
            if(opp.Original_Contract__c!=null){
                contractIds.add(opp.Original_Contract__c);
            }
        }
        List<Account> accts=new List<Account>();
        accts=[SELECT Id,(Select Id from Contacts) from Account where ID IN :acctIds];
        Map<Id,Id> mapAccountToContact=new Map<Id,Id>();
        for(Account acct:accts){
            if(acct.contacts.size()>0){
                mapAccountToContact.put(acct.Id,acct.contacts[0].Id);
            }
        }
        Map<Id,List<ffbc__ContractLineItem__c>> mapContractToContractLineItems=new Map<Id,List<ffbc__ContractLineItem__c>>();
        List<ffbc__Contract__c> billingContracts=new List<ffbc__Contract__c>();
        if(!Test.isRunningTest())
        billingContracts=[SELECT Id,SF_Contract__c,SF_Contract__r.EndDate,ffbc__StartDate__c,ffbc__EndDate__c,Preferred_Payment_Date__c, (Select Id,ffbc__ProductService__c,ffbc__StartDate__c,ffbc__EndDate__c,ffbc__UnitPrice__c,ffbc__Quantity__c,ffbc__ProductService__r.ProductCode,ffbc__ProductService__r.Name from ffbc__ContractLineItems__r where  (NOT ffbc__ProductService__r.Name  like 'PAT%') and (NOT ffbc__ProductService__r.Name  like 'Fixed Wire%')) from ffbc__Contract__c where SF_Contract__c IN :contractIds and ffbc__Status__c='Active' order by createdDate desc limit 1];
        if(Test.isRunningTest()){
            billingContracts=[SELECT Id,SF_Contract__c,SF_Contract__r.EndDate,ffbc__StartDate__c,ffbc__EndDate__c,Preferred_Payment_Date__c, (Select Id,ffbc__ProductService__c,ffbc__StartDate__c,ffbc__EndDate__c,ffbc__UnitPrice__c,ffbc__Quantity__c,ffbc__ProductService__r.ProductCode,ffbc__ProductService__r.Name from ffbc__ContractLineItems__r where  (NOT ffbc__ProductService__r.Name  like 'PAT%') and (NOT ffbc__ProductService__r.Name  like 'Fixed Wire%')) from ffbc__Contract__c where SF_Contract__c IN :contractIds and ffbc__Status__c='Draft' order by createdDate desc limit 1];
        }
        Map<Id,ffbc__Contract__c> mapContractToBillingContract=new Map<Id,ffbc__Contract__c>();
        for(ffbc__Contract__c contract:billingContracts){
            mapContractToBillingContract.put(contract.SF_Contract__c,contract);
            for(ffbc__ContractLineItem__c ccline:contract.ffbc__ContractLineItems__r){
                if(mapContractToContractLineItems.containsKey(contract.SF_Contract__c)){
                    List<ffbc__ContractLineItem__c> contractLines=new List<ffbc__ContractLineItem__c>();
                    contractLines=mapContractToContractLineItems.get(contract.SF_Contract__c);
                    contractLines.add(ccline);
                    mapContractToContractLineItems.put(contract.SF_Contract__c,contractLines);
                }

                else{
                    List<ffbc__ContractLineItem__c> contractLines=new List<ffbc__ContractLineItem__c>();
                    contractLines.add(ccline);
                    mapContractToContractLineItems.put(contract.SF_Contract__c,contractLines);
                }
            }
        }
       Savepoint sp = Database.setSavepoint();
        try{
            SBQQ__QuoteTemplate__c qTemplate = [SELECT Id FROM SBQQ__QuoteTemplate__c WHERE Business_Type__c = 'Citation Client Relations' AND Template_Type__c = 'Quote' LIMIT 1];
            
            List<Opportunity> opps = [SELECT Id,AccountId,Original_Contract__c,Original_Contract__r.ContractTerm,Account.Industry,Account.BillingCountry FROM Opportunity where Id IN :oppties];
            for(Opportunity opp: opps){
                SBQQ__Quote__c cpqQuote=new SBQQ__Quote__c();
                cpqQuote.SBQQ__StartDate__c = (mapContractToBillingContract.get(opp.Original_Contract__c).SF_Contract__r.EndDate).addDays(1);
                cpqQuote.SBQQ__EndDate__c=cpqQuote.SBQQ__StartDate__c.addMonths(opp.Original_Contract__r.ContractTerm).addDays(-1);
                cpqQuote.Preferred_Payment_Date__c = mapContractToBillingContract.get(opp.Original_Contract__c).Preferred_Payment_Date__c;
                cpqQuote.SBQQ__QuoteTemplateId__c = qTemplate.Id;
                cpqQuote.Initial_Payment_Date__c = Date.newInstance(cpqQuote.SBQQ__StartDate__c.year(), cpqQuote.SBQQ__StartDate__c.month(), Integer.valueOf(cpqQuote.Preferred_Payment_Date__c));
                if(cpqQuote.SBQQ__StartDate__c > cpqQuote.Initial_Payment_Date__c){
                    cpqQuote.Initial_Payment_Date__c  = cpqQuote.Initial_Payment_Date__c.addMonths(1);
                }
                cpqQuote.SBQQ__Status__c = 'Draft';
                cpqQuote.SBQQ__Account__c = opp.AccountId;
                cpqQuote.SBQQ__Opportunity2__c = opp.Id;
                cpqQuote.RecordTypeId=quoteRTID;
                if(mapAccountToContact.containsKey(opp.AccountId)){
                    cpqQuote.SBQQ__PrimaryContact__c=mapAccountToContact.get(opp.AccountId);
                }
                cpqQuotes.add(cpqQuote);
            }
            opps = null;

            if(cpqQuotes.size()>0){
                insert cpqQuotes;
            }
            List<SBQQ__QuoteLineGroup__c> quoteLineGroups=new List<SBQQ__QuoteLineGroup__c>();
            for(SBQQ__Quote__c quote:cpqQuotes){
                SBQQ__QuoteLineGroup__c qlg=new SBQQ__QuoteLineGroup__c();
                qlg.Name='Current';
                qlg.SBQQ__Number__c=1;
                qlg.CurrencyIsoCode='GBP';
                qlg.SBQQ__ListTotal__c=0;
                qlg.SBQQ__SubscriptionTerm__c=quote.SBQQ__StartDate__c.monthsBetween(quote.SBQQ__EndDate__c);
                qlg.SBQQ__NetTotal__c=0;
                qlg.SBQQ__CustomerTotal__c=0;
                qlg.SBQQ__Quote__c=quote.Id;
                quoteLineGroups.add(qlg);
            }
            if(quoteLineGroups.size()>0){
                insert quoteLineGroups;
            }
            Map<Id,Id> mapQuoteToQuoteLineGroup=new Map<Id,Id>();
            for(SBQQ__QuoteLineGroup__c qlg:quoteLineGroups){
                mapQuoteToQuoteLineGroup.put(qlg.SBQQ__Quote__c,qlg.Id);
            }
            List<SBQQ__QuoteLine__c> quoteLines=new List<SBQQ__QuoteLine__c>();
            Set<String> listcoreProductCodes  = new Set<String>();
            listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));

            List<SBQQ__Quote__c> quotes = [select Id,SBQQ__Opportunity2__c,Preferred_Payment_Date__c,SBQQ__Opportunity2__r.Original_Contract__c,SBQQ__Opportunity2__r.Account.Industry,SBQQ__Opportunity2__r.Account.BillingCountry,SBQQ__StartDate__c,SBQQ__EndDate__c from SBQQ__Quote__c where Id IN :cpqQuotes ];

            for(SBQQ__Quote__c quote: quotes){
                Set<String> uniqueProductNames=new Set<String>();
                for(ffbc__ContractLineItem__c ccline:mapContractToContractLineItems.get(quote.SBQQ__Opportunity2__r.Original_Contract__c)){
                    uniqueProductNames.add(ccline.ffbc__ProductService__r.Name);
                    SBQQ__QuoteLine__c ql=new SBQQ__QuoteLine__c();
                    ql.SBQQ__Product__c=ccline.ffbc__ProductService__c;
                    ql.SBQQ__SubscriptionTerm__c=ccline.ffbc__StartDate__c.monthsBetween(ccline.ffbc__EndDate__c);
                    ql.SBQQ__StartDate__c = ql.Service_Start_Date__c = quote.SBQQ__StartDate__c;
                    ql.Billing_Start_Date__c = Date.newInstance(quote.SBQQ__StartDate__c.year(), quote.SBQQ__StartDate__c.month(), Integer.valueOf(quote.Preferred_Payment_Date__c));
                    if(quote.SBQQ__StartDate__c > ql.Billing_Start_Date__c ){
                        ql.Billing_Start_Date__c = ql.Billing_Start_Date__c.addMonths(1);
                    }
                    ql.SBQQ__Quote__c=quote.Id;
                    ql.SBQQ__Group__c=mapQuoteToQuoteLineGroup.get(quote.Id);
                    //Added by Srikanth Ragi
                    //The below line is mandatory to create a contract
                    ql.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    //ql.SBQQ__NetPrice__c=ccline.ffbc__UnitPrice__c*(ccline.ffbc__StartDate__c.monthsBetween(ccline.ffbc__EndDate__c));
                    if(listcoreProductCodes.contains(ccline.ffbc__ProductService__r.ProductCode)){
                        ql.SBQQ__SpecialPrice__c=ccline.ffbc__UnitPrice__c*1.05;
                        ql.SBQQ__ListPrice__c=ccline.ffbc__UnitPrice__c*1.05;
                    }
                    else{
                        ql.SBQQ__SpecialPrice__c=ccline.ffbc__UnitPrice__c;
                        ql.SBQQ__ListPrice__c=ccline.ffbc__UnitPrice__c;
                    }
                    ql.SBQQ__Quantity__c=ccline.ffbc__Quantity__c;
                    //ql.SBQQ__CustomerPrice__c=ccline.ffbc__UnitPrice__c*(ccline.ffbc__StartDate__c.monthsBetween(ccline.ffbc__EndDate__c));
                    //ql.SBQQ__RegularPrice__c=ccline.ffbc__UnitPrice__c;
                    quoteLines.add(ql);
                }
                //logic to get all the products based on the Atlas Sector  SDT-1485
                //Renewal Opportunity creation batch size is 1 
                List<Product_Atlas_Sector__mdt> productAtlasSectors=new List<Product_Atlas_Sector__mdt>();
                List<String> atlasSector=new List<String>{'Residential Home Adults','Domicillary Care','Care'};
                String industry=quote.SBQQ__Opportunity2__r.Account.Industry;
                String BillingCountry=quote.SBQQ__Opportunity2__r.Account.BillingCountry;
                String query='Select Atlas_Sector__c, Care_Policies__c, Country__c, CQC_Pro__c, DeveloperName, EAP__c, FRA_Repeat__c, FRA_Review__c, Id, Label, Language, MasterLabel, Mock_Inspections__c, NamespacePrefix, On_site_HR__c, On_site_HS__c, Product_Names__c, QualifiedApiName, Serial_Number__c, Upskill__c From Product_Atlas_Sector__mdt';
                if(quote.SBQQ__Opportunity2__r.Account.Industry.contains(atlasSector[0])
                  || quote.SBQQ__Opportunity2__r.Account.Industry.contains(atlasSector[1]) 
                  || quote.SBQQ__Opportunity2__r.Account.Industry.contains(atlasSector[2])){
                    query+=' WHERE Atlas_Sector__c=:industry AND Country__c=:BillingCountry';
                }
                else{
                    query+=' WHERE Atlas_Sector__c=:industry';
                }
                productAtlasSectors=(List<Product_Atlas_Sector__mdt>)Database.query(query);
                List<String> productNames=new List<String>();
                for(Product_Atlas_Sector__mdt productAtlas:productAtlasSectors){
                    for(String s:productAtlas.Product_Names__c.split(';')){
                        if(uniqueProductNames.add(s)){
                            productNames.add(s);
                        }
                    }
                    
                }
                List<Product2> products=new List<Product2>();
                products=[SELECT Id,Name,ProductCode FROM Product2 WHERE Name In :productNames and isActive=true];
                SBQQ__QuoteLineGroup__c qlg2=new SBQQ__QuoteLineGroup__c();
                if(!products.isEmpty()){
                    qlg2.Name='Proposed';
                    qlg2.SBQQ__Number__c=1;
                    qlg2.CurrencyIsoCode='GBP';
                    qlg2.SBQQ__ListTotal__c=0;
                    qlg2.SBQQ__SubscriptionTerm__c=quote.SBQQ__StartDate__c.monthsBetween(quote.SBQQ__EndDate__c);
                    qlg2.SBQQ__NetTotal__c=0;
                    qlg2.SBQQ__CustomerTotal__c=0;
                    qlg2.SBQQ__Quote__c=quote.Id;
                    insert qlg2;
                }
                List<PriceBookEntry> pbeList=new List<PriceBookEntry>();
                pbeList=[SELECT Id,UnitPrice,Product2Id FROM PriceBookEntry WHERE Product2Id In :products and Pricebook2.Name='Standard Price Book' and isActive=true];
                Map<Id,Decimal> mapProduct2Price=new Map<Id,Decimal>();
                for(PriceBookEntry pbe:pbeList){
                    mapProduct2Price.put(pbe.Product2Id,pbe.UnitPrice);
                }
                List<Product2> prods = [SELECT Id,Name,ProductCode FROM Product2 WHERE Name in :productNames ];
                for(Product2 prod: prods){
                    SBQQ__QuoteLine__c ql=new SBQQ__QuoteLine__c();
                    ql.SBQQ__Product__c=prod.Id;
                    ql.SBQQ__SubscriptionTerm__c=quote.SBQQ__StartDate__c.monthsBetween(quote.SBQQ__EndDate__c);
                    ql.SBQQ__StartDate__c=ql.Service_Start_Date__c=ql.Billing_Start_Date__c=quote.SBQQ__StartDate__c;
                    ql.Billing_Start_Date__c = Date.newInstance(quote.SBQQ__StartDate__c.year(), quote.SBQQ__StartDate__c.month(), Integer.valueOf(quote.Preferred_Payment_Date__c));
                    if(quote.SBQQ__StartDate__c > ql.Billing_Start_Date__c ){
                        ql.Billing_Start_Date__c = ql.Billing_Start_Date__c.addMonths(1);
                    }
                    ql.SBQQ__Quote__c=quote.Id;
                    ql.SBQQ__Group__c=qlg2.Id;
                    if(listcoreProductCodes.contains(prod.ProductCode)){
                        ql.SBQQ__SpecialPrice__c=mapProduct2Price.get(prod.Id)*1.05;
                        ql.SBQQ__ListPrice__c=mapProduct2Price.get(prod.Id)*1.05;
                    }
                    else{
                        ql.SBQQ__SpecialPrice__c=mapProduct2Price.get(prod.Id);
                        ql.SBQQ__ListPrice__c=mapProduct2Price.get(prod.Id);
                    }
                    ql.SBQQ__Quantity__c=1;
                    quoteLines.add(ql);
                }
                prods = null;

            }
            quotes = null;
            if(quoteLines.size()>0){
                insert quoteLines;
            }
        }
        catch(Exception e){
            System.debug('Error occured is'+e.getMessage() +'line number'+e.getLineNumber());
            GA_Event_Log__c log=new GA_Event_Log__c();
            log.CurrencyIsoCode='GBP';
            log.Event_Type__c=e.getTypeName();
            log.Exception_Details__c=e.getStackTraceString();
            log.Response__c='Error occured is'+e.getMessage() +' line number'+e.getLineNumber();
            insert log;
            Database.rollback(sp);
        }
    }
    /**
    * @author Raghunath Utpala
    * @date Nov 14th 2019
    * @description fired on Renewal Opportunity creation
    * this methods creates Sales Contract for Renewal Oppty of Type Auto . 
    * SDT-1779
    * @return void
    **/
    public static void createRenewalContractFromRenewalOppAuto(List<Opportunity> oppList){
        User salesSupportUser=[SELECT Id FROM User Where Name='Salesforce Support' limit 1];
	 //updated the record type get here from 'Auto Renewal Contract' to  'Client Relations Renewal Contract' as record type doesn't exist timm deployment of SDT-1779 and logic still inactive
        String renewalContractRecId=Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Renewal Contract').getRecordTypeId();
        List<Contract> renewalContractFromRenewalOppAuto=new List<Contract>();
        List<SBQQ__Subscription__c> subscriptionLines=new List<SBQQ__Subscription__c>();
        Map<Id,Id> mapRenewalOppToSalesContract=new Map<Id,Id>();
        Map<Id,ffbc__Contract__c> mapContractToBillingContract=new Map<Id,ffbc__Contract__c>();
        Set<Id> salesContractIds=new Set<Id>();
        Map<Id,Decimal> mapContractToBillingContractValue=new Map<Id,Decimal>();
        Map<Id,Decimal> mapContractToBillingContractUnitPrice=new Map<Id,Decimal>();
        Map<Id,Date> mapContractToStartDate=new Map<Id,Date>();
        Map<Id,Decimal> mapContractToContractTerm=new Map<Id,Decimal>();
        Savepoint sp = Database.setSavepoint();
        try{
        
        //prepare map of Opportunity to original sales contract.
        for(Opportunity opp:oppList){
            salesContractIds.add(opp.Original_Contract__c);
            mapRenewalOppToSalesContract.put(opp.Id,opp.Original_Contract__c);

        }
        
        // get all the original sales contracts.
        Map<Id,Contract> mapOriginalSalesContract=new Map<Id,Contract>([SELECT Id,AccountId,Account.Name
                                        ,Ts_Cs_Version__c
                                        ,Source_Opportunity__c
                                        ,Payment_Period__c
                                        ,Preferred_Payment_Date__c
                                        ,Initial_Payment2__c
                                        ,(Select Id,Preferred_Payment_Date__c from Contracts__r)
                                FROM Contract WHERE Id in :salesContractIds]);
        
        //prepare a map of sales contract to corresponding billing contract.
        //get the billing contract Ids, to fetch the corresponding billing contract lines.
        Set<Id> billingContractIds=new Set<Id>();
        for(Contract c:mapOriginalSalesContract.values()){
            if(c.Contracts__r.size()>0){
                mapContractToBillingContract.put(c.Id,c.Contracts__r[0]);
                billingContractIds.add(c.Contracts__r[0].Id);
            }                 
        }
        List<ffbc__ContractLineItem__c> billingContractLines=new List<ffbc__ContractLineItem__c>();
        Map<Id,List<ffbc__ContractLineItem__c>> mapBillingContractToLines=new Map<Id,List<ffbc__ContractLineItem__c>>();
        billingContractLines=[SELECT Id,Total_Billing_Terms__c,ffbc__ProductService__c,ffbc__Quantity__c,ffbc__UnitPrice__c,Service_End_Date__c,ffbc__Contract__c,ffbc__Contract__r.sf_Contract__c,ffbc__BillingType__c,ffbc__BillingTerm__r.Name,ffbc__BillingTerm__c from ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN :billingContractIds];
        
        //prepare a map of billing contract to corresponding billing contract lines.
        for(ffbc__ContractLineItem__c cline:billingContractLines){
            if(mapBillingContractToLines!=null 
               &&  mapBillingContractToLines.containsKey(cline.ffbc__Contract__c)){
                List<ffbc__ContractLineItem__c> clines=new List<ffbc__ContractLineItem__c>();
                clines=mapBillingContractToLines.get(cline.ffbc__Contract__c);
                clines.add(cline);
                mapBillingContractToLines.put(cline.ffbc__Contract__c,clines);

            }
            else{
                List<ffbc__ContractLineItem__c> clines=new List<ffbc__ContractLineItem__c>();
                clines.add(cline);
                mapBillingContractToLines.put(cline.ffbc__Contract__c,clines);

            }
        }
        //loop through the original sales contracts process the logic to get the Contract Term ,Start Date , Initial Payment and Contract Value.
        //Start Date of Contract = Billing Contract Line having longest end Date + 1 day
        //Contract Term = Billing Contract Line having the longest term
        //Initial Payment = Sum of all Unit Prices of billing contract lines
        //Contract Value = Sum of all Unit Prices * Term of billing contract lines.
        for(Contract c:mapOriginalSalesContract.values()){
            Date endDate;
            Decimal contractTerm=0;
            Decimal contractValue=0;
            Decimal unitPrice=0;
            if(mapBillingContractToLines!=null 
                && mapBillingContractToLines.containsKey(c.Contracts__r[0].Id)
                && mapBillingContractToLines.get(c.Contracts__r[0].Id).size()>0){
                endDate=mapBillingContractToLines.get(c.Contracts__r[0].Id)[0].Service_End_Date__c;
                contractTerm=mapBillingContractToLines.get(c.Contracts__r[0].Id)[0].Total_Billing_Terms__c;
                for(ffbc__ContractLineItem__c cline:mapBillingContractToLines.get(c.Contracts__r[0].Id)){
                    if(endDate!=null && endDate<cline.Service_End_Date__c){
                        endDate=cline.Service_End_Date__c;
                    }
                    if(contractTerm!=null && contractTerm<cline.Total_Billing_Terms__c){
                        contractTerm=cline.Total_Billing_Terms__c;
                    }
                    contractValue+=cline.ffbc__UnitPrice__c*cline.Total_Billing_Terms__c;
                    unitPrice+=cline.ffbc__UnitPrice__c;
                }
                mapContractToStartDate.put(c.Id,endDate);
                mapContractToContractTerm.put(c.Id,contractTerm);
                mapContractToBillingContractValue.put(c.Id,contractValue);
                mapContractToBillingContractUnitPrice.put(c.Id,unitPrice);
            }
        }

        for(Opportunity opp:oppList){
            Contract originalContract=new Contract();
            Contract renewalContract=new Contract();
            //start of renewal contract creation logic.
            if(mapRenewalOppToSalesContract!=null 
                && mapRenewalOppToSalesContract.containsKey(opp.Id) 
                && mapOriginalSalesContract!=null
                && mapRenewalOppToSalesContract.get(opp.Id)!=null
                && mapOriginalSalesContract.containsKey(mapRenewalOppToSalesContract.get(opp.Id))){
                originalContract=mapOriginalSalesContract.get(mapRenewalOppToSalesContract.get(opp.Id));
                renewalContract.AccountId=originalContract.AccountId;
                renewalContract.Ts_Cs_Version__c=originalContract.Ts_Cs_Version__c;
                renewalContract.Payment_Period__c=originalContract.Payment_Period__c;

                //logic to set the Start Date , Contract Term , Contract Value , Initial Payment on Renewal Contract.
                if(mapContractToStartDate!=null && mapContractToStartDate.containsKey(originalContract.Id)){
                    renewalContract.StartDate=mapContractToStartDate.get(originalContract.Id).addDays(1);
                }
                if(mapContractToContractTerm!=null && mapContractToContractTerm.containsKey(originalContract.Id)){
                    renewalContract.ContractTerm=Integer.valueOf(mapContractToContractTerm.get(originalContract.Id));
                }
                if(mapContractToBillingContractValue!=null && mapContractToBillingContractValue.containsKey(originalContract.Id)){
                    renewalContract.Contract_Value__c=renewalContract.Total_Contract_Value__c=mapContractToBillingContractValue.get(originalContract.Id);
                }
                if(mapContractToBillingContractUnitPrice!=null && mapContractToBillingContractUnitPrice.containsKey(originalContract.Id)){
                    renewalContract.Initial_Payment2__c=mapContractToBillingContractUnitPrice.get(originalContract.Id);
                }
            }
            //logic to set the Preferred Payment Date from Billing Contract.
            if(mapContractToBillingContract!=null
                && mapRenewalOppToSalesContract!=null
                && mapContractToBillingContract.containsKey(mapRenewalOppToSalesContract.get(opp.Id))){
                    ffbc__Contract__c bc=new ffbc__Contract__c();
                    bc=mapContractToBillingContract.get(mapRenewalOppToSalesContract.get(opp.Id));
                    renewalContract.Preferred_Payment_Date__c=bc.Preferred_Payment_Date__c;
            }
            renewalContract.RecordTypeId=renewalContractRecId;
            renewalContract.Status='Draft';
            renewalContract.CurrencyIsoCode='GBP';
            renewalContract.Source_Opportunity__c=opp.Id;
            renewalContract.Renewal_Type__c='Auto';
            renewalContract.Agreement_Type__c='Auto';
            renewalContract.Business_Type__c='Existing Business';
            renewalContract.CompanySignedDate=System.today();
            renewalContract.FOC_Period_Mths__c=0;
            renewalContract.FOC_Period_Mths_End__c=0;
            renewalContract.CompanySignedId=salesSupportUser.Id;
            renewalContract.OwnerId=salesSupportUser.Id;
            renewalContract.Name=originalContract.Account.Name+' - '+renewalContract.Renewal_Type__c+' - '+renewalContract.Business_Type__c+' - '+System.today().day()+'/'+System.today().month()+'/'+system.today().year();
            Integer preferredPaymentDay=Integer.valueOf(renewalContract.Preferred_Payment_Date__c);
            
            // Logic to update the Initial Payment Date on Contract
            // Initial Payment Dat = Next Date after Contract Start Date
            if(renewalContract.StartDate.day()>preferredPaymentDay){
                renewalContract.Initial_Payment_Date__c=Date.newInstance(renewalContract.startDate.addMonths(1).Year(),renewalContract.startDate.addMonths(1).month(),preferredPaymentDay);
            }
            else if(renewalContract.startDate.day()<preferredPaymentDay){
                renewalContract.Initial_Payment_Date__c=Date.newInstance(renewalContract.startDate.Year(), renewalContract.startDate.month(), preferredPaymentDay);
            }
            renewalContractFromRenewalOppAuto.add(renewalContract);

            //end of renewal contract creation logic.
        }

        if(!renewalContractFromRenewalOppAuto.isEmpty()){
            insert renewalContractFromRenewalOppAuto;
        }
        
        // start of subscription lines creation logic
        for(Contract c:renewalContractFromRenewalOppAuto){
            if(mapRenewalOppToSalesContract!=null
               && mapRenewalOppToSalesContract.containsKey(c.Source_Opportunity__c)
               && mapContractToBillingContract!=null 
               && mapContractToBillingContract.containsKey(mapRenewalOppToSalesContract.get(c.Source_Opportunity__c))
               && mapBillingContractToLines!=null 
               && mapBillingContractToLines.containsKey(mapContractToBillingContract.get(mapRenewalOppToSalesContract.get(c.Source_Opportunity__c)).Id)){
                   for(ffbc__ContractLineItem__c cline:mapBillingContractToLines.get(mapContractToBillingContract.get(mapRenewalOppToSalesContract.get(c.Source_Opportunity__c)).Id)){
                       SBQQ__Subscription__c subLine=new SBQQ__Subscription__c();
                       subLine.SBQQ__Contract__c=c.Id;
                       subLine.SBQQ__Account__c=c.AccountId;
                       if(cline.ffbc__BillingType__c=='One-off' && cline.ffbc__BillingTerm__c==null){
                           subLine.SBQQ__BillingFrequency__c='One-Off';
                       }
                       else if(cline.ffbc__BillingType__c=='Recurring Fixed'
                                && cline.ffbc__BillingTerm__c!=null
                                && cline.ffbc__BillingTerm__r.Name=='Monthly'){
                           subLine.SBQQ__BillingFrequency__c='Monthly';
                       }
                       else if(cline.ffbc__BillingType__c=='Recurring Fixed'
                                && cline.ffbc__BillingTerm__c!=null
                                && cline.ffbc__BillingTerm__r.Name=='Annual'){
                           subLine.SBQQ__BillingFrequency__c='Annual';
                       }
                       else if(cline.ffbc__BillingType__c=='Recurring Fixed'
                                && cline.ffbc__BillingTerm__c!=null
                                && cline.ffbc__BillingTerm__r.Name=='Quarterly'){
                           subLine.SBQQ__BillingFrequency__c='Quarterly';
                       }
                       else if(cline.ffbc__BillingType__c=='Recurring Fixed'
                                && cline.ffbc__BillingTerm__c!=null
                                && cline.ffbc__BillingTerm__r.Name=='Bi-annually'){
                           subLine.SBQQ__BillingFrequency__c='Bi-annually';
                       }
                       subLine.SBQQ__CustomerPrice__c=cline.ffbc__UnitPrice__c*cline.Total_Billing_Terms__c;
                       subLine.Initial_Payment_m__c=cline.ffbc__UnitPrice__c;
                       subLine.SBQQ__NetPrice__c=cline.ffbc__UnitPrice__c*cline.Total_Billing_Terms__c;
                       subLine.SBQQ__PricingMethod__c='Custom';
                       subLine.SBQQ__Product__c=cline.ffbc__ProductService__c;
                       subLine.SBQQ__Quantity__c=cline.ffbc__Quantity__c;
                       subLine.Regular_Payment_m__c=cline.ffbc__UnitPrice__c;
                       subLine.SBQQ__RegularPrice__c=cline.ffbc__UnitPrice__c*cline.Total_Billing_Terms__c;
                       subLine.Subscription_Term_m__c=cline.Total_Billing_Terms__c;
                       subLine.Service_Start_Date_m__c=cline.Service_End_Date__c.addDays(1);
                       subLine.SBQQ__SubscriptionStartDate__c=cline.Service_End_Date__c.addDays(1);
                       subLine.Service_End_Date_m__c=subLine.SBQQ__SubscriptionEndDate__c=subLine.SBQQ__SubscriptionStartDate__c.addMonths(Integer.valueOf(cline.Total_Billing_Terms__c)).addDays(-1);
                       subLine.SBQQ__SpecialPrice__c=cline.ffbc__UnitPrice__c;
                       subLine.FOC_Months_m__c=0;
                       subscriptionLines.add(subLine);
                   }
               }
        }
        if(!subscriptionLines.isEmpty()){
            insert subscriptionLines;
        }
        List<Contract> contractsToPendingStart=new List<Contract>();
        // end of subscrption lines creation logic.
        List<Contract> contracts  = [SELECT Id,status , (select Id,Name from SBQQ__Subscriptions__r) from Contract WHERE Id IN :renewalContractFromRenewalOppAuto];
        for(Contract c: contracts){
            if(c.SBQQ__Subscriptions__r.size()>0){
                c.status='Pending Start';
                contractsToPendingStart.add(c);
            }
        }
        contracts = null;
        if(!contractsToPendingStart.isEmpty()){
            update contractsToPendingStart;
        }

      }//try cblock close

      catch(Exception e){
          System.debug('Error occured is'+e.getMessage() +'line number'+e.getLineNumber());
          database.rollback(sp);
      }
    }
    
    /*
    * @date 18-07-2022
    * @description This Method is used to Updated Contracted checkbox on QMS opportunity upon checking New Service Form returned checkbox
    * @param List of Opportunities that are Updated,Map of Opportunities prior to Update(trigger.oldmap)
    * @return void(returns nothing)
    */
    public static void updateContractedonQMSOpp(List<Opportunity> updatedOpp,Map<Id,Opportunity> oldOppMap){
        //Set to store all QMS RecordType Ids
        Set<Id> qmsOppRecordTypeIds=new Set<Id>();
        qmsOppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS').getRecordTypeId());
        qmsOppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS Mid Contract Changes').getRecordTypeId());
        qmsOppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS Renewal').getRecordTypeId());
        //Loop through all Updated Opportunities and Updated Contracted checkbox if the QMS opportunity's New Service Form Returned is Checked 
        for(Opportunity eachUpdatedOpp:updatedOpp){
            if(qmsOppRecordTypeIds.contains(eachUpdatedOpp.RecordTypeId) && eachUpdatedOpp.New_Service_Form_Returned__c && eachUpdatedOpp.New_Service_Form_Returned__c!=oldOppMap.get(eachUpdatedOpp.Id).New_Service_Form_Returned__c){
               eachUpdatedOpp.SBQQ__Contracted__c=true; 
            }
        }
    }
} // end class