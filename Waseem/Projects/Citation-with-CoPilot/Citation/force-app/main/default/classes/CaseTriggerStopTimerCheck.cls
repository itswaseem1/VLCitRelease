public without sharing class CaseTriggerStopTimerCheck {

    public static final Id ATLAS_SUPPORT_RECORD_TYPE =
            Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();
    private static final String QMS_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_BDM_Query').getRecordTypeId();
    private static final String QMS_GAQ_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_General_Admin_Query').getRecordTypeId();
    private static final String QMS_SSAQ_RT_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales_Support_Address_Queries').getRecordTypeId();
    private static final String QMS_C_S =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Connect_Support').getRecordTypeId();
    private static final String QMS_C_A =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Contract_Accounts').getRecordTypeId();
    private static final String QMS_A =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Accounts').getRecordTypeId();
    private static final String QMS_CANCELLATION =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Cancellation').getRecordTypeId();
	private static final String QMS_S =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales').getRecordTypeId();
    private static final String QMS_M =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Marketing').getRecordTypeId();
    private static final String QMS_R = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Reactivations').getRecordTypeId();
    private static final String QMS_RQ = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Retention_Query').getRecordTypeId();
    private static final String QMS_TS = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Technical_Support').getRecordTypeId();
    private static final String QMS_CA = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Complaints_Appeal').getRecordTypeId();
    private static final String QMS_RQE = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Referral_Queries').getRecordTypeId();
    private static final String QMS_TPCC = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Third_Party_Customer_Complaint').getRecordTypeId();    
    private static final Set<Id> RT_FOR_CHECK = new Set<Id>{
            ATLAS_SUPPORT_RECORD_TYPE,
            QMS_RT_ID,
            QMS_GAQ_RT_ID,
            QMS_SSAQ_RT_ID,
            QMS_C_S,
            QMS_C_A,
            QMS_A,
            QMS_CANCELLATION,
            QMS_S,
            QMS_M,
            QMS_R,
            QMS_RQ,
            QMS_TS,
            QMS_CA,
            QMS_RQE,
            QMS_TPCC
                
    };

    public static void checkForCaseStatus(Map<Id, Case> oldMap, Map<Id, Case> newMap) {

        for (Id caseId : newMap.keySet()) {

            Case newCaseItem = newMap.get(caseId);
            Case oldCaseItem = oldMap.get(caseId);

            if (RT_FOR_CHECK.contains(newCaseItem.RecordTypeId) && newCaseItem.Status != oldCaseItem.Status) {
                newCaseItem.IsStopped = (newCaseItem.Status == 'Awaiting Information');
            }
        }
    }
}