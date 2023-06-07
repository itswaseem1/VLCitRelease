/**
 * @File Name          : ServiceAppointmentSentEmailQmsHelper.cls
 * @Description        :
 * @Author             : Mukul -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 21/04/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     26/7/2021      Initial Version
 **/
public with sharing class ServiceAppointmentSentEmailQmsHelper {

      public static String sAstatus='Confirmed';
      public static List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
      public static List<Id> shadowSAIds = new List<Id>();
      public static List<OrgWideEmailAddress> emailDisplayName;
    
    
      /*public static void sendEmailForQMSSA(List<ServiceAppointment> saList,Map<id,ServiceAppointment> sAMap){
       
       emailDisplayName =  [select id,Address, DisplayName from OrgWideEmailAddress where address = 'reply-email@citation.co.uk' Limit 1];
       for(ServiceAppointment sa : [select status,SchedStartTime,SchedEndTime,Business__c,AppointmentNumber,
                                    contact.email From ServiceAppointment Where id IN:saList
                                   WITH SECURITY_ENFORCED])
       {
           if(sa.status==sAstatus && (sa.SchedStartTime!=sAMap.get(sa.id).SchedStartTime
              || sa.SchedEndTime!=sAMap.get(sa.id).SchedEndTime || sAMap.get(sa.id).status=='Scheduled') 
              && sa.Business__c=='QMS' && sa.contact.Email!=null)
           {
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               mail.setTargetObjectId(sa.ContactId);
               mail.setUseSignature(false);
               mail.setSubject('Appointment Has Been Scheduled');
               mail.setPlainTextBody('Your Appointment: ' + sa.AppointmentNumber +' has been Scheduled.');
               mail.setOrgWideEmailAddressId(emailDisplayName[0].id);
               mail.setSaveAsActivity(true);
               mail.setWhatId(sa.id);
               emailList.add(mail);
           }
       }
        try{
       if(emailList.size()>0)
       {
           Messaging.sendEmail(emailList);  
       }
          }
          catch(Exception e)
          {
              if(e.getMessage().contains('EMAIL_ADDRESS_BOUNCED'))
              {
                  saList[0].addError(System.Label.InvalidEmail);
              }
             
          }
      checkShadowAppointment(saList);
       
   }*/

    public static void checkShadowAppointment(List<ServiceAppointment> sAList)
    {
        
        Map<String,ServiceAppointment> shadowServiceAppointmentMap = new Map<String,ServiceAppointment>();
        for(ServiceAppointment sa : sAList)
        {
            if(sa.Shadow__c==true && sa.Status=='Scheduled')
            {
                shadowSAIds.add(sa.id);
                shadowServiceAppointmentMap.put(sa.id,sa);
                system.debug(sa.id);
            }
        }
        if(shadowSAIds.size()>0)
        {
        List<FSL__Time_Dependency__c> dependantSAs=   [select FSL__Service_Appointment_1__c,
                                                       FSL__Service_Appointment_2__c
                                                       from FSL__Time_Dependency__c
                                                       Where FSL__Service_Appointment_2__c IN :shadowSAIds OR
                                                       FSL__Service_Appointment_1__c IN:shadowSAIds
                                                       WITH SECURITY_ENFORCED
                                                       ];
        if(dependantSAs.size()==0)
        {
            sAList[0].addError(system.Label.Dependent_SA_Error);
        }
        
      } 
    }
}