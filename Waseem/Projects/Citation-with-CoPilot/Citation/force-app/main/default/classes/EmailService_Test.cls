@isTest
public class EmailService_Test {
	@isTest
	public static void given_InboundEmail_ReceivedFromHighValueCustomers_When_threadIDNotFound_Then_NewCase_Created_And_EmailMessageAttached() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL

		User usr = new User();
		usr.FirstName = 'Testuser';
		usr.LastName = 'TestLastname';
		usr.Email = 'test12442121@citation.co.uk';
		usr.AliasEmail__c = 'test12442121@citation.co.uk';
		usr.profileId = TestUtility.getFakeId(Profile.SObjectType);
		usr.Id = TestUtility.getFakeId(User.SObjectType);
		Map<Id, User> userMap = new Map<id, User>();
		userMap.put(usr.id, usr);
		selector.users = userMap;

		selector.queueId = TestUtility.getFakeId(Group.SObjectType);

		Id conId = TestUtility.getFakeId(Contact.SObjectType);
		Contact con = new Contact();
		con.LastName = 'lastNameTest';
		con.Email = 'testcontact@citation.co.uk';
		con.AccountId = TestUtility.getFakeId(Account.SObjectType);
		List<contact> contactsList = new List<Contact>();
		contactsList.add(con);
		selector.contacts = contactsList;

		selector.caseRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		List<Case> casesList = new List<Case>();
		Case cs = new Case();
		cs.Status = 'New';
		cs.OwnerId = usr.Id;
		cs.Description = 'ascdas';
		cs.Subject = 'TestSubject';
		cs.recordTypeId = selector.caseRecordTypeId;
		selector.cases = casesList;

		EmailService service = new EmailService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
		Messaging.InboundEmail.Header eH = new Messaging.InboundEmail.Header();
		eH.name = 'Message-ID';
		eH.value = 'TestMessageID12345';
		emailHeaders.add(eh);

		Messaging.InboundEmail inboundEmail = new Messaging.InboundEmail();
		inboundEmail.fromAddress = 'testcontact@citation.co.uk';
		inboundEmail.toAddresses = new List<String>{ usr.AliasEmail__c };
		inboundEmail.subject = 'TestSubject';
		inboundEmail.plainTextBody = 'ascdas';
		inboundEmail.headers = emailHeaders;

		Messaging.InboundEnvelope inboundEnvelope = new Messaging.InboundEnvelope();
		inboundEnvelope.fromAddress = 'testcontact@citation.co.uk';
		inboundEnvelope.toAddress = usr.AliasEmail__c;

		Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
		txtAttachment.fileName = 'txtfile';
		txtAttachment.body = 'testbody';

		Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binAttachment.fileName = 'binfile';
		binAttachment.body = Blob.valueOf('testbody');

		inboundEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{ txtAttachment };
		inboundEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{ binAttachment };

		test.startTest();
		service.emailMessageHandlerForHighValueCustomer(InboundEmail, inboundEnvelope, 'ELT_Advice_Generic');
		test.stopTest();

		List<Case> cases = uow.getRecords(Case.SObjectType);
		List<emailMessage> emailMessages = uow.getRecords(emailMessage.SObjectType);

