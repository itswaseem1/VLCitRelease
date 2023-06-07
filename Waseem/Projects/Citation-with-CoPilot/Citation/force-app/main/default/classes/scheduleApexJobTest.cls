@isTest
public class scheduleApexJobTest {

    @testSetUp
    public static void setup(){
        TestDataFactory.buildCustomSettingsForDialListJobs('DialListCriteriaFieldsBatch');
        List<Automation_Configuration__c> aucRecords = TestDataFactory.createAutomationConfigurationRecords();
    }
    
    @isTest
    public static void testschdule(){
        Test.startTest();
        ScheduleApexJob.scheduleDialListCriteriaFieldsBatch('classname');
            Test.stopTest();
    }
}