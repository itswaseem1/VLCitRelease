public With Sharing class AssetTriggerHandler {
    public void afterUpdateAssetDetails(List<Asset> newAssetList, Map<id, Asset> oldAssetMap){
        List<Asset> onHoldAssetList = new List<Asset>();
        List<Asset> offHoldAssetList = new List<Asset>();
        AssetTriggerOnHoldHelper onHold = new AssetTriggerOnHoldHelper();
        AssetTriggerOffHoldHelper offHold = new AssetTriggerOffHoldHelper();
        
            for(Asset assetRec : newAssetList){
                if(assetRec.status == 'On Hold' && oldAssetMap.get(assetRec.id).Status != 'On Hold'){
                   onHoldAssetList.add(assetRec) ;
                }
                if(assetRec.status != 'On Hold' && oldAssetMap.get(assetRec.id).Status == 'On Hold'){
                    offHoldAssetList.add(assetRec);
                }
                
            }
            if(!onHoldAssetList.isEmpty()){
                onHold.getAssetToEntitlement(onHoldAssetList);
                onHold.getAssetToCases(onHoldAssetList);
            }
            if(!offHoldAssetList.isEmpty()){
                offHold.getAssetToEntitlement(offHoldAssetList);
            	offHold.getAssetToCases(offHoldAssetList);
            }
     }
}