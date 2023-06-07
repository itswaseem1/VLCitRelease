public with sharing class CaseTriggerBHoursHandler {

    private static final String UK_BH_NAME = 'UK Business Hours';

    private static final String ELT_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('ELT_Advice_Generic').getRecordTypeId();
    private static final String HS_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('HS_Advice_Generic').getRecordTypeId();
    private static final String ATLAS_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('S360_Atlas_Support').getRecordTypeId();
    private static final String QMS_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_BDM_Query').getRecordTypeId();
    private static final String QMS_C_S = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Connect_Support').getRecordTypeId();
    private static final String QMS_GAQ_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_General_Admin_Query').getRecordTypeId();
    private static final String QMS_SSAQ_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales_Support_Address_Queries').getRecordTypeId();
    private static final String HRCYJ_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('HR_CYJ').getRecordTypeId();
    private static final String CCO_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Citation_Client_Operations').getRecordTypeId();
    private static final String FLD_SPRT_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Field_Support').getRecordTypeId();
    private static final String CCA_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Citation_Contract_Admin').getRecordTypeId();
    private static final String QMS_C_A = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Contract_Accounts').getRecordTypeId();
    private static final String CCC_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Citation_Credit_Control').getRecordTypeId();
    private static final String QMS_CT_MS_C_ACC_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Citation_MS_Contract_Accounts').getRecordTypeId();
    private static final String QMS_A = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Accounts').getRecordTypeId();
    private static final String QMS_CANCELLATION = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Cancellation').getRecordTypeId();
    private static final String QMS_CV = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Verification').getRecordTypeId();
    private static final String QMS_CGG = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Compliance_General').getRecordTypeId();
    private static final String QMS_CFA = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Amendments').getRecordTypeId();
    private static final String QMS_CFR = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Requests').getRecordTypeId();
    private static final String QMS_DON = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Deed_of_Novation').getRecordTypeId();
    private static final String QMS_SSE = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Sales_Support_Existing_Customers_Contract_Changes').getRecordTypeId();
    private static final String QMS_CTC = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Customer_Complaints').getRecordTypeId();
    private static final String QMS_CS = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Compliance_Support').getRecordTypeId();
    private static final String CITATION_COMPLAINT = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Citation_Complaints').getRecordTypeId();
    private static final String QMS_S = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales').getRecordTypeId();
    private static final String QMS_M = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Marketing').getRecordTypeId();
	private static final String QMS_R = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Reactivations').getRecordTypeId();
    private static final String QMS_RQ = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Retention_Query').getRecordTypeId();
    private static final String QMS_TS = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Technical_Support').getRecordTypeId();
    private static final String QMS_CA = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Complaints_Appeal').getRecordTypeId();
    private static final String QMS_RQE = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Referral_Queries').getRecordTypeId();
    private static final String QMS_SUSPENSION = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Suspension').getRecordTypeId();
    private static final String QMS_ELS = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_eLearning_Support').getRecordTypeId();
    private static final String QMS_TSS = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Technical_Specialist_Support').getRecordTypeId();
    private static final String QMS_SA = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Suspension_Appeal').getRecordTypeId();
    private static final String QMS_TPCC = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Third_Party_Customer_Complaint').getRecordTypeId();
    private static final String QMS_GBR = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_General_Booking_Requests').getRecordTypeId();
    private static final String QMS_FSR = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Field_Staff_Requests').getRecordTypeId();

    
    private static final Map<Id, String> CASE_RT_IDS_BH_NAMES = new Map<Id, String>{
            ATLAS_RT_ID => Label.Business_hours_for_Atlas_support,
            ELT_RT_ID => UK_BH_NAME,
            HS_RT_ID => UK_BH_NAME,
            QMS_RT_ID => UK_BH_NAME,
            QMS_C_S => UK_BH_NAME,
            QMS_GAQ_RT_ID => UK_BH_NAME,
            HRCYJ_RT_ID => UK_BH_NAME,
            QMS_SSAQ_RT_ID => UK_BH_NAME,
            CCO_RT_ID => UK_BH_NAME,
            FLD_SPRT_RT_ID => UK_BH_NAME,
            CCA_RT_ID => UK_BH_NAME,
            QMS_C_A => UK_BH_NAME,
            CCC_RT_ID => UK_BH_NAME,
            QMS_CT_MS_C_ACC_ID => UK_BH_NAME,
            QMS_A => UK_BH_NAME,
            QMS_CANCELLATION => UK_BH_NAME,
            QMS_CV => UK_BH_NAME,
            QMS_CGG => UK_BH_NAME,
            QMS_CFA => UK_BH_NAME,
            QMS_CFR => UK_BH_NAME,
            QMS_DON => UK_BH_NAME,
            QMS_SSE => UK_BH_NAME,
            QMS_CTC => UK_BH_NAME,
            QMS_CS => UK_BH_NAME,
            CITATION_COMPLAINT => UK_BH_NAME,
            QMS_S => UK_BH_NAME,
            QMS_M => UK_BH_NAME,
            QMS_R => UK_BH_NAME,
            QMS_RQ => UK_BH_NAME,
            QMS_TS => UK_BH_NAME,
            QMS_CA => UK_BH_NAME,
            QMS_RQE => UK_BH_NAME,
            QMS_SUSPENSION => UK_BH_NAME,
            QMS_ELS => UK_BH_NAME,
            QMS_TSS => UK_BH_NAME,
            QMS_SA => UK_BH_NAME,
            QMS_TPCC => UK_BH_NAME,
            QMS_GBR => UK_BH_NAME,
            QMS_FSR => UK_BH_NAME
                
    };

    private static Map<Id, Id> rtIdBHIdMap {
        get {
            return (rtIdBHIdMap == null) ? (rtIdBHIdMap = getRTIdBHIdMap()) : rtIdBHIdMap;
        }
        set;
    }

    private static Map<Id, Id> getRTIdBHIdMap() {
        Map<Id, Id> result = new Map<Id, Id>();

        Map<String, Id> bhNameBHIdMap = getBHNameBHIdMap();


        for (Id recordTypeId : CASE_RT_IDS_BH_NAMES.keySet()) {
            result.put(recordTypeId, bhNameBHIdMap.get(CASE_RT_IDS_BH_NAMES.get(recordTypeId)));
        }

        return result;
    }

    private static Map<String, Id> getBHNameBHIdMap() {
        Map<String, Id> result = new Map<String, Id>();

        List<BusinessHours> bhItems = [
                SELECT Id, Name
                FROM BusinessHours
                WHERE Name IN :new Set<String>(CASE_RT_IDS_BH_NAMES.values())
                WITH SECURITY_ENFORCED
        ];

        for (BusinessHours bhItem : bhItems) {
            result.put(bhItem.Name, bhItem.Id);
        }

        return result;
    }

    public static void updateBHoursOnCases(Map<Id, Case> oldMap, List<Case> newCaseItems) {
        Boolean isUpdate = (oldMap != null);

        Case oldCaseItem;

        for (Case newCaseItem : newCaseItems) {
            oldCaseItem = oldMap?.get(newCaseItem.Id);

            if (!isUpdate || (isUpdate && newCaseItem.RecordTypeId != oldCaseItem.RecordTypeId)) {
                updateBHoursOnCase(oldCaseItem, newCaseItem);
            }
        }
    }

    private static void updateBHoursOnCase(Case oldCaseItem, Case newCaseItem) {
        if (newCaseItem.RecordTypeId == ELT_RT_ID || newCaseItem.RecordTypeId == HS_RT_ID) {
            if (newCaseItem.Origin == 'Phone' || newCaseItem.Origin == 'Email') {
                newCaseItem.BusinessHoursId = rtIdBHIdMap.get(newCaseItem.RecordTypeId);
            }
        } else {
            if (rtIdBHIdMap.containsKey(newCaseItem.RecordTypeId)) {
                newCaseItem.BusinessHoursId = rtIdBHIdMap.get(newCaseItem.RecordTypeId);
            }
        }
    }
}