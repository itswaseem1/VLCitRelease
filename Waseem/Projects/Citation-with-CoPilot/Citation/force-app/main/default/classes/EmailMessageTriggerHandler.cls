public with sharing class EmailMessageTriggerHandler {

    @TestVisible
    private static final String CASE_STATUS_FOR_CHECK = 'Awaiting Information';

    @TestVisible
    private static final String CASE_SUB_STATUS_FOR_CHECK = 'Jira Ticket';

    @TestVisible
    private static final String CASE_STATUS_TO_CHANGE = 'New Info Added';

    @TestVisible
    private static final String CASE_SUB_STATUS_TO_CHANGE = 'New incoming email';

    @TestVisible
    private static final List<Id> RT_TO_CHECK = new List<Id>{
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('S360_Atlas_Support').getRecordTypeId(),
            Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Connect_Support').getRecordTypeId()
    };

    public static void changeCaseStatus(List<EmailMessage> emailItems) {
        List<Id> caseIds = new List<Id>();

        for (EmailMessage emailItem : emailItems) {
            if(emailItem.RelatedToId != null ){
                if (emailItem.RelatedToId.getSobjectType() == Case.SObjectType && emailItem.Incoming) {
                    caseIds.add(emailItem.ParentId);
                }
            }
        }

        if (!caseIds.isEmpty()) {
            updateCaseStatus(caseIds);
        }
    }

    private static void updateCaseStatus(List<Id> caseIds) {

        List<Case> casesForUpdate = getCaseItemsByIds(caseIds);

        for (Case caseItem : casesForUpdate) {
            caseItem.Status = CASE_STATUS_TO_CHANGE;
            caseItem.Sub_Status__c = CASE_SUB_STATUS_TO_CHANGE;
        }
        if (Case.SObjectType.getDescribe().isUpdateable()) {
            update casesForUpdate;
        }
    }

    private static List<Case> getCaseItemsByIds(List<Id> caseIds) {
        return [
                SELECT Id
                FROM Case
                WHERE
                Id IN :caseIds AND
                Status = :CASE_STATUS_FOR_CHECK AND
                Sub_Status__c = :CASE_SUB_STATUS_FOR_CHECK AND
                RecordTypeId IN :RT_TO_CHECK
                WITH SECURITY_ENFORCED
        ];
    }

}