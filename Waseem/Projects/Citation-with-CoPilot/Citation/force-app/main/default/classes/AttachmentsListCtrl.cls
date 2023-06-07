public with sharing class AttachmentsListCtrl {

    @AuraEnabled
    public static Map<String, Object> getInitialParams(Id caseId) {
        return new Map<String, Object>{
                'availableOptions' => getAvailableOptions(caseId)
        };
    }

    private static List<Map<String, Object>> getAvailableOptions(Id caseId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        List<Id> linkedEntityIds = new List<Id>{
                caseId
        };
        linkedEntityIds.addAll(getEmailMessageIds(caseId));

        List<ContentVersion> contentVersionItems = [
                SELECT
                        Id,
                        ContentDocument.Title
                FROM
                        ContentVersion
                WHERE
                ContentDocumentId IN :getContentDocumentIds(linkedEntityIds) AND
                IsLatest = TRUE
                WITH SECURITY_ENFORCED
        ];

        for (ContentVersion contentVersionItem : contentVersionItems) {
            result.add(
                    new Map<String, Object>{
                            'value' => contentVersionItem.Id,
                            'label' => contentVersionItem.ContentDocument.Title
                    }
            );
        }

        return result;
    }

    private static List<Id> getEmailMessageIds(Id caseId) {
        return new List<Id>(new Map<Id, EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :caseId]).keySet());
    }

    private static List<Id> getContentDocumentIds(List<Id> recordIds) {
        List<Id> result = new List<Id>();

        List<ContentDocumentLink> cdLinkItems = [
                SELECT
                        ContentDocumentId
                FROM
                        ContentDocumentLink
                WHERE
                        LinkedEntityId IN :recordIds
                WITH SECURITY_ENFORCED
        ];

        for (ContentDocumentLink cdLinkItem : cdLinkItems) {
            result.add(cdLinkItem.ContentDocumentId);
        }

        return result;
    }
}