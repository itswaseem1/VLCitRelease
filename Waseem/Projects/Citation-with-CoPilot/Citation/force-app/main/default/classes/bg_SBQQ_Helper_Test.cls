@isTest
private class bg_SBQQ_Helper_Test
{
	@isTest
	static void testDepartmetnNotQMSProcessIDset()
	{

		 User ownerTest = new User(Department='Citation',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last',
	     Email = 'test@brightgen.com',
	     Username = 'test@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST',
	     Title = 'title',
	     Alias = 'alias',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US'
		);

		insert ownerTest;

         Account acc=new Account(Name='test');
        insert acc;
		SBQQ__QuoteProcess__c processTest = new SBQQ__QuoteProcess__c();
		insert processTest;

		SBQQ__Quote__c quoteTest = new SBQQ__Quote__c(OwnerID = ownerTest.Id,SBQQ__Account__c=acc.id);

		insert quoteTest;

		SBQQ__Quote__c quoteInserted = [SELECT SBQQ__QuoteProcessID__c FROM SBQQ__Quote__c WHERE Id = :quoteTest.Id];

		System.assertEquals(quoteInserted.SBQQ__QuoteProcessID__c, processTest.Id,'Process Id Not set to a3V9E000000CjBT');
	}

		@isTest
	static void testDepartmetnIsQMSNotProcessIDsetAndBillingFrequencyisQuarterlyDD()
	{

		 User ownerTest = new User(Department='QMS',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last',
	     Email = 'test@brightgen.com',
	     Username = 'test@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST',
	     Title = 'title',
	     Alias = 'alias',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US'
		);

		insert ownerTest;

		SBQQ__Quote__c quoteTest = new SBQQ__Quote__c(OwnerID = ownerTest.Id);

		insert quoteTest;

		SBQQ__Quote__c quoteInserted = [SELECT SBQQ__QuoteProcessID__c,SBQQ__BillingFrequency__c FROM SBQQ__Quote__c WHERE Id = :quoteTest.Id];

		System.assert(quoteInserted.SBQQ__QuoteProcessID__c !='a3V9E000000CjBT','Process Id has been set to a3V9E000000CjBT');
		System.assertNotEquals(quoteInserted.SBQQ__BillingFrequency__c, 'Quarterly DD', 'Billing frequency is not Quarterly DD');
	}

	@isTest
	static void testNoPrimaryContactNoCustomerSignatory()
	{

		 User ownerTest = new User(Department='Citation',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last',
	     Email = 'test@brightgen.com',
	     Username = 'test@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST',
	     Title = 'title',
	     Alias = 'alias',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US'
		);

		insert ownerTest;

		SBQQ__Quote__c quoteTest = new SBQQ__Quote__c(OwnerID = ownerTest.Id);

		insert quoteTest;

		SBQQ__Quote__c quoteInserted = [SELECT Customer_Signatory__c FROM SBQQ__Quote__c WHERE Id = :quoteTest.Id];

		System.assertEquals(quoteInserted.Customer_Signatory__c, null,'There is Customer Signatory');
	}

	@isTest
	static void testPrimaryContactIntoCustomerSignatory()
	{

		 User ownerTest = new User(Department='Citation',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last',
	     Email = 'test@brightgen.com',
	     Username = 'test@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST',
	     Title = 'title',
	     Alias = 'alias',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US'
		);

		insert ownerTest;

		Contact contactTest = new Contact();

		SBQQ__Quote__c quoteTest = new SBQQ__Quote__c(OwnerID = ownerTest.Id, SBQQ__PrimaryContact__c = contactTest.Id);

		insert quoteTest;

		SBQQ__Quote__c quoteInserted = [SELECT Customer_Signatory__c FROM SBQQ__Quote__c WHERE Id = :quoteTest.Id];

		System.assertEquals(quoteInserted.Customer_Signatory__c, contactTest.Id,'Billing frequency is not Monthly');
	}

	@isTest
	static void testOwnerManagerIsNUll()
	{

		 User ownerTest = new User(Department='Citation',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last',
	     Email = 'test@brightgen.com',
	     Username = 'test@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST',
	     Title = 'title',
	     Alias = 'alias',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US'
		);

		insert ownerTest;

		SBQQ__Quote__c quoteTest = new SBQQ__Quote__c(OwnerID = ownerTest.Id);

		insert quoteTest;

		SBQQ__Quote__c quoteInserted = [SELECT Manager__c FROM SBQQ__Quote__c WHERE Id = :quoteTest.Id];

		System.assertEquals(quoteInserted.Manager__c, null,'There is a manager');
	}


		@isTest
	static void testOwnerManagerIsNotNUll()
	{
		 User ownerManager = new User(Department='Citation',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last1',
	     Email = 'test1@brightgen.com',
	     Username = 'test1@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST1',
	     Title = 'title1',
	     Alias = 'alias1',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US'
		);

		insert ownerManager;

		 User ownerTest = new User(Department='Citation',
	     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	     LastName = 'last',
	     Email = 'test@brightgen.com',
	     Username = 'test@brightgen.com' + System.currentTimeMillis(),
	     CompanyName = 'TEST',
	     Title = 'title',
	     Alias = 'alias',
	     TimeZoneSidKey = 'America/Los_Angeles',
	     EmailEncodingKey = 'UTF-8',
	     LanguageLocaleKey = 'en_US',
	     LocaleSidKey = 'en_US',
	     Manager = ownerManager
		);

		insert ownerTest;

		SBQQ__Quote__c quoteTest = new SBQQ__Quote__c(OwnerID = ownerTest.Id);

		insert quoteTest;

		SBQQ__Quote__c quoteInserted = [SELECT Manager__c FROM SBQQ__Quote__c WHERE Id = :quoteTest.Id];

		System.assertEquals(quoteInserted.Manager__c, ownerTest.ManagerId,'Manager set incorrectly');
	}


}