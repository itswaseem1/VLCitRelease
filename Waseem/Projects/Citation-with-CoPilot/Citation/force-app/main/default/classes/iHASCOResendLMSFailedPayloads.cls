//Batch to send Failed Payloads to iHASCO LMS to be scheduled in Live for Harmonic runs
global without sharing class iHASCOResendLMSFailedPayloads implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,RecordId__c,Message__c, Retry__c FROM ApplicationLog__c WHERE Retry__c = true';
        return Database.getQueryLocator(query);
    }

     global void execute(Database.BatchableContext BC, List<ApplicationLog__c> appLogs) {
         List<ApplicationLog__c> updatedApplogs = new List<ApplicationLog__c>();
         for(ApplicationLog__c applog : appLogs){
             String JsonString = applog.Message__c;
             iHASCOLmsWrapper log = (iHASCOLmsWrapper)JSON.deserialize(JsonString, iHASCOLmsWrapper.class);
             String EventType = log.EventType;
             String recordId = applog.RecordId__c;
             if(!(( recordId == '') || (EventType == ''))){
                 iHASCOLmsRestOutbound instance = new iHASCOLmsRestOutbound();
                 instance.sendLMSData(recordId, EventType);
             } 
             ApplicationLog__c updatedApplog = new ApplicationLog__c();
             updatedApplog.id = applog.id;
             updatedApplogs.add(updatedApplog);
         }
        
         if(!updatedApplogs.isEmpty()){
             delete updatedApplogs;
         }
    }    
    global void execute(SchedulableContext sc){
        iHASCOResendLMSFailedPayloads iHASCOpayloadbatch = new iHASCOResendLMSFailedPayloads();
        Database.executeBatch(iHASCOpayloadbatch, 1);
    }
    global void finish(Database.BatchableContext BC){    
    }
}