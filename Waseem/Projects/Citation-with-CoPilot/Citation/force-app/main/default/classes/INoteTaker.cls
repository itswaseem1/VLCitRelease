public interface INoteTaker
{
	SObjectField getNoteField();

    Map<String, SObject> getRecipientRecords(List<SObjectNote> notes);    
}