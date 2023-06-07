/**
* @File Name          : UpdateAttendees.cls
* @Description        : Payload structure for updating recipients of Meeting
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
public class UpdateAttendees {
    public String meetingId{get; set;}
    public Set<Attendee> attendees{get; set;}
    public Integer flag{get; set;}
    public AuthorizationDetails authorizationDetails{get; set;}
    public String recordId{get; set;}
    
    public UpdateAttendees(String saId,Set<Attendee> attds,String host,String mtId){
        this.meetingId = mtId;
        this.attendees = attds;
        this.flag = 6;
        this.authorizationDetails = new AuthorizationDetails(host);
        this.recordId = saId;
    }
    
    public override String toString() {
        return JSON.serializePretty(this);
    }
}