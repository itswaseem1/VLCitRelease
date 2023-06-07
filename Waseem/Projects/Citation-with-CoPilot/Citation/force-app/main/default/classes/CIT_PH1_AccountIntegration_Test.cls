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
public with sharing class CIT_PH1_AccountIntegration_Test {
	@isTest
	static void AccountIntegration_FinanceApproved_isFinanceApproved() {
		Integer expectedValue = 1;
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;
		Account account = CIT_PH1_Trigger_Utils.createAccounts(expectedValue)[0];
		CIT_PH1_HTTPManager.isApexTest = true;
		insert account;
		System.Debug('Nimil : ' + account);
		Test.StartTest();
			account.Finance_Approved__c = true;
			update account;
		Test.stopTest();
		 
		Account actualValue = [SELECT Id, Finance_Approved__c FROM Account WHERE Id =:account.Id];
		System.Assert(actualValue!=null);
		System.Assert(true,actualValue.Finance_Approved__c);
    }
}