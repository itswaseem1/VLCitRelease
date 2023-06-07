public with sharing class ServiceResourceTriggerHandler {
    public static final String PLANNED_ABSENCE_TYPE = 'Planned Leave';
    public static final String UNPLANNED_ABSENCE_TYPE = 'Un-Planned Leave';
    public static final String CANCELLED_PLAN_STATUS = 'Cancelled';
    // check future leave plans for new service resource
    public static void checkFutureLeavePlans(List<ServiceResource> newResources) {
        Map<Id, ServiceResource> usersResourceMap = new Map<Id, ServiceResource>();
        for (ServiceResource resource : newResources) {
            if (resource.RelatedRecordId != null && resource.IsActive) {
                usersResourceMap.put(resource.RelatedRecordId, resource);
            }
        }
        if (!usersResourceMap.keySet().isEmpty()) {
            Map<Id, Map<Id, Atlas_Leave_Plan__c>> usersLeavePlansMap = new Map<Id, Map<Id, Atlas_Leave_Plan__c>>();
            for (Atlas_Leave_Plan__c leavePlan : getLeavePlansMap(usersResourceMap.keySet()).values()) {
                if (leavePlan.Status__c != CANCELLED_PLAN_STATUS) {
                    ResourceAbsenceManager.getUsersLeavePlansMap(usersLeavePlansMap, leavePlan);
                }
            }
            ResourceAbsenceManager.createNewResourceAbsences(usersResourceMap.values(), usersLeavePlansMap);
        }
    }
    // check future leave plans for updated service resource
    public static void checkFutureLeavePlans(Map<Id, ServiceResource> oldResources, Map<Id, ServiceResource> newResources) {
        Map<Id, ServiceResource> usersResourceMap = new Map<Id, ServiceResource>();
        for (ServiceResource resource : newResources.values()) {
            Boolean isNeedToCheck =
                resource.RelatedRecordId != null &&
                resource.IsActive == TRUE &&
                oldResources.get(resource.Id).IsActive == FALSE;
            if (isNeedToCheck) {
                usersResourceMap.put(resource.RelatedRecordId, resource);
            }
        }
        if (!usersResourceMap.keySet().isEmpty()) {
            Map<Id, Atlas_Leave_Plan__c> leavePlansMap = getLeavePlansMap(usersResourceMap.keySet());
            excludeCreatedResourceAbsences(usersResourceMap.keySet(), leavePlansMap);
            Map<Id, Map<Id, Atlas_Leave_Plan__c>> usersLeavePlansMap = new Map<Id, Map<Id, Atlas_Leave_Plan__c>>();
            for (Atlas_Leave_Plan__c leavePlan : leavePlansMap.values()) {
                if (leavePlan.Status__c != CANCELLED_PLAN_STATUS) {
                    ResourceAbsenceManager.getUsersLeavePlansMap(usersLeavePlansMap, leavePlan);
                }
            }
            ResourceAbsenceManager.createNewResourceAbsences(usersResourceMap.values(), usersLeavePlansMap);
        }
    }
    
    private static void excludeCreatedResourceAbsences(Set<Id> usersIds, Map<Id, Atlas_Leave_Plan__c> leavePlansMap) {
        List<Id> planIdsToExclude = new List<Id>();
        List<ResourceAbsence> absences = [
            SELECT Id, Start, End
            FROM ResourceAbsence
            WHERE Resource.RelatedRecordId IN :usersIds
            WITH SECURITY_ENFORCED
        ];
        for (ResourceAbsence absence : absences) {
            for (Atlas_Leave_Plan__c plan : leavePlansMap.values()) {
                Boolean identicalRecords = 
                    absence.Start == plan.From_Date__c &&
                    absence.End == plan.To_Date__c;
                if (identicalRecords) {
                    planIdsToExclude.add(plan.Id);
                }
            }
        }
        leavePlansMap.keySet().removeAll(planIdsToExclude);
    }
    
    private static Map<Id, Atlas_Leave_Plan__c> getLeavePlansMap(Set<Id> usersIds) {
        return new Map<Id, Atlas_Leave_Plan__c>([
            SELECT Id, From_Date__c, To_Date__c, User_email__c, Status__c
            FROM Atlas_Leave_Plan__c
            WHERE User_email__c IN :usersIds
            AND From_Date__c != NULL
            AND To_Date__c != NULL
            AND Status__c != :CANCELLED_PLAN_STATUS
            WITH SECURITY_ENFORCED
        ]);
    }
    
    public static void createNewAbsenceRecs(List<ServiceResource> serRes){
        Set<Id> advisorIds = new Set<Id>();
        for(ServiceResource res : serRes){
            if(res.RelatedRecordId != null && res.IsActive){
                advisorIds.add(res.RelatedRecordId);
            }
        }
        if(advisorIds.size()>0){
            createAbsences(advisorIds);
        }
    }
    public static void updateAbsenceRecs(Map<Id, ServiceResource> oldResources, Map<Id, ServiceResource> newResources){
        Set<Id> delExistingRes = new Set<Id>();
        Set<Id> createAbsRecs = new Set<Id>();
        for(ServiceResource res : newResources.values()){
            if(oldResources.get(res.Id).IsActive == true && res.IsActive == false){
                delExistingRes.add(res.RelatedRecordId);
            }
            else if(oldResources.get(res.Id).IsActive == false && res.IsActive == true){
                createAbsRecs.add(res.RelatedRecordId);
            }else if(oldResources.get(res.Id).IsActive == true && res.IsActive == true && oldResources.get(res.Id).RelatedRecordId != res.RelatedRecordId){
                delExistingRes.add(oldResources.get(res.Id).RelatedRecordId);
                createAbsRecs.add(res.RelatedRecordId);
            }
        }
        if(delExistingRes.size()>0){
            WorkScheduleHandler.deleteExistingPublicHolidays(delExistingRes);
        }
        if(createAbsRecs.size()>0){
           createAbsences(createAbsRecs);
        }
    }
    public static void createAbsences(Set<Id> advisorIds){
         Map<Id,Work_Schedule__c> wrkSch = new Map<Id,Work_Schedule__c>([Select Id,Operating_Hours__c,Advisor__c from Work_Schedule__c where Advisor__c IN: advisorIds]);
            if(wrkSch != null && !wrkSch.isEmpty()){
                Map<Id,Id> advisors = WorkScheduleHandler.getAdvisorsMap(wrkSch);
                WorkScheduleHandler.createNewAbsenceRecs(advisors);
            }
    }
}