/**
* @File Name          : CaseTriggerHSQueueHandler.apx
* @Description        : To assign case directly to H&S queue.
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
public with sharing class CaseTriggerHSQueueHandler {
    public static Id hsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HS_Advice_Generic').getRecordTypeId();
    public static Map<Id, Case> filteredCaseMap = new Map<Id, Case>();
    public static Map<Id,Id> caseAccountMap = new Map<Id, Id>();
    public static Id etQueueId;
    public static Id handSGenericrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HS_Advice_Generic').getRecordTypeId();
    public static Id eltAdvicerecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
    public static Id hrCYJrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HR_CYJ').getRecordTypeId();
    public static Id atlasrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();
    
    //SST-255
  public static void updateOwnershipChange(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        
        for(Case c:newCaseList){
            if(c.Ownership_Change__c==false && c.OwnerId!= oldCaseMap.get(c.Id).OwnerId && (c.RecordTypeId==handSGenericrecordTypeId || c.RecordTypeId==eltAdvicerecordTypeId || c.RecordTypeId==hrCYJrecordTypeId))
                c.Ownership_Change__c=true;
            if(c.RecordTypeId == atlasrecordTypeId && c.Status == 'Resolved' && c.Ownership_Change__c == False)
                c.Ownership_Change__c = True;
        }
    }
    
    public static void updateDateTimeofLastStatusUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        if(Trigger.isInsert){
            for(Case c:newCaseList){
                c.Date_Time_of_Last_Status_Update__c=System.now();
            }
        }
        else
        {
            for(Case c:newCaseList){
                if(c.status!=null && c.status!= oldCaseMap.get(c.Id).status){
                    c.Date_Time_of_Last_Status_Update__c=System.now(); 
                }
            }
        }
    }

    public static void caseAssignmentHSHandler(List<Case> newCaseList ){
        if(CaseTransfer_Util.isAlreadyRan ){
            return;
        }
        getHSQueueId();
        checkCriteria(newCaseList);
        
        if(  (NULL != filteredCaseMap  && filteredCaseMap.size() > 0 ) && 
          	(Limits.getQueueableJobs() != Limits.getLimitQueueableJobs())){ //ASYNC JOB 
            system.enqueueJob(new CaseAssignmentHSQueuebaleFunction(filteredCaseMap, caseAccountMap, system.now()));
        }
    }
    
    //CHECK CRITERIA TO SEE IF OWNER IS CHNAGED TO H&S ADVICE 
    public static void checkCriteria(List<Case> newCaseList){
       
        for( Case caseObj : [select id, ownerId, AccountId,RecordTypeId, Reception_Transfer_To__c from Case where Id IN :newCaseList ] ){
            if( caseObj.ownerId == etQueueId && caseObj.RecordTypeId == hsRecordTypeId ){
                filteredCaseMap.put( caseObj.Id, caseObj);
              
                if( caseObj.AccountId != null ){
                caseAccountMap.put(caseObj.Id, caseObj.AccountId);
              
                }
            }
        }
    }
    //GET HS ADVISE QUEUE ID
    public static void getHSQueueId(){ 
        etQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'H_S_Advice' and Type = 'Queue'].Id;
     
       }

}