/**
 * @File Name          : SAEmailReminderBatchHelper.cls
 * @Description        : To send reminder email when service appointment status get dispatched.
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/06/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     26/7/2021      Initial Version
 **/
public with Sharing class SAEmailReminderBatchHelper {
    public static List<String> meetingTypeList = new List<String>();
    public static Map<String,String> emailTempBodyMap = new Map<String, String>();
    public static Map<Id,User> serAppAssResMap = new Map<Id, User>();
    public static List<Messaging.SingleEmailMessage> finalMailsList = new List<Messaging.SingleEmailMessage>();
    public static List<EnhancedLetterhead> letterhead = new List<EnhancedLetterhead>();
    public static List<OrgWideEmailAddress> emailDisplayName = new List<OrgWideEmailAddress>();
    
    public static void setupReminderEmailData(List<ServiceAppointment> serAppList){
        for(ServiceAppointment serApp :serAppList ){
                    if((serApp.Status == 'Dispatched')){
                        meetingTypeList.add(serApp.Meeting_Type__c);
                    
                    }
            
		}
        if(!serAppList.isEmpty()){
            for(AssignedResource arRec : [Select Id, ServiceAppointmentId, ServiceResource.RelatedRecord.Name, 
                                          ServiceResource.RelatedRecord.Title, ServiceResource.RelatedRecord.Phone, 
                                          ServiceResource.RelatedRecord.MobilePhone from AssignedResource where ServiceAppointmentId 
                                          IN : serAppList WITH SECURITY_ENFORCED ]){
                serAppAssResMap.put(arRec.ServiceAppointmentId,arRec.ServiceResource.RelatedRecord);
                                           
                                    
            }
             finalMailsList = setupDataToSendEmail(meetingTypeList, serAppList);
             if(!finalMailsList.isEmpty()){
                sendEmail(finalMailsList);
             }
        }
    }
    public static List<Messaging.SingleEmailMessage> setupDataToSendEmail(List<String> meetingTypeList, List<ServiceAppointment>serAppList){
		
		letterhead = [select id, name, LetterheadFooter,LetterheadHeader from EnhancedLetterhead 
										where Name = 'Citation service appointment dispatch letterhead' WITH SECURITY_ENFORCED limit 1 ];
        emailDisplayName =  [select id,Address, DisplayName from OrgWideEmailAddress where address = 'reply-email@citation.co.uk' Limit 1];
        /*for(EmailTemplate empTemp : [Select id, name, HtmlValue,Markup, body from EmailTemplate where name IN :meetingTypeList WITH SECURITY_ENFORCED] ){
            emailTempBodyMap.put(empTemp.name, empTemp.Markup);
            system.debug('in empTemp'+empTemp); 
        }*/
		
        for(ServiceAppointment serApp : serAppList){
            if(serApp.Meeting_Type__c != null && System.Label.SA_Meeting_Type.contains(serApp.Meeting_Type__c) && (serApp.Visit_Type__c != '')){				   
				Id contactEmail = serApp.ContactId;
				//String body = emailTempBodyMap.get(serApp.Meeting_Type__c) != null ? emailTempBodyMap.get(serApp.Meeting_Type__c): ' ' ;
				
				if(serApp.status == 'Dispatched'){
					finalMailsList = sendF2FReminderEmail(contactEmail, serApp );
                } 
				   
			}
        }
		 return finalMailsList;
     }
	
    public static List<Messaging.SingleEmailMessage> sendF2FReminderEmail(Id rContactEmail, ServiceAppointment serAppRec){
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        User assRes = new user();
        DateTime schDate =serAppRec.SchedStartTime;
		String schDateFormated = schDate.format('MM/dd/yyyy HH:mm:ss','Europe/London');
		String contactName = serAppRec.Contact.FirstName != null ? serAppRec.Contact.FirstName+', ' : '' ;
        String customerFriMeeName = serAppRec.Customer_Friendly_Meeting_Name__c != null ? serAppRec.Customer_Friendly_Meeting_Name__c+' ': '';
        String street = serAppRec.Street != null ? serAppRec.Street+', ' : '';
        String city = serAppRec.City != null ? serAppRec.City+', ': '';
        String state = serAppRec.State != null ? serAppRec.State+', ': '';
        String postalCode = serAppRec.PostalCode != null ? serAppRec.PostalCode+'. ': '';
        String country = serAppRec.Country != null ? serAppRec.Country+'. ': '';
        
        if(serAppAssResMap.get(serAppRec.Id) != null){
            assRes= serAppAssResMap.get(serAppRec.Id);
            system.debug('user details'+assRes);
        }
        String name = assRes.Name != null ? assRes.Name : UserInfo.getName();
        String title = assRes.Title != null ? assRes.Title : '';
        String phone = assRes.Phone != null ? assRes.Phone : '';
        String mobilePhone = assRes.MobilePhone != null ? assRes.MobilePhone : '';
        
		mail.setTargetObjectId(rContactEmail);
		mail.setReplyTo('hsfieldsupport@citation.co.uk');
		//mail.setSenderDisplayName('Citation <reply-email@citation.co.uk>');
        mail.setOrgWideEmailAddressId(emailDisplayName[0].Id);
		mail.setSubject('Reminder Citation Visit: ' + customerFriMeeName +' on '+schDateFormated);
		mail.setBccSender(false);
		mail.setWhatId(serAppRec.id);
		mail.setSaveAsActivity(true);
		mail.setUseSignature(false);
       
        if(serAppRec.Visit_Type__c == 'Face-To-Face'){
        mail.setHtmlBody('<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'Dear '+contactName +'<br/><br/> Just a reminder that your ' +customerFriMeeName +' is booked for '+
        schDateFormated+' with '+name +' and will take place at: '+Street +City +State +PostalCode +'<br/>'
                        + 'Should you have any queries please do not hesitate to contact me.<br/>' +'<br/>Best Regards, <br/>'+Name + '<br/>' + Title + '<br/>' +Phone
                        +'<br/>'+MobilePhone+'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+'<br/><br/>'+letterhead[0].LetterheadFooter+'</div>');	
            
        }else if(serAppRec.Visit_Type__c == 'virtual'){
            mail.setHtmlBody('<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'Dear '+contactName +'<br/><br/> Just a reminder that your ' +customerFriMeeName +' is booked for '+
        	schDateFormated+' with '+name +' and will take place "via video link".<br/>' 
                        + 'Should you have any queries please do not hesitate to contact me.<br/>' +'<br/>Best Regards, <br/>'+Name + '<br/>' + Title + '<br/>' +Phone
                        +'<br/>'+MobilePhone +'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+'<br/><br/>'+letterhead[0].LetterheadFooter+'</div>');	
        }
        
        finalMailsList.add(mail);
        return finalMailsList;
        
    }
    public static void sendEmail(List<Messaging.SingleEmailMessage> finalEmailList){
        try{
			Messaging.sendEmail(finalEmailList);
            finalEmailList.clear();
        }Catch(Exception e){
            system.debug('Send Email Exception'+ e);
        }
        
    }

}