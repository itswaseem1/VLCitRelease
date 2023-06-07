@isTest
public class PartnershipCallScheduleTest 
{
    @isTest
    private static void whenLastDateNeedsUpdating_updatesAccount_CreatesTask()
    {
        Account act = new Account(Name = 'Fred', 
                                    BDC_del__c = UserInfo.getUserId() , 
                                    LastParternshipCheckIn__c = Date.today().addDays(-40));
        insert act;

        Test.startTest();
        new PartnershipCallSchedule().execute(null);
        Test.stopTest();

        act = [SELECT LastParternshipCheckIn__c, BDC_del__c
                FROM Account 
                WHERE Id = :act.Id];
        System.assertEquals(Date.today(), act.LastParternshipCheckIn__c);

        Task task = [SELECT ActivityDate FROM Task WHERE OwnerId = :act.BDC_del__c];

        System.assertEquals(Date.today().addDays(7), task.ActivityDate);
    }

    @isTest
    private static void whenLastDateIsRecent_ignoresAccount()
    {
        Account act = new Account(Name = 'Fred', 
                                    BDC_del__c = UserInfo.getUserId() , 
                                    LastParternshipCheckIn__c = Date.today().addDays(-10));
        insert act;

        Test.startTest();
        new PartnershipCallSchedule().execute(null);
        Test.stopTest();

        act = [SELECT LastParternshipCheckIn__c, BDC_del__c
                FROM Account 
                WHERE Id = :act.Id];
        System.assertEquals(Date.today().addDays(-10), act.LastParternshipCheckIn__c);

        List<Task> tasks = [SELECT ActivityDate FROM Task WHERE OwnerId = :act.BDC_del__c];

        System.assertEquals(0, tasks.size());
    }
}