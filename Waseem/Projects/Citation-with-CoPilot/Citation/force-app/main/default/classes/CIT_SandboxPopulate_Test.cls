@isTest
private class CIT_SandboxPopulate_Test {
    
	@testSetup static void setup() {        
        FM_Integration__c f = new FM_Integration__c() ;
        f.Http_Callout_Endpoint__c = 'UAT URL' ;
        f.name='Host' ;
        insert f ;       

		pricebook2 pb = new pricebook2(name='tst',isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
		insert pb ;
	}

    static testMethod void NVMSettingsTest() {
        
        NVMContactWorld__Settings__c settingscurrent = NVMContactWorld__Settings__c.getOrgDefaults() ;
        insert settingscurrent ;

        test.starttest() ;
        CIT_SandboxPopulate.adjustNVMSettings() ;
        test.stoptest() ;

        NVMContactWorld__Settings__c settings = NVMContactWorld__Settings__c.getOrgDefaults() ;
       
        system.assertEquals(string.valueof(System.label.NVM_ContactWorld_Test_API_Auth_Token),settings.NVMContactWorld__clientSecret__c) ;
        system.assertEquals(string.valueof(System.label.NVM_ContactWorld_Test_Account_Key),settings.NVMContactWorld__clientId__c) ;
        system.assertEquals(string.valueof(System.label.NVM_ContactWorld_Test_URL),settings.NVMContactWorld__baseURL__c) ;

    }

    static testMethod void insertAccountsWithContactsTest() {
        test.starttest() ;
        Test.testSandboxPostCopyScript(new CIT_SandboxPopulate(),null,null,null) ;
        test.stoptest() ;

        system.assertEquals(10,[select id from account].size()) ;
        system.assertEquals(10,[select id from contact].size()) ;
    }

    static testMethod void FreezeUsersTest() {

        Profile FreezeProfile = [select id from Profile where name = 'Citation Data Quality & Diary Mgmt (inc MI)'] ;

        user UserToFreeze = new user(ProfileId = FreezeProfile.id , 
                            username = 'TestFreeze@citation.co.uk', 
                            lastname = 'TestUser',
                            email = 'testuser@citation.co.uk',
                            alias = 'pbtest', isactive = true ,
                            timezonesidkey = 'Europe/London',
                            localeSidKey = 'en_GB',
                            EmailEncodingKey = 'ISO-8859-1',
                            LanguageLocaleKey = 'en_US'
                    ) ;

        

        Profile NoFreezeProfile = [select id from Profile where name = 'Citation Data Admin'] ;
 
        user UserNotToFreeze = new user(ProfileId = NoFreezeProfile.id , 
                            username = 'TestNoFreeze@citation.co.uk', 
                            lastname = 'TestUser',
                            email = 'testuser@citation.co.uk',
                            alias = 'pbtest', isactive = true ,
                            timezonesidkey = 'Europe/London',
                            localeSidKey = 'en_GB',
                            EmailEncodingKey = 'ISO-8859-1',
                            LanguageLocaleKey = 'en_US'
                    ) ;

        insert UserToFreeze  ; 
        insert UserNotToFreeze ;

        test.starttest() ;
        Test.testSandboxPostCopyScript(new CIT_SandboxPopulate(),null,null,null) ;
        test.stoptest() ;

        UserLogin FreezeCheck = new UserLogin() ;
        FreezeCheck = [select isFrozen from UserLogin where UserId = :UserToFreeze.id] ;
        UserLogin NoFreezeCheck = new UserLogin() ;
        NoFreezeCheck = [select isFrozen from UserLogin where UserId = :UserNotToFreeze.id] ;

        system.assertEquals(true,FreezeCheck.isFrozen) ;
        system.assertEquals(false,NoFreezeCheck.isFrozen) ;
    }

    static testMethod void ReactivateDevUsersTest() {

        Profile DataAdmin = [select id from Profile where name = 'Citation Data Admin'] ;
 
        user UserToReactivate = new user(ProfileId = DataAdmin.id , 
                            username = 'TestReactivate@citation.co.uk', 
                            lastname = 'TestUser',
                            IsActive = false ,
                            developer__c = true,
                            email = 'testuser@citation.co.uk',
                            alias = 'pbtest', 
                            timezonesidkey = 'Europe/London',
                            localeSidKey = 'en_GB',
                            EmailEncodingKey = 'ISO-8859-1',
                            LanguageLocaleKey = 'en_US'
                    ) ;
        Insert UserToReactivate ;

        test.starttest() ;
        Test.testSandboxPostCopyScript(new CIT_SandboxPopulate(),null,null,null) ;
        test.stoptest() ;
       
        system.assertEquals(true,[select id, isactive from user where id = :UserToReactivate.id].IsActive) ;        
    }

    

     static testMethod void RepointCustomSettingsTest() {

        test.starttest() ;
        Test.testSandboxPostCopyScript(new CIT_SandboxPopulate(),null,null,null) ;
        test.stoptest() ;

        string FMIntegrationUAT = string.valueof(System.label.FM_Integration_UAT_URL) ;

        FM_Integration__c postRefreshFMIntegration = new FM_Integration__c() ;
        postRefreshFMIntegration =  FM_Integration__c.getvalues('Host') ;

        system.assertEquals(FMIntegrationUAT,postRefreshFMIntegration.Http_Callout_Endpoint__c) ;
    }
}