@IsTest
private class SendToJiraCmpCtrlTest {
	class JitterbitServer implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();

			Map<String, Object> payload = getPayload(request.getBody());

			String action = (String) payload.get('action');
			Map<String, Object> message = (Map<String, Object>) payload.get('message');

			switch on action {
				when 'createTicket' {
					if ((String) message.get('accountName') == 'Test' && (String) message.get('contactName') == 'test test') {
						response.setStatusCode(202);
					}
				}
				when 'createComment' {
					if ((String) message.get('comment') == 'test' && (String) message.get('jiraTicketNumber') == 'Pending...') {
						response.setStatusCode(202);
					}
				}
			}

			return response;
		}

		private Map<String, Object> getPayload(String requestBody) {
			return (Map<String, Object>) JSON.deserializeUntyped(requestBody);
		}
	}

	@TestSetup
	static void init() {
		Account testAccount = new Account(Name = 'Test');
		insert testAccount;

		Contact testContact = new Contact(FirstName = 'test', LastName = 'test', Email = 'test@test.com', AccountId = testAccount.Id);
		insert testContact;

		Id atlasSupportRTId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();

		List<Case> testCaseItems = new List<Case>();

		testCaseItems.add(new Case(Subject = 'test1', Description = 'test1', RecordTypeId = atlasSupportRTId, AccountId = testAccount.Id, ContactId = testContact.Id, Jira_Ticket_Number__c = 'Pending...', Issue_Type__c = 'Data Change', Priority = 'Normal', Type = 'EL Area', Issue_Area__c = 'Absence', Case_Reason__c = 'Existing problem', Impacted_Users__c = 'Multiple Clients', Status = 'Awaiting Information'));

		insert testCaseItems;

		ContentVersion cvItem = new ContentVersion(Title = 'Test1', PathOnClient = 'Test1.txt', VersionData = Blob.valueOf('test'));
		insert cvItem;

		Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvItem.Id LIMIT 1].ContentDocumentId;

		insert new ContentDocumentLink(LinkedEntityId = testCaseItems.get(0).Id, ContentDocumentId = cdId);
	}

	static Id getCaseId(String name) {
		return [SELECT Id FROM Case WHERE Subject = :name LIMIT 1].Id;
	}

	static List<Id> getContentDocumentIds(Map<String, Object> initParams) {
		List<Id> result = new List<Id>();

		for (Map<String, Object> availableOptionsItem : (List<Map<String, Object>>) initParams.get('availableOptions')) {
			result.add((String) availableOptionsItem.get('value'));
		}

		return result;
	}

	@IsTest
	static void whenSendCaseToJiraIsCalledWithRightJSONData_NoExceptionIsReceived() {
		Id caseId = getCaseId('test1');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new JitterbitServer());

		Map<String, Object> attachmentsInitParams = AttachmentsListCtrl.getInitialParams(caseId);

		Map<String, Object> initParams = SendToJiraCmpCtrl.getInitParams(caseId);
		System.assert(String.isNotBlank((String) initParams.get('jiraTicketNumber')), 'No params');

		Map<String, String> updatedCaseData = new Map<String, String>();
		updatedCaseData.put('recordId', caseId);
		updatedCaseData.put('updatedIssueType', 'Bug');
		updatedCaseData.put('updatedCasePriority', 'Low');
		updatedCaseData.put('updatedCaseReason', 'Existing problem');
		updatedCaseData.put('updatedIssueArea', 'Absence');
		updatedCaseData.put('updatedImpactedUsers', 'Multiple Clients');
		updatedCaseData.put('updatedSubject', 'test1');
		updatedCaseData.put('updatedType', 'EL Area');

		Boolean hasException = false;
		try {
			SendToJiraCmpCtrl.sendCaseToJira(updatedCaseData, getContentDocumentIds(attachmentsInitParams));
		} catch (Exception e) {
			hasException = true;
			System.debug(e.getMessage());
		}

		System.assert(!hasException, 'Exception');

		Test.stopTest();
	}

	@IsTest
	static void whenCorrectDataIsSentTo_sendCaseToJira_ThenCaseIsCorrectlyUpdated() {
		Id caseId = getCaseId('test1');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new JitterbitServer());

		Map<String, Object> attachmentsInitParams = AttachmentsListCtrl.getInitialParams(caseId);

		Map<String, Object> initParams = SendToJiraCmpCtrl.getInitParams(caseId);
		System.assert(String.isNotBlank((String) initParams.get('jiraTicketNumber')), 'No params');

		Map<String, String> updatedCaseData = new Map<String, String>();
		updatedCaseData.put('recordId', caseId);
		updatedCaseData.put('updatedIssueType', 'Product Change Request');
		updatedCaseData.put('updatedCasePriority', 'High');
		updatedCaseData.put('updatedCaseReason', 'Existing problem');
		updatedCaseData.put('updatedIssueArea', 'Absence');
		updatedCaseData.put('updatedImpactedUsers', 'Multiple Clients');
		updatedCaseData.put('updatedSubject', 'test1');
		updatedCaseData.put('updatedType', 'EL Area');
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		try {
			SendToJiraCmpCtrl.sendCaseToJira(updatedCaseData, getContentDocumentIds(attachmentsInitParams));
		} catch (Exception e) {
			System.debug(e.getMessage());
		}

		List<case> updatedCases = uow.getRecords(Case.SObjectType);
		Case c = updatedCases[0];
		Assert.areEqual('Product Change Request', c.issue_type__c);
		Assert.areEqual('High', c.priority);
		Test.stopTest();
	}

	@IsTest
	static void whenIncorrectDataIsSentTo_sendCaseToJira_ThenExceptionIsReturned() {
		Id caseId = getCaseId('test1');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new JitterbitServer());

		Map<String, Object> attachmentsInitParams = AttachmentsListCtrl.getInitialParams(caseId);

		Map<String, Object> initParams = SendToJiraCmpCtrl.getInitParams(caseId);
		System.assert(String.isNotBlank((String) initParams.get('jiraTicketNumber')), 'No params');

		Map<String, String> updatedCaseData = new Map<String, String>();
		updatedCaseData.put('recordId', caseId);
		updatedCaseData.put('updatedIssueType', 'Task');
		updatedCaseData.put('updatedCasePriority', 'Low');
		updatedCaseData.put('updatedType', 'EL Area');
		updatedCaseData.put('updatedIssueArea', 'Citation');

		try {
			SendToJiraCmpCtrl.sendCaseToJira(updatedCaseData, getContentDocumentIds(attachmentsInitParams));
			Assert.fail('Exception failure is always an option');
		} catch (Exception ex) {
			System.assert(ex.getMessage().contains('Script-thrown exception'), 'Error');
			Assert.isInstanceOfType(ex, AuraHandledException.class);
		}
		Assert.areNotEqual('Task', [SELECT issue_type__c FROM case WHERE Subject = 'test1' LIMIT 1].issue_type__c);
		Test.stopTest();
	}

	@IsTest
	static void testSendCaseCommentToJira() {
		Id caseId = getCaseId('test1');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new JitterbitServer());

		Map<String, Object> attachmentsInitParams = AttachmentsListCtrl.getInitialParams(caseId);

		Boolean hasException = false;
		Map<String, String> caseCommentData = new Map<String, String>();
		caseCommentData.put('comment', 'test');
		caseCommentData.put('updatedCasePriority', 'Low');
		caseCommentData.put('recordId', caseId);

		try {
			SendToJiraCmpCtrl.sendCaseCommentToJira(caseCommentData, getContentDocumentIds(attachmentsInitParams));
		} catch (Exception e) {
			hasException = true;
		}

		System.assert(!hasException, 'Exception');

		Test.stopTest();
	}

	@IsTest
	static void whenIncorrectDataIsSentTo_sendCaseToJira_ThenCorrectStatusCodeNotReturned() {
		Id caseId = getCaseId('test1');
        Account acc=[select id,name from Account where name='Test' limit 1 ];
		acc.name='Failure Test Account';
		update acc;
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new JitterbitServer());

		Map<String, Object> attachmentsInitParams = AttachmentsListCtrl.getInitialParams(caseId);

		Map<String, Object> initParams = SendToJiraCmpCtrl.getInitParams(caseId);
		System.assert(String.isNotBlank((String) initParams.get('jiraTicketNumber')), 'No params');

		Map<String, String> updatedCaseData = new Map<String, String>();
		updatedCaseData.put('recordId', caseId);
		updatedCaseData.put('updatedIssueType', 'Product Change Request');
		updatedCaseData.put('updatedCasePriority', 'High');
		updatedCaseData.put('updatedCaseReason', 'Existing problem');
		updatedCaseData.put('updatedIssueArea', 'Absence');
		updatedCaseData.put('updatedImpactedUsers', 'Multiple Clients');
		updatedCaseData.put('updatedSubject', 'test1');
		updatedCaseData.put('updatedType', 'EL Area');

		try {
			SendToJiraCmpCtrl.sendCaseToJira(updatedCaseData, getContentDocumentIds(attachmentsInitParams));
			Assert.fail('Exception failure is always an option');
		} catch (Exception ex) {
			System.assert(ex.getMessage().contains('Script-thrown exception'), 'Error');
			Assert.isInstanceOfType(ex, AuraHandledException.class);
		}
		
		Test.stopTest();
	}
}