@isTest
private class TaskTriggerHandlerTest {
    public static Id eltAdvicerecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
      public static Id taskrecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Service_360_Default').getRecordTypeId();  

    private static testMethod void CheckCallCount() {
        user assignedUser = [select id from user where userType = 'Standard' and Isactive = true and ProfileId = '00eD00000016PHn' limit 1] ; 
        list<id> asidl = new list<id>();
        asidl.add(assignedUser.id);
        user unassignedUser = [select id from user where userType = 'Standard' and Isactive = true and ProfileId = '00eD00000016PHn' and id not in:asidl limit 1] ;
        Lead testLead = new lead(FirstName='Bob', LastName='Marley', Status='Callback Requested', Company='Jammin Ltd', BDC__c=assignedUser.id, FT_Employees__c=12, PT_Employees__c=3, Directors__c=0, Subcontractors__c=0,Callback_Date_Time__c=System.now());
        insert testLead; 
        list<task> tList = new list<task>() ;
        for(Integer i=1;i<=12;i++) {
            id asid = assignedUser.id;
            id unasid= unassignedUser.id;
            if(i <= 3) {
                
                tList.add(new task(subject = 'Outbound Call', Status = 'Completed', OwnerId=asid, WhoId=testLead.id)) ;
             }
             else if(i>=4 && i<=6)
             {
                tList.add(new task(subject = 'Outbound Call', Status = 'Not Started', OwnerId=asid, WhoId=testLead.id)) ;
             }
             else if(i>=7 && i<=9)
             {
                 
                tList.add(new task(subject = 'Outbound Call', Status = 'Completed', OwnerId=unasid, WhoId=testLead.id)) ;
             }
            else{
                tList.add(new task(subject = 'Skipped Outbound Call', Status = 'Completed', OwnerId=unasid, WhoId=testLead.id)) ;
            }
        }
        insert tList ;
        test.starttest() ;
        update tList ;
        test.stoptest() ;
        
        
        Lead tListCheck1 = [select BDC_Calls__c from lead where id = :testLead.id] ;
        
        
        //system.assertEquals(3,tListCheck1.BDC_Calls__c) ;
        
    }
    private static testMethod void CheckCallCountforNonStartedTasks() {
        user assignedUser = [select id from user where userType = 'Standard' and Isactive = true and ProfileId = '00eD00000016PHn' limit 1] ; 
        list<id> asidl = new list<id>();
        asidl.add(assignedUser.id);
        user unassignedUser = [select id from user where userType = 'Standard' and Isactive = true and ProfileId = '00eD00000016PHn' and id not in:asidl limit 1] ;
        Lead testLead = new lead(FirstName='Bob', LastName='Marley', Status='Callback Requested', Company='Jammin Ltd', BDC__c=assignedUser.id, FT_Employees__c=12, PT_Employees__c=3, Directors__c=0, Subcontractors__c=0,Callback_Date_Time__c=System.now());
        insert testLead;
        //Insert a account for assigning to WhatId of task record
        Account acc=new Account(Name='Test',EL_HR_Advice_TrafficLight__c='Test',HS_TrafficLight__c='Test',EL_HR_TrafficLight__c='Test',HS_Advice_TrafficLight__c='Test');
        insert acc;
        //Insert a contact for assigning to who id of task record
        Contact con=new Contact(LastName='Test',AccountId=acc.Id);
        insert con;
        //create a task list to store tasks to insert
        list<task> tList = new list<task>() ;
        id asid = assignedUser.id;
        //Create a new tasks one with WhoId as LeadId and One with WhoId as Contact Id and Provide account and insert
        tList.add(new task(subject = 'Outbound Call', Status = 'Not Started', OwnerId=asid, WhoId=testLead.id)) ;
        tList.add(new task(subject = 'Outbound Call', Status = 'Not Started', OwnerId=asid, WhoId=con.id,WhatId=acc.Id)) ;
        insert tList ;
        test.starttest() ;
        //change the status of task for which whoid is contact id to completed and make EL_HR_advice_task__c to true and Update the list
        tList[1].status='Completed';
        tList[1].EL_HR_advice_task__c=true;
        update tList ;
        test.stoptest() ;
    }
    
    private static testMethod void checkSegmentation() {
        
        Account acc=new Account(Name='Test',EL_HR_Advice_TrafficLight__c='Test',HS_TrafficLight__c='Test',EL_HR_TrafficLight__c='Test',HS_Advice_TrafficLight__c='Test');
        insert acc;
        
        Case c = new Case(Subject = 'test case', AccountId = acc.id, Description = 'test description', recordTypeId = eltAdvicerecordTypeId);
        insert c;
        
        Task t = new Task(WhatId = c.id, Subject = 'Test Task', recordTypeId = taskrecordTypeId);
        insert t;
    }
}