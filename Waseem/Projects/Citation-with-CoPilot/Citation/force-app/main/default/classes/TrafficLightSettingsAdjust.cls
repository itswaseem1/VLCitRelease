public with sharing class TrafficLightSettingsAdjust {
    public integer Light1RedThreshold {get;set;}
    public integer Light1AmberThreshold {get;set;}
    public integer Light2RedThreshold {get;set;}
    public integer Light2AmberThreshold {get;set;} 
    public boolean Light1TasksEnabled {get;set;}  
    public boolean Light2TasksEnabled {get;set;}  
    public boolean BronzeEnabled {get;set;}
    public boolean SilverEnabled {get;set;}
    public boolean GoldEnabled {get;set;}
    public boolean GoldPlusEnabled {get;set;}
    public boolean PlatinumEnabled {get;set;}
    public boolean BlankEnabled {get;set;}
    
    public boolean HS_Advice_30_month_renewals_only {get;set;}
	public boolean EL_HR_Advice_30_month_renewals_only {get;set;}

	public boolean hs_advice_non_auto_only {get;set;}
	public boolean EL_HR_advice_non_auto_only {get;set;}
    
    
    
    
    public  TrafficLightSettingsAdjust() {
    	TrafficLights__c tl = TrafficLights__c.getvalues('Standard') ;
    	 Light1RedThreshold = (Integer)tl.Light1RedThreshold__C ;
    	 Light1AmberThreshold = (Integer)tl.Light1AmberThreshold__C;
    	  Light2RedThreshold = (Integer)tl.Light2RedThreshold__C ;
    	 Light2AmberThreshold = (Integer)tl.Light2AmberThreshold__C;
    	 Light1TasksEnabled = tl.Light1TasksEnabled__c ;
    	 Light2TasksEnabled = tl.Light2TasksEnabled__c ;
    	 BlankEnabled = tl.EnableForBlanks__c ;
    	 BronzeEnabled = tl.EnableForBronze__c ;
    	 SilverEnabled = tl.EnableForSilver__c ;
    	 GoldEnabled = tl.EnableForGold__c ;
    	 GoldPlusEnabled = tl.EnableForGoldPlus__c ;
    	 PlatinumEnabled = tl.EnableForPlatinum__c ;
    	 
    	 HS_Advice_30_month_renewals_only = tl.HS_Advice_30_month_renewals_only__c ;
		 EL_HR_Advice_30_month_renewals_only = tl.EL_HR_Advice_30_month_renewals_only__c ;

		 hs_advice_non_auto_only = tl.hs_advice_non_auto_only__c ;
		 EL_HR_advice_non_auto_only = tl.EL_HR_advice_non_auto_only__c ;
    	 
    	
    	system.debug('----------->' +Light1RedThreshold) ;
    }
    
    
    /*
    public  TrafficLightSettingsAdjust(ApexPages.StandardController standardController) {
    	TrafficLights__c tl = TrafficLights__c.getvalues('Standard') ;
    	 Light1RedThreshold = (Integer)tl.Light1RedThreshold__C ;
    	 Light1AmberThreshold = (Integer)tl.Light1AmberThreshold__C;
    	  Light2RedThreshold = (Integer)tl.Light2RedThreshold__C ;
    	 Light2AmberThreshold = (Integer)tl.Light2AmberThreshold__C;
    	  Light1TasksEnabled = tl.Light1TasksEnabled__c ;
    	 Light2TasksEnabled = tl.Light2TasksEnabled__c ;
    	 
    	system.debug('----------->' +Light2RedThreshold) ;
    }
    */
   
    
    public void SaveSetting() {
    	TrafficLights__c tl = TrafficLights__c.getvalues('Standard') ;
    	tl.Light1RedThreshold__C = Light1RedThreshold ;
    	tl.Light1AmberThreshold__C = Light1AmberThreshold ;
    	
    		tl.Light2RedThreshold__C = Light2RedThreshold ;
    	tl.Light2AmberThreshold__C = Light2AmberThreshold ;
    	
    	tl.Light1TasksEnabled__c  = Light1TasksEnabled ;
    	tl.Light2TasksEnabled__c = Light2TasksEnabled;
    	
    	   tl.EnableForBlanks__c = BlankEnabled;
    	   tl.EnableForBronze__c = BronzeEnabled ;
    	   tl.EnableForSilver__c = SilverEnabled ;
    	   tl.EnableForGold__c = GoldEnabled ;
    	   tl.EnableForGoldPlus__c = GoldPlusEnabled ;
    	   tl.EnableForPlatinum__c = PlatinumEnabled ;
    	   
    	   tl.HS_Advice_30_month_renewals_only__c = HS_Advice_30_month_renewals_only ;
		   tl.EL_HR_Advice_30_month_renewals_only__c = EL_HR_Advice_30_month_renewals_only ;

		   tl.hs_advice_non_auto_only__c = hs_advice_non_auto_only ;
		   tl.EL_HR_advice_non_auto_only__c = EL_HR_advice_non_auto_only ;
    
    	
    	update tl ;
    	string strMessage = 'Saved' ;
				
				ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Info,strMessage) ;
			 	ApexPages.AddMessage(message) ;
    }
    
    
   
}