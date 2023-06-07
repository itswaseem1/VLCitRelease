/**
* @File Name          : SDP_QMSAutoCloseMissedBatch.cls
* @Description        :
* @Author             : Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 07/26/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     07/26/2021      Initial Version
**/
@SuppressWarnings('PMD')
public class SDP_QMSAutoCloseMissedBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<String> recordTypeNames = new List<String>{'QMS_Visits'};
            Set<Id> recordTypeIds = new Set<Id>();
        
        for (String recordTypeName : recordTypeNames) {
            recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId());
        }
        
        Date dateToConsider = System.today();
        String query = '';
        if (test.isRunningTest()) {
            query = 'Select Id, Status, Start_Date__c,Due_Date__c, Milestone_Template__r.Name, Milestone_Template__r.Business__c FROM Case';
        } else {
            query = 'Select Id, Status, Start_Date__c,Due_Date__c, Milestone_Template__r.Name, Milestone_Template__r.Business__c FROM Case where RecordTypeId in :recordTypeIds AND Origin = \'Service Delivery Milestone\' AND Milestone_Template__r.Business__c=\'QMS\' AND Due_Date__c <= :dateToConsider';
        }
        return Database.getQueryLocator(query); 
        
    }
    
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();
        List<WorkOrder> workordersToUpdate = new List<WorkOrder>();
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        Set<Id> caseIdSet = new Set<Id>();
        
        
        for (Case caseInScope : scope) {
            if(caseInScope.Milestone_Template__r.Name.contains('Annual')){
                casesToUpdate.add(new case(Id= caseInScope.Id, Status = 'Missed'));
                caseIdSet.add(caseInScope.Id);
            } 
        }
        
        if( caseIdSet != null && caseIdSet.size() > 0 ){
            for( WorkOrder wObj : [SELECT Id,Status, (SELECT Id, status,reason__c FROM ServiceAppointments WHERE Status NOT IN ('Completed','Cannot Complete','Canceled')) FROM WorkOrder WHERE caseId IN:caseIdSet AND Status NOT IN ('Closed','Completed','Canceled','Cannot Complete') ]){
                workordersToUpdate.add( new WorkOrder(id= wObj.Id , status ='Cannot Complete'));
                for(ServiceAppointment saObj : wObj.ServiceAppointments){
                    saToUpdate.add(new ServiceAppointment(Id= saObj.Id, Status = 'Cannot Complete', Reason__c='Service Window Closed'));
                }
            }
        }
        
        if (null != casesToUpdate && casesToUpdate.size() > 0) {
            try {
                update casesToUpdate;
            } catch (Exception error) {
                system.debug(error.getMessage());
            }
        }
        
        if (null != workordersToUpdate && workordersToUpdate.size() > 0) {
            try {
                update workordersToUpdate;
            } catch (Exception error) {
                system.debug(error.getMessage());
            }
        }
        
        if (null != saToUpdate && saToUpdate.size() > 0) {
            try {
                update saToUpdate;
            } catch (Exception error) {
                system.debug(error.getMessage());
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        system.debug('after finish logic to send error emails');
    }
    
}