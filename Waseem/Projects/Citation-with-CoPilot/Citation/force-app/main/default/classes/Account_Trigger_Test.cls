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
@isTest(isParallel=false)
private class Account_Trigger_Test {

    @TestSetup
    private static void testSetup()
    {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;
    }


    @isTest
    static void AccountTrigger_InsertAccount_isAccountInserted() {
        Integer expectedValue = 20;

        List<Account> accounts = CIT_PH1_Trigger_Utils.createAccounts(expectedValue);
        
        Test.StartTest();
            insert accounts;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Account WHERE Id in :accounts];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void AccountTrigger_UpdateAccount_isAccountUpdated() {
        Integer expectedValue = 20;

        List<Account> accounts = CIT_PH1_Trigger_Utils.createAccounts(expectedValue);
        insert accounts;
        
        Test.StartTest();
            update accounts;    
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Account WHERE Id in :accounts];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void AccountTrigger_DeleteAccount_isAccountDeleted() {
        Integer expectedValue = 20;

        List<Account> accounts = CIT_PH1_Trigger_Utils.createAccounts(expectedValue);
        insert accounts;
        
        Test.StartTest();
            delete accounts;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Account WHERE Id in :accounts];
        
        System.AssertEquals(0,actualValue);
    }
    
    @isTest
    static void AccountTrigger_UnDeleteAccount_isAccountUndeleted() {
        Integer expectedValue = 20;
        
        List<Account> accounts = CIT_PH1_Trigger_Utils.createAccounts(expectedValue);
        insert accounts;
        delete accounts;
        
        Test.StartTest();
            undelete accounts;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Account WHERE Id in :accounts];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    
}