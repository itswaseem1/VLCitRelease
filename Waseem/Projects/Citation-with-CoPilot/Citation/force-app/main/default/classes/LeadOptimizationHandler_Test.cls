@isTest
private class LeadOptimizationHandler_Test {
	
	@testSetup static void setup() {
	    Lead myLead = new Lead(LastName = 'Fry', Company='Fry And Sons', MADE_Criteria__c = 'Outbound - 1', AnnualRevenue = 100000, Appointment_Type__c = 'Combined', Approved_By_User__c = UserInfo.getUserId(), Approved_Date__c = Date.today(), Date_Made__c = Date.today(), Sector__c = 'ACCOMMODATION');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
        myLead.RecordTypeId = devRecordTypeId;
        insert myLead;
        
	}
	
	

    static testMethod void AutoCloseALead() {
       Lead l = [select id,OutboundAnswerMachineCallCount__c,NVMConnect__NextContactTime__c,Status from Lead limit 1] ;
       test.starttest() ;
       L.OutboundAnswerMachineCallCount__c = 6 ;
       update L ;
       test.stoptest() ;
       
       Lead CheckLead = [select id,OutboundAnswerMachineCallCount__c,NVMConnect__NextContactTime__c,Status from Lead limit 1]  ;
       system.assertEquals('Closed',CheckLead.Status) ; 
    }
}