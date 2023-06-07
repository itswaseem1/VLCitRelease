public with sharing class SplitCaseCtrl {

    private class SplitCaseException extends Exception {}

    @AuraEnabled(Cacheable = true)
    public static Map<String, Object> getInitParams(Id recordId) {
        return new Map<String, Object>{
                'hasEditAccess' => hasEditAccess(recordId),
                'caseId' => getEmailMessageItem(recordId).ParentId
        };
    }

    private static Boolean hasEditAccess(Id recordId) {
        return [
                SELECT
                        HasEditAccess,
                        RecordId
                FROM UserRecordAccess
                WHERE
                UserId = :UserInfo.getUserId() AND
                RecordId = :recordId
        ].HasEditAccess;
    }

    @AuraEnabled
    public static Id doSplit(Id recordId, Id existingCaseId, String optionValue) {
        Id result;

        try {

            switch on optionValue {
                when 'option1' {
                    result = doSplitOption12(recordId, true);
                }
                when 'option2' {
                    result = doSplitOption12(recordId, false);
                }
                when 'option3' {
                    result = doSplitOption34(recordId, existingCaseId, true);
                }
                when 'option4' {
                    result = doSplitOption34(recordId, existingCaseId, false);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    private static Id doSplitOption12(Id recordId, Boolean needToDelete) {
        if (!(Case.SObjectType.getDescribe().isCreateable() && EmailMessage.SObjectType.getDescribe().isCreateable())){
            System.debug('Error due to permissions. Create on case is '+Case.SObjectType.getDescribe().isCreateable()+'. Create on Email message is '+EmailMessage.SObjectType.getDescribe().isCreateable());
            return null;
        }
        EmailMessage emailMessageItem = getEmailMessageItem(recordId);
        Case caseItem = getCaseItem(emailMessageItem.ParentId);
               
        Case clonedCaseItem = getClonedCaseItem(caseItem, emailMessageItem);
		
      	insert clonedCaseItem;             
                   
        EmailMessage clonedEmailMessageItem = getClonedEmailMessageItem(emailMessageItem);
        clonedEmailMessageItem.RelatedToId = clonedCaseItem.Id;
        clonedEmailMessageItem.ParentId = clonedCaseItem.Id;
        clonedEmailMessageItem.ValidatedFromAddress = '';
		insert clonedEmailMessageItem;          
       
		if(!emailMessageItem.Incoming){
            List<Id> relatedContentDocumentIds = getRelatedContentDocumentIds(recordId);
        	insert getClonedContentDocumentLinks(clonedEmailMessageItem.Id, relatedContentDocumentIds);
        }            
        if(emailMessageItem.Incoming){
            List<Attachment> attachments = getRelatedAttachments(recordId);
            insert getClonedAttachments(clonedEmailMessageItem.Id, attachments);
        }	
        
        if (needToDelete) {
            delete emailMessageItem;
        }
        return clonedCaseItem.Id;
    }

    private static Id doSplitOption34(Id recordId, Id existingCaseId, Boolean needToDelete) {
        if(!EmailMessage.SObjectType.getDescribe().isCreateable()){
            System.debug('Error due to permission. Email message can not be created');
             return null;
        }
                   
        EmailMessage emailMessageItem = getEmailMessageItem(recordId);        

        EmailMessage clonedEmailMessageItem = getClonedEmailMessageItem(emailMessageItem);
        clonedEmailMessageItem.RelatedToId = existingCaseId;
        clonedEmailMessageItem.ParentId = existingCaseId;
        clonedEmailMessageItem.ValidatedFromAddress = '';

        if (EmailMessage.SObjectType.getDescribe().isCreateable()) {
            insert clonedEmailMessageItem;
        }
        if(!emailMessageItem.Incoming){
            List<Id> relatedContentDocumentIds = getRelatedContentDocumentIds(recordId);
            insert getClonedContentDocumentLinks(clonedEmailMessageItem.Id, relatedContentDocumentIds);
        }
        if(emailMessageItem.Incoming){
            List<Attachment> attachments = getRelatedAttachments(recordId);
            insert getClonedAttachments(clonedEmailMessageItem.Id, attachments);
        }

        if (needToDelete) {
            delete emailMessageItem;
        }

        return clonedEmailMessageItem.Id;
    }

    private static Case getCaseItem(Id recordId) {
        return [
                SELECT
                        ContactId,
                        AccountId,
                        SuppliedEmail,
                        ContactEmail,
                        RecordTypeId
                FROM
                        Case
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }

    private static Case getClonedCaseItem(Case originalCase, EmailMessage emailMessageItem) {
        Case result = originalCase.clone(false, true);
        result.Subject = emailMessageItem.Subject;
        result.Description = emailMessageItem.TextBody;
        result.ParentId = originalCase.Id;
        return result;
    }

    private static List<ContentDocumentLink> getClonedContentDocumentLinks(Id recordId, List<Id> relatedContentDocumentIds) {
        List<ContentDocumentLink> result = new List<ContentDocumentLink>();

        for (Id contentDocumentId : relatedContentDocumentIds) {
            result.add(new ContentDocumentLink(
                    LinkedEntityId = recordId,
                    ContentDocumentId = contentDocumentId
            ));
        }

        return result;
    }
    
    private static List<Attachment> getClonedAttachments(Id recordId, List<Attachment> attachments){
        List<Attachment> result = new List<Attachment>();

        for (Attachment a : attachments) {
            result.add(new Attachment(
                    ParentId = recordId,
                    body = a.body,
                	name = a.name,
                	description = a.description
            ));
        }

        return result;
    }

    private static List<Id> getRelatedContentDocumentIds(Id recordId) {
        List<Id> result = new List<Id>();

        List<ContentDocumentLink> cdlItems = [
                SELECT
                        ContentDocumentId
                FROM
                        ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                WITH SECURITY_ENFORCED
        ];

        for (ContentDocumentLink cdlItem : cdlItems) {
            result.add(cdlItem.ContentDocumentId);
        }

        return result;
    }
    
    private static List<Attachment> getRelatedAttachments(Id recordId){
        
        List<Attachment> attachItems = [
                SELECT
                        Id, Body, Name, description
                FROM
                        Attachment
                WHERE ParentId = :recordId
                WITH SECURITY_ENFORCED
        ];

        return attachItems;
    }

    private static EmailMessage getClonedEmailMessageItem(EmailMessage originalEmailMessageItem) {
        return originalEmailMessageItem.clone(false, true);
    }

    private static EmailMessage getEmailMessageItem(Id recordId) {
        return [
                SELECT
                        Id,
                        ParentId,
                        ActivityId,
                        CreatedById,
                        CreatedDate,
                        LastModifiedDate,
                        LastModifiedById,
                        SystemModstamp,
                        TextBody,
                        HtmlBody,
                        Headers,
                        Subject,
                        FromName,
                        FromAddress,
                        ValidatedFromAddress,
                        ToAddress,
                        CcAddress,
                        BccAddress,
                        Incoming,
                        HasAttachment,
                        Status,
                        MessageDate,
                        IsDeleted,
                        ReplyToEmailMessageId,
                        IsExternallyVisible,
                        MessageIdentifier,
                        ThreadIdentifier,
                        IsClientManaged,
                        RelatedToId,
                        IsTracked,
                        IsOpened,
                        FirstOpenedDate,
                        LastOpenedDate,
                        IsBounced,
                        EmailTemplateId
                FROM EmailMessage
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }
}