public with sharing class TaskHelper {
    public static final string DIVIDER = '-';
    private static Map<String, String> allNotes = new Map<String, String>();
    private static Map<ID, User> allUsers;
    
    // will load up all users,it is important we do this once and once only
    // as we have thousands of them and there are cases where this trigger
    // gets hit many times, resulting in query row 50001 exception
    // Until/unless this whole flow of key object updates is changed, DO NOT
    // remove the check to ensure a single load per transaction without considering
    // the trigger being called many times.
    @testVisible
    private static Map<Id, User> getUsers()
    {
        if(allUsers == null)
        {
            List<User> users = [Select ID, FirstName, LastName, Name from User];
            allUsers = new Map<Id, User>(users);
        }

        return allUsers;
    }
    

    public static void createInteractionEventNotesLookup (List<Task> newTasks) {
        //Build parent and child list of all Interaction Events and Interaction Notes
        List <NVMContactWorld__InteractionEventNote__c> conList = New List<NVMContactWorld__InteractionEventNote__c>();
        String combinedNote;
        String guid;
        String newGuid;
        String oldGuid;
        List<String> TaskCallGuids = new List<String> ();
        for (Task ss : newTasks) {
            TaskCallGuids .Add (ss.CallObject);
        }

        Map<Id, User> users = getUsers();

        for (NVMContactWorld__InteractionEvent__c event:
            [Select id, name, NVMContactWorld__Agent__c,
            NVMContactWorld__IndexedCallObjectIdentifier__c,
            (SELECT Name, CreatedDate, NVMContactWorld__Detail__c
            FROM NVMContactWorld__Interaction_Event_Notes__r)
            From NVMContactWorld__InteractionEvent__c
            WHERE NVMContactWorld__IndexedCallObjectIdentifier__c IN :TaskCallGuids
            ORDER BY NVMContactWorld__TimeStamp__c ASC NULLS FIRST]) 
        {
            //System.debug('Outside of loop ' + event.NVMContactWorld__IndexedCallObjectIdentifier__c);
            combinedNote = Null;

            //Loop through child records
            for (NVMContactWorld__InteractionEventNote__c note:event.NVMContactWorld__Interaction_Event_Notes__r) {
                //Change ID for real name
                User createdByName = users.get(event.NVMContactWorld__Agent__c);
                newGuid = event.NVMContactWorld__IndexedCallObjectIdentifier__c;
                //System.debug('Debug element ' + note);
                //We need to merge single records into 1
                String noteDetail;
                if (note.NVMContactWorld__Detail__c != Null)
                {
                    noteDetail = note.NVMContactWorld__Detail__c;
                }
                else
                {
                    noteDetail = '';
                }
                conList.add(note);

                //Create the actual string
                //SM    combinedNote = createdByName.Name + ' | on ' + note.CreatedDate + ' | ' + noteDetail + '\r\n';
                if (note.NVMContactWorld__Detail__c != Null) {
                    combinedNote = createdByName.Name + ' | ' + noteDetail + '\r\n';
                }
                else
                {
                    combinedNote = '';
                }
                                
                guid = event.NVMContactWorld__IndexedCallObjectIdentifier__c;
                if (allNotes.get(event.NVMContactWorld__IndexedCallObjectIdentifier__c) == Null)
                {
                    allNotes.put(guid, combinedNote);
                } 
                else
                {
                    String oldNotes = allNotes.get(event.NVMContactWorld__IndexedCallObjectIdentifier__c);
                    allNotes.put(event.NVMContactWorld__IndexedCallObjectIdentifier__c, oldNotes + ' \r\n' + combinedNote);
                }
            }
        }
    }

    public static void processTasks(List<Task> newTasks)
    {
        createInteractionEventNotesLookup (newTasks);

        //Loop through Task records and get GUIDs to query Interaction Events - checking that it is only NVM Tasks
        for (Task ss : newTasks) {
            if (ss.CallType == Null || ss.CallObject == Null) continue;

            String oldValue = ss.Description;
            If (ss.Description == Null) {
              ss.Description = '\r\n' + DIVIDER + '\r\n' + allNotes.get(ss.CallObject);
            } 
            else if (oldValue.contains(DIVIDER)) {
                Integer thingsToRemove = oldValue.indexOf(DIVIDER);
                ss.Description = oldValue.left(thingsToRemove) + '\r\n' + DIVIDER + '\r\n' + allNotes.get(ss.CallObject);
             }
             else {
                String newValue = oldValue + '\r\n' + DIVIDER + '\r\n' + allNotes.get(ss.CallObject);
                ss.Description = newValue;
            }
        }
        //end for
    }
    //end method
}
//end class