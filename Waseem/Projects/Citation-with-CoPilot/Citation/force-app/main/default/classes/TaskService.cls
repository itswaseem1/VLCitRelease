public inherited sharing class TaskService extends DefaultService implements INoteTaker
{
	/*
	*	This implementation of the service will require a selector to handle loading
	*	records that it will need to perform its job.
	*/
	public interface ISelector
	{
		Map<Id, Lead> getRelatedLeads(List<Task> tasks);

        Map<String, Task> getTasksByCallObjects(Set<String> callObjects);
	}

	/*
	*	Our selector that we were provided by what ever created us.
	*/
	private ISelector selector;
	private INoteService noteService;

	public TaskService(ISelector selector, INoteService noteService) 
	{
		this.selector = selector;
		this.noteService = noteService;
	}

	/*
	*	See INoteTaker
	*/
	public SObjectField getNoteField()
	{
		return Task.Description;
	}

    /*
	*	See INoteTaker
	*/
	public Map<String, SObject> getRecipientRecords(List<SObjectNote> notes)
	{
		Set<String> callIds = new Set<String>();
		for(SObjectNote note: notes)
		{
			callIds.add(note.noteSource);
		}

		return selector.getTasksByCallObjects(callIds);
	}

	/*
    *   see IDomainService
    */
    public override void setDefaults(List<SObject> newRecords)
    {
        List<Task> newTasks = (List<Task>)newRecords;

        setProcessRunTime(newTasks, null);
		changeManualCallDescription(newTasks, null);
		copyDescriptionToComment(newTasks);
    }

    /*
    *   see IDomainService
    */
    public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        List<Task> newTasks = (List<Task>)newRecords;
        Map<Id, Task> oldTasks = (Map<Id, Task>)oldRecords;

        setProcessRunTime(newTasks, oldTasks);
		changeManualCallDescription(newTasks, oldTasks);
		copyDescriptionToComment(newTasks);
    }

	/*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnNew(List<SObject> newRecords)
    {
        List<Task> newTasks = (List<Task>)newRecords;

		// as there may be various updates to Leads we ensure that they all select and
		// update the same lead instance, and that we then perform just a single DML op
		// on all of them afterwards.
		LeadCache leadCache = new LeadCache(selector.getRelatedLeads(newTasks));

		callHandling(newTasks, null, leadCache);
		nvmDialerOutcomes(newTasks, null, leadCache);
		copyNotesToInterestedParties(newTasks, null, noteService);

		leadCache.updateLeads();

		copyNotesToInterestedParties(newTasks, null, noteService);
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        List<Task> newTasks = (List<Task>)newRecords;
        Map<Id, Task> oldTasks = (Map<Id, Task>)oldRecords;

		// as there may be various updates to Leads we ensure that they all select and
		// update the same lead instance, and that we then perform just a single DML op
		// on all of them afterwards.
		LeadCache leadCache = new LeadCache(selector.getRelatedLeads(newTasks));

		callHandling(newTasks, oldTasks, leadCache);
		nvmDialerOutcomes(newTasks, oldTasks, leadCache);
		copyNotesToInterestedParties(newTasks, oldTasks, noteService);

		leadCache.updateLeads();
		
		copyNotesToInterestedParties(newTasks, oldTasks, noteService);
    }

	private void changeManualCallDescription(List<Task> newTasks, Map<Id, Task> oldTasks)
	{
		new ChangeManualCallDescription(newTasks, oldTasks, noteService).process();
	}
	
	private void copyDescriptionToComment(List<Task> newTasks)
	{
		new CopyDescriptionToComment(newTasks).process();
	}

	private void copyNotesToInterestedParties(List<Task> newTasks, Map<Id, Task> oldTasks, INoteService noteService)
	{
		new CopyNotesToInterestedParties(newTasks, oldTasks, noteService).process();
	}

	private void setProcessRunTime(List<Task> newTasks, Map<Id, Task> oldTasks)
	{
		new ProcessRunTime(newTasks, oldTasks).process();
	}

	private void callHandling(List<Task> newTasks, Map<Id, Task> oldTasks, LeadCache cache)
	{
		new CallHandling(newTasks, oldTasks, selector, cache).process();
	}

	private void nvmDialerOutcomes(List<Task> newTasks, Map<Id, Task> oldTasks, LeadCache cache)
	{
		new NVMDiallerOutcomes(newTasks, oldTasks, selector, cache).process();
	}

	public class DefaultSelector implements ISelector
	{
		public Map<Id, Lead> getRelatedLeads(List<Task> tasks)
		{
			if(tasks == null || tasks.isEmpty())
				return new Map<Id, Lead>();

			SObjectType leadType = Lead.SObjectType;
			Set<Id> leadIds = new Set<Id>();
			for(Task task: tasks)
			{
				Id whoId = task.WhoId;
				if(whoId != null && whoId.getSObjectType() == leadType)
				{
					leadIds.add(whoId);
				}
			}

			if(leadIds.isEmpty())
				return new Map<Id, Lead>();
				
			List<Lead> leads = [SELECT Id FROM Lead WHERE Id IN :leadIds];

			return new Map<Id, Lead>(leads);
		}

        public Map<String, Task> getTasksByCallObjects(Set<String> callObjects)
		{
            if(callObjects.isEmpty())
                return new Map<String, Task>();

			List<Task> tasks = [SELECT Description,
										CallObject 
								FROM Task
								WHERE CallObject IN :callObjects];
		
			Map<String, Task> taskMap = new Map<String, Task>();
			for(Task task: tasks)
			{
				taskMap.put(task.callObject, task);
			}

			return taskMap;
		}
	}

	class CallHandling
	{
		private List<Task> newTasks;
		private Map<Id, Task> oldTasks;

		/*
		*	So we use the same 'now' for all updates by this logic.
		*/
		DateTime now;

		/*
		*	there is a lot of logic that wil iterate over the tasks and update related leads.
		*	As a result it is easeir for now to just load all potential leads up front, rather than 
		*	try and accumulate all leads for various reasons and still only use 1 SOQL.
		*
		*	furthermore, as there are many bits of logic that will update related leads, and therefore
		*	possibly many updates to the same lead, we maintain a 'cache' of dirty leads that stuff in here
		*	can interact with, without worryig about what has or has not been queried already or updated already etc.
		*/
		private LeadCache leads;

		CallHandling(List<Task> newTasks, Map<Id, Task> oldTasks, ISelector selector, LeadCache leadCache)
		{
			this.leads = leadCache;
			this.newTasks = newTasks;
			this.oldTasks = oldTasks;
			this.now = System.now();			
		}

		void process()
		{
			handleOutbound();
			handleInbound();
			handleFullTimeEmployees();
		}

		private void handleOutbound()
		{
			for(Task task: newTasks)
			{
				if(!hasOutboundInfo(task))
					continue;

				Lead lead = leads.getLead(task.WhoId);
				if(lead == null)
				{	
					continue;
				}

				lead.LastOutboundCall__c = now;
				lead.OutboundCallCheck__c = true;
				lead.Last_Outbound_Caller__c = task.OwnerId;

				leads.registerDirty(lead);
			}
		}

		private void handleInbound()
		{
			for(Task task: newTasks)
			{
				if(!hasInboundInfo(task))
					continue;

				Lead lead = leads.getLead(task.WhoId);
				if(lead == null)
				{	
					continue;
				}

				lead.LastInboundCall__c = now;
				lead.InboundCallCheck__c = true;

				leads.registerDirty(lead);
			}
		}

		private void handleFullTimeEmployees()
		{
			for(Task task: newTasks)
			{
				if(!hasFullTimeEmployees(task))
					continue;

				Lead lead = leads.getLead(task.WhoId);
				if(lead == null)
				{	
					continue;
				}

				lead.FT_Employees__c = task.FullTimeEmployees__c;

				leads.registerDirty(lead);
			}
		}

		private Boolean hasOutboundInfo(Task Task)
		{
			if(task.CallType != 'Outbound' ||
				task.CallObject == null ||
				task.WhoId == null ||
				task.WhoId.getSObjectType() != Lead.SObjectType)
			{
				return false;
			}

			if(oldTasks == null)
			{
				return true;
			}

			Task oldTask = oldTasks.get(task.ID);
			if(oldTask == null)
			{
				return false;
			}

			return task.CallType != oldTask.CallType ||
					task.CallObject != oldTask.CallObject ||
					task.WhoId != oldTask.WhoId;
		}

		private Boolean hasInboundInfo(Task Task)
		{
			if(task.CallType != 'Inbound' ||
				task.CallObject == null ||
				task.WhoId == null ||
				task.WhoId.getSObjectType() != Lead.SObjectType)
			{
				return false;
			}

			if(oldTasks == null)
			{
				return true;
			}

			Task oldTask = oldTasks.get(task.ID);
			if(oldTask == null)
			{
				return false;
			}

			return task.CallType != oldTask.CallType ||
					task.CallObject != oldTask.CallObject ||
					task.WhoId != oldTask.WhoId;
		}

		private Boolean hasFullTimeEmployees(Task Task)
		{
			if(task.FullTimeEmployees__c == null ||
				task.FullTimeEmployees__c == 0 ||
				task.CallObject == null ||
				task.WhoId == null ||
				task.WhoId.getSObjectType() != Lead.SObjectType)
			{
				return false;
			}

			if(oldTasks == null)
			{
				return true;
			}

			Task oldTask = oldTasks.get(task.ID);
			if(oldTask == null)
			{
				return false;
			}

			return task.FullTimeEmployees__c != oldTask.FullTimeEmployees__c ||
					task.CallObject != oldTask.CallObject ||
					task.WhoId != oldTask.WhoId;
		}
	}
	
	class ProcessRunTime
	{
		private List<Task> newTasks;
		private Map<Id, Task> oldTasks;

		/*
		*	This is setting a time which is then used elsewhere to schedule a lead update.
		*/
		ProcessRunTime(List<Task> newTasks, Map<Id, Task> oldTasks)
		{
			this.newTasks = newTasks;
			this.oldTasks = oldTasks;
		}

		void process()
		{
			for(Task task: newTasks)
			{
				if(!hasCallObjectAndLead(task))
					continue;

				Datetime nextPoint = task.NVMContactWorld__CW_Call_End_Time__c.addMinutes(65);
				task.Process_Run_Time__c = nextPoint;
			}
		}

		private Boolean hasCallObjectAndLead(Task Task)
		{
			if(task.NVMContactWorld__CW_Call_End_Time__c == null ||
				task.CallObject == null ||
				task.WhoId == null ||
				task.WhoId.getSObjectType() != Lead.SObjectType)
			{
				return false;
			}

			if(oldTasks == null)
			{
				return true; // insert, not looking for change vs old.
			}

			Task oldTask = oldTasks.get(task.ID);
			if(oldTask == null)
			{
				return false;
			}

			//has value changed
			return task.CallObject != oldTask.CallObject ||
					task.WhoId != oldTask.WhoId;
		}
	}

	class NVMDiallerOutcomes
	{
		private List<Task> newTasks;
		private Map<Id, Task> oldTasks;

		/*
		*	there is a lot of logic that wil iterate over the tasks and update related leads.
		*	As a result it is easeir for now to just load all potential leads up front, rather than 
		*	try and accumulate all leads for various reasons and still only use 1 SOQL.
		*
		*	furthermore, as there are many bits of logic that will update related leads, and therefore
		*	possibly many updates to the same lead, we maintain a 'cache' of dirty leads that stuff in here
		*	can interact with, without worryig about what has or has not been queried already or updated already etc.
		*/
		private LeadCache leads;

		NVMDiallerOutcomes(List<Task> newTasks, Map<Id, Task> oldTasks, ISelector selector, LeadCache leadCache)
		{
			this.leads = leadCache;
			this.newTasks = filterByLeadTasksOnly(newTasks);
			this.oldTasks = oldTasks;
			
		}

		private List<Task> filterByLeadTasksOnly(List<Task> newtasks)
		{
			// this set of logic is only interested in tasks related to Leads
			// therefore we check all the tasks and make sure we only bother handling 
			// those ones.
			List<Task> tasks = new List<Task>();
			for(Task task: newtasks)
			{
				Lead lead = leads.getLead(task.WhoId);
				if(lead != null)
				{	
					tasks.add(task);
				}
			}

			return tasks;
		}

		void process()
		{
			updateLeadStatus();
		}

		private void updateLeadStatus()
		{
			Map<String, LeadStatusUpdate> handlers = getSuspendedCloseUpdateMap();
			Map<String, LeadStatusUpdate> statusHandlers = getStatusUpdateMap();

			for(Task task: newTasks)
			{
				// there are 2 sets of handlers, one set is based on the current 
				// suspense_closed field (most of them), and the other set based on the Status field.
				// Only 1 handler will process the task, if any.
				LeadStatusUpdate handler = handlers.get(task.Suspended_Close__c);
				if(handler == null)
				{
					handler = statusHandlers.get(task.Status__c);
				}

				if(handler != null)
				{
					Task oldTask = oldTasks != null ? oldTasks.get(task.Id) : null;

					handler.handle(task, oldTask, leads);
				}
			}
		}

		private Map<String, LeadStatusUpdate> getSuspendedCloseUpdateMap()
		{
			Map<String, LeadStatusUpdate> logicMap = new Map<String, LeadStatusUpdate>();
			logicMap.put('Future Third Party', new NVM_FutureThirdParty());
			logicMap.put('DMU', new NVM_DMU());
			logicMap.put('Gatekeeper Refusal', new NVM_GateKeeperRefusal());
			logicMap.put('None DM Callback', new NVM_CallBack());
			logicMap.put('DM Callback', new NVM_CallBack());
			logicMap.put('Returned Callback', new NVM_ReturnCallback());
			logicMap.put('No Answer', new NVM_NoAnswer());
			logicMap.put('Answer Machine', new NVM_AnswerMachine());
			logicMap.put('Busy', new NVM_Busy());
			logicMap.put('Disconnect', new NVM_Disconnect());
			logicMap.put('Under Criteria', new NVM_UnderCriteria());
			logicMap.put('Over Criteria', new NVM_OverCriteria());
			logicMap.put('Not Interested', new NVM_NotInterested());
			logicMap.put('Bad Sector', new NVM_BadSector());
			logicMap.put('Bad Company', new NVM_BadCompany());
			logicMap.put('DM Refusal', new NVM_DMRefusal());
			logicMap.put('Third Party Renewal', new NVM_ThirdPartyRefusal());
			logicMap.put('Sole Trading', new NVM_SoleTrader());
			logicMap.put('Area Not Covered', new NVM_AreaNotCovered());
			logicMap.put('Ceased Trading', new NVM_CeasedTrading());
			logicMap.put('Branch', new NVM_Branch());
			logicMap.put('Do Not Call', new NVM_DoNotCall());
			logicMap.put('Duplicate', new NVM_Duplicate());
			logicMap.put('Client', new NVM_Client());
			logicMap.put('Local Authority', new NVM_LocalAuthority());
			logicMap.put('Employee', new NVM_Employee());
			logicMap.put('Member of public', new NVM_MemberPublic());


			return logicMap;
		}

		private Map<String, LeadStatusUpdate> getStatusUpdateMap()
		{
			Map<String, LeadStatusUpdate> logicMap = new Map<String, LeadStatusUpdate>();
			logicMap.put('Appointment', new NVM_Appointment());
			logicMap.put('Internal Call', new NVM_InternalCall());

			return logicMap;
		}
	}

	class ChangeManualCallDescription
	{
		private List<Task> tasks;
		private INoteService noteService;

		ChangeManualCallDescription(List<Task> tasks, Map<Id, Task> oldTasks, INoteService noteService)
		{
			this.tasks = tasksToProcess(tasks, oldTasks);
			this.noteService = noteService;
		}

		private List<Task> tasksToProcess(List<Task> tasks, Map<Id, Task> oldTasks)
		{
			List<Task> tasksToCheck = new List<Task>();

			for(Task task: tasks)
			{
				if(task.callObject == null)
					continue;

				if(oldTasks == null ||
					task.Description != oldTasks.get(task.Id).Description)
				{
					tasksToCheck.add(task);
				}
			}

			return tasksToCheck;
		}

        void process()
        {
			noteService.fixManualEdits(tasks, Task.Description);
        }
	}

	class CopyNotesToInterestedParties
	{
		private List<Task> newTasks;
		private Map<Id, Task> oldTasks;
		private INoteService noteService;

		CopyNotesToInterestedParties(List<Task> newTasks, Map<Id, Task> oldTasks, INoteService noteService)
		{
			this.newTasks = newTasks;
			this.oldTasks = oldTasks;	
			this.noteService = noteService;	
		}

		void process()
		{
			List<SObjectNote> notesToSend = new List<SObjectNote>();

			for(Task task: newTasks)
			{
				if(task.CallObject != null && (hasNewDescription(task) || hasNewWho(task)))
				{
					List<SObjectNote> notes = noteService.convertToNotes(task.Description, task.Id);
					notesToSend.addAll(notes);
				}
			}

			if(!notesToSend.isEmpty())
				noteService.setNotes(notesToSend);
		}

		private Boolean hasNewDescription(Task task)
		{
			if(task.Description == null)
				return false;

			if(oldTasks == null || oldTasks.isEmpty())
				return true;

			Task oldTask = oldTasks.get(task.Id);

			if(oldTask == null)
				return true;

			return task.Description != oldTask.Description;
		}

		private Boolean hasNewWho(Task task)
		{
			if(task.WhoId == null)
				return false;

			if(oldTasks == null || oldTasks.isEmpty())
				return true;

			Task oldTask = oldTasks.get(task.Id);

			if(oldTask == null)
				return true;

			return task.WhoId != oldTask.WhoId;
		}
	}

	class CopyDescriptionToComment
	{
		private List<Task> tasks;

		CopyDescriptionToComment(List<Task> tasks)
		{
			this.tasks = tasks;	
		}

		void process()
		{
			for(Task task: tasks)
			{
				if(task.Description != null) // old WF copied from only copied non null description and left old comments otherwise
				{
					if(task.Description.length() > 255)
						task.Comment__c = task.Description.left(252) + '...';
					else
						task.Comment__c = task.Description;
				}	
			}
		}
	}

	abstract class LeadStatusUpdate
	{
		private Boolean checkStatus;

		LeadStatusUpdate()
		{
			this(false);
		}

		LeadStatusUpdate(Boolean needStatusCheck)
		{
			this.checkStatus = needStatusCheck;
		}

		void handle(Task task, Task oldTask, LeadCache leads)
		{
			if(hasNVMUpdate(task, oldTask))
			{
				Lead lead = leads.getLead(task.WhoId);
				updateLead(task, lead);
				leads.registerDirty(lead);
			}
		}

		abstract void updateLead(Task task, Lead lead); 
		
		protected virtual Boolean hasNVMUpdate(Task task, Task oldTask)
		{
			if(oldTask == null)
			{
				return true;
			}

			Boolean noChange = task.WhoId == oldTask.WhoID && 
								task.CallObject == oldTask.CallObject &&
								task.Suspended_Close__c == oldTask.Suspended_Close__c;
			
			noChange = checkStatus ? (noChange && task.Status__c == oldTask.Status__c) : noChange;

			return !noChange;
		}
	}

	class NVM_LocalAuthority extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Local Authority';
		}		
	}

	class NVM_Employee extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Employee';
		}		
	}

	class NVM_MemberPublic extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Member of the public';
		}		
	}

	class NVM_DoNotCall extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Do Not Call';
			lead.IsTPS__c = 'Yes';
		}		
	}

	class NVM_Duplicate extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Duplicate';
		}		
	}

	class NVM_Client extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Client';
		}		
	}

	class NVM_AreaNotCovered extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Area Not Covered';
		}		
	}

	class NVM_CeasedTrading extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Ceased Trading';
		}		
	}

	class NVM_Branch extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Closed';
			lead.Suspended_Closed_Reason__c = 'Branch';
		}		
	}

	class NVM_BadCompany extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'Bad Company';
		}		
	}

	class NVM_DMRefusal extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'DM Refusal';
		}		
	}

	class NVM_ThirdPartyRefusal extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Renewal_Date__c = task.Renewal_Date__c;
			lead.Suspended_Closed_Reason__c = 'Third Party Renewal';
		}		
	}

	class NVM_SoleTrader extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'Sole Trader';
		}		
	}

	class NVM_UnderCriteria extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'Under Criteria';
			lead.FT_Employees__c = task.FullTimeEmployees__c;
		}		
	}

	class NVM_OverCriteria extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'Over Criteria';
			lead.FT_Employees__c = task.FullTimeEmployees__c;
		}		
	}

	class NVM_NotInterested extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'Not Interested';
		}		
	}

	class NVM_BadSector extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Suspended';
			lead.Suspended_Closed_Reason__c = 'Bad Sector';
		}		
	}

	class NVM_NoAnswer extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Open';
			lead.Suspended_Closed_Reason__c = 'No Answer';
			lead.OutboundNoAnswerCheck__c = true;
		}		
	}

	class NVM_AnswerMachine extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Open';
			lead.Suspended_Closed_Reason__c = 'Answer Machine';
			lead.OutboundAnswerMachineCallCheck__c = true;
		}		
	}

	class NVM_Busy extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Open';
			lead.Suspended_Closed_Reason__c = 'Busy';
			lead.OutboundBusyCheck__c = true;
		}		
	}

	class NVM_Disconnect extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Open';
			lead.Suspended_Closed_Reason__c = 'Disconnect';
			lead.OutboundDisconnectCallCheck__c = true;

		}		
	}

	class NVM_DMU extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Open';
			lead.Suspended_Closed_Reason__c = 'Decision Maker Unavailable';
			lead.OutboundDMUnavailableCheck__c = true;
		}		
	}
	
	class NVM_GateKeeperRefusal extends LeadStatusUpdate
	{
		override void updateLead(Task task, Lead lead)
		{
			lead.Status = 'Open';
			lead.Suspended_Closed_Reason__c = 'Gatekeeper Refusal';
			lead.OutboundGKCheck__c = true;
		}		
	}

	class NVM_CallBack extends LeadStatusUpdate
	{
		NVM_CallBack()
		{
			super(true);
		}

		override void updateLead(Task task, Lead lead)
		{
			if(task.Status__c != 'Callback Requested')
			{
				return;
			}	

			lead.Status = 'Callback Requested';
			lead.Suspended_Closed_Reason__c = task.Suspended_Close__c;
			lead.BDC__c = task.OwnerId;
			lead.Callback_Date_Time__c = task.CallbackDateTime__c;
			lead.Rating = task.Rating__c;
		}		
	}

	class NVM_FutureThirdParty extends LeadStatusUpdate
	{
		NVM_FutureThirdParty()
		{
			super(true);
		}

		override void updateLead(Task task, Lead lead)
		{
			lead.Assigned_BDC__c = task.OwnerId;
			lead.Renewal_Date__c = task.Renewal_Date__c;
			lead.Status = task.Status__c;
			lead.Suspended_Closed_Reason__c = task.Suspended_Close__c;
		}	

		protected override Boolean hasNVMUpdate(Task task, Task oldTask)
		{
			if(task.Status__c != 'Open')
				return false;

			Boolean basicFieldsChange = super.hasNVMUpdate(task, oldTask);

			Boolean noOtherChange = oldTask != null &&
											task.OwnerId == oldTask.OwnerId &&
											task.Renewal_Date__c == oldTask.Renewal_Date__c;

			return basicFieldsChange || !noOtherChange;
		}	
	}

	class NVM_Appointment extends LeadStatusUpdate
	{
		NVM_Appointment()
		{
			super(true);
		}

		override void updateLead(Task task, Lead lead)
		{
			lead.Status = task.Status__c;
			lead.Suspended_Closed_Reason__c = task.Suspended_Close__c;
		}		
	}

	class NVM_InternalCall extends LeadStatusUpdate
	{
		NVM_InternalCall()
		{
			super(true);
		}

		override void updateLead(Task task, Lead lead)
		{
			lead.Status = task.Status__c;
			lead.Suspended_Closed_Reason__c = task.Suspended_Close__c;
		}		
	}
	
	class NVM_ReturnCallback extends LeadStatusUpdate
	{
		NVM_ReturnCallback()
		{
			super(true);
		}

		override void updateLead(Task task, Lead lead)
		{
			if(task.Status__c != 'Callback Requested')
			{
				return;
			}	

			lead.Status = task.Status__c;
			lead.Suspended_Closed_Reason__c = task.Suspended_Close__c;
		}		
	}

	

	class LeadCache
	{
		/*
		*	there is a lot of logic that will iterate over the tasks and update related leads.
		*	As a result it is easeir for now to just load all potential leads up front, rather than 
		*	try and accumulate relevent leads for various reasons whilst only using 1 SOQL.
		*
		*	furthermore, as there are many bits of logic that will update related leads, and therefore
		*	possibly many updates to the same lead, we maintain a 'cache' of updated leads and do just one
		*	DML at the end.
		*/
		private Map<Id, Lead> leads;
		private Map<Id, Lead> leadsToUpdate;

		LeadCache(Map<Id, Lead> leads)
		{
			this.leads = leads;
			this.leadsToUpdate = new Map<Id, Lead>();
		}

		Lead getLead(Id leadId)
		{
			return leads.get(leadId);
		}

		void registerDirty(Lead lead)
		{
			leadsToUpdate.put(lead.Id, lead);
		}

		void updateLeads()
		{
			if(leadsToUpdate.size() > 0)
			{
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.updateRecords(leadsToUpdate.values());
			}
		}
	}
}