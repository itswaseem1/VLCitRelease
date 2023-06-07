@isTest
public class EmailMessageService_Test {
    @isTest
	public static void given_IncomingEmail_When_CaseOpened_Then_CaseStatus_Updated_WithNewInfoAdded() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		Id caseRecordTypeId= TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        Id caseId = TestUtility.getFakeId(SObjectType.Case.SObjectType);
		Map<String, Case> casesMap = new Map<String, Case>();

		Case caseRecord = new Case();
		caseRecord.Status = 'Open';
		caseRecord.Description = 'ascdas';
		caseRecord.Subject = 'TestSubject';
		caseRecord.recordTypeId = caseRecordTypeId;
        caseRecord.Id = caseId;
        casesMap.Put('UKSM_Support', caseRecord);
		selector.casesMap = casesMap;
        List<EmailMessage> emailMessages=new List<EmailMessage>();
        emailMessages.add( new EmailMessage(
                ParentId = caseId,
                Incoming = true
        ));
		Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
        EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
            Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        EmailCasesReplySettingMap.put('UKSM_Support', emailCasesReplySetting);
        selector.emailCaseReplySetting = EmailCasesReplySettingMap;
		EmailMessageService service = new EmailMessageService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnNew(emailMessages);
		test.stopTest();

		System.assertEquals('New Info Added', caseRecord.Status);
	}
    
    @isTest
	public static void given_NotIncomingEmail_When_CaseOpened_Then_CaseStatus_NotUpdated_WithNewInfoAdded() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		Id caseRecordTypeId= TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        Id caseId = TestUtility.getFakeId(SObjectType.Case.SObjectType);
		Map<String, Case> casesMap = new Map<String, Case>();

		Case caseRecord = new Case();
		caseRecord.Status = 'Open';
		caseRecord.Description = 'ascdas';
		caseRecord.Subject = 'TestSubject';
		caseRecord.recordTypeId = caseRecordTypeId;
        caseRecord.Id = caseId;
        casesMap.Put('UKSM_Support', caseRecord);
		selector.casesMap = casesMap;
        List<EmailMessage> emailMessages=new List<EmailMessage>();
        emailMessages.add( new EmailMessage(
                ParentId = caseId,
                Incoming = false
        ));
		Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
        EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
            Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        EmailCasesReplySettingMap.put('UKSM_Support', emailCasesReplySetting);
        selector.emailCaseReplySetting = EmailCasesReplySettingMap;
		EmailMessageService service = new EmailMessageService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnNew(emailMessages);
		test.stopTest();

        System.assertNotEquals('New Info Added', caseRecord.Status);
	}
    
    @isTest
	public static void given_IncomingEmail_When_CaseOpened_Then_CaseStatus_NotUpdated_WithNewInfoAdded() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		Id caseRecordTypeId= TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        Id caseId = TestUtility.getFakeId(SObjectType.Case.SObjectType);
		Map<String, Case> casesMap = new Map<String, Case>();

		Case caseRecord = new Case();
		caseRecord.Status = 'New';
		caseRecord.Description = 'ascdas';
		caseRecord.Subject = 'TestSubject';
		caseRecord.recordTypeId = caseRecordTypeId;
        caseRecord.Id = caseId;
        casesMap.Put('UKSM_Support', caseRecord);
		selector.casesMap = casesMap;
        List<EmailMessage> emailMessages=new List<EmailMessage>();
        emailMessages.add( new EmailMessage(
                ParentId = caseId,
                Incoming = true
        ));
		Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
        EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
            Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        EmailCasesReplySettingMap.put('UKSM_Support', emailCasesReplySetting);
        selector.emailCaseReplySetting = EmailCasesReplySettingMap;
		EmailMessageService service = new EmailMessageService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnNew(emailMessages);
		test.stopTest();

		System.assertNotEquals('New Info Added', caseRecord.Status);
	}
	
	@isTest
	public static void given_IncomingEmail_When_CaseNotOpened_Then_CaseStatus_NotUpdated_WithNewInfoAdded() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		Id caseRecordTypeId= TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        Id caseId = TestUtility.getFakeId(SObjectType.Case.SObjectType);
		Map<String, Case> casesMap = new Map<String, Case>();

		Case caseRecord = new Case();
		caseRecord.Status = 'New';
		caseRecord.Description = 'ascdas';
		caseRecord.Subject = 'TestSubject';
		caseRecord.recordTypeId = caseRecordTypeId;
        caseRecord.Id = caseId;
        casesMap.Put('UKSM_Support', caseRecord);
		selector.casesMap = casesMap;
        List<EmailMessage> emailMessages=new List<EmailMessage>();
        emailMessages.add( new EmailMessage(
                ParentId = caseId,
                Incoming = true
        ));
		Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
        EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
            Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        EmailCasesReplySettingMap.put('UKSM_Support', emailCasesReplySetting);
        selector.emailCaseReplySetting = EmailCasesReplySettingMap;
		EmailMessageService service = new EmailMessageService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnNew(emailMessages);
		test.stopTest();

		System.assertNotEquals('New Info Added', caseRecord.Status);
	}
    
    @isTest
	public static void given_IncomingEmail_When_NoParentCase_Then_CaseStatus_NotUpdated_WithNewInfoAdded() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		Id caseRecordTypeId= TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        Id caseId = TestUtility.getFakeId(SObjectType.Case.SObjectType);
		Map<String, Case> casesMap = new Map<String, Case>();

		Case caseRecord = new Case();
		caseRecord.Status = 'New';
		caseRecord.Description = 'ascdas';
		caseRecord.Subject = 'TestSubject';
		caseRecord.recordTypeId = caseRecordTypeId;
        caseRecord.Id = caseId;
        casesMap.Put('UKSM_Support', caseRecord);
		selector.casesMap = casesMap;
        List<EmailMessage> emailMessages=new List<EmailMessage>();
        emailMessages.add( new EmailMessage(
                Incoming = true
        ));
		Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
        EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
            Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        EmailCasesReplySettingMap.put('UKSM_Support', emailCasesReplySetting);
        selector.emailCaseReplySetting = EmailCasesReplySettingMap;
		EmailMessageService service = new EmailMessageService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnNew(emailMessages);
		test.stopTest();

		System.assertNotEquals('New Info Added', caseRecord.Status);
	}
    
    @isTest
	public static void given_IncomingEmail_When_Case_WithDifferentRecordType_Then_CaseStatus_NotUpdated_WithNewInfoAdded() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		Id caseRecordTypeId= TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        Id caseId = TestUtility.getFakeId(SObjectType.Case.SObjectType);
		Map<String, Case> casesMap = new Map<String, Case>();

		Case caseRecord = new Case();
		caseRecord.Status = 'New';
		caseRecord.Description = 'ascdas';
		caseRecord.Subject = 'TestSubject';
		caseRecord.recordTypeId = caseRecordTypeId;
        caseRecord.Id = caseId;
        casesMap.Put('DifferentType', caseRecord);
		selector.casesMap = casesMap;
        List<EmailMessage> emailMessages=new List<EmailMessage>();
        emailMessages.add( new EmailMessage(
                ParentId = caseId,
                Incoming = true
        ));
		Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
        EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
            Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        EmailCasesReplySettingMap.put('UKSM_Support', emailCasesReplySetting);
        selector.emailCaseReplySetting = EmailCasesReplySettingMap;
		EmailMessageService service = new EmailMessageService(selector);

		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnNew(emailMessages);
		test.stopTest();

		System.assertNotEquals('New Info Added', caseRecord.Status);
	}
    
    @isTest
	public static void given_CaseExistsWithGivenIds_whenGetCasesbyCaseIdsCalled_Then_Selector_ReturnsCasesbyCaseIds() {
		List<Case> caselist = new List<Case>();
		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
		Case casephone = new Case();
		casephone.RecordTypeId = recordTypeId;
		casephone.Origin = 'Phone - Atlas Support';
		casephone.Status = 'New';
		caselist.add(casephone);
		Case cemail = new Case();
		cemail.RecordTypeId = recordTypeId;
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

		system.assertEquals(caseIds.size(), Cases.size(), 'Expected number of cases returned');
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
        List<Case> cases = new List<Case>();
		cases = selector.getCasesbyCaseIds(new List<id>{ String.valueOf(casephone.Id).substring(0, 15).toUpperCase() });
		Test.stopTest();

		system.assertEquals(0, cases.size());
	}
    
    @isTest 
    public static void given_EmailCustomSettings_WhenemailCaseReplySettingCalled_Then_Selector_ReturnCustomSettingData(){
    	EmailCasesReplySetting__c emailCasesReplySetting = new EmailCasesReplySetting__c(
          Incoming_Email_Case_Status_update__c = 'New Info Added',
            Case_Statuses_Include__c ='Resolved,Open',
           Name ='UKSM_Support' 
        );
        
        Insert emailCasesReplySetting;
        
        Test.startTest();
		EmailMessageService.EmailMessageServiceSelector selector = new EmailMessageService.EmailMessageServiceSelector(); 
        Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
		EmailCasesReplySettingMap = selector.getEmailCasesReplySetting();
		Test.stopTest();
        
       System.assertEquals(EmailCasesReplySettingMap.values().size(), 1);
    }
    
    @isTest 
    public static void given_NoEmailCustomSettings_WhenemailCaseReplySettingCalled_Then_Selector_ReturnNoCustomSettingData(){
        
        Test.startTest();
		EmailMessageService.EmailMessageServiceSelector selector = new EmailMessageService.EmailMessageServiceSelector(); 
        Map<String,EmailCasesReplySetting__c> EmailCasesReplySettingMap= new Map<String,EmailCasesReplySetting__c>();
		EmailCasesReplySettingMap = selector.getEmailCasesReplySetting();
		Test.stopTest();
        
       System.assertEquals(EmailCasesReplySettingMap.values().size(), 0);
    }

       
	class MockSelector implements EmailMessageService.ISelector {

        Map<String,EmailCasesReplySetting__c> emailCaseReplySetting;
		Map<String, Case> casesMap;

		public Map<String, Case> getCasesbyCaseIds(List<id> caseIds) {
			return casesMap;
		}


        public Map<String,EmailCasesReplySetting__c> getEmailCasesReplySetting(){
            return emailCaseReplySetting;
        }
	}

}