		System.assertEquals('New', cases[0].Status);
		System.assertEquals(con.AccountId, cases[0].AccountId);
		System.assertEquals(con.Id, cases[0].ContactId);
		System.assertEquals(usr.Id, cases[0].OwnerId);
		System.assertEquals(1, emailMessages.size());
	}

	@isTest
	public static void given_InboundEmail_ReceivedFromHighValueCustomers_When_threadIDFound_Then_ExistingCaseStatus_Updated_And_EmailMessageAttached() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL

		User usr = new User();
		usr.FirstName = 'Testuser';
		usr.LastName = 'TestLastname';
		usr.Email = 'test12442121@citation.co.uk';
		usr.AliasEmail__c = 'test12442121@citation.co.uk';
		usr.profileId = TestUtility.getFakeId(Profile.SObjectType);
		usr.Id = TestUtility.getFakeId(User.SObjectType);
		Map<Id, User> userMap = new Map<id, User>();
		userMap.put(usr.id, usr);
		selector.users = userMap;

		selector.queueId = TestUtility.getFakeId(Group.SObjectType);

		Id conId = TestUtility.getFakeId(Contact.SObjectType);
		Contact con = new Contact();
		con.LastName = 'lastNameTest';
		con.Email = 'testcontact@citation.co.uk';
		con.AccountId = TestUtility.getFakeId(Account.SObjectType);
		List<contact> contactsList = new List<Contact>();
		contactsList.add(con);
		selector.contacts = contactsList;

		selector.caseRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		List<Case> casesList = new List<Case>();
		Case cs = new Case();
		cs.Id = TestUtility.getFakeId(Case.SObjectType);
		cs.Status = 'New';
		cs.OwnerId = usr.Id;
		cs.Description = 'ascdas';
		cs.Subject = 'TestSubject';
		cs.recordTypeId = selector.caseRecordTypeId;
		casesList.add(cs);
		selector.cases = casesList;
		selector.caseId = cs.Id ;
		EmailService service = new EmailService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		List<Messaging.InboundEmail.Header> emailHeaders = new List<Messaging.InboundEmail.Header>();
		Messaging.InboundEmail.Header eH = new Messaging.InboundEmail.Header();
		eH.name = 'Message-ID';
		eH.value = 'TestMessageID12345';
		emailHeaders.add(eh);

		Messaging.InboundEmail inboundEmail = new Messaging.InboundEmail();
		inboundEmail.fromAddress = 'testcontact@citation.co.uk';
		inboundEmail.toAddresses = new List<String>{ usr.AliasEmail__c };
		inboundEmail.subject = 'TestSubject';
		inboundEmail.plainTextBody = 'ascdas';
		inboundEmail.headers = emailHeaders;

		Messaging.InboundEnvelope inboundEnvelope = new Messaging.InboundEnvelope();
		inboundEnvelope.fromAddress = 'testcontact@citation.co.uk';
		inboundEnvelope.toAddress = usr.AliasEmail__c;

		test.startTest();
		service.emailMessageHandlerForHighValueCustomer(InboundEmail, inboundEnvelope, 'ELT_Advice_Generic');
		test.stopTest();

		List<Case> cases = uow.getRecords(Case.SObjectType);
		List<emailMessage> emailMessages = uow.getRecords(emailMessage.SObjectType);

		System.assertEquals('New Info Added', cases[0].Status);
		System.assertEquals(1, emailMessages.size());
	}

	@isTest
	public static void given_InboundEmail_ReceivedFromHighValueCustomers_When_EXception_OccoursInHandling_Then_EmailMessageResult_Updated_WithReason() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL

		User usr = new User();
		usr.FirstName = 'Testuser';
		usr.LastName = 'TestLastname';
		usr.Email = 'test12442121@citation.co.uk';
		usr.AliasEmail__c = 'test12442121@citation.co.uk';
		usr.profileId = TestUtility.getFakeId(Profile.SObjectType);
		usr.Id = TestUtility.getFakeId(User.SObjectType);
		Map<Id, User> userMap = new Map<id, User>();
		userMap.put(usr.id, usr);
		selector.users = userMap;

		selector.queueId = TestUtility.getFakeId(Group.SObjectType);

		Id conId = TestUtility.getFakeId(Contact.SObjectType);
		Contact con = new Contact();
		con.LastName = 'lastNameTest';
		con.Email = 'testcontact@citation.co.uk';
		con.AccountId = TestUtility.getFakeId(Account.SObjectType);
		List<contact> contactsList = new List<Contact>();
		contactsList.add(con);
		selector.contacts = contactsList;

		selector.caseRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		List<Case> casesList = new List<Case>();
		Case cs = new Case();
		cs.Status = 'New';
		cs.OwnerId = usr.Id;
		cs.Description = 'ascdas';
		cs.Subject = 'TestSubject';
		cs.recordTypeId = selector.caseRecordTypeId;
		selector.cases = casesList;

		EmailService service = new EmailService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		Messaging.InboundEmail inboundEmail = new Messaging.InboundEmail();
		inboundEmail.fromAddress = 'testcontact@citation.co.uk';
		inboundEmail.toAddresses = new List<String>{ 'usr.AliasEmail__c' };
		inboundEmail.subject = 'TestSubject';
		inboundEmail.plainTextBody = 'ascdas';

		Messaging.InboundEnvelope inboundEnvelope = new Messaging.InboundEnvelope();
		inboundEnvelope.fromAddress = 'testcontact@citation.co.uk';
		inboundEnvelope.toAddress = usr.AliasEmail__c;

		test.startTest();
		Messaging.InboundEmailResult emailResult = service.emailMessageHandlerForHighValueCustomer(InboundEmail, inboundEnvelope, 'ELT_Advice_Generic');
		test.stopTest();

		System.assertEquals(false, emailResult.success);
		System.assertNotEquals(null, emailResult.message);
	}

	@isTest
	public static void given_AgentUserExists_whenGetAgentUsersCalled_Then_Selector_ReturnsAgentUsers() {
		User citationBDMUser = TestDataFactory.createUser_Generic('Citation BDM', '', false);
		citationBDMUser.AliasEmail__c = 'testemailservice1@citation.co.uk';
		insert citationBDMUser;

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		Map<Id, User> agentIds = selector.getAgentUsers(new List<String>{ 'testemailservice1@citation.co.uk' });
		Test.stopTest();

		system.assertEquals(citationBDMUser.Id, agentIds.Values()[0].Id, 'Expected User Id not returned');
	}

	@isTest
	public static void given_NoAgentUserExists_whenGetAgentUsersCalled_Then_Selector_ReturnsNoAgentUsers() {
		User citationBDMUser = TestDataFactory.createUser_Generic('Citation BDM', '', false);
		citationBDMUser.AliasEmail__c = 'testemailservice1@citation.co.uk';
		insert citationBDMUser;

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		Map<Id, User> agentIds = selector.getAgentUsers(new List<String>{ 'test2emailservice1@citation.co.uk' });
		Test.stopTest();

		system.assertEquals(0, agentIds.size(), 'Expected 0 Users');
	}

	@isTest
	public static void given_QueueExistsWithGivenName_whenGetQueueByNameCalled_Then_Selector_ReturnsQueueByName() {
		Group g = new Group(Type = 'Queue', Name = 'QueueTest');
		insert g;
		QueueSObject q = new QueueSObject(SobjectType = 'Case', QueueId = g.Id);
		insert q;

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		id queueId = selector.getQueueByName('QueueTest');
		Test.stopTest();

		system.assertEquals(q.QueueId, queueId, 'Expected queue Id Not returned');
	}

	@isTest
	public static void given_NoQueueExistsWithGivenName_whenGetQueueByNameCalled_Then_Selector_ReturnsNoQueueByName() {
		Group g = new Group(Type = 'Queue', Name = 'QueueTest');
		insert g;
		QueueSObject q = new QueueSObject(SobjectType = 'Lead', QueueId = g.Id);
		insert q;

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		id queueId = selector.getQueueByName('QueueTest2');
		Test.stopTest();

		system.assertEquals(null, queueId, 'Expected queue Id Null');
	}

	@isTest
	public static void given_ContactExistsWithGivenEmail_whenGetContactsByEmailCalled_Then_Selector_ReturnsContactsByEmail() {
		List<Account> acList = TestDataFactory.getAccounts(1, 'iHASCO TEST', true);
		Contact c = new Contact();
		c.FirstName = 'Test';
		c.LastName = 'Contact';
		c.AccountId = acList[0].Id;
		c.Phone = '01912553955';
		c.MobilePhone = '70875327792';
		c.Email = 'testcontact@citation.co.uk';
		insert c;

		Test.setFixedSearchResults(new List<String>{ c.id });
		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		List<Contact> contacts = selector.getContactsByEmail('testcontact@citation.co.uk');
		Test.stopTest();

		system.assertEquals(1, contacts.size(), 'Expected one contact not returned');
	}

	@isTest
	public static void given_NoContactExistsWithGivenEmail_whenGetContactsByEmailCalled_Then_Selector_ReturnsNoContactsByEmail() {
		List<Account> acList = TestDataFactory.getAccounts(1, 'iHASCO TEST', true);
		Contact c = new Contact();
		c.FirstName = 'Test';
		c.LastName = 'Contact';
		c.AccountId = acList[0].Id;
		c.Phone = '01912553955';
		c.MobilePhone = '70875327792';
		c.Email = 'testcontact@citation.co.uk';
		insert c;

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		List<Contact> contacts = selector.getContactsByEmail('testcontact2@citation.co.uk');
		Test.stopTest();

		system.assertEquals(0, contacts.size(), 'Expected 0 contacts');
	}

	@isTest
	public static void given_CaseExistsWithGivenIds_whenGetCasesbyCaseIdsCalled_Then_Selector_ReturnsCasesbyCaseIds() {
		List<Case> caselist = new List<Case>();
		Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
		Case casephone = new Case();
		casephone.RecordTypeId = rTId;
		casephone.Origin = 'Phone - Atlas Support';
		casephone.Status = 'New';
		caselist.add(casephone);
		Case cemail = new Case();
		cemail.RecordTypeId = rTID;
		cemail.Origin = 'Email - Atlas Support';
		cemail.Status = 'New';
		caselist.add(cemail);
		insert (caselist);
		List<id> caseIds = new List<id>();
		for (Case c : caselist) {
			caseIds.add(c.id);
		}

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		List<Case> Cases = selector.getCasesbyCaseIds(caseIds);
		Test.stopTest();

		system.assertEquals(caseIds.size(), Cases.size(), 'Expected number of cases not returned');
	}

	@isTest
	public static void given_NoCaseExistsWithGivenIds_whenGetCasesbyCaseIdsCalled_Then_Selector_ReturnsNoCasesbyCaseIds() {
		List<Case> caselist = new List<Case>();
		Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
		Case casephone = new Case();
		casephone.RecordTypeId = rTId;
		casephone.Origin = 'Phone - Atlas Support';
		casephone.Status = 'New';
		caselist.add(casephone);
		insert casephone;

		Test.startTest();
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		List<Case> cases = selector.getCasesbyCaseIds(new List<id>{ String.valueOf(casephone.Id).substring(0, 15).toUpperCase() });
		Test.stopTest();

		//system.assertEquals(1, cases.size(), 'Expected number of cases 1');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInToAddress_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.toAddresses = new List<String>{System.Label.HRAdvice_Personal};
		MockSelector selector = new MockSelector();
		EmailService service = new EmailService(selector);

		Test.startTest();
		Messaging.InboundEmailResult emr = service.emailMessageHandlerForHighValueCustomer(email, env, 'ELT_Advice_Generic');
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInCcAddress_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.ccAddresses = new List<String>{System.Label.HRAdvice_Personal};
		email.toAddresses = new List<String>{'Test@test.co.uk'};
		MockSelector selector = new MockSelector();
		EmailService service = new EmailService(selector);

		Test.startTest();
		Messaging.InboundEmailResult emr = service.emailMessageHandlerForHighValueCustomer(email, env, 'ELT_Advice_Generic');
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInToAddress_SmallLetters_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.toAddresses = new List<String>{'hradvice@citation.co.uk'};
		email.ccAddresses = new List<String>{'Test@test.co.uk'};
		MockSelector selector = new MockSelector();
		EmailService service = new EmailService(selector);

		Test.startTest();
		Messaging.InboundEmailResult emr = service.emailMessageHandlerForHighValueCustomer(email, env, 'ELT_Advice_Generic');
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInToAddress_CaptialLetters_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.toAddresses = new List<String>{'HRADVICE@citation.co.uk'};
		email.ccAddresses = new List<String>{'Test@test.co.uk'};
		MockSelector selector = new MockSelector();
		EmailService service = new EmailService(selector);

		Test.startTest();
		Messaging.InboundEmailResult emr = service.emailMessageHandlerForHighValueCustomer(email, env, 'ELT_Advice_Generic');
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}

	private static Messaging.InboundEmail buildEmailMessage() {
		Messaging.InboundEmail email = new Messaging.InboundEmail();

		Messaging.InboundEmail.Header hditem = new Messaging.InboundEmail.Header();
		email.headers = new Messaging.InboundEmail.Header[1];
		hditem.name = 'Message-ID';
		hditem.value = 'xyz';
		email.fromAddress = 'test@test.com';
		email.headers[0] = hditem;
		email.subject = 'testop1Job_Reference';
		email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
		Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];
		Messaging.InboundEmail.TextAttachment[] textAttachments = new Messaging.InboundEmail.TextAttachment[1];
		Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.Filename = 'test.pdf';
		binaryAttachment.body = Blob.valueOf('xyz');
		binaryAttachments.add(binaryAttachment);
		return email;
	}
	class MockSelector implements EmailService.ISelector {
		Map<Id, User> users;
		Id queueId;
		List<Contact> contacts;
		List<Case> cases;
		Id caseRecordTypeId;
		Id caseId;

		public Map<Id, User> getAgentUsers(List<String> aliasEmailAddresses) {
			return users;
		}
		public Id getQueueByName(String queueName) {
			return queueId;
		}
		public List<Contact> getContactsByEmail(String emailAddress) {
			return contacts;
		}
		public List<Case> getCasesbyCaseIds(List<id> caseIds) {
			return cases;
		}
		public Id getRecordTypeId(SObjectType objType, String devName) {
			return caseRecordTypeId;
		}
		public Id getCaseIdFromEmailHeader(Messaging.InboundEmail email)
		{
			return caseId;
		}
	}
}