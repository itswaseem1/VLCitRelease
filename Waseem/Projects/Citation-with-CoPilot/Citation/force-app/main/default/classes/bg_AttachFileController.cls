/*******************************************************************
 * Controller for the Attach File VisualForce page.
 * attaches files to the opportunity 
 *
 * This is an extension controller for the Opportunity standard 
 * controller
 *
 * Author: James Garford(BrightGen.com)
 * Created: 05-01-2015
 * Changes:
*******************************************************************/

public with sharing class bg_AttachFileController {
  private id objectId {get;set;}
  private Opportunity theOpportunity {get;set;}
  public blob documentBody {get;set;}
  public String documentName {get;set;}

  public static final string ATTACHMENT_ERROR_CANNOT_DELETE_ATTACHMENTS = 'You are are not permitted to delete Attachment records.';
  public static final string ATTACHMENT_ERROR_FILE_UPLOAD = 'Error uploading file';
  public static final string ATTACHMENT_ERROR_SELECT_DOCUMENT = 'Please select a Document Type';
   
  // other strings
  public static final string PICKLIST_SEPARATOR = ';';  
  public static final string MAPPING_FIELD_SEPARATOR = '=';
  public static final string UPLOADED_SUFFIX = '_Uploaded__c';
  public static final string SITE_ROOT = '/';
  public static final string MAPPING_SEPARATOR = ',';
    
  public bg_AttachFileController(ApexPages.StandardController standardController) { 
    objectId = standardController.getId();
    theOpportunity=(Opportunity) standardController.getRecord();   
  }

  public bg_AttachFileController() {   
  }
 
  public PageReference upload() {
    String fieldName;
    
    if (theOpportunity.Key_Document_Type__c != null) { 
      try {
        fieldName = theOpportunity.Key_Document_Type__c.replace(' ','_'); 
        fieldName += UPLOADED_SUFFIX;     
        Attachment theAttachment = new Attachment();
        theAttachment.Body = documentBody; 
        theAttachment.ParentId = objectId;
        theAttachment.Name = documentName;   
        insert theAttachment;
        try {          
          theOpportunity.put(fieldName, true);
          upsert theOpportunity;
        } catch (SobjectException soEx) {
          theOpportunity.put(fieldName, false);
          throw soEx;
        }
           
      } catch (DMLException e) {
        theOpportunity.put(fieldName, false);

        Integer numberOfMessages = e.getNumDml();    
        
        if (numberOfMessages > 0) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
        } else {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ATTACHMENT_ERROR_FILE_UPLOAD));
        }
        return null;
      }
    } else {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ATTACHMENT_ERROR_SELECT_DOCUMENT));
      return null;
    }
    return new PageReference(SITE_ROOT + objectId);
  }
  
  public PageReference cancel() {
    return new PageReference(SITE_ROOT + objectId);
  }
   
}