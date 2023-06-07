global class CIT_SandboxPopulate implements SandboxPostCopy {
	
	global void runApexClass(SandboxContext context) {	
		createDataSetupRecords() ;	
		adjustNVMSettings() ;	
		adjustFMIntegrationSetting() ;	
		FreezeUsers() ;
		ReactivateDevUsers() ;
		insertAccountsWithContacts(context) ;
	}

	public void insertAccountsWithContacts(SandboxContext context) {
    	
    	list<account> accountList = new list<Account>() ;
    	List<contact> contactList = new list<contact>() ;
    	
    	for ( integer i = 1; i <= 10; i++) {
    		accountList.add( new account(Name = getInstance() + ' - ' + context.sandboxName() + ' SBAccount ' + i,Account_External_Id__c = 'SBAccount ' + i)) ;
    		contactList.add(new contact(lastname = getInstance() + ' - ' + context.sandboxName() + ' SBContact ' + i,account = new account(Account_External_Id__c ='SBAccount ' + i ))) ;
    	}
    	
    	insert AccountList ;
    	insert contactList ;
    }   

		@future
		public static void FreezeUsers() {
    	List<UserLogin> users = [SELECT IsFrozen,UserId FROM UserLogin WHERE UserId IN 
				(SELECT Id FROM User
					WHERE Profile.Name != 'System Administrator' 
						AND Profile.Name != 'API User'
						AND Profile.Name != 'Citation Data Admin'
						AND Profile.Name != 'B2BMA Integration User'	
						AND Profile.name != 'Pardot Connector'
				 		AND Profile.name != 'Sales Insights Integration User'
						AND IsActive=True) 
						AND UserId != :UserInfo.getUserId()];

		 for (UserLogin ul : users) { ul.isFrozen = True; }
	
		 update users;
    }

		@future
    public static void ReactivateDevUsers() {
    	
    	list<User> UsersToActivate = [select id, isactive from user where developer__C = true and isactive = false ] ;
    	for(user u : USersToActivate) {
    		u.isactive = true ;
    	}

        if(UsersToActivate.size() >0 ) {
            list<User> userListToDeactivate = [select id,isactive, username, lastlogindate, usertype from user where  usertype ='standard' and  developer__C = false and License_Type__c = 'Salesforce' and isactive = true order by lastlogindate limit :UsersToActivate.size()] ;
            
            for(user u : userListToDeactivate) {
                u.isactive = false ;
            }

            update userListToDeactivate ;
            update UsersToActivate ;
        } 
    }

	public void createDataSetupRecords() {
		Task_Reassign__c t = new Task_Reassign__c() ;
		insert t ;
	}

	 @future
    public static void adjustNVMSettings()  {
        
        NVMContactWorld__Settings__c settings = NVMContactWorld__Settings__c.getOrgDefaults() ;

        settings.NVMContactWorld__clientSecret__c = string.valueof(System.label.NVM_ContactWorld_Test_API_Auth_Token);
        settings.NVMContactWorld__clientId__c = string.valueof(System.label.NVM_ContactWorld_Test_Account_Key)  ;
        settings.NVMContactWorld__baseURL__c = string.valueof(System.label.NVM_ContactWorld_Test_URL)  ;

        upsert settings ;
    }
    
    @future
    public static void adjustFMIntegrationSetting() {
        string FMIntegrationUAT = string.valueof(System.label.FM_Integration_UAT_URL) ;
		
		FM_Integration__c postRefreshFMIntegration = new FM_Integration__c() ;
	    postRefreshFMIntegration =  FM_Integration__c.getvalues('Host') ;
		if(postRefreshFMIntegration != null) 
			{
				postRefreshFMIntegration.Http_Callout_Endpoint__c = FMIntegrationUAT ;
				update postRefreshFMIntegration ;
			}
    }	
    
  public string getInstance() {
			string UrlInstance = System.URL.getSalesforceBaseURL().getHost(); 
			string[] instance = urlInstance.split('\\.') ;
			return(instance[0]) ;
		}
    
}