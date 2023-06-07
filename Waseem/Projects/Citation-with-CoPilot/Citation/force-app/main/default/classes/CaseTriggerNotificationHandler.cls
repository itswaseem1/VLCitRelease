public with sharing class CaseTriggerNotificationHandler {

    private static final String STATUS_NAME = 'New Info Added';
    private static final String RECEPTION_STATUS_NAME = 'New Info Available';
    private static final String CUSTOM_NOTIFICATION_DEV_NAME = 'Custom_Notification';

    private static Id notificationTypeId {
        get {
            return (notificationTypeId == null) ? (notificationTypeId = getNotificationTypeId()) : notificationTypeId;
        }
        set;
    }

    public static void sendMessages(Map<Id, Case> caseMapOld, Map<Id, Case> caseMapNew) {

        Case oldCaseItem;
        Case newCaseItem;

        for (Id caseId : caseMapOld.keySet()) {

            oldCaseItem = caseMapOld.get(caseId);
            newCaseItem = caseMapNew.get(caseId);

            if (((newCaseItem.Status == STATUS_NAME && oldCaseItem.Sub_Status__c != newCaseItem.Sub_Status__c) || 
                 ((newCaseItem.RecordTypeName__c).equalsIgnoreCase('Reception General') && newCaseItem.Status == RECEPTION_STATUS_NAME)) &&
                    newCaseItem.OwnerId != UserInfo.getUserId()) {
                sendNotification(newCaseItem);
            }
        }
    }

    private static Id getNotificationTypeId() {
        return [
                SELECT Id
                FROM CustomNotificationType
                WHERE DeveloperName = :CUSTOM_NOTIFICATION_DEV_NAME
        ]?.Id;
    }

    private static void sendNotification(Case caseItem) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        notification.setTitle(Label.CaseNotifications_Title);
        if((caseItem.RecordTypeName__c).equalsIgnoreCase('Reception General')){
            notification.setBody(
                String.format(
                        Label.Case_Notification_for_Reception_Cases,
                        new List<String>{
                                caseItem.CaseNumber,
                                caseItem.Status
                        }
                )
        	);
        }else{
            notification.setBody(
                String.format(
                        Label.CaseNotifications_Body,
                        new List<String>{
                                caseItem.CaseNumber,
                                caseItem.Status,
                                caseItem.Sub_Status__c
                        }
                )
        	);
        }
        

        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(caseItem.Id);

        try {
            notification.send(
                    new Set<String>{
                            caseItem.OwnerId
                    }
            );
        } catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}