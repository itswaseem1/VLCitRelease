Public class iHASCO_PurgatoryBatch implements Database.Batchable<sobject>{
    
    Public Database.QueryLocator start(database.BatchableContext BC){
        Date Today= system.today();
        String activeStatus = DataConstants.ACCOUNT_STATUS_ACTIVE;
        String query = 'SELECT ID from Account WHERE iHASCO_Client__c = True AND Contract_End_Date__c < Today AND iHASCO_Finance_Status__c =:activeStatus'  ;
        return database.getQueryLocator(query);
    }
    
    Public void execute(Database.BatchableContext BC,list<Account> scope){
        
        List<id> accIdList = new List<id>();
        for(Account act: scope){
            
            accIdList.add(act.id);
        }
        iHASCOAccountServices.updatePurgatoryStatusInactive(accIdList);
        
    }
    
    Public void finish(database.BatchableContext BC){
    }
}