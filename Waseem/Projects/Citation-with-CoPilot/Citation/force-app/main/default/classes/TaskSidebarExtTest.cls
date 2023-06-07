@isTest
private class TaskSidebarExtTest {
	
	 @testSetup static void setup() {
	 	list<task> tList = new list<task>() ;
	 	for(Integer i=1;i<=10;i++) {
	 		if(i <= 5) {
	 			tList.add(new task(subject = 'No H&S Advice Calls in 6 Months',hs_advice_task__c = true)) ;
	 		}
	 		else{
	 			tList.add(new task(subject = 'No EL/HR Advice Calls in 6 Months', status='Completed',EL_HR_advice_task__c = true)) ;
	 		}
	 	}
	 	insert tList ;
	 	
	 	Task_Reassign__c t = new Task_Reassign__c() ;
	 	insert t ;
	 	
	 }

    static testMethod void TestReassignAll() {
       	TaskSideBarExt Ext = new TaskSideBarExt() ;
       	id CurrentUserID = UserInfo.GetUserId() ;
       	user newUser = [select id from user where userType = 'Standard' and Isactive = true and id <> :CurrentUserID limit 1] ;
       	
       	Ext.TaskReassign.Old_User__c = CurrentUserId ;
       	Ext.TaskReassign.new_user__c = newUser.id ;
       	Ext.TaskReassign.Open_Tasks_Only__c = false ;
       	
       	test.starttest() ;
       	Ext.DoReassign() ;
       	test.stoptest() ;
       	
       	
       	list<Task> tListCheck1 = [select id from task where ownerid = :newUser.id] ;
       	
       	list<Task> tListCheck2 = [select id from task where ownerid = :CurrentUserID] ;
       	
       	system.assertEquals(10,tListCheck1.size()) ;
       	system.assertEquals(0,tListCheck2.size()) ;
       	
       	
        
    }
    
    static testMethod void TestReassignOpen() {
       	TaskSideBarExt Ext = new TaskSideBarExt() ;
       	id CurrentUserID = UserInfo.GetUserId() ;
       	user newUser = [select id from user where userType = 'Standard' and Isactive = true and id <> :CurrentUserID limit 1] ;
       	
       	Ext.TaskReassign.Old_User__c = CurrentUserId ;
       	Ext.TaskReassign.new_user__c = newUser.id ;
       	Ext.TaskReassign.Open_Tasks_Only__c = true ;
       	
       	test.starttest() ;
       	Ext.DoReassign() ;
       	test.stoptest() ;
       	
       	
       	list<Task> tListCheck1 = [select id from task where ownerid = :newUser.id] ;
       	
       	list<Task> tListCheck2 = [select id from task where ownerid = :CurrentUserID] ;
       	
       	system.assertEquals(5,tListCheck1.size()) ;
       	system.assertEquals(5,tListCheck2.size()) ;
       	
       	
        
    }
    
    
     static testMethod void TestReassignUsersMustDiffer() {
       	TaskSideBarExt Ext = new TaskSideBarExt() ;
       	id CurrentUserID = UserInfo.GetUserId() ;
       	user newUser = [select id from user where userType = 'Standard' and Isactive = true and id <> :CurrentUserID limit 1] ;
       	
       	Ext.TaskReassign.Old_User__c = CurrentUserId ;
       	Ext.TaskReassign.new_user__c = CurrentUserId ;
       	Ext.TaskReassign.Open_Tasks_Only__c = true ;
       	
       	
       	
       	
		
		PageReference TSB = Page.TaskSidebar ;
    	test.starttest() ;
    	Test.setCurrentPage(TSB);
    	
       	Ext.DoReassign() ;
       	
       	
       	List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('differ')) b = true;
		    system.debug(msg.getdetail()) ;
		}
		
		test.stoptest() ;
		system.assert(b);
       	
       	
       	list<Task> tListCheck1 = [select id from task where ownerid = :newUser.id] ;
       	
       	list<Task> tListCheck2 = [select id from task where ownerid = :CurrentUserID] ;
       	
       	system.assertEquals(0,tListCheck1.size()) ;
       	system.assertEquals(10,tListCheck2.size()) ;
       	
       	
        
    }
    
     static testMethod void TestReassignUsersMustBePopulated() {
       	TaskSideBarExt Ext = new TaskSideBarExt() ;
       	id CurrentUserID = UserInfo.GetUserId() ;
       	user newUser = [select id from user where userType = 'Standard' and Isactive = true and id <> :CurrentUserID limit 1] ;
       	
       	Ext.TaskReassign.Old_User__c = null ;
       	Ext.TaskReassign.new_user__c = CurrentUserId ;
       	Ext.TaskReassign.Open_Tasks_Only__c = true ;
       	
       	
       	
       	
		
		PageReference TSB = Page.TaskSidebar ;
    	test.starttest() ;
    	Test.setCurrentPage(TSB);
    	
       	Ext.DoReassign() ;
       	
       	
       	List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('both fields')) b = true;
		    system.debug(msg.getdetail()) ;
		}
		
		test.stoptest() ;
		system.assert(b);
       	
       	
       	list<Task> tListCheck1 = [select id from task where ownerid = :newUser.id] ;
       	
       	list<Task> tListCheck2 = [select id from task where ownerid = :CurrentUserID] ;
       	
       	system.assertEquals(0,tListCheck1.size()) ;
       	system.assertEquals(10,tListCheck2.size()) ;
       	
       	
        
    }
    
  
}