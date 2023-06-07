@isTest
public class BatchToDeleteMergedCasesTest {
    
    
       
  
    
    @isTest
    public static void deleteMergedCasesTest() {
     
        case caseObj = new case();
        caseObj.STart_date__c = date.today();
        caseObj.Origin = 'Service Delivery Milestone';
        caseObj.Status='Merged Closed';
        insert caseObj;
     
        Test.startTest(); 
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 6 * * * ?';
        String jobId = System.schedule('delete merged cases', cronExp, new ScheduleBatchToDeleteMergedCases());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered,'success');

        
        Test.stopTest();
    }

}