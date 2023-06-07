@isTest
public class TriggerOpportunityHandlerTest 
{
    @isTest
    public static void executeData(){
        Id oppoRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal / Retention Opportunity - Non-Auto').getRecordTypeId();
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id,StageName,Original_Contract__c,AccountId,Account.Name,Account.Industry,Account.BillingCountry FROM Opportunity WHERE RecordTypeId=:oppoRecordTypeName]; 
        TriggerOpportunityHandler.createQuotes(oppList);
        Test.stopTest();
    }
    
    @isTest
    public static void CreateRenewalContractTest(){
        Id oppoRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal / Retention Opportunity - Non-Auto').getRecordTypeId();
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id,StageName,Original_Contract__c,AccountId,Account.Name,Account.Industry,Account.BillingCountry FROM Opportunity WHERE RecordTypeId=:oppoRecordTypeName]; 
        TriggerOpportunityHandler.createQuotes(oppList);
        TriggerOpportunityHandler.createRenewalContractFromRenewalOppAuto(oppList);
        Test.stopTest();
    }

    /**
     * @date 18-07-2022
     * @description This Method is used to Test Contracted checkbox on QMS opportunity upon checking New Service Form returned checkbox
     * @param No Parameters
     * @return void(returns nothing)
	*/
    @isTest public static void verifyContractedQMSopp()
    {
        //QMS RecordType Id of Opportunity
        Id qmsOppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS').getRecordTypeId();
        
        //Call generateAccountWithContacts method of TestDataFactory to Insert Contacts and Accounts
        List<Contact> contactsInserted=TestDataFactory.generateAccountWithContacts('Verify',1,'Verify','ContractedContact',true);
        //Call generateOppsForAccount method of TestDataFactory to fetch Opportunites
        List<Opportunity> opportunitestoUpdate=TestDataFactory.generateOppsForAccount(contactsInserted[0].AccountId, 1000, 2, true);
        List<Pricebook2> priceBooksInserted=TestDataFactory.getPricebooks();

        SBQQ__Quote__c quoteforOpportunityOne=TestDataFactory.getQuotesNoDML(opportunitestoUpdate[0].Id,contactsInserted[0].AccountId,contactsInserted[0].Id,priceBooksinserted[0].Id);
        SBQQ__Quote__c quoteforOpportunityTwo=TestDataFactory.getQuotesNoDML(opportunitestoUpdate[1].Id,contactsInserted[0].AccountId,contactsInserted[0].Id,priceBooksinserted[0].Id);
        insert new List<SBQQ__Quote__c>{quoteforOpportunityOne, quoteforOpportunityTwo};

        List<OpportunityContactRole> opportunityCRtoInsert=new List<OpportunityContactRole>();
        //assign Opportunity with New Service form Returned as true
        for(Opportunity eachOpp:opportunitestoUpdate){
            OpportunityContactRole oppcr=new OpportunityContactRole(OpportunityId=eachOpp.Id,IsPrimary=true,ContactId=contactsInserted[0].Id);
            opportunityCRtoInsert.add(oppcr);
            eachOpp.RecordTypeId=qmsOppRecordTypeId;
        }
        
        //insert Opportunitycontactrole records
        insert opportunityCRtoInsert;
        Test.startTest();
        //Update Oppotunities
        opportunitestoUpdate[0].New_Service_Form_Returned__c=true;
        Update opportunitestoUpdate;
        Test.stopTest();
        //Query the inserted Opportunites
        List<Opportunity> insertedOpportunities=[Select Id,New_Service_Form_Returned__c,SBQQ__Contracted__c From Opportunity where AccountId=:contactsInserted[0].AccountId];
        System.assertEquals(insertedOpportunities[0].New_Service_Form_Returned__c, insertedOpportunities[0].SBQQ__Contracted__c, 'Contracted is same as NewServiceFormReturned');
        System.assertEquals(insertedOpportunities[1].New_Service_Form_Returned__c, insertedOpportunities[1].SBQQ__Contracted__c, 'Contracted is same as NewServiceFormReturned');
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on Values in Source__c on opportunity
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOpportunityforSource(){
        //List to store all Opportunities to Insert
        List<Opportunity> oppstoInsert=new List<Opportunity>();
        //List of String values fron Group_Configuration__mdt Records
        List<string> keyMap = verifySalesChannelonOppHelper();
        //Insert Account that needs to be tagged to Opportunity
        List<Account> accountforOpp=TestDataFactory.getAccounts(1,'TestAccounttoVerifySalesChannelonOpportunity',true);
        //Opportunities to Test Sales Channel Based on different Values in Source
        if(!accountforOpp.isEmpty()){
            List<Opportunity> oppwithSource=TestDataFactory.generateOppsForAccount(accountforOpp[0].Id,100,keyMap.size(),false);
            //Update the Source__c for all the Opportunites with Strings from Group_Configuration__mdt Records
            for(Integer i=0;i<keyMap.size();i++){
                oppwithSource[i].Source__c= keyMap[i];
                oppstoInsert.add(oppwithSource[i]);
            }
            //Insert Opportunities
            Test.startTest();
            insert oppstoInsert;
            Test.stopTest();
            //Get all the Opportunities inserted to Verify SalesChannel
            List<Opportunity> opportunitiesInserted=[Select Id,Sales_Channel__c,Data_Supplier__c,Source__c From Opportunity where Id IN :oppstoInsert];
            //All above opportunities should have SalesChannel as "Cross Sell"
            for(Opportunity eachOpportunity: opportunitiesInserted){
                System.assertEquals('Cross Sell',eachOpportunity.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachOpportunity.Sales_Channel__c+'Where Source is '+eachOpportunity.Source__c);
            }
        }
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on Values in Data_Supplier__c on opportunity
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOpportunityforDataSupplier(){
        //List to store all Opportunities to Insert
        List<Opportunity> oppstoInsert=new List<Opportunity>();
        //List of String values fron Group_Configuration__mdt Records
        List<string> keyMap = verifySalesChannelonOppHelper();
        //Insert Account that needs to be tagged to Opportunity
        List<Account> accountforOpp=TestDataFactory.getAccounts(1,'TestAccounttoVerifySalesChannelonOpportunity',true);
        //Opportunities to Test Sales Channel Based on different Values in Source
        if(!accountforOpp.isEmpty()){
            //Opportunities to Test Sales Channel Based on different Values in Data Supplier
            List<Opportunity> oppwithDataSupplier=TestDataFactory.generateOppsForAccount(accountforOpp[0].Id,100,keyMap.size(),false);
            //Update the Data_Supplier__c for all the Opportunites with Strings from Group_Configuration__mdt Records
            for(Integer i=0;i<keyMap.size();i++){
                oppwithDataSupplier[i].Data_Supplier__c= keyMap[i];
                oppstoInsert.add(oppwithDataSupplier[i]);
            }
            //Insert Opportunities
            Test.startTest();
            insert oppstoInsert;
            Test.stopTest();
            //Get all the Opportunities inserted to Verify SalesChannel
            List<Opportunity> opportunitiesInserted=[Select Id,Sales_Channel__c,Data_Supplier__c,Source__c From Opportunity where Id IN :oppstoInsert];
            //All above opportunities should have SalesChannel as "Cross Sell"
            for(Opportunity eachOpportunity: opportunitiesInserted){
                System.assertEquals('Cross Sell',eachOpportunity.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachOpportunity.Sales_Channel__c+'Where Data_Supplier__C is '+eachOpportunity.Data_Supplier__c);
            }
        }
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on PrimaryCampaignSource on Opportunity
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOppBasedonPrimaryCampaignSource(){
        //List to store all Opportunities to Insert
        List<Opportunity> oppstoInsert=new List<Opportunity>();
        //List to store all Campaigns to Insert
        List<Campaign> campaignforPrimaryCampaignSource=new List<Campaign>();
        //List of String values from Group_Configuration__mdt Records
        List<string> keyMap = verifySalesChannelonOppHelper();
        //Insert Account that needs to be tagged to Opportunity
        List<Account> accountforOpp=TestDataFactory.getAccounts(1,'TestAccounttoVerifySalesChannelonOpportunity',true);
        if(!accountforOpp.isEmpty()){
            //Opportunities to Test Sales Channel Based on different Values Present in Name of the Campaign tagged in Primary Campaign Source
            List<Opportunity> oppwithPrimaryCampaignSource=TestDataFactory.generateOppsForAccount(accountforOpp[0].Id,100,keyMap.size(),false);
            //Insert Campaigns with Names in the Strings from Group_Configuration__mdt Records
            for(Integer i=0;i<keyMap.size();i++){
                campaignforPrimaryCampaignSource.addAll(TestDataFactory.getCampaigns(1,keyMap[i],'Test',false));
            }
            //insert Campaign to tag to Opportunities
            insert campaignforPrimaryCampaignSource;
            //Update the CampaignId for all the Opportunites with above Inserted Campaigns
            for(Integer i=0;i<campaignforPrimaryCampaignSource.size();i++){
                oppwithPrimaryCampaignSource[i].CampaignId=campaignforPrimaryCampaignSource[i].Id;
                oppstoInsert.add(oppwithPrimaryCampaignSource[i]);
            }
            //Insert Opportunities
            Test.startTest();
            if(!oppstoInsert.isEmpty()){
                insert oppstoInsert;
            }
            Test.stopTest();
            //Get all the Opportunities inserted to Verify SalesChannel
            List<Opportunity> opportunitiesInserted=[Select Id,Sales_Channel__c,Campaign.Name From Opportunity where Id IN :oppstoInsert];
            //All above opportunities should have SalesChannel as "Cross Sell"
            for(Opportunity eachOpportunity: opportunitiesInserted){
                System.assertEquals('Cross Sell',eachOpportunity.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachOpportunity.Sales_Channel__c+' Where Campaign Name is '+eachOpportunity.Campaign.Name);
            }
        }
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on LeadSource on Opportunity
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOppBasedonLeadSource(){
        //List to store all Opportunities to Insert
        List<Opportunity> oppstoInsert=new List<Opportunity>();
        //All Picklist Values of LeadSource that are related to the values in Group_Configuration__mdt Records
        List<String> LeadSourcedesirredValues=new List<String>{'Cross Sell - Mitigate','Cross Sell - Mitigate','ELAS','Cross Sell_uCheck','EPM Cross Sell','Food Alert','HS Direct','Cross Sell_iHASCO','Cross Sell_P&R','Cross Sell - QMS','Cross Sell_SMAS','Cross Sell - Southalls'};
        //Insert Account that needs to be tagged to Opportunity
        List<Account> accountforOpp=TestDataFactory.getAccounts(1,'TestAccounttoVerifySalesChannelonOpportunity',true);
        if(!accountforOpp.isEmpty()){
            //Opportunities to Test Sales Channel Based on different Values in LeadSource
            List<Opportunity> oppwithLeadSource=TestDataFactory.generateOppsForAccount(accountforOpp[0].Id,100,LeadSourcedesirredValues.size(),false);
            //Update the LeadSource for all the Opportunites with Picklist Values in LeadSourcedesirredValues List
            for(Integer i=0;i<LeadSourcedesirredValues.size();i++){
                oppwithLeadSource[i].LeadSource=LeadSourcedesirredValues[i];
                oppstoInsert.add(oppwithLeadSource[i]);
            }
            //Insert Opportunity
            Test.startTest();
            insert oppstoInsert;
            Test.stopTest();
            //Get all the Opportunities inserted to Verify SalesChannel
            List<Opportunity> opportunitiesInserted=[Select Id,Sales_Channel__c,LeadSource From Opportunity where Id IN :oppstoInsert];
            //All above opportunities should have SalesChannel as "Cross Sell"
            for(Opportunity eachOpportunity: opportunitiesInserted){
                System.assertEquals('Cross Sell',eachOpportunity.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachOpportunity.Sales_Channel__c+' Where LeadSource is '+eachOpportunity.LeadSource);
            }
        }
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on Referred_By_Citation_Company__c on Opportunity
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOppBasedonReferredbyCitationCompany(){
        //List to store all Opportunities to Insert
        List<Opportunity> oppstoInsert=new List<Opportunity>();
        //All Picklist Values of Referred_By_Citation_Company__c that are related to the values in Group_Configuration__mdt Records
        List<String> ReferredbyccdesirredValues=new List<String>{'QMS','ELAS','EPM','Food Alert','HS Direct','EL Direct','iHASCO','QMS','SMAS','Southalls','uCheck','Mitigate'};
        //Insert Account that needs to be tagged to Opportunity
        List<Account> accountforOpp=TestDataFactory.getAccounts(1,'TestAccounttoVerifySalesChannelonOpportunity',true);
        if(!accountforOpp.isEmpty()){
            //Opportunities to Test Sales Channel Based on different Values in "Referred By Citation Company"
            List<Opportunity> oppwithReferredbycc=TestDataFactory.generateOppsForAccount(accountforOpp[0].Id,100,ReferredbyccdesirredValues.size(),false);
            //Update the Referred_By_Citation_Company__c for all the Opportunites with Picklist Values in ReferredbyccdesirredValues List
            for(Integer i=0;i<ReferredbyccdesirredValues.size();i++){
                oppwithReferredbycc[i].Referred_By_Citation_Company__c=ReferredbyccdesirredValues[i];
                oppwithReferredbycc[i].MADE_Criteria__c='Franchises - 1';
                oppstoInsert.add(oppwithReferredbycc[i]);
            }
            //Insert Opportunity
            Test.startTest();
            insert oppstoInsert;
            Test.stopTest();
            //Get all the Opportunities inserted to Verify SalesChannel
            List<Opportunity> opportunitiesInserted=[Select Id,Sales_Channel__c,Referred_By_Citation_Company__c From Opportunity where Id IN :oppstoInsert];
            //All above opportunities should have SalesChannel as "Cross Sell"
            for(Opportunity eachOpportunity: opportunitiesInserted){
                System.assertEquals('Cross Sell',eachOpportunity.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachOpportunity.Sales_Channel__c+' Where Referred By Citation Company is '+eachOpportunity.Referred_By_Citation_Company__c);
            }
        }
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel when Opportunity doesn't contain values in Keywords
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOppwhennotinKeyword(){
        //Insert Account that needs to be tagged to Opportunity
        List<Account> accountforOpp=TestDataFactory.getAccounts(1,'TestAccounttoVerifySalesChannelonOpportunity',true);
        if(!accountforOpp.isEmpty()){
            //Opportunities to Test Sales Channel
            List<Opportunity> oppwithReferredbycc=TestDataFactory.generateOppsForAccount(accountforOpp[0].Id,100,1,true);
            if(!oppwithReferredbycc.isEmpty()){
                //Get all the Opportunities inserted to Verify SalesChannel
                List<Opportunity> opportunitiesInserted=[Select Id,Sales_Channel__c From Opportunity where Id=:oppwithReferredbycc[0].Id];
                //Above opportunity shouldn't have SalesChannel as "Cross Sell"
                System.assertNotEquals('Cross Sell',opportunitiesInserted[0].Sales_Channel__c, 'Sales Channel is Expected to be not Cross Sell But It is Cross Sell');
            }
        }
    }
    /**
     * @date 28-09-2022
     * @description This Method is used to Prepare a List of Values Present in Keyword__C in Group_Configuration__mdt Records
     * @param No Parameters
     * @return List containing all Keywords in Group_Configuration__mdt Records
     */
    public static List<string> verifySalesChannelonOppHelper(){
        //List to store all KeyWord__C values from Group_Configuration__mdt Records
        List<string> keyMap = new List<string>();
        //Get all Records in Group_Configuration__mdt
        list<Group_Configuration__mdt> gcm = [select Keywords__c from Group_Configuration__mdt];
        //Populate keyMap with all the values in KeyWord__c field in Group_Configuration__mdt
        for(Group_Configuration__mdt gm: gcm){
            keyMap.addAll(gm.Keywords__c.split(','));  
        }
        return keyMap;
    }
    /**
     * @date 31-10-2022
     * @description This Method is used to Test createQuotes Method
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void createQuotesTest(){
        SBQQ__QuoteTemplate__c q = new SBQQ__QuoteTemplate__c();
        q.Business_Type__c = 'Citation Client Relations' ;
        q.Template_Type__c = 'Quote';
        q.Name = 'Test Template';
        insert q;  
        List<Opportunity> opp=helperforcreateQuoteandRenewalContract(2,false);
        Test.startTest();
        Insert opp[0];
        Test.stopTest();
        List<SBQQ__Quote__c> cpqquotes=[Select Id From SBQQ__Quote__c where SBQQ__Opportunity2__c=:opp[0].Id];
        System.assertEquals(false, cpqquotes.isEmpty(),'CPQ Quote are not Created');
        List<SBQQ__QuoteLine__c> cpqquotelines=[Select Id From SBQQ__QuoteLine__c where SBQQ__Quote__c=:cpqquotes[0].Id];
        System.assertEquals(false, cpqquotelines.isEmpty(),'CPQ Quote Lines are not Created for the CPQ Quote');
    }
    /**
     * @date 31-10-2022
     * @description This Method is used to Test createRenewalContractFromRenewalOppAuto Method
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void createRenewalContractfromRenewalOppAutoTest(){ 
        List<Opportunity> opp=helperforcreateQuoteandRenewalContract(1,true);
        List<Opportunity> opplist=new List<Opportunity>();
        opplist.add(opp[1]);
        insert opp;
        Test.startTest();
        TriggerOpportunityHandler.createRenewalContractFromRenewalOppAuto(opplist);
        String renewalContractRecId=Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Renewal Contract').getRecordTypeId();
        List<Contract> contRec=[Select Id,Name from Contract where Name LIKE '%TestAccountforCreateQuotesMethod%'];
        System.assertEquals(false, contRec.isEmpty(), 'Renewal Contract not Created');
        Test.stopTest();
    }
    /**
     * @date 31-10-2022
     * @description This Method is used as helper for createRenewalContractfromRenewalOppAutoTest and createQuotesTest Method
     * @param No Parameters
     * @return void(returns nothing)
     */
    public static List<Opportunity> helperforcreateQuoteandRenewalContract(Integer numberofProducts,Boolean needRenewalOpp){
        List<Account> acc=TestDataFactory.getAccounts(1,'TestAccountforCreateQuotesMethod',false);
        acc[0].Industry='Construction';
        insert acc;
        List<contact> con=TestDataFactory.getContacts(1, 'TestContact', 'CreateQuotesMethod', acc[0].Id, true);
        List<Contract> cont=TestDataFactory.getContracts(1);
        cont[0].CustomerSignedId=con[0].Id;
        cont[0].AccountId=acc[0].Id;
        cont[0].Preferred_Payment_Date__c='14';
        insert cont;
        List<fferpcore__Company__c> com = TestDataFactory.getCompanys('Citation Limited');
        insert com;
        ffbc__Contract__c billCon = new ffbc__Contract__c();
        billCon.ffbc__Account__c = acc[0].Id;
        billCon.ffbc__Company__c = com[0].Id;
        billCon.Contract_Type__c = 'New';
        billCon.SF_Contract__c=cont[0].Id;
        billCon.ffbc__StartDate__c = System.today().addDays(-366);
        billCon.ffbc__EndDate__c = System.today();
        billCon.ffbc__Status__c='Draft';
        insert billCon;
        List<Revenue_Recognition_Logic__c> getRevLogic = TestDataFactory.getRevRecLogic('Atlas Rev','New','Monthly Flat Phased - Contract','Citation Limited');
        insert getRevLogic[0];
        ffbc__SoftDate__c softDate=new ffbc__SoftDate__c(Name='Monthly',ffbc__Definition__c='+1M');
        insert softDate;
        List<Product2> proList = new List<Product2>();
        Product2 AtlasUpskillProduct=new Product2(Name='Atlas UpSkill',Product_Grouping__c='Monthly Flat Phased - Contract',IsActive=true);
        proList.add(AtlasUpskillProduct);
        if(numberofProducts==2){
            Product2 FRAProduct=new Product2(Name='Fire Risk Assessment - Annual Review - Up to Full Day',Product_Grouping__c='Monthly Flat Phased - Contract',IsActive=true);
            proList.add(FRAProduct);
        }
        Insert  proList;
        List<ffbc__ContractLineItem__c> getContractLines = TestDataFactory.getContractLineItems(billCon.Id,proList[0].Id,getRevLogic[0].Id);
        getContractLines[0].ffbc__StartDate__c=System.today().addDays(-30);
        getContractLines[0].ffbc__EndDate__c=system.today();
        getContractLines[0].ffbc__BillingTerm__c=softDate.Id;
        insert getContractLines[0];  
        List<Opportunity> opp=TestDataFactory.generateOppsForAccount(acc[0].Id,100,1,false);
        opp[0].RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Retention_Opportunity_NA').getRecordTypeId();
        opp[0].Original_Contract__c=cont[0].Id;
        if(needRenewalOpp){
            Id oppoRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal / Retention Opportunity - Non-Auto').getRecordTypeId();
            Opportunity oppAuto = new Opportunity();
            oppAuto.RecordTypeId = oppoRecordTypeName;
            oppAuto.Original_Contract__c = cont[0].Id;
            oppAuto.Name = 'Auto Renewal Opportunity';
            oppAuto.CloseDate = Date.today()+740;
            oppAuto.AccountId = acc[0].Id;
            oppAuto.StageName = 'Renewal Contact Due';
            opp.add(oppAuto);
        }
        return opp;
    }
}