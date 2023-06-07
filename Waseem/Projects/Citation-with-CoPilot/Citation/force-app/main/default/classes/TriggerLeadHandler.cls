public with sharing class TriggerLeadHandler {

    //fudged this for now, make these static as they are constant anyway.
    // make 1 visible to tests so can test the chucnk of otheriwse untested code.
    @testVisible
    static Set<String> ihascoIntegrationusers = new Set<String>(System.Label.iHascoLeadDataIntegrationUsers.split(','));
    static String iHascoLeadRTID=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default IHASCO').getRecordTypeId();
    static String iHascoTaskWIRTID=Schema.SObjectType.Task.getRecordTypeInfosByName().get('web enquiry').getRecordTypeId();
    
    /* ATTRIBUTES */
    LeadTriggerHandler lhandler = new LeadTriggerHandler();
    
    /* CONSTRUCTOR */
    private TriggerLeadHandler() {
        
    }

    private static TriggerLeadHandler instance;
    public static TriggerLeadHandler getInstance() {
        if (instance == null) {
            instance = new TriggerLeadHandler();
        }
        return instance;
    }

    /* PUBLIC METHODS */

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    public void onBeforeInsert(final List<Lead> newObjects) {
        lhandler.populateIndividual(newObjects);
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<Lead> newObjects, final Map<Id, Lead> newObjectsMap) {
        
        List<Task> tskList = new List<Task>();
        for(Lead ld : newObjects){
        //Added LeadSource not equal to null to avoid creating tasks for Purchased data
            if((ld.LeadSource <> null) && (ld.RecordTypeId == iHascoleadRTID) && ihascoIntegrationusers.contains(ld.CreatedById) ){
               Task tsk = new Task();
               tsk.WhoId = ld.id;
               tsk.RecordTypeId = iHascoTaskWIRTID;
               tsk.LeadSource__c = ld.LeadSource;
               tsk.utm_campaign__c = ld.utm_campaign__c;
               tsk.utm_keyword__c = ld.utm_keyword__c;
               tsk.utm_medium__c = ld.utm_medium__c;
               tsk.Subject = ld.Prospect_Channel__c;
               tsk.Description = ld.Notes__c; 
               tsk.Status = 'Completed'; 
               tsk.EmailId__c = ld.Email;
               tsk.which_white_paper_download__c = ld.Free_Guide__c; //Added as part of IH-388
               tskList.add(tsk);
            }
            
            
        }
        
        if(!tskList.isEmpty()){
            insert tskList;
        }
        
        
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onBeforeUpdate(final List<Lead> oldObjects, final Map<Id, Lead> oldObjectsMap,
                               final List<Lead> newObjects, final Map<Id, Lead> newObjectsMap) {
                                   
        lhandler.checktoCallUpdateIndividual(newObjects,oldObjectsMap);
                
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    public void onAfterUpdate(final List<Lead> oldObjects, final Map<Id, Lead> oldObjectsMap,
                              final List<Lead> newObjects, final Map<Id, Lead> newObjectsMap) {
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before delete event, deletes all the attached documents and sets the application active to false
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    public void onBeforeDelete(final List<Lead> oldObjects, final Map<Id, Lead> oldObjectsMap) {
        
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    public void onAfterDelete(final List<Lead> oldObjects, final Map<Id, Lead> oldObjectsMap) {
    }

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    public void onAfterUndelete(final List<Lead> newObjects, final Map<Id, Lead> newObjectsMap) {
    }    
}