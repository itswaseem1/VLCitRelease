@isTest
private class TriggerNVMCallSummaryHandlerTest {
	
	@TestSetUp
    static void setData(){
        List<Task> taskLead = TestDataFactory.generateTask_Lead('Kumar','Citation',3,true);
       	User u = newUser();
       	insert u;
       	User curUser = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
       	System.runAs(u){
            PermissionSet perset = [SELECT Id FROM PermissionSet WHERE Name='Lead_Object_Executive_Access'];
       	    insert new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=perset.Id);
       	}

		// create dial list
		List<NVMConnect__DialList__c> diallistToUpdate = new List<NVMConnect__DialList__c>();
		for(Integer i = 0; i < taskLead.size(); i++){
			NVMConnect__DialList__c  dlist = new NVMConnect__DialList__c();
			dlist.Name = 'test' + i;
			dlist.Alert_volume__c = 2;
			dlist.NVMConnect__Mode__c = 'Preview';
			dlist.NVMConnect__Active__c = true;
			diallistToUpdate.add(dlist);
		}
		insert diallistToUpdate;

		List<Task> tasksToUpdate = new List<Task>();
		Integer counter = 0;
		for(Task record: taskLead){
			record.NVMConnect__DialList__c = diallistToUpdate[counter].Id;
			tasksToUpdate.add(record);
			++counter;
		}

