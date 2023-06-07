public with sharing class PartnerMemberContractCreationBatch implements Database.Batchable<SObject>, Database.stateful {
    Set<Id> pmrSet = new Set<Id>();
    Set<Id> insufficientPMRIdSet = new Set<Id>();
    Map<Id,Integer> hrAccessUnitsMap = new Map<Id,Integer>();
    Map<Id,Integer> hsAccessUnitsMap = new Map<Id,Integer>();
    public partnerMemberContractCreationBatch(Set<Id> pmrIdSet, Map<Id,Integer> hrAccessMap, Map<Id,Integer> hsAccessMap){
        pmrSet = pmrIdSet;
        hrAccessUnitsMap = hrAccessMap;
        hsAccessUnitsMap = hsAccessMap;
        system.debug(hrAccessUnitsMap+'---'+hsAccessUnitsMap+'--PMCC Batch constructor---'+pmrSet);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Member_Lead__c, Member_Lead__r.How_To_Hub_Member__c, Member__c, Partner__c,HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c,Member_left_Partner_date__c FROM Partner_Member_Relationship__c Where Id=:pmrSet';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Partner_Member_Relationship__c> pmrList) {
        system.debug('pmrList---'+pmrList);
        Integer hrAccess;
        Integer hsAccess;
        Boolean howtoHub;
        List<Partner_Member_Relationship__c> updatedPMRList = new List<Partner_Member_Relationship__c>();
        for(Partner_Member_Relationship__c partMemObj: pmrList){
            howtoHub = false;
            if(hrAccessUnitsMap.containsKey(partMemObj.Partner__c) && hrAccessUnitsMap.get(partMemObj.Partner__c) > 0 && partMemObj.HR_Access_Unit_Assigned__c==null){
                howtoHub = true;
                partMemObj.HR_Access_Unit_Assigned__c = 'HR How-To Hub';
                hraccess = hrAccessUnitsMap.get(partMemObj.Partner__c);
                hrAccessUnitsMap.put(partMemObj.Partner__c,--hraccess);
            }
            if(hsAccessUnitsMap.containsKey(partMemObj.Partner__c) && hsAccessUnitsMap.get(partMemObj.Partner__c) > 0 && partMemObj.H_S_Access_Unit_Assigned__c==null){
                howtoHub = true;
                partMemObj.H_S_Access_Unit_Assigned__c = 'H&S How-To Hub';
                hsaccess = hsAccessUnitsMap.get(partMemObj.Partner__c);
                hsAccessUnitsMap.put(partMemObj.Partner__c,--hsaccess);
            }
            if(howtoHub){
                updatedPMRList.add(partMemObj);
            }else{
               insufficientPMRIdSet.add(partMemObj.Id); 
            }
        }
        system.debug('hrAccessUnitsMap---'+hrAccessUnitsMap);
        system.debug('hsAccessUnitsMap---'+hsAccessUnitsMap);
        system.debug(updatedPMRList.size()+'--updatedPMRList---'+updatedPMRList);
        if(!updatedPMRList.isEmpty()){
            partnerMemberAtlasAccess.createMember(updatedPMRList);  
        }
    }
    public void finish(Database.BatchableContext BC){    
        system.debug('In finish Method of PartnerMemberContractCreationBatch====');
        if(!insufficientPMRIdSet.isEmpty()){
            PartnerMemberUploadBatchHelper.failureEmailNotification(insufficientPMRIdSet, false);
        }
    }
}