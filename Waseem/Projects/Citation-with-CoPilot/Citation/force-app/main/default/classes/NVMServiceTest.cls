@isTest
public class NVMServiceTest
{
    @isTest
    public static void givenNoNote_whenEventNoteInserted_thenNoteServiceNotCalled()
    {
        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        NVMContactWorld__InteractionEventNote__c note = new NVMContactWorld__InteractionEventNote__c();
        note.NVMContactWorld__Detail__c = null;
        note.NVMContactWorld__Event__c = parentEvent.Id;

        List<NVMContactWorld__InteractionEventNote__c> notes = new List<NVMContactWorld__InteractionEventNote__c>{note};

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnNew(notes);
        Test.stopTest();

        system.assertEquals(false, noteService.called);
    }

    @isTest
    public static void givenNoNotes_whenEventNotesProcessed_thenNoSOQLCall()
    {
        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        NVMContactWorld__InteractionEventNote__c note = new NVMContactWorld__InteractionEventNote__c();
        note.NVMContactWorld__Detail__c = null;
        note.NVMContactWorld__Event__c = parentEvent.Id;

        List<NVMContactWorld__InteractionEventNote__c> notes = new List<NVMContactWorld__InteractionEventNote__c>{note};

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnNew(notes);
        Test.stopTest();

        system.assertEquals(false, selector.getInteractionEventsCalled);
    }

    @isTest
    public static void givenNoNote_whenEventNoteUpdated_thenNoteServiceNotCalled()
    {
        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        List<NVMContactWorld__InteractionEventNote__c> oldNotes = new List<NVMContactWorld__InteractionEventNote__c>{
            new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Detail__c = null,
                                                        NVMContactWorld__Event__c = parentEvent.Id)
        
        };
        TestUtility.setIds(oldNotes);

        List<NVMContactWorld__InteractionEventNote__c> newNotes = new List<NVMContactWorld__InteractionEventNote__c>{
            new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Detail__c = null,
                                                        NVMContactWorld__Event__c = parentEvent.Id,
                                                        Id = oldNotes[0].Id)     
        };

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnChange(newNotes, new Map<Id, NVMContactWorld__InteractionEventNote__c>(oldNotes));
        Test.stopTest();

        system.assertEquals(false, noteService.called);
    }

    @isTest
    public static void givenNoteNotChanged_whenEventNoteUpdated_thenNoteServiceNotCalled()
    {
        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        List<NVMContactWorld__InteractionEventNote__c> oldNotes = new List<NVMContactWorld__InteractionEventNote__c>{
            new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Detail__c = 'hello',
                                                        NVMContactWorld__Event__c = parentEvent.Id)
        
        };
        TestUtility.setIds(oldNotes);

        List<NVMContactWorld__InteractionEventNote__c> newNotes = new List<NVMContactWorld__InteractionEventNote__c>{
            new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Detail__c = 'hello',
                                                        NVMContactWorld__Event__c = parentEvent.Id,
                                                        Id = oldNotes[0].Id)     
        };

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnChange(newNotes, new Map<Id, NVMContactWorld__InteractionEventNote__c>(oldNotes));
        Test.stopTest();

        system.assertEquals(false, noteService.called);
    }

    @isTest
    public static void givenNote_whenEventNoteInserted_thenNoteServiceCalled()
    {
        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        NVMContactWorld__InteractionEventNote__c note = new NVMContactWorld__InteractionEventNote__c();
        note.NVMContactWorld__Detail__c = 'hello';
        note.NVMContactWorld__Event__c = parentEvent.Id;

        List<NVMContactWorld__InteractionEventNote__c> notes = new List<NVMContactWorld__InteractionEventNote__c>{note};

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnNew(notes);
        Test.stopTest();

        system.assertEquals(true, noteService.called);
    }

    @isTest
    public static void givenNoteChanged_whenEventNoteUpdated_thenNoteServiceCalled()
    {
        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        List<NVMContactWorld__InteractionEventNote__c> oldNotes = new List<NVMContactWorld__InteractionEventNote__c>{
            new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Detail__c = 'hello',
                                                        NVMContactWorld__Event__c = parentEvent.Id)
        
        };
        TestUtility.setIds(oldNotes);

        List<NVMContactWorld__InteractionEventNote__c> newNotes = new List<NVMContactWorld__InteractionEventNote__c>{
            new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Detail__c = 'edited hello',
                                                        NVMContactWorld__Event__c = parentEvent.Id,
                                                        Id = oldNotes[0].Id)     
        };

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnChange(newNotes, new Map<Id, NVMContactWorld__InteractionEventNote__c>(oldNotes));
        Test.stopTest();

        system.assertEquals(true, noteService.called);
    }

    @isTest
    public static void givenNote_whenEventNoteSentToTasksService_thenCorrectDataSent()
    {
        Datetime now = System.now();

        NVMContactWorld__InteractionEvent__c parentEvent = new NVMContactWorld__InteractionEvent__c();
        parentEvent.NVMContactWorld__IndexedCallObjectIdentifier__c = 'xxx';
        TestUtility.setId(parentEvent);

        NVMContactWorld__InteractionEventNote__c note = new NVMContactWorld__InteractionEventNote__c();
        note.NVMContactWorld__Detail__c = 'hello';
        note.CreatedDate = now;
        note.NVMContactWorld__Event__c = parentEvent.Id;

        List<NVMContactWorld__InteractionEventNote__c> notes = new List<NVMContactWorld__InteractionEventNote__c>{note};

        MockSelector selector = new MockSelector();
        selector.events = new List<NVMContactWorld__InteractionEvent__c>{parentEvent};

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new NVMService(selector, noteService).processRelatedRecordsOnNew(notes);
        Test.stopTest();

        SObjectNote sentNote = (SObjectNote)noteService.notesSent[0];
        system.assertEquals('xxx', sentNote.noteSource);
        system.assertEquals('NVM : ' + now, sentNote.key);
        system.assertEquals('hello', sentNote.note);
    }

    class MockSelector implements NVMService.ISelector
    {
        Boolean getInteractionEventsCalled = false;
        public List<NVMContactWorld__InteractionEvent__c> events;

        public List<NVMContactWorld__InteractionEvent__c> getInteractionEvents(List<NVMContactWorld__InteractionEventNote__c> notes)
        {
            getInteractionEventsCalled = true;
            return events != null ? events : new List<NVMContactWorld__InteractionEvent__c>();
        }
    }

    class MockNoteService implements INoteService
    {
        Boolean called = false;
        List<SObjectNote> notesSent;

        public void setNotes(List<SObjectNote> notes)
        {
            called = true;
            notesSent = notes;
        }

        public void fixManualEdits(List<Sobject> objs, SObjectField noteField)
        {

        }

        public List<SObjectNote> convertToNotes(String existingNotes, String noteSource)
        {
            return new List<SObjectNote>();
        }
    }
}