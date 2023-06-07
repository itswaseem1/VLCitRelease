public with sharing class AtlasLeavePlanTriggerHandler {
    public static final String CANCELLED_PLAN_STATUS = 'Cancelled';
    // check if user has active Service Resource and create Resource Absence after Atlas Leave Plan creating
    public static void checkActiveServiceResource(List<Atlas_Leave_Plan__c> newLeavePlans) {
        if (newLeavePlans.isEmpty()) {
            return;
        }
        Map<Id, Map<Id, Atlas_Leave_Plan__c>> usersLeavePlansMap = new Map<Id, Map<Id, Atlas_Leave_Plan__c>>();
        for (Atlas_Leave_Plan__c leavePlan : newLeavePlans) {
            if (leavePlan.Status__c != CANCELLED_PLAN_STATUS) {
                ResourceAbsenceManager.getUsersLeavePlansMap(usersLeavePlansMap, leavePlan);
            }
        }
        List<ServiceResource> serviceResources = [
            SELECT Id, IsActive, RelatedRecordId
            FROM ServiceResource
            WHERE IsActive = TRUE
            AND RelatedRecordId IN :usersLeavePlansMap.keySet()
            WITH SECURITY_ENFORCED
        ];
        ResourceAbsenceManager.createNewResourceAbsences(serviceResources, usersLeavePlansMap);
    }
    // update Resource Absence after Atlas Leave plan updating
    public static void updateResourceAbsence(Map<Id, Atlas_Leave_Plan__c> oldPlans, Map<Id, Atlas_Leave_Plan__c> newPlans) {
        Map<Id, Map<Id, Atlas_Leave_Plan__c>> changedPlanDetailsMap = new Map<Id, Map<Id, Atlas_Leave_Plan__c>>();
        Map<Id, Map<Id, Atlas_Leave_Plan__c>> cancelledPlansMap = new Map<Id, Map<Id, Atlas_Leave_Plan__c>>();
        for (Atlas_Leave_Plan__c newPlan : newPlans.values()) {
            Boolean isCancelledPlan = newPlan.Status__c == CANCELLED_PLAN_STATUS;
            Boolean isChangedPlan =
                !newPlan.From_Date__c.isSameDay(oldPlans.get(newPlan.Id).From_Date__c) ||
                !newPlan.To_Date__c.isSameDay(oldPlans.get(newPlan.Id).To_Date__c) ||
                newPlan.Status__c != oldPlans.get(newPlan.Id).Status__c;
            if (isChangedPlan && !isCancelledPlan) {
                ResourceAbsenceManager.getUsersLeavePlansMap(changedPlanDetailsMap, newPlan);
            } else if (isCancelledPlan) {
                ResourceAbsenceManager.getUsersLeavePlansMap(cancelledPlansMap, newPlan);
            }
        }
        List<ResourceAbsence> absences = getResorceAbsences(changedPlanDetailsMap.keySet());
        ResourceAbsenceManager.updateResourceAbsences(changedPlanDetailsMap, oldPlans.values(), absences);
        absences = getResorceAbsences(cancelledPlansMap.keySet());
        ResourceAbsenceManager.deleteAbsences(oldPlans.values(), absences);
    }

    private static List<ResourceAbsence> getResorceAbsences(Set<Id> userIds) {
        return [
            SELECT Id, Start, End, Type, Resource.RelatedRecordId, Resource.IsActive, Status__c
            FROM ResourceAbsence
            WHERE Resource.RelatedRecordId IN :userIds
            AND Resource.IsActive = TRUE
            WITH SECURITY_ENFORCED
        ];
    }
    
    //Logic for handling the DST errors 
    public static void checkForDates(List<Atlas_Leave_Plan__c> newLeavePlans){
        if (newLeavePlans.isEmpty()) {
            return;
        }
        try{
            for(Atlas_Leave_Plan__c alp : newLeavePlans){
                alp.From_Date__c = Datetime.newInstance(alp.From_Date__c.dateGmt(), alp.From_Date__c.timeGmt());
                alp.To_Date__c = Datetime.newInstance(alp.To_Date__c.dateGmt(), alp.To_Date__c.timeGmt());
            }
        }catch(Exception ex){
            system.debug('Exception ex-->'+ex.getStackTraceString());
        }
    }
}