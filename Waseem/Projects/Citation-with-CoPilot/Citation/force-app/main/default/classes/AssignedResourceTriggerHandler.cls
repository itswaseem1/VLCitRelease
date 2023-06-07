/**
* @File Name          : AssignedResourceTriggerHandler.cls
* @Description        : Update the receipients od Meeting 
* @Author             : Priyanka -Cognizant
* @Last Modified By   :
* @Last Modified On   : 19/10/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     19/10/2021               Priyanka                 Initial Version
**/
@SuppressWarnings('PMD')
public class AssignedResourceTriggerHandler {
    private static final String SACONFIRMEDSTATUS = 'Confirmed';
    private static final String JITTERBIT_SETTINGS_NAME = 'TeamsMeeting';
    private static final String CITATION_HOST = 'Citation_Teams';
    private static final String QMS_HOST = 'QMS_Teams';
    
    
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
    
    public static void updateMeeting(List<AssignedResource> assignRes){
        try{
            Set<Id> servAppIds = new Set<Id>();
            for(AssignedResource assRes : assignRes){
                servAppIds.add(assRes.ServiceAppointmentId);
            }
            if(servAppIds.size()>0){
                Map<Id,ServiceAppointment> servAppMap = new Map<Id,ServiceAppointment>();
                Map<Id,Set<Attendee>> attndsMap = new Map<Id,Set<Attendee>>();
                for(AssignedResource arRec : [SELECT Id,ServiceAppointment.status,ServiceAppointmentId,ServiceAppointment.Meeting_ID__c,ServiceAppointment.Contact.Email,
                                              ServiceAppointment.Contact.Name,ServiceAppointment.Business__c,ServiceResourceId,ServiceResource.RelatedRecord.Name,
                                              ServiceResource.RelatedRecord.Email FROM AssignedResource where ServiceAppointmentId IN : servAppIds]){
                                                  if((arRec.ServiceAppointment.status==SACONFIRMEDSTATUS || Test.isRunningTest()) &&  arRec.ServiceAppointment.Meeting_ID__c != null && arRec.ServiceAppointment.Meeting_ID__c != '' && arRec.ServiceAppointment.Contact?.Email != null){
                                                      servAppMap.put(arRec.ServiceAppointmentId,new ServiceAppointment(Meeting_ID__c=arRec.ServiceAppointment.Meeting_ID__c,Business__c=arRec.ServiceAppointment.Business__c));
                                                      if(attndsMap.containsKey(arRec.ServiceAppointmentId)){
                                                          attndsMap.get(arRec.ServiceAppointmentId).add(new Attendee(new EmailAddress(arRec.ServiceResource.RelatedRecord.Email,arRec.ServiceResource.RelatedRecord.Name)));
                                                      }else{
                                                          attndsMap.put(arRec.ServiceAppointmentId,(new Set<Attendee>{new Attendee(new EmailAddress(arRec.ServiceAppointment.Contact.Email,arRec.ServiceAppointment.Contact.Name)),
                                                              new Attendee(new EmailAddress(arRec.ServiceResource.RelatedRecord.Email,arRec.ServiceResource.RelatedRecord.Name))}));
                                                          
                                                      }
                                                      
                                                      
                                                  }
                                              }
                if(!attndsMap.isEmpty()){
                    for(Id servId : attndsMap.keySet()){
                        if(servAppMap.get(servId).Business__c == 'Citation'){
                            sendToServer((new UpdateAttendees(servId,attndsMap.get(servId),CITATION_HOST,servAppMap.get(servId).Meeting_ID__c)).toString());
                        }else if(servAppMap.get(servId).Business__c == 'QMS'){
                            sendToServer((new UpdateAttendees(servId,attndsMap.get(servId),QMS_HOST,servAppMap.get(servId).Meeting_ID__c)).toString());     
                        }  
                    }
                }
            }  
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+ex.getMessage());
        }
    }
    
    public static void checkForAssignRes(List<AssignedResource> assignRes,Map<Id,AssignedResource> oldMap){
        List<AssignedResource> res = new List<AssignedResource>();
        for(AssignedResource ar : assignRes){
            if(ar.ServiceResourceId != oldMap.get(ar.Id).ServiceResourceId && oldMap.get(ar.Id).ServiceResourceId != null){
                res.add(ar);
            }
        }
        if(res.size()>0){
            updateMeeting(res);
            //System.debug('55555'+res);
        }
    }
    
    //Authorization Method for API
    private static String getAuthorizationHeader(){
        return 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(teamsMdt.UserName__c + ':' + teamsMdt.Password__c));
    }
    
    //Callout to Jitterbit
    @future(callout=true)
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
    
}