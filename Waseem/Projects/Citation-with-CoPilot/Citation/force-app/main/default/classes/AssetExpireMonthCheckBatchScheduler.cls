public with sharing class AssetExpireMonthCheckBatchScheduler implements schedulable  {
public void execute(SchedulableContext sc){
        
        AssetExpireMonthCheckBatch batch = new AssetExpireMonthCheckBatch();
		database.executebatch(batch,50);

    } 
}