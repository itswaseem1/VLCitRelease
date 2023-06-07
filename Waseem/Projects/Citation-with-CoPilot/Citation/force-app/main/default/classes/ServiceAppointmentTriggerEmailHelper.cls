/**
 * @File Name          : ServiceAppointmentTriggerEmailHelper.cls
 * @Description        : To send email when service appointment status get Confirmed/Canceled.
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/11/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     26/7/2021      Initial Version
 **/
@SuppressWarnings('PMD')
public with sharing class ServiceAppointmentTriggerEmailHelper {
    public static Set<String> meetingTypeSet = new Set<String>();
	
    public static Map<String,String> emailTempBodyMap = new Map<String, String>();
    public static Map<Id,User> serAppAssResMap = new Map<Id, User>();
    public static Map<Id, ServiceAppointment> newServiceAppointmentMap = new Map<Id, ServiceAppointment>();
	
    public static List<Messaging.SingleEmailMessage> finalMailsList = new List<Messaging.SingleEmailMessage>();
    public static List<EnhancedLetterhead> letterhead = new List<EnhancedLetterhead>();
    public static List<OrgWideEmailAddress> emailDisplayName = new List<OrgWideEmailAddress>();
    public static List<user> currUserDetails = new List<user>();
	public static String phone = '';    
    //Community FSL book appoinement error if user tries to create Service Appointment from Community
    public static void checkCommunityUser (list<ServiceAppointment> serviceAppointmentList){//NOPMD
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() ];//NOPMD
        String myProflieNamee = profile[0].Name;
        for(ServiceAppointment sAppt : serviceAppointmentList){
            If( myProflieNamee == 'Citation Customer Community Login User'){
            
                serviceclass.runSALogic=false; 
               // String erMessageCustLabel = Label.community_Service_Appt_Creation;
                //sAppt.addError(erMessageCustLabel);
				return;
                
            }
        }
        
    }
    
        
    /*public static void sendEmailNotificationOnStatusDisCan(List<ServiceAppointment> newSerAppList, Map<Id, ServiceAppointment> oldSerAppMap){
                 
        for(ServiceAppointment serApp : [Select Id, contact.FirstName, contact.MobilePhone, Status, ServiceTerritory.Name, Milestone_Work_Type__r.Milestone_Template__r.Business__c, Address, Street,City, state, postalCode, Country,
                                         visit_type__c, Meeting_Type__c, Customer_Friendly_Meeting_Name__c, AppointmentNumber, SchedStartTime,SchedEndTime 
                 						 from ServiceAppointment Where Milestone_Work_Type__r.Milestone_Template__r.Business__c = 'Citation' AND
                                         Status in('Confirmed', 'Canceled') AND visit_type__c in ('Face-To-Face', 'Virtual')
										 AND ServiceTerritory.Name IN ('H&S Territory', 'EL / HR Territory', 'Atlas On-Boarding', 'Onsite HR Territory')
										 AND ID IN : newSerAppList WITH SECURITY_ENFORCED]){
										 
           
            IF(( oldSerAppMap.get(serApp.Id).status == 'Scheduled' && serApp.Status == 'Confirmed' )
                ||(serApp.Status == 'Confirmed' && (serApp.SchedStartTime != oldSerAppMap.get(serApp.id).SchedStartTime || serApp.SchedEndTime != oldSerAppMap.get(serApp.id).SchedEndTime))
			    ||( oldSerAppMap.get(serApp.Id).status != 'Canceled'  && serApp.Status != oldSerAppMap.get(serApp.Id).Status) ){
                    
					meetingTypeSet.add(serApp.Meeting_Type__c);
					newServiceAppointmentMap.put(serApp.Id, serApp);
                
			}
        }
        if(!newServiceAppointmentMap.isEmpty()){
            for(AssignedResource arRec : [Select Id, ServiceAppointmentId, ServiceResource.RelatedRecord.Name, 
                                          ServiceResource.RelatedRecord.Title, ServiceResource.RelatedRecord.Phone, 
                                          ServiceResource.RelatedRecord.MobilePhone from AssignedResource where ServiceAppointmentId 
                                          IN : newServiceAppointmentMap.keySet() ]){
                serAppAssResMap.put(arRec.ServiceAppointmentId,arRec.ServiceResource.RelatedRecord);
                                           
                                              
            }
			getEmailTempAndLetterheadDetails(meetingTypeSet);
			setupDataToSendEmail(oldSerAppMap);
			if(!finalMailsList.isEmpty()){
              	sendEmail(finalMailsList);
			}
        }
	
    }
	public static void getEmailTempAndLetterheadDetails(Set<String> meetingTypeSet){
		letterhead = [select id, name, LetterheadFooter,LetterheadHeader from EnhancedLetterhead 
										where Name = 'Citation service appointment dispatch letterhead' WITH SECURITY_ENFORCED limit 1 ];
        
        for(EmailTemplate empTemp : [Select id, name, HtmlValue,Markup, body from EmailTemplate where name IN :meetingTypeSet WITH SECURITY_ENFORCED] ){
            emailTempBodyMap.put(empTemp.name, empTemp.Markup);
            
        }
       emailDisplayName =  [select id,Address, DisplayName from OrgWideEmailAddress where address = 'reply-email@citation.co.uk' Limit 1];
        currUserDetails = [select Id, phone, Name, username from User where id =: UserInfo.getUserId() Limit 1];
        phone = currUserDetails[0].phone;
	
	}
		
	public static void setupDataToSendEmail(Map<Id, ServiceAppointment> oldSerAppMap){
				
        for(ServiceAppointment serApp : newServiceAppointmentMap.values()){
            if(serApp.Meeting_Type__c != null && System.Label.SA_Meeting_Type.contains(serApp.Meeting_Type__c) ){				   
				Id contactEmail = serApp.ContactId;
				String body = emailTempBodyMap.get(serApp.Meeting_Type__c) != null ? emailTempBodyMap.get(serApp.Meeting_Type__c): ' ' ;
							
				if(serApp.status == 'Confirmed' && serApp.SchedStartTime != null){
                    confirmStatusChecks(contactEmail, body, serApp, oldSerAppMap);
					
                }else if(serApp.status == 'Canceled'){
                   cancelCheck(contactEmail, serApp , oldSerAppMap);
                }
				   
			}
        }
    }		 
     
	
    public static void sendF2FDispatchedEmail(Id rContactEmail, String body, ServiceAppointment serAppRec){
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        User assRes = new user();
        String schDateFormated = '';
        DateTime schDate = serAppRec.SchedStartTime;
        schDateFormated = schDate.format('EEEEE dd MMMMM , yyyy hh:mm a');
        
		String contactName = serAppRec.Contact.FirstName != null ? serAppRec.Contact.FirstName+', ' : '' ;
        String customerFriMeeName = serAppRec.Customer_Friendly_Meeting_Name__c != null ? serAppRec.Customer_Friendly_Meeting_Name__c+' ': '';
        String street = serAppRec.Street != null ? serAppRec.Street+', ' : '';
        String city = serAppRec.City != null ? serAppRec.City+', ' : '';
        String state = serAppRec.State != null ? serAppRec.State+', ' : '';
        String postalCode = serAppRec.PostalCode != null ? serAppRec.PostalCode+'. ' : '';
        String country = serAppRec.Country != null ? serAppRec.Country+'. ' : '';
        if(serAppAssResMap.get(serAppRec.Id) != null){
            assRes= serAppAssResMap.get(serAppRec.Id);
            
        }
        String name = assRes.Name != null ? assRes.Name : UserInfo.getName();
        String title = assRes.Title != null ? assRes.Title : '';
        String phone = assRes.Phone != null ? assRes.Phone : '';
        String mobilePhone = assRes.MobilePhone != null ? assRes.MobilePhone : '';
        
		mail.setTargetObjectId(rContactEmail);
		mail.setReplyTo('hsfieldsupport@citation.co.uk');
		//mail.setSenderDisplayName('Citation <reply-email@citation.co.uk>');
        mail.setOrgWideEmailAddressId(emailDisplayName[0].Id);
        
		mail.setSubject('Citation Visit: ' + customerFriMeeName +' on '+schDateFormated);
		mail.setBccSender(false);
		mail.setSaveAsActivity(true);
		mail.setUseSignature(false);
        mail.setWhatId(serAppRec.id);
        
        if(serAppRec.Visit_Type__c == 'Face-To-Face'){
            mail.setHtmlBody('<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'Dear '+contactName +'<br/><br/>Your ' +customerFriMeeName +' is booked for '+
            schDateFormated+' and will take place at: '+Street +City +State +PostalCode
                            + Body +'<br/>Best Regards, <br/>'+Name + '<br/>' + Title + '<br/>' +Phone
                            +'<br/>'+MobilePhone +'<br/>'+'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>');	
        }else if(serAppRec.Visit_Type__c == 'Virtual'){
            mail.setHtmlBody('<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'Dear '+contactName +'<br/><br/>Your ' +customerFriMeeName +' is booked for '+
            schDateFormated+' and will take place "via virtual link".<br/> '
                            + Body +'<br/>Best Regards, <br/>'+Name + '<br/>' + Title + '<br/>' +Phone
                            +'<br/>'+MobilePhone +'<br/>'+'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>');	 
        }
        
        finalMailsList.add(mail);
       
        
    }

    public static void sendCancelEmail(Id rContactEmail, ServiceAppointment serAppRec,  Map<Id, ServiceAppointment> oldSerAppMap){
        
        String schDateFormated = '';
        DateTime schDate =oldSerAppMap.get(serAppRec.id).SchedStartTime;
        schDateFormated = schDate.format('EEEEE dd MMMMM , yyyy hh:mm a');
        
        String contactName = serAppRec.Contact.FirstName != null ? serAppRec.Contact.FirstName : '' ;
        String visitType = serAppRec.visit_type__c != null ? serAppRec.visit_type__c : '' ;
        String customerFriMeeName = serAppRec.Customer_Friendly_Meeting_Name__c != null ? serAppRec.Customer_Friendly_Meeting_Name__c+' ': '';
        
		String email = userInfo.getUserName(); 
        String name =  UserInfo.getName();
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       	mail.setTargetObjectId(rContactEmail);
		mail.setReplyTo('hsfieldsupport@citation.co.uk');
		//mail.setSenderDisplayName('Citation <reply-email@citation.co.uk>');
        mail.setOrgWideEmailAddressId(emailDisplayName[0].Id);
		mail.setSubject('Citation Meeting Cancellation: ' + customerFriMeeName +' on '+schDateFormated);
		mail.setBccSender(false);
        mail.setWhatId(serAppRec.id);
		mail.setSaveAsActivity(true);
		mail.setUseSignature(false);
       	        
        mail.setHtmlBody('<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'Dear '+contactName +',<br/><br/>Your ' +customerFriMeeName+' arranged for '+schDateFormated +' has been cancelled. <br/>'+
            'If you have arranged an alternative meeting date then you will receive a new booking confirmation.  If not, please contact me at your earliest convenience either by telephone '
            +phone +' '+'or by email hsfieldsupport@citation.co.uk.'+'<br/>'+'For general day-to-day enquiries, advice and guidance on any issues you can call our 24 hour helpline on 0345 844 4848.'+
             '<br/> <br/>'+'Best Regards,<br/>'+ name+ '<br/>'+email+'<br/>'+phone+'<br/>'+'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>' );	
        
        finalMailsList.add(mail);
        
        
    }
    public static void sendEmail(List<Messaging.SingleEmailMessage> finalEmailList){
        try{
			Messaging.sendEmail(finalEmailList);
            finalEmailList.clear();
            //newServiceAppointmentMap.clear();
           }Catch(Exception e){
           	 system.debug('Send Email Exception'+ e);
           }
        
    }
    public static void cancelCheck(Id rContactEmail, ServiceAppointment serAppRec,  Map<Id, ServiceAppointment> oldSerAppMap){
        if(oldSerAppMap.get(serAppRec.id).SchedStartTime != null){
            sendCancelEmail(rContactEmail, serAppRec, oldSerAppMap);
        }
    }
    public static void confirmStatusChecks(Id contactEmail,  String body, ServiceAppointment serApp, Map<Id, ServiceAppointment> oldSerAppMap){  
        sendF2FDispatchedEmail(contactEmail, body, serApp);
        
    }*/
    

}