public with sharing class CitationServicesOnHoldemailHelper {
    @InvocableMethod(label='OnHold Send email' description='This method sends the emails for OnHold')
    public static void onHoldsendEmail(List<ID> account) {

  //New instance of a single email message
          Messaging.SingleEmailMessage mail;
          List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Id tempId = [select id from EmailTemplate where DeveloperName='CitationServicesOnHold'].id;
        Id queueId = [select id from Group where DeveloperName='On_Hold'].id;
        //List<RecordType> caseRecTypeId = [Select id from RecordType where sObjectType = 'Case' and DeveloperName IN ('S360_Atlas_Support','ELT_Advice_Generic','HS_Advice_Generic','Citation_Client_Operations','HR_CYJ','Citation_Contract_Admin','Citation_Common_Request','Reception_General') ];
        List<RecordType> caseRecTypeId;
        if(
            RecordType.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.RecordType.fields.Id.isAccessible() 
        ) {
            caseRecTypeId = [Select Id from RecordType where sObjectType = 'Case' and DeveloperName IN ('S360_Atlas_Support','ELT_Advice_Generic','HS_Advice_Generic','Citation_Client_Operations','HR_CYJ','Citation_Contract_Admin','Field_Support','Reception_General') ];
        }
         
        List<Case> listPreOwnerId = new List<Case>();
        List<Case> cslist = new List<Case>();
                
              if(
                Case.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Case.fields.Id.isAccessible() &&
                Schema.SObjectType.Case.fields.RecordTypeId.isAccessible()&&
                Schema.SObjectType.Case.fields.ContactId.isAccessible()&&
                Schema.SObjectType.Case.fields.PreviousOwnerId__c.isAccessible()&&
                Schema.SObjectType.Case.fields.OwnerId.isAccessible()&&
                Schema.SObjectType.Case.fields.Status.isAccessible()
             ) {
           		 cslist = [SELECT Id,RecordTypeId,ContactId,PreviousOwnerId__c,OwnerId,Status,Contact.email from Case where AccountId in :account and RecordTypeId in :caseRecTypeId and Status in ('In Progress','Awaiting Information','New Info Added','New')];
              }
            
                   For(Case cs: cslist){
                                              
                     cs.PreviousOwnerId__c=cs.OwnerId;
                          
                      if( cs.Status== 'In Progress'|| cs.Status=='Awaiting Information' || cs.Status=='New Info Added')
                      {
                        cs.OwnerId = queueId;
                      }
                      
                       if(cs.ContactId!=null && cs.Contact.email!=null && cs.Status=='New')
                       {
                          cs.OwnerId = queueId;
                          mail =new Messaging.SingleEmailMessage();
                          // Who you are sending the email to 
                          mail.setTargetObjectId(cs.ContactId);
                        
                           mail.setTemplateId(tempId);
                           mail.setWhatId(cs.Id);
                           mail.setBccSender(false);
                           mail.setUseSignature(false);
                           mail.setReplyTo('reply-email@citation.co.uk');
                           mail.setSenderDisplayName('Citation Support');
                           mail.setSaveAsActivity(false);  
                           allmsg.add(mail);
                       }
                 listPreOwnerId.add(cs);
             }
              
          Messaging.sendEmail(allmsg,false);
        
        try{
            if (listPreOwnerId.size()>0 && Case.sObjectType.getDescribe().isUpdateable())
            {
            update listPreOwnerId;
            }
            
        }catch(Exception error){
            system.debug(error.getMessage());
        }
    }  

}