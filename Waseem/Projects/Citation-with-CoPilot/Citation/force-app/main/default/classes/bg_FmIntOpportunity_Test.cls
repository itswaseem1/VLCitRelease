@isTest
public class bg_FmIntOpportunity_Test {
    private static Account acc;
    private static Contact cnt;
    private static Opportunity Opp;
    private static Opportunity Opp2;
    private static Opportunity Opp3;
    private static Id ext_id;
    private static Id auditLineId;
    private static Id certLineId;
    
    @testSetup 
    public static void setup() {
        Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ', External_Id__c = 'Test!2#');
        insert qmsNewPB;
        
        List<Product2> productRecords = new List<Product2>();
        productRecords.add(createQMSProduct('ISO 9001', 'ISO 9001-CPQ-A', 'QMS'));
        productRecords.add(createQMSProduct('ISO 9001 - Premium - Consultancy & Certification', 'ISO 9001-A', 'Certification'));
        productRecords.add(createQMSProduct('ISO 9001 - Premium - Surveillance Audit', 'ISO 9001-A', 'Audit'));
        productRecords.add(createQMSProduct('ISOMentor', 'ISOtrain', 'QMS'));
        productRecords[3].SBQQ__BillingFrequency__c = 'One-Off';
        productRecords.add(createQMSProduct('QMS eLearning - Annual license fee', 'eLearning-CPQ-E', 'QMS'));
        productRecords[4].SBQQ__BillingFrequency__c = 'One-Off';
        productRecords.add(createQMSProduct('ISO 9001 Parent', 'ISO 9001-Old', 'Training'));
        productRecords.add(createQMSProduct('ISO 9001 Child', 'ISO 9001-Old', 'Training'));
        insert productRecords;
        
        List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[0].Id, 0, 0, 0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[1].Id, 500.0, 500.0, 500.0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[2].Id, 500.0, 500.0, 500.0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[3].Id, 600.0, 600.0, 600.0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[4].Id, 600.0, 600.0, 600.0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[5].Id, 600.0, 600.0, 600.0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[6].Id, 600.0, 600.0, 600.0));
        insert stdPricebookEntries;
        
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[0].Id, 0, 0, 0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[1].Id, 500.0, 500.0, 500.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[2].Id, 500.0, 500.0, 500.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[3].Id, 600.0, 600.0, 600.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[4].Id, 600.0, 600.0, 600.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[5].Id, 600.0, 600.0, 600.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[6].Id, 600.0, 600.0, 600.0));
        insert pricebookEntries;
        
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        productOptions.add(createProductOption(1, 1, productRecords[0].Id, productRecords[1].Id, 'Component'));
        productOptions.add(createProductOption(2, 1, productRecords[0].Id, productRecords[2].Id, 'Component'));
        productOptions.add(createProductOption(1, 1, productRecords[5].Id, productRecords[6].Id, 'Component'));        
        insert productOptions;
        
        Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert account;
        
        Contact con = TestDataFactory.getContacts(1, 'firstName', 'lastName', account.id, false)[0];
        con.phone = '123456789';
        con.email = 'test@test.com';
        insert con;
        
        Profile adminProfile = [Select Id from Profile where Name = 'System Administrator' limit 1];
        
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        QMSUser.ProfileId = adminProfile.Id;
        QMSUser.lastname='bg_FmIntOpportunity_Test';
        insert QMSUser;
        
        Product2 isoParent = [Select Id from Product2 where Name = 'ISO 9001'];
        Product2 isoCC = [Select Id from Product2 where Name = 'ISO 9001 - Premium - Consultancy & Certification'];
        Product2 isoSA = [Select Id from Product2 where Name = 'ISO 9001 - Premium - Surveillance Audit'];
        Product2 isoMentor = [Select Id from Product2 where Name = 'ISOMentor'];
        Product2 eLearning = [Select Id from Product2 where ProductCode = 'eLearning-CPQ-E'];
        
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' and Pricebook2.External_Id__c = 'Test!2#' limit 1]; 
        
        setupCustomSettings();
        
        system.runAs(QMSUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            Opp = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 9);
            Opp.Pricebook2Id = priceBookEntry.Pricebook2Id;
            Opp.Contact__c = con.Id; 
            Opp.Deposit__c = 0;
            Opp.Deposit_Received__c = true;
            Opp.Deposit_Received_Date__c = System.today();
            Opp.New_Service_Form_Returned__c = true;
            Opp.New_Service_Form_Returned_Date__c = System.today();
            Opp.Contract_Signed__c = true;
            Opp.ECHO_Customer_Signed_Date__c = System.today();
            oppList.add(Opp);
            
            Opp2 = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 9);
            Opp2.Name = 'test 2';
            Opp2.Pricebook2Id = priceBookEntry.Pricebook2Id;
            Opp2.Contact__c = con.Id; 
            Opp2.Deposit__c = 0;
            Opp2.Deposit_Received__c = true;
            Opp2.Deposit_Received_Date__c = System.today();
            Opp2.New_Service_Form_Returned__c = true;
            Opp2.New_Service_Form_Returned_Date__c = System.today();
            Opp2.Contract_Signed__c = true;
            Opp2.ECHO_Customer_Signed_Date__c = System.today();
            oppList.add(Opp2);
            
            Opp3 = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 9);
            Opp3.Name = 'test 3';
            Opp3.Pricebook2Id = priceBookEntry.Pricebook2Id;
            Opp3.Contact__c = con.Id; 
            Opp3.Deposit__c = 0;
            Opp3.Deposit_Received__c = true;
            Opp3.Deposit_Received_Date__c = System.today();
            Opp3.New_Service_Form_Returned__c = true;
            Opp3.New_Service_Form_Returned_Date__c = System.today();
            Opp3.Contract_Signed__c = true;
            Opp3.ECHO_Customer_Signed_Date__c = System.today();
            oppList.add(Opp3);
            insert oppList;
            
            System.assertEquals(priceBookEntry.Pricebook2Id, [select Pricebook2Id from opportunity where id = : Opp.Id].Pricebook2Id, 'changed price book');
            
            List<sbqq__quote__c> quoteList = new List<sbqq__quote__c>();
            sbqq__quote__c q1 = new sbqq__quote__c(sbqq__account__c = account.id,SBQQ__Opportunity2__c = Opp.id,SBQQ__QuoteTemplateId__c=null, SBQQ__PrimaryContact__c = con.id) ;
            q1.Initial_Payment__c = 1000;
            q1.Initial_Payment_Date__c = date.today().addDays(2);
            q1.SBQQ__BillingFrequency__c = 'Monthly';
            q1.Preferred_Payment_Date__c = '7';
            q1.Second_Signatory_Required__c = 'No';
            q1.SBQQ__Primary__c = true;
            q1.SBQQ__StartDate__c = system.today();
            quoteList.add(q1);
            
            sbqq__quote__c q2 = new sbqq__quote__c(sbqq__account__c = account.id,SBQQ__Opportunity2__c = Opp2.id,SBQQ__QuoteTemplateId__c=null, SBQQ__PrimaryContact__c = con.id) ;
            q2.Initial_Payment__c = 1000;
            q2.Initial_Payment_Date__c = date.today().addDays(2);
            q2.SBQQ__BillingFrequency__c = 'Monthly';
            q2.Preferred_Payment_Date__c = '14';
            q2.Second_Signatory_Required__c = 'No';
            q2.SBQQ__Primary__c = true;
            q2.SBQQ__StartDate__c = system.today();
            quoteList.add(q2);
            
            sbqq__quote__c q3 = new sbqq__quote__c(sbqq__account__c = account.id,SBQQ__Opportunity2__c = Opp3.id,SBQQ__QuoteTemplateId__c=null, SBQQ__PrimaryContact__c = con.id) ;
            q3.Initial_Payment__c = 1000;
            q3.Initial_Payment_Date__c = date.today().addDays(2);
            q3.SBQQ__BillingFrequency__c = 'Monthly';
            q3.Preferred_Payment_Date__c = '28';
            q3.Second_Signatory_Required__c = 'No';
            q3.SBQQ__Primary__c = true;
            q3.SBQQ__StartDate__c = system.today();
            quoteList.add(q3);
            insert quoteList;
            
            SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q1.Id);
            qg.Name = 'Option 1';
            insert qg;
            
            SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q2.Id);
            qg1.Name = 'Option 1';
            insert qg1;
            
            SBQQ__QuoteLineGroup__c qg2 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q3.Id);
            qg2.Name = 'Option 1';
            insert qg2;
        }
    }
    
    private static Product2 createQMSProduct(String category, String type, String service) {
        return new Product2(
            Name = category,
            ProductCode = type,
            Family = service,
            Business_Type__c = 'QMS',
            SBQQ__SubscriptionPricing__c = 'Fixed Pricing',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionType__c = 'Renewable'
        );
    }
    
    private static SBQQ__ProductOption__c createProductOption(Integer num, Integer quantity, Id parent, Id child, String type) {
        return new SBQQ__ProductOption__c(
            SBQQ__Number__c = num,
            SBQQ__Quantity__c = quantity,
            SBQQ__ConfiguredSKU__c = parent,
            SBQQ__OptionalSKU__c = child, 
            SBQQ__Type__c = type
        );
    }
    
    public class MockHttpResponseGeneratorFor2ProductTesting implements HttpCalloutMock {

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.

            String endpoint = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Endpoint__c'));
            String query = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Query__c'));

            System.assertEquals(endpoint + query, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"response":{"created":true,"id":"79296","ext_id":"'+ext_id+'","success":true,"message":"Record Activation <Activate> success","auditLineId":null,"certLineId":"'+certLineId+'"}},{"response":{"created":true,"id":"79297","ext_id":"'+ext_id+'","success":true,"message":"Record Activation <Activate> success","auditLineId":"'+auditLineId+'","certLineId":null}}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseGeneratorFor1ProductTesting implements HttpCalloutMock {

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.

            String endpoint = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Endpoint__c'));
            String query = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Query__c'));

            System.assertEquals(endpoint + query, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"response":{"created":true,"id":"79296","ext_id":"'+ext_id+'","success":true,"message":"Record Activation <Activate> success","auditLineId":null,"certLineId":"'+certLineId+'"}}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private static void setupCustomSettings() {
            FM_Integration__c integrationSetting = FM_Integration__c.getValues('Host');
            if(integrationSetting == null) {
                integrationSetting = new FM_Integration__c(Name= 'Host');
                integrationSetting.Http_Callout_Endpoint__c = 'test';
                integrationSetting.Http_Callout_Query__c = '?action=POST';
                integrationSetting.Http_Callout_Username__c = 'test';
                integrationSetting.Http_Callout_Password__c = 'test';
                integrationSetting.SF_API_Username__c = 'batman';
                insert integrationSetting;
            }

    }   
    
    @isTest 
    private static void testgetContactsWithoutExtIds() {
        Account acc = [Select Id from Account];
        
        List<Contact> retCont = new List<Contact>();
        Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', acc.Id, true, 9);
        insert opportunity;
        ext_id = opportunity.id;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunity);
        
        Test.startTest();
        retCont = bg_FmIntOpportunity.getContactsWithoutExtIds(oppList);
        Test.stopTest();

        System.assertEquals(0, retCont.size());
    }

    @isTest 
    private static void testserialize() {
        Account acc = [Select Id from Account];
        List<String> retStrng = new List<String>();
        List<String> retStrng2 = new List<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', acc.Id, true, 9);
        insert opportunity;
        
        List<Contact> conList = [SELECT id from Contact LIMIT 1];
        ext_id = opportunity.id;
        oppList.add(opportunity);
        
        Test.startTest();
        retStrng = bg_FmIntOpportunity.serialize(conList,oppList);
        retStrng2 = bg_FmIntOpportunity.serialize(oppList);
        Test.stopTest();

        System.assertNotEquals(0, retStrng.size());
        System.assertNotEquals(0, retStrng2.size());
    }
    
    @isTest 
    private static void testGetMethods() {
        Account acc = [Select Id from Account];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        List<Id> lstIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        Map<Id, Contact> conMap = new Map<Id, Contact>();
        Map<ID, Opportunity> oppMap2 = new Map<ID, Opportunity>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<id> oppIdSet = new Set<Id>();
        Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', acc.Id, true, 9);
        insert opportunity;
        oppList.add(opportunity);
        
        List<Contact> conList = [SELECT id from Contact LIMIT 1];
        List<Account> accList = [SELECT id from Account LIMIT 1];
        ext_id = opportunity.id;
        oppIdSet.add(opportunity.id);
        
        Test.startTest();
        oppMap = bg_FmIntOpportunity.getCntId2OppMap(oppList);
        lstIds = bg_FmIntOpportunity.getCntIds(oppList);
        accIds = bg_FmIntOpportunity.getAccIds(oppList);
        conMap = bg_FmIntOpportunity.getCntMap(conList);
        oppMap2 = bg_FmIntOpportunity.getOppMap(oppIdSet);
        Test.stopTest();

        System.assertNotEquals(0, lstIds.size());
        System.assertNotEquals(0, accIds.size());
        System.assertNotEquals(NULL, conMap.get(conList[0].id));
        System.assertNotEquals(NULL, oppMap2.get(opportunity.id));
    }
    
    @isTest 
    private static void givenISO9001AndISOMentorToFM_thenUpdateFMEquiryIdsOnOppLineItems() {
        user qmsUser = [select id from user where lastname ='bg_FmIntOpportunity_Test'];
        
        system.runAs(qmsUser) {
            Product2 isoParent = [Select Id from Product2 where Name = 'ISO 9001'];
            Product2 isoCC = [Select Id from Product2 where Name = 'ISO 9001 - Premium - Consultancy & Certification'];
            Product2 isoSA = [Select Id from Product2 where Name = 'ISO 9001 - Premium - Surveillance Audit'];
            Product2 isoMentor = [Select Id from Product2 where ProductCode = 'ISOtrain'];
            
            sbqq__quote__c q2 = [Select Id from sbqq__quote__c where Preferred_Payment_Date__c = '14'];
            SBQQ__QuoteLineGroup__c qg1 = [Select Id from SBQQ__QuoteLineGroup__c where sbqq__quote__c =: q2.Id];
            
            List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();            
            SBQQ__Quoteline__c ql5 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoParent.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, SBQQ__SubscriptionTerm__c = 12, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql6 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoCC.id, SBQQ__RequiredBy__c = ql5.id, SBQQ__SubscriptionTerm__c = 12, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql7 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoSA.id, SBQQ__RequiredBy__c = ql5.id, SBQQ__SubscriptionTerm__c = 12, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql8 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoMentor.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, SBQQ__SubscriptionTerm__c = 12, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            quoteLines.add(ql5); quoteLines.add(ql6); quoteLines.add(ql7); quoteLines.add(ql8);
            Test.startTest();
            insert quoteLines;
            
                        
            Opportunity OppQuried = [select id,ECHO_Customer_Signed_Date__c,Contact__c,Deposit__c,Deposit_Received__c,Deposit_Received_Date__c,New_Service_Form_Returned__c,New_Service_Form_Returned_Date__c,Contract_Signed__c from Opportunity where name ='test 2'] ;
            ext_id = OppQuried.Id;
            
            OpportunityLineItem objISOtrain = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and OpportunityId =: ext_Id];
            auditLineId = objISOtrain.Id;
            
            OpportunityLineItem objISOCert = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where  Product2.Name = 'ISO 9001 - Premium - Consultancy & Certification'];
            certLineId = objISOCert.Id;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFor2ProductTesting());
            
            String type = 'Opportunity';
            String action = 'Activate';
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(OppQuried);
            
            System.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity', 'Update', oppList));
            Test.stopTest();
        }    
        
        OpportunityLineItem objISOtrain = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and OpportunityId =: ext_Id];
        System.assertEquals('79297', objISOtrain.FM_Enquiry_Id__c);
        
        OpportunityLineItem objISOCert = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where Product2.Name = 'ISO 9001 - Premium - Consultancy & Certification'];
        System.assertEquals('79296', objISOCert.FM_Enquiry_Id__c);
    }
    
    @isTest 
    private static void givenISO9001AndElearningToFM_thenUpdateFMEquiryIdsOnOppLineItems() {
        user qmsUser = [select id from user where lastname ='bg_FmIntOpportunity_Test'];
        
        system.runAs(qmsUser) {
            Product2 isoParent = [Select Id from Product2 where Name = 'ISO 9001'];
            Product2 isoCC = [Select Id from Product2 where Name = 'ISO 9001 - Premium - Consultancy & Certification'];
            Product2 isoSA = [Select Id from Product2 where Name = 'ISO 9001 - Premium - Surveillance Audit'];
            Product2 eLearning = [Select Id from Product2 where ProductCode = 'eLearning-CPQ-E'];
            
            sbqq__quote__c q2 = [Select Id from sbqq__quote__c where Preferred_Payment_Date__c = '14'];
            SBQQ__QuoteLineGroup__c qg1 = [Select Id from SBQQ__QuoteLineGroup__c where sbqq__quote__c =: q2.Id];
            
            List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();            
            SBQQ__Quoteline__c ql5 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoParent.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, SBQQ__SubscriptionTerm__c = 12, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql6 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoCC.id, SBQQ__RequiredBy__c = ql5.id, SBQQ__SubscriptionTerm__c = 12, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql7 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = isoSA.id, SBQQ__RequiredBy__c = ql5.id, SBQQ__SubscriptionTerm__c = 12, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql8 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q2.id, sbqq__group__c = qg1.id, sbqq__product__c = eLearning.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, SBQQ__SubscriptionTerm__c = 12, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            quoteLines.add(ql5); quoteLines.add(ql6); quoteLines.add(ql7); quoteLines.add(ql8);
            Test.startTest();
            insert quoteLines;
            
                        
            Opportunity OppQuried = [select id,ECHO_Customer_Signed_Date__c,Contact__c,Deposit__c,Deposit_Received__c,Deposit_Received_Date__c,New_Service_Form_Returned__c,New_Service_Form_Returned_Date__c,Contract_Signed__c from Opportunity where name ='test 2'] ;
            ext_id = OppQuried.Id;
            
            OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
            auditLineId = objElearning.Id;
            
            OpportunityLineItem objISOCert = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where  Product2.Name = 'ISO 9001 - Premium - Consultancy & Certification'];
            certLineId = objISOCert.Id;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFor2ProductTesting());
            
            String type = 'Opportunity';
            String action = 'Activate';
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(OppQuried);
            
            System.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity', 'Update', oppList));
            Test.stopTest();
        }    
        
        OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
        System.assertEquals('79297', objElearning.FM_Enquiry_Id__c);
        
        OpportunityLineItem objISOCert = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where Product2.Name = 'ISO 9001 - Premium - Consultancy & Certification'];
        System.assertEquals('79296', objISOCert.FM_Enquiry_Id__c);

    }
    
    @isTest 
    private static void givenISOMentorToFM_thenUpdateFMEquiryIdOnOppLineItem() {
        user qmsUser = [select id from user where lastname ='bg_FmIntOpportunity_Test'];
        
        system.runAs(qmsUser) {
            Product2 isoMentor = [Select Id from Product2 where Name = 'ISOMentor'];
            
            sbqq__quote__c q3 = [Select Id from sbqq__quote__c where Preferred_Payment_Date__c = '28'];
            SBQQ__QuoteLineGroup__c qg2 = [Select Id from SBQQ__QuoteLineGroup__c where sbqq__quote__c =: q3.Id];
            
            List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();            
            SBQQ__Quoteline__c ql9 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q3.id, SBQQ__SubscriptionTerm__c = 12, sbqq__group__c = qg2.id, sbqq__product__c = isoMentor.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            quoteLines.add(ql9);
            Test.startTest();
            insert quoteLines;
                        
            Opportunity OppQuried = [select id,ECHO_Customer_Signed_Date__c,Contact__c,Deposit__c,Deposit_Received__c,Deposit_Received_Date__c,New_Service_Form_Returned__c,New_Service_Form_Returned_Date__c,Contract_Signed__c from Opportunity where name ='test 3'] ;
            ext_id = OppQuried.Id;
            
            OpportunityLineItem objISOMentor = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and Opportunity.Name = 'test 3'];
            certLineId = objISOMentor.Id;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFor1ProductTesting());
            
            String type = 'Opportunity';
            String action = 'Activate';
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(OppQuried);
            
            System.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity', 'Update', oppList));
            Test.stopTest();
            
        }    
        
        OpportunityLineItem objISOMentor = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and OpportunityId =: ext_Id];
        System.assertEquals('79296', objISOMentor.FM_Enquiry_Id__c);
    }    
    
    @isTest 
    private static void givenElearningToFM_thenUpdateFMEquiryIdOnOppLineItem() {
        user qmsUser = [select id from user where lastname ='bg_FmIntOpportunity_Test'];
        
        system.runAs(qmsUser) {
            Product2 eLearning = [Select Id from Product2 where ProductCode = 'eLearning-CPQ-E'];
            
            sbqq__quote__c q3 = [Select Id from sbqq__quote__c where Preferred_Payment_Date__c = '28'];
            SBQQ__QuoteLineGroup__c qg2 = [Select Id from SBQQ__QuoteLineGroup__c where sbqq__quote__c =: q3.Id];
            
            List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();            
            SBQQ__Quoteline__c ql10 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q3.id, SBQQ__SubscriptionTerm__c = 12, sbqq__group__c = qg2.id, sbqq__product__c = eLearning.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            quoteLines.add(ql10);
            Test.startTest();
            insert quoteLines;
                        
            Opportunity OppQuried = [select id,ECHO_Customer_Signed_Date__c,Contact__c,Deposit__c,Deposit_Received__c,Deposit_Received_Date__c,New_Service_Form_Returned__c,New_Service_Form_Returned_Date__c,Contract_Signed__c from Opportunity where name ='test 3'] ;
            ext_id = OppQuried.Id;
            
            OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
            certLineId = objElearning.Id;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFor1ProductTesting());
            
            String type = 'Opportunity';
            String action = 'Activate';
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(OppQuried);
            
            System.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity', 'Update', oppList));
            Test.stopTest();
            
        }    
        
        OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
        System.assertEquals('79296', objElearning.FM_Enquiry_Id__c);        
    }
    
    @isTest 
    private static void givenISOMentorAndElearningToFM_thenUpdateFMEquiryIdsOnOppLineItems() {
        user qmsUser = [select id from user where lastname ='bg_FmIntOpportunity_Test'];
        
        system.runAs(qmsUser) {
            Product2 eLearning = [Select Id from Product2 where ProductCode = 'eLearning-CPQ-E'];
            Product2 isoMentor = [Select Id from Product2 where Name = 'ISOMentor'];
            
            sbqq__quote__c q3 = [Select Id from sbqq__quote__c where Preferred_Payment_Date__c = '28'];
            SBQQ__QuoteLineGroup__c qg2 = [Select Id from SBQQ__QuoteLineGroup__c where sbqq__quote__c =: q3.Id];
            
            List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();            
            SBQQ__Quoteline__c ql9 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q3.id, SBQQ__SubscriptionTerm__c = 12, sbqq__group__c = qg2.id, sbqq__product__c = isoMentor.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql10 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q3.id, SBQQ__SubscriptionTerm__c = 12, sbqq__group__c = qg2.id, sbqq__product__c = eLearning.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            quoteLines.add(ql9); quoteLines.add(ql10);
            Test.startTest();
            insert quoteLines;
                        
            Opportunity OppQuried = [select id,ECHO_Customer_Signed_Date__c,Contact__c,Deposit__c,Deposit_Received__c,Deposit_Received_Date__c,New_Service_Form_Returned__c,New_Service_Form_Returned_Date__c,Contract_Signed__c from Opportunity where name ='test 3'] ;
            ext_id = OppQuried.Id;
            
            OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
            auditLineId = objElearning.Id;
            
            OpportunityLineItem objISOMentor = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and Opportunity.Name = 'test 3'];
            certLineId = objISOMentor.Id;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFor2ProductTesting());
            
            String type = 'Opportunity';
            String action = 'Activate';
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(OppQuried);
            
            System.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity', 'Update', oppList));
            Test.stopTest();
            
        }    
        
        OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
        System.assertEquals('79297', objElearning.FM_Enquiry_Id__c);
        
        OpportunityLineItem objISOMentor = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and OpportunityId =: ext_Id];
        System.assertEquals('79296', objISOMentor.FM_Enquiry_Id__c);
    }
    
    @isTest 
    private static void givenISOMentorAndElearningToFM_thenNoUpdateFMEquiryIdsOnOppLineItems() {
        user qmsUser = [select id from user where lastname ='bg_FmIntOpportunity_Test'];
        
        system.runAs(qmsUser) {
            Product2 eLearning = [Select Id from Product2 where ProductCode = 'eLearning-CPQ-E'];
            Product2 isoMentor = [Select Id from Product2 where Name = 'ISOMentor'];
            
            sbqq__quote__c q3rec = [Select Id from sbqq__quote__c where Preferred_Payment_Date__c = '28'];
            SBQQ__QuoteLineGroup__c qg2 = [Select Id from SBQQ__QuoteLineGroup__c where sbqq__quote__c =: q3rec.Id];
            
            List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();            
            SBQQ__Quoteline__c ql9 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q3rec.id, SBQQ__SubscriptionTerm__c = 12, sbqq__group__c = qg2.id, sbqq__product__c = isoMentor.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            SBQQ__Quoteline__c ql10 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q3rec.id, SBQQ__SubscriptionTerm__c = 12, sbqq__group__c = qg2.id, sbqq__product__c = eLearning.id, SBQQ__Quantity__c = 1.0, Initial_Payment__c = 120, FOC_Period__c = 'Start', SBQQ__BillingFrequency__c = 'Monthly');
            quoteLines.add(ql9); quoteLines.add(ql10);
            Test.startTest();
            insert quoteLines;
                        
            Opportunity OppQuried = [select id,ECHO_Customer_Signed_Date__c,Contact__c,Deposit__c,Deposit_Received__c,Deposit_Received_Date__c,New_Service_Form_Returned__c,New_Service_Form_Returned_Date__c,Contract_Signed__c from Opportunity where name ='test 3'] ;
            ext_id = OppQuried.Id;
            
            OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
            auditLineId = objElearning.Id;
            
            OpportunityLineItem objISOCert = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and Opportunity.Name = 'test 3'];
            certLineId = objISOCert.Id;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFor2ProductTesting());
            
            String type = 'Opportunity';
            String action = 'Activate';
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(OppQuried);
            
            System.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity', 'Update', oppList));
            Test.stopTest();
            
        }    
        
        OpportunityLineItem objElearning = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'eLearning-CPQ-E' and OpportunityId =: ext_Id];
        System.assertNotEquals('79296', objElearning.FM_Enquiry_Id__c);
        
        OpportunityLineItem objISOCert = [Select Id, FM_Enquiry_Id__c from OpportunityLineItem where ProductCode = 'ISOtrain' and OpportunityId =: ext_Id];
        System.assertNotEquals('79297', objISOCert.FM_Enquiry_Id__c);
    }
}