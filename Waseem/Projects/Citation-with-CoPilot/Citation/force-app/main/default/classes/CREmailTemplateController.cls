public class CREmailTemplateController {
//	public  Event evnt {get;set;}
    public id recid {get;set;}
    public String Contacts {get;set;}

    public Event evnt{
        get {
            try{
          evnt = [select id,Subject,StartDateTime,Location, who.name ,Owner.name, createdby.name from Event where id =: recid];
          List<id> ContactInvitees = new List<id>();
          if(system.label.TimeZone == 'BST'){
              evnt.StartDateTime = (evnt.StartDateTime).addHours(1);
          }
          Contacts = '';
                if((String)evnt.who.name != '' && evnt.who.name != NULL){
                    Contacts = (String)evnt.who.name;
                }
          For(EventRelation eventRel : [SELECT id, RelationId from EventRelation where EventId =: recid]){
                if(String.valueOf(eventRel.RelationId).StartsWith('003')){
                  ContactInvitees.add((ID)eventRel.RelationId);  
                }  
            }
            if(ContactInvitees != NULL && ContactInvitees.SIZE() != 0){
                for(Contact c : [Select name from Contact where id IN :ContactInvitees]){ 
                    If( Contacts != '' && !Contacts.contains((String)c.name)){
                    	Contacts = Contacts   + ', ' + (String)c.name;
                    } else{
                        Contacts = (String)c.name;
                    }
                }
            }    
          return evnt; }
         Catch(Exception e){
             System.debug('Exception in CREmailTemplateController' +  e.getMessage());
             return null;
         } }
       set;
    }
/*	public CREmailTemplateController() {
        try{
            System.debug('Entered the Apex with id - ' + recid);
            evnt = [select id,Subject,StartDateTime,Location, who.name ,Owner.name, createdby.name from Event LIMIT 1];
        	System.debug('Entered the Apex with evnt - ' + evnt);
        } Catch(Exception e){
            System.debug('Exception in CREmailTemplateController' +  e.getMessage());
        }
    }  */

}