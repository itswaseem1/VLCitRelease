/**
 * @File Name          : CancelMeeting.cls
 * @Description        : Fields of Cancelling Teams Meeting Invite
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
public class CancelMeeting {
	public AuthorizationDetails authorizationDetails{get; set;}
    public String meetingId{get; set;}
    public String comment{get; set;}
    public String recordId{get; set;}
    public Integer flag{get; set;}
    
    public CancelMeeting(String cmt,String mtId,String host,String recId){
        this.authorizationDetails = new AuthorizationDetails(host);
        this.meetingId = mtId;
        this.comment = cmt.replace('\"', '\'');
        this.recordId = recId;
        this.flag = 3;
    }
    
    public override String toString() {
        return JSON.serialize(this);
    }
}