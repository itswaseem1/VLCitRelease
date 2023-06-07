public with sharing class CIT_TaskNobleLeadIntegration implements ITaskAfterInsertProcessor {
    
    public List<Task> candidates = new List<Task>();
    public Set<Id> leadIds = new Set<Id>();
    public Set<Id> userIds = new Set<Id>();
    
    private static Set<Id> processedTasks = new Set<Id>();
    
    public static List<Schema.PicklistEntry> statusOptions = new List<Schema.PicklistEntry>();
    public static List<Schema.PicklistEntry> suspendedClosedReasoncOptions = new List<Schema.PicklistEntry>();
    
    public static Map<String, String> nobleToSuspClosed = new Map<String, String>{'Answer Machine - Answer Machine' => 'Answer Machine', 
        'Closed - Branch' => 'Branch', 'Closed - Bad Sector' => 'Bad Sector', 'Closed - Client' => 'Client', 'Closed - Ceased Trading' => 'Ceased Trading',
        'Closed - Do Not Call' => 'Do Not Call', 'Closed - Duplicate' => 'Duplicate', 'Closed - Local Authority' => 'Local Authority',
        'Closed - Not Interested' => 'Not Interested', 'Closed - Sole Trader' => 'Sole Trader', 'Closed - Over Criteria' => 'Over Criteria', 'Closed - Under Criteria' => 'Under Criteria',
        'Callback Scheduled - DMC Callback' => 'DM Callback', 'Callback Scheduled - NON DMC Callback' => 'Non DM Callback', 'Open - Decision Maker Unav' => 'Decision Maker Unavailable',
        'Open - Fax' => 'Answer Machine', 'Open - Gate Keeper Refusal' => 'Gatekeeper Refusal', 'Open - No Answer' => 'No Answer', 'No Answer' => 'No Answer',
        'Closed - Third Party Renewal' => 'Third Party Renewal', 'Employee' => 'Employee', 'Member of the public' => 'Member of the public'};
    
    public static Map<String, String> suspClosedToProspect = new Map<String, String>{'Answer Machine' => 'Open', 'Branch' => 'Closed', 'Bad Sector' => 'Suspended', 
        'Client' => 'Closed', 'Ceased Trading' => 'Closed', 'Do Not Call' => 'Closed', 'Duplicate' => 'Closed', 'Sole Trader' => 'Closed', 'Not Interested' => 'Suspended',
        'Over Criteria' => 'Closed', 'Under Criteria' => 'Suspended', 'DM Callback' => 'Callback Requested', 'Non DM Callback' => 'Callback Requested', 'Local Authority' => 'Closed',
        'Decision Maker Unavailable' => 'Open', 'Gatekeeper Refusal' => 'Open', 'No Answer' => 'Open', 'Third Party Renewal' => 'Suspended', 'Employee' => 'Closed', 'Member of the public' => 'Closed'};
    
    static {
        leadPicklistOptions();
    }
    
    public static void leadPicklistOptions() {
        DescribeSObjectResult descLead = Lead.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = descLead.fields.getMap();
        statusOptions = fieldMap.get('Status').getDescribe().getPickListValues(); 
        suspendedClosedReasoncOptions = fieldMap.get('Suspended_Closed_Reason__c').getDescribe().getPickListValues();
    }
    
    // Takes an IProcessorFactory, if of type ITaskAfterInsertFactory, check its array of tasks that need processing.
    // If it has new tasks with 'Outbound Call', add these tasks to the processors internal list for processing.
    // Get the lead and user Id's so we can perform a single SOQL query when we process the candidates.
    public boolean hasCandidates(IProcessorFactory factory) {
        if (factory instanceof ITaskAfterInsertFactory) {

            for (Task checkTask : ((ITaskAfterInsertFactory)factory).getNewTasks()) {
                if (!processedTasks.contains(checkTask.Id)) {
                    if (checkTask.Subject != null && checkTask.Subject.trim() == 'Outbound Call')
                        candidates.Add(checkTask);
                    if (checkTask.WhoId != null) 
                        leadIds.Add(checkTask.WhoId);
                    if (checkTask.OwnerId != null)
                        userIds.Add(checkTask.OwnerId); 
                }
            }
            if (!candidates.isEmpty())
                return true;
        }
        return false;   
    }
    
    // Perform the required operation on the new tasks.
    public void processCandidates() {
        // Batch Apex get leads related to tasks and their owners
        Map<Id, Lead> processedLeads = new Map<Id, Lead>();
        Map<Id, Lead> relatedLeads = new Map<Id, Lead>([SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c FROM Lead WHERE Id IN :leadIds]);
        Map<Id, User> relatedUsers = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :userIds]);
        
        for (Task processTask : candidates) {
            // Check for call disposition, check this against the Maps to make sure the information is valid for Salesforce.
            if (processTask.CallDisposition != null  && processTask.CallDisposition.length() > 0) {
                // Get the lead the task will be updating.
                if (relatedLeads.containsKey(processTask.WhoId)) {
                        Lead updateLead = relatedLeads.get(processTask.WhoId);
    
                    if (nobleToSuspClosed.containsKey(processTask.CallDisposition)) {
                        String suspClosedReason = nobleToSuspClosed.get(processTask.CallDisposition.trim());
                        
                        if (suspClosedToProspect.containsKey(suspClosedReason)) {
                            String prospectStatus = suspClosedToProspect.get(suspClosedReason);
                            
                            if (getPicklistEntryForLabel(prospectStatus, statusOptions) != null && getPicklistEntryForLabel(suspClosedReason, suspendedClosedReasoncOptions) != null) {
                                // set the statuses in the Lead, BDC__c only needs to be set for 'Callback Requested'
                                //updateLead.BDC__c = null;
                                updateLead.Status = getPicklistEntryForLabel(prospectStatus, statusOptions).getLabel();
                                updateLead.Suspended_Closed_Reason__c = getPicklistEntryForLabel(suspClosedReason, suspendedClosedReasoncOptions).getLabel();
                                
                                // set any notes from the task in the Lead.
                                if (processTask.OwnerId != null) {
                                    if (updateLead.Status == 'Callback Requested')  updateLead.BDC__c = processTask.OwnerId;
                                
                                    User owner = relatedUsers.get(processTask.OwnerId); 
                                    getNotes(processTask, updateLead, owner);
                                }
                                // If all checks pass, add lead to list of leads to be updated.
                                processedLeads.Put(updateLead.Id, updateLead);
                            }
                        }
                    
                    }
                }
            }
            // All tasks must be added to processedTasks in case the trigger fires a second time, this batch do not need updating.
            processedTasks.Add(processTask.Id);
        }
        // updated the leads that have been successfully altered.
        update processedLeads.values();
    }
    
    public Schema.PicklistEntry getPicklistEntryForLabel(String label, List<Schema.PicklistEntry> listToCheck) {
        Schema.PicklistEntry returnEntry = null; 
        for (Schema.PicklistEntry entry : listToCheck) {
            if (entry.getLabel() == label) {
                 returnEntry = entry;
            }
        }
        return returnEntry;
    }
    
    public void getNotes(Task newTask, Lead updateLead, User creator) {
        system.debug(Logginglevel.ERROR, newTask);
        String agentNotes = 'Agent Notes:';
        if (newTask.Description != null && newTask.Description.indexOf(agentNotes) != -1) { 
            String notes = newTask.Description.substring(newTask.Description.indexOf(agentNotes) 
                            + agentNotes.length(), newTask.Description.length()).trim();
            if (notes != null && notes.length() > 0 && creator != null) {
                
                notes = '[' + creator.Email + ' ' + newTask.CreatedDate.format('dd/MM/yyyy')
                     + ' ' + newTask.CreatedDate.format('HH:mm:ss') + ']\n' + notes + '\n\n';
                
                if (updateLead.Notes__c != null) { 
                    updateLead.Notes__c = notes + updateLead.Notes__c;
                } else {
                    updateLead.Notes__c = notes;
                }
            }
        }
    }
}