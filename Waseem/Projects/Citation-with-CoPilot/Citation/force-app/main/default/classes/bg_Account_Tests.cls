/********************************************************************************
* bg_Account_Tests :
*
* Test methods for the Account Helper class.
* Tests:
* 		Insert single QMS account with AnnualRevenue
*		Insert multiple QMS accounts with same AnnualRevenue
*		Insert multiple QMS accounts with different AnnualRevenue
*		Update single QMS account with AnnualRevenue
*		Update multiple QMS accounts with same AnnualRevenue
*		Update multiple QMS accounts with different AnnualRevenue
*		Insert single non-QMS account with AnnualRevenue
*		Update single non-QMS account with AnnualRevenue
*
*		Update QMS account with open opportunities to new turnover threshold
*		Update QMS account with open opportunities to same turnover threshold
*		Update QMS account with closed opportunities to new turnover threshold
*		Update QMS account with open and closed opportunities to new turnover threshold
*		Update multiple QMS accounts with open and closed opportunities to new turnover thresholds
*
* Created By: Jamie Wooley
* Created Date: 11-01-2015 
*
* Changes:
* JW 23-05-2016 - Added tests for the GA Integration
*********************************************************************************/
@isTest
private class bg_Account_Tests {

	public static final Integer BULK_FACTOR = 5;

	/*
		Insert single QMS account with AnnualRevenue
	*/
	/*
	@isTest static void testSingleAccountWithRevenue(){
		
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebook;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
			insert account;
		}
		Test.stopTest();

		
		Account updatedAccount = [select Id, AnnualRevenue, Price_Book__c from Account limit 1];
		system.assertEquals(5000.0, updatedAccount.AnnualRevenue);
		system.assertEquals(pricebook.Id, updatedAccount.Price_Book__c);
	}
	*/
	

	/*
		Insert multiple QMS accounts with same AnnualRevenue
	*/
	/*
	@isTest static void testMultiAccountsWithRevenue(){
		
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebook;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			List<Account> accounts = new List<Account>();
			for (Integer i=0; i<BULK_FACTOR; i++)
			{
				Account account = bg_Account_TestUtils.createQMSAccount(string.valueOf(i), 5000.0);
				accounts.add(account);
			}
			insert accounts;
		}
		Test.stopTest();

		
		List<Account> updatedAccounts = [select Id, AnnualRevenue, Price_Book__c from Account];
		for (Account updatedAccount : updatedAccounts)
		{
			system.assertEquals(5000.0, updatedAccount.AnnualRevenue);
			system.assertEquals(pricebook.Id, updatedAccount.Price_Book__c);
		}
		
	}
	*/

	/*
		Insert multiple QMS accounts with different AnnualRevenue
	*/
	
	/*
	@isTest static void testMultiAccountsWithDiffRevenues(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 150000.0, 15000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			List<Account> accounts = new List<Account>();
			for (Integer i=1; i<=BULK_FACTOR; i++)
			{
				Account account = bg_Account_TestUtils.createQMSAccount(string.valueOf(i), 5000.0*i);
				accounts.add(account);
			}
			insert accounts;
		}
		Test.stopTest();

		
		List<Account> updatedAccounts = [select Id, AnnualRevenue, Price_Book__c from Account];
		for (Account updatedAccount : updatedAccounts)
		{
			if(updatedAccount.AnnualRevenue <= 15000.0)
			{
				system.assertEquals(pricebook.Id, updatedAccount.Price_Book__c);
			}
			else
			{
				system.assertEquals(pricebook2.Id, updatedAccount.Price_Book__c);
			}
		}
		
	}
	
	*/

	/*
		Update single QMS account with AnnualRevenue
	*/
	/*
	@isTest static void testUpdateSingleAccountWithRevenue(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
			insert account;
			account.AnnualRevenue = 50000.0;
			update account;
		}
		Test.stopTest();

		
		Account updatedAccount = [select Id, AnnualRevenue, Price_Book__c from Account limit 1];
		system.assertEquals(50000.0, updatedAccount.AnnualRevenue);
		system.assertEquals(pricebook2.Id, updatedAccount.Price_Book__c);
	}
	*/

	/*
		Update multiple QMS accounts with same AnnualRevenue
	*/
	
