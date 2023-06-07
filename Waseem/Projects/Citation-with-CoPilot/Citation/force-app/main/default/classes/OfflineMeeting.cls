/**
 * @File Name          : OfflineMeeting.cls
 * @Description        : Payload structure required for creating Teams Offline meeting 
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
public without sharing class OfflineMeeting {
    public AuthorizationDetails authorizationDetails{get; set;}
    public Boolean allowNewTimeProposals{get; set;}
    public List<Attendee> attendees{get; set;} 
    public EmailBody body{get; set;}
    public DateTimeFormat endDateTime{get; set;}
    public Boolean isOnlineMeeting{get; set;}
    public Boolean isOrganizer{get; set;}
    public Boolean responseRequested{get; set;}
    public DateTimeFormat startDateTime{get; set;}
    public String subject{get; set;}
    public OfflineLocation location{get; set;}
    public Boolean isReminderOn{get; set;}
    public String recordId{get; set;}
    public Integer flag{get; set;}
    
    public OfflineMeeting(List<Attendee> attnds, String subject, EmailBody body, ServiceAppointment servApp,String host){
        this.authorizationDetails = new AuthorizationDetails(host);
        this.allowNewTimeProposals = false;
        this.attendees = attnds;
        this.body = body;
        this.endDateTime = new DateTimeFormat(servApp.SchedEndTime,servApp.ServiceTerritory?.OperatingHours?.Timezone);
        this.isOnlineMeeting = false;
        this.isOrganizer = true;
        this.responseRequested = false;
        this.startDateTime =  new DateTimeFormat(servApp.SchedStartTime,servApp.ServiceTerritory?.OperatingHours?.Timezone);
        this.subject = subject;
        this.location = new OfflineLocation(new Address(servApp));
        this.isReminderOn = true;
        this.recordId = servApp.Id;
        this.flag = 2;
    }
    
    public class OfflineLocation {
        public Address address{get; set;}
        
        public OfflineLocation(Address addr){
            this.address = addr;
        }
    }
    
    public class Address {
        public String city{get; set;}
        public String countryOrRegion{get; set;}
        public String postalCode{get; set;}
        public String state{get; set;}
        public String street{get; set;}
        
        public Address(ServiceAppointment sa){
            this.city = sa.City;
            this.countryOrRegion = sa.Country;
            this.postalCode = sa.PostalCode;
            this.state = sa.State;
            this.street = sa.Street;
        }
    }
    
    public override String toString() {
        return JSON.serialize(this);
    }
}