public inherited sharing class LeadService extends DefaultService implements INoteTaker, ILeadService
{
	/*
	*	This implementation of the service will require a selector to handle loading
	*	records that it will need to perform its job.
	*/
	public interface ISelector
	{
		Map<Id, User> getOwners(List<Lead> leads);

		Map<String, Lead> getLeadsByTaskIds(Set<Id> taskIds);

		Id getRecordTypeId(SObjectType objType, String developerName);

		/*
		 * To get Lead matches of account, contact, Lead,
		 *  if any contact or account or Lead has same email or email domain.
		 * It takes input as email list string or email domain string or both
		 */
		List<List<SObject>> getEmailMatchRecords(String emailSearchList, List<Id> leadIds, Id iHASCOLeadRecordType);


		// Get the Events related to the Lead
		List<Event> getEvents(List<Lead> events, String type);

		String getSMSTemplateText(String name);

	}

	/*
	*	Our selector that we were provided by what ever created us.
	*/
	private ISelector selector;
	private INoteService noteService;

	public LeadService(ISelector selector, INoteService noteService)
	{
		this.selector = selector;
		this.noteService = noteService;
	}

	/*
	*	See INoteTaker
	*/
	public SObjectField getNoteField()
	{
		return Lead.Notes__c;
	}

	/*
	*	See INoteTaker
	*/
	public Map<String, SObject> getRecipientRecords(List<SObjectNote> notes)
	{
		Set<Id> taskIds = new Set<Id>();
		for(SObjectNote note: notes)
		{
			taskIds.add(note.noteSource);
		}

		return selector.getLeadsByTaskIds(taskIds);
	}

	/*
	*   see IDomainService
	*/
	public override void setDefaults(List<SObject> newRecords)
	{
		super.setDefaults(newRecords);

		List<Lead> leads = (List<Lead>)newRecords;
		setFMDate(leads);
		setDateMadeCount(leads, null);
		setPipeLineDatetime(leads, null);
		setBDCCallback(leads, null);
		setEMailDomain(leads, null);
		handlePopupProspect(leads, null);
		copySessionNotesToNotes(leads);
		onOwnerChange(leads, null);
	}

	/*
	*   see IDomainService
	*/
	public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
	{
		super.processChangedValues(newRecords, oldRecords);

		List<Lead> leads = (List<Lead>)newRecords;
		Map<Id, Lead> oldLeads = (Map<Id, Lead>)(oldRecords);

		setDateMadeCount(leads, oldLeads);
		setPipeLineDatetime(leads, oldLeads);
		setBDCCallback(leads, oldLeads);
		setEMailDomain(leads, oldLeads);
		handlePopupProspect(leads, oldLeads);
		copySessionNotesToNotes(leads);
		onOwnerChange(leads, oldLeads);
	}

	public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
	{
		List<Lead> newLeads = (List<Lead>)newRecords;
		Map<Id, Lead> oldLeadsMap = (Map<Id, Lead>)oldRecords;

		createSMSMessageRecords(newLeads, oldLeadsMap);
	}

	private void createSMSMessageRecords(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap)
	{
		new SMSMessage(newLeads, oldLeadsMap, selector).process();
	}

	private void setFMDate(List<Lead> leads)
	{
		new FMDate(leads).process();
	}

	private void setDateMadeCount(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		new DateMadeCount(leads, oldLeads).process();
	}

	private void setPipeLineDatetime(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		new PipeLineDatetime(leads, oldLeads).process();
	}

	private void setBDCCallback(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		new BDCCallback(leads, oldLeads).process();
	}

	private void setEMailDomain(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		new EmailDomain(leads, oldLeads).process();
	}

	private void handlePopupProspect(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		new PopupProspect(leads, oldLeads).process();
	}

	private void copySessionNotesToNotes(List<Lead> leads)
	{
		new CopySessionNotesToNotes(leads, noteService).process();
	}

	private void onOwnerChange(List<Lead> leads, Map<Id, Lead> oldLeads)
	{
		new onOwnerChange(leads, oldLeads, selector).process();
	}

	/*
	 * See ILeadService
	 *
	 */
	public void updateDuplicateLead(List<Lead> leads, Id iHASCOLeadRecordType)
	{
		new DuplicateProspect(leads, iHASCOLeadRecordType, selector).process();
	}

	/*
	*	Our default selector.
	*/
	public class DefaultSelector extends RecordTypeSelector implements ISelector
	{
		public Map<Id, User> getOwners(List<Lead> leads)
		{
			if(leads == null || leads.isEmpty())
				return new Map<Id, User>();

			Set<Id> userIds = new Set<Id>();
			for(Lead lead: leads)
			{
				userIds.add(lead.OwnerId);
			}
			userIds.remove(null);

			if(userIds.isEmpty())
				return new Map<Id, User>();

			List<User> users = [SELECT FirstName, LastName FROM User WHERE id IN :userIds];

			return new Map<Id, User>(users);
		}

		public Map<String, Lead> getLeadsByTaskIds(Set<Id> taskIds)
		{
			List<Task> tasks = [SELECT Id, WhoId FROM Task WHERE Id IN :taskIds];

			Set<Id> leadIds = new Set<Id>();
			for(Task t: tasks)
				leadIds.add(t.whoid);
			leadIds.remove(null);

			if(leadIds.isEmpty())
				return new Map<String, Lead>();

			List<Lead> leads = [SELECT Id, Notes__c FROM Lead WHERE Id IN :leadIds];

			Map<Id, Lead> leadMap = new Map<Id, Lead>(leads);

			Map<String, Lead> leadsByTaskIds = new Map<String, Lead>();
			for(Task t: tasks)
			{
				Lead lead = leadMap.get(t.WhoId);
				if(lead != null)
					leadsByTaskIds.put(t.Id, lead);
			}

			return leadsByTaskIds;
		}

	   	public List<List<SObject>> getEmailMatchRecords(String emailSearchList, List<Id> leadIds, Id iHASCOLeadRecordType)
		{
			List<List<SObject>> sObjectList = new List<List<SObject>>();

			sObjectList = [FIND :emailSearchList IN Email FIELDS RETURNING Lead(Id, Email WHERE Id NOT IN:leadIds AND RecordTypeId=:iHASCOLeadRecordType ), Contact(Id, Email), Account(Id, AccountsEmailAddress__c)];

			return sObjectList;
		}

		public List<Event> getEvents(List<Lead> leads, String eventType) {

			if (leads == null || leads.isEmpty())
				return new List<Event>();

			Set<Id> leadIds = (new Map<Id,SObject>(leads)).keySet();

			return [SELECT Id, WhoId, StartDateTime FROM Event WHERE WhoId IN :leadIds AND Type = :eventType AND StartDateTime != NULL AND StartDateTime > TODAY];
		}

		public String getSMSTemplateText(String templateName) {

			List<smagicinteract__SMS_Template__c> templates = [SELECT Id, smagicinteract__Text__c  FROM smagicinteract__SMS_Template__c WHERE smagicinteract__Name__c = :templateName];
			if (!templates.isEmpty()) {
				return templates[0].smagicinteract__Text__c ;
			}
			return null;
		}

	}

	class FMDate
	{
		private List<Lead> leads;

		FMDate(List<Lead> leads)
		{
			this.leads = leads;
		}

		void process()
		{
			DateTime now = System.now();
			for(Lead lead: leads)
			{
				lead.FMCreatedDate__c = now;
			}
		}
	}

	class onOwnerChange
	{
		private List<Lead> leads;
		private Map<Id, Lead> oldLeads;
		private ISelector selector;

		onOwnerChange(List<Lead> leads, Map<Id, Lead> oldLeads, ISelector selector)
		{
			this.leads = leads;
			this.oldLeads = oldLeads;
			this.selector = selector;
		}

		void process()
		{
			List<Lead> leadsToEdit = getChangedLeads();
			if(leadsToEdit.isEmpty())
				return;

			Map<Id, User> users = selector.getOwners(leadsToEdit);
			Id QMSRecordTypeID = selector.getRecordTypeId(Lead.SObjectType, 'QMS_Record_Type');

			for(Lead lead: leadsToEdit)
			{
				User user = users.get(lead.OwnerId);
				if(user != null)
				{
					setBDM(lead, user);
					setAdvisor(lead, user, QMSRecordTypeID);
				}

			}

		}

		private Lead setBDM(Lead lead, User user)
		{
			lead.TEXT_BDM__c = user.FirstName + ' ' + user.LastName;
			return lead;
		}

		private Lead setAdvisor(Lead lead, User user, ID QMSRecordTypeID)
		{
			if (lead.RecordTypeId == QMSRecordTypeID)
			{
				lead.Office_Advisor__c = user.FirstName + ' ' + user.LastName;
				lead.Field_Advisor__c = 'Not Visited';

			}

			return lead;
		}

		private List<Lead> getChangedLeads()
		{
			if(oldLeads == null)
				return leads;

			List<Lead> ownerChanged = new List<Lead>();
			for(Lead lead: leads)
			{
				if(lead.OwnerId != oldLeads.get(lead.Id).OwnerId)
				{
					ownerChanged.add(lead);
				}
			}

			return ownerChanged;
		}
	}

	class DateMadeCount
	{
		private List<Lead> leads;
		private Map<Id, Lead> oldLeads;

		DateMadeCount(List<Lead> leads, Map<Id, Lead> oldLeads)
		{
			this.leads = leads;
			this.oldLeads = oldLeads;
		}

		void process()
		{
			for(Lead lead: leads)
			{
				if(hasDateChanged(lead) ||
					statusRequiresCount(lead))
				{
					lead.CountDateMade__c =  lead.CountDateMade__c == null ? 1 : lead.CountDateMade__c + 1;
				}
			}
		}

		private Boolean hasDateChanged(Lead lead)
		{
			if(oldLeads == null) // insert
				return lead.Date_Made__c != null;

			// update
			return lead.Date_Made__c != null &&
					lead.Date_Made__c != oldLeads.get(lead.Id).Date_Made__c;
		}

		private Boolean statusRequiresCount(Lead lead)
		{
			if(lead.Date_Made__c != null)
			{
				return false;
			}

			if(lead.status == 'Data Quality' ||
				lead.status == 'Approved')
			{
				return true;
			}

			return lead.Prospect_Channel__c == 'SEM' &&
					lead.Seminar_Status__c == 'Registered' &&
					(
						lead.MADE_Criteria__c == 'Seminar Registered 1' ||
						lead.MADE_Criteria__c == 'Seminar Registered 2' ||
						lead.MADE_Criteria__c == 'Seminar Registered 3'
					);
		}
	}

	class PipeLineDatetime
	{
		private List<Lead> leads;
		private Map<Id, Lead> oldLeads;

		PipeLineDatetime(List<Lead> leads, Map<Id, Lead> oldLeads)
		{
			this.leads = leads;
			this.oldLeads = oldLeads;
		}

		void process()
		{
			for(Lead lead: leads)
			{
				if(isCallBackRequested(lead) && hasBDCChanged(lead))
				{
					lead.PipeLine_BDC__c =  lead.BDC__c;
					lead.Pipeline_Date_Time__c = System.Now();
				}
				else if(!isCallBackRequested(lead) && isNotPipelineBDC(lead))
				{
					lead.PipeLine_BDC__c =  null;
					lead.Pipeline_Date_Time__c = null;
				}
			}
		}

		private Boolean isCallBackRequested(Lead lead)
		{
			return lead.Status == 'Callback Requested';
		}

		private Boolean hasBDCChanged(Lead lead)
		{
			if(oldLeads == null) // insert
				return lead.BDC__c != null;

			// update
			return lead.BDC__c != null &&
					lead.BDC__c != oldLeads.get(lead.Id).BDC__c;
		}

		private Boolean isNotPipelineBDC(Lead lead)
		{
			return lead.PipeLine_BDC__c != lead.BDC__c;
		}
	}

	class SMSMessage {

		private List<Lead> filteredLeads;
		private ISelector selector;

		private String smsFromNumber = '447520649722';
		private String smsAppointmentTemplate = 'SMSNewAppointment';
		private String firstVisitEventType = '1st Visit';

		SMSMessage(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap, ISelector selector) {
			this.filteredLeads = findLeadsToProcess(newLeads, oldLeadsMap);
			this.selector = selector;
		}

		//get list of Leads
		private List<Lead> findLeadsToProcess(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
			List<Lead> filteredLeadList = new List<Lead>();

			for (Lead objLead : newLeads) {
				if (objLead.Status == 'Approved' && oldLeadsMap.get(objLead.Id).Status != 'Approved' && objLead.Text_Opt_Out__c == false) {
					filteredLeadList.add(objLead);
				}
			}

			return filteredLeadList;
		}

		void process() {

			if (filteredLeads == null || filteredLeads.isEmpty())
				return;

			List<Event> eventList = selector.getEvents(filteredLeads, firstVisitEventType);

			if (eventList == null || eventList.isEmpty())
				return;

			String templateText = selector.getSMSTemplateText(smsAppointmentTemplate);
			if (templateText == null)
				return;

			List<smagicinteract__smsMagic__c> smsMagicInsertList = createSMSMagicRecords(filteredLeads, eventList, templateText);

			if(!smsMagicInsertList.isEmpty())
			{

				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.insertRecords(smsMagicInsertList);
			}
		}

		private List<smagicinteract__smsMagic__c>  createSMSMagicRecords(List<Lead> leads, List<Event> events, String templateText) {

			Map<Id, Lead> leadMap =  new Map<Id, Lead>(leads);
			List<smagicinteract__smsMagic__c>  smsObjectList = new List<smagicinteract__smsMagic__c>();

			for (Event e :events) {
				Lead l = leadmap.get(e.WhoId);
				String phoneNumber;
				if (l.Phone != null) {
					phoneNumber = MobileUtility.formatMobileNumber(l.Phone);
				}

				if (phoneNumber == null && l.MobilePhone != null) {
					phoneNUmber = MobileUtility.formatMobileNumber(l.MobilePhone);
				}

				if (phoneNumber != null) {

					String name = l.Name;
					templateText = templateText.replace('eventDate', e.StartDateTime.format());

					smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
					smsObject.smagicinteract__SenderId__c = smsFromNumber;
					smsObject.smagicinteract__PhoneNumber__c = phoneNumber;
					smsObject.smagicinteract__Name__c = name;
					smsObject.smagicinteract__ObjectType__c = 'Lead';
					smsObject.smagicinteract__disableSMSOnTrigger__c = 0;
					smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
					smsObject.smagicinteract__SMSText__c = templateText;
					smsObject.smagicinteract__Lead__c = e.WhoId;
					smsObjectList.add(smsObject);
				}

			}

			return smsObjectList;

		}


	}

	class BDCCallback
	{
		private List<Lead> leads;
		private Map<Id, Lead> oldLeads;

		BDCCallback(List<Lead> leads, Map<Id, Lead> oldLeads)
		{
			this.leads = leads;
			this.oldLeads = oldLeads;
		}

		void process()
		{
			for(Lead lead: leads)
			{
				if( (hasBDCChanged(lead) && lead.Status == 'Callback Requested') ||
					hasChangedToCallbackRequested(lead))
				{
					lead.BDC_Callback_Datestamp__c = Date.today();
				}
				else if (noCallback(lead))
				{
					lead.BDC_Callback_Datestamp__c = null;
				}
			}
		}

		private Boolean hasBDCChanged(Lead lead)
		{
			if(oldLeads == null) // insert
				return lead.BDC__c != null;

			// update
			return lead.BDC__c != null &&
					lead.BDC__c != oldLeads.get(lead.Id).BDC__c;
		}

		private Boolean hasChangedToCallbackRequested(Lead lead)
		{
			if(lead.Status != 'Callback Requested')
				return false;

			if(oldLeads == null) // insert
				return true;

			// update
			return lead.Status != oldLeads.get(lead.Id).Status;
		}

		private Boolean noCallback(Lead ld)
		{
			//logic from old PB, not sure I get what it was meaning.
			Boolean condition1 = ld.Status != 'Callback Requested' && ld.Status != 'Data Quality';

			Boolean condition2 = ld.MADE_criteria__c != null &&
									ld.BDC__c != null &&
									ld.LeadSource != null &&
									ld.Status == 'Data Quality';

			return condition1 || condition2;
		}
	}

	class EmailDomain
	{
		private List<Lead> leads;
		private Map<Id, Lead> oldLeads;

		EmailDomain(List<Lead> leads, Map<Id, Lead> oldLeads)
		{
			this.leads = leads;
			this.oldLeads = oldLeads;
		}

		void process()
		{
			for(Lead lead: leads)
			{
				if(isEmailChanged(lead))
				{
					List<String> parts = lead.EMail.split('@');
					lead.Email_Domain__c = parts.size() == 2 ? parts[1] : null;
				}
			}
		}

		private Boolean isEmailChanged(Lead lead)
		{
			if(oldLeads == null) // insert
				return lead.Email != null;

			// update
			return lead.Email != null &&
					lead.Email != oldLeads.get(lead.Id)?.Email;
		}
	}

	class PopupProspect
	{
		private List<Lead> leads;
		private Map<Id, Lead> oldLeads;

		PopupProspect(List<Lead> leads, Map<Id, Lead> oldLeads)
		{
			this.leads = leads;
			this.oldLeads = oldLeads;
		}

		void process()
		{
			for(Lead lead: leads)
			{
				if(hasChangedToPopupForm(lead))
				{
					lead.Marketing_Channel__c = 'SEO';
					lead.Sales_Channel__c = 'Inbound';
				}
				else if(hasChangedFromPopupForm(lead))
				{
					if(lead.Marketing_Channel__c == 'SEO')
						lead.Marketing_Channel__c = null;

					if(lead.Sales_Channel__c == 'Inbound')
						lead.Sales_Channel__c = null;
				}
			}
		}

		private Boolean hasChangedToPopupForm(Lead lead)
		{
			if(oldLeads == null) // insert
				return lead.Prospect_Channel__c == 'Pop Up Form';

			// update
			return lead.Prospect_Channel__c == 'Pop Up Form' &&
					lead.Prospect_Channel__c != oldLeads.get(lead.Id)?.Prospect_Channel__c;
		}

		private Boolean hasChangedFromPopupForm(Lead lead)
		{
			if(oldLeads == null) // insert
				return false;

			// update
			return lead.Prospect_Channel__c != 'Pop Up Form' &&
					oldLeads.get(lead.Id)?.Prospect_Channel__c == 'Pop Up Form';
		}
	}

	class CopySessionNotesToNotes
	{
		private List<Lead> leads;
		private INoteService noteService;

		CopySessionNotesToNotes(List<Lead> leads, INoteService noteService)
		{
			this.leads = leads;
			this.noteService = noteService;
		}

		void process()
		{
			List<Lead> leadsToProcess = new List<Lead>();
			for(Lead lead: leads)
			{
				if(lead.Session_Notes__c != null)
				{
					String note = lead.Notes__c != null ? lead.Notes__c : '';
					if(note != null)
						note = '\n' + note;

					lead.Notes__c = lead.Session_Notes__c + note;
					leadsToProcess.add(lead);
				}
			}

			noteService.fixManualEdits(leadsToProcess, Lead.Notes__c);

			for(Lead lead: leadsToProcess)
			{
				lead.Session_Notes__c = null;
			}
		}
	}

	class DuplicateProspect
	{
		List<Lead> leadsToProcess;
		Id iHASCOLeadRecordType;
		ISelector selector;

		DuplicateProspect(List<Lead> leadList,Id iHASCOLeadRecordType, ISelector selector)
		{
			this.selector = selector;
			this.iHASCOLeadRecordType = iHASCOLeadRecordType;
			this.leadsToProcess = findLeadToProcess(leadList);
		}

		void Process()
		{
			if(leadsToProcess.isEmpty())
				return;

			List<Lead> updatedLeadList = new List<Lead>();

			for(Lead leadRec:leadsToProcess)
			{
				leadRec.Status = DataConstants.LEAD_STATUS_DUPLICATE_FOUND;
				updatedLeadList.add(leadRec);
			}
			if(!updatedLeadList.isEmpty())
			{
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.updateRecords(updatedLeadList);
			}
		}

		List<Lead> findLeadToProcess(List<Lead> leadList)
		{
			String emailSearchList;
			List<Lead> duplicateLeads = new List<Lead>();
			Map<String,Id> emailAndLeadIdMap= new Map<String,Id>();
			List<List<SObject>> ObjsList;
			List<String> duplicateEmailList= new List<String>();
			List<String> businessDomains= new List<String>();
			String emailDomain;

			for(Lead leadRec:leadList)
			{
				emailAndLeadIdMap.put(leadRec.Email,leadRec.Id);
				if( leadRec.Email_Domain__c !=NULL && ! label.Free_Domain_List.contains(leadRec.Email_Domain__c) )
				{
				   businessDomains.add(leadRec.Email_Domain__c);
				   emailAndLeadIdMap.put(leadRec.Email_Domain__c, leadRec.Id);
				}
			}
			emailSearchList = String.join(New List<string>(emailAndLeadIdMap.Keyset()), ' OR ');
			ObjsList=selector.getEmailMatchRecords(emailSearchList, emailAndLeadIdMap.values(), iHASCOLeadRecordType);
			duplicateEmailList =getDuplicateEmailList(ObjsList);
			String duplicateEmails = String.join(duplicateEmailList, ' OR ');

			for(Lead leadRec:leadList)
			{
				if(duplicateEmailList.contains(leadRec.Email) ||
				   (duplicateEmails.contains(leadRec.Email_Domain__c) && businessDomains.contains(leadRec.Email_Domain__c)) )
				{
					duplicateLeads.add(leadRec);
				}
			}

			return duplicateLeads;
		}

	   List<String> getDuplicateEmailList(List<List<SObject>> ObjsList)
		{
			List<String> duplicateEmailList= new List<String>();
			for(List<SObject> objList:ObjsList){

				for(SObject obj:objList)
				{
					if(obj.getSObjectType() ==Account.sObjectType)
					{
						Account accountRec=(Account)obj;
						duplicateEmailList.add(accountRec.AccountsEmailAddress__c);
					}
					else if(obj.getSObjectType() ==Lead.sObjectType)
					{
						Lead leadRec=(Lead)obj;
						duplicateEmailList.add(leadRec.Email);
					}
					else if(obj.getSObjectType() ==Contact.sObjectType)
					{
						Contact contactRec=(Contact)obj;
						duplicateEmailList.add(contactRec.Email);
					}
				}
			}

			return duplicateEmailList;
		}

	}
}