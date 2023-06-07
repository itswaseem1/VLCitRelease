/**********************************************************************
* bg_FmIntHttpQueueableCallout_Test:
*
* Class to test object bg_FmIntHttpCallout used to send a json message
* to the FileMaker Web service
* Created By: SA
* Created Date: 11-02-2016
*
* Changes: 
***********************************************************************/

@isTest
global with sharing class bg_FmIntHttpQueueableCallout_Test {

	static private Account acc;
	static private Contact cnt;

	private static Id ext_id;
    private static Id auditLineId;
    private static Id certLineId;

    
    @testSetup 
    public static void setup() {

        Opportunity Opp;
        Opportunity Opp2;
        Opportunity Opp3;
        
        Features__c f = new features__c(name='Default') ;
	  	insert f ;
        
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
        QMSUser.lastname='bg_FmIntHttpQueueableCallout_TestLastName';
        QMSUser.UserName = 'bg_FmIntHttpQueueableCallout_TestLastName@username.com';
        QMSUser.CommunityNickname ='Http200';
        QMSUser.Alias = 'bfhqc';
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

	global class MockHttpResponseGenerator implements HttpCalloutMock {

	    // Implement this interface method
	    global HTTPResponse respond(HTTPRequest req) {
	        // Optionally, only send a mock response for a specific endpoint
	        // and method.

	        System.debug('mock req: ' + req);

	        String endpoint = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Endpoint__c'));
	        String query = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Query__c'));

	        System.assertEquals(endpoint + query, req.getEndpoint());
	        System.assertEquals('POST', req.getMethod());
	        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('[{"response":{"created":true,"id":"01","ext_id":"' + ext_id + '","success":true,"message":null}}]');
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
                integrationSetting.SF_API_Username__c = 'test';

                insert integrationSetting;
            }

	}	

    private static void initialSetup() {
    	setupCustomSettings();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        //pricebook.Name ='Term user';
		insert pricebook;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		acc = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert acc;

		cnt = New Contact(FirstName = 'Bruce', LastName = 'Wayne', Account = acc);
		insert cnt;
	}
    
    @isTest
    private static void testContact(){
    	initialSetup();
		Contact con = new Contact();
        con.FirstName = 'Karthik';
        con.LastName = 'Sai';
        con.FM_Contact_External_Id__c = '23';
        insert con;
        con.Email = 'saikarthik@citation.co.uk';
        update con;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
    }

    @isTest 
    private static void testCalloutAccount() {
		integer QueueCallsMade = 0 ;
		initialSetup();

		cnt.AccountId = acc.id;
		cnt.FM_Contact_External_Id__c = '01';
		update cnt;

		ext_id = cnt.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();
        acc.Name = 'test one update';
        update acc;

		
        QueueCallsMade = Limits.getQueueableJobs();
       
        Test.stopTest();

        Contact ucnt = [select Id, FM_Contact_External_Id__c from Contact where Id =: cnt.Id];

    	System.assertEquals('01', ucnt.FM_Contact_External_Id__c);
        system.assertequals(1,QueueCallsMade) ;
    }
    
     @isTest 
    private static void testCalloutAccountNoContactCallout() {
		integer QueueCallsMade = 0 ;
        
		initialSetup();

		cnt.AccountId = acc.id;
		cnt.FM_Contact_External_Id__c = '01';
		update cnt;

		ext_id = cnt.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();
        

        acc.Name = 'test one update';
        acc.ffps_accBalance__CalculatedBalance__c = 1 ;
        update acc;

		QueueCallsMade = Limits.getQueueableJobs();
        Test.stopTest();

        Contact ucnt = [select Id, FM_Contact_External_Id__c from Contact where Id =: cnt.Id];
		
    	System.assertEquals('01', ucnt.FM_Contact_External_Id__c);
        system.assertequals(0,QueueCallsMade) ;
    }
    

    @isTest 
    private static void testNoCalloutAccount() {

		initialSetup();

		cnt.AccountId = acc.id;
		update cnt;

		ext_id = cnt.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();

        acc.Name = 'test one update';
        update acc;

        Test.stopTest();

        Contact ucnt = [select Id, FM_Contact_External_Id__c from Contact where Id =: cnt.Id];

    	System.assertEquals(null, ucnt.FM_Contact_External_Id__c);
    }

    @isTest 
    private static void testCalloutContact() {

		initialSetup();

		ext_id = cnt.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();

		cnt.AccountId = acc.id;
		cnt.FM_Contact_External_Id__c = '01';
		update cnt;

        Test.stopTest();

        Contact ucnt = [select Id, FM_Contact_External_Id__c from Contact where Id =: cnt.Id];

    	System.assertEquals('01', ucnt.FM_Contact_External_Id__c);
    }

    @isTest 
    private static void testNoCalloutContact() {

		initialSetup();

		ext_id = cnt.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();

		cnt.AccountId = acc.id;
		update cnt;

        Test.stopTest();

        Contact ucnt = [select Id, FM_Contact_External_Id__c from Contact where Id =: cnt.Id];

    	System.assertEquals(null, ucnt.FM_Contact_External_Id__c);
    }



    @isTest 
    private static void testCalloutOpportunity() {

		initialSetup();

		Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', acc.Id, true, 9);
        opportunity.Pricebook2Id =[Select id from Pricebook2 limit 1].id;
		insert opportunity;
		ext_id = opportunity.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();

		opportunity.Sale_Approved__c = true;
		update opportunity;

        Test.stopTest();

        Opportunity uopp = [select Id, FM_Opportunity_External_Id__c from Opportunity where Id =: opportunity.Id];

        /* sa tofix response handler code is not executed ??
    	System.assertEquals('01', uopp.FM_Opportunity_External_Id__c);
    	*/

    }

    @isTest 
    private static void testNoCalloutOpportunity() {

		initialSetup();

		Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', acc.Id, true, 9);
		insert opportunity;
		ext_id = opportunity.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

		/*
			Business Logic
		*/
        Test.startTest();

		cnt.AccountId = acc.id;
		update cnt;

		opportunity.Contact__c = cnt.id;
		update opportunity;

        Test.stopTest();

        Opportunity uopp = [select Id, FM_Opportunity_External_Id__c from Opportunity where Id =: opportunity.Id];
    	System.assertEquals(null, uopp.FM_Opportunity_External_Id__c);

        Contact ucnt = [select Id, FM_Contact_External_Id__c from Contact where Id =: cnt.Id];
    	System.assertEquals(null, ucnt.FM_Contact_External_Id__c);

    }

    @isTest 
    private static void givenElearningToFM_thenUpdateFMEquiryIdOnOppLineItem() {
        user qmsUser = [select id from user where lastname ='bg_FmIntHttpQueueableCallout_TestLastName'];
        
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
    
    
}