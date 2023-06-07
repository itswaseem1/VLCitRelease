public inherited sharing class NVMService extends DefaultService
{
    /*
	*	This implementation of the service will require a selector to handle loading
	*	records that it will need to perform its job.
	*/
	public interface ISelector
	{
        List<NVMContactWorld__InteractionEvent__c> getInteractionEvents(List<NVMContactWorld__InteractionEventNote__c> notes);
	}

    private ISelector selector;
    private INoteService noteService;

    public NVMService(ISelector selector, INoteService noteService)
    {
        this.selector = selector;
        this.noteService = noteService;
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnNew(List<SObject> newRecords)
    {
        List<NVMContactWorld__InteractionEventNote__c> newNotes = (List<NVMContactWorld__InteractionEventNote__c>)newRecords;

		copyNotesToInterestedParties(newNotes, null);
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        List<NVMContactWorld__InteractionEventNote__c> newNotes = (List<NVMContactWorld__InteractionEventNote__c>)newRecords;
        Map<Id, NVMContactWorld__InteractionEventNote__c> oldNotes = (Map<Id, NVMContactWorld__InteractionEventNote__c>)oldRecords;

		copyNotesToInterestedParties(newNotes, oldNotes);
    }

    private void copyNotesToInterestedParties(List<NVMContactWorld__InteractionEventNote__c> newNotes, Map<Id, NVMContactWorld__InteractionEventNote__c> oldNotes)
    {
        new CopyNotesToInterestedParties(newNotes, oldNotes, selector, noteService).process();
    }

    public class DefaultSelector implements ISelector
    {
        public List<NVMContactWorld__InteractionEvent__c> getInteractionEvents(List<NVMContactWorld__InteractionEventNote__c> notes)
        {
            Set<Id> ids = new Set<Id>();
            for(NVMContactWorld__InteractionEventNote__c note: notes)
            {
                ids.add(note.NVMContactWorld__Event__c);
            }

            return [SELECT NVMContactWorld__IndexedCallObjectIdentifier__c
                    FROM NVMContactWorld__InteractionEvent__c
                    WHERE Id IN :ids];
        }
    }

    class CopyNotesToInterestedParties
    {
		private List<NVMContactWorld__InteractionEventNote__c> notesToProcess;
        private ISelector selector;
		private INoteService noteService;

		CopyNotesToInterestedParties(List<NVMContactWorld__InteractionEventNote__c> newNotes, 
                                    Map<Id, NVMContactWorld__InteractionEventNote__c> oldNotes, 
                                    ISelector selector,
                                    INoteService noteService)
		{
            this.noteService = noteService;
            this.selector = selector;
			this.notesToProcess = getNotesToProcess(newNotes, oldNotes);
		}

        private List<NVMContactWorld__InteractionEventNote__c> getNotesToProcess(List<NVMContactWorld__InteractionEventNote__c> newNotes, Map<Id, NVMContactWorld__InteractionEventNote__c> oldNotes)
        {
            List<NVMContactWorld__InteractionEventNote__c> notesToProcess = new List<NVMContactWorld__InteractionEventNote__c>();

            for(NVMContactWorld__InteractionEventNote__c note: newNotes)
            {
                if(note.NVMContactWorld__Detail__c != null)
                {
                    //insert or update changed detail
                    if(oldNotes == null ||
                        note.NVMContactWorld__Detail__c != oldNotes.get(note.Id).NVMContactWorld__Detail__c)
                    {
                        notesToProcess.add(note);
                    }
                }
            }

            return notesToProcess;
        }

        void process()
        {
            if(notesToProcess.isEmpty())
                return;
                
            List<NVMContactWorld__InteractionEvent__c> events = selector.getInteractionEvents(notesToProcess);
            Map<Id, NVMContactWorld__InteractionEvent__c> eventMap = new Map<Id, NVMContactWorld__InteractionEvent__c>(events);

            List<SObjectNote> callnotes = new List<SObjectNote>();

            for(NVMContactWorld__InteractionEventNote__c eventNote: notesToProcess)
            {
                NVMContactWorld__InteractionEvent__c event = eventMap.get(eventNote.NVMContactWorld__Event__c);

                SObjectNote taskNote = new SObjectNote();
                taskNote.noteSource = event.NVMContactWorld__IndexedCallObjectIdentifier__c;
                taskNote.note = eventNote.NVMContactWorld__Detail__c;
                taskNote.key = 'NVM : ' + eventNote.CreatedDate;

                callNotes.add(taskNote);
            }

            if(!callNotes.isEmpty())
                noteService.setNotes(callNotes);
        }
    }
}