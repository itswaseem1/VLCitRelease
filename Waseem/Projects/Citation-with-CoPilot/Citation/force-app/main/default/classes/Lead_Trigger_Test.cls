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
private class Lead_Trigger_Test {

    @isTest
    static void LeadTrigger_InsertLead_isLeadInserted() {
        Integer expectedValue = 5;
        List<Lead> leads = CIT_PH1_Trigger_Utils.createleads(expectedValue);
        
        Test.StartTest();
            insert leads;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Lead WHERE Id in :leads];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void LeadTrigger_UpdateLead_isLeadUpdated() {
        Integer expectedValue = 5;
        List<Lead> leads = CIT_PH1_Trigger_Utils.createleads(expectedValue);
        insert leads;
        
        Test.StartTest();
            update leads;   
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Lead WHERE Id in :leads];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void LeadTrigger_DeleteLead_isLeadDeleted() {
        Integer expectedValue = 5;
        List<Lead> leads = CIT_PH1_Trigger_Utils.createleads(expectedValue);
        insert leads;
        
        Test.StartTest();
            delete leads;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Lead WHERE Id in :leads];
        
        System.AssertEquals(0,actualValue);
    }
    
    @isTest
    static void LeadTrigger_UnDeleteLead_isLeadUndeleted() {
        Integer expectedValue = 5;
        List<Lead> leads = CIT_PH1_Trigger_Utils.createleads(expectedValue);
        insert leads;
        delete leads;
        
        Test.StartTest();
            undelete leads;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Lead WHERE Id in :leads];
        System.AssertEquals(expectedValue,actualValue);
    }
}