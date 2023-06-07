@isTest
public class NoteServiceTest
{
    @isTest
	public static void givenExistingPriorFormatNoteAndNewNote_whenEditNewNote_thenCorrectlyMergesEdit()
	{
		SObjectNote note = new SObjectNote();
		note.noteSource = '111';
		note.key = 'Key : 2022-12-10';
		note.note = 'An edited message';

		String newNote = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
		String oldStyleNote = '[amandahailey@citation.co.uk 2022-10-06 10:18:22]\n-\nAmanda Hailey | an old note';

		Map<String, Task> tasks = new Map<String, Task>{
			'111' => new Task(callObject = '111', Description = newNote + '\n' + oldStyleNote)
		};

		MockSelector selector = new MockSelector();
		selector.user = 'Bob';

		MockNoteTaker taker = new MockNoteTaker();
		taker.objsToUpdate = tasks;

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		Test.startTest();
		new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
		Test.stopTest();
		
		System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
		String finalMessage = ((Task)uow.getRecords(Task.SObjectType)[0]).Description;
		String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n' + oldStyleNote;

		System.assertEquals(expectedMessage, finalMessage);
	}

	@isTest
	public static void givenExistingPriorFormatNoteAndNewNote_whenEditNewNote_thenLeavesOldNotes()
	{
		SObjectNote note = new SObjectNote();
		note.noteSource = '111';
		note.key = 'Key : 2022-12-10';
		note.note = 'An edited message';

		String newNote = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
		String oldStyleNote = '[amandahailey@citation.co.uk 2022-10-06 10:18:22]\n-\nAmanda Hailey | an old note';

		Map<String, Task> tasks = new Map<String, Task>{
			'111' => new Task(callObject = '111', Description = newNote + '\n' + oldStyleNote)
		};

		MockSelector selector = new MockSelector();
		selector.user = 'Bob';

		MockNoteTaker taker = new MockNoteTaker();
		taker.objsToUpdate = tasks;

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		Test.startTest();
		new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
		Test.stopTest();
		
		System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
		String finalMessage = ((Task)uow.getRecords(Task.SObjectType)[0]).Description;
		System.assert(finalMessage.endsWith(oldStyleNote), 'Expected Message ends with ' + oldStyleNote + ' actual message ' + finalMessage);
	}

	@isTest
	public static void givenExistingPriorFormatNoteAndNewNote_whenFixManualEdits_thenLeavesOldNotes()
	{

		String edit = 'A message';
		String newNote = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
		String oldStyleNote = '[amandahailey@citation.co.uk 2022-10-06 10:18:22]\n-\nAmanda Hailey | an old note';

		Map<String, Task> tasks = new Map<String, Task>{
			'111' => new Task(callObject = '111', Description = edit + '\n' +newNote + oldStyleNote)
		};

		MockSelector selector = new MockSelector();
		selector.user = 'Bob';

		MockNoteTaker taker = new MockNoteTaker();

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		Test.startTest();
		new NoteService(selector, taker).fixManualEdits(tasks.values(), Task.Description);
		Test.stopTest();

		String finalMessage = tasks.values()[0].Description;
		System.assert(finalMessage.trim().endsWith(oldStyleNote), 'Expected Message ends with ' + oldStyleNote + '\n actual message ' + finalMessage);
	}

	@isTest
	public static void givenExistingPriorFormatNote_whenSetNotesCalled_thenLeavesOldNotes()
	{
		SObjectNote note = new SObjectNote();
		note.noteSource = '111';
		note.key = 'Key : 2022-12-10';
		note.note = 'A message';

		String oldStyleNote = '[amandahailey@citation.co.uk 2021-01-11 17:21:05]\nAn Existing note';
		Map<String, Task> tasks = new Map<String, Task>{
			'111' => new Task(callObject = '111', Description = oldStyleNote)
		};

		MockSelector selector = new MockSelector();
		selector.user = 'Bob';

		MockNoteTaker taker = new MockNoteTaker();
		taker.objsToUpdate = tasks;

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		Test.startTest();
		new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
		Test.stopTest();
		
		System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
		String finalMessage = ((Task)uow.getRecords(Task.SObjectType)[0]).Description;
		System.assert(finalMessage.endsWith(oldStyleNote), 'Expected Message ends with ' + oldStyleNote + ' actual message ' + finalMessage);
	}