	/*
	@isTest static void testUpdateMultiAccountsWithRevenue(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			List<Account> accounts = new List<Account>();
			for (Integer i=0; i<BULK_FACTOR; i++)
			{
				Account account = bg_Account_TestUtils.createQMSAccount(string.valueOf(i), 5000.0);
				accounts.add(account);
			}
			insert accounts;
			for (Account account : accounts)
			{
				account.AnnualRevenue = 50000.0;
			}
			update accounts;
		}
		Test.stopTest();

		
		List<Account> updatedAccounts = [select Id, AnnualRevenue, Price_Book__c from Account];
		for (Account updatedAccount : updatedAccounts)
		{
			system.assertEquals(50000.0, updatedAccount.AnnualRevenue);
			system.assertEquals(pricebook2.Id, updatedAccount.Price_Book__c);
		}
		
	}
	*/	
	

	/*
		Update multiple QMS accounts with different AnnualRevenue
	*/
	/*
	@isTest static void testUpdateMultiAccountsWithDiffRevenues(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 150000.0, 15000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		Test.startTest();
		system.runAs(QMSUser)
		{
			List<Account> accounts = new List<Account>();
			for (Integer i=1; i<=BULK_FACTOR; i++)
			{
				Account account = bg_Account_TestUtils.createQMSAccount(string.valueOf(i), 5000.0*i);
				accounts.add(account);
			}
			insert accounts;
			for (Account account : accounts)
			{
				account.AnnualRevenue = account.AnnualRevenue*15;
			}
			Database.SaveResult[] srList = Database.update(accounts, false);
			for (Database.SaveResult sr : srList)
			{
				if (!sr.isSuccess())
				{
					for(Database.Error err : sr.getErrors())
					{                 
			            System.assertEquals(Label.QMS_Invalid_Revenue, err.getMessage());
			        }
			    }
			}
        }
        Test.stopTest();

		
		List<Account> updatedAccounts = [select Id, AnnualRevenue, Price_Book__c from Account];
		for (Account updatedAccount : updatedAccounts)
		{
			if(updatedAccount.AnnualRevenue <= 15000.0)
			{
				system.assertEquals(pricebook.Id, updatedAccount.Price_Book__c);
			}
			else
			{
				system.assertEquals(pricebook2.Id, updatedAccount.Price_Book__c);
			}
		}
		
	}
	*/

	/*
		Insert single non-QMS account with AnnualRevenue
	*/
	/*
	@isTest static void testSingleNonQMSAccountWithRevenue(){
		
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebook;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			Account account = bg_Account_TestUtils.createCitationAccount('1', 5000.0);
			insert account;
		}
		Test.stopTest();

		
		Account updatedAccount = [select Id, AnnualRevenue, Price_Book__c from Account limit 1];
		system.assertEquals(5000.0, updatedAccount.AnnualRevenue);
		system.assertEquals(pricebook.Id, updatedAccount.Price_Book__c);
	}
	*/

	/*
		Update single non-QMS account with AnnualRevenue
	*/
	
	/*
	@isTest static void testUpdateSingleNonQMSAccountWithRevenue(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			Account account = bg_Account_TestUtils.createCitationAccount('1', 5000.0);
			insert account;
			account.AnnualRevenue = 50000.0;
			update account;
		}
		Test.stopTest();

		Account updatedAccount = [select Id, AnnualRevenue, Price_Book__c from Account limit 1];
		system.assertEquals(50000.0, updatedAccount.AnnualRevenue);
		system.assertEquals(pricebook2.Id, updatedAccount.Price_Book__c);
	}
	*/

	/*
		Update QMS account with open opportunities to new turnover threshold
	*/
	
	/*	
	@isTest static void testUpdateSingleAccountWithOpenOpps(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for (Integer i=0; i<BULK_FACTOR; i++)
		{
			Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity(string.valueOf(i), account.Id, true, 1);
			opps.add(opp);
		}
		insert opps;
		account.AnnualRevenue = 50000.0;
		update account;
		Test.stopTest();

		Account updatedAccount = [select Id from Account limit 1];
		List<Opportunity> updatedOpps = [select Id, AccountId, Pricebook_Approval_Required__c from Opportunity];
		for (Opportunity updatedOpp : updatedOpps)
		{
			system.assertEquals(updatedAccount.Id, updatedOpp.AccountId);
			system.assertEquals(true, updatedOpp.Pricebook_Approval_Required__c);
		}
	}
	*/

