/**************************************
* This Cluster Manager will Return Cluster Object with Related Details
***************************************/
public class ClusterManager {
    
      
    /*:::: This method with retrun Cluster__c Object based on Prefix of the postcode ::::*/
    public static Map<Id,Cluster__c>  getclusterName (List<Account> acctList){
        Map<String,Cluster__c> mapCluster = New Map<String,Cluster__c> ();
        Map<String,String> mapCulsterNameVal = New Map<String,String> ();
        Map<String, set<String>> mapPostcodePrefix = new Map<String, set<String>> ();
        List<Cluster__c> clusterList  = New List<Cluster__c> ();
        Map<Id,Cluster__c> mapAccountCluster = new Map<Id,Cluster__c> ();
        Map<String, Account> mapPostDistAccount = new Map<String, Account> ();
        string prifixPostcode;
        
        
        if (!acctList.isEmpty()) {
            for(Account acc: acctList){
                if(acc.Postcode_District__c != Null){
                    prifixPostcode = acc.Postcode_District__c.toUpperCase();
                }
            }
        }
        System.debug('mapPostDistAccount::==' + mapPostDistAccount);
       
        clusterList = [Select Id, Name, Cluster_Prefix_Postcodes__c, Owner__c,
                              Region__c
                              From Cluster__c Where Name like '%Cluster%' ];
                                   
        System.debug('clusterList::==' + clusterList);

        for (Cluster__c cls : clusterList) {
                If(cls.Cluster_Prefix_Postcodes__c != Null && !mapPostcodePrefix.containskey(cls.Name)){
                                        mapPostcodePrefix.put(cls.Name, new Set<String>(cls.Cluster_Prefix_Postcodes__c.Split(',')));
                }
                mapCluster.put(cls.Name, cls);
            }
        

        if(!mapPostcodePrefix.isEmpty()){
            for (String clustername: mapPostcodePrefix.Keyset()) {
                for (string val: mapPostcodePrefix.get(clustername)) {
                    mapCulsterNameVal.put(val.trim(), clustername.trim());
                }
            }
        }
        
        for(account act: acctList){
            if(act.Postcode_District__c != null){
                if(mapCulsterNameVal.containsKey(act.Postcode_District__c.toUpperCase())){
                    mapAccountCluster.put(act.id,mapCluster.get(mapCulsterNameVal.get(act.Postcode_District__c.toUpperCase()).trim()));
                }
            }
            
        }
        System.debug('mapAccountCluster::=='+ mapAccountCluster);
        return mapAccountCluster;
    }
    
    public static Map<Id,Cluster__c>  getclusterNameByRole (List<Account> acctList ,String Role){
        Map<String,Cluster__c> mapCluster = New Map<String,Cluster__c> ();
        Map<String,String> mapCulsterNameVal = New Map<String,String> ();
        Map<String, set<String>> mapPostcodePrefix = new Map<String, set<String>> ();
        List<Cluster__c> clusterList  = New List<Cluster__c> ();
        Map<Id,Cluster__c> mapAccountCluster = new Map<Id,Cluster__c> ();
        Map<String, Account> mapPostDistAccount = new Map<String, Account> ();
        string prifixPostcode;
        
        
        if (!acctList.isEmpty()) {
            for(Account acc: acctList){
                if(acc.Postcode_District__c != Null){
                    prifixPostcode = acc.Postcode_District__c.toUpperCase();
                }
            }
        }
        System.debug('mapPostDistAccount::==' + mapPostDistAccount);
       
        clusterList = [Select Id, Name, Cluster_Prefix_Postcodes__c, Owner__c, Role__c, Segmentation__c,
                              Region__c
                              From Cluster__c];
        
                                   
        System.debug('clusterList::==' + clusterList);

        for (Cluster__c cls : clusterList) {
            List<String> cRoles = cls.Role__c?.Split(';');
            if( !(cRoles == null) && cRoles.contains(Role)){
                If(cls.Cluster_Prefix_Postcodes__c != Null){
                    if(!(cls.Segmentation__c == null)){
                        for(String Segmentation: cls.Segmentation__c?.Split(';')){
                            if(!mapPostcodePrefix.containskey(cls.Name + '::' + Segmentation)){
                                //map of cluster name to string set of postcodes
                                mapPostcodePrefix.put(cls.id + '::' + Segmentation, new Set<String>(cls.Cluster_Prefix_Postcodes__c.Split(',')));
                            }
                        }
                    } else{
                        mapPostcodePrefix.put(cls.id + '::' + null, new Set<String>(cls.Cluster_Prefix_Postcodes__c.Split(',')));
                    }
                }
                mapCluster.put(cls.id, cls);
            }
        }
        

        if(!mapPostcodePrefix.isEmpty()){
            for (String clusternamewithSeg: mapPostcodePrefix.Keyset()) {
                //for each cluster get prefixes one each time
                for (string val: mapPostcodePrefix.get(clusternamewithSeg)) {
                    mapCulsterNameVal.put(val.trim().toUpperCase() + '::' + clusternamewithSeg.split('::')[1].toUpperCase() , clusternamewithSeg.split('::')[0].trim());
                }
            }
        }
        for(account act: acctList){
            if(act.Postcode_District__c != null){
                String accSegmentation = act.S__c?.toUpperCase();
                if(mapCulsterNameVal.containsKey(act.Postcode_District__c.toUpperCase()  + '::' +  accSegmentation)){
                    mapAccountCluster.put(act.id,mapCluster.get(mapCulsterNameVal.get(act.Postcode_District__c.toUpperCase()  + '::' +  accSegmentation).trim()));
                }
            }    
        }
        System.debug('mapAccountCluster::=='+ mapAccountCluster);
        return mapAccountCluster;
    }
    
}