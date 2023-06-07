/**
* @File Name          : ServiceAppointmentMeetingCreation.cls
* @Description        : Send the Teams Meeting Invites via Jitterbit 
* @Author             : Priyanka -Cognizant
* @Last Modified By   :
* @Last Modified On   : 06/10/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     06/10/2021               Priyanka                 Initial Version
**/
@SuppressWarnings('PMD')
public class ServiceAppointmentMeetingCreation {
    private static final String SACONFIRMEDSTATUS = 'Confirmed';
    private static final String VIRTUALVISIT = 'Virtual';
    private static final String FACETOFACEVISIT = 'Face-to-Face';
    private static final String HOMEREMOTEVISIT = 'Home Remote Audit';
    private static final String CITATION_HOST = 'Citation_Teams';
    private static final String QMS_HOST = 'QMS_Teams';
    private static final String SERVAPPSCHSTATUS = 'Scheduled';
    private static final List<String> SERVAPPCANCELSTATUS = new List<String>{'Canceled','Cannot Complete'};
    private static final String LETTERHEADNAME = 'Citation service appointment dispatch letterhead';
    private static final String JITTERBIT_SETTINGS_NAME = 'TeamsMeeting';
    public static String phone = '';
    public static Map<String,String> emailTempBodyMap = new Map<String,String>();
    public static Map<Id,User> serAppAssResMap = new Map<Id, User>();
    public static Map<Id,Set<EmailAddress>> assignedResEmails = new Map<Id,Set<EmailAddress>>();
    public static List<EnhancedLetterhead> letterhead = new List<EnhancedLetterhead>();
    public static Map<Id,Id> SAvsScheduler=new Map<id,Id>();
    public static Map<Id,User> userData=new Map<id,User>();
    private static JitterbitSettings__mdt getJitterbitSettingsItem(){
        List<JitterbitSettings__mdt> jbItems=[Select Endpoint__c,Username__c,Password__c From JitterbitSettings__mdt
                                              where DeveloperName =: JITTERBIT_SETTINGS_NAME Limit 1];
        return (!jbItems.isEmpty()) ? jbItems.get(0) : null;
    } 
    
    private static JitterbitSettings__mdt teamsMdt{
        get{
            return (teamsMdt==null) ? (teamsMdt = getJitterbitSettingsItem()) : teamsMdt;
        }
        set;
    }
    
    //Callout to Jitterbit
    @future (callout=true)
    private static void sendToServer(String body) {
      
        if(teamsMdt != null) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(teamsMdt.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Authorization', getAuthorizationHeader()); //NOPMD
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            HttpResponse response = (new Http()).send(request);
        }
    }
    
    //Fetches the Confirmed Status Service Appointments
    public static void sendEmails(List<ServiceAppointment> saList, Map<Id,ServiceAppointment> sAMap){
        
        Map<Id,ServiceAppointment> servAppIds = new Map<Id,ServiceAppointment>();
        Set<String> emailTempNames = new Set<String>();
        try{
            for(ServiceAppointment sa : [Select Id,(SELECT ServiceAppointmentId,CreatedById FROM Histories where Field = 'Service_Resource__c' AND DataType = 'Text' ORDER BY CreatedDate ASC NULLS FIRST),Status,SchedStartTime,SchedEndTime,Business__c,AppointmentNumber, Contact.Email,Contact.Name,Contact.FirstName,Contact.MobilePhone,Customer_Friendly_Meeting_Name__c,
                                         Meeting_Type__c,Address,Street,City,State,PostalCode,Country,Visit_type__c,account.name,
                                         ServiceTerritory.Name,Service_Resource__r.RelatedRecord.Name,ServiceTerritory.OperatingHours.Timezone,Meeting_ID__c from ServiceAppointment where Id IN:sAMap.keySet() and Status =: SACONFIRMEDSTATUS and Meeting_Type__c != 'No Auto-Emails']){
                                             if(sa.status==SACONFIRMEDSTATUS && sAMap.get(sa.id).status == SERVAPPSCHSTATUS && sa.Business__c == 'QMS' && sa.Contact.Email!=null){
                                                 servAppIds.put(sa.Id,sa);
                                             }
                                             else if(sa.Business__c == 'Citation' && sa.Contact.Email!=null && sAMap.get(sa.Id).status == SERVAPPSCHSTATUS && sa.Status == SACONFIRMEDSTATUS){
                                                 servAppIds.put(sa.Id,sa);    
                                                 emailTempNames.add(sa.Meeting_Type__c);                    
                                             }
                                             
                                             for (ServiceAppointmentHistory  sch: sa.Histories){
                                                 SAvsScheduler.put(sch.ServiceAppointmentId,sch.CreatedById);
                                             }
                                         }    
            if(!servAppIds.isEmpty()){
                if(!SAvsScheduler.isEmpty()){
                    for(User u: [select id,name,title from user where id in: SAvsScheduler.values()])
                        userData.put(u.id,u);
                }
                
                postMeetingPayload(servAppIds,emailTempNames);
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+','+ex.getMessage());
        }
    }
    
