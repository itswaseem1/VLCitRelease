public with sharing class CreateTicketMessage {
	public Id caseId;
	public String subject;
	public String description;
	public String caseNumber;
	public String priority;
	public String origin;
	public String jiraTicketNumber;
	public String contactName;
	public String contactEmail;
	public String accountName;
	public String issueType;
	public String issueLabel;
	public String threadId;
	public String issueArea;
	public String caseReason;
	public String impactedUsers;
	public String type;
	public String feature;
	public List<Id> contentVersionIds;

	public CreateTicketMessage(Case caseItem, Map<String, Object> updatedCaseData, List<Id> contentVersionIds) {
		this.caseId = caseItem.Id;
		this.subject = String.valueOf(updatedCaseData.get('updatedSubject'));
		this.issueArea = String.valueOf(updatedCaseData.get('updatedIssueArea'));
		this.caseReason = String.valueOf(updatedCaseData.get('updatedCaseReason'));
		this.impactedUsers = String.valueOf(updatedCaseData.get('updatedImpactedUsers'));
		this.type = String.valueOf(updatedCaseData.get('updatedType'));
		this.description = caseItem.Description;
		this.caseNumber = caseItem.CaseNumber;
		
		if(updatedCaseData.get('updatedCasePriority')!=null){
			this.priority = String.valueOf(updatedCaseData.get('updatedCasePriority'));
			if (this.priority.equals('Critical')) {
				this.priority = 'Highest';
			} else if (this.priority.equals('Normal')) {
				this.priority = 'Medium';
			}
		}
		
		this.origin = caseItem.Origin;
		this.jiraTicketNumber = (caseItem.Jira_Ticket_Number__c!=null ?  caseItem.Jira_Ticket_Number__c: null);
		this.contactName = caseItem.Contact?.Name;
		this.contactEmail = caseItem.ContactEmail;
		this.accountName = caseItem.Account?.Name;
		this.issueType = String.valueOf(updatedCaseData.get('updatedIssueType'));
		this.issueLabel = SendToJiraCmpCtrl.RT_JIRA_TICKET_LABEL_MAP.get(caseItem.RecordTypeId);
		this.threadId = caseItem.ThreadId__c;

		if (this.type != null && this.issueArea != null) {
			this.feature = this.type + ' - ' + this.issueArea;
		}
		this.contentVersionIds = contentVersionIds;
	}
}