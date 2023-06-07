public class TerritiroryAssignmentHandler implements Queueable, Database.AllowsCallouts{
    
    public Set<id> accids = null;
        
    public void execute(QueueableContext context) {
        Map<id,Account> standardContractAccounts = new Map<id,Account>();
        List<Account> updatedAccount = new List<Account>();
        Set<String> IdSet = new Set<String>();
        Map<Id,Cluster__c> accClusterMap = new Map<Id,Cluster__c>();
        List<Territory2> territoryList = [SELECT Id, Name, ParentTerritory2.name, Territory2Type.Developername FROM Territory2 where Territory2Type.Developername = 'Contact_Strategy'];
        Map<String,String> TerrChildParentMap = new Map<String,String>();
        for(Territory2 t2: territoryList){
            TerrChildParentMap.put(t2.Name,t2.ParentTerritory2.name);
        }
        standardContractAccounts = new Map<id,Account>([SELECT Id, Postcode_District__c , S__c, Contact_Strategy_Territory__c  from Account where id IN :accIds]);
        accClusterMap = ClusterManager.getclusterNameByRole(standardContractAccounts.values(),DataConstants.ClUSTER_ROLE_CONTACT_STRATEGY);
         System.debug('Check-This-Waseem');
        for(String acid: accClusterMap.keySet()){
            if(TerrChildParentMap != null &&
               !TerrChildParentMap.isEmpty() &&
               TerrChildParentMap.containsKey(String.Valueof(standardContractAccounts.get(acid).Contact_Strategy_Territory__c)) &&
               accClusterMap.get(acid).Name == TerrChildParentMap.get(String.Valueof(standardContractAccounts.get(acid).Contact_Strategy_Territory__c))){
                
            } else {
                Account ac = new Account();
                ac.id = acid;
                IdSet.add(acid);
                ac.Contact_Strategy_Territory__c = accClusterMap.get(acid).Name;
                ac.Cluster__c = accClusterMap.get(acid).Name;
                updatedAccount.add(ac);
            }
        }
        update updatedAccount;   
        if(IdSet != null && !(IdSet.isEmpty()) ){
            RunTerritoryRules job = new RunTerritoryRules() ;
            job.accntIds = IdSet; 
            IF(!Test.isRunningTest()){
            System.enqueueJob(job);
        }
    }
}
}