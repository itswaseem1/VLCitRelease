@isTest
public with sharing class CIT_PH1_EmailHandler_Test {
	@isTest
	static void EmailHandler_SendEmail_checkEmail(){
		Test.startTest();
			CWS_Integration__c integrationSetting = CWS_Integration__c.getValues('Host');
  
		  	if(integrationSetting == null) {
		    	integrationSetting = new CWS_Integration__c(Name= 'Host');
		    	integrationSetting.RemoteServer__c = 'Test';
		    	integrationSetting.Error_Email__c = 'test@test.co.uk';
		    	insert integrationSetting;
		  	}
    
			CIT_PH1_EmailHandler.sendMail('Test Message', 'Test JSON');
		Test.stopTest();
	}
}