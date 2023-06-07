/*
* @date 12-09-2022
* @description This Class is used as ServerSide Controller for RestrictBDMfromAccessingothersCalendars Lightning Component
*/
public class RestrictBDMfromAccessingothersCalendars {
    /*
    * @date 12-09-2022
    * @description This Method verifies if a BDM is Viewing other BDMS events if Yes it communicates to Client Side Controller to navigate back to Calendar Home
    * @param Event record Id
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean verifyandRemoveCalendarView(Id recordId){
        Id currentUserId=UserInfo.getUserId();
        Id currentUserProfileId=UserInfo.getProfileId();
        List<Id> BDMProfileIds=System.label.Restricted_BDM_Profiles.split(','); 
        //Checks if Current User is a BDM User
        if(BDMProfileIds.contains(currentUserProfileId)){
            //Fetches the Current Events Owner details to verify if BDM is Viewing Other BDM events/his own Events 
            Event currentEvent=[Select Id,OwnerId,Owner.ProfileId From Event where Id=:recordId];
            if(BDMProfileIds.contains(currentEvent.Owner.ProfileId) && currentEvent.OwnerId!=currentUserId){
                List<CalendarView> calendarViewRecordofBDM=[SELECT Id FROM CalendarView where OwnerId=:currentUserId AND Publisher.ProfileId IN :BDMProfileIds];
                if(!calendarViewRecordofBDM.isEmpty()){
                    Database.delete(calendarViewRecordofBDM,false);
                }
                return true;//BDM Viewing Other BDM's Events
            }
            else{
                return false;//BDM is Viewing either his Own Events/ an non BDM Users Events
            }
        }
        else{
            return false;//Current User is not a BDM User
        }
    }
}