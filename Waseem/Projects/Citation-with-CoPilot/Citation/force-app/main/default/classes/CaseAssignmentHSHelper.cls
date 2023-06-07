public without sharing class CaseAssignmentHSHelper {
    public static List<Case> casestoAssign = new List<Case>();
    public static Map<Case, List<Id>> eligibleListMap = new Map<Case, List<Id>>();
    public static List<Id> workScheduleAgentFiteredList = new List<Id>();
    public static List<case> casesToUpdate = new List<Case>();
    public static DateTime assignedDtTime;
    public static List<Advisor_Availability__c> advisorToUpdate = new List<Advisor_Availability__c>();

    //Get Preferred Advsiros, ELT Advise, H&SAdvice(Geenral Queue Advisor Availablity Data)
    //public static  Map<Id, Advisor_Availability__c> getAdvisoryAvailabilityData(Set<Id> preferredAdvisorUserSet, Set<Id> generalQueueAdvisorSet ){
    public static Map<Id, Advisor_Availability__c> getAdvisoryAvailabilityData(
        Set<Id> generalQueueAdvisorSet
    ) {
        Map<Id, Advisor_Availability__c> advisorAAMap = new Map<Id, Advisor_Availability__c>();
        //  for( Advisor_Availability__c aaObj : [Select Id,Advisor__c, Availability__c, Last_Case_Assigned1__c,Reference_Date_Time__c FROM Advisor_Availability__c WHERE (Advisor__c IN:preferredAdvisorUserSet OR Advisor__c IN :generalQueueAdvisorSet) AND Availability__c='Available' ORDER BY Reference_Date_Time__c ASC  ]){
        //  AdvisorAAMap.put( aaObj.Advisor__c, aaObj );

        for (Advisor_Availability__c aaObj : [
            SELECT
                Id,
                Advisor__c,
                Availability__c,
                Last_Case_Assigned1__c,
                Reference_Date_Time__c
            FROM Advisor_Availability__c
            WHERE
                Advisor__c IN :generalQueueAdvisorSet AND Advisor__r.IsActive = True
                AND Availability__c = 'Available'
            ORDER BY Reference_Date_Time__c ASC
        ]) {
            AdvisorAAMap.put(aaObj.Advisor__c, aaObj);
        }

        return advisorAAMap;
    }

    public static void aaAssignmentLogic(
        CaseAssignmentHSQueuebaleFunction.AAassignmentWrapper aaWrap
    ) {
        Map<Id, Case> filteredCases = aaWrap.filteredCases;
        DateTime assignedDateTime = aaWrap.assignedDateTime;
        Map<Id, Set<Id>> preferredAdvisorAccountMap = aaWrap.preferredAdvisorAccountMap;
        Map<Id, Advisor_Availability__c> allAdvisorAvailability = aaWrap.allAdvisorAvailability;
        assignedDtTime = aaWrap.assignedDateTime;

        Map<Id, Id> caseAdvisorMap = new Map<id, Id>();

        for (Case caseObj : filteredCases.values()) {
            Set<Id> preferredAdvisorSet = preferredAdvisorAccountMap
                    ?.get(caseObj.AccountId) != null
                ? preferredAdvisorAccountMap?.get(caseObj.AccountId)
                : null; //GET PREFFERED ADVISOR LIST
            if (preferredAdvisorSet == null) {
                assignmentForNonPreferredAdvisors(
                    caseObj,
                    allAdvisorAvailability
                ); //USE GENERAL QUEUE AGENTS FOR ASSIGNMENT
            } else {
                assignmentForPreferredAdvisors(
                    caseObj,
                    allAdvisorAvailability,
                    preferredAdvisorSet
                ); //USE PREFERRED ADVISORS FOR ASSIGNMENT
            }
        }
        updateCasesOwnership(eligibleListMap, allAdvisorAvailability);
    }

    //No PreferredAgents , fetch general queue agents
    public static void assignmentForNonPreferredAdvisors(
        Case caseObj,
        Map<Id, Advisor_Availability__c> allAdvisorAvailability
    ) {
        List<Advisor_Availability__c> allAgents = new List<Advisor_Availability__c>();
        List<Id> eligibleAgents = new List<Id>();
        List<AdvisorAvailabilityWrapper> allAgentsWrapper = new List<AdvisorAvailabilityWrapper>();

        //WRAPPER TO SORT ALL AGENTS BASED ON LONGEST DURATION
        for (Id aaId : allAdvisorAvailability.keyset()) {
            allAgentsWrapper.add(
                new AdvisorAvailabilityWrapper(
                    allAdvisorAvailability.get(aaId).Advisor__c,
                    allAdvisorAvailability.get(aaId).Reference_Date_Time__c
                )
            );
        }

        if (allAgentsWrapper.isEmpty() || allAgentsWrapper.size() == 0) {
            return;
        }

        //SORTING LOGIC USING COMPARABLE INTERFACE- AdvisorAvailabilityWrapper
        allAgentsWrapper.sort();

        for (AdvisorAvailabilityWrapper aaObj : allAgentsWrapper) {
            //ASSIGN ELIGIBLE CANDIDATES BASED ON LONGEST DURATION
            eligibleAgents.add(aaObj.advisorId);
        }

        eligibleListMap.put(caseObj, eligibleAgents); //POPULATE MAP OF CASE WITH ELIGIBLE CANDIDATES
    }

    public static void assignmentForPreferredAdvisors(
        Case caseObj,
        Map<Id, Advisor_Availability__c> allAdvisorAvailability,
        Set<Id> preferredAdvisorSet
    ) {
        Boolean firstTimeRunCompleted = true;
        List<Id> sortedAgents;
        List<Advisor_Availability__c> allAgents = new List<Advisor_Availability__c>();
        List<Id> eligibleAgents = new List<Id>();
        List<AdvisorAvailabilityWrapper> allPreferredAgentsWrapper = new List<AdvisorAvailabilityWrapper>();
        List<AdvisorAvailabilityWrapper> allNonPreferredAgentsWrapper = new List<AdvisorAvailabilityWrapper>();

        for (Id preferredId : preferredAdvisorSet) {
            if (allAdvisorAvailability.containsKey(preferredId)) {
                allPreferredAgentsWrapper.add(
                    new AdvisorAvailabilityWrapper(
                        allAdvisorAvailability.get(preferredId).Advisor__c,
                        allAdvisorAvailability.get(preferredId)
                            .Reference_Date_Time__c
                    )
                ); //GENERATE PREFFERED AGENT WRAPPER
            }
        }

        //SORTING LOGIC USING COMPARABLE INTERFACE- AdvisorAvailabilityWrapper
        allPreferredAgentsWrapper.sort();

        for (AdvisorAvailabilityWrapper aaObj : allPreferredAgentsWrapper) {
            eligibleAgents.add(aaObj.advisorId);
        }

        //WRAPPER TO SORT ALL NON PREFEERED AGENTS BASED ON LONGEST DURATION
        for (Id aaId : allAdvisorAvailability.keyset()) {
            if (!preferredAdvisorSet.contains(aaId)) {
                allNonPreferredAgentsWrapper.add(
                    new AdvisorAvailabilityWrapper(
                        allAdvisorAvailability.get(aaId).Advisor__c,
                        allAdvisorAvailability.get(aaId).Reference_Date_Time__c
                    )
                );
            }
        }

        allNonPreferredAgentsWrapper.sort();

        for (AdvisorAvailabilityWrapper aaObj : allNonPreferredAgentsWrapper) {
            eligibleAgents.add(aaObj.advisorId);
        }

        eligibleListMap.put(caseObj, eligibleAgents);
    }

    public static void updateCasesOwnership(
        Map<Case, List<Id>> eligibleListMap,
        Map<Id, Advisor_Availability__c> allAdvisorAvailability
    ) {
        //NOPMD
        List<Id> agntId = new List<id>();
        Map<Id, User> usermap;
        Date dt = System.today(); //current date
        Integer day = dt.Day(); //get day
        Integer month = dt.Month(); //get month
        Integer year = dt.Year(); //get year
        Integer index = 0;
        DateTime cutOffTime = DateTime.newInstance(year, month, day, 16, 30, 0);

        for (case caseObj : eligibleListMap.keyset()) {
            agntId = eligibleListMap.get(caseObj);
        }

        if (null != agntId && agntId.size() > 0) {
            usermap = new Map<Id, User>(
                [SELECT Id, Name FROM user WHERE ID IN :agntId]
            );
        }

        /*     for(integer i=0; i< agntId.size(); i++ ){
            system.debug('prferred Ad '+ i+ ': ' +agntId[i] + ' Username::: '+ usermap.get(agntId[i]).name + ' ::: Dateime:: '+ allAdvisorAvailability.get(agntId[i]).Reference_Date_Time__c);
        }
        system.debug('assignedDtTime'+assignedDtTime);*/
        if (assignedDtTime <= cutOffTime) {
            workScheduleAgentFiteredList = CaseELTWorkScheduleHelper.assigneCasesWorkSchedule(
                eligibleListMap,
                assignedDtTime,
                allAdvisorAvailability
            );
        }

        /*  system.debug('before 4:30pm');
          for(integer i=0; i< workScheduleAgentFiteredList.size(); i++ ){
            system.debug('prferred Ad '+ i+ ': ' +workScheduleAgentFiteredList[i] + ' Username::: '+ usermap.get(workScheduleAgentFiteredList[i]).name + ' ::: Dateime:: '+ allAdvisorAvailability.get(workScheduleAgentFiteredList[i]).Reference_Date_Time__c);
        }*/

        if (
            null == workScheduleAgentFiteredList ||
            workScheduleAgentFiteredList.size() == 0 ||
            (assignedDtTime >= cutOffTime)
        ) {
            BusinessHoursCalculator bObj = new BusinessHoursCalculator();
            Date nextDay = bObj.nextBusinessDay(assignedDtTime.addDays(1));
            DateTime nextDayDateTime = dateTime.newInstance(
                nextDay.year(),
                nextDay.month(),
                nextDay.day(),
                10,
                0,
                0
            );
            system.debug('nextDayDateTime' + nextDayDateTime);
            workScheduleAgentFiteredList = CaseELTWorkScheduleHelper.assigneCasesWorkSchedule(
                eligibleListMap,
                nextDayDateTime,
                allAdvisorAvailability
            );
        }

        /*  system.debug('after 4:30pm');
          for(integer i=0; i< workScheduleAgentFiteredList.size(); i++ ){
            system.debug('prferred Ad '+ i+ ': ' +workScheduleAgentFiteredList[i] + ' Username::: '+ usermap.get(workScheduleAgentFiteredList[i]).name + ' ::: Dateime:: '+ allAdvisorAvailability.get(workScheduleAgentFiteredList[i]).Reference_Date_Time__c);
        }*/

        if (
            null != workScheduleAgentFiteredList &&
            workScheduleAgentFiteredList.size() > 0
        ) {
            for (case caseObj : eligibleListMap.keyset()) {
                caseObj.OwnerId = workScheduleAgentFiteredList[index];
                caseObj.Reception_Transfer_To__c = 'H&S';
                casesToUpdate.add(caseObj);
                advisorToUpdate.add(
                    new Advisor_Availability__c(
                        Id = allAdvisorAvailability.get(
                                workScheduleAgentFiteredList[index]
                            )
                            .Id,
                        Advisor__c = workScheduleAgentFiteredList[index],
                        Reference_Date_Time__c = System.now()
                    )
                );
            }
        }

        if (null != casesToUpdate && casesToUpdate.size() > 0) {
            udpateCases(casesToUpdate);
            performCaseSharing(casesToUpdate);
        }

        if (null != advisorToUpdate && advisorToUpdate.size() > 0) {
            updateAdvisors(advisorToUpdate);
        }
    }

    public static void udpateCases(List<Case> casesToUpdate) {
        try {
            CaseTransfer_Util.isAlreadyRan = true;
            update casesToUpdate;
        } catch (Exception error) {
            system.debug(error.getMessage());
        }
    }

    public static void updateAdvisors(
        List<Advisor_Availability__c> advisorToUpdate
    ) {
        try {
            update advisorToUpdate;
        } catch (Exception error) {
            system.debug(error.getMessage());
        }
    }

    public static void performCaseSharing(List<Case> caseList) {
        if (caseList.isEmpty() || caseList.size() == 0) {
            return;
        }

        List<CaseShare> caseshrList = new List<CaseShare>();

        for (Group grp : [
            SELECT Id, Name, RelatedId, Type
            FROM Group
            WHERE
                RelatedId IN (
                    SELECT Id
                    FROM userRole
                    WHERE
                        DeveloperName IN (
                            'H_S_Advice_Team_Manager',
                            'Head_of_H_S',
                            'H_S_Advisor',
                            'H_S_Consultant',
                            'H_S_Coordinator',
                            'H_S_Regional_Manager',
                            'H_S_Field_Consultant',
                            'H_S_Field_Team_Leader',
                            'H_S_Quality_Manager',
                            'H_S_Team_Leader_Senior_Consultant'
                        )
                )
        ]) {
            for (Case caseObj : caseList) {
                caseshrList.add(
                    new CaseShare(
                        CaseId = caseObj.Id,
                        UserOrGroupId = grp.Id,
                        RowCause = 'Manual',
                        CaseAccessLevel = 'Edit'
                    )
                );
            }
        }

        insert caseshrList; //NOPMD
    }
}