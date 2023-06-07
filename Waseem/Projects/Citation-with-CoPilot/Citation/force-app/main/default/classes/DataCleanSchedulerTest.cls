@isTest
public class DataCleanSchedulerTest
{
    @isTest
    private static void whenScheduled_CreatesJobRecord()
    {
        Test.startTest();
        String sch = '0 0 23 * * ?';
        Id jobId = system.schedule('Data Clean', sch, new DataCleanScheduler() );
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM CronTrigger WHERE id = :jobId].size());
    }
}