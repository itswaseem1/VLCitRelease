public with sharing class CIT_PH1_EventManager {
	private Map<Id,Lead> leadMap;
	
	private Map<Id,Event> eventMap;
	
	public void addEvents(List<Event> newObjects){
		eventMap = new Map<Id,Event>();
		for(Event eachEvent : newObjects){
			this.eventMap.put(eachEvent.whoId,eachEvent);
		}
	}
	public void setLeadVisitedDate(){
		leadMap = new Map<Id,Lead>([Select X1st_Visit_Date__c,X1st_Visit_Status__c, Id From Lead l WHERE ID in :eventMap.keyset()]);
		List<Lead> leadToBeUpdated = new List<Lead>();
		for(Event eachEvent : eventMap.values()){
			if(eachEvent.recordtypeid != System.Label.CRE_Record_Type && eachEvent.Type!=null && eachEvent.Type.equalsIgnoreCase('1st Visit')){
				if(leadMap.containsKey(eachEvent.whoId)){
					leadMap.get(eachEvent.whoId).X1st_Visit_Date__c = eachEvent.ActivityDateTime;
					leadMap.get(eachEvent.whoId).X1st_Visit_Status__c = eachEvent.Event_Status__c;
					leadToBeUpdated.add(leadMap.get(eachEvent.whoId));
				}	
			}
		}
		update leadToBeUpdated;
	}
	
    //The below is method is for setting the Street information before the event is created
	public list<event> setStreet(list<event> eventList){
		for(event et:eventList){
			if(et.recordtypeid == DataConstants.E_CITATION_EVENT_RID && et.Street__c == null && et.whoid != null && String.valueof(et.whoid).startsWith('00Q') && TriggerEventHandler.leadMap.containskey(et.whoid)){
					et.Street__c = TriggerEventHandler.leadMap.get(et.whoid).street;
			}
		}
		return eventList;
	}

	public list<event> updateEventBInsert(list<event> listEvents){
		list<id> oppId = new list<id>();
        list<id> accId = new list<id>();
		    for(event etm: listEvents){
				String s1 = '006';
                String s2 = '001';
				string etwid = etm.whatid;
				if(etwid != null && etwid != '' && etwid.startswith(s1)){
					oppId.add(etm.whatid);
                }else if(etwid != null && etwid != '' && etwid.startswith(s2)){
                    accId.add(etm.WhatId);
                }
			}
			map<id,opportunity> oppMap = new map<id,opportunity>([select id,name,account.name from opportunity where id In: oppId]);
        	map<id,Account> accMap = new map<id,Account>([select id,name from Account where id In: accId]);
			for(event et: listEvents){
				String pc= '';
                if(et.Post_Code__c != NULL){
                    pc =  et.Post_Code__c;
                }
                if(et.recordtypeid == System.Label.CRE_Record_Type && et.WhatId!=null){
                    if(String.valueOf(et.WhatId).startsWith('006')){
						et.subject = 'Confirmation of meeting between ' + oppMap.get(et.whatid).account.name + ' and Citation ' + pc;
                	}else if(String.valueOf(et.WhatId).startsWith('001')){
                    	et.subject = 'Confirmation of meeting between ' + accMap.get(et.whatid).name + ' and Citation ' + pc;
                	}
                }				
			}
			return listEvents;
	}
    
    /**
    * @date 02 November 2022
    * @description fired on before delete event to restrict BDM's from deleting Events
    * @return void
    * @param eventsGettingDeleted: trigger.old - list of all records before delete
    */
    public static void restrictBDMtoDeleteEvents(List<Event> eventsGettingDeleted){
        Id citationBDMProfileID=[Select Id From Profile Where Name='Citation BDM' LIMIT 1].Id;
        if(UserInfo.getProfileId()==citationBDMProfileID){
            for(Event eventGettingDeleted:eventsGettingDeleted){
                eventGettingDeleted.addError('Please Cancel the Event - Event Cannot be Deleted.');
            }
        }
    }
}