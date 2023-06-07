public without sharing class DataCleanScheduler implements Schedulable
{
    public void execute(SchedulableContext sctx)
    {
        // Future: check for whether it is already running. 
        // Not doing for now, as intent is to run at such a wide interval
        // that it shouldn't be an issue.
        DataCleanService.runAsync();
    }
}