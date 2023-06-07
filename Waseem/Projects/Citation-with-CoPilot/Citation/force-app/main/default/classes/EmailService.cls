public class EmailService {
	public interface ISelector {
		/*
		 *  Returns the user List of email recepients using AliasEmail.
		 *  Alias Email is a custom email field on User record.
		 */
		Map<Id, User> getAgentUsers(List<String> aliasEmailAddresses);

		/*
		 *  Returns the Queue Id using QueueName and SObject Name.
		 */
		Id getQueueByName(String queueName);

		/*
		 *  Returns the Contacts List of the email address searching all Contact email fields.
		 */
		List<Contact> getContactsByEmail(String emailAddress);

		/*
		 *  Returns the Case List of caseId List.
		 */
		List<Case> getCasesbyCaseIds(List<id> caseIds);

		/*
		 *  Returns the RecordTypeId of Object based on
		 *  RecordType Developer Name.
		 */
		Id getRecordTypeId(SObjectType objType, String devName);
		
		/** Return Case Id from Email Header 
		 * Standard Method
		 **/
		Id getCaseIdFromEmailHeader(Messaging.InboundEmail email);
	}

	/*For Custom Exception Handling created below class*/
	public virtual class CustomException extends Exception {
	}

	/*
	 *   Our selector that we were provided by what ever created us.
	 */
	private ISelector selector;

	public EmailService(ISelector selector) {
		this.selector = selector;
	}

	public Messaging.InboundEmailResult emailMessageHandlerForHighValueCustomer(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, String defaultQueueName) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

		if(checkHRAdviceEmail(email))
		{
			result.success = true;
			return result;
		}

		Savepoint sp = Database.setSavePoint();

		try {
			Map<id, User> userMap = selector.getAgentUsers(email.toAddresses);
			Id caseId = selector.getCaseIdFromEmailHeader(email);
			Case updatedCase = caseManager(email, CaseId, userMap, defaultQueueName);
			if (updatedCase != null) {
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.upsertRecords(new List<Case>{ updatedCase });
			}
			CaseId = updatedCase.id;

			// Insert the new EmailMessage
			EmailMessage em = createEmailMessageAttachedToCase(email, CaseId);
			IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
			uow.insertRecords(new List<EmailMessage>{ em });

			List<Attachment> attachments = addAttachmentToEmail(email, em.id);
			if (attachments != null && !attachments.isEmpty()) {
				uow.insertRecords(attachments);
			}

			result.success = true;
			return result;
		} catch (Exception e) {
			Database.rollBack(sp);

			result.success = false;
			result.message = 'Failed to handle emailMessage from ' + email.fromAddress + ' of HighValueCustomers';
			result.message = result.message + e.getMessage();
			result.message = result.message + e.getStackTraceString();
			return result;
		}
	}

	private Case caseManager(Messaging.InboundEmail email, Id caseId, Map<id, User> userMap, String defaultQueueName) {
		Case updatedCase;
		if (caseId == null) {
			updatedCase = createNewCasesAssignedToAgents(email, userMap, defaultQueueName);
		} else {
			updatedCase = handleExistingCasesAssignedToAgents(email, CaseId, userMap, defaultQueueName);
		}
		return updatedCase;
	}

	private Case createNewCasesAssignedToAgents(Messaging.InboundEmail email, Map<id, User> userMap, String defaultQueueName) {
		id owner;
		if (userMap != null && userMap.size() == 1) {
			Owner = userMap.values()[0].id;
		} else {
			id queueid = selector.getQueueByName(defaultQueueName);
			Owner = queueid;
		}
		Contact[] searchContacts = selector.getContactsByEmail(email.fromAddress);
		Case c = new Case(Subject = email.subject, recordTypeId = selector.getRecordTypeId(Case.SObjectType, 'ELT_Advice_Generic'), Description = email.plainTextBody, Ownerid = Owner, Status = 'New');
		if (searchContacts != null && searchContacts.size() == 1) {
			c.AccountId = searchContacts[0]?.AccountId;
			c.ContactId = searchContacts[0]?.Id;
		}
		return c;
	}

	private Case handleExistingCasesAssignedToAgents(Messaging.InboundEmail email, Id caseId, Map<id, User> userMap, String defaultQueueName) {
		List<Case> caseList = selector.getCasesbyCaseIds(new List<Id>{ caseId });
		Case updatedCase = new Case();
		updatedCase.id = CaseId;
		updatedCase.Status = 'New Info Added';

		if (!(userMap.containsKey(caseList[0]?.ownerId))) {
			if (userMap != null && userMap.size() == 1) {
				updatedCase.ownerId = userMap.values()[0].id;
			} else {
				id queueid = selector.getQueueByName(defaultQueueName);
				updatedCase.OwnerId = queueid;
			}
		}

		return updatedCase;
	}

	private EmailMessage createEmailMessageAttachedToCase(Messaging.InboundEmail email, Id caseId) {
		// Process recipients
		String toAddresses;
		if (email.toAddresses != null) {
			toAddresses = String.join(email.toAddresses, '; ');
		}

		// To store an EmailMessage for threading, you need at minimum
		// the Status, the MessageIdentifier, and the ParentId fields
		EmailMessage em = new EmailMessage(
			Status = '0',
			MessageIdentifier = email.messageId,
			ParentId = caseId,
			// Important fields
			FromAddress = email.fromAddress,
			FromName = email.fromName,
			ToAddress = toAddresses,
			TextBody = email.plainTextBody,
			Subject = email.subject,
			Incoming = true,
			CreatedByEmailService__c = true
			// Other fields you wish to add
		);
		em.Headers = email.headers.toString();
		return em;
	}

	private List<Attachment> addAttachmentToEmail(Messaging.InboundEmail email, id parentId) {
		List<Attachment> attachments = new List<Attachment>();
		if (!(email.textAttachments == null)) {
			for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
				Attachment attachment = new Attachment();
				attachment.Name = tAttachment.fileName;
				attachment.Body = Blob.valueOf(tAttachment.body);
				attachment.ParentId = parentId;
				attachments.add(attachment);
			}
		}

		//Save any Binary Attachment
		if (!(email.binaryAttachments == null)) {
			for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
				Attachment attachment = new Attachment();
				attachment.Name = bAttachment.fileName;
				attachment.Body = bAttachment.body;
				attachment.ParentId = parentId;
				attachments.add(attachment);
			}
		}
		return attachments;
	}
	
	private Boolean checkHRAdviceEmail(Messaging.InboundEmail email)
	{
		String hrAdviceEmail = System.Label.HRAdvice_Personal.toLowerCase();
		List<String> emailAddresses = new List<String>();
		
		emailAddresses.addAll(email.toAddresses);
		if(email.ccAddresses != null) 
		{
			emailAddresses.addAll(email.ccAddresses);
		}
	  	for(Integer i=0; i<emailAddresses.size(); i++)
		{
			emailAddresses[i] = emailAddresses[i].toLowerCase();
		}
		if(emailAddresses.contains(hrAdviceEmail))
		{
			   return true;
		}
		else
		{
			return false;
		}
	}
	public without sharing class EmailServiceSelector extends RecordTypeSelector implements EmailService.ISelector {
		public map<Id, User> getAgentUsers(List<String> aliasEmailAddresses) {
			Map<id, User> agentUsersMap = new Map<id, User>(
				[
					SELECT Id, AliasEmail__c
					FROM User
					WHERE AliasEmail__c IN :aliasEmailAddresses
				]
			);
			return agentUsersMap;
		}

		public Id getQueueByName(String queueName) {
			String objectName = String.valueOf(Case.sObjectType);
			List<QueueSobject> queueList = [
				SELECT QueueId
				FROM QueueSobject
				WHERE Queue.name = :queueName AND SobjectType = :objectName
			];
			if (queueList.size() > 0) {
				return queueList[0].QueueId;
			} else {
				return null;
			}
		}

		public List<Contact> getContactsByEmail(String emailAddress) {
			List<List<SObject>> searchList = [FIND :emailAddress IN EMAIL FIELDS RETURNING Contact(AccountId, Id)];
			return (Contact[]) searchList[0];
		}

		public List<Case> getCasesbyCaseIds(List<id> caseIds) {
			return [SELECT id, ownerId FROM Case WHERE Id IN :caseIds];
		}
		
		public Id getCaseIdFromEmailHeader(Messaging.InboundEmail email)
		{
			return Cases.getCaseIdFromEmailHeaders(email.headers);
		}
	}
}