    public static void postMeetingPayload(Map<Id,ServiceAppointment> servAppIds,Set<String> emailTempNames){
        letterhead = [Select Id, Name, LetterheadFooter,LetterheadHeader from EnhancedLetterhead where Name =: LETTERHEADNAME Limit 1 ];
        if(emailTempNames.size() > 0){
            fetchEmailTemplates(emailTempNames);
        }
        List<user> currUserDetails = [select Id, phone, Name, username from User where id =: UserInfo.getUserId() Limit 1];
        phone = (currUserDetails[0].phone != null ? currUserDetails[0].phone : ' ');
        populateAssignRes(servAppIds.keySet());
        for(ServiceAppointment sa : servAppIds.values()){
            List<Attendee> atts = fetchAttendees(sa,assignedResEmails);
            if(sa.Business__c == 'Citation'){
           
                sendCitMeetingsData(sa,atts);
            }else{
                sendQMSMeetingsData(sa,atts);
            }   
        } 
    }
    
    //Fetches the Assigned Resources associated to the Service Appointments
    public static void populateAssignRes(Set<Id> servAppIds){
        for(AssignedResource arRec : [Select Id, ServiceAppointmentId, ServiceResource.RelatedRecord.Name, 
                                      ServiceResource.RelatedRecord.Title, ServiceResource.RelatedRecord.Phone, ServiceResourceId,ServiceResource.RelatedRecord.Email,
                                      ServiceResource.RelatedRecord.MobilePhone from AssignedResource where ServiceAppointmentId IN : servAppIds]){
                                          serAppAssResMap.put(arRec.ServiceAppointmentId,arRec.ServiceResource.RelatedRecord);   
                                          if(arRec.ServiceResource.RelatedRecord.Email != null){
                                              if(assignedResEmails.containsKey(arRec.ServiceAppointmentId)){
                                                  assignedResEmails.get(arRec.ServiceAppointmentId).add(new EmailAddress(arRec.ServiceResource.RelatedRecord.Email,arRec.ServiceResource.RelatedRecord.Name));
                                              }else{
                                                  assignedResEmails.put(arRec.ServiceAppointmentId, new Set<EmailAddress>{new EmailAddress(arRec.ServiceResource.RelatedRecord.Email,arRec.ServiceResource.RelatedRecord.Name)});
                                              } 
                                          }
                                      }
    }
    
