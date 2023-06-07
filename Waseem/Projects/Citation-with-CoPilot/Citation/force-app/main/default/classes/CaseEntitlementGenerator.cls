public without sharing class CaseEntitlementGenerator {

    public static final String DEFAULT_ENTITLEMENTS_ACCOUNT_NAME = 'Entitlement Default Account';

    public static final Id DEFAULT_ENTITLEMENTS_ACCOUNT_RECORD_TYPE =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    private static final String ATLAS_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('S360_Atlas_Support').getRecordTypeId();
    private static final String QMS_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_BDM_Query').getRecordTypeId();
    private static final String QMS_GAQ_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_General_Admin_Query').getRecordTypeId();
    private static final String QMS_SSAQ_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales_Support_Address_Queries').getRecordTypeId();
    private static final String QMS_C_S =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Connect_Support').getRecordTypeId();
    private static final String FLD_SUP_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Field_Support').getRecordTypeId();
    private static final String QMS_C_A =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Contract_Accounts').getRecordTypeId();
    private static final String QMS_CT_MS_C_ACC_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Citation_MS_Contract_Accounts').getRecordTypeId();
    private static final String QMS_A =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Accounts').getRecordTypeId();
    private static final String QMS_CANCELLATION =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Cancellation').getRecordTypeId();
    private static final String QMS_CFA =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Amendments').getRecordTypeId();
    private static final String QMS_CFR =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Requests').getRecordTypeId();
    private static final String QMS_CTC =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Customer_Complaints').getRecordTypeId();
    private static final String QMS_CS =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Compliance_Support').getRecordTypeId();
    private static final String QMS_S =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales').getRecordTypeId();
    private static final String QMS_M =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Marketing').getRecordTypeId();
    private static final String QMS_R = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Reactivations').getRecordTypeId();
    private static final String QMS_RQ = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Retention_Query').getRecordTypeId();
    private static final String QMS_TPCC = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Third_Party_Customer_Complaint').getRecordTypeId();

    private static final Map<String, Id> ENTITLEMENT_NAME_RT_ID = new Map<String, Id>{
            'Default Atlas Support Entitlement' => ATLAS_RT_ID,
            'Default QMS Query Entitlement' => QMS_RT_ID,
            'Default QMS General Admin Query Entitlement' => QMS_GAQ_RT_ID,
            'Default QMS Sales Support Address Query Entitlement' => QMS_SSAQ_RT_ID,
            'Default QMS Connect Support' => QMS_C_S,
            'Default Field Support' => FLD_SUP_ID,
            'Default QMS Contract - Accounts' => QMS_C_A,
            'Default QMS Citation MS Contract - Accounts' => QMS_CT_MS_C_ACC_ID,
            'Default QMS Accounts' => QMS_A,
            'Default QMS Cancellation' => QMS_CANCELLATION,
            'Default Certificate Amendments' => QMS_CFA,
            'Default Certificate Requests' => QMS_CFR,
            'Default Customer Complaints' => QMS_CTC,
            'Default Compliance Support' => QMS_CS,
            'Default QMS Sales' => QMS_S,
            'Default QMS Marketing' => QMS_M,
            'Default QMS Reactivations' => QMS_R,
            'Default QMS Retention Query' => QMS_RQ,
            'Default QMS Third Party Customer Complaint Query' => QMS_TPCC


                
                
                
                
    };

    private static final Map<String, String> ENTITLEMENT_NAME_SLA_NAME = new Map<String, String>{
            'Default Atlas Support Entitlement' => 'Atlas support process',
            'Default QMS Query Entitlement' => 'QMS Query process',
            'Default QMS General Admin Query Entitlement' => 'QMS General Admin Query process',
            'Default QMS Sales Support Address Query Entitlement' => 'QMS Sales Support - Address Query process',
            'Default QMS Connect Support' => 'QMS Connect Support',
            'Default Field Support' => 'Field Support Entitlement Process',
            'Default QMS Contract - Accounts' => 'QMS Contract - Accounts',
            'Default QMS Citation MS Contract - Accounts' => 'QMS Citation MS Contract - Accounts Entitlement Process',
            'Default QMS Accounts' => 'QMS Accounts',
            'Default QMS Cancellation' => 'QMS Cancellation',
            'Default Certificate Amendments' => 'Certificate Amendments Entitlement Process',
            'Default Certificate Requests' => 'Certificate Requests Entitlement Process',
            'Default Customer Complaints' => 'Customer Complaints Entitlement Process', 
            'Default Compliance Support' => 'Compliance Support',
            'Default QMS Sales' => 'QMS Sales Entitlement Process',
            'Default QMS Marketing' => 'QMS Marketing Entitlement Process',
            'Default QMS Reactivations' => 'QMS Reactivations Entitlement Process',
            'Default QMS Retention Query' => 'QMS Retention Query Entitlement Process',
            'Default QMS Third Party Customer Complaint Query'=>'QMS Third Party Customer Complaint Entitlement Process'
   
    };

    private static Id entitlementAccountId {
        get {
            return (entitlementAccountId == null) ?
                    (entitlementAccountId = getEntitlementAccountId()) :
                    entitlementAccountId;
        }
        set;
    }

    private static Map<Id, Id> recordTypeIdEntitlementIdMap {
        get {
            return (recordTypeIdEntitlementIdMap == null) ?
                    (recordTypeIdEntitlementIdMap = getRecordTypeIdEntitlementIdMap()) :
                    recordTypeIdEntitlementIdMap;
        }
        set;
    }

    private static Id getEntitlementAccountId() {
        Id result = [
                SELECT Id
                FROM Account
                WHERE Name = :DEFAULT_ENTITLEMENTS_ACCOUNT_NAME
                WITH SECURITY_ENFORCED
                LIMIT 1
        ]?.Id;
        return (result != null) ? result : createAndGetEntitlementAccountId();
    }

    private static Id createAndGetEntitlementAccountId() {
        Account accountForInsert = new Account(
                Name = DEFAULT_ENTITLEMENTS_ACCOUNT_NAME,
                RecordTypeId = DEFAULT_ENTITLEMENTS_ACCOUNT_RECORD_TYPE
        );

        if (Account.SObjectType.getDescribe().isCreateable()) {
            insert accountForInsert;
        }

        return accountForInsert.Id;
    }

    private static Map<Id, Id> getRecordTypeIdEntitlementIdMap() {
        Map<Id, Id> result = new Map<Id, Id>();

        Map<String, Id> entitlementItemsMap = getEntitlementItemsMap();

        for (String entitlementName : ENTITLEMENT_NAME_RT_ID.keySet()) {

            Id entitlementId = entitlementItemsMap.get(entitlementName);

            result.put(
                    ENTITLEMENT_NAME_RT_ID.get(entitlementName),
                    (entitlementId != null) ? entitlementId : createAndGetNewEntitlementId(entitlementName)
            );
        }

        return result;
    }

    private static Id createAndGetNewEntitlementId(String entitlementName) {
        Id result;

        Map<String, Id> slaProcessItemsMap = getSLAProcessItemsMap();

        String slaProcessName = ENTITLEMENT_NAME_SLA_NAME.get(entitlementName);

        if (slaProcessItemsMap.containsKey(slaProcessName)) {
            Entitlement entitlementItem = new Entitlement(
                    Name = entitlementName,
                    AccountId = entitlementAccountId,
                    SlaProcessId = slaProcessItemsMap.get(slaProcessName)
            );

            if (Entitlement.SObjectType.getDescribe().isCreateable()) {
                insert entitlementItem;
            }

            result = entitlementItem.Id;
        }

        return result;
    }

    private static Map<String, Id> getSLAProcessItemsMap() {
        Map<String, Id> result = new Map<String, Id>();

        List<SlaProcess> slaProcessItems = [
                SELECT Id, Name
                FROM SlaProcess
                WHERE Name IN :ENTITLEMENT_NAME_SLA_NAME.values()
                WITH SECURITY_ENFORCED
        ];

        for (SlaProcess slaProcessItem : slaProcessItems) {
            result.put(
                    slaProcessItem.Name,
                    slaProcessItem.Id
            );
        }

        return result;
    }

    private static Map<String, Id> getEntitlementItemsMap() {
        Map<String, Id> result = new Map<String, Id>();

        List<Entitlement> entitlementItems = [
                SELECT
                        Id, Name
                FROM
                        Entitlement
                WHERE
                        Name IN :ENTITLEMENT_NAME_RT_ID.keySet()
                WITH SECURITY_ENFORCED
        ];

        for (Entitlement entitlementItem : entitlementItems) {
            result.put(entitlementItem.Name, entitlementItem.Id);
        }

        return result;
    }

    private static Id getEntitlementId(Id caseRecordTypeId) {
        return recordTypeIdEntitlementIdMap.get(caseRecordTypeId);
    }

    public static void updateEntitlementId(List<Case> caseItems) {
        for (Case caseItem : caseItems) {
            if (caseItem.EntitlementId == null) {
                caseItem.EntitlementId = getEntitlementId(caseItem.RecordTypeId);
            }
        }
    }
}