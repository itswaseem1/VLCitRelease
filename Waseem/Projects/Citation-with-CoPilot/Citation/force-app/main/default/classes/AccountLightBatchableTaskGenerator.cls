global class AccountLightBatchableTaskGenerator implements Database.Batchable<Account>, schedulable {
	 
	 
	 /*
	 need a class per set of lights...  or to know what lights to create tasks for each month!
	 
	 end of MARCH - H&S & EL/HR advice tasks
	 
	 also,  need to adjust query not to generate tasks for accounts who already have a task? - or create an escalation task?
	 
	 */
	public list<user> AdminuserList = new list<user>() ;
	public  list<Cluster__c> ClusterList = new list<cluster__c>() ;
	public  map<string,user> ClusterUserMap = new map<string,user>() ;
	public   TrafficLights__c t1 = new TrafficLights__c() ; 	
	public  user u = new user() ;
	
    global AccountLightBatchableTaskGenerator() {
    	
    }
    
    global void execute(SchedulableContext sc) {
   	 database.executebatch(this,25) ;
   }
   
    
    global Iterable<Account> start(Database.BatchableContext BC) {
   	   //t1 = new TrafficLights__c() ; 	
   
    	  
   	  string strSOQL = '' ;    	  
   	  strSOQL += 'Select id,name,HS_Advice_Renewal_Days__c,EL_HR_Advice_Renewal_Days__c,HS_Advice_Renew_months__c,EL_HR_Advice_Renew_months__c,HS_Advice_Renewal_Type__c,EL_HR_Advice_Renewal_Type__c, cluster__c, hs_advice_trafficlight__c, el_hr_advice_trafficlight__c ' ;
   	  
   	    strSOQL += ', (select id from tasks where status <> \'Completed\' and (EL_HR_Task__c = true or hs_task__c = true or el_hr_advice_task__c = true or hs_advice_task__c = true)) ' ;
   	
   	  strSOQL += ' from account where ' ;
   	//  strSOQL += '( ' ;
   	  strSOQL += '(     (HS_Advice_TrafficLight__c = \'Red\' and  (HS_Advice_Reset_Date__c = null or HS_Advice_Reset_Date__c < last_n_days:90))    ' ;
   	  
   	  strSOQL += ' or (EL_HR_Advice_TrafficLight__c = \'Red\'  and  (EL_HR_Advice_Reset_Date__c = null or EL_HR_Advice_Reset_Date__c < last_n_days:180) )      ) ' ;
   	  
   	 // strSOQL += ') and id = \'0019E00000ZndDBQAZ\' ' ;
   	 strSOQL += ' order by name ' ;
   	   list<Account> accountList = database.query(strSOQL) ;
   	   
   	   
   	   
   	   return accountList ;
   	   
    }
    
     global void execute(Database.BatchableContext BC, List<Account> recs) {
     	
     	 RecordType recType = [Select id from recordtype where name = 'Client Relations Task Record Type' limit 1] ;
     	 AdminuserList = [select id from user where title = 'Client Relations Manager' and isactive = true limit 1] ;
			
			if (AdminuserList.size() <> 0 ) {
				u = Adminuserlist[0] ;
			}
			//This apex jobs is not in use so we can remove this cluster reference if needed jus kept here so when scheduled the batch doesn't abend bcoz of task owner
			ClusterList = [select id,name, Owner__c from Cluster__c] ; 
			
			for (Cluster__c c : ClusterList) {
				if(c.Owner__c != null) {
					ClusterUsermap.put(c.name,new user(id=c.Owner__c)) ;
					
				}
			}
			
	    t1 = TrafficLights__c.getvalues('Standard') ;
	    
	    system.debug(t1) ;
				  
    	list<task> tList = new list<task>() ;
    	
    	 if(recs.size() >0) {
    		task t = new task() ;
    	 	boolean newtask = false ;
	    	for(Account acc : recs) {
	    		t = null ;
    	 			t = new task() ;
    	 			t.recordTypeId = recType.id ;
    	 			t.activitydate = date.today().adddays(5) ;
    	 			t.subject = 'Client Healthscore task' ;
    	 			t.whatid = acc.id ;
    	 			//set start flags 
    	 			t.hs_advice_task__C = true ;
    	 			t.el_hr_advice_task__C = true ;
    	 			
    	 			// check for existing open Healthscore tasks
		    	 			if(acc.tasks.size() > 0) {
		    	 					t.hs_advice_task__C = false ;
    	 							t.el_hr_advice_task__C = false ;
		    	 			}
    	 			
    	 			//check hs parameters
    	 			if(t1.Light1TasksEnabled__c == true) {
    	 				if(acc.hs_advice_trafficlight__c == '' || acc.hs_advice_trafficlight__c == null || acc.hs_advice_trafficlight__c == 'Green'|| acc.hs_advice_trafficlight__c == 'Amber') {
    	 					t.hs_advice_task__c = false ;
    	 				}
    	 				
    	 				if(t1.HS_Advice_30_month_renewals_only__c && t.hs_advice_task__c == true) {
    	 					//if(acc.HS_Advice_Renew_months__c > 30) {
    	 					if(acc.HS_Advice_Renew_months__c < 9 || acc.HS_Advice_Renew_months__c > 24) {
		    	 				
    	 						t.hs_advice_task__c = false ;
    	 						system.debug('Failed on HS renew months') ;
    	 					}
    	 				}
    	 				
    	 				if(t1.hs_advice_non_auto_only__c == true && t.hs_advice_task__c == true ) {
    	 					if(acc.HS_Advice_Renewal_Type__c != 'Non-Auto') {
    	 						t.hs_advice_task__c = false ;
    	 						system.debug('Failed on HS non auto') ;
    	 					}
    	 				}
    	 			} // end if ligth1 task enabled
    	 				else {
    	 					system.debug('failed on HS tasks disabled') ;
    	 					t.hs_advice_task__c = false ;
    	 				}
    	 				
    	 				
    	 			//check hs parameters
    	 			if(t1.Light2TasksEnabled__c == true) {
    	 				
    	 				if(acc.el_hr_advice_trafficlight__c == '' || acc.el_hr_advice_trafficlight__c == null || acc.el_hr_advice_trafficlight__c == 'Green' || acc.el_hr_advice_trafficlight__c == 'Amber') {
    	 					t.el_hr_advice_task__c = false ;
    	 				}
    	 				if(t1.EL_HR_Advice_30_month_renewals_only__c && t.EL_HR_advice_task__c == true) {
    	 					//if(acc.EL_HR_Advice_Renew_months__c > 30) {
    	 					if(acc.EL_HR_Advice_Renew_months__c < 9 || acc.EL_HR_Advice_Renew_months__c  > 24) {
		    	 			
    	 						t.EL_HR_advice_task__c = false ;
    	 						system.debug('Failed on EL/HR renew months') ;
    	 					}
    	 				}
    	 				
    	 				if(t1.EL_HR_advice_non_auto_only__c == true && t.EL_HR_advice_task__c == true) {
    	 					if(acc.EL_HR_Advice_Renewal_Type__c != 'Non-Auto') {
    	 						t.EL_HR_advice_task__c = false ;
    	 						system.debug('Failed on EL/HR non auto ') ;
    	 						
    	 					}
    	 				}
    	 			} // end if light2 task enabled
    	 				else {
    	 					t.EL_HR_advice_task__c = false ;
    	 					system.debug('failed on task disabled' ) ;
    	 				}
    	 			
    	 			//if any params = true, generate and add task
    	 			if(t.hs_advice_task__C == true || t.el_hr_advice_task__c == true) {
    	 				
                        t.ownerid = u.id ;
                        
    	 				if(Clusterusermap.get(acc.cluster__c) != null) {
							t.ownerid = clusterusermap.get(acc.cluster__c).id ;
							
								}
								
    	 				tlist.add(t) ;
    	 				
    	 			} // end if any task flags are true
	    		
	    		
	    	} // end for accounts
    	 } // end if recs size > 0
    	
    	if(tlist.size() >0) {
    		insert tList ;
    	}
    	 
    	
    }
    
    global void finish(database.batchableContext BC) {
    	
    }
    
}