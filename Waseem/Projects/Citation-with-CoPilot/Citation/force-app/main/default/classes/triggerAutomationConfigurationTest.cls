@isTest
public class triggerAutomationConfigurationTest {
	
     @testSetUp
    public static void setup(){
        TestDataFactory.buildCustomSettingsForDialListJobs('DialListCriteriaFieldsBatch');
        List<Automation_Configuration__c> aucRecords = TestDataFactory.createAutomationConfigurationRecords();
    }
    
    @isTest
    public static void testinsert(){
        String listTypeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_LIST_TYPE_ASSIGNMENT_RECORD_TYPE;
       	ID ListTypeRecordTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(ListTypeRecTypeName).getRecordTypeId();
         
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = ListTypeRecordTypeID;
            ac.BDM__c = 'Waseem Test 1';
            ac.List_Type__c = 'List 1c';
            ac.Maximum_Prospects__c=3;
            sl.add(ac);
        } 
        Test.startTest();
        insert sl;
        Test.stopTest();
    }
    
    @isTest
    public static void testupdate(){
        String listTypeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_LIST_TYPE_ASSIGNMENT_RECORD_TYPE;
       	ID ListTypeRecordTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(ListTypeRecTypeName).getRecordTypeId();
         
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Automation_Configuration__c ac:[SELECT Id, List_Type__c from Automation_Configuration__c where recordTypeid = :ListTypeRecordTypeID] ){
            ac.List_Type__c = 'List 1a';
            sl.add(ac);
        } 
        Test.startTest();
        update sl;
        Test.stopTest();
    }
    
    @isTest
    public static void testdelete(){
        String listTypeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_LIST_TYPE_ASSIGNMENT_RECORD_TYPE;
       	ID ListTypeRecordTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(ListTypeRecTypeName).getRecordTypeId();
         
        List<Automation_Configuration__c> sl = [SELECT Id, List_Type__c from Automation_Configuration__c where recordTypeid = :ListTypeRecordTypeID];
        Test.startTest();
        Delete sl;
        Test.stopTest();
    }
}