    //Creates the Meeting Invites for Citation Service Appointments
    public static void sendCitMeetingsData(ServiceAppointment sa,List<Attendee> atts){
        User serAppAssRes = serAppAssResMap.get(sa.Id);
		String subj;
        String accountName=sa.account.name;
        if(sa.Visit_Type__c == FACETOFACEVISIT && sa.ServiceTerritory.Name=='FRA Territory'){
            subj = 'Citation Visit: Fire Risk Assessment Confirmation:  on '+(sa.SchedStartTime.format('EEEEE dd MMMMM , yyyy hh:mm a'));
        }else{
            subj = 'Citation Visit: ' + (sa.Customer_Friendly_Meeting_Name__c != null ? (sa.Customer_Friendly_Meeting_Name__c+' ') : '') +' on '+(sa.SchedStartTime.format('EEEEE dd MMMMM , yyyy hh:mm a'))+' Account Name: '+accountName;
        }
        if(sa.Visit_Type__c == VIRTUALVISIT){
            String citOnlineBody = fetchCitationEmailBody(sa,serAppAssRes);
            if(sa.Meeting_ID__c != null && sa.Meeting_ID__c != ''){
                sendToServer((new OnlineMeetingUpdate(sa.Meeting_ID__c,new OnlineMeeting(atts,subj,new EmailBody('html',citOnlineBody),sa,CITATION_HOST))).toString());
            }else{
                sendToServer((new OnlineMeeting(atts,subj,new EmailBody('html',citOnlineBody),sa,CITATION_HOST)).toString());
            }
        }else if(sa.Visit_Type__c == FACETOFACEVISIT){
            String citOfflineBody;
            if (sa.ServiceTerritory.Name=='FRA Territory')
                citOfflineBody=fetchCitationEmailBodyForFRA(sa,serAppAssRes);
            else
                citOfflineBody  = fetchCitationEmailBody(sa,serAppAssRes);
            if(sa.Meeting_ID__c != null && sa.Meeting_ID__c != ''){
                sendToServer((new OfflineMeetingUpdate(sa.Meeting_ID__c,new OfflineMeeting(atts,subj,new EmailBody('html',citOfflineBody),sa,CITATION_HOST))).toString()); 
            }else{
               sendToServer((new OfflineMeeting(atts,subj,new EmailBody('html',citOfflineBody),sa,CITATION_HOST)).toString());  
            }
        }
    }
    
    //Creates the Meeting Invites for QMS Service Appointments
    public static void sendQMSMeetingsData(ServiceAppointment sa,List<Attendee> atts){
        String subj = 'Appointment Has Been Scheduled';
        String bdy = '<span style="color:red">'+System.Label.TeamsMeetingCancelMsg+'</span><br/><br/>'+'Your Appointment: ' + sa.AppointmentNumber +' has been Scheduled.';
        if(sa.Visit_Type__c == VIRTUALVISIT || sa.Visit_Type__c == HOMEREMOTEVISIT){
            if(sa.Meeting_ID__c != null && sa.Meeting_ID__c != ''){
                sendToServer((new OnlineMeetingUpdate(sa.Meeting_ID__c,new OnlineMeeting(atts,subj,new EmailBody('html',bdy),sa,QMS_HOST))).toString());
            }else{
                sendToServer((new OnlineMeeting(atts,subj,new EmailBody('html',bdy),sa,QMS_HOST)).toString()); 
            }
        }else if(sa.Visit_Type__c == FACETOFACEVISIT){
            if(sa.Meeting_ID__c != null && sa.Meeting_ID__c != ''){
                sendToServer((new OfflineMeetingUpdate(sa.Meeting_ID__c,new OfflineMeeting(atts,subj,new EmailBody('html',bdy),sa,QMS_HOST))).toString()); 
            }else{
               sendToServer((new OfflineMeeting(atts,subj,new EmailBody('html',bdy),sa,QMS_HOST)).toString()); 
            }
        }	
    }
    