	@isTest
	public static void givenExistingPriorFormatNote_whenFixManualEdits_thenLeavesOldNotes()
	{

		String edit = 'A message';
		String oldStyleNote = '[amandahailey@citation.co.uk 2023-01-11 17:21:05]\nAn Existing note';
		Map<String, Task> tasks = new Map<String, Task>{
			'111' => new Task(callObject = '111', Description = edit + '\n' +oldStyleNote)
		};

		MockSelector selector = new MockSelector();
		selector.user = 'Bob';

		MockNoteTaker taker = new MockNoteTaker();

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		Test.startTest();
		new NoteService(selector, taker).fixManualEdits(tasks.values(), Task.Description);
		Test.stopTest();

		String finalMessage = tasks.values()[0].Description;
		System.assert(finalMessage.trim().endsWith(oldStyleNote), 'Expected Message ends with ' + oldStyleNote + ' actual message ' + finalMessage);
	}

	@isTest
    public static void givenNoNotes_whensetNotesCalled_thenDoesNotCallIntefaces()
    {
        MockSelector selector = new MockSelector();
        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>());
        Test.stopTest();

        System.assertEquals(false, selector.called);
        System.assertEquals(false, taker.called);
    }

    @isTest
    private static void givenNewNote_whenNoRecipient_thenDoNotError()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'A message';

        Map<String, Task> tasks = new Map<String, Task>{
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        try
        {
            new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        }
        catch(Exception e)
        {
            System.assert(false, 'SObjectNote Service should not have failed : ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void givenNewNote_whenSetCallNotes_thenSetDescription()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'A message';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = null)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
        System.assertEquals(expectedMessage, ((Task)uow.getRecords(Task.SObjectType)[0]).Description);
    }

    

    @isTest
    private static void givenNewVeryLongNote_whenSetCallNotes_thenTruncatesValue()
    {
        String msgPart = 'abcdefghijklm';
        String msg = '';
        for(Integer i = 0; i < 3200; i++)
            msg += msgPart;

        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = msg;

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = null)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
        String notes = ((Task)uow.getRecords(Task.SObjectType)[0]).Description;
        System.assertEquals(31999, notes.length());//fld size - 1 (for safety)
    }

    @isTest
    private static void givenManyNotesFor1Task_whenSetCallNotes_thenSetDescription()
    {
        SObjectNote note1 = new SObjectNote();
        note1.noteSource = '111';
        note1.key = 'Key : 2022-12-10';
        note1.note = 'A message';

        SObjectNote note2 = new SObjectNote();
        note2.noteSource = '111';
        note2.key = 'Key : 2022-12-11';
        note2.note = 'Another message';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = null)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note1, note2});
        Test.stopTest();

        String expectedMessage = '--\n[Key : 2022-12-11] Bob | \n\nAnother message\n';
        expectedMessage += '--\n[Key : 2022-12-10] Bob | \n\nA message\n';

        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
        System.assertEquals(expectedMessage, ((Task)uow.getRecords(Task.SObjectType)[0]).Description);
    }

    @isTest
    private static void givenNotesForManyTasks_whenSetCallNotes_thenSetDescription()
    {
        SObjectNote note1 = new SObjectNote();
        note1.noteSource = '111';
        note1.key = 'Key : 2022-12-10';
        note1.note = 'A message';

        SObjectNote note2 = new SObjectNote();
        note2.noteSource = '222';
        note2.key = 'Key : 2022-12-11';
        note2.note = 'Another message';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = null),
            '222' => new Task(callObject = '222', Description = null)
        };
        TestUtility.setIds(tasks.values());

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note1, note2});
        Test.stopTest();

        List<Task> updatedTasks = (List<Task>)uow.getRecords(Task.SObjectType);
        System.assertEquals(2, updatedTasks.size());

        Map<id, Task> updatedTaskMap = new Map<Id, Task>(updatedTasks);
        System.assertEquals('--\n[Key : 2022-12-10] Bob | \n\nA message\n', updatedTaskMap.get(tasks.get('111').id).Description);
        System.assertEquals('--\n[Key : 2022-12-11] Bob | \n\nAnother message\n', updatedTaskMap.get(tasks.get('222').id).Description);
    }

    @isTest
    private static void givenExistingNote_whenSetCallNotes_thenDoesNotUpdateTask()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'A message';

        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = expectedMessage)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Task.SObjectType).size());
    }

    @isTest
    private static void givenExistingNote_whenAddNewNote_thenUpdatesNotes()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-11';
        note.note = 'Another message';

        String oldMessage = '--\n[Key : 2022-12-10] Harry | \n\nA message\n';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = oldMessage)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
        Task task = (Task)uow.getRecords(Task.SObjectType)[0];
        String expectedNotes = '--\n[Key : 2022-12-11] Bob | \n\nAnother message\n' + oldMessage;
        System.assertEquals(expectedNotes, task.Description);
    }

    @isTest
    private static void givenExistingNoteAmongstManyNotes_whenSetCallNotes_thenDoesNotUpdateTask()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'Message 2';

        String oldMessage = '--\n[Key : 2022-12-09] Bob | \n\nMessage 1\n--\n[Key : 2022-12-10] Bob | \n\nMessage 2\n--\n[Key : 2022-12-11] Bob | \n\nMessage 3\n';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = oldMessage)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Task.SObjectType).size());
    }

    @isTest
    private static void givenUpdatedNote_whenSetCallNotes_thenUpdateTaskDescription()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'An edited message';

        String oldMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = oldMessage)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        List<Task> updatedTasks = (List<Task>)uow.getRecords(Task.SObjectType);
        System.assertEquals(1, updatedTasks.size());
        System.assertEquals('--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n', updatedTasks[0].Description);
    }

    @isTest
    private static void givenUpdatedNoteAmongstManyNotes_whenSetCallNotes_thenUpdateTaskDescription()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'An edited message';

        String oldMessage = '--\n[Key : 2022-12-09] Harry | \n\nMessage 1\n--\n[Key : 2022-12-10] Harry | \n\nMessage 2\n--\n[Key : 2022-12-11] Harry | \n\nMessage 3\n';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(callObject = '111', Description = oldMessage)
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();
        taker.objsToUpdate = tasks;

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new NoteService(selector, taker).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        List<Task> updatedTasks = (List<Task>)uow.getRecords(Task.SObjectType);
        System.assertEquals(1, updatedTasks.size());

        String expectedMsg = '--\n[Key : 2022-12-09] Harry | \n\nMessage 1\n--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n--\n[Key : 2022-12-11] Harry | \n\nMessage 3\n';
        System.assertEquals(expectedMsg, updatedTasks[0].Description);
    }

    @isTest
    private static void givenManualEditOfDescription_whenCallTask_thenConvertsNoteToKeyedVersion()
    {
        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = 'A manual Edit')
        };

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        // 2 asserts, as we don't know the exact dateTime
        String expectedPrefix = '--\n[Manual : ';
        String expectedSuffix = '] Bob | \n\nA manual Edit\n';
        System.assert(tasks[0].Description.startsWith(expectedPrefix), tasks[0].Description + ' should have been converted to keyed style');
        System.assert(tasks[0].Description.endsWith(expectedSuffix), tasks[0].Description + '  should have been converted to keyed style');
    }

    @isTest
    private static void givenKeyNotes_whenCallTask_thenConvertsNoteIgnoresKeyedVersion()
    {
        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n';
        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = expectedMessage)
        };
        TestUtility.setIds(tasks);

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        System.assertEquals(expectedMessage, tasks[0].Description);
    }

    @isTest
    private static void givenKeyNotes_whenWindowsReturns_thenConvertsNoteIgnoresKeyedVersion()
    {
        String windowsMessage = '--\r\n[Key : 2022-12-10] Bob | \n\nAn edited message\r\n';
        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = windowsMessage)
        };
        TestUtility.setIds(tasks);

        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n';
        System.assertEquals(expectedMessage, tasks[0].Description);
    }

    @isTest
    private static void givenManualAndKeyedNotes_whenCallTask_thenConvertsNotes()
    {
        String expectedMessage = 'Manual SObjectNote';
        expectedMessage += '--\n[Key : 2022-12-09] Harry | \n\nAnother edited message\n';
        
        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = expectedMessage)
        };
        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        System.assert(tasks[0].Description.startsWith('--\n[Manual'), 'Did not convert manual note :' + tasks[0].Description);
        System.assert(tasks[0].Description.contains('Bob | \n\nManual SObjectNote'), 'Did not convert manual note :' + tasks[0].Description);
        System.assert(tasks[0].Description.endsWith('--\n[Key : 2022-12-09] Harry | \n\nAnother edited message\n'), 'Lost the keyed note :' + tasks[0].Description);
    }

    @isTest
    private static void givenMultiKeyNotes_whenCallTask_thenConvertsNoteIgnoresKeyedVersion()
    {
        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n';
        expectedMessage += '--\n[Key : 2022-12-09] Harry | \n\nAnother edited message\n';

        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = expectedMessage)
        };
        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        System.assertEquals(expectedMessage, tasks[0].Description);
    }

    @isTest
    private static void givenKeyNotes_whenCallTaskWithDifferentUser_thenConvertsNoteRetainsUserName()
    {
        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n';
        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = expectedMessage)
        };
        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        System.assertEquals(expectedMessage, tasks[0].Description);
    }

    @isTest
    private static void givenNullDescription_whenCallTask_thenConvertsNoteToKeyedVersionLeavesNull()
    {
        List<Task> tasks = new List<Task>{
            new Task(callObject = '111', Description = null)
        };
        MockSelector selector = new MockSelector();
        selector.user = 'Bob';

        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        new NoteService(selector, taker).fixManualEdits(tasks, Task.Description);
        Test.stopTest();

        System.assertEquals(null, tasks[0].Description);
    }

    @isTest
    private static void givenNoteFieldWith1Note_whenConvertedToNotes_thenConvertsCorrectly()
    {
        String oldNotes = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n';

        MockSelector selector = new MockSelector();
        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        List<SObjectNote> notes = new NoteService(selector, taker).convertToNotes(oldNotes, '111');
        Test.stopTest();


        System.assertEquals(1, notes.size());
        SObjectNote note = notes[0];
        System.assertEquals('111', note.noteSource);
        System.assertEquals('Key : 2022-12-10', note.key);
        System.assertEquals('An edited message', note.note);
        System.assertEquals('Bob', note.user);
    }

    @isTest
    private static void givenNoteFiledWithManyNotes_whenConvertedToNotes_thenConvertsCorrectly()
    {
        String oldNotes = '--\n[Key : 2022-12-10] Bob | \n\nAn edited message\n';
        oldNotes += '--\n[Key : 2022-12-11] Harry | \n\nAnother message\n';

        MockSelector selector = new MockSelector();
        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        List<SObjectNote> notes = new NoteService(selector, taker).convertToNotes(oldNotes, '111');
        Test.stopTest();


        System.assertEquals(2, notes.size());
        SObjectNote note = notes[0];
        System.assertEquals('111', note.noteSource);
        System.assertEquals('Key : 2022-12-11', note.key);
        System.assertEquals('Another message', note.note);
        System.assertEquals('Harry', note.user);

        note = notes[1];        
        System.assertEquals('111', note.noteSource);
        System.assertEquals('Key : 2022-12-10', note.key);
        System.assertEquals('An edited message', note.note);
        System.assertEquals('Bob', note.user);
    }

    @isTest
    private static void givenNullNoteFiled_whenConvertedToNotes_thenReturnsEmptyList()
    {
        String oldNotes = null;

        MockSelector selector = new MockSelector();
        MockNoteTaker taker = new MockNoteTaker();

        Test.startTest();
        List<SObjectNote> notes = new NoteService(selector, taker).convertToNotes(oldNotes, '111');
        Test.stopTest();


        System.assertEquals(0, notes.size());
    }

    class MockNoteTaker implements INoteTaker
    {
        public Boolean called = false;
        public Map<String, Task> objsToUpdate;

        public SObjectField getNoteField()
        {
            return Task.Description;
        }

        public Map<String, SObject> getRecipientRecords(List<SObjectNote> notes)
        {
            called = true;
            return objsToUpdate != null ? objsToUpdate : new Map<String, Task>();
        }
    }

    class MockSelector implements NoteService.ISelector
    {
        public Boolean called = false;
        public String user;

        public String getCurrentUserName()
        {
            called = true;
            return user == null ? UserInfo.getName() : user;
        }
    }
}