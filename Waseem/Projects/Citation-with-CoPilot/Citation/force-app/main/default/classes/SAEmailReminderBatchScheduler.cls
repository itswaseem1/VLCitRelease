/**
* @File Name          : SAEmailReminderBatchScheduler.apx
* @Description        : To schedule Batch class on service appointment.
* @Author             : Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 8/9/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    6/15/2021      Initial Version            SS-518
**/
public without sharing class SAEmailReminderBatchScheduler implements Schedulable{
 public void execute(SchedulableContext sc){
        
        SAEmailReminderBatch batch = new SAEmailReminderBatch(); 
        database.executebatch(batch, 20);

    }

}