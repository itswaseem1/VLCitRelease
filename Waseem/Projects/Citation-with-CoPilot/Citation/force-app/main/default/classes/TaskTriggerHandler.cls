public  class TaskTriggerHandler {
    
    public static void AfterUpdateHandler(list<task> oldList, list<task> newList) {
        map<id,task> oldMap = new map<id,task>(oldList) ;
        //list<account> aList = new list<account>() ;
        //map<id,Account> aMap = new map<id,account>() ;
        account acc = new account() ;
        set<id> idSet = new set<id>() ;
        
        for(task t : newList) {
            idSet.add(t.accountid) ;
        }
        
        map<id,Account> aMap = new map<id,account>([select id, EL_HR_Advice_TrafficLight__c, EL_HR_Advice_Reset_date__c,HS_Advice_TrafficLight__c, HS_Advice_Reset_date__c,EL_HR_TrafficLight__c, EL_HR_Reset_date__c,HS_TrafficLight__c, HS_Reset_date__c from Account where id in :IdSet ]) ;
        
        
        
        for(task t : newList) {
            if((t.EL_HR_advice_task__c == true || t.HS_advice_task__c == true || t.EL_HR_task__c == true || t.HS_task__c == true) && oldmap.get(t.id).status != 'Completed' && t.status == 'Completed') {
                acc = null ;
                acc = amap.get(t.accountid) ;
                
                //acc.id = t.accountid ;
                //if(t.EL_HR_advice_task__c == true) {
                if(acc.EL_HR_Advice_TrafficLight__c != null && acc.EL_HR_Advice_TrafficLight__c != '') {
                    acc.EL_HR_Advice_TrafficLight__c = 'Green' ;
                    acc.EL_HR_Advice_Reset_date__c = date.today() ;                 
                }
                
                if(acc.HS_Advice_TrafficLight__c != null && acc.HS_Advice_TrafficLight__c != '') {
                    acc.HS_Advice_TrafficLight__c = 'Green' ;
                    acc.HS_Advice_Reset_date__c = date.today() ;                    
                }
                
                if(acc.EL_HR_TrafficLight__c != null && acc.EL_HR_TrafficLight__c != '') {
                    acc.EL_HR_TrafficLight__c = 'Green' ;
                    acc.EL_HR_Reset_date__c = date.today() ;                    
                }
                
                if(acc.HS_TrafficLight__c != null && acc.HS_TrafficLight__c != '') {
                    acc.HS_TrafficLight__c = 'Green' ;
                    acc.HS_Reset_date__c = date.today() ;                   
                }
                amap.put(t.accountid,acc) ;
            }
            
        }
        
        if(amap.values().size() > 0 ) {
            update amap.values() ; 
        }
    }
    
    public static void BDCCallCount(list<task> taskList) {
        set<id> leadid=new set<id>();
        list<id> lownerid=new list<id>();
        List<Lead> leadlist = new List<Lead>(); 
        for(Task t:taskList){
            String s1 = String.valueof(t.WhoId);
            if(s1 !=null && s1.startsWith('00Q')) 
            {              
                leadid.add(t.WhoId);
                system.debug('leadid'+leadid);
            }
        }
        map<id,Lead> ld;
        map<id,decimal> leadBDCcal = new map<id,decimal>();
        if(leadid.size()>0)
        { 
            ld = new map<id,lead>([select id,BDC_Calls__c,BDC__c from Lead where id = :leadid and IsConverted = False]);
             for(lead l:ld.values()){
             	lownerid.add(l.BDC__c);
             }             
            system.debug(lownerid);
            list<task> taskListq = [select id,ownerid,whoid from task where status='Completed' and subject like'Outbound Call%' and whoid=:leadid and ownerid=:lownerid];
            if(taskListq.size()>0){
                for(task tk: taskListq){
                    if(tk.ownerid == ld.get(tk.whoid).bdc__c){
                        if(leadBDCcal.containsKey(tk.whoid)){
                            decimal dc = leadBDCcal.get(tk.whoid); 
                            leadBDCcal.put(tk.whoid,dc+1);
                        }
                        else{
                            leadBDCcal.put(tk.whoid,1);
                        }
                        
                    }
                }
            }
            if(leadBDCcal.size()>0){
                system.debug('leadsize'+ld.size());
                for(Lead thisLead: ld.values())
                {
                    thisLead.BDC_Calls__c = leadBDCcal.get(thisLead.id);
					leadlist.add(thisLead);  
                }
            }    
            else{
                for(Lead dl: ld.values()){
                    lead tempL = new lead();
                    tempL.id = dl.id;
                    if(dl.BDC_Calls__c != null && dl.BDC_Calls__c > 0){
                        tempL.BDC_Calls__c = 0;
                        leadlist.add(tempL);
                    }
                    else if(dl.BDC_Calls__c != 0) {
                        tempL.BDC_Calls__c = 0;
                        leadlist.add(tempL);
                    }
                    
                }
                 
            }
        if(leadlist.size()>0){
            update leadlist;
        }
       } 
       
    }
    
    public static void updateSegmentation(list<task> taskList){
        Set<Id> caseids = new Set<Id>();
        //Id eltAdvicerecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
    	//Id hrCYJrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HR_CYJ').getRecordTypeId();
        for(Task t : taskList){
            If(t.whatId != Null && t.whatId.getsObjectType() == Case.sObjectType)
            	caseids.add(t.WhatId);
        }
        //Map<Id,Case> caseMap = new Map<Id, Case>();
        if(!caseids.isEmpty()){
              Map<Id,Case> caseMap = new Map<Id,Case>([Select Id, Account.S__c from Case where Id =: caseids AND (RecordType.Name = 'ELT Advice - Generic' OR RecordType.Name = 'HR-CYJ')]);
        		for(Task t : taskList){
                    if(caseMap.containsKey(t.WhatId) && caseMap.get(t.WhatId).Account.S__c != null){
                        t.Segmentation_Status__c = caseMap.get(t.WhatId).Account.S__c;
                    }            		
        	}
        }
      
    }
    
}