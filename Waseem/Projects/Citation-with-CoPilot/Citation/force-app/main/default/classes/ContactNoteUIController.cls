public with sharing class ContactNoteUIController {
    @AuraEnabled   
    public static List <ContentDocumentLink> fetchContactNotes( String caseIds )  {  
        Set<Id> contactIds= new Set<Id>();
        List<case> caseList =new List<case>();
        if (Schema.sObjectType.Case.fields.ContactId.isAccessible()){
            caseList= [SELECT ContactId FROM Case WHERE Id=:caseIds WITH SECURITY_ENFORCED];
        }
        for(case c:caseList){
            contactIds.add(c.ContactId); 
            
        }
        List<ContentDocumentLink> conLinks =new List<ContentDocumentLink>();
        if (Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible() &&
            Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){
                
                conLinks=[select Id, LinkedEntityId,ContentDocumentId, ContentDocument.LatestPublishedVersion.Title,
                          ContentDocument.LatestPublishedVersion.CreatedBy.Name, 
                          ContentDocument.LatestPublishedVersion.CreatedDate from ContentDocumentLink 
                          where LinkedEntityId IN :contactIds WITH SECURITY_ENFORCED  order by ContentDocument.LatestPublishedVersion.CreatedDate desc];
            }
        
        
        return conLinks;  
    } 
    
}