    //Creates the Email Body for Meeting Invites based on the Email Templates for Citation
    public static String fetchCitationEmailBody(ServiceAppointment sa, User serRes){
        String emailBody = '';
        String customerFriMeeName = sa.Customer_Friendly_Meeting_Name__c != null ? sa.Customer_Friendly_Meeting_Name__c+' ': '';
        String schDateFormated = sa.SchedStartTime.format('EEEEE dd MMMMM , yyyy hh:mm a');
        String name = serRes?.Name != null ? serRes?.Name : UserInfo.getName();
        String title = serRes?.Title != null ? serRes?.Title : '';
        String body = emailTempBodyMap.get(sa.Meeting_Type__c) != null ? emailTempBodyMap.get(sa.Meeting_Type__c): ' ' ;
        String contactName = sa.Contact.FirstName != null ? sa.Contact.FirstName+', ' : '' ;
        String mobilePhone = serRes?.MobilePhone != null ? serRes?.MobilePhone : '';
        if(sa.Visit_Type__c == VIRTUALVISIT){
            emailBody = '<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'<span style="color:red">'+System.Label.TeamsMeetingCancelMsg+'</span><br/><br/>'+'Dear '+contactName +'<br/><br/>Your ' +customerFriMeeName +' is booked for '+
                schDateFormated+' and will take place via the virtual link below.<br/> '
                + body +'<br/>Best Regards, <br/>'+name + '<br/>' + title + '<br/>' + phone
                +'<br/>'+mobilePhone +'<br/>'+'<br/><br/>Reference: '+sa.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>'; 
        }else{
            String street = sa.Street != null ? sa.Street+', ' : '';
            String city = sa.City != null ? sa.City+', ' : '';
            String state = sa.State != null ? sa.State+', ' : '';
            String postalCode = sa.PostalCode != null ? sa.PostalCode+'. ' : '';
            String country = sa.Country != null ? sa.Country+'. ' : '';
            emailBody = '<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'<span style="color:red">'+System.Label.TeamsMeetingCancelMsg+'</span><br/><br/>'+'Dear '+contactName +'<br/><br/>Your ' +customerFriMeeName +' is booked for '+
                schDateFormated+' and will take place at: '+street +city +state +postalCode
                + body +'<br/>Best Regards, <br/>'+name + '<br/>' + title + '<br/>' + phone
                +'<br/>'+mobilePhone +'<br/>'+'<br/><br/>Reference: '+sa.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>';
        }
        return emailBody;
    }
    
    //Fetches the Email Templates Data depending upon the Meeting Types
    public static void fetchEmailTemplates(Set<String> emailTempNames){
        for(EmailTemplate empTemp : [Select id, name, HtmlValue,Markup, body from EmailTemplate where name IN: emailTempNames] ){
            emailTempBodyMap.put(empTemp.name, empTemp.Markup);
        }
    }
    
    //Creates the Receipients data for Meeting Invites
    public static List<Attendee> fetchAttendees(ServiceAppointment servApp,Map<Id,Set<EmailAddress>> assignedResEmails){
        List<Attendee> attnds = new List<Attendee>{new Attendee(new EmailAddress(servApp.Contact.Email,servApp.Contact.Name))};
            if(assignedResEmails.containsKey(servApp.Id)){
                if(assignedResEmails.get(servApp.Id).size()>0){
                    for(EmailAddress emAddr : assignedResEmails.get(servApp.Id)){  
                        attnds.add(new Attendee(emAddr));
                    }
                }
            }
        return attnds;
    }
    