		update tasksToUpdate;
    }

	
    static testMethod User newUser(){
        Profile pro = [SELECT Id FROM Profile WHERE Name='Citation Data Quality & Diary Mgmt (inc MI)' LIMIT 1];
        User u = new User(
            ProfileId       = pro.Id,
            FirstName       = 'andrew',
            LastName        = 'russell',
            Email           = 'andrewrussell@citation.co.uk',
            Username        = 'andrewrussell250319ar@citation.co.uk',
            CompanyName     = 'Citation Limited',
            Title           = 'President',
            Alias           = 'arus',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US'
        );
        return u;
    }
    
    static testMethod void onBeforeInsertTest(){
        List<Task> taskRecs = [SELECT Id,Status__c, Suspended_Close__c, NVMConnect__DialList__c FROM Task];
		System.assertNotEquals(taskRecs[0].NVMConnect__DialList__c, null);

		NVMStatsSF__NVM_Call_Summary__c callSummary = new NVMStatsSF__NVM_Call_Summary__c();
		callSummary.NVMStatsSF__TaskExists__c = true;
		callSummary.NVMStatsSF__TaskID__c = taskRecs[0].Id;

		Test.startTest();
		insert callSummary;
		Test.stopTest();

		System.assertEquals(1, [select count() from NVMStatsSF__NVM_Call_Summary__c]);
		System.assertNotEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);
		System.assertEquals('test0', [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);
    }

	static testMethod void onBeforeUpdateNullTest(){
        List<Task> taskRecs = [SELECT Id,Status__c, Suspended_Close__c, NVMConnect__DialList__c FROM Task];
		System.assertNotEquals(taskRecs[0].NVMConnect__DialList__c, null);

		NVMStatsSF__NVM_Call_Summary__c callSummary = new NVMStatsSF__NVM_Call_Summary__c();
		callSummary.NVMStatsSF__TaskExists__c = true;
		callSummary.NVMStatsSF__TaskID__c = taskRecs[0].Id;
		insert callSummary;
		
		System.assertNotEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);

		Test.startTest();
		NVMStatsSF__NVM_Call_Summary__c callSummaryUpdate = [select Id, NVMStatsSF__TaskID__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1];
		callSummaryUpdate.NVMStatsSF__TaskID__c = null;
		update callSummaryUpdate;
		Test.stopTest();

		System.assertEquals(1, [select count() from NVMStatsSF__NVM_Call_Summary__c]);
		System.assertEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);
    }

	static testMethod void onBeforeUpdateNoneNullTest(){
        List<Task> taskRecs = [SELECT Id,Status__c, Suspended_Close__c, NVMConnect__DialList__c FROM Task];
		System.assertNotEquals(taskRecs[0].NVMConnect__DialList__c, null);

		NVMStatsSF__NVM_Call_Summary__c callSummary = new NVMStatsSF__NVM_Call_Summary__c();
		callSummary.NVMStatsSF__TaskExists__c = true;
		callSummary.NVMStatsSF__TaskID__c = taskRecs[0].Id;
		insert callSummary;
		
		System.assertNotEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);

		Test.startTest();
		NVMStatsSF__NVM_Call_Summary__c callSummaryUpdate = [select Id, NVMStatsSF__TaskID__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1];
		callSummaryUpdate.NVMStatsSF__TaskID__c = taskRecs[1].Id;
		update callSummaryUpdate;
		Test.stopTest();

		System.assertNotEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);
		System.assertEquals('test1', [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummary.Id limit 1 ].Dial_List_Name__c);

    }

	static testMethod void onBeforeInsertBulkTest(){
        List<Task> taskRecs = [SELECT Id,Status__c, Suspended_Close__c, NVMConnect__DialList__c FROM Task];
		System.assertNotEquals(taskRecs[0].NVMConnect__DialList__c, null);
		Integer size = taskRecs.size();

		List<NVMStatsSF__NVM_Call_Summary__c> callSummaryToInsert = new List<NVMStatsSF__NVM_Call_Summary__c>();
		for(Task record: taskRecs){
			NVMStatsSF__NVM_Call_Summary__c callSummary = new NVMStatsSF__NVM_Call_Summary__c();
			callSummary.NVMStatsSF__TaskExists__c = true;
			callSummary.NVMStatsSF__TaskID__c = record.Id;
			callSummaryToInsert.add(callSummary);
		}

		Test.startTest();
		insert callSummaryToInsert;
		Test.stopTest();

		System.assertEquals(size, [select count() from NVMStatsSF__NVM_Call_Summary__c]);
		System.assertNotEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummaryToInsert[size-1].Id limit 1 ].Dial_List_Name__c);
		System.assertEquals(('test' + (size-1)), [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummaryToInsert[size-1].Id limit 1 ].Dial_List_Name__c);
		
    }

	
	static testMethod void onBeforeUpdateBulkTest(){
        List<Task> taskRecs = [SELECT Id,Status__c, Suspended_Close__c, NVMConnect__DialList__c FROM Task];
		System.assertNotEquals(taskRecs[0].NVMConnect__DialList__c, null);
		Integer size = taskRecs.size();

		List<NVMStatsSF__NVM_Call_Summary__c> callSummaryToInsert = new List<NVMStatsSF__NVM_Call_Summary__c>();
		for(Task record: taskRecs){
			NVMStatsSF__NVM_Call_Summary__c callSummary = new NVMStatsSF__NVM_Call_Summary__c();
			callSummary.NVMStatsSF__TaskExists__c = true;
			callSummary.NVMStatsSF__TaskID__c = record.Id;
			callSummaryToInsert.add(callSummary);
		}
		insert callSummaryToInsert;

		Test.startTest();
		List<NVMStatsSF__NVM_Call_Summary__c> callSummaryToUpdate = new List<NVMStatsSF__NVM_Call_Summary__c>();
		for(NVMStatsSF__NVM_Call_Summary__c record: [select Id, NVMStatsSF__TaskID__c from NVMStatsSF__NVM_Call_Summary__c]){
			record.NVMStatsSF__TaskID__c = taskRecs[0].Id;
			callSummaryToUpdate.add(record);
		}
		update callSummaryToUpdate;
		Test.stopTest();

		System.assertEquals(size, [select count() from NVMStatsSF__NVM_Call_Summary__c]);
		System.assertNotEquals(null, [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummaryToInsert[size-1].Id limit 1 ].Dial_List_Name__c);
		System.assertEquals('test0', [select Id, Dial_List_Name__c from NVMStatsSF__NVM_Call_Summary__c where Id =: callSummaryToInsert[size-1].Id limit 1 ].Dial_List_Name__c);
		
    }

}