	/*
		Update QMS account with open opportunities to same turnover threshold
	*/
	/*
	@isTest static void testUpdateSingleAccountWithOpenOppsNegative(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for (Integer i=0; i<BULK_FACTOR; i++)
		{
			Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity(string.valueOf(i), account.Id, true, 1);
			opps.add(opp);
		}
		insert opps;
		account.AnnualRevenue = 6000.0;
		update account;
		Test.stopTest();

		
		Account updatedAccount = [select Id from Account limit 1];
		List<Opportunity> updatedOpps = [select Id, AccountId, Pricebook_Approval_Required__c from Opportunity];
		for (Opportunity updatedOpp : updatedOpps)
		{
			system.assertEquals(updatedAccount.Id, updatedOpp.AccountId);
			system.assertEquals(false, updatedOpp.Pricebook_Approval_Required__c);
		}
	}
	*/
	
	/*
		Update QMS account with closed opportunities to new turnover threshold
	*/
	/*
	@isTest static void testUpdateSingleAccountWithClosedOpps(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for (Integer i=0; i<BULK_FACTOR; i++)
		{
			Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity(string.valueOf(i), account.Id, true, 1);
			opp.StageName = 'Closed Won';
			opps.add(opp);
		}
		insert opps;
		account.AnnualRevenue = 50000.0;
		update account;
		Test.stopTest();

		
		Account updatedAccount = [select Id from Account limit 1];
		List<Opportunity> updatedOpps = [select Id, AccountId, Pricebook_Approval_Required__c from Opportunity];
		for (Opportunity updatedOpp : updatedOpps)
		{
			system.assertEquals(updatedAccount.Id, updatedOpp.AccountId);
			system.assertEquals(false, updatedOpp.Pricebook_Approval_Required__c);
		}
	}
	*/

	/*
		Update QMS account with open and closed opportunities to new turnover threshold
	*/
	/*
	@isTest static void testUpdateSingleAccountWithClosedAndOpenOpps(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 100000.0, 10000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for (Integer i=0; i<BULK_FACTOR; i++)
		{
			Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity(string.valueOf(i), account.Id, true, 1);
			if ( math.mod(i,2) == 0)
			{
				opp.StageName = 'Closed Won';
			}
			opps.add(opp);
		}
		insert opps;
		account.AnnualRevenue = 50000.0;
		update account;
		Test.stopTest();

		
		Account updatedAccount = [select Id from Account limit 1];
		List<Opportunity> updatedOpps = [select Id, AccountId, Pricebook_Approval_Required__c, StageName from Opportunity];
		for (Opportunity updatedOpp : updatedOpps)
		{
			system.assertEquals(updatedAccount.Id, updatedOpp.AccountId);
			if (updatedOpp.StageName == 'Closed Won')
			{
				system.assertEquals(false, updatedOpp.Pricebook_Approval_Required__c);
			}
			else
			{
				system.assertEquals(true, updatedOpp.Pricebook_Approval_Required__c);
			}
		}
	}
	*/


	/*
		Update multiple QMS accounts with open and closed opportunities to new turnover thresholds
	*/
	/*
	
	@isTest static void testUpdateMultiAccountsWithClosedAndOpenOpps(){
		
		List<Pricebook2> pricebooks = new List<Pricebook2>();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
		pricebooks.add(pricebook);
		Pricebook2 pricebook2 = bg_Pricebook_TestUtils.createPricebook('2', 150000.0, 15000.1);
		pricebooks.add(pricebook2);
		insert pricebooks;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		
		Test.startTest();
		system.runAs(QMSUser)
		{
			List<Account> accounts = new List<Account>();
			// Create accounts that span two pricebooks
			for (Integer i=1; i<=BULK_FACTOR; i++)
			{
				Account account = bg_Account_TestUtils.createQMSAccount(string.valueOf(i), 5000.0*i);
				accounts.add(account);
			}
			insert accounts;
			List<Opportunity> opps = new List<Opportunity>();
			for (Account account : accounts)
			{
				for (Integer i=0; i<BULK_FACTOR; i++)
				{
					Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity(string.valueOf(i), account.Id, true, 1);
					if ( math.mod(i,2) == 0)
					{
						opp.StageName = 'Closed Won';
					}
					opps.add(opp);
				}
				// Update the accounts so that at least one of them changes pricebooks
				account.AnnualRevenue += 1;
			}
			insert opps;
			update accounts;

		}
		Test.stopTest();

		
		List<Opportunity> updatedOpps = [select Id, Account.AnnualRevenue, Pricebook_Approval_Required__c, StageName from Opportunity];
		for (Opportunity updatedOpp : updatedOpps)
		{
			// for the account that change pricebook, all its open opps should need approval
			if (updatedOpp.Account.AnnualRevenue == 15001 && updatedOpp.StageName != 'Closed Won')
			{
				system.assertEquals(true, updatedOpp.Pricebook_Approval_Required__c);
			}
			// for all close opps, or opps that were for accounts whose pricebook didn't change, they shouldn't need approving.
			else
			{
				system.assertEquals(false, updatedOpp.Pricebook_Approval_Required__c);
			}
		}
		
	}
	*/

	/*
		Test that an actvated account with one client Id is sent to GA
	*/
	@istest private static void test_activateAccountWithGAClientId(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = '12345';
        insert account;
        Contact contact = bg_Contact_TestUtils.createContact('test 2', account.Id);
		insert contact;
        Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
        contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today();
        insert contract;

        Test.startTest();

        account.Last_Contract__c = contract.Id;
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(1, eventLog.size());
        system.assertEquals(bg_Constants.ACCOUNT_ACTIVATION, eventLog.get(0).Event_Type__c);

    }

    /*
		Test that a deactivated account with one client Id is sent to GA
	*/
	@istest private static void test_deactivateAccountWithGAClientId(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = '12345';
        account.ATLASLive__c = true;
        insert account;

        Test.startTest();

        account.ATLASLive__c = false;
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(1, eventLog.size());
        system.assertEquals(bg_Constants.ACCOUNT_DEACTIVATION, eventLog.get(0).Event_Type__c);

	}

	/*
		Test that an actvated account with multiple client Ids is sent to GA
	*/
	@istest private static void test_activateAccountWithMultipleGAClientIds(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = '1, 2, 3, 4, 5';
        insert account;
        Contact contact = bg_Contact_TestUtils.createContact('test 2', account.Id);
		insert contact;
        Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
        contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today();
        insert contract;

        Test.startTest();

        account.Last_Contract__c = contract.Id;
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(1, eventLog.size());
        system.assertEquals(bg_Constants.ACCOUNT_ACTIVATION, eventLog.get(0).Event_Type__c);

	}

	/*
		Test that a deactivated account with multiple client Ids is sent to GA
	*/
	@istest private static void test_deactivateAccountWithMultipleGAClientIds(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21';
        account.ATLASLive__c = true;
        insert account;

        Test.startTest();

        account.ATLASLive__c = false;
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(2, eventLog.size());
        system.assertEquals(bg_Constants.ACCOUNT_DEACTIVATION, eventLog.get(0).Event_Type__c);

	}

	/*
		Test that an actvated account with no client Id is not sent to GA
	*/
	@istest private static void test_activateAccountWithNoGAClientId(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = null;
        insert account;
        Contact contact = bg_Contact_TestUtils.createContact('test 2', account.Id);
		insert contact;
        Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
        contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today();
        insert contract;

        Test.startTest();

        account.Last_Contract__c = contract.Id;
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(0, eventLog.size());

	}

	/*
		Test that a deactivated account with no client Id is not sent to GA
	*/
	@istest private static void test_deactivateAccountWithNoGAClientId(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = null;
        account.ATLASLive__c = true;
        insert account;

        Test.startTest();

        account.ATLASLive__c = false;
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(0, eventLog.size());

	}

	/*
		Test that an already activated account is not sent to GA again
	*/
	@istest private static void test_activateAccountWithGAClientIdFurtherUpdate(){
		bg_GAMockInterface.bg_GAMockRespond mock = new bg_GAMockInterface.bg_GAMockRespond();
        Test.setMock(HttpCalloutMock.class, mock);

        GA_Integration__c gaSettings = new GA_Integration__c();
        gaSettings.Endpoint__c = 'testing.com';
        gaSettings.Property_Id__c = '12345';
        insert gaSettings;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 15000.0, 0.0);
        insert pricebook;
        Account account = bg_Account_TestUtils.createCitationAccount('1', 10000);
        account.gaClientID__c = '12345';
        insert account;
        Contact contact = bg_Contact_TestUtils.createContact('test 2', account.Id);
		insert contact;
        Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
        contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today();
        insert contract;

        Test.startTest();

        account.Last_Contract__c = contract.Id;
        update account;

        account.Name = account.Name + '2';
        update account;

        Test.stopTest();

        List<GA_Event_Log__c> eventLog = [select Status__c, Related_Record_ID__c, Response__c, Event_Type__c from GA_Event_Log__c where Related_Record_ID__c = :account.Id];
        system.assertEquals(1, eventLog.size());
        system.assertEquals(bg_Constants.ACCOUNT_ACTIVATION, eventLog.get(0).Event_Type__c);

	}

}