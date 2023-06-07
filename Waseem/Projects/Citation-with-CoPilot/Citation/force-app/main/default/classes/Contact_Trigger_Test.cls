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
private class Contact_Trigger_Test {

    @isTest
    static void ContactTrigger_InsertContact_isContactInserted() {
        Integer expectedValue = 20;
        List<Contact> Contacts = CIT_PH1_Trigger_Utils.createContacts(expectedValue);
        
        Test.StartTest();
            insert Contacts;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Contact WHERE Id in :Contacts];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void ContactTrigger_UpdateContact_isContactUpdated() {
        Integer expectedValue = 20;
        List<Contact> Contacts = CIT_PH1_Trigger_Utils.createContacts(expectedValue);
        insert Contacts;
        
        Test.StartTest();
            update Contacts;    
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Contact WHERE Id in :Contacts];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void ContactTrigger_DeleteContact_isContactDeleted() {
        Integer expectedValue = 20;
        List<Contact> Contacts = CIT_PH1_Trigger_Utils.createContacts(expectedValue);
        insert Contacts;
        
        Test.StartTest();
            delete Contacts;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Contact WHERE Id in :Contacts];
        
        System.AssertEquals(0,actualValue);
    }
    
    @isTest
    static void ContactTrigger_UnDeleteContact_isContactUndeleted() {
        Integer expectedValue = 20;
        List<Contact> Contacts = CIT_PH1_Trigger_Utils.createContacts(expectedValue);
        insert Contacts;
        delete Contacts;
        
        Test.StartTest();
            undelete Contacts;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Contact WHERE Id in :Contacts];
        System.AssertEquals(expectedValue,actualValue);
    }
}