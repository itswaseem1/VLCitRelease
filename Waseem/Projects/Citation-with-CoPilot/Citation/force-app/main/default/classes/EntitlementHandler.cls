public with sharing class EntitlementHandler {
  public static Map<Id, Entitlement> assetEntitlmentMap = new Map<Id, Entitlement>();
  public static Map<Id, Date> assetStartDateMap = new Map<Id, Date>();
  public static Map<Id,Asset> assetMap = new Map<Id,Asset>(); 
  public static Map<Id, Date> assetEndDateMap = new Map<Id, Date>();

  public static void populateFields(List<Entitlement> entitlementList) {
    for (Entitlement enObj : entitlementList) {
      if (null != enObj.AssetId) {
        assetEntitlmentMap.put(enObj.AssetId, enObj);
      }
    }

    populateCLI();
    populateDatesonEntitlement(entitlementList);
  }

  public static void populateCLI() {
    for (Asset assetObj : [
      SELECT
        Id,
        Billing_Contract__c,Service_Start_Date__c,Service_End_Date__c,
        Billing_Contract_Line_Item__r.Service_Start_Date__c,
        Billing_Contract_Line_Item__r.Service_End_Date__c
      FROM Asset
      WHERE Id IN :assetEntitlmentMap.keyset()
    ]) {
      assetStartDateMap.put(
        assetObj.Id,
        assetObj.Billing_Contract_Line_Item__r.Service_Start_Date__c
      );
      assetEndDateMap.put(
        assetObj.Id,
        assetObj.Billing_Contract_Line_Item__r.Service_End_Date__c
      );
      assetMap.put(assetObj.Id, assetObj);
    }
  }

  public static void populateDatesonEntitlement(
    List<Entitlement> entitlementList
  ) {
    for (Entitlement enObj : entitlementList) {
      enObj.StartDate = assetStartDateMap?.get(enObj.AssetId) != null ?  assetStartDateMap?.get(enObj.AssetId) : assetMap?.get(enObj.AssetId)?.Service_Start_Date__c;
      enObj.EndDate = assetEndDateMap?.get(enObj.AssetId) != null ? assetEndDateMap?.get(enObj.AssetId) : assetMap?.get(enObj.AssetId)?.Service_End_Date__c; 
    }
  }
}