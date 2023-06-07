/**
 * @File Name          : OnlineMeeting.cls
 * @Description        : Payload structure required for creating Teams Online meeting 
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
public class OnlineMeeting {
    public AuthorizationDetails authorizationDetails{get; set;}
    public Boolean allowNewTimeProposals{get; set;}
    public List<Attendee> attendees{get; set;} 
    public EmailBody body{get; set;}
    public DateTimeFormat endDateTime{get; set;}
    public Boolean isOnlineMeeting{get; set;}
    public Boolean isOrganizer{get; set;}
    public String onlineMeetingProvider{get; set;}
    public Boolean responseRequested{get; set;}
    public DateTimeFormat startDateTime{get; set;}
    public String subject{get; set;}
    public OnlineLocation location{get; set;}
    public Boolean isReminderOn{get; set;}
    public String recordId{get; set;}
    public Integer flag{get; set;}
    
    public OnlineMeeting(List<Attendee> attnds, String subject, EmailBody body, ServiceAppointment servApp,String host){
        this.authorizationDetails = new AuthorizationDetails(host);
        this.allowNewTimeProposals = false;
        this.attendees = attnds;
        this.body = body;
        this.endDateTime = new DateTimeFormat(servApp.SchedEndTime,servApp.ServiceTerritory?.OperatingHours?.Timezone);
        this.isOnlineMeeting = true;
        this.isOrganizer = true;
        this.onlineMeetingProvider = 'teamsForBusiness';
        this.responseRequested = false;
        this.startDateTime =  new DateTimeFormat(servApp.SchedStartTime,servApp.ServiceTerritory?.OperatingHours?.Timezone);
        this.subject = subject;
        this.location = new OnlineLocation();
        this.isReminderOn = true;
        this.recordId = servApp.Id;
        this.flag = 1;
    }
    
    public class OnlineLocation {
        public String displayName{get; set;}
        
        public OnlineLocation(){
            this.displayName = 'Microsoft Teams Meeting';
        }
    }
    
    public override String toString() {
        return JSON.serialize(this);
    }
}