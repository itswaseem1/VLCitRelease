public with sharing class AccountLightUpdateHandler {
    
    @future
    public static void ProcessAccountLightUpdates(list<id> idList) {
    	
    	TrafficLights__c tl = TrafficLights__c.getvalues('Standard') ;
    	
    	
    	
    	list<Account_Light_Update__c> ALUList = [Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
    	
    		ClientId__c, HS_Calls__c, PEL_Calls__c, HS_Visits__c, PEL_Visits__c,
    		HS_Contract__c, 
    		PEL_Contract__c, 
    		Combined_Contract__c, 
    		Combined_Advice_Only__c, 
    		System__c, 
    		PEL_Advice_and_Indemnity_Only__c, 
    		HS_Advice_Only__c, 
    		PEL_Advice_Only__c, 
    		Combined_Advice_and_Indemnity_Only__c, 
    		HS_Advice_and_Indemnity_Only__c, 
    		Segmentation__c, 
    		Board_Report_Classification__c, 
    		Industry__c, 
    		Months_Til_Renewal__c, 
    		Renewal_Type__c ,Renewal_Days__c
    		
    		FROM Account_Light_Update__c where id in :idList] ;
    		
    		system.debug('List to Process-------' + ALUList) ;
    		
    	set<decimal> ClientIds = new set<decimal>() ;
    	
    	for(Account_Light_Update__c ALU : ALUList) {
    		ClientIds.add((decimal.valueof(ALU.ClientId__c))) ;
    	}
    	
    	List<Account> AccountList = [Select EL_HR_Advice_Renewal_Type__c,HS_Advice_Renewal_Type__c,EL_HR_Advice_Renewal_Days__c,HS_Advice_Renewal_Days__c,EL_HR_Advice_Renew_Months__c, HS_Advice_Renew_Months__c, Account_External_Id__c, Shorthorn_Id__c, HS_Advice_TrafficLight__c, HS_Advice_Reset_Date__c, EL_HR_Advice_Calls__c, HS_Advice_Calls__c, EL_HR_Advice_TrafficLight__c, EL_HR_Advice_Reset_Date__c,
				    	EL_HR_Renewal_Type__c, HS_Renewal_Type__c, 
				
						EL_HR_Renew_Months__c, 
						HS_Renew_Months__c, 
						
						HS_TrafficLight__c, 
						HS_Reset_Date__c, 
						
						EL_HR_Visits__c, 
						HS_Visits__c, 
						
						EL_HR_TrafficLight__c, 
						EL_HR_Reset_Date__c 
    	
    			 FROM Account where shorthorn_id__c in :ClientIds ] ;
    	
    	system.debug('Account List ----> ' + AccountList) ;
    	
    	map<decimal,account> AccountMap = new map<decimal,account>() ;
    	for(Account a : accountList) {
    		accountmap.put(a.shorthorn_id__c,a) ;
    	}
    	
    	system.debug(accountmap) ;
    	
    	Account acc = new account() ;
    	for(Account_Light_Update__c ALU : ALUList) {
    		system.debug(ALU.clientid__c) ;
    		acc = accountmap.get(decimal.valueof(ALU.clientid__c)) ;
    		system.debug('Did we find a record?---->' + acc) ;
    		if(acc != null) {
	    		if(ALU.PEL_Calls__C != null) {
	    			acc.EL_HR_Advice_Calls__c = ALU.PEL_Calls__C ;
	    		}
	    		
	    		if(ALU.HS_Calls__c != null) {
	    			acc.HS_Advice_Calls__c = ALU.HS_Calls__c ;
	    		}
	    		
	    		if(ALU.PEL_visits__C != null) {
	    			acc.EL_HR_Visits__c = ALU.PEL_visits__C ;
	    		}
	    		
	    		if(ALU.HS_Calls__c != null) {
	    			acc.HS_visits__c = ALU.HS_visits__c ;
	    		}
	    		
	    		
	    		
	    		
	    		ALu.status__c = 'Processed' ;
	    		
	    		acc.Board_Report_Classification__c = ALU.Board_Report_Classification__c ;
	    		
	    		system.debug('Checking Contract type') ;
	    		
	    		
	    		
	    		
	    		if(ALU.HS_Contract__C > 0 || ALU.Combined_Contract__c > 0 || ALU.Combined_Advice_Only__c > 0 || ALU.HS_Advice_Only__C > 0 || ALU.Combined_Advice_and_Indemnity_Only__c > 0 || ALU.HS_Advice_and_Indemnity_Only__c > 0) {
	    			
	    			/* do visits for where not advice only */
	    			if(ALU.HS_Contract__C > 0 || ALU.Combined_Contract__c > 0 ) {	    				
	    				acc.HS_Renewal_TYpe__c = ALU.Renewal_type__c ;
	    				if(ALU.Months_Til_Renewal__c < acc.HS_Renew_Months__c || acc.HS_Renew_Months__c == null) {
	    					acc.HS_Renew_Months__c = ALU.Months_Til_Renewal__c ;
	    				}
	    				
	    				
	    				if(acc.HS_Reset_Date__c < date.today().adddays(-90) || acc.HS_Reset_Date__c == null) {
		    				system.debug('No Rst or old reset') ;
		    				acc.HS_TrafficLight__c = 'Green' ;
		    				
		    				if (ALU.HS_Visits__c  <= tl.Light3AmberThreshold__c) {
		    					acc.HS_TrafficLight__c = 'Amber' ;
		    					
		    				} 
		    				if(ALU.HS_Visits__c  <= tl.Light3RedThreshold__c) {
		    					acc.HS_TrafficLight__c = 'Red' ;		    					
		    				} 	    				
	    				}   				
	    				
	    			
	    			}
	    			
	    			/* do visits for where not advice only */
	    			
	    			acc.HS_Advice_Renewal_Days__c = ALU.renewal_days__c ;
	    			acc.HS_Advice_Renewal_TYpe__c = ALU.Renewal_type__c ;
	    			system.debug('Has Contract HS') ;
	    			if(ALU.Months_Til_Renewal__c < acc.HS_Advice_Renew_Months__c || acc.HS_Advice_Renew_Months__c == null) {
	    				acc.HS_Advice_Renew_Months__c = ALU.Months_Til_Renewal__c ;
	    			}
	    			if(acc.HS_Advice_Reset_Date__c < date.today().adddays(-90) || acc.HS_Advice_Reset_Date__c == null) {
	    				system.debug('No Rst or old reset') ;
	    				acc.HS_Advice_TrafficLight__c = 'Green' ;
	    				
	    				if (ALU.HS_Calls__c  <= tl.Light1AmberThreshold__c) {
	    					acc.HS_Advice_TrafficLight__c = 'Amber' ;
	    					
	    				} 
	    				if(ALU.HS_Calls__c  <= tl.Light1RedThreshold__c) {
	    					acc.HS_Advice_TrafficLight__c = 'Red' ;
	    					
	    				} 
	    				
	    			}
	    		}
    		
    		
    		
	    		
	    		
	    		if(ALU.PEL_Contract__C > 0 || ALU.Combined_Contract__c > 0 || ALU.Combined_Advice_Only__c > 0 || ALU.PEL_Advice_Only__C > 0 || ALU.Combined_Advice_and_Indemnity_Only__c > 0 || ALU.PEL_Advice_and_Indemnity_Only__c > 0) {
	    		
	    			/* do visits for where not advice only */
	    			if(ALU.PEL_Contract__C > 0 || ALU.Combined_Contract__c > 0) {
	    				
	    				acc.EL_HR_Renewal_TYpe__c = ALU.Renewal_type__c ;
	    				if(ALU.Months_Til_Renewal__c < acc.EL_HR_Renew_Months__c || acc.EL_HR_Renew_Months__c == null) {
	    					acc.el_hr_Renew_Months__c = ALU.Months_Til_Renewal__c ;
	    				}
	    				
	    				
	    				if(acc.EL_HR_Reset_Date__c < date.today().adddays(-90) || acc.EL_HR_Reset_Date__c == null) {
		    				system.debug('No Rst or old reset') ;
		    				acc.EL_HR_TrafficLight__c = 'Green' ;
		    				
		    				if (ALU.PEL_Visits__c  <= tl.Light4AmberThreshold__c) {
		    					acc.EL_HR_TrafficLight__c = 'Amber' ;
		    					
		    				} 
		    				if(ALU.PEL_Visits__c  <= tl.Light4RedThreshold__c) {
		    					acc.EL_HR_TrafficLight__c = 'Red' ;		    					
		    				} 	    				
	    				}   				
	    				
	    				
	    				
	    				
	    			}
	    			
	    			/* do visits for where not advice only */
	    		
	    			acc.EL_HR_Advice_Renewal_Days__c = ALU.renewal_days__c ;
	    			acc.EL_HR_Advice_Renewal_TYpe__c = ALU.Renewal_type__c ;
	    			if(ALU.Months_Til_Renewal__c < acc.EL_HR_Advice_Renew_Months__c || acc.EL_HR_Advice_Renew_Months__c  == null) {
	    				acc.EL_HR_Advice_Renew_Months__c = ALU.Months_Til_Renewal__c ;
	    			}
	    			
	    			if(acc.EL_HR_Advice_Reset_Date__c < date.today().adddays(-90) || acc.EL_HR_Advice_Reset_Date__c == null) {
	    				
	    				acc.EL_HR_Advice_TrafficLight__c = 'Green' ;
	    				
	    				if (ALU.PEL_Calls__c  <= tl.Light2AmberThreshold__c) {
	    					acc.EL_HR_Advice_TrafficLight__c = 'Amber' ;
	    				} 
	    				if(ALU.PEL_Calls__c  <= tl.Light2RedThreshold__c) {
	    					acc.EL_HR_Advice_TrafficLight__c = 'Red' ;
	    				} 
	    				
	    			}
	    		}
	    		
	    		
	    		accountmap.put(acc.shorthorn_id__c,acc) ;
	    		
	    		acc=  null ;
    		}
    	}
    	
    	system.debug(accountmap.values()) ;
    	try {
    	update accountmap.values() ;
    	 delete ALUList ;
    	}
    	catch (Exception ex) {
    		for(Account_Light_Update__c ALU : ALUList) {
    		ALU.status__c = 'Error' ;
    		}
    		update ALUList ;
    	}
    	
    	
    	
    	//
    }
   
    
}