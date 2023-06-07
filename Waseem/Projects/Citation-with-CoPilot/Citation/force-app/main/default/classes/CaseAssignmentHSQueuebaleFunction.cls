public with sharing class CaseAssignmentHSQueuebaleFunction implements Queueable {
    public static Map<Id, Set<Id>> preferredAdvisorAccountMap = new Map<Id, Set<Id>>();
    public static Map<Id, Set<Id>> filteredPreferredAdvisorsAA = new Map<Id, Set<Id>>();
    public static Set<Id> generalQueueAdvisorSet = new Set<Id>();
    // public static Set<Id> preferredAdvisorUserSet = new Set<id>();
    public static Map<Id, Advisor_Availability__c> allAdvisorAvailability = new Map<Id, Advisor_Availability__c>();

    public Map<Id, Case> filteredCases;
    public Map<Id, Id> caseAccountMap;
    public DateTime assignedDateTime;

    public CaseAssignmentHSQueuebaleFunction(
        Map<Id, Case> filteredCases,
        Map<Id, Id> caseAccountMap,
        DateTime assignedDateTime
    ) {
        //CONSTRUCTOR
        this.filteredCases = filteredCases;
        this.caseAccountMap = caseAccountMap;
        this.assignedDateTime = assignedDateTime;
    }

    public void execute(QueueableContext context) {
        transferCases(filteredCases, caseAccountMap, assignedDateTime); //MAIN METHOD TO TRANSFER CASES
    }

    public static void transferCases(
        Map<Id, Case> filteredCases,
        Map<Id, Id> caseAccountMap,
        DateTime assignedDateTime
    ) {
        //   getPreferredAdvisorList(caseAccountMap); //GET PREFERRED ADVISORS IN ACCOUNT PREFEERED ADVISOR MAP - Commented as No Preferred ADvsior in H&S
        getGeneralQueueAdvisorList(); //GET GENERAL QUEUE ADVISOR SET

        //allAdvisorAvailability = CaseAssignmentHSHelper.getAdvisoryAvailabilityData(preferredAdvisorUserSet, generalQueueAdvisorSet );// CHECK WHICH ADVISORS HAVE AVAILABILTY='AVAILABLE IN ADVISOR AVAILABILTY OBJECT
        allAdvisorAvailability = CaseAssignmentHSHelper.getAdvisoryAvailabilityData(
            generalQueueAdvisorSet
        ); // CHECK WHICH ADVISORS HAVE AVAILABILTY='AVAILABLE IN ADVISOR AVAILABILTY OBJECT
        getEligibleAdvisors(filteredCases, assignedDateTime); //GENERATE THE NECESSARY CASE - LIST OF ADVISOR ( PREFEERED/NON PREFEERED0 SORTED IN ASCENDING ORDER NOTE: REFERENCE DATE TIME IS 2000-0101 00:00:00 )
    }

    public static void getGeneralQueueAdvisorList() {
        Set<Id> queuIdSet = new Set<Id>();

        for (Group queueObj : [
            SELECT Id
            FROM Group
            WHERE type = 'Queue' AND Name IN ('H&S Advice')
        ]) {
            queuIdSet.add(queueObj.Id);
        }

        for (GroupMember gmObj : [
            SELECT UserOrGroupId
            FROM GroupMember
            WHERE GroupId = :queuIdSet
        ]) {
            generalQueueAdvisorSet.add(gmObj.UserOrGroupId);
        }
    }

    public static void getEligibleAdvisors(
        Map<Id, Case> filteredCases,
        DateTime assignedDateTime
    ) {
        AAassignmentWrapper aaWrap = new AAassignmentWrapper();
        aaWrap.filteredCases = filteredCases;
        aaWrap.preferredAdvisorAccountMap = preferredAdvisorAccountMap;
        aaWrap.assignedDateTime = assignedDateTime;
        aaWrap.allAdvisorAvailability = allAdvisorAvailability;

        CaseAssignmentHSHelper.aaAssignmentLogic(aaWrap);
    }

    public class AAassignmentWrapper {
        public Map<Id, Case> filteredCases;
        public DateTime assignedDateTime;
        public Map<Id, Set<Id>> preferredAdvisorAccountMap;
        public Map<Id, Advisor_Availability__c> allAdvisorAvailability;

        public AAassignmentWrapper() {
            filteredCases = new Map<Id, Case>();
            preferredAdvisorAccountMap = new Map<Id, Set<Id>>();
            allAdvisorAvailability = new Map<Id, Advisor_Availability__c>();
        }
    }
}