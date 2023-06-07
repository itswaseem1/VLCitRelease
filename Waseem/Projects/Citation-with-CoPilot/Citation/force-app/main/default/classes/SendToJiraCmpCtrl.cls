public with sharing class SendToJiraCmpCtrl {
	private static final String ATLAS_RT_ID = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('S360_Atlas_Support').getRecordTypeId();
	private static final String QMS_C_S = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Connect_Support').getRecordTypeId();

	public static final Map<Id, String> RT_JIRA_TICKET_LABEL_MAP = new Map<Id, String>{ ATLAS_RT_ID => 'Atlas_Support', QMS_C_S => 'Connect_Support' };

	private static final List<String> CASE_FIELDS = new List<String>{ 'Subject', 'Description', 'CaseNumber', 'Jira_Ticket_Number__c', 'Jira_Ticket_Link__c', 'Priority', 'ThreadId__c', 'Origin', 'Contact.Name', 'ContactEmail', 'Account.Name', 'RecordTypeId', 'Issue_Type__c', 'Issue_Area__c', 'Reason', 'Impacted_Users__c', 'Type' };

	private static final String JITTERBIT_SETTINGS_NAME = 'SendToJIRA';

	private static final Set<Integer> OK_STATUS_CODES = new Set<Integer>{ 200, 201, 202 };

	public class SendTOJiraException extends Exception {
	}

	private class JitterbitPayload {
		public String action;
		public Object message;

		public JitterbitPayload(String action, Object message) {
			this.action = action;
			this.message = message;
		}

		public override String toString() {
			return JSON.serialize(this);
		}
	}

	private static JitterbitSettings__mdt jsItem {
		get {
			return (jsItem == null) ? (jsItem = getJitterbitSettingsItem()) : jsItem;
		}
		set;
	}

	private static JitterbitSettings__mdt getJitterbitSettingsItem() {
		List<JitterbitSettings__mdt> jbItems = [SELECT Endpoint__c, Username__c, Password__c FROM JitterbitSettings__mdt WHERE DeveloperName = :JITTERBIT_SETTINGS_NAME LIMIT 1];
		return (!jbItems.isEmpty()) ? jbItems.get(0) : null;
	}

	@AuraEnabled(Cacheable=true)
	public static Map<String, Object> getInitParams(Id recordId) {
		return new Map<String, Object>{ 'jiraTicketNumber' => getCaseItem(recordId)?.Jira_Ticket_Number__c, 'jiraTicketLink' => getCaseItem(recordId)?.Jira_Ticket_Link__c, 'formValues' => getFormValues(recordId) };
	}

	private static Map<String, Object> getFormValues(Id recordId) {
		Case caseItem = getCaseItem(recordId);

		return new Map<String, Object>{ 'ticketLabel' => RT_JIRA_TICKET_LABEL_MAP.get(caseItem.RecordTypeId), 'updatedIssueType' => caseItem.Issue_Type__c, 'updatedCasePriority' => caseItem.Priority, 'updatedSubject' => caseItem.Subject, 'updatedIssueArea' => caseItem.Issue_Area__c, 'updatedCaseReason' => caseItem.Reason, 'updatedImpactedUsers' => caseItem.Impacted_Users__c, 'updatedType' => caseItem.Type };
	}

	private static Case getCaseItem(Id recordId) {
		List<String> queryFields = new List<String>(CASE_FIELDS);
		return (Case) Database.query(String.format('SELECT {0} FROM Case WHERE Id = :recordId', new List<String>{ String.join(queryFields, ',') })).get(0);
	}

	/*This is called from LWC when case data has to be sent to Jira*/
	@AuraEnabled
	public static void sendCaseToJira(Map<String, Object> updatedCaseData, List<Id> contentVersionIds) {
		try {
			Id recordId = String.valueOf(updatedCaseData.get('recordId'));
			sendToServer(new JitterbitPayload('createTicket', new CreateTicketMessage(getCaseItem(recordId), updatedCaseData, contentVersionIds)).toString());
			updateCase(recordId,updatedCaseData);
			} 
			catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static void updateCase(Id recordId, Map<String, Object> updatedCaseData) {
		Case caseItemToUpdate = prepareCaseToUpdate(recordId,updatedCaseData);

		updateCaseUsingUOW(caseItemToUpdate);
	}

	private static Case prepareCaseToUpdate(Id recordId,Map<String, Object> updatedCaseData){
		
			Case caseItemToUpdate = new Case();
			caseItemToUpdate.id = recordId;
			caseItemToUpdate.type = String.valueof(updatedCaseData.get('updatedType'));
			caseItemToUpdate.Status = 'Awaiting Information';
			caseItemToUpdate.Sub_Status__c = 'Jira Ticket';
			caseItemToUpdate.Priority = String.valueOf(updatedCaseData.get('updatedCasePriority'));
			caseItemToUpdate.Issue_Type__c = String.valueOf(updatedCaseData.get('updatedIssueType'));
			caseItemToUpdate.Issue_Area__c = String.valueof(updatedCaseData.get('updatedIssueArea'));
			caseItemToUpdate.reason = String.valueof(updatedCaseData.get('updatedCaseReason'));
			caseItemToUpdate.Impacted_Users__c =  String.valueof(updatedCaseData.get('updatedImpactedUsers'));
			caseItemToUpdate.Subject = String.valueof(updatedCaseData.get('updatedSubject'));
			
			String jiraTicketNumber = getCaseItem(recordId)?.Jira_Ticket_Number__c;
		    	if (jiraTicketNumber == null || String.isBlank(jiraTicketNumber) || jiraTicketNumber.containsIgnoreCase('Pending')) {
				caseItemToUpdate.Jira_Ticket_Number__c = 'Pending...';
			}
			
			return caseItemToUpdate;
		
	}

	/*This is called from LWC when case comments have to be sent to Jira*/
	@AuraEnabled
	public static void sendCaseCommentToJira(Map<String, Object> caseCommentData, List<Id> contentVersionIds) {
		try {
			Id recordId = String.valueOf(caseCommentData.get('recordId'));
			String comment = String.valueOf(caseCommentData.get('comment'));
			String jiraTicketNumber = getCaseItem(recordId).Jira_Ticket_Number__c;
			String updatedCasePriority = String.valueOf(caseCommentData.get('updatedCasePriority'));
			sendToServer(new JitterbitPayload('createComment', new CreateCommentMessage(jiraTicketNumber, comment , contentVersionIds)).toString());
			addCommentToCaseComments(recordId, comment);
			updateStatus(recordId, updatedCasePriority);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static void updateStatus(Id recordId, String updatedCasePriority) {
		Case caseItemToUpdate = new Case(Id = recordId, Status = 'Awaiting Information', Sub_Status__c = 'Jira Ticket', Priority = updatedCasePriority);
		updateCaseUsingUOW(caseItemToUpdate);
	}

	private static void updateCaseUsingUOW(Case caseItemToUpdate){
		List<case> updatedCase = new List<case>{ caseItemToUpdate };
		if (Case.SObjectType.getDescribe().isUpdateable()) {
			IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
			uow.updateRecords(updatedCase);
		}
	}

	
	/*When The body has been prepared send this data to Jitterbit so that
	 Jitterbit sends the data to Jira*/
	private static void sendToServer(String body) {
		if (jsItem != null) {
			HttpRequest request = new HttpRequest();
			request.setEndpoint(jsItem.Endpoint__c);
			request.setMethod('POST');
			request.setHeader('Authorization', getAuthorizationHeader()); //NOPMD
			request.setHeader('Content-Type', 'application/json');
			request.setBody(body);
			
			HttpResponse response = (new Http()).send(request);
			if (!OK_STATUS_CODES.contains(response.getStatusCode())) {
				throw new SendTOJiraException(response.getBody());
			}
		} else {
			throw new SendTOJiraException('No Jitterbit Settings. Please, contact System Administrator');
		}
	}

	private static void addCommentToCaseComments(Id caseId, String comment) {
			if (CaseComment.SObjectType.getDescribe().isCreateable()) {
			insert new CaseComment(ParentId = caseId, CommentBody = String.format(Label.SendToJira_Comment_Body, new List<String>{ comment }));
			}
	}

	private static String getAuthorizationHeader() {
			return 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(jsItem.Username__c + ':' + jsItem.Password__c));
			}
}