@isTest
public class HighValueCustomerEmailServiceHandlerTest extends RecordTypeSelector {
	@testSetup
	static void setupData() {
		Id Profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		List<User> users = new List<User>{ new User(firstName = 'Test', LastName = 'Elttest1', email = 'testeltCaseemail12311@citation.co.uk', AliasEmail__c = 'testELTEmail1@citation.co.uk', Username = 'testeltCaseemail12311@citation.co.uk', Alias = 'etls', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = Profile, LanguageLocaleKey = 'en_US') };
		insert users;
	}

	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_ExistinCaseNotFound_Then_NewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = buildEmailMessage();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		Map<id, User> users = new Map<id, User>([SELECT Id, AliasEmail__c FROM USER WHERE AliasEmail__c LIKE 'testELTEmail%']);
		List<String> addresses = new List<String>();
		for (User u : users.values()) {
			addresses.add(u.AliasEmail__c);
		}
		email.toAddresses = addresses;

		Test.startTest();
		HighValueCustomerEmailServiceHandler emailHandler = new HighValueCustomerEmailServiceHandler();
		Messaging.InboundEmailResult emr = emailHandler.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(true, emr.success, 'Call to EmailService was not successfull');
		System.assertEquals(1, [SELECT id FROM Case].size(), 'Single Case was not created to single email Message');
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
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInToAddress_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = buildEmailMessage();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.toAddresses = new List<String>{System.Label.HRAdvice_Personal};

		Test.startTest();
		HighValueCustomerEmailServiceHandler emailHandler = new HighValueCustomerEmailServiceHandler();
		Messaging.InboundEmailResult emr = emailHandler.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInCcAddress_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = buildEmailMessage();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.ccAddresses = new List<String>{System.Label.HRAdvice_Personal};
		email.toAddresses = new List<String>{'Test@test.co.uk'};

		Test.startTest();
		HighValueCustomerEmailServiceHandler emailHandler = new HighValueCustomerEmailServiceHandler();
		Messaging.InboundEmailResult emr = emailHandler.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInToAddress_SmallLetters_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = buildEmailMessage();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.toAddresses = new List<String>{'hradvice@citation.co.uk'};
		email.ccAddresses = new List<String>{'Test@test.co.uk'};

		Test.startTest();
		HighValueCustomerEmailServiceHandler emailHandler = new HighValueCustomerEmailServiceHandler();
		Messaging.InboundEmailResult emr = emailHandler.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}
	
	@isTest
	private static void given_InboundEmail_ReceivedFromHighValueCustomers_When_HRAdviceInToAddress_CaptialLetters_Then_NoNewCase_Created_And_EmailMessageAttached() {
		Messaging.InboundEmail email = buildEmailMessage();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		env.fromAddress = 'test@Citation.co.uk';
		email.toAddresses = new List<String>{'HRADVICE@citation.co.uk'};
		email.ccAddresses = new List<String>{'Test@test.co.uk'};

		Test.startTest();
		HighValueCustomerEmailServiceHandler emailHandler = new HighValueCustomerEmailServiceHandler();
		Messaging.InboundEmailResult emr = emailHandler.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(true, emr.success);
		System.assertEquals(0, [SELECT id FROM Case].size(), 'No Case Created');
		System.assertNotEquals(null, [SELECT id FROM EmailMessage], 'Email Message was not created');
	}

}