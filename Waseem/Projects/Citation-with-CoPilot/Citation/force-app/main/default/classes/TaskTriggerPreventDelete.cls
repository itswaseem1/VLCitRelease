/**
 * @File Name          : TaskTriggerPreventDelete.cls
 * @Description        : To prevent deletion of Tasks 
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 09/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     09/08/2021      Initial Version
 **/



public with sharing class TaskTriggerPreventDelete 
{
    //Method to add error message while deleting tasks.
    public static void addError(List<Task>tasks)
    {
		
		list<task> tasksCannotBeDeleted = new TaskTriggerPreventDelete().checkTaskRecordType(tasks);
		if(tasksCannotBeDeleted.size()>0){
			Id userProfileId = userinfo.getProfileId();
    		String userProfileName = [SELECT ID, Name from Profile Where Id = : userProfileId].Name;
    		if(System.Label.TaskPreventDelete.contains(userProfileName) )
			{
				For(Task t:tasks)
				{
						t.adderror(Label.Error_Message_For_Task_Deletion);
				}
			
			}
		}
	
    }

	// The below method checks the recordtype and seperate iHASCO users delete their own tasks 
	private list<task> checkTaskRecordType(list<task> tasks){
		Id iHASCOTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Default iHASCO').getRecordTypeId();
     	list<task> tasksIncluded = new list<task>();
		for(Task tsk: tasks){
			if(tsk.recordtypeid != iHASCOTaskRecordTypeId)
			{
				tasksIncluded.add(tsk);
			}
		}
		return tasksIncluded;
	}

}