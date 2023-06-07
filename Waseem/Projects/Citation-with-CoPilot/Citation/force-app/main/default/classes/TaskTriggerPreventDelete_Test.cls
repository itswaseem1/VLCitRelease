@isTest
public class TaskTriggerPreventDelete_Test 
{
    static testmethod void addErrorCitationUser()
    {
    	Profile citationProfile = [SELECT Id FROM Profile WHERE Name='S360 ELT Advice'limit 1];
    	User citationUser = new User(
            Alias = 'standt',
            Email = 'standarduser@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'citationUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = CitationProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'citationFSLTestUser@testorg.com',
            UserPermissionsKnowledgeUser = True,
            IsActive = True
           
        );
    	insert citationUser;
		
		PermissionSet setupPermSet = [select id from PermissionSet where Name ='View_Setup_and_Configuration' limit 1];
		PermissionSetAssignment     SetupPermSetAssig = new PermissionSetAssignment();
		SetupPermSetAssig.PermissionSetId = setupPermSet.id;
		SetupPermSetAssig.AssigneeId = citationUser.id;
		insert  SetupPermSetAssig;

		Test.startTest();
    	System.runAs(citationUser) 
    	{   
    		Task tskRecord = new Task(Subject='testTask');        
  			insert tskRecord;
        	try
        	{
            	delete tskRecord;
        	}
        	catch(DMLexception e)
        	{
            	System.assert(e.getMessage().contains('Task cannot be deleted'));
        	}
    	}
        Test.stopTest();
    }

	static testmethod void deleteiHASCOUserTask()
    {
    	Profile iHASCOProfile = [SELECT Id FROM Profile WHERE Name='iHASCO NBM' limit 1];
    	User iHASCOUser = new User(
            Alias = 'standt',
            Email = 'standarduser@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'iHASCOUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = iHASCOProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'iHASCOTestUser@testorg.com',
            IsActive = True
           
        );
    	insert iHASCOUser;
		Test.startTest();
    	System.runAs(iHASCOUser) 
    	{   
    		Task tskRecord = new Task(Subject='testTask');        
  			insert tskRecord;
        	delete tskRecord;
			system.assertEquals(0,Database.query('select id from task').size());
    	}
        Test.stopTest();
    }
}