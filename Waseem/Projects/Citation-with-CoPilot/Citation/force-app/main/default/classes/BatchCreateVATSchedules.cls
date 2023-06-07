global with sharing class BatchCreateVATSchedules implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,ffbc__Status__c,SF_Contract__c,SF_Contract__r.RecordTypeId,VAT_schedule_start__c,VAT_schedule_filetrigger__c,Service_Start_Roll_up__c,VAT_schedules__c ,(Select Id,Name from Attachments) from ffbc__Contract__c where Sf_Contract__r.RecordType.Name=\'E-Commerce\' and VAT_schedules__c!=null and Sf_Contract__c!=null and Sf_Contract__r.Id!=null and Sf_Contract__r.status=\'Active\' and ffbc__Status__c=\'Active\'';
        return Database.getQueryLocator(query);
    }

     global void execute(Database.BatchableContext BC, List<ffbc__Contract__c> billingContracts) {
         List<ffbc__Contract__c> contractsToProcess=new List<ffbc__Contract__c>();
         for(ffbc__Contract__c ffbc:billingContracts){
             if(ffbc.Attachments.isEmpty()){
                 contractsToProcess.add(ffbc);
            }
         }

        if(!contractsToProcess.isEmpty()){
            TriggerffbcContractHandler.createVATSchedules(contractsToProcess);
        }
    }   
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchCreateVATSchedules());
    }
    global void finish(Database.BatchableContext BC){    
    }
}