@isTest
public class schPolicyObjTriggerTest {
	@testSetup
    static void setup(){
        FSL__Scheduling_Policy__c schPolicy = new FSL__Scheduling_Policy__c();
        schPolicy.Name = 'test Policy';
        insert schPolicy;
        
        FSL__Service_Goal__c goal = new FSL__Service_Goal__c();
        Id goalRecordTypeId = Schema.SObjectType.FSL__Service_Goal__c.getRecordTypeInfosByName().get('ASAP').getRecordTypeId();
        goal.Name = 'ASAP test';
        goal.RecordTypeId = goalRecordTypeId;
        insert goal;
        
        FSL__Scheduling_Policy_Goal__c policyObj = new FSL__Scheduling_Policy_Goal__c();
        policyObj.FSL__Service_Goal__c = goal.Id;
        policyObj.FSL__Scheduling_Policy__c = schPolicy.Id;
        policyObj.FSL__Weight__c = 6;
        insert policyObj;
        
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
        FSL__Scheduling_Policy_Goal__c schPolicy1 = [Select Id from FSL__Scheduling_Policy_Goal__c limit 1];
       // System.runAs(systemTestUser){
            try{
                delete schPolicy1;
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }
       // }
    }
}