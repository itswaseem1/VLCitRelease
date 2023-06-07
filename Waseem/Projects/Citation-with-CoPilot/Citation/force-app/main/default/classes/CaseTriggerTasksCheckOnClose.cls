public without sharing class CaseTriggerTasksCheckOnClose { 

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
    private static final String QMS_CT_MS_C_ACC_ID =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Citation_MS_Contract_Accounts').getRecordTypeId();
    private static final String QMS_CANCELLATION =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Cancellation').getRecordTypeId();
    private static final String QMS_CV =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Verification').getRecordTypeId();
    private static final String QMS_CGG =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Compliance_General').getRecordTypeId();
    private static final String QMS_CFA =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Amendments').getRecordTypeId();
    private static final String QMS_CFR =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Certificate_Requests').getRecordTypeId();
    private static final String QMS_CTC =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Customer_Complaints').getRecordTypeId();
    private static final String QMS_DON =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Deed_of_Novation').getRecordTypeId();
    private static final String QMS_SSECCC =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Sales_Support_Existing_Customers_Contract_Changes').getRecordTypeId();
     private static final String QMS_CS =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Compliance_Support').getRecordTypeId();
	private static final String QMS_M =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Marketing').getRecordTypeId();
    private static final String QMS_S =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Sales').getRecordTypeId();
    private static final String QMS_R =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Reactivations').getRecordTypeId();
     private static final String QMS_RQ =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Retention_Query').getRecordTypeId();
     private static final String QMS_TS =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Technical_Support').getRecordTypeId();
    private static final String QMS_RF =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Referral_Queries').getRecordTypeId();
    private static final String QMS_CA =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Complaints_Appeal').getRecordTypeId();
    private static final String QMS_SUSPENSION =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Suspension').getRecordTypeId();
    private static final String QMS_ELS =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_eLearning_Support').getRecordTypeId();
    private static final String QMS_TSS =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Technical_Specialist_Support').getRecordTypeId();
    private static final String QMS_SA =
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Suspension_Appeal').getRecordTypeId();
    private static final String QMS_TPCC = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Third_Party_Customer_Complaint').getRecordTypeId();
    private static final String QMS_GBR = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_General_Booking_Requests').getRecordTypeId();
    private static final String QMS_FSR = 
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Field_Staff_Requests').getRecordTypeId();
    
  private static final Set<Id> RT_FOR_CHECK_QMS = new Set<Id>{
            QMS_RT_ID,
            QMS_GAQ_RT_ID,
            QMS_SSAQ_RT_ID,
            QMS_C_S,
            QMS_C_A,
            QMS_CT_MS_C_ACC_ID,
            QMS_CANCELLATION,
            QMS_CV,
            QMS_CGG,
            QMS_CFA,
            QMS_CFR,
            QMS_CTC,
            QMS_DON,
            QMS_SSECCC,
            QMS_CS,
            QMS_M,
            QMS_S,
            QMS_R,
            QMS_RQ,
            QMS_TS,
            QMS_RF,
            QMS_CA,
            QMS_SUSPENSION,
            QMS_ELS,
            QMS_TSS,
            QMS_SA,
            QMS_TPCC,
            QMS_GBR,
            QMS_FSR
                
                
                
    };
      
    private static final Set<Id> RT_FOR_CHECK = new Set<Id>{
            ATLAS_SUPPORT_RECORD_TYPE
            
    };

    private static final Set<String> STATUSES_FOR_CHECK = new Set<String>{
            'Closed',
            'Resolved'
    };
    
    private static final Set<String> SUB_STATUSES_FOR_CHECK = new Set<String>{
            'Cancelled',
            'Duplicate Case',
            'Duplicate Ticket',
            'Duplicate'
    };



    private static final Set<String> ORIGINS_FOR_TASKS = new Set<String>{
            'Phone - Atlas Support',
            'QMS BDM - Phone',
            'QMS GAQ - Phone',
            'QMS Address Queries - Phone',
            'QMS Connect Support - Phone',
            'QMS Contract Accounts - Phone',
            'QMS Citation MS Contract - Accounts - Phone',
            'QMS Cancellation - Phone',
            'Certificate Verification - Phone',
            'Compliance General - Phone',
            'Certificate Amendments - Phone',
            'Certificate Requests - Phone',
            'Customer Complaints - Phone',
            'Deed of Novation - Phone',
			'Existing Customers Contract Changes - Phone',
            'Compliance Support - Phone',
            'Marketing - Phone',
            'Sales - Phone',
            'Retention Query - Phone',
            'Reactivations - Phone',
            'QMS Technical Support - Phone',
            'QMS Complaints Appeal - Phone',
            'Referral Queries - Phone',
            'QMS Suspension - Phone',
            'QMS eLearning Support - Phone',
            'QMS Suspension Appeal - Phone',
            'QMS Technical Specialist Support - Phone',
            'QMS Third Party Customer Complaint - Phone',
            'QMS General Booking Requests - Phone',
            'QMS Field Staff Requests - Phone'
    };

    private static final Set<String> ORIGINS_FOR_EMAILS = new Set<String>{
            'Email - Atlas Support',
            'Atlas Support Voice message',
            'User Snap',
            'QMS BDM - Email',
            'QMS GAQ - Email',
            'QMS Address Queries - Email',
            'QMS Connect Support - Email',
            'QMS Contract Accounts - Email',
            'QMS Citation MS Contract - Accounts - Email',
            'QMS Cancellation - Email',
            'Certificate Verification - Email',
            'Compliance General - Email',
            'Certificate Amendments - Email', 
            'Certificate Requests - Email',
            'Customer Complaints - Email',
			'Deed of Novation - Email',
			'Existing Customers Contract Changes - Email',
            'Compliance Support - Email',
            'Marketing - Email',
            'Sales - Email',
            'Retention Query - Email',
            'Reactivations - Email',
            'QMS Technical Support - Email',
            'QMS Complaints Appeal - Email',
            'Referral Queries - Email',
            'QMS Suspension - Email',
            'QMS eLearning Support - Email',
            'QMS Suspension Appeal - Email',
            'QMS Technical Specialist Support - Email',
            'QMS Third Party Customer Complaint - Email',
            'QMS General Booking Requests - Email',
            'QMS Field Staff Requests - Email'                
    };

    private static Set<Id> getCaseIdsWithTasks(Set<Id> caseIds) {
        Set<Id> result = new Set<Id>();

        List<AggregateResult> arItems = [
                SELECT WhatId caseId
                FROM Task
                WHERE Subject = 'Call' AND WhatId IN :caseIds
                WITH SECURITY_ENFORCED
                GROUP BY WhatId
        ];

        for (AggregateResult arItem : arItems) {
            result.add((Id) arItem.get('caseId'));
        }

        return result;
    }

    private static Set<Id> getCaseIdsWithEmails(Set<Id> caseIds) {
        Set<Id> result = new Set<Id>();

        List<AggregateResult> arItems = [
                SELECT ParentId caseId
                FROM EmailMessage
                WHERE Incoming = FALSE AND CreatedBy.name != 'Salesforce Admin' AND ParentId IN :caseIds
                WITH SECURITY_ENFORCED
                GROUP BY ParentId
        ];

        for (AggregateResult arItem : arItems) {
            result.add((Id) arItem.get('caseId'));
        }

        return result;
    }
    public static void checkClosedCaseItemsQMS(Map<Id, Case> newCaseMap) {
           Set<Id> caseIds = newCaseMap.keySet();
           Set<Id> caseIdsWithTasks = getCaseIdsWithTasks(caseIds);
           Set<Id> caseIdsWithEmails = getCaseIdsWithEmails(caseIds);
           
           for (Id caseId : caseIds) {
            Case caseItem = newCaseMap.get(caseId);

        
        if (STATUSES_FOR_CHECK.contains(caseItem.Status) && RT_FOR_CHECK_QMS.contains(caseItem.RecordTypeId) && !SUB_STATUSES_FOR_CHECK.contains(caseItem.Sub_Status__c))
           {
                if (ORIGINS_FOR_TASKS.contains(caseItem.Origin) && (!caseIdsWithTasks.contains(caseId)&&!caseIdsWithEmails.contains(caseId))) {
                    caseItem.addError(Label.Error_Message_For_Other_Cases);
                } else if (ORIGINS_FOR_EMAILS.contains(caseItem.Origin) && (!caseIdsWithTasks.contains(caseId)&&!caseIdsWithEmails.contains(caseId))){
                    caseItem.addError(Label.Error_Message_For_Other_Cases);
                }
            }

        }
        }
    public static void checkClosedCaseItems(Map<Id, Case> newCaseMap) {

        Set<Id> caseIds = newCaseMap.keySet();

        Set<Id> caseIdsWithTasks = getCaseIdsWithTasks(caseIds);
        Set<Id> caseIdsWithEmails = getCaseIdsWithEmails(caseIds);

        for (Id caseId : caseIds) {
            Case caseItem = newCaseMap.get(caseId);

        
    
        if (STATUSES_FOR_CHECK.contains(caseItem.Status) && RT_FOR_CHECK.contains(caseItem.RecordTypeId) && !SUB_STATUSES_FOR_CHECK.contains(caseItem.Sub_Status__c))
           {
                if (ORIGINS_FOR_TASKS.contains(caseItem.Origin) && !caseIdsWithTasks.contains(caseId)) {
                    caseItem.addError(Label.Error_Message_For_Phone_Cases);
                } else if (ORIGINS_FOR_EMAILS.contains(caseItem.Origin) && !caseIdsWithEmails.contains(caseId)) {
                    caseItem.addError(Label.Error_Message_For_Other_Cases);
                }
            }

        }
    }

}