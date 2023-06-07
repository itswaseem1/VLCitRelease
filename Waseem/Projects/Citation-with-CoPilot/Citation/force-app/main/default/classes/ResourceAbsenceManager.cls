public with sharing class ResourceAbsenceManager {
    public static final String PLANNED_ABSENCE_TYPE = 'Planned Leave';
    public static final String UNPLANNED_ABSENCE_TYPE = 'Un-Planned Leave';
    public static final String CANCELLED_PLAN_STATUS = 'Cancelled';
    public static final Id ABSENCE_NON_AVAILABILITY_RECORDTYPE_ID = 
        Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();

    public static void getUsersLeavePlansMap(Map<Id, Map<Id, Atlas_Leave_Plan__c>> usersLeavePlansMap, Atlas_Leave_Plan__c leavePlan) {
        if (usersLeavePlansMap.containsKey(leavePlan.User_email__c)) {
            usersLeavePlansMap.get(leavePlan.User_email__c).put(leavePlan.Id, leavePlan);
        } else {
            usersLeavePlansMap.put(leavePlan.User_email__c, new Map<Id, Atlas_Leave_Plan__c>{ leavePlan.Id => leavePlan });
        }
    }

    public static void createNewResourceAbsences(List<ServiceResource> serviceResources, Map<Id, Map<Id, Atlas_Leave_Plan__c>> usersLeavePlansMap) {
        List<ResourceAbsence> newResourceAbsences = new List<ResourceAbsence>();
        for (ServiceResource serviceResource : serviceResources) {
            if (usersLeavePlansMap.get(serviceResource.RelatedRecordId) == null) {
                continue;
            }
            for (Atlas_Leave_Plan__c leavePlan : usersLeavePlansMap.get(serviceResource.RelatedRecordId).values()) {
                Boolean isHasTime =
                    leavePlan.From_Date__c != null &&
                    leavePlan.To_Date__c != null &&
                    leavePlan.To_Date__c > System.now();
                if (isHasTime) {
                    newResourceAbsences.add(createAbsence(serviceResource, leavePlan));
                }
            }
        }
        if (!newResourceAbsences.isEmpty() && ResourceAbsence.sObjectType.getDescribe().isCreateable()) {
            insert newResourceAbsences;
        }
    }

    private static ResourceAbsence createAbsence(ServiceResource serviceResource, Atlas_Leave_Plan__c leavePlan) {
        return new ResourceAbsence(
            Start = leavePlan.From_Date__c,
            End = leavePlan.To_Date__c,
            ResourceId = serviceResource.Id,
            Status__c = leavePlan.Status__c,
            FSL__Approved__c = true,
            Type = 
                (System.now().addDays(7) <= leavePlan.From_Date__c) ?
                PLANNED_ABSENCE_TYPE :
                UNPLANNED_ABSENCE_TYPE,
            RecordTypeId = ABSENCE_NON_AVAILABILITY_RECORDTYPE_ID
        );
    }

    public static void updateResourceAbsences(Map<Id, Map<Id, Atlas_Leave_Plan__c>> changedPlanDetailsMap, List<Atlas_Leave_Plan__c> oldPlans, List<ResourceAbsence> absences) {
        List<ResourceAbsence> resAbsToUpdate = new List<ResourceAbsence>();
        for (ResourceAbsence absence : absences) {
            for (Atlas_Leave_Plan__c oldPlan : oldPlans) {
            Boolean areRecordsIdentical = 
                absence.Start.date() == oldPlan.From_Date__c.date() &&
                absence.End.date() == oldPlan.To_Date__c.date() &&
                absence.Status__c == oldPlan.Status__c &&
                absence.Resource.RelatedRecordId == oldPlan.User_email__c;
                if (areRecordsIdentical) {
                    absence.Start = changedPlanDetailsMap.get(absence.Resource.RelatedRecordId).get(oldPlan.Id).From_Date__c;
                    absence.End = changedPlanDetailsMap.get(absence.Resource.RelatedRecordId).get(oldPlan.Id).To_Date__c;
                    absence.Status__c = changedPlanDetailsMap.get(absence.Resource.RelatedRecordId).get(oldPlan.Id).Status__c;
                    absence.FSL__Approved__c = true;
                    absence.Type = 
                        (System.now().addDays(7) <= absence.Start) ?
                        PLANNED_ABSENCE_TYPE :
                        UNPLANNED_ABSENCE_TYPE;
                    absence.RecordTypeId = ABSENCE_NON_AVAILABILITY_RECORDTYPE_ID;
                    resAbsToUpdate.add(absence);
                }
            }
        }
        if (!resAbsToUpdate.isEmpty() && ResourceAbsence.sObjectType.getDescribe().isUpdateable()) {
            update resAbsToUpdate;
        }
    }

    public static void deleteAbsences(List<Atlas_Leave_Plan__c> oldPlans, List<ResourceAbsence> absences) {
        List<ResourceAbsence> absencesForDelete = new List<ResourceAbsence>();
        for (ResourceAbsence absence : absences) {
            for (Atlas_Leave_Plan__c oldPlan : oldPlans) {
                Boolean areRecordsIdentical = 
                    absence.Start.date() == oldPlan.From_Date__c.date() &&
                    absence.End.date() == oldPlan.To_Date__c.date() &&
                    absence.Status__c == oldPlan.Status__c &&
                    absence.Resource.RelatedRecordId == oldPlan.User_email__c;
                if (areRecordsIdentical) {
                    absencesForDelete.add(absence);
                }
            }
        }
        if (!absencesForDelete.isEmpty() && ResourceAbsence.sObjectType.getDescribe().isDeletable()) {
            delete absencesForDelete;
        }
    }
}