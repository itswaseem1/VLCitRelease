/**
	* This class contains unit tests for validating the behavior of Apex classes
	* and triggers.
	*
	* Unit tests are class methods that verify whether a particular piece
	* of code is working properly. Unit test methods take no arguments,
	* commit no data to the database, and are flagged with the testMethod
	* keyword in the method definition.
	*
	* All test methods in an organization are executed whenever Apex code is deployed
	* to a production organization to confirm correctness, ensure code
	* coverage, and prevent regressions. All Apex classes are
	* required to have at least 75% code coverage in order to be deployed
	* to a production organization. In addition, all triggers must have some code coverage.
	*
	* The @isTest class annotation indicates this class only contains test
	* methods. Classes defined with the @isTest annotation do not count against
	* the organization size limit for all Apex scripts.
	*
	* See the Apex Language Reference for more information about Testing and Code Coverage.
	*/

	@isTest
	private class CreateBillingScheduleControllerTest 
	{

	static testMethod void testMethodOne()
	{
		User systemTestUser = TestHarness.createTestUser();
		System.runAs(systemTestUser)
		{
			//ARRANGE
			customSettings();
			Account testAccount = TestHarness.createAccount(true);
			Product2 testProduct = TestHarness.createProduct(true);
			Opportunity testOpportunity = TestHarness.createOpportunity(true, testAccount.id);
			PricebookEntry testPriceBookEntry = TestHarness.createPriceBookEntry(true, testProduct.id);
			OpportunityLineItem testOpportunityLine = TestHarness.createOpportunityProduct(true, testOpportunity.id, testPriceBookEntry.id);
			ffbc__SoftDate__c softDate = TestHarness.createSoftDate(true); 
			fferpcore__Company__c billingCompany = TestHarness.createBillingCompany(true);
			ffbc__Contract__c billingContract = TestHarness.createBillingContract(true, testAccount, billingCompany, testOpportunity);
			ffbc__ContractLineItem__c billingContractLine = TestHarness.createBillingContractLine(true, testProduct, softDate, billingContract);
			ffbc.ContractsService.ActivationRequest activateReq = new ffbc.ContractsService.ActivationRequest();
			activateReq.ContractIds = new Set<Id>{billingContract.id};
			//ffbc.ContractsService.Activation(activateReq);

			//ACT
			Test.startTest();
			delete [SELECT id FROM ffbc__BillingSchedule__c];
			CreateBillingScheduleController controler = new CreateBillingScheduleController();
			CreateBillingScheduleController.createSchedules(new List<id>{billingContract.id});
			Test.stopTest();

			//ASSERT
			//system.assertEquals(13, [SELECT count() FROM ffbc__BillingSchedule__c]);
		}
	}

		private static void customSettings()
		{
		c2g__codaGeneralLedgerAccount__c gl = new c2g__codaGeneralLedgerAccount__c();
		gl.Name = '45100 - Trade Debtors Control';
		gl.Account_Description__c = 'Trade Debtors Control';
		gl.c2g__ReportingCode__c = '45100';
		gl.c2g__ExternalId__c = '45100 - Trade Debtors Control';
		gl.Sub_Ledger_Required__c = 'Tax';
		gl.c2g__TrialBalance1__c = 'Balance Sheet';
		gl.c2g__Type__c = 'Balance Sheet';
		gl.c2g__TrialBalance2__c = 'Current Assets';
		gl.c2g__TrialBalance3__c = 'Trade debtors';
		insert gl;

		c2g__codaTaxCode__c tc = new c2g__codaTaxCode__c();
		tc.c2g__ExternalId__c = 'GB-O-STD';
		tc.CurrencyIsoCode = 'GBP';
		tc.ffvat__NetBox__c = 'Box 6';
		tc.ffvat__TaxBox__c = 'Box 1';
		tc.c2g__Description__c = 'UK Output Standard Rated';
		tc.c2g__GeneralLedgerAccount__c = gl.Id;
		insert tc;

		c2g__codaTaxCode__c tc1 = new c2g__codaTaxCode__c();
		tc1.c2g__ExternalId__c = 'GB-I-STD';
		tc1.CurrencyIsoCode = 'GBP';
		tc1.ffvat__NetBox__c = 'Box 7';
		tc1.ffvat__TaxBox__c = 'Box 4';
		tc1.c2g__Description__c = 'UK Input Standard Rated';
		tc1.c2g__GeneralLedgerAccount__c = gl.Id;
		insert tc1;
		
			ffbc__BackgroundProcessSettings__c settings = new ffbc__BackgroundProcessSettings__c();
		settings.ffbc__GenerateSchedulesQueueSize__c = 5;
		settings.ffbc__GenerateSchedulesSchedulesPerLine__c = 100;
		settings.ffbc__GenerateSchedulesScopeSize__c = 5;

		insert settings;
		}
	}