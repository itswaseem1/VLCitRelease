public without sharing class EntitlementsController {
	@AuraEnabled(cacheable=true)
    public static List<EntitlementContact> getEntitlements(String contId) {
        List<EntitlementContact> entCnts = [SELECT ContactId, Id, EntitlementId,Entitlement.Name,Entitlement.StartDate,Entitlement.Status,Entitlement.EndDate 
                FROM EntitlementContact 
                WHERE ContactId = :contId
                WITH SECURITY_ENFORCED];
        return entCnts;
    }
}