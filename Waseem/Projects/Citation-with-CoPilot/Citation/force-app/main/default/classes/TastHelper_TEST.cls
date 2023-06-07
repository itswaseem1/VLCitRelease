@isTest
public class TastHelper_TEST {


    @isTest
    private static void whenCalledMultipleTimes_OnlyQueriesUsersOnce()
    {
        TaskHelper.getUsers();
        
        System.assertEquals(1, Limits.getQueries());
        
        TaskHelper.getUsers();
        
        System.assertEquals(1, Limits.getQueries());
    }

    @IsTest
    private static void testTrigger()
    {
        NVMContactWorld__InteractionEvent__c ilog = new NVMContactWorld__InteractionEvent__c();
        ilog.NVMContactWorld__IndexedCallObjectIdentifier__c = 'Lead';
        ilog.NVMContactWorld__Type__c = 'Deliver';
        ilog.NVMContactWorld__TimeStamp__c = System.Now().addDays(2); 
        ilog.NVMContactWorld__Agent__c = UserInfo.getUserId();
        insert ilog;
        
        List<NVMContactWorld__InteractionEventNote__c> ilognotes = new List<NVMContactWorld__InteractionEventNote__c>();
        NVMContactWorld__InteractionEventNote__c ilognote = new NVMContactWorld__InteractionEventNote__c();
        ilognote.name = 'Test';
        ilognote.NVMContactWorld__Event__c = ilog.Id;
        ilognote.NVMContactWorld__Detail__c = 'test';
        ilognotes.add(ilognote);
        
        NVMContactWorld__InteractionEventNote__c ilognote2 = new NVMContactWorld__InteractionEventNote__c();
        ilognote2.name = 'Test';
        ilognote2.NVMContactWorld__Event__c = ilog.Id;
        ilognote2.NVMContactWorld__Detail__c = 'ts-ts';
        ilognotes.add(ilognote2);
        
        insert ilognotes;
        
        
        List<Task> lstTask = TestDataFactory.generateTask_Lead('TestLead','TestComp',10,true);
        List<Task> lstTask2 = new List<Task>();
        Task tk1 = lstTask[0];
        tk1.CallType = 'Inbound';
        tk1.CallObject = 'Lead';
        lstTask2.add(tk1);
        Task tk2 = lstTask[1];
        tk2.CallType = 'Inbound';
        tk2.Description = '-ts-st-';
        tk2.CallObject = 'Lead';
        lstTask2.add(tk2);
        Task tk3 = lstTask[2];
        tk3.CallType = 'Inbound';
        tk3.Description = 'test';
        tk3.CallObject = 'Lead';
        lstTask2.add(tk3);
        Task tk4 = lstTask[3];
        tk4.CallType = 'Inbound';
        tk4.Description = 'test';
        tk4.CallObject = 'Lead';
        lstTask2.add(tk4);
        update lstTask2;
        
        System.assertEquals(10,[SELECT count() from Task] );
       
    }
}