/**********************************************************************
* bg_FmIntOpportunityWS_Test:
*
* Class to test object bg_FmIntOpportunityWS_Test used to send a 
* son message to the FileMaker Web service from Opp DTR/SalesVisit
* buttons.
* Created By: SA
* Created Date: 11-02-2016
*
* Changes: 
***********************************************************************/
@isTest
global class bg_FmIntOpportunityWS_Test {
	static private Account acc;
	static private Contact cnt;

	static private Id ext_id;
    
    @testSetup static void setup()
    {
        Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ');
        insert qmsNewPB;
    }

	global class MockHttpResponseGenerator implements HttpCalloutMock {

	    // Implement this interface method
	    global HTTPResponse respond(HTTPRequest req) {
	        // Optionally, only send a mock response for a specific endpoint
	        // and method.

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
                integrationSetting.SF_API_Username__c = 'batman';
                insert integrationSetting;
            }

	}	

    private static void initialSetup() {
    	setupCustomSettings();

		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebook;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		acc = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert acc;

		cnt = New Contact(FirstName = 'Bruce', LastName = 'Wayne', Account = acc);
		insert cnt;


	}	


    @isTest 
    private static void testCalloutOpportunityDTR() {

		initialSetup();

		Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', acc.Id, true, 9);
		insert opportunity;
		ext_id = opportunity.id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);

        System.debug('testCalloutOpportunityDTR, opp: ' + opportunity);

		/*
			Business Logic
		*/
        Test.startTest();

        bg_FmIntOpportunityWS.send(opportunity.id, true, false, false);

        Test.stopTest();

        Opportunity uopp = [select Id, FM_Opportunity_External_Id__c from Opportunity where Id =: opportunity.Id];

        /* sa tofix response handler code is not executed ??
    	System.assertEquals('01', uopp.FM_Opportunity_External_Id__c);
		*/
    }


    @isTest 
    private static void testCalloutOpportunitySalesVisit() {

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

	    bg_FmIntOpportunityWS.send(opportunity.id, false, true, false);

	    Test.stopTest();

	    Opportunity uopp = [select Id, FM_Opportunity_External_Id__c from Opportunity where Id =: opportunity.Id];

        /* sa tofix response handler code is not executed ??
		System.assertEquals('01', uopp.FM_Opportunity_External_Id__c);
		*/
	}


    @isTest 
    private static void testCalloutOpportunityProforma() {

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

	    bg_FmIntOpportunityWS.send(opportunity.id, false, false, true);

	    Test.stopTest();

	    Opportunity uopp = [select Id, FM_Opportunity_External_Id__c from Opportunity where Id =: opportunity.Id];

        /* sa tofix response handler code is not executed ??
		System.assertEquals('01', uopp.FM_Opportunity_External_Id__c);
		*/
	}

    @isTest
    Private static void testSendEmail(){
        Test.startTest();
        bg_FmIntOpportunityWS.sendEmail('test@citation.co.uk', 'Please note a proforma has been requested','test body');
        Test.stopTest();
    }
}