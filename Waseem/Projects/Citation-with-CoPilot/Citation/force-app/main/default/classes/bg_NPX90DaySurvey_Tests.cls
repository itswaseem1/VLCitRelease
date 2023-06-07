/****************************************************************************
*
*	Tests for the schedulable apex for the generation of NPX Survey records for every contract that has been signed 90 days ago.
*
*	Created By: Jamie Wooley
*	Created Date: 28-03-2017
*
*	Changes:
*
****************************************************************************/
@isTest
private class bg_NPX90DaySurvey_Tests {
	
	@testSetup static void setupData() {
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
        insert pricebook;
	}
	
	@isTest static void testCreateSingleSurveyMainUser_Positive() {
		// Setup
		NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
		accountMapping.Name = 'Account__c';
		accountMapping.SF_Field_Name__c = 'Id';
		insert accountMapping;

		NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
		contactMapping.Name = 'Contact__c';
		contactMapping.SF_Field_Name__c = 'Id';
		insert contactMapping;

		Account account = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
		account.CALC_Citation_Contract__c = 1;
		account.Cluster_Start_Date__c = Date.today().addDays(-90);
		insert account;

		Contact contact = bg_Contact_TestUtils.createContact('test 1', account.Id);
		contact.Main_User__c = 'Yes';
		insert contact;

		Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
		contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today().addDays(-90);
        Test.startTest();
		insert contract;
		Test.stopTest();
		// Logic
		bg_NPX90DaySurvey_Schedulable.processAndGenerateSurveys();

		// Assertions
		List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
		system.assertEquals(0, surveyRecords.size());
		//system.assertEquals(account.Id, surveyRecords.get(0).Account__c);
		//system.assertEquals(contact.Id, surveyRecords.get(0).Contact__c);

	}

	@isTest static void testCreateSingleSurveyMainUser_Negative() {
		// Setup
		NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
		accountMapping.Name = 'Account__c';
		accountMapping.SF_Field_Name__c = 'Cluster_Start_Date__c';
		insert accountMapping;

		NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
		contactMapping.Name = 'Contact__c';
		contactMapping.SF_Field_Name__c = 'Phone';
		insert contactMapping;
		
		Account account = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
		account.CALC_Citation_Contract__c = 1;
		account.Cluster_Start_Date__c = Date.today().addDays(-90);
		insert account;

		Contact contact = bg_Contact_TestUtils.createContact('test 1', account.Id);
		contact.Main_User__c = 'Yes';
		insert contact;

		Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
		contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today().addDays(-90);
		insert contract;

		// Logic
		bg_NPX90DaySurvey_Schedulable.processAndGenerateSurveys();

		// Assertions
		List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
		system.assertEquals(0, surveyRecords.size());

	}

	@isTest static void testCreateMultiSurveys_Positive() {
		// Setup
		NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
		accountMapping.Name = 'Account__c';
		accountMapping.SF_Field_Name__c = 'Id';
		insert accountMapping;

		NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
		contactMapping.Name = 'Contact__c';
		contactMapping.SF_Field_Name__c = 'Id';
		insert contactMapping;

		Account account = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
		account.CALC_Citation_Contract__c = 1;
		account.Cluster_Start_Date__c = Date.today().addDays(-90);
		insert account;

		List<Contact> contactsToInsert = new List<Contact>();
		Contact contact1 = bg_Contact_TestUtils.createContact('test 1', account.Id);
		contact1.Main_User__c = 'Yes';
		contactsToInsert.add(contact1);
		Contact contact2 = bg_Contact_TestUtils.createContact('test 2', account.Id);
		contactsToInsert.add(contact2);
		insert contactsToInsert;

		Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
		contract.CustomerSignedId = contact2.Id;
		contract.CustomerSignedDate = Date.today().addDays(-90);
		insert contract;

		// Logic
		bg_NPX90DaySurvey_Schedulable.processAndGenerateSurveys();

		// Assertions
		List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
		system.assertEquals(0, surveyRecords.size());

	}

	@isTest static void testCreateMultiSurveys_Bulk() {
		// Setup
		NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
		accountMapping.Name = 'Account__c';
		accountMapping.SF_Field_Name__c = 'Id';
		insert accountMapping;

		NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
		contactMapping.Name = 'Contact__c';
		contactMapping.SF_Field_Name__c = 'Id';
		insert contactMapping;

		Account account = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
		account.CALC_Citation_Contract__c = 1;
		account.Cluster_Start_Date__c = Date.today().addDays(-90);
		insert account;

		List<Contact> contactsToInsert = new List<Contact>();
		for (Integer i = 0; i <100; i++)
		{
			Contact contact1 = bg_Contact_TestUtils.createContact('test ' + string.valueOf(i), account.Id);
			contact1.Service_Owner__c = True;
			contactsToInsert.add(contact1);
		}
        Test.startTest();
		insert contactsToInsert;
		test.stopTest();
		Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
		contract.CustomerSignedId = contactsToInsert.get(0).Id;
		contract.CustomerSignedDate = Date.today().addDays(-90);
		insert contract;
		
		// Logic
		bg_NPX90DaySurvey_Schedulable.processAndGenerateSurveys();

		// Assertions
		List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
		system.assertEquals(0, surveyRecords.size());

	}
    
    @isTest static void testCreateMultiSurveys_Bulk_SurveyCreation(){
       
        NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
		accountMapping.Name = 'Account__c';
		accountMapping.SF_Field_Name__c = 'Id';
		insert accountMapping;

		NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
		contactMapping.Name = 'Contact__c';
		contactMapping.SF_Field_Name__c = 'Id';
		insert contactMapping;

		Account account = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
		account.CALC_Citation_Contract__c = 1;
		account.Cluster_Start_Date__c = Date.today().addDays(-90);
        account.IsActive__c = true;
		insert account;

		List<Contact> contactsToInsert = new List<Contact>();
		for (Integer i = 0; i <100; i++)
		{
			Contact contact1 = bg_Contact_TestUtils.createContact('test ' + string.valueOf(i), account.Id);
			contact1.Service_Owner__c = True;
            contact1.Active__c = true;
            contact1.HasOptedOutOfEmail = false;
            contact1.Email = 'test' + i + '@test.com';
            if(i<25){
            contact1.Main_User__c = 'Yes';
            } else if(i > 25 && i <50){
                contact1.Online_Super_User__c = 'Yes';
            } else if(i > 50 && i <75){
                contact1.Helpline_PEL__c = 'Yes';
            }else {
                contact1.AdviceCard__c = true;
            }
			contactsToInsert.add(contact1);
		}
		insert contactsToInsert;

		Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
		contract.CustomerSignedId = contactsToInsert.get(0).Id;
		contract.CustomerSignedDate = Date.today().addDays(-90);
        contract.Services_Taken_EL__c = true;
        contract.Status = 'Draft';
        contract.StartDate=Date.today().addDays(-90);
        test.startTest();
		insert contract;
        contract.Status = 'Active';
        
        update contract;
    	
            bg_NPX90DaySurvey_Schedulable ssoor = new bg_NPX90DaySurvey_Schedulable();
            string schedule = '0 0 23 * * ?';
            system.schedule('Test Update', schedule, ssoor);
        test.stopTest();
        
        List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
		system.assertEquals(100, surveyRecords.size());
    }
    
    @isTest static void testCreateSingleSurvey_Exception() {
		// Setup
		NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
		accountMapping.Name = 'Account__c';
		accountMapping.SF_Field_Name__c = 'Id';
		insert accountMapping;

		NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
		contactMapping.Name = 'Contact__c';
		contactMapping.SF_Field_Name__c = 'lastname';
		insert contactMapping;

		Account account = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
		account.CALC_Citation_Contract__c = 1;
		account.Cluster_Start_Date__c = Date.today().addDays(-90);
        account.IsActive__c = true;
		insert account;

		Contact contact = bg_Contact_TestUtils.createContact('test 1', account.Id);
		contact.Main_User__c = 'Yes';
		insert contact;

		Contract contract = bg_Contract_TestUtils.createContract('1', account.Id);
		contract.CustomerSignedId = contact.Id;
		contract.CustomerSignedDate = Date.today().addDays(-90);
		contract.Services_Taken_AI_Only_HS__c = true;
        contract.Status = 'Draft';
        test.startTest();
		insert contract;
        contract.Status = 'Active';
       
        update contract;
         test.stopTest();
		// Logic
		
            bg_NPX90DaySurvey_Schedulable ssoor = new bg_NPX90DaySurvey_Schedulable();
            string schedule = '0 0 23 * * ?';
            system.schedule('Test Update', schedule, ssoor);
       
        
        List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
		system.assertEquals(0, surveyRecords.size());

	}
	
}