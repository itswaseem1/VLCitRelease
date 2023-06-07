/******************************
Aurther : Sai KarthiK
Date    : 07th Jan 2020
Purpose : Scheduled Job updates the QMS_Process_RPI_Rollup__c field on Billing Contract
******************************/

global class QMSRPIUpdateBatchJob implements Database.Batchable<SObject>,Database.Stateful {

    private String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id,ffbc__Contract__c FROM ffbc__ContractLineItem__c WHERE (ffbc__Contract__r.ffbc__Status__c!=\'Expired\' AND ffbc__Contract__r.ffbc__Status__c!=\'Superseded\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ffbc__ContractLineItem__c> scope){
        try{
                List<Id> billContractList = new List<Id>();
                List<ffbc__Contract__c> billContractUp = new List<ffbc__Contract__c>();
                Map<Id,Decimal> totalValuesMap = new Map<Id,Decimal>();
                Map<Id,Decimal> trueValuesMap = new Map<Id,Decimal>();
                for(ffbc__ContractLineItem__c cli : scope){
                    billContractList.add(cli.ffbc__Contract__c);
                }
                for(AggregateResult rs:[SELECT ffbc__Contract__c,COUNT(Id) totalCount FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN:billContractList GROUP BY ffbc__Contract__c]){
                    totalValuesMap.put((Id)rs.get('ffbc__Contract__c'),(Decimal)rs.get('totalCount'));
                }
                for(AggregateResult rs:[SELECT ffbc__Contract__c,COUNT(Id) totalCount FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN:billContractList AND QMS_Process_RPI_Line__c=true GROUP BY ffbc__Contract__c]){
                    trueValuesMap.put((Id)rs.get('ffbc__Contract__c'),(Decimal)rs.get('totalCount'));
                }
                for(Id billId:totalValuesMap.keySet()){
                    if(trueValuesMap.containskey(billId) && trueValuesMap.get(billId)>0){
                        ffbc__Contract__c billConUp = new ffbc__Contract__c();
                        billConUp.Id = billId;
                        billConUp.QMS_Process_RPI_Rollup__c = true;
                        billContractUp.add(billConUp);
                    }else{
                        ffbc__Contract__c billConUp = new ffbc__Contract__c();
                        billConUp.Id = billId;
                        billConUp.QMS_Process_RPI_Rollup__c = false;
                        billContractUp.add(billConUp);
                    }
                }
                if(!billContractUp.isEmpty()){
                    Database.update(billContractUp,false);
                }
        }catch(Exception e){
            System.debug('Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
    }
}