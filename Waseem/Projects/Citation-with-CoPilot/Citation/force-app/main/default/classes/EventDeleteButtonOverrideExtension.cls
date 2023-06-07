public class EventDeleteButtonOverrideExtension{
    
    final Event event {get; set;}
    public EventDeleteButtonOverrideExtension(ApexPages.standardController controller){
        
        this.event = [Select Subject, StartDateTime, EndDateTime, IsPrivate, WhatId, WhoId from Event where Id = :controller.getRecord().Id ];
        
    }
    
    public PageReference handleDeletionRequest(){
        
        Event_Deletion_Configuration__c mhc = Event_Deletion_Configuration__c.getInstance(UserInfo.getProfileId());
        Boolean mEventsCanBeDeleted = mhc.Can_delete_events__c;
        
        if(mEventsCanBeDeleted){
            
            insert new Failed_Event_Deletion__c(
                Event_Id__c= this.event.Id,
                Deleted__c = true,
                Subject__c = this.event.Subject,
                StartDateTime__c = this.event.StartDateTime,
                EndDateTime__c = this.event.EndDateTime,
                IsPrivate__c = this.event.IsPrivate,
                Related_To_Id__c = this.event.WhatId, 
                Who_Id__c = this.event.WhoId       
            );
            
            delete this.event;
            return new PageReference('/00U/c');
            
        } else{
            
            insert new Failed_Event_Deletion__c(
                Event_Id__c= this.event.Id,
                Deleted__c = false,
                Subject__c = this.event.Subject,
                StartDateTime__c = this.event.StartDateTime,
                EndDateTime__c = this.event.EndDateTime,
                IsPrivate__c = this.event.IsPrivate,
                Related_To_Id__c = this.event.WhatId, 
                Who_Id__c = this.event.WhoId                      
            );
        }
        
        return null;
    }
}