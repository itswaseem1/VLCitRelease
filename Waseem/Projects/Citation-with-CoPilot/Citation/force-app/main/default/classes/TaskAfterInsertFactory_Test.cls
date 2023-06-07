@isTest
public class TaskAfterInsertFactory_Test {
    
    static testmethod void insertTask() {
        
        Lead leads = new Lead();
        leads.Company = 'Test Prospect';
        leads.LastName = 'BLANK';
        leads.status = 'open';
        leads.FT_Employees__c = 0;
        leads.PT_employees__c = 0;
        leads.Directors__c = 0;
        leads.subcontractors__c = 0;
        // add whatever other fields are required for account creation here
        insert leads;
        
        Task u = new Task();
        u.ownerId = '005D00000037QH7IAM'; // you've now successfully created your test user, time to use it on your new task
        u.whoId = leads.Id; // you've now successfully created your test contact, time to use it on your new task
        u.Subject = 'Outbound Call';
        u.Status = 'Completed';
        u.Priority = 'Normal';
        Test.StartTest();
        insert u;
        Test.stopTest();
        
        
        for (Task t : [SELECT Id, Subject, Description FROM Task WHERE Id = :u.Id]) {
            System.assertEquals('Outbound Call', t.subject); // asserts that your test worked properly
        }
    }
    
    static testmethod void getTaskMap() {
        
        Lead leads = new Lead();
        leads.Company = 'Test Prospect';
        leads.LastName = 'BLANK';
        leads.status = 'open';
        leads.FT_Employees__c = 0;
        leads.PT_employees__c = 0;
        leads.Directors__c = 0;
        leads.subcontractors__c = 0;
        // add whatever other fields are required for account creation here
        insert leads;
        
        Task u = new Task();
        u.ownerId = '005D00000037QH7IAM'; // you've now successfully created your test user, time to use it on your new task
        u.whoId = leads.Id; // you've now successfully created your test contact, time to use it on your new task
        u.Subject = 'Outbound Call';
        u.Status = 'Completed';
        u.Priority = 'Normal';
        insert u;
        List<Task> tskList = new List<Task>();
        tskList.add(u);
        Map<id,Task> tskMap = new Map<id,Task>();
        tskMap.put(u.id,u);
        Test.StartTest();
        TaskAfterInsertFactory Taif = new TaskAfterInsertFactory(tskList,tskMap);
        Test.stopTest();
        
        Map<id,Task> tskMap2 = Taif.getNewTasksMap();
        System.assertNotEquals(NULL, tskMap2.get(u.id));
        
        
    }
}