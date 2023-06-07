public with sharing class AssignAtlasAccessUnitsBatch implements Database.Batchable<sObject>,Database.stateful {
    List<Partner_Member_Relationship__c> selectedPmrList = new List<Partner_Member_Relationship__c>();
    Integer availableHR;
    Integer availableHS;
    String partnerAccId;
    public AssignAtlasAccessUnitsBatch(List<Partner_Member_Relationship__c> pmrList, Integer availHR,Integer availHS,String accId){
        system.debug('pmrList in constructor--'+pmrList+'--'+availHR+'--'+availHS);
        selectedPmrList = pmrList;
        availableHR = availHR;
        availableHS = availHS;
        partnerAccId = accId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('Inside start method');
        String query = 'SELECT Id,Name,Member_Lead__c,Member_Lead__r.How_To_Hub_Member__c,Member__c, Partner__c,HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c,Member_left_Partner_date__c FROM Partner_Member_Relationship__c Where Id=:selectedPmrList AND Member_left_Partner_date__c = NULL';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Partner_Member_Relationship__c> pmrList) {
        system.debug('pmrList execute Batch---'+pmrList+'--'+availableHR+'--'+availableHS);
        Integer hrcount = 0;
        Integer hscount = 0;
        Boolean howtoHub;
        List<Partner_Member_Relationship__c> filteredPmrList = new List<Partner_Member_Relationship__c>();
        for(Partner_Member_Relationship__c partMemObj: pmrList){
            howtoHub = false;
            if(availableHR>0 && hrcount < availableHR && partMemObj.HR_Access_Unit_Assigned__c==null){
                howtoHub = true;
                partMemObj.HR_Access_Unit_Assigned__c = 'HR How-To Hub';
                availableHR--;
            }
            if(availableHS>0 && hscount < availableHS && partMemObj.H_S_Access_Unit_Assigned__c==null){
                howtoHub = true;
                partMemObj.H_S_Access_Unit_Assigned__c = 'H&S How-To Hub';
                availableHS--;
            }
            if(howtoHub){
               filteredPmrList.add(partMemObj); 
            }
        }
        if(!filteredPmrList.isEmpty()){
            partnerMemberAtlasAccess.createMember(filteredPmrList);
        }
    }
    public void finish(Database.BatchableContext BC){    
        system.debug('Inside finish method');
        Account accId = new Account(Id=partnerAccId);
        accId.Assign_Access_Units_In_Progress__c = false;
        ByPassUtils.ByPass('AccountTrigger');
        Database.update(accId,false);
    }
}