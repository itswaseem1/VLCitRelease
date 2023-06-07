/**
* @File Name          : SDP_ScheduleQMSAutoCloseMissedBatch.cls
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
public with sharing class SDP_ScheduleQMSAutoCloseMissedBatch implements System.Schedulable{
    
    public void execute(System.SchedulableContext sc){
        SDP_QMSAutoCloseMissedBatch  scheduledbatch = new SDP_QMSAutoCloseMissedBatch();
        Database.executeBatch(scheduledbatch, 10);
    }
}