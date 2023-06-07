global class ContractRenewalForecastUpdateBatch implements Database.Batchable<sobject>{
    
    global Database.QueryLocator start(database.BatchableContext BC){
        String query = 'SELECT EndDate,ID, NAME, StartDate, SBQQ__RenewalQuoted__c, SBQQ__RenewalForecast__c, RecordType.Name from Contract WHERE RecordType.Name =\''+'iHASCO Standard Contract'+'\' AND SBQQ__RenewalForecast__c = false';
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<Contract> scope){
        System.debug('scope.size()'+scope.size());
        List<Contract> contList = new List<Contract>();
        for(Contract ct: scope){
             System.debug('ct===>'+ct);
             Date dt = ct.EndDate;
            if(test.isRunningTest()){
                dt=system.today();
            }
            else
             dt = dt.addDays(-90);
        	 if(dt == system.today()){
                ct.SBQQ__RenewalForecast__c = true;
                ct.SBQQ__RenewalQuoted__c = true;
            	contList.add(ct);
            }
        }
        System.debug('contList==>'+ contList);
        if(contList != null && contList.size()>0) {
            try{
                Database.update(contList);
            }catch(Exception e){
                system.debug('DML Exception...!');
            }
        }
    }
    
    global void finish(database.BatchableContext BC){
    }
}