public with sharing class EventCloneHandler {
     public static void cloneEvent(map<id,event> newEventMap, map<id,event> oldEventMap){
        list<event> newEventList = new list<event>();
        list<EventRelation> evRelation = new list<EventRelation>(); 
        list<id> eventid = new list<id>();
        map<id,event> mapEvent = new map<id,event>();
        
       
            for(event et: newEventMap.values()){
                system.debug(Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosById().get(et.recordtypeid).getName()+'--'+et.Event_Status__c+'--'+oldEventMap.get(et.id).Event_Status__c);
                if(Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosById().get(et.recordtypeid).getName() == 'Client Relations Record Type' && et.Event_Status__c == 'Cancel and Re-Book' && et.Event_Status__c != oldEventMap.get(et.id).Event_Status__c){
                    if(RecursiveTriggerHandler.isFirstTime){
                    event evtClone = et.clone(false, true, false);
                    evtClone.StartDateTime = et.Rebooking_Date__c;
                    evtClone.ActivityDateTime = et.Rebooking_Date__c;
                    evtClone.EndDateTime = null;
                    evtClone.durationinminutes = et.durationinminutes;
                    evtClone.Cancelled_Event__c ='/lightning/r/Event/'+et.id+'/view';
                    evtClone.Cancellation_Date__c = null;
                    evtClone.Cancellation_Reason__c = null;
                    evtClone.Cancellation_Status__c = null;
                    evtClone.CR_Event_Notification_Email_Sent__c = null;
                    evtClone.Cancellation_By__c = null;
                    evtClone.Rebooking_Date__c = null;
                    evtClone.Event_Status__c = 'Booked';
                    list<string> evsub = new list<string>();
                    if(et.subject.contains('CANCELLED - ')){

                        evsub = et.subject.split('-');
                        evtClone.subject = evsub[evsub.size()-1];
                    }
                    eventid.add(et.id);
                    newEventList.add(evtClone);
                    system.debug('Inside of clone');
                }
                }
            }
         	RecursiveTriggerHandler.isFirstTime = false;
            
            if(newEventList.size()>0){
                    system.debug('Inside of New events'+newEventList);
                    insert newEventList;
                    system.debug('event ids'+newEventList);
                    for(event etn: newEventList){
                        list<string> elin = etn.Cancelled_Event__c.split('/');
                        system.debug('e id '+elin[4]);
                        mapEvent.put(elin[4],etn);
                        
                    }
            }
            
            
            for(eventRelation ert: [SELECT EventId,RelationId FROM EventRelation where eventid In: eventid]){
                eventRelation evr = ert.clone(false,true,false);
                evr.EventId = mapEvent.get(ert.EventId).id;
                evRelation.add(evr);
            }
            if(evRelation.size()>0){
                insert evRelation;
            }

        
         
    }
}