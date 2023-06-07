public with sharing class TaskSidebarExt {
	
	
	public Task_Reassign__c TaskReassign {get;private set;}
	public boolean errorflag {get;set;}
	public list<task> TaskList {get;set;}
	public string strMessage {get;set;}
	public boolean CanReasignTasks {get;set;}
	
	
	public TaskSidebarExt() {
		CheckCanReassign() ;
		ErrorFlag = false ;
		TaskReassign = [Select id,Old_User__c, new_user__c, Open_Tasks_Only__c from Task_Reassign__c limit 1 ] ;
		
	}
	

	public void CheckCanReassign() {
		id UserId = userinfo.getuserid() ;
		list<PermissionSetAssignment> psa = [Select id from PermissionSetAssignment where Assignee.id = :UserId and PermissionSet.label = 'Reassign Tasks'] ;
		CanReasignTasks = false ;
		if(psa.size() >0) {
			CanReasignTasks = true ;
		}
	}
	
	
	public pagereference DoReassign() {
		ErrorFlag = false ;
		
		system.debug('User ID ------------> ' + TaskReassign );
		
		if(TaskReassign.Old_User__c == null || TaskReassign.New_User__c == null) {
		 ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Error,'complete both fields') ;
                    ApexPages.AddMessage(message) ;
                    ErrorFlag = true ;
		}  
		
		if(TaskReassign.Old_User__c == TaskReassign.New_User__c && TaskReassign.Old_User__c != null) {
		 ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Error,'Users must differ') ;
                    ApexPages.AddMessage(message) ;
                    ErrorFlag=true ;
		}    
		if(ErrorFlag == false) {
				system.debug('Time To Do Update') ;
				if(TaskReassign.Open_Tasks_Only__c) {
					system.debug('Open Tasks Only') ;
					TaskList = [select id, ownerid from task where ownerid = :TaskReassign.Old_User__c and status <> 'Completed' and (hs_advice_task__c = true or el_hr_advice_task__c = true or hs_task__c = true or el_hr_task__c = true)] ;
					
				}
				else
				{
					system.debug('AllTasks') ;
					TaskList = [select id, ownerid from task where ownerid = :TaskReassign.Old_User__c  and (hs_advice_task__c = true or el_hr_advice_task__c = true or hs_task__c = true or el_hr_task__c = true)] ;
				}
				
				for(Task t : TaskList) {
					t.ownerid = TaskReassign.New_User__c ;
				}
				
				system.debug(TaskList) ;
				
				update TaskList ;
				
				TaskReassign = [Select id,Old_User__c, new_user__c, Open_Tasks_Only__c from Task_Reassign__c limit 1 ] ;
		
				strMessage = 'Done' ;
				
				ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Info,strMessage) ;
			 	ApexPages.AddMessage(message) ;
		}
		
		return null ;
	}
	
	
	
	
	
    
}