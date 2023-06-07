public class iHASCO_PurgatorySchedule implements Schedulable

{
    public void execute(SchedulableContext sc)
        
    {  
        iHASCO_PurgatoryBatch batchObject = new iHASCO_PurgatoryBatch();
        database.executeBatch(batchObject,5);
        
    }
    
}