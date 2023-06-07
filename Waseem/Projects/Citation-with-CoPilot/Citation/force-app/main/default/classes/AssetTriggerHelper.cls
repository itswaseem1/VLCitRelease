/**
 * @File Name          : AssetTriggerHelper.cls
 * @Description        : Updates the Asset with Certificate Details only on Asset creation
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka                  Initial Version
 **/
public without sharing class AssetTriggerHelper {
    public static void updateCertificateDetails(List<Asset> assetList){
        Set<Id> accId = new Set<Id>();
        List<Asset> assets = new List<Asset>();
        Map<String,List<Asset>> certMap = new Map<String,List<Asset>>();
        Map<String,Id> certIdMap = new Map<String,Id>();
        Set<Certificate__c> certInsert = new Set<Certificate__c>();
        //Fetches the Set of Assets where Business Area is QMS and valid Standard
        for(Asset ast : assetList){
            if(ast.Business_Area__c == 'QMS' && !String.isBlank(ast.Standard__c)){
                accId.add(ast.AccountId);
                assets.add(ast);
            }
        }
        if(assets.size()>0){
            List<Certificate__c> certs = [Select Id, Standard__c, Account__c from Certificate__c where Account__c In: accId and Completed__c = false WITH SECURITY_ENFORCED];
            if(certs.size() > 0){
                certIdMap = getCertificateMap(certs);
            }
            AssetCertWrapper aw = getAssetDetails(assets,certIdMap);
            certInsert = aw.certInsert;
            certMap = aw.certMap;
            if(certInsert.size() > 0){
                createNewCerts(certInsert,certMap);
            }
        }
        
    }
    
    //Creates new Certificates for Assets
    public static void createNewCerts(Set<Certificate__c> certInsert,Map<String,List<Asset>> certMap){
        List<Certificate__c> certInserts = new List<Certificate__c>(certInsert);
        Database.SaveResult[] srList = Database.insert(certInserts,false);
        Set<Id> newCertIds = new Set<Id>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                newCertIds.add(sr.getId());
            }
        }
        if(newCertIds.size()>0){
            updateAssets(newCertIds,certMap);
        }
    }
    
    //Updates the Assets with newly created Certificates
    public static void updateAssets(Set<Id> newCertIds,Map<String,List<Asset>> certMap){
        List<Certificate__c> certificates = [Select Id, Account__c, Standard__c from Certificate__c where Id In: newCertIds WITH SECURITY_ENFORCED];
        if(certificates.size() > 0){
            for(Certificate__c ct : certificates){
                String key = ct.Account__c+ct.Standard__c; 
                if(certMap.containsKey(key)){
                    for(Asset asst1 : certMap.get(key)){
                        asst1.Certificate__c = ct.Id;
                    }
                }
            }
        }
    }
    
    public static Map<String,Id> getCertificateMap(List<Certificate__c> certs){
        Map<String,Id> certIdMap = new Map<String,Id>();
        for(Certificate__c ct : certs){
            certIdMap.put(ct.Account__c+ct.Standard__c, ct.Id);
        }
        return certIdMap;
    }
    
    //Fetches the Assets for new Certificates creation
    public static AssetCertWrapper getAssetDetails(List<Asset> assets,Map<String,Id> certIdMap){
        Set<Certificate__c> certInsert = new Set<Certificate__c>();
        Map<String,List<Asset>> certMap = new Map<String,List<Asset>>();
        for(Asset at : assets){
            if(certIdMap.containsKey(at.AccountId+at.Standard__c)){
                at.Certificate__c = certIdMap.get(at.AccountId+at.Standard__c);
            }else{
                Certificate__c c = new Certificate__c(Account__c=at.AccountId,Standard__c=at.Standard__c);
                certInsert.add(c);
                if(certMap.containsKey(at.AccountId+at.Standard__c)){
                    certMap.get(at.AccountId+at.Standard__c).add(at);
                }else{
                    certMap.put(at.AccountId+at.Standard__c,new List<Asset>{at});
                }
            }
        }
        return (new AssetCertWrapper(certInsert,certMap));
    }
    
    public class AssetCertWrapper{
        public Set<Certificate__c> certInsert{get; set;}
        public Map<String,List<Asset>> certMap{get; set;}
        
        public AssetCertWrapper(Set<Certificate__c> certInsert,Map<String,List<Asset>> certMap){
            this.certInsert = certInsert;
            this.certMap = certMap;
        }
    }
}