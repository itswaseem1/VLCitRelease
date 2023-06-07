/**
* @author Nimil Christopher
* @date 29 July 2013
* @description Event trigger handler 
*/

public With Sharing  class TriggerEventHandler {
	 /* ATTRIBUTES */
	
    /* CONSTRUCTOR */
    /*private TriggerEventHandler() {
		
    }*/
				
	Public list<id> whoidsL = new list<id>();
	Public list<id> whoidsC = new list<id>();
	Public list<id> whatIdA =  new list<id>();
	Public list<id> whatIdO =  new list<id>();
	Public static Map<id,Account> accountMap = new map<id,Account>() ;
	Public static Map<id,Lead> leadMap = new map<id,Lead>();
	Public static Map<id,Opportunity> opportunityMap = new map<id,Opportunity>() ;
	private static TriggerEventHandler instance;
    public static TriggerEventHandler getInstance() {
        if (instance == null) {
            instance = new TriggerEventHandler();
        }
        return instance;
    }

    /* PUBLIC METHODS */
	
	/**
    * @author Srikanth Ragi
    * @date 04 March 2020
    * @This method is invoked to fetch the related data
    * @return void
    * @param whoidsL,whoidsC,WhatIdA,WhatIdO: boolean values 
    */
    public void fetchRelatedData(list<id> whoidsL,list<id> whoidsC,list<id> whatIdA,list<id> whatIdO) {
		   if(whoidsL.size()>0){
				leadMap = new map<id,Lead>([select id,postalcode,street,company,status,made_criteria__c from lead where id in :whoidsL ]) ;
			}
		    //For future related contact information
			/*
			if(whoidsC.size() > 0){

			}*/
        	if(whatIdO.size() > 0){
				opportunityMap = new map<id,Opportunity>([select id,accountid,name,made_criteria__c from opportunity where id in :whatIdO]) ;
                for(opportunity op: opportunityMap.values()){
                    if(op.accountid != null){
                        whatIdA.add(op.accountid);
                    }
                }
                
			}
			if(whatIdA.size() > 0){
				accountMap = new map<id,Account>([select id,name,post_code__c,BillingPostalCode from account where id in :whatIdA]) ;
			}
			
			}
	
    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    public void onBeforeInsert(final List<Event> newObjects) {
		CIT_PH1_EventManager eventManager = new CIT_PH1_EventManager();
		eventManager.addEvents(newObjects);
		eventManager.setLeadVisitedDate();
		eventManager.updateEventBInsert(trigger.new);
        eventManager.setStreet(trigger.new);


	}
	
	public void prepareRelatedIds(list<event> eventList){
		for(Event e : eventList) {
            string whid = (string)e.WhoId;
            string whaid = (string)e.whatid;
            if(e.WhoId != null && whid.startsWith('00Q')){
                whoidsL.add(e.whoid) ;
            }
            
            if(e.WhatId != null && whaid.startsWith('006')){
                whatIdO.add(e.whatid) ;
            }
            if(e.whatId != null && whaid.startsWith('001')){
                if(e.accountid != null){
                whatIdA.add(e.accountId) ;  
            }
                else 
                 whatIdA.add(e.whatId) ;
            }
            						  		
            else if(e.accountid != null){
                   whatIdA.add(e.accountId) ; 
            }
            
            
            						  		
	   }
        if(whoidsL.size() >0 || whatIdO.size() > 0 ||  whatIdA.size() >0){
           
           fetchRelatedData(whoidsL,null,whatIdA,whatIdO);
        }
		               
	}

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<Event> newObjects, final Map<Id, Event> newObjectsMap) {
    	  
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Event> oldObjects, final Map<Id, Event> oldObjectsMap,
                               final List<Event> newObjects, final Map<Id, Event> newObjectsMap) {
    		  	CIT_PH1_EventManager eventManager = new CIT_PH1_EventManager();
				eventManager.addEvents(newObjects);
				eventManager.setLeadVisitedDate();
                List<Event> eventList = new List<Event>();
				for(Event e : newObjects){
                    Event oE = oldObjectsMap.get(e.id);
                    if(e.Post_Code__c != oE.Post_Code__c || 
                       (e.WhatId != NULL && oE.WhatId != NULL && e.WhatId != oE.WhatId && (String.valueOf(e.WhatId).startsWith('006') 
                       																	|| String.valueOf(e.WhatId).startsWith('001')) ) ){
                        eventList.add(e);
                    }                   
				}
                if(!eventList.isEmpty()){
                   eventManager.updateEventBInsert(eventList); 
                }                   
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    
   

    public static void onAfterInsert(list<id> idList) {
    	
    	//list<feature_enablement__mdt> l = [select enabled__c from feature_enablement__mdt where masterlabel = 'Event Subject Fix'] ;
    	
    	Features__c f = new Features__c() ;
    	try {
    		f = Features__c.getValues('Default');
    	}
    	catch (Exception ex) {
    		
    	}
    	
    	
    	if(f != null && f.Event_Subject_Fix__c == true) {
    	
    	//if(l.size() >0 && l[0].Enabled__c == true) {
    	
		    	list<Event> EventList = [select id,post_code__c, whoid, whatid, accountid, event_status__c,subject from Event where id in :idList] ;
		    	string EventSubject = '' ;
		    	boolean skip = false ;
		    	list<Event> EventsToUpdate = new list<Event>() ;
		    	for(Event e : EventList) {
		    		skip = false ;
		    		EventSubject = '' ;
		    		
		    		/* Postcode*/
		    		if(leadMap.get(e.whoid) != null && leadMap.get(e.whoid).Postalcode != null) {
		    			EventSubject += leadMap.get(e.whoid).Postalcode + '|' ;
		    		} 
			    		else if(e.post_code__c != null) {
			    			EventSubject += e.post_code__c + '|' ;	
			    		}
			    			else if(AccountMap.get(e.accountId) != null && AccountMap.get(e.AccountId).post_code__c != null) {
			    			EventSubject += AccountMap.get(e.AccountId).post_code__c + '|' ;	
			    		}
			    		else {
			    			skip = true ;
			    		}
		    		
		    		/* Company */
		    		if(leadmap.get(e.whoid) != null && leadMap.get(e.whoid).company != null) {
		    			EventSubject += leadMap.get(e.whoid).company + '|' ;
		    		}
		    		
		    		else if(OpportunityMap.get(e.whatid) != null && Opportunitymap.get(e.whatid).name != null) {
		    			EventSubject += OpportunityMap.get(e.whatid).name + '|' ;
		    		}
		    		else if(e.accountid != null && accountmap.containsKey(e.accountid)) {
		    			EventSubject += accountmap.get(e.accountid).name + '|'  ;
		    		}
		    		else {
		    			skip = true ;
		    		}
		    		
		    		/* status */
		    		
		    		
		    		if(e.event_status__c == 'Confirmed') {
		    			EventSubject += e.event_status__c + '|' ;
		    		}
		    		else if(leadmap.get(e.whoid) != null &&
		    		
		    			 (leadmap.get(e.whoid).status == 'Approved' ||
		    			 	
		    			 	  leadmap.get(e.whoid).status == 'Rejected' ||
		    			  leadmap.get(e.whoid).status == 'Pended'  )
		    			 ) {
		    			EventSubject += leadmap.get(e.whoid).status + '|' ;
		    		}
		    		
		    		else if (leadmap.get(e.whoid) != null &&  leadmap.get(e.whoid).status == 'Data Quality' ) {
		    			EventSubject += 'To Be Approved|' ;
		    		}
		    		
		    		else if(e.whatid != null && (opportunitymap.get(e.whatid) != null || (e.accountid != null &&  accountmap.get(e.accountid) != null )) ) {
		    			EventSubject += 'Approved' + '|' ;
		    		}
		    		
		    		else {
		    			skip = true ;
		    		}
		    		
		    		
		    		
		    		/* Made Criteria */
		    		if(leadmap.get(e.whoid) != null && leadmap.get(e.whoid).Made_Criteria__c != null) {
		    			EventSubject += LeadMap.get(e.whoid).Made_Criteria__c ;
		    		}
		    		else if(Opportunitymap.get(e.whatid) != null && opportunitymap.get(e.whatid).made_Criteria__c != null) {
		    			EventSubject += OpportunityMap.get(e.whatid).Made_Criteria__c ;
		    		}
		    		else {
		    			skip = true ;
		    		}
		    		
		    		
		    		if(skip == false && e.Subject != EventSubject) {
		    			
		    			EventsToUpdate.add(new Event(id=e.id,subject=EventSubject)) ;
		    		}
		    		
		    	}
		    	
		    	if(EventsToUpdate.size() != 0) {
		    		update EventsToUpdate ;
		    	}
    	
    	}
    	 
    }
    
    public void onAfterUpdate(final List<Event> oldObjects, final Map<Id, Event> oldObjectsMap,
                              final List<Event> newObjects, final Map<Id, Event> newObjectsMap) {
    	      
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Event> oldObjects, final Map<Id, Event> oldObjectsMap) {
		CIT_PH1_EventManager.restrictBDMtoDeleteEvents(oldObjects);
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    public void onAfterDelete(final List<Event> oldObjects, final Map<Id, Event> oldObjectsMap) {
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Event> newObjects, final Map<Id, Event> newObjectsMap) {
    }
    
}