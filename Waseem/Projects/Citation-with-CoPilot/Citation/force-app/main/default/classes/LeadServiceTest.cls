@isTest
public class LeadServiceTest
{
	@isTest
	private static void setDefaults_SetFMCreatedDate()
	{
		Datetime now = System.now();

		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test')
		};

		Test.startTest();
		new LeadService(new MockSelector(), new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		// we can't get exact enough to an equals check, but it will be no earlier than start of test.
		System.assert(leads[0].FMCreatedDate__c >= now, 'FMCreatedDate__c not set correct');
	}

	@isTest
	private static void setDefaults_SetBDM()
	{
		List<User> users = new List<User>{
			new User(FirstName = 'Bob', LastName = 'Test')
		};
		TestUtility.setIDs(users);

		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', OwnerId = users[0].Id)
		};

		MockSelector selector = new MockSelector();
		selector.owners = new Map<Id, User>(users);

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals('Bob Test', leads[0].TEXT_BDM__c);
	}

	@isTest
	private static void processChangedValues_SetBDM()
	{
		List<User> users = new List<User>{
			new User(FirstName = 'Bob', LastName = 'Test'),
			new User(FirstName = 'Mary', LastName = 'Test')
		};
		TestUtility.setIDs(users);


		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test', OwnerId = users[0].Id)
		};
		TestUtility.setIDs(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id, LastName = 'Test', OwnerId = users[1].Id)
		};

		MockSelector selector = new MockSelector();
		selector.owners = new Map<Id, User>(users);

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals('Mary Test', leads[0].TEXT_BDM__c);
	}

	@isTest
	private static void setDefaults_WhenDateMade_incrementDateMadeCount()
	{

		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', CountDateMade__c = 0, Date_Made__c = Date.today())
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(1, leads[0].CountDateMade__c);
	}

	@isTest
	private static void setDefaults_WhenNoDateMade_incrementDateMadeCount()
	{

		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', CountDateMade__c = 0 )
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(0, leads[0].CountDateMade__c);
	}

	@isTest
	private static void processChangedValues_WhenDateMadeChanges_incrementDateMadeCount()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test', Date_Made__c = Date.today().addDays(-1))
		};
		TestUtility.setIDs(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id, LastName = 'Test', CountDateMade__c = 0, Date_Made__c = Date.today())
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(1, leads[0].CountDateMade__c);
	}

	@isTest
	private static void processChangedValues_WhenNoDateMadeChange_DateMadeCountNotIncremented()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test', Date_Made__c = Date.today())
		};
		TestUtility.setIDs(oldLeads);


		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id, LastName = 'Test', CountDateMade__c = 0, Date_Made__c = Date.today())
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(0, leads[0].CountDateMade__c);
	}

	@isTest
	private static void setDefaults_WhenDataQuality_DateMadeCountIncremented()
	{
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', CountDateMade__c = 0, Status = 'Data Quality')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(1, leads[0].CountDateMade__c);
	}

	@isTest
	private static void setDefaults_WhenApproved_DateMadeCountIncremented()
	{
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', CountDateMade__c = 0, Status = 'Approved')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(1, leads[0].CountDateMade__c);
	}

	@isTest
	private static void setDefaults_WhenSeminar_DateMadeCountIncremented()
	{
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test',
					CountDateMade__c = 0,
					Prospect_Channel__c = 'SEM',
					Seminar_Status__c = 'Registered',
					MADE_Criteria__c = 'Seminar Registered 3')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(1, leads[0].CountDateMade__c);
	}

	@isTest
	private static void setDefaults_whenCallbackRequestedWithBDC_setsPipelineBDC()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		DateTime now = System.Now();

		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Status = 'Callback Requested', BDC__c = BDC )
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(BDC, leads[0].PipeLine_BDC__c);
		System.assert(leads[0].Pipeline_Date_Time__c > now, 'Expected datetime to be just after test started'); //cannot get exact, but should be at least this.
	}

	@isTest
	private static void setDefaults_whenNoCallbackRequested_noPipelineBDCSet()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);

		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Status = 'Something', BDC__c = BDC )
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(null, leads[0].PipeLine_BDC__c);
		System.assertEquals(null, leads[0].Pipeline_Date_Time__c);
	}

	@isTest
	private static void setDefaults_whenCallbackRequestedWithNoBDC_noPipelineBDCSet()
	{
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Status = 'Callback Requested')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(null, leads[0].PipeLine_BDC__c);
		System.assertEquals(null, leads[0].Pipeline_Date_Time__c);
	}

	@isTest
	private static void processChangedValues_whenCallbackRequestedWithNewBDC_setsNewPipelineBDC()
	{
		Id oldBDC = TestUtility.getFakeId(User.SObjectType);
		Id newBDC = TestUtility.getFakeId(User.SObjectType);
		DateTime now = System.Now();

		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Status = 'Callback Requested',
					BDC__c = oldBDC,
					PipeLine_BDC__c = oldBDC,
					Pipeline_Date_Time__c = now.addDays(-1) )
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Status = 'Callback Requested',
					BDC__c = newBDC,
					PipeLine_BDC__c = oldBDC,
					Pipeline_Date_Time__c = now.addDays(-1))
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(newBDC, leads[0].PipeLine_BDC__c);
		System.assert(leads[0].Pipeline_Date_Time__c > now, 'Expected datetime to be just after test started'); //cannot get exact, but should be at least this.
	}

	@isTest
	private static void processChangedValues_whenCallbackRequestedWithSameBDC_noPipelineBDCSet()
	{
		Id oldBDC = TestUtility.getFakeId(User.SObjectType);
		DateTime now = System.Now();

		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Status = 'Callback Requested',
					BDC__c = oldBDC,
					PipeLine_BDC__c = oldBDC,
					Pipeline_Date_Time__c = now.addDays(-1) )
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Status = 'Callback Requested',
					BDC__c = oldBDC,
					PipeLine_BDC__c = oldBDC,
					Pipeline_Date_Time__c = now.addDays(-1))
		};
		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(oldBDC, leads[0].PipeLine_BDC__c);
		System.assertEquals(now.addDays(-1), leads[0].Pipeline_Date_Time__c);
	}

	@isTest
	private static void processChangedValues_whenStatusNoCallback_PipelineCleared()
	{
		Id oldBDC = TestUtility.getFakeId(User.SObjectType);
		Id newBDC = TestUtility.getFakeId(User.SObjectType);
		DateTime now = System.Now();

		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Status = 'Callback Requested',
					BDC__c = oldBDC,
					PipeLine_BDC__c = oldBDC,
					Pipeline_Date_Time__c = now.addDays(-1) )
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Status = 'Done',
					BDC__c = newBDC,
					PipeLine_BDC__c = oldBDC,
					Pipeline_Date_Time__c = now.addDays(-1))
		};
		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(null, leads[0].PipeLine_BDC__c);
		System.assertEquals(null, leads[0].Pipeline_Date_Time__c);
	}

	@isTest
	private static void setDefaults_WhenCallBackRequested_SetsCallStamp()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Status = 'Callback Requested', BDC__c = BDC)
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(Date.today(), leads[0].BDC_Callback_Datestamp__c);
	}

	@isTest
	private static void setDefaults_WhenCallBackNotRequested_DoesNotStamp()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Status = 'Something', BDC__c = BDC)
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(null, leads[0].BDC_Callback_Datestamp__c);
	}

	@isTest
	private static void processChangedValues_whenChangesToCallBackRequested_StampsDate()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Status = 'Something' )
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Status = 'Callback Requested')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(Date.today(), leads[0].BDC_Callback_Datestamp__c);
	}

	@isTest
	private static void processChangedValues_WhenNoLongerCallbackRequested_NullsDate()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		DateTime now = System.Now();

		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Status = 'Callback Requested',
					BDC_Callback_Datestamp__c = Date.today().addDays(-2))
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Status = 'Something',
					BDC_Callback_Datestamp__c = Date.today().addDays(-2))
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(null, leads[0].BDC_Callback_Datestamp__c);
	}

	@isTest
	private static void processChangedValues_changesToDataQuality_noLeadSource_LeavesDate()
	{
		Id oldBDC = TestUtility.getFakeId(User.SObjectType);
		Id newBDC = TestUtility.getFakeId(User.SObjectType);
		DateTime now = System.Now();

		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Status = 'Callback Requested',
					BDC_Callback_Datestamp__c = Date.today().addDays(-2))
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Status = 'Data Quality',
					BDC_Callback_Datestamp__c = Date.today().addDays(-2))
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(Date.today().addDays(-2), leads[0].BDC_Callback_Datestamp__c);
	}

	@isTest
	private static void setDefaults_whenEmail_setsDomain()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Email = 'me@Something.com')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals('Something.com', leads[0].Email_Domain__c);
	}

	@isTest
	private static void processChangedValues_whenEmailChanges_setsDomain()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					Email = 'me@Something.com' )
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					Email = 'me@Something.co.uk')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals('Something.co.uk', leads[0].Email_Domain__c);
	}

	@isTest
	private static void setDefaults_whenPopupChannel_setsChannel()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Prospect_Channel__c  = 'Pop Up Form')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals('SEO', leads[0].Marketing_Channel__c);
		System.assertEquals('Inbound', leads[0].Sales_Channel__c);
	}

	@isTest
	private static void setDefaults_whenNotPopupChannel_ignoresChannels()
	{
		Id BDC = TestUtility.getFakeId(User.SObjectType);
		List<Lead> leads = new List<Lead>{
			new Lead(LastName = 'Test', Prospect_Channel__c  = 'Something')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals(null, leads[0].Marketing_Channel__c);
		System.assertEquals(null, leads[0].Sales_Channel__c);
	}


	@isTest
	private static void processChangedValues_whenChangesToPopupChannel_setsChannel()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					 Prospect_Channel__c  = 'Something')
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					 Prospect_Channel__c  = 'Pop Up Form')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals('SEO', leads[0].Marketing_Channel__c);
		System.assertEquals('Inbound', leads[0].Sales_Channel__c);
	}

	@isTest
	private static void processChangedValues_whenChangesFromPopupChannel_withChannelSet_blanksChannel()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					 Prospect_Channel__c  = 'Pop Up Form',
					 Marketing_Channel__c = 'SEO',
					 Sales_Channel__c = 'Inbound')
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					 Prospect_Channel__c  = 'Something',
					 Marketing_Channel__c = 'SEO',
					 Sales_Channel__c = 'Inbound')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(null, leads[0].Marketing_Channel__c);
		System.assertEquals(null, leads[0].Sales_Channel__c);
	}

	@isTest
	private static void processChangedValues_whenChangesFromPopupChannel_withChannelNotSetForPopUp_ignoresChannel()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead(LastName = 'Test',
					 Prospect_Channel__c  = 'Pop Up Form',
					 Marketing_Channel__c = 'xxx',
					 Sales_Channel__c = 'xxx')
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id,
					LastName = 'Test',
					 Prospect_Channel__c  = 'Something',
					 Marketing_Channel__c = 'xxx',
					 Sales_Channel__c = 'xxx')
		};

		MockSelector selector = new MockSelector();

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals('xxx', leads[0].Marketing_Channel__c);
		System.assertEquals('xxx', leads[0].Sales_Channel__c);
	}

	@isTest
	private static void givenSessionNotes_whenUpdated_thenNotesUpdated()
	{
		List<Lead> oldLeads = new List<Lead>{
			new Lead()
		};
		TestUtility.setIds(oldLeads);

		List<Lead> leads = new List<Lead>{
			new Lead(Id = oldLeads[0].Id, Session_Notes__c = 'Message', Notes__c = null)
		};

		MockSelector selector = new MockSelector();
		selector.user = 'Bob';

		Test.startTest();
		new LeadService(selector, new NoteService(selector, null)).processChangedValues(leads, new Map<Id, Lead>(oldLeads));
		Test.stopTest();

		System.assertEquals(null, leads[0].Session_Notes__c);
		System.assert(leads[0].Notes__c != null, 'Lead notes should have been updated with session note');
		System.assert(leads[0].Notes__c.contains('Message'), 'Lead notes should have been updated with session note');
	}

	@isTest
	private static void setDefaults_SetFieldAdvisorOfficeAdvisor_WithNotVisitedAndBdmName_WhenOnInsert() {
		String qmsLeadRecordTypeId = new RecordTypeSelector().getRecordTypeId(Lead.SObjectType, 'QMS_Record_Type');

		List<User> users = new List<User>{ new User(FirstName = 'Bob', LastName = 'Test') };
		TestUtility.setIDs(users);

		List<Lead> leads = new List<Lead>{ new Lead(LastName = 'Test', OwnerId = users[0].Id, RecordTypeId = qmsLeadRecordTypeId) };

		MockSelector selector = new MockSelector();
		selector.owners = new Map<Id, User>(users);
		selector.recordTypeID = qmsLeadRecordTypeId;

		Test.startTest();
		new LeadService(selector, new MockNoteService()).setDefaults(leads);
		Test.stopTest();

		System.assertEquals('Bob Test', leads[0].Office_Advisor__c);
		System.assertEquals('Not Visited', leads[0].Field_Advisor__c);
	}

	@isTest
	private static void processChangedValues_SetFieldAdvisorOfficeAdvisor_WithNotVisitedAndBdmName_WhenOwnerChanged() {
		String qmsLeadRecordTypeId = new RecordTypeSelector().getRecordTypeId(Lead.SObjectType, 'QMS_Record_Type');

		List<User> users = new List<User>{ new User(FirstName = 'Bob', LastName = 'Test'), new User(FirstName = 'Mary', LastName = 'Test') };
		TestUtility.setIDs(users);

		List<Lead> oldLeads = new List<Lead>{ new Lead(LastName = 'Test', OwnerId = users[0].Id, RecordTypeId = qmsLeadRecordTypeId) };
		TestUtility.setIDs(oldLeads);

		List<Lead> leads = new List<Lead>{ new Lead(Id = oldLeads[0].Id, LastName = 'Test', OwnerId = users[1].Id, RecordTypeId = qmsLeadRecordTypeId) };

		MockSelector selector = new MockSelector();
		selector.owners = new Map<Id, User>(users);
		selector.recordTypeID = qmsLeadRecordTypeId;

		Test.startTest();
		new LeadService(selector, new MockNoteService()).processChangedValues(leads, new Map<Id, Lead>(oldLeads));

		Test.stopTest();

		System.assertEquals('Mary Test', leads[0].Office_Advisor__c);
		System.assertEquals('Not Visited', leads[0].Field_Advisor__c);
	}

	/*
	 *void updateDuplicateLead(List<Lead> leads, Id iHASCOLeadRecordType) Test methods Start
	 */
	@isTest
	static void givenLeadDetails_WhenAnotherLeadHavingSameEmail_ThenUpdate_LeadStatus_ToDuplicateFound()
	{
		MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> leads= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@duplicate.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='duplicate.com';

		Lead leadRec1=new lead();
		leadRec1.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec1.email = 'test@duplicate.com';
		leadRec1.Status = 'Open';
		leadRec1.Email_Domain__c='duplicate.com';
		leadRec1.RecordTypeId = recordTypeId;
		leads.add(leadRec1);
		sObjecstList.add(leads);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);

	}

	@isTest
	static void givenLeadDetails_WhenContactHavingSameEmail_ThenUpdate_LeadStatus_ToDuplicateFound()
	{
		 MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> contacts= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@duplicate.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='duplicate.com';

		Contact conRec=new Contact();
		conRec.Id=TestUtility.getFakeId(Contact.SObjectType);
		conRec.email = 'test@duplicate.com';
		conRec.Email_Domain__c='duplicate.com';
		contacts.add(conRec);
		sObjecstList.add(contacts);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);
	}

	@isTest
	static void givenLeadDetails_WhenAccountHavingSameEmail_ThenUpdate_LeadStatus_ToDuplicateFound()
	{
		 MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> accounts= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@duplicate.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='duplicate.com';

		Account accountRec=new Account();
		accountRec.Id=TestUtility.getFakeId(Account.SObjectType);
		accountRec.AccountsEmailAddress__c = 'test@duplicate.com';
		accounts.add(accountRec);
		sObjecstList.add(accounts);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);
	}

	@isTest
	static void givenLeadDetails_WhenAnotherLeadHavingSameEmailDomain_ButDifferentEmail_ThenUpdate_LeadStatus_ToDuplicateFound()
	{
		MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> leads= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@duplicate.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='duplicate.com';

		Lead leadRec1=new lead();
		leadRec1.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec1.email = 'test2@duplicate.com';
		leadRec1.Status = 'Open';
		leadRec1.Email_Domain__c='duplicate.com';
		leadRec1.RecordTypeId = recordTypeId;
		leads.add(leadRec1);
		sObjecstList.add(leads);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);

	}

	@isTest
	static void givenLeadDetails_WhenContactHavingSameEmailDomain_ButDifferentEmail_ThenUpdate_LeadStatus_ToDuplicateFound()
	{
		 MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> contacts= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@duplicate.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='duplicate.com';

		Contact conRec=new Contact();
		conRec.Id=TestUtility.getFakeId(Contact.SObjectType);
		conRec.email = 'test2@duplicate.com';
		conRec.Email_Domain__c='duplicate.com';
		contacts.add(conRec);
		sObjecstList.add(contacts);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);
	}

	@isTest
	static void givenLeadDetails_WhenAccountHavingSameEmailDomain_ButDifferentEmail_ThenUpdate_LeadStatus_ToDuplicateFound()
	{
		 MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> accounts= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@duplicate.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='duplicate.com';

		Account accountRec=new Account();
		accountRec.Id=TestUtility.getFakeId(Account.SObjectType);
		accountRec.AccountsEmailAddress__c = 'test2@duplicate.com';
		accounts.add(accountRec);
		sObjecstList.add(accounts);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);
	}

   	@isTest
	static void givenLeadDetails_WhenContactHavingSameEmailDomain_ButDifferentEmail_AndFreeDomain_Then_LeadStatus_NotUpdated()
	{
		 MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> contacts= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@gmail.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='gamil.com';

		Contact conRec=new Contact();
		conRec.Id=TestUtility.getFakeId(Contact.SObjectType);
		conRec.email = 'test2@gmail.com';
		conRec.Email_Domain__c='gmail.com';
		contacts.add(conRec);
		sObjecstList.add(contacts);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertNotEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);
	}

	@isTest
	static void givenLeadDetails_WhenContactHavingDifferentEmailDomain_AndDifferentEmail_Then_LeadStatus_NotUpdated()
	{
		 MockSelector selector=new MockSelector();         // Using Mock selector to avoid SOQL
		List<List<SObject>> sObjecstList = new List<List<SObject>>();
		List<Sobject> contacts= new List<Sobject>();
		Id recordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

		Lead leadRec=new lead();
		leadRec.Id=TestUtility.getFakeId(Lead.SObjectType);
		leadRec.email = 'test@gmail.com';
		leadRec.Status = 'Open';
		leadRec.Email_Domain__c='gmail.com';

		Contact conRec=new Contact();
		conRec.Id=TestUtility.getFakeId(Contact.SObjectType);
		conRec.email = 'test2@outlook.com';
		conRec.Email_Domain__c='outlook.com';
		contacts.add(conRec);
		sObjecstList.add(contacts);
		selector.sObjecstList =sObjecstList;

		LeadService service= new LeadService(selector, NULL);
		MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		test.startTest();
		service.updateDuplicateLead(new List<Lead>{leadRec}, recordTypeId);
		test.stopTest();

		System.assertNotEquals(DataConstants.LEAD_STATUS_DUPLICATE_FOUND, leadRec.Status);
	}
	/*
	 *void updateDuplicateLead(List<Lead> leads, Id iHASCOLeadRecordType) Test methods End
	 */

    @isTest
    private static void whenProspectIsApproved_createSMSMessageRecords_ValidPhoneNumber()
    {
        List<Lead> oldLeads = new List<Lead>{
                new Lead(LastName = 'Test', Status = 'Data Quality', Phone='07568440436')
        };
        TestUtility.setIDs(oldLeads);

        List<Lead> leads = new List<Lead>{
                new Lead(Id = oldLeads[0].Id, Status = 'Approved', Phone='07568440436')
        };

        List<Event> events = new List<Event>();
        Event e = new Event();
        e.StartDateTime = Date.today();
        e.WhoId = oldLeads[0].Id;
        events.add(e);

        MockSelector selector = new MockSelector();
        selector.events = events;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        LeadService service= new LeadService(selector, null);
        service.processRelatedRecordsOnChange(leads, new Map<Id, Lead>(oldLeads));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(smagicinteract__smsMagic__c.SObjectType).size());
        smagicinteract__smsMagic__c smsMagic = (smagicinteract__smsMagic__c)uow.getRecords(smagicinteract__smsMagic__c.SObjectType)[0];
        System.assertEquals('Lead', smsMagic.smagicinteract__ObjectType__c);
        System.assertEquals('447568440436', smsMagic.smagicinteract__PhoneNumber__c );
        System.assertEquals(e.WhoId, smsMagic.smagicinteract__Lead__c);

    }


    @isTest
    private static void whenProspectIsApproved_createSMSMessageRecords_ValidMobileNumber()
    {
        List<Lead> oldLeads = new List<Lead>{
                new Lead(LastName = 'Test', Status = 'Data Quality', MobilePhone='07568440436')
        };
        TestUtility.setIDs(oldLeads);

        List<Lead> leads = new List<Lead>{
                new Lead(Id = oldLeads[0].Id, Status = 'Approved', MobilePhone='07568440436')
        };

        List<Event> events = new List<Event>();
        Event e = new Event();
        e.StartDateTime = Date.today();
        e.WhoId = oldLeads[0].Id;
        events.add(e);

        MockSelector selector = new MockSelector();
        selector.events = events;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        LeadService service= new LeadService(selector, null);
        service.processRelatedRecordsOnChange(leads, new Map<Id, Lead>(oldLeads));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(smagicinteract__smsMagic__c.SObjectType).size());
        smagicinteract__smsMagic__c smsMagic = (smagicinteract__smsMagic__c)uow.getRecords(smagicinteract__smsMagic__c.SObjectType)[0];
        System.assertEquals('Lead', smsMagic.smagicinteract__ObjectType__c);
        System.assertEquals('447568440436', smsMagic.smagicinteract__PhoneNumber__c );
        System.assertEquals(e.WhoId, smsMagic.smagicinteract__Lead__c);

    }

    @isTest
    private static void whenProspectIsApproved_createSMSMessageRecords_InValidPhoneNumber()
    {
        List<Lead> oldLeads = new List<Lead>{
                new Lead(LastName = 'Test', Status = 'Data Quality', Phone='03458441111')
        };
        TestUtility.setIDs(oldLeads);

        List<Lead> leads = new List<Lead>{
                new Lead(Id = oldLeads[0].Id, Status = 'Approved', Phone='03458441111')
        };

        List<Event> events = new List<Event>();
        Event e = new Event();
        e.StartDateTime = Date.today();
        e.WhoId = oldLeads[0].Id;
        events.add(e);

        MockSelector selector = new MockSelector();
        selector.events = events;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        LeadService service= new LeadService(selector, null);
        service.processRelatedRecordsOnChange(leads, new Map<Id, Lead>(oldLeads));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(smagicinteract__smsMagic__c.SObjectType).size());

    }

    @isTest
    private static void whenProspectIsApproved_createSMSMessageRecords_TwoNumbers()
    {
        List<Lead> oldLeads = new List<Lead>{
                new Lead(LastName = 'Test', Status = 'Data Quality', Phone='03458441111', MobilePhone='07568440436')
        };
        TestUtility.setIDs(oldLeads);

        List<Lead> leads = new List<Lead>{
                new Lead(Id = oldLeads[0].Id, Status = 'Approved', Phone='03458441111', MobilePhone='07568440436')
        };

        List<Event> events = new List<Event>();
        Event e = new Event();
        e.StartDateTime = Date.today();
        e.WhoId = oldLeads[0].Id;
        events.add(e);

        MockSelector selector = new MockSelector();
        selector.events = events;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        LeadService service= new LeadService(selector, null);
        service.processRelatedRecordsOnChange(leads, new Map<Id, Lead>(oldLeads));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(smagicinteract__smsMagic__c.SObjectType).size());
        smagicinteract__smsMagic__c smsMagic = (smagicinteract__smsMagic__c)uow.getRecords(smagicinteract__smsMagic__c.SObjectType)[0];
        System.assertEquals('Lead', smsMagic.smagicinteract__ObjectType__c);
        System.assertEquals('447568440436', smsMagic.smagicinteract__PhoneNumber__c );
        System.assertEquals(e.WhoId, smsMagic.smagicinteract__Lead__c);

    }

	class MockSelector implements LeadService.ISelector, NoteService.ISelector
	{
		Map<Id, User> owners = new Map<Id, User>();
		String user = 'Bob';
		List<List<SObject>> sObjecstList =new List<List<SObject>>();
		Id recordTypeID;
        List<Event> events = new List<Event>();
        String templateText = 'test';


		public Map<Id, User> getOwners(List<Lead> leads)
		{
			return owners;
		}

		public Map<String, Lead> getLeadsByTaskIds(Set<Id> taskIds)
		{
			return new Map<String, Lead>();
		}

		public String getCurrentUserName()
		{
			return user;
		}

		public List<List<SObject>> getEmailMatchRecords(String emailSearchList, List<Id> leadIds,Id iHASCORecordTypeId)
		{
			return sObjecstList;
		}


		public Id getRecordTypeId(SObjectType objType, String developerName)
		{
			return recordTypeId;
		}

        public List<Event> getEvents(List<Lead> leads, string eventType) {
            return events;
        }

        public String getSMSTemplateText(String templateName) {
            return templateText;
        }



	}

	class MockNoteService implements INoteService
	{
		Boolean fixupCalled = false;
		public void setNotes(List<SObjectNote> notes)
		{
		}

		public void fixManualEdits(List<Sobject> objs, SObjectField noteField)
		{
			fixupCalled = true;
		}

		public List<SObjectNote> convertToNotes(String existingNotes, String noteSource)
		{
			return new List<SObjectNote>();
		}
	}
}