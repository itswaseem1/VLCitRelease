public class IhascoBDMAppointment {

  @AuraEnabled
    public static void ihascoBDM(ID leadID) {
        
        try{

        lead le = [select id,Appointment_Type__c,OwnerId from LEAD where (ID=:leadID AND owner.profile.Name='iHasco NBM')];
            if(le !=NULL){
              Event ev = new Event();
              ev.OwnerId =le.OwnerId;
              ev.StartDateTime=system.now();
              ev.EndDateTime=system.now().addMinutes(1);
              ev.RecordTypeId= Schema.SObjectType.Event.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
              ev.Subject= 'iHasco BDM Appointment';
              ev.WhoId=le.id;
             
            insert ev;
            }
            }
            catch (Exception ex)
            {
                system.debug (ex);
            }
        }
}