public with sharing class UnAssignAtlasAccessUnitsBatch implements Database.Batchable<sObject>,Database.stateful {
    List<Partner_Member_Relationship__c> selectedPmrList = new List<Partner_Member_Relationship__c>();
    Map<Id, Partner_Member_Relationship__c> updatedPmrListMap = new Map<Id, Partner_Member_Relationship__c>();
    String partnerAccId;
    public unAssignAtlasAccessUnitsBatch(List<Partner_Member_Relationship__c> pmrList,String accId ,Map<Id, Partner_Member_Relationship__c> newPmrListMap){
        system.debug('pmrList in constructor--');
        selectedPmrList = pmrList;
        partnerAccId = accId;
        updatedPmrListMap = newPmrListMap;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('Inside start method');
        String query = 'SELECT Id,Name,Member_Lead__c,Member_Lead__r.How_To_Hub_Member__c,Member__c, Partner__c,HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c,Member_left_Partner_date__c FROM Partner_Member_Relationship__c Where Id=:selectedPmrList';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Partner_Member_Relationship__c> pmrList) {
        system.debug('pmrList execute Batch---'+pmrList);
        Set<Id> memberIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();
        List<Lead> leadUpdateList = new List<Lead>();
        List<Contract> contractList = new List<Contract>();
        for(Partner_Member_Relationship__c partMemObj: pmrList){
            partMemObj.H_S_Access_Unit_Assigned__c = NULL;
            partMemObj.HR_Access_Unit_Assigned__c = NULL;
            if(updatedPmrListMap.containsKey(partMemObj.Id)){
                partMemObj.Member_left_Partner_date__c = updatedPmrListMap.get(partMemObj.Id).Member_left_Partner_date__c;
            }
            if(partMemObj.Member__c!=null){
                memberIdSet.add(partMemObj.Member__c);
            }
            if(partMemObj.Member_Lead__c!=null && partMemObj.Member_Lead__r.How_To_Hub_Member__c){
                leadIdSet.add(partMemObj.Member_Lead__c);
            }
        }
        system.debug('memberIdSet---'+memberIdSet);
        Database.update(pmrList,false);
        for(Contract objCont: [SELECT Id,Cancellation_Date__c, Cancellation_Reason__c,Status FROM Contract 
                               WHERE AccountId=:memberIdSet 
                               AND RecordType.Name='Standard Contract'
                               AND Status != 'Cancelled'
                               AND Total_Contract_Value__c = 0
                               AND (H_S_Member_Atlas_Access_Units__c > 0 OR HR_Member_Atlas_Access_Units__c > 0)
                              ]){
                                  objCont.Status = 'Cancelled';
                                  objCont.Cancellation_Date__c = System.today();
                                  objCont.Cancellation_Reason__c = 'Partner ceased service';
                                  contractList.add(objCont);
                              }
        if(!contractList.isEmpty()){
            Database.update(contractList,false); 
        }
        if(!leadIdSet.isEmpty()){
            for(Id objId:leadIdSet){
                leadUpdateList.add(new Lead(Id=objId,How_To_Hub_Member__c=false));
            }
            system.debug('leadUpdateList--'+leadUpdateList);
            if(!leadUpdateList.isEmpty()){
                Database.update(leadUpdateList,false);
            }
        }
    }
    public void finish(Database.BatchableContext BC){    
        system.debug('Inside finish method');
        Account accId = new Account(Id=partnerAccId);
        accId.UnAssign_Access_Units_In_Progress__c = false;
        ByPassUtils.ByPass('AccountTrigger');
        Database.update(accId,false);
    }
}