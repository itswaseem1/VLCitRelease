/**
* @File Name          : ScheduleBatchToActivateMilestones.cls
* @Description        : 
* @Author             : 
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 2/22/2021.
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     2/22/2021       Initial Version
**/
public with sharing class SDP_ScheduleBatchToActivateMilestones implements System.Schedulable{
    
    public void execute(System.SchedulableContext sc){
        SDP_BatchToActivateMilestones  scheduledbatch = new SDP_BatchToActivateMilestones(null,false);
        if(!test.isRunningTest()){
        	Database.executeBatch(scheduledbatch,1);
        }else{
           Database.executeBatch(scheduledbatch); 
        }
    }
}