    //Authorization Method for API
    private static String getAuthorizationHeader(){
        return 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(teamsMdt.UserName__c + ':' + teamsMdt.Password__c));
    }
    
    //Checks for Canceled Service Appointments
    public static void checkCanceledSA(Map<Id,ServiceAppointment> saMap,Map<Id,ServiceAppointment> oldSaMap){
        List<EnhancedLetterhead> letterhead = [Select Id, Name, LetterheadFooter,LetterheadHeader from EnhancedLetterhead where Name =: LETTERHEADNAME Limit 1 ];
        List<ServiceAppointment> saApps = [Select Id,Status,ServiceTerritory.Name,SchedEndTime,SchedStartTime,Business__c,Meeting_ID__c,
                                     Contact.FirstName,visit_type__c,Customer_Friendly_Meeting_Name__c,AppointmentNumber from ServiceAppointment where Id IN: saMap.keySet() and Status IN: SERVAPPCANCELSTATUS and Meeting_Type__c != 'No Auto-Emails'];
        for(ServiceAppointment sa : saApps){
                                         if(sa.Meeting_ID__c != null && oldSaMap.get(sa.Id).Status != sa.Status && oldSaMap.get(sa.Id).SchedEndTime > System.now()){
                                             if(sa.Business__c == 'Citation'){
                                                 sendToServer((new CancelMeeting(getCancelEmailBody(sa,oldSaMap,letterhead),sa.Meeting_ID__c,CITATION_HOST,sa.Id)).toString());
                                             }else if(sa.Business__c == 'QMS'){
                                                 sendToServer((new CancelMeeting('',sa.Meeting_ID__c,QMS_HOST,sa.Id)).toString());
                                             }
                                         }
                                     }
    }
    
    //Creates Cancellation Email Body
    public static String getCancelEmailBody(ServiceAppointment serAppRec,Map<Id,ServiceAppointment> oldSerAppMap,List<EnhancedLetterhead> letterhead){
        String emailBody = '';
        String schDateFormated = '';
        DateTime schDate =oldSerAppMap.get(serAppRec.id)?.SchedStartTime;
        schDateFormated = schDate.format('EEEEE dd MMMMM , yyyy hh:mm a');
        
        String contactName = serAppRec.Contact.FirstName != null ? serAppRec.Contact.FirstName : '' ;
        String visitType = serAppRec.visit_type__c != null ? serAppRec.visit_type__c : '' ;
        String customerFriMeeName = serAppRec.Customer_Friendly_Meeting_Name__c != null ? serAppRec.Customer_Friendly_Meeting_Name__c+' ': '';
        
        String email = userInfo.getUserName(); 
        String name =  UserInfo.getName();
        
        if (serAppRec.ServiceTerritory!=null && serAppRec.ServiceTerritory.Name=='FRA Territory'){
            emailBody = '<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'Dear '+contactName +',<br/><br/>Your ' +customerFriMeeName+' arranged for '+schDateFormated +' has been cancelled. <br/>'+
            'If you have arranged an alternative meeting date then you will receive a new booking confirmation.  If not, please contact me at your earliest convenience either by telephone '
            +phone +' '+'or by email '+System.Label.FRA_Email+'.'+'<br/>'+'For general day-to-day enquiries, advice and guidance on any issues you can call our 24 hour helpline on '+System.Label.FRA_Phone_Number+'.'+
            '<br/> <br/>'+'Best Regards,<br/>'+ name+ '<br/>'+email+'<br/>'+phone+'<br/>'+'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>';
        }else{
            emailBody = '<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'Dear '+contactName +',<br/><br/>Your ' +customerFriMeeName+' arranged for '+schDateFormated +' has been cancelled. <br/>'+
            'If you have arranged an alternative meeting date then you will receive a new booking confirmation.  If not, please contact me at your earliest convenience either by telephone '
            +phone +' '+'or by email hsfieldsupport@citation.co.uk.'+'<br/>'+'For general day-to-day enquiries, advice and guidance on any issues you can call our 24 hour helpline on 0345 844 4848.'+
            '<br/> <br/>'+'Best Regards,<br/>'+ name+ '<br/>'+email+'<br/>'+phone+'<br/>'+'<br/><br/>Reference: '+serAppRec.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>';
        }	
        return emailBody;
    }
    
    //Checks for Meeting Updates
    public static void checkForMeetingUpdates(List<ServiceAppointment> saList, Map<Id, ServiceAppointment> sAMap){
        Map<Id,ServiceAppointment> servAppIds = new Map<Id,ServiceAppointment>();
        
        Set<String> emailTempNames = new Set<String>();
        try{
            for(ServiceAppointment sa : [Select Id,(SELECT ServiceAppointmentId,CreatedById FROM Histories where Field = 'Service_Resource__c' AND DataType = 'Text' ORDER BY CreatedDate ASC NULLS FIRST),Status,SchedStartTime,SchedEndTime,Business__c,AppointmentNumber, Contact.Email,Contact.Name,Contact.FirstName,Contact.MobilePhone,Customer_Friendly_Meeting_Name__c,
                                         Meeting_Type__c,Address,Street,City,State,PostalCode,Country,Visit_type__c,account.name,
                                         ServiceTerritory.Name,Service_Resource__r.RelatedRecord.Name,ServiceTerritory.OperatingHours.Timezone,Meeting_ID__c from ServiceAppointment where Id IN:sAMap.keySet() and  Meeting_ID__c != '' and Meeting_Type__c != 'No Auto-Emails']){
                                           
                                             if(sa.status==SACONFIRMEDSTATUS && sa.Meeting_ID__c != null && sa.Meeting_ID__c != '' && sa.SchedEndTime != null && sa.SchedStartTime != null && (sa.SchedEndTime != sAMap.get(sa.id).SchedEndTime || sa.SchedStartTime != sAMap.get(sa.id).SchedStartTime 
                                                                             || sa.Meeting_Type__c != sAMap.get(sa.id).Meeting_Type__c || sa.Visit_Type__c != sAMap.get(sa.id).Visit_Type__c)){
                                                                                 
                                                                                 if(sa.Business__c == 'QMS' && sa.Contact.Email!=null){
                                                                                     servAppIds.put(sa.Id,sa);
                                                                                     
                                                                                 }
                                                                                 else if(sa.Business__c == 'Citation' && sa.Contact.Email!=null){
                                                                                     servAppIds.put(sa.Id,sa);   
                                                                                     emailTempNames.add(sa.Meeting_Type__c);                    
                                                                                 }
                                                                                 for (ServiceAppointmentHistory  sch: sa.Histories){
                                                                                     SAvsScheduler.put(sch.ServiceAppointmentId,sch.CreatedById);
                                                                                 }
                                                                             }
                                            
                                             if(!servAppIds.isEmpty()){
                                                 if(!SAvsScheduler.isEmpty()){
                                                     for(User u: [select id,name,title from user where id in: SAvsScheduler.values()])
                                                         userData.put(u.id,u);
                                                 }
                                                 
                                                 postMeetingPayload(servAppIds,emailTempNames);
                                             }
                                         }
            
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+','+ex.getMessage());
        }
        
    }
    
    //Creates the Email Body for Meeting Invites based on the Email Templates for Citation (FRA)
    public static String fetchCitationEmailBodyForFRA(ServiceAppointment sa, User serRes){
        String emailBody = '';
        String customerFriMeeName = sa.Customer_Friendly_Meeting_Name__c != null ? sa.Customer_Friendly_Meeting_Name__c+' ': '';
        String schDateFormated = sa.SchedStartTime.format('EEEEE dd MMMMM , yyyy hh:mm a');
        String name = serRes?.Name != null ? serRes?.Name : UserInfo.getName();
        String title = serRes?.Title != null ? serRes?.Title : '';
        String body = emailTempBodyMap.get(sa.Meeting_Type__c) != null ? emailTempBodyMap.get(sa.Meeting_Type__c): ' ' ;
        String contactName = sa.Contact.FirstName != null ? sa.Contact.FirstName+', ' : '' ;
        String mobilePhone = serRes?.MobilePhone != null ? serRes?.MobilePhone : '';
        
        String street = sa.Street != null ? sa.Street+', ' : '';
        String city = sa.City != null ? sa.City+', ' : '';
        String state = sa.State != null ? sa.State+', ' : '';
        String postalCode = sa.PostalCode != null ? sa.PostalCode+'. ' : '';
        String country = sa.Country != null ? sa.Country+'. ' : '';
        String Assessor=sa.Service_Resource__r.RelatedRecord.Name;
        String company=sa.account.name;
        emailBody = '<div style="font-family:Arial">'+letterhead[0].LetterheadHeader+'<br/><br/>' +'<span style="color:red">'+System.Label.TeamsMeetingCancelMsg+'</span><br/><br/>'+'Dear '+contactName +'<br/><br/>Following our earlier communication, we are pleased to confirm that your <span style="color:red">Fire Risk Assessment</span> has been booked as follows:<br/><br/><b>Company & Address: </b><br/><span style="color:red">'
            +company+',<br/'+street+'<br/>' +city+'<br/>' +state+'<br/>' 
            +postalCode+'</span><br/><br/><b>Day/Date and Time:</b><span style="color:red">'+schDateFormated+'</span><br/><br/><b>Assessor:</b><span style="color:red">'+Assessor+'</span>'
            + body +'<br/>Best Regards, <br/>'+ userData.get(SAvsScheduler.get(sa.Id)).name + '<br/>' + userData.get(SAvsScheduler.get(sa.Id)).title + '<br/>' + System.Label.FRA_Phone_Number
            +'<br/>'+'<br/><br/>Reference: '+sa.AppointmentNumber+'<br/>'+letterhead[0].LetterheadFooter+'</div>';
        
        return emailBody;
    }
}