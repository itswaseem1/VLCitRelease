/******************************
Aurther : Vazeer Mohammed
Date    : 17th Nov 2021
Purpose : Scheduled Job updates the Revenue Recognition Logic Percent field on CLI based on RRL
******************************/
global class PercentPopScheduledJob implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id,Month__c,Revenue_Recognition_Logic_Percent__c,Revenue_Recognition_Logic__c FROM ffbc__ContractLineItem__c WHERE Revenue_Recognition_Logic__c != NULL AND Month__c != NULL  AND ffbc__ContractStatus__c!=\'Superseded\' AND ffbc__ContractStatus__c!=\'Expired\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ffbc__ContractLineItem__c> scope){
        List<ffbc__ContractLineItem__c> cliList = new List<ffbc__ContractLineItem__c>();
        Set<Id> revIds = new Set<Id>();
        Map<Id,Revenue_Recognition_Logic__c> revRecMap = new Map<Id,Revenue_Recognition_Logic__c>();
        try{
            for(ffbc__ContractLineItem__c cli : scope){
                if(cli.Revenue_Recognition_Logic__c!=null){
                    revIds.add(cli.Revenue_Recognition_Logic__c);
                }
            }
            for(Revenue_Recognition_Logic__c objRev:  Database.query(PercentPopScheduledJobHelper.AllFields('Revenue_Recognition_Logic__c',revIds))){
                revRecMap.put(objRev.Id,objRev);
            }
            system.debug('revRecMap--'+revRecMap);
            for(ffbc__ContractLineItem__c cli : scope){
                Decimal valDec = Decimal.valueOf(cli.Month__c);
                if(valDec>=1){
                    cli.Revenue_Recognition_Logic_Percent__c = (Decimal)revRecMap.get(cli.Revenue_Recognition_Logic__c).get('Month_'+valDec+'__c');
                }else{
                    cli.Revenue_Recognition_Logic_Percent__c = 0;
                }
                cliList.add(cli);
            }
            system.debug('cliList---'+cliList);
            if(!cliList.isEmpty()){
                Database.update(cliList,false);
            }
        }catch(Exception e){
            System.debug('Error Message:::'+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new PercentPopScheduledJob(), Integer.valueOf(System.Label.PercentPopScheduledJobBatchSize));
   	}
}