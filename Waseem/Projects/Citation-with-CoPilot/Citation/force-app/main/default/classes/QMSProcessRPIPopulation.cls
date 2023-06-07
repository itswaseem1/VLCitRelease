public class QMSProcessRPIPopulation {
    public void fieldPopulation(List<ffbc__ContractLineItem__c> cliList){
        if(AvoidRecursion.QMSRPI_isFirstRun()){
            try{
                List<Id> billContractList = new List<Id>();
                List<ffbc__Contract__c> billContractUp = new List<ffbc__Contract__c>();
                Map<Id,Decimal> totalValuesMap = new Map<Id,Decimal>();
                Map<Id,Decimal> trueValuesMap = new Map<Id,Decimal>();
                for(ffbc__ContractLineItem__c cli : cliList){
                    billContractList.add(cli.ffbc__Contract__c);
                }
                for(AggregateResult rs:[SELECT ffbc__Contract__c,COUNT(Id) totalCount FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN:billContractList GROUP BY ffbc__Contract__c]){
                    totalValuesMap.put((Id)rs.get('ffbc__Contract__c'),(Decimal)rs.get('totalCount'));
                }
                for(AggregateResult rs:[SELECT ffbc__Contract__c,COUNT(Id) totalCount FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN:billContractList AND QMS_Process_RPI_Line__c=true GROUP BY ffbc__Contract__c]){
                    trueValuesMap.put((Id)rs.get('ffbc__Contract__c'),(Decimal)rs.get('totalCount'));
                }
                for(ffbc__Contract__c billId:[SELECT Id,QMS_Process_RPI_Rollup__c FROM ffbc__Contract__c WHERE Id IN:totalValuesMap.keySet()]){
                    if(trueValuesMap.get(billId.Id)>0){
                        billId.QMS_Process_RPI_Rollup__c = true;
                        billContractUp.add(billId);
                   }else{
                        billId.QMS_Process_RPI_Rollup__c = false;
                        billContractUp.add(billId);
                    }
                }
                if(!billContractUp.isEmpty()){
                    update billContractUp;
                }
            }
            catch(Exception e){
                System.debug('fieldPopulation:::'+e.getMessage());
            }
        }
    }
}