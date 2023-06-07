//Handler for case Assignment ELT cases//
public with sharing class CaseTriggerELTHandler {
	
    public static Id eltRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
    public static Map<Id, Case> filteredCaseMap = new Map<Id, Case>();
    public static Map<Id,Id> caseAccountMap = new Map<Id, Id>();
    public static Id etQueueId;
    public static void caseAssignmentHandler(List<Case> newCaseList, Map<Id, Case> oldCaseMap ){
        
        if(CaseTransfer_Util.isAlreadyRan ){
            return;
        }
        getELTQueueId();
        checkCriteria(newCaseList,oldCaseMap);
        
        if(  (NULL != filteredCaseMap  && filteredCaseMap.size() > 0 ) && 
          	(Limits.getQueueableJobs() != Limits.getLimitQueueableJobs())){ //ASYNC JOB 
            system.enqueueJob(new CaseAssignmentELTQueuebaleFunction(filteredCaseMap, caseAccountMap, system.now()));
        }
    }
    
    //CHECK CRITERIA TO SEE IF OWNER IS CHNAGED TO ELT ADVICE
    public static void checkCriteria(List<Case> newCaseList, Map<id, Case> oldCaseMap){
        
        for( Case caseObj : newCaseList ){
            if( caseObj.ownerId == etQueueId && caseObj.ownerId != oldCaseMap.get(caseObj.Id).ownerId){
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