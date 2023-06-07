/**
 * @File Name          : OnlineMeetingUpdate.cls
 * @Description        : Payload structure required for updating Teams Online meeting 
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
public class OnlineMeetingUpdate {
	public String meetingId{get; set;}
    public OnlineMeeting meetingDetails{get; set;}
    public Integer flag{get; set;}
    
    public OnlineMeetingUpdate(String mtngId, OnlineMeeting onlineMt){
        this.meetingId = mtngId;
        this.meetingDetails = onlineMt;
        this.flag = 4;
    }
    
    public override String toString() {
        return JSON.serializePretty(this);
    }
}