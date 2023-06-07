/*
*   implementation of the INoteService.
*
*	This impl requires that an INoteTaker (or maybe a list in future)
*	is passed to it, and it is these note takers that will be updated
*	when setNotes is called.  
*
*   This will be done by creating a single string representing many Notes
*	which will be stamped with the current user and timestamp etc
*
*	This service exists as a refactor of existing note handling which was 
*	scattered all over and a mix of confusing techs (PB, WF, Apex, fields etc).
*	This isn't a great impl, and the user requirements would be better served by
*	LWC viewers rather than copying data around, but that can come later on. For
*	now the existing impl needed some fixes.
*/
public inherited sharing class NoteService implements INoteService
{
    public interface ISelector 
    {
        String getCurrentUserName();
    }

    private ISelector selector;
	private INoteTaker noteTaker;

    public NoteService(ISelector selector, INoteTaker noteTaker)
    {
        this.selector = selector;
		this.noteTaker = noteTaker;
    }

	/*
	*	See INoteService
	*/
	public void setNotes(List<SObjectNote> notes)
	{
		new CopyCallNotes(notes, selector, noteTaker).process();
	}

    /*
    *   See INoteService
    */
    public void fixManualEdits(List<Sobject> objs, SObjectField noteField)
    {
        new FixManualEdits(objs, noteField, selector).process();
    }

    /*
    *   See INoteService
    */
	public List<SObjectNote> convertToNotes(String existingNotes, String noteSource)
	{
		return new NoteProcessor(selector).convertToNotes(existingNotes, noteSource);
	}

    
    public class DefaultSelector implements ISelector
    {
        public String getCurrentUserName()
        {
            return UserInfo.getUserName();
        }
    }

    class NoteProcessor
	{
		private ISelector selector;
		private String keyStart = '--\n[';
		private String keyEnd = ']';
		private String oldDelimiter = '[old style notes]';

		NoteProcessor(ISelector selector)
		{
			this.selector = selector;
		}

		List<SObjectNote> convertToNotes(String description, String source)
		{
			List<SObjectNote> notes = new List<SObjectNote>();

			grabNotes(description, notes, 0);

			for(SObjectNote note: notes)
			{
				note.noteSource = source;
			}

			return notes;
		}

		String fixManualEdits(String description)
		{
			if(description == null)
				return null;

			description = description.replace('\r\n', '\n');
			Datetime now = System.now();

			List<SObjectNote> notes = new List<SObjectNote>();
			grabNotes(description, notes, 0);

			String newDescription = null;
			for(SObjectNote note: notes)
			{
				if(note.key == null)
				{
					note.key = 'Manual : ' + now;
				}

				newDescription = mergeNote(newDescription, note);
			}

			return newDescription;
		}

        /*
        *   Recursive function that will parse the description looking for notes with
        *   keys or those without and populate the notes list with the DTO representations.
        */
		private void grabNotes(String description, List<SObjectNote> notes, Integer start)
		{
			if(description == null || start >= description.length())
				return;

			Integer index = description.indexOf(keyStart, start);
			Integer nextNoteIndex = description.indexOf(keyStart, index + 1);

			SObjectNote note = new SObjectNote();
			if(start < index) // manual edit before proper key notes
			{
				// the first part must be a manual note, so create it
				// then set the nextNoteIndex to be the one we found, so 
				// that is where we start from in next recursive call.
				note.note = description.subString(start, index);
				nextNoteIndex = index;
			}
			else if(index < 0)  // no proper keyed notes, all old style or manual
			{
				// no keyed note, the entire description is a manual edit
				note.note = description;
				nextNoteIndex = -1;
			}
			else // we have a proper keyed note which may or may not be followed by more
			{
				// find the end bracket, and then the key is the bit between both brackets.
				Integer keyEndIndex = description.indexOf(keyEnd, index + 1);
				String key = description.subString(index + keyStart.length(), keyEndIndex);

				// check for next keyed note, get the text between end of key and start of next 
				// note or the end of full description as needed.
				// NB if there is no nextNote then there may also be old style notes
				// beyond, which we end up picking as part of this note in essence.
				// that issue should disappear over time, so not changing anything for now
				String noteText = nextNoteIndex < 0 ? 
									description.subString(keyEndIndex + 1) : 
									description.subString(keyEndIndex + 1, nextNoteIndex);
				
				// remove the 'username | ' part from the note.
				// we only want the first | as there could be others in the notes themselves
				// or more likely they can be part of the old style note seprator
				// split('\\|', 2) ensure we split at the first | only.
				List<String> noteParts = noteText.split('\\|', 2); 
				String userName = noteParts[0].trim();
				noteText = noteParts[1].trim();

				note.key = key;
				note.note = noteText;
				note.user = userName;
			}

			if(notes.size() > 0)
				notes.add(0, note);
			else
				notes.add(note);

			if(nextNoteIndex > 0)
				grabNotes(description, notes, nextNoteIndex);
		}

		String mergeNote(String description, SObjectNote note)
		{
			String userName = note.user != null ? note.user : selector.getCurrentUserName();
			String newPart = keyStart + note.key + keyEnd + ' ' + userName + ' | ' + '\n\n' + note.note + '\n';

			Integer existingNotes = getExistingNotePosition(description, note.key);
			
			if(existingNotes == null)
			{
				String oldPart = description == null ? '' : description;
			
				return newPart + oldPart;
			}
			else
			{
				return replace(description, existingNotes, newPart);
			}			
		}

		Integer getExistingNotePosition(String description, String key)
		{
			if(description == null)
				return null;

			String fullKey = keyStart + key + keyEnd;
			Integer index = description.indexOf(fullKey);
			return index < 0 ? null : index;
		}

		String replace(String description, Integer index, String newNote)
		{
			Integer nextIndex = description.indexOf(keyStart, index + 1);
			if(nextIndex < 0)
			{
				// make sure we do not lose all the old notes, so we put the new
				// not between key of new note and start of old notes
				nextIndex = getOldStyleNotePosition(description, index + keyStart.length());
			}

			if(nextIndex < 0)
			{
				return description.subString(0, index) + newNote;
			}				
			else
			{
				String oldPart1 = description.subString(0, index);
				String oldPart2 = description.subString(nextIndex);

				return oldPart1 + newNote + oldPart2;
			}
		}

		Integer getOldStyleNotePosition(String description, Integer startPosition)
		{
			if(description == null)
				return -1;
			
			Integer firstBrace = description.indexOf('[', startPosition);
			if(firstBrace < 0)
				return -1;

			Integer citationEmail = description.indexOf('@citation', firstBrace);
			if(citationEmail < 0)
				return -1;

			Integer lastBrace = description.indexOf(']', citationEmail);
		
			return lastBrace < 0 ? -1 : firstBrace;
		}
	}

	class FixManualEdits
	{
		private List<Sobject> objs;
		private ISelector selector;
		private SObjectField noteField;

		FixManualEdits(List<Sobject> objs, SObjectField noteField, ISelector selector)
		{
			this.objs = objs;
			this.selector = selector;
			this.noteField = noteField;		
		}

		void process()
		{
			NoteProcessor processor = new NoteProcessor(selector);

			for(Sobject obj: objs)
			{
				String notes = (String)obj.get(noteField);
				String newNotes = processor.fixManualEdits(notes);
				if(newNotes != notes)
				{
					obj.put(noteField, newNotes);
				}
			}
		}
	}

	class CopyCallNotes
    {
		private List<SObjectNote> notes;
		private ISelector selector;
		private INoteTaker noteTaker;

		CopyCallNotes(List<SObjectNote> notes, ISelector selector, INoteTaker noteTaker)
		{
			this.notes = notes;
			this.selector = selector;
			this.noteTaker = noteTaker;		
		}

        void process()
        {
			if(noteTaker == null || notes.isEmpty())
				return;

			NoteProcessor processor = new NoteProcessor(selector);
			Map<String, SObject> objs = noteTaker.getRecipientRecords(notes);
			SObjectField fld = noteTaker.getNoteField();
			Integer fieldLength = fld.getDescribe().getLength();

			Map<Id, SObject> updatedObjs = new Map<Id, SObject>();
			for(SObjectNote note: notes)
			{
				SObject obj = objs.get(note.noteSource);
				if(obj == null)
					continue;

				String existingNotes = (String)obj.get(fld);

				String newDescription = processor.mergeNote(existingNotes, note);
				if(newDescription != existingNotes)
				{
					// truncate if too big
					if(newDescription.length() >= fieldLength)
						newDescription = newDescription.left(fieldLength - 1);

					obj.put(fld, newDescription);
					updatedObjs.put(obj.Id, obj);
				}
			}

			if(!updatedObjs.isEmpty())
			{
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.updateRecords(updatedObjs.values());
			}			
        }
    }
}