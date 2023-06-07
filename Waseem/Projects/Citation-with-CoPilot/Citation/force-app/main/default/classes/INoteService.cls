/*
*   We have some areas, mainly tasks/leads that pull in notes from 
*   many individual records and concenate them together into 1 large
*   text field. This isn't great, but for now this service is an attempt
*   to have a single service handle this generically, that can be used
*   by any object that wishes such a feature.
*/
public interface INoteService
{
    /*
    *   Tell the notes service to process these notes.
    *   Who, what, how etc are upto the service. This is
    *   really a method for a note setter to signal there are
    *   notes that others may wish to copy or know about etc.
    */
    void setNotes(List<SObjectNote> notes);

    /*
    *   Given a string representing existing notes concatenated 
    *   together then check for any manual edits, as in those with
    *   no source/timestamp etc, and return a version with those edits
    *   changed to have a source and timestamp (which will be 'now').
    */
    void fixManualEdits(List<Sobject> objs, SObjectField noteField);

    /*
    *   take an existing text field of old notes and convert them back
    *   into a list of Notes, with the given noteSource
    */
    List<SObjectNote> convertToNotes(String existingNotes, String noteSource);

}