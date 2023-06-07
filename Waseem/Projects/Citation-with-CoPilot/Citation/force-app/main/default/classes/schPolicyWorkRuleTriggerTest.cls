@isTest
public class schPolicyWorkRuleTriggerTest {
	@testSetup
    static void setup(){
        Id wrRecordTypeId = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByName().get('Field Service - Match Territory').getRecordTypeId();
        FSL__Work_Rule__c rule1 = new FSL__Work_Rule__c();
        rule1.Name = 'Test Work Rule';
        rule1.FSL__Description__c = 'Test permission';
        rule1.RecordTypeId = wrRecordTypeId;
        insert rule1;        
        
        FSL__Scheduling_Policy__c schPolicy = new FSL__Scheduling_Policy__c();
        schPolicy.Name = 'test Policy';
        insert schPolicy;
        
        FSL__Scheduling_Policy_Work_Rule__c schPolicyWorkRule = new FSL__Scheduling_Policy_Work_Rule__c();
        schPolicyWorkRule.FSL__Scheduling_Policy__c = schPolicy.Id;
        schPolicyWorkRule.FSL__Work_Rule__c = rule1.id;
        insert schPolicyWorkRule;
    }
    @isTest
    static void deletePermission(){
        
        /*User systemTestUser = TestHarness.createTestUser();
        PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'FSL_Admin_Permissions'
    ];
        insert new PermissionSetAssignment(
      AssigneeId = systemTestUser.id,
      PermissionSetId = ps.Id
    );*/
        FSL__Scheduling_Policy_Work_Rule__c schPolicyWorkRule = [Select Id from FSL__Scheduling_Policy_Work_Rule__c where FSL__Work_Rule__r.Name = 'Test Work Rule'];
       // System.runAs(systemTestUser){
            try{
                delete schPolicyWorkRule;
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }
       // }
    }
}