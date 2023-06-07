public with sharing class AccountLightsExt {
	
	public Account acc {get;set;}
	public string overall {get;set;}
	
	public AccountLightsExt(ApexPages.StandardController standardController){
		
		try {
				standardController.addFields(new List<String>{'id', 'name','HS_Advice_Reset_Date__c', 'EL_HR_Advice_Reset_Date__c', 'HS_Advice_TrafficLight__c', 'EL_HR_Advice_TrafficLight__c','Overall_Account_Status__c','HS_Advice_Calls__c','EL_HR_Advice_Calls__c','HS_Advice_Renewal_Days__c','EL_HR_Advice_Renewal_Days__c','HS_Advice_Renew_months__c','EL_HR_Advice_Renew_months__c','HS_Advice_Renewal_Type__c','EL_HR_Advice_Renewal_Type__c','cluster__c'}) ;
		
		}
		catch (Exception ex) {
			
		}
		// if (!Test.isRunningTest()) {
		//	standardController.addFields(new List<String>{'id', 'name','HS_Advice_Reset_Date__c', 'EL_HR_Advice_Reset_Date__c', 'HS_Advice_TrafficLight__c', 'EL_HR_Advice_TrafficLight__c','Overall_Account_Status__c','HS_Advice_Calls__c','EL_HR_Advice_Calls__c'}) ;
		// }
		acc =  (account)standardController.getRecord();
		
		overall = 'Green' ;
			
			if(acc.HS_Advice_TrafficLight__c == 'Amber' || acc.EL_HR_Advice_TrafficLight__c == 'Amber' ) {
				overall = 'Amber' ;
			}
			
			
			if(acc.HS_Advice_TrafficLight__c == 'Red' || acc.EL_HR_Advice_TrafficLight__c == 'Red' ) {
				overall = 'Red' ;
			}
		
	}
	
	
	public AccountLightsExt() {
		Id AccountId = apexpages.currentpage().getparameters().get('id');
		string AccountExternalId = apexpages.currentpage().getparameters().get('accountcode');
		try {
			if(AccountId != null) {
				acc = [select id, name,HS_Advice_Reset_Date__c, EL_HR_Advice_Reset_Date__c, HS_Advice_TrafficLight__c, EL_HR_Advice_TrafficLight__c,Overall_Account_Status__c,HS_Advice_Calls__c,EL_HR_Advice_Calls__c,HS_Advice_Renewal_Days__c,EL_HR_Advice_Renewal_Days__c,HS_Advice_Renew_months__c,EL_HR_Advice_Renew_months__c,HS_Advice_Renewal_Type__c,EL_HR_Advice_Renewal_Type__c,cluster__C  from account where id = :AccountID] ;
			}
			else if( AccountExternalId != null) {
				acc = [select id, name,HS_Advice_Reset_Date__c, EL_HR_Advice_Reset_Date__c,  HS_Advice_TrafficLight__c, EL_HR_Advice_TrafficLight__c,Overall_Account_Status__c,HS_Advice_Calls__c,EL_HR_Advice_Calls__c, HS_Advice_Renewal_Days__c,EL_HR_Advice_Renewal_Days__c,HS_Advice_Renew_months__c,EL_HR_Advice_Renew_months__c,HS_Advice_Renewal_Type__c,EL_HR_Advice_Renewal_Type__c,cluster__c from account where Account_External_Id__c = :AccountExternalId] ;
			}
			
			overall = 'Green' ;
			
			if(acc.HS_Advice_TrafficLight__c == 'Amber' || acc.EL_HR_Advice_TrafficLight__c == 'Amber' ) {
				overall = 'Amber' ;
			}
			
			
			if(acc.HS_Advice_TrafficLight__c == 'Red' || acc.EL_HR_Advice_TrafficLight__c == 'Red' ) {
				overall = 'Red' ;
			}
			
		}
		catch (Exception ex) {
			
		}
		
	}
	
    
}