/**
* @File Name          : ScheduleBatchToActivateMilestones.cls
* @Description        : 
* @Author             : 
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 3/25/2021.
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     3/25/2021       Initial Version
**/
public with sharing class ScheduleBatchToDeleteMergedCases implements System.Schedulable{
    
    public void execute(System.SchedulableContext sc){
        BatchToDeleteMergedCases  scheduledbatch = new BatchToDeleteMergedCases();
        Database.executeBatch(scheduledbatch);
    }
}