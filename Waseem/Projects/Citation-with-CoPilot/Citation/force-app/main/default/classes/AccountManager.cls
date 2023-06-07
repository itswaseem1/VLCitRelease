public class AccountManager {

    
    public AccountManager() {

    }
    
    public static void updateNewAccCluster (List<Account> accList){

        Map<Id,Cluster__c> mapAccountCluster = new Map<Id,Cluster__c> ();
                
        if(!accList.isEmpty()){
            mapAccountCluster =  ClusterManager.getclusterName(accList);
        }
        system.debug('mapAccountCluster::= '+mapAccountCluster);

        for(Account acc: accList){
            if(acc.Postcode_District__c != Null){
                if(!mapAccountCluster.isEmpty() && mapAccountCluster.containsKey(acc.Id)){
                    acc.Cluster__c = mapAccountCluster.get(acc.Id).Name;
                }
            }
        }
    }

    public static void updateExistingAccCluster (List<Account> accList, map<Id, Account> oldAccMap){
        
        Map<Id,Account> mapAccount = new Map<Id,Account> ();
        Map<Id,Cluster__c> mapAccountCluster = new Map<Id,Cluster__c> ();
        
        if(!accList.isEmpty() && !oldAccMap.isEmpty()){

            mapAccountCluster =  ClusterManager.getclusterName(accList);
            
            system.debug('mapAccountCluster::= '+mapAccountCluster);
            
            for(Account acc: accList){
                if(acc.Postcode_District__c != Null){
                    if(acc.Postcode_District__c != oldAccMap.get(acc.Id).Postcode_District__c){
                        if(!mapAccountCluster.isEmpty() && mapAccountCluster.containsKey(acc.Id)){
                            acc.Cluster__c = mapAccountCluster.get(acc.Id).Name;
                        }
                    }
                }
            }
        }
        
    }
}