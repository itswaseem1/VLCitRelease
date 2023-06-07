/**
* @File Name          : CaseTriggerELTQueueHandler.apx
* @Description        : To assign case directly to ELT queue.
* @Author             : Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 8/9/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    5/15/2021      Initial Version            SS-518
**/
public with sharing class CaseTriggerELTQueueHandler {
    public static Id eltRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
    public static Map<Id, Case> filteredCaseMap = new Map<Id, Case>();
    public static Map<Id,Id> caseAccountMap = new Map<Id, Id>();
    public static Id etQueueId;
    public static void caseAssignmentELTHandler(List<Case> newCaseList ){
        
        if(CaseTransfer_Util.isAlreadyRan ){
            return;
        }
        getELTQueueId();
        checkCriteria(newCaseList);
        
        if(  (NULL != filteredCaseMap  && filteredCaseMap.size() > 0 ) && 
          	(Limits.getQueueableJobs() != Limits.getLimitQueueableJobs())){ //ASYNC JOB 
            system.enqueueJob(new CaseAssignmentELTQueuebaleFunction(filteredCaseMap, caseAccountMap, system.now()));
        }
    }
    
    //CHECK CRITERIA TO SEE IF OWNER IS CHNAGED TO ELT ADVICE
    public static void checkCriteria(List<Case> newCaseList){
        
        for( Case caseObj : [select id, ownerId, AccountId,RecordTypeId, Reception_Transfer_To__c from Case where Id IN :newCaseList ] ){
            if( caseObj.ownerId == etQueueId && caseObj.RecordTypeId == eltRecordTypeId){
                filteredCaseMap.put( caseObj.Id, caseObj);
                if( caseObj.AccountId != null ){
                caseAccountMap.put(caseObj.Id, caseObj.AccountId);
                }
            }
        }
    }
    //GET ELT ADVISE QUEUE ID
    public static void getELTQueueId(){ 
        etQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'ELT_Advice' and Type = 'Queue'].Id;
       }
}