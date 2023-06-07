/**
 * @File Name          : AssetExpireMonthCheckBatch.cls
 * @Description        : Batch Class
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/09/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     26/7/2021      Initial Version
 **/
public without sharing class AssetExpireMonthCheckBatch implements Database.Batchable<sObject> {
         
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
    Date todaysDate = System.today();
   	return Database.getQueryLocator([Select Id, Service_Start_Date__c, Service_End_date__c, Product2.Business_Type__c From Asset
                                     Where (Service_End_date__c != NULL AND Service_Start_Date__c != null AND Service_End_date__c < : todaysDate )
                                     AND Status != 'Obsolete' WITH SECURITY_ENFORCED]);

    }

    public void execute(Database.BatchableContext bc, List<Asset> assetList) {
        
        AssetExpireMonthCheckBatchHelper.getDetailsOnAssetExpires(assetList);
        
		
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('Batch Execution Finished');

    }
    


}