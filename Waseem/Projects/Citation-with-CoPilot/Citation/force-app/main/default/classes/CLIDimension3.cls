public class CLIDimension3 {
    public void executeMethod(List<ffbc__ContractLineItem__c> contractNew){
      if(AvoidRecursion.DM3_isFirstRun()){
        Map<Id,String> cliMap = new Map<Id,String>();
        Map<String,Id> dimMap = new Map<String,Id>();
        List<ffbc__ContractLineItem__c> cliList = new List<ffbc__ContractLineItem__c>();
        
        for(ffbc__ContractLineItem__c cli : [SELECT Id,ffbc__Contract__r.Name FROM ffbc__ContractLineItem__c WHERE Id IN :contractNew]){
        	cliMap.put(cli.Id,cli.ffbc__Contract__r.Name);
        }
        for(c2g__codaDimension3__c dm : [SELECT Id,Name FROM c2g__codaDimension3__c WHERE Name IN:cliMap.values()]){
            System.debug('dm List::::'+dm.Id+'name::'+dm.Name);
            dimMap.put(dm.Name,dm.Id);
        }        
        for(ffbc__ContractLineItem__c cli : [SELECT Id,ffbc__Contract__r.Name FROM ffbc__ContractLineItem__c WHERE Id IN :contractNew]){
            if(dimMap.containsKey(cli.ffbc__Contract__r.Name)){
                System.debug('Inside If condition');
                cli.Dimension_3__c = dimMap.get(cli.ffbc__Contract__r.Name);
                cliList.add(cli);
            }
        }
        if(!cliList.isEmpty()){
            update cliList;
        }
    }
  }
}