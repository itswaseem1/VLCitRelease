public without sharing class LegacyTaskTriggerHandler implements ITriggerHandler
{
	public void beforeInsert(List<SObject> newRecords)
	{
        List<Task> tasks = (List<Task>)newRecords;

        TaskTriggerHandler.updateSegmentation(tasks);
	}

	public void afterInsert(List<SObject> newRecords)
	{
        List<Task> tasks = (List<Task>)newRecords;

        ITaskHandler handler = TriggerTaskHandler.getInstance();
        handler.setFactory(new TaskAfterInsertFactory(tasks, new Map<Id, Task>(tasks)));
        handler.handle();

        TaskTriggerHandler.BDCCallCount(tasks) ;
	}

    public void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {		
    }

	public void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
	{
        List<Task> tasks = (List<Task>)newRecords.values();
        List<Task> oldTasks = (List<Task>)oldRecords.values();

        TaskTriggerHandler.AfterUpdateHandler(oldTasks, tasks) ;
        TaskTriggerHandler.BDCCallCount(tasks) ;
	}

    public void beforeDelete(List<SObject> oldRecords)
    {
        TaskTriggerPreventDelete.addError((List<Task>)oldRecords);
    }

    public void afterDelete(List<SObject> oldRecords)
    {
        TaskTriggerHandler.BDCCallCount((List<Task>)oldRecords) ;
    }

    public void afterUnDelete(List<SObject> newRecords)
    {
        TaskTriggerHandler.BDCCallCount((List<Task>)newRecords) ;
    }
}