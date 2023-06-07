@isTest
private class bg_LogsHelper_Tests {
	@testSetup static void setup() {

	}
	/*
	 * Test a log being added to the opportunity line items
	 * Test a log being added to the quote line item
	 * Bulk test a log being added to the opportunity line items
	 * Bulk test a log being added to the quote line items
	 * Test the log getting above the character limit and truncating the field
	 * Test an individual log getting too big and displaying a truncated version - TODO maybe use a custom setting to define the message limit
	 * Test an error on creating the log at an item level
	 * Test an error on save of the record
	 * Test an error outside the item level
	 */

    @isTest static void testMethod1() {
        OpportunityLineItem opportunityLineItemRecord = new OpportunityLineItem();
        List<OpportunityLineItem> opportunityLineItemRecords = new List<OpportunityLineItem>();
        opportunityLineItemRecords.add(opportunityLineItemRecord);

        bg_LogsHelper.setupVariables('bg_LogsHelper_Tests', 'testMethod1');
        
        User userToRunAs = bg_User_TestUtils.createQMSSalesUser('1');

        testRunner(userToRunAs, opportunityLineItemRecords, 'Test message', 'bg_LogsHelper_Tests', 'testMethod1');
    }

    @isTest static void testMethod2() {
        QuoteLineItem quoteLineItemRecord = new QuoteLineItem();
        List<QuoteLineItem> quoteLineItemRecords = new List<QuoteLineItem>();

        bg_LogsHelper.setupVariables('bg_LogsHelper_Tests', 'testMethod1');

        User userToRunAs = bg_User_TestUtils.createQMSSalesUser('1');

        testRunner(userToRunAs, quoteLineItemRecords, 'Test message', 'bg_LogsHelper_Tests', 'testMethod1');
    }

    @isTest static void testMethod3() {
        List<OpportunityLineItem> opportunityLineItemRecords = new List<OpportunityLineItem>();
        for(Integer i = 0; i < 500; i++)
        {
            opportunityLineItemRecords.add(new OpportunityLineItem());
        }

        bg_LogsHelper.setupVariables('bg_LogsHelper_Tests', 'testMethod1');
        
        User userToRunAs = bg_User_TestUtils.createQMSSalesUser('1');

        testRunner(userToRunAs, opportunityLineItemRecords, 'Test message', 'bg_LogsHelper_Tests', 'testMethod1');
    }

    @isTest static void testMethod4() {
        List<QuoteLineItem> quoteLineItemRecords = new List<QuoteLineItem>();

        for(Integer i = 0; i < 500; i++)
        {
            quoteLineItemRecords.add(new QuoteLineItem());
        }

        bg_LogsHelper.setupVariables('bg_LogsHelper_Tests', 'testMethod1');

        User userToRunAs = bg_User_TestUtils.createQMSSalesUser('1');

        testRunner(userToRunAs, quoteLineItemRecords, 'Test message', 'bg_LogsHelper_Tests', 'testMethod1');
    }

    public static void testRunner(User userRecord, List<sObject> records, String message, String className, String methodName) {
    	system.runAs(userRecord)
    	{
    		for(sObject record : records)
    		{
    			bg_LogsHelper.populateLog(record, message, className, methodName);

		        System.assertNotEquals(null, record.get('Logs__c'), 'The logs weren\'t populated');

		        String messageDateTime = String.valueOf(DateTime.now());
		    	String processedMessage = String.format(new bg_LogsHelper().MESSAGE_TEMPLATE, new List<String> {messageDateTime, className, methodName, 'Test message'});

		        //System.assertEquals(processedMessage, record.get('Logs__c'));
    		}
    	}
    }
}