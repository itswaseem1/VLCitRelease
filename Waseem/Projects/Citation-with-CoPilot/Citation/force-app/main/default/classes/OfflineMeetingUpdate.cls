/**
 * @File Name          : OfflineMeetingUpdate.cls
 * @Description        : Payload structure required for updating Teams Offline meeting 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 18/10/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     18/10/2021               Priyanka                 Initial Version
 **/
@SuppressWarnings('PMD')
public class OfflineMeetingUpdate {
	public String meetingId{get; set;}
    public OfflineMeeting meetingDetails{get; set;}
    public Integer flag{get; set;}
    
    public OfflineMeetingUpdate(String mtngId, OfflineMeeting offMt){
        this.meetingId = mtngId;
        this.meetingDetails = offMt;
        this.flag = 5;
    }
    
    public override String toString() {
        return JSON.serializePretty(this);
    }
}