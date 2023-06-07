/*
*   See INoteService.
*   DTO representing a note that came from.
*
*   We copy notes around and combine them, hence we need to carry some extra
*   metadata around that allows us to merge, split and apply edits etc.
*   Hence, each note has source, which is the record it came from, a key that includes
*   enough info to find a note amongst a larger text field of many combined notes, it 
*   probably included a timestamp for example.
*
*   Had to give it an odd name as there is a Note standard object name clash otherwise
*/
public class SObjectNote 
{
    public String noteSource;  // source of the note, SObject Id
    public String key;         // A key for working out which part of a large text is which note 
    public String note;        // the note text 
    public String user;        // the editing user. 
}