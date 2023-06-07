global class ContractRenewalForecastSchedulable implements Schedulable

{
    global void execute(SchedulableContext sc)
        
    {  
        ContractRenewalForecastUpdateBatch batchObject = new ContractRenewalForecastUpdateBatch();
        database.executeBatch(batchObject,2);
        
    }
    
}