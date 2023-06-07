/********************************************************************************
 * bg_Opportunity_Helper_Tests
 *
 * Author: Hossein Mirzapour (BrightGen)
 * Created: 07-09-2015
 * Changes: KH 07-09-2015 - Updates to fix unit test as Delimit Records now using Field Label 
 *                          rather than the API Name
 ********************************************************************************/


@isTest
private class bg_Opportunity_Helper_Tests
{

	private static Account account = new Account();
	private static Contact contact = new Contact();
	public static final String OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY = 'Default Citation Opportunity';
	public static final Integer BULK_VALUE = 100;

    @isTest static void ifOpportunityHasMultiSelectDelimitRecordsShouldBeCreated() {
    	ifOpportunityHasMultiSelectDelimitRecordsShouldBeCreatedTestRunner();
    }

    @isTest static void ifOpportunityHasMultiSelectRemovingItShouldRemoveDelimitRecords() {
    	ifOpportunityHasMultiSelectRemovingItShouldRemoveDelimitRecordsTestRunner();
    }

    @isTest static void ifOpportunityHasMultiSelectRemovingItShouldRemoveDelimitRecordsBulk() {
    	ifOpportunityHasMultiSelectRemovingItShouldRemoveDelimitRecordsTestRunner();
    }

    // ##################################### Private methods #############################################

    private static String findAMultiSelectPickList()
    {
		Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();
		for (String fieldName: fieldMap.keySet()) 
		{
			Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
			
			// if its a multiselect picklist add it to the list
			if(fielddataType == Schema.DisplayType.MultiPicklist) 
			{
				return fieldName;
			}
		}
		return null;
    }
    
    private static void ifOpportunityHasMultiSelectDelimitRecordsShouldBeCreatedTestRunner()
    {
        /*
            * Setup
            */
        setup();
        Opportunity opp = bg_Unit_Test_Helper.createOpportunity('testOpp', OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY, account, contact);
            
        Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();

        String multiselectField = findAMultiSelectPickList();

        /*
            * Business Logic
            */
        if(multiselectField != null)
        {
            opp.put(multiselectField, 'test');
            update opp;

            System.assertEquals(1, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
            System.assertEquals(opp.get(multiselectField), [SELECT Picklist__c FROM MultiSelectPIcklist_delimit__c].Picklist__c);
            System.assertEquals(fieldMap.get(multiselectField).getDescribe().getLabel(), [SELECT Picklist_Field__c FROM MultiSelectPIcklist_delimit__c].Picklist_Field__c);
        }
        else 
        {
            System.assertEquals(0, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
        }       
    }

    private static void ifOpportunityHasMultiSelectRemovingItShouldRemoveDelimitRecordsTestRunner()
    {            
        /*
            * Setup
            */
        setup();
        Opportunity opp = bg_Unit_Test_Helper.createOpportunity('testOpp', OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY, account, contact);
        
        String multiselectField = findAMultiSelectPickList();
        /*
            * Business Logic
            */
        if(multiselectField != null)
        {
            opp.put(multiselectField, '');
            update opp;

            System.assertEquals(0, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
        }           
    }

    private static void ifOpportunityHasMultiSelectDelimitRecordsShouldBeCreatedBulkTestRunner()
    {
        /*
         * Setup
         */
        Account testAccount = [Select Id From Account Where Name = 'test 1'];

        List<Opportunity> initialOpps = CIT_PH1_Trigger_Utils.createOpportunities(BULK_VALUE, testAccount);
        List<Opportunity> updatedOpps = new List<Opportunity>();

        String multiselectField = findAMultiSelectPickList();
        /*
         * Business Logic
        */

        if(multiselectField != null)
        {
           
            for(Opportunity opp : initialOpps)
            {
            	opp.put(multiselectField, 'test');
            	updatedOpps.add(opp);
            }
			test.startTest();
            insert updatedOpps;
			test.stopTest();
            System.assertEquals(100, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
        }
        else 
        {
        	System.assertEquals(0, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
        }       
    }

    private static void ifOpportunityHasMultiSelectRemovingItShouldRemoveDelimitRecordsBulkTestRunner()
    {
        /*
         * Setup
         */
        setup();

        List<Opportunity> initialOpps = CIT_PH1_Trigger_Utils.createOpportunities(BULK_VALUE);
        List<Opportunity> updatedOpps = new List<Opportunity>();

        String multiselectField = findAMultiSelectPickList();
        /*
         * Business Logic
        */

        if(multiselectField != null)
        {
            for(Opportunity opp : initialOpps)
            {
            	opp.put(multiselectField, 'test');
            	updatedOpps.add(opp);
            }

            insert updatedOpps;

            System.assertEquals(0, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
        }
        else 
        {
        	System.assertEquals(0, [SELECT count() FROM MultiSelectPIcklist_delimit__c]);
        }             
    }

    private static void setup()
    {
    	Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
        insert pricebook;
        account = bg_Unit_Test_Helper.createAccount('test account');
    	contact = bg_Unit_Test_Helper.createContact('test', 'tester', account.id);
    }

    /*
        Test that a renewal is not created on insert if conditions are not met.
    */
    @isTest static void testRenewalOnInsertNegative()
    {
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;

        Test.startTest();

        system.runAs(QMSUser)
        {
            Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
            insert testAccount;
            Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 1);
            insert opp;
            opp.Ready_For_Renewal__c = False;
            opp.Contract_End_Date__c = Date.Today()-90;
            opp.StageName = 'Cancelled';
            opp.Accepted_Quote__c = False;
            update opp;
        }

        Test.stopTest();

        List<Opportunity> UpdatedOpp = [SELECT Ready_For_Renewal__c, Contract_End_Date__c, StageName FROM Opportunity];

        //Checking that no opportunity has been created
        System.AssertEquals(1, UpdatedOpp.size(), 'No Renewal Opportunity is created if criteria IS NOT met');
    }

    /*
        Test that a renewal is not created on update if conditions are not met.
    */
    @isTest static void testRenewalOnUpdateNegative()
    {
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;

        Test.startTest();

        system.runAs(QMSUser)
        {
            Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
            insert testAccount;
            Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 1);
            insert opp;
            opp.Ready_For_Renewal__c = False;
            opp.Contract_End_Date__c = Date.Today()-90;
            opp.StageName = 'Cancelled';
            opp.Accepted_Quote__c = False;
            update opp;
        }

        Test.stopTest();

        List<Opportunity> UpdatedOpp = [SELECT Ready_For_Renewal__c, Contract_End_Date__c, StageName FROM Opportunity];

        //Checking that no opportunity has been created
        System.AssertEquals(1, UpdatedOpp.size(), 'No Renewal Opportunity is created if criteria IS NOT met');
    }
    /*
        Test that a reduction is created correctly for an opp that needs it.
    */
    static testMethod void testSingleReductionOpp(){
        /*
            Setup
        */
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;
        Product2 product = bg_Product_TestUtils.createProduct(bg_Constants.REDUCTION_PRODUCT_TYPE, 'Test', 'Test');
        insert product;
        PricebookEntry stdPricebookEntry = bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), product.Id, 0.0, 0.0, 0.0);
        insert stdPricebookEntry;
        PricebookEntry pricebookEntry = bg_PricebookEntry_TestUtils.createPricebookEntry(pricebook.Id, product.Id, 0.0, 0.0, 0.0);
        insert pricebookEntry;
        Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert testAccount;
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 9);
            insert opportunity;
            opportunity.Is_Reduction__c = true;
            opportunity.Reduction_Amount__c = 1000.0;
            update opportunity;
        }
        Test.stopTest();

        /*
            Assertions
        */
        Opportunity updatedOpportunity = [select Id, Amount from Opportunity limit 1];
    }

    @testSetup static void setupData() {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;
        Product2 product = bg_Product_TestUtils.createProduct(bg_Constants.REDUCTION_PRODUCT_TYPE, 'Test', 'Test');
        insert product;
        PricebookEntry stdPricebookEntry = bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), product.Id, 0.0, 0.0, 0.0);
        insert stdPricebookEntry;
        PricebookEntry pricebookEntry = bg_PricebookEntry_TestUtils.createPricebookEntry(pricebook.Id, product.Id, 0.0, 0.0, 0.0);
        insert pricebookEntry;
        Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert testAccount;
        Pricebook2 pricebookqms = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        pricebookqms.Name = DataConstants.PRICEBOOK_QMS_NAME;   
        insert pricebookqms;
        
    }

    @isTest static void Given_AnOpportunity_When_TheTypeIsReduction_Then_CreateNegativeLineItemsAgainstTheOpportunity() {
         /*
            Setup
        */
        
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');

        Account testAccount = [Select Id From Account Where Name = 'test 1'];

        Test.startTest();
        List<Opportunity> opportunityRecords = new List<Opportunity>();
        system.runAs(QMSUser)
        {
            opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 9));
            opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('2', testAccount.Id, true, 9));
            opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('3', testAccount.Id, true, 9));
            insert opportunityRecords;

            /*
             * Set opportunities to renewal
             */
            opportunityRecords[0].Is_Reduction__c = true;
            opportunityRecords[0].Reduction_Amount__c = 1000.0;

            opportunityRecords[1].Is_Reduction__c = true;
            opportunityRecords[1].Reduction_Amount__c = null;

            opportunityRecords[2].Is_Reduction__c = true;
            opportunityRecords[2].Reduction_Amount__c = -300;
            update opportunityRecords;
        }
        Test.stopTest();

        opportunityRecords = [Select Id, Amount, Reduction_Amount__c, Is_Reduction__c From Opportunity Where Id IN :opportunityRecords order by name asc];
        System.assertEquals(-0, opportunityRecords[0].Reduction_Amount__c);
        System.assertEquals(false, opportunityRecords[0].Is_Reduction__c);

        System.assertEquals(null, opportunityRecords[1].Amount);
        System.assertEquals(-0, opportunityRecords[1].Reduction_Amount__c);
        System.assertEquals(false, opportunityRecords[1].Is_Reduction__c);

        System.assertEquals(null, opportunityRecords[2].Amount);
        System.assertEquals(-0, opportunityRecords[2].Reduction_Amount__c);
        System.assertEquals(false, opportunityRecords[2].Is_Reduction__c);

    }

    @isTest static void InsertOpportunityWithValidTermAndRevenueForGivenPricebook()
    {
        /*
            Setup
        */
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0, '10');
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;
        Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert testAccount;

        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        /*
            Business Logic
        */
        Test.startTest();
        System.runAs(QMSUser)
        {
            Opportunity testOpp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 9, '10');
            insert testOpp;
        }
        Test.stopTest();

        /*
            Assertions
        */
        Opportunity opportunityRecord = [Select Id, Name, Pricebook2Id From Opportunity Limit 1];
		Id qmsPBId = [Select id From  PriceBook2 where Name=:DataConstants.PRICEBOOK_QMS_NAME].id;
    }

    @isTest static void InsertOpportunityWithNoTerm()
    {
        /*
            Setup
        */
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0, '10');
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;
        Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert testAccount;

        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        /*
            Business Logic
        */
        Test.startTest();
        System.runAs(QMSUser)
        {
            Opportunity testOpp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 9, null);

            String errorMessage = '';
            try
            {
                insert testOpp;
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
            /*
            *   Assertions
            */ 
            System.assert(errorMessage.containsIgnoreCase(Label.QMS_Invalid_Term_For_Opportunity), ' The Opportunity should error if no term is present on a QMS Opportunity. ERROR: '+errorMessage);
        }
        Test.stopTest();
    }

    @isTest static void InsertOpportunityWithTermWithoutCorespondingPricebook()
    {
        /*
            Setup
        */
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0, '10');
        pricebook.Name = pricebook.name + ' Term';
        insert pricebook;
        Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert testAccount;

        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        /*
            Business Logic
        */
        Test.startTest();
        System.runAs(QMSUser)
        {
            Opportunity testOpp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 9, '3');

            String errorMessage = '';
            try
            {
                insert testOpp;
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
        }
        Test.stopTest();
    }

     @isTest static void InsertOpportunityWithoutCorespondingPricebook()
    {
        /*
            Setup
        */
        //The two pricebooks below are both incorrect, the combination of term AND revenue must be correct.
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0, '10');
        pricebook.Name = pricebook.name + ' Term';
        Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('1', 75000.0, 10001.0, '3');
        pricebook2.Name = pricebook2.name + ' Term';
        insert pricebook;
        Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert testAccount;

        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        /*
            Business Logic
        */
        Test.startTest();
        System.runAs(QMSUser)
        {
            Opportunity testOpp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 9, '3');

            String errorMessage = '';
            try
            {
                insert testOpp;
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
        }
        Test.stopTest();
    }
}