public with sharing class CaseAssignmentELTQueuebaleFunction implements Queueable  {//

public static Map<Id, Set<Id> > preferredAdvisorAccountMap = new Map<Id, Set<Id> >();
public static Map<Id,Set<Id> > filteredPreferredAdvisorsAA = new Map<Id, Set<Id> >();
public static Set<Id> generalQueueAdvisorSet = new Set<Id>();
public static Set<Id> preferredAdvisorUserSet = new Set<id>();
public static Map<Id, Advisor_Availability__c> allAdvisorAvailability = new Map<Id, Advisor_Availability__c>();

public Map<Id, Case> filteredCases;
public Map<Id, Id> caseAccountMap;
public DateTime assignedDateTime;

public CaseAssignmentELTQueuebaleFunction(Map<Id, Case> filteredCases, Map<Id, Id> caseAccountMap, DateTime assignedDateTime){    //CONSTRUCTOR
	this.filteredCases = filteredCases;
	this.caseAccountMap = caseAccountMap;
	this.assignedDateTime = assignedDateTime;
}

public void execute(QueueableContext context) {
	transferCases(filteredCases, caseAccountMap, assignedDateTime); //MAIN METHOD TO TRANSFER CASES
}




public static void transferCases(Map<Id, Case> filteredCases, Map<Id, Id> caseAccountMap, DateTime assignedDateTime){

	getGeneralQueueAdvisorList(); //GET GENERAL QUEUE ADVISOR SET
	getPreferredAdvisorList(caseAccountMap); //GET PREFERRED ADVISORS IN ACCOUNT PREFEERED ADVISOR MAP


	allAdvisorAvailability = CaseAssignmentELTHelper.getAdvisoryAvailabilityData(preferredAdvisorUserSet, generalQueueAdvisorSet );// CHECK WHICH ADVISORS HAVE AVAILABILTY='AVAILABLE IN ADVISOR AVAILABILTY OBJECT

	getEligibleAdvisors(filteredCases, assignedDateTime);//GENERATE THE NECESSARY CASE - LIST OF ADVISOR ( PREFEERED/NON PREFEERED0 SORTED IN ASCENDING ORDER NOTE: REFERENCE DATE TIME IS 2000-0101 00:00:00 )
}


public static void getPreferredAdvisorList(Map<Id, Id> filteredCases){

	for(Account accObj : [SELECT Id, (SELECT Id,UserId,AccountId FROM AccountTeamMembers WHERE TeamMemberRole ='Preferred ELT Advisor') FROM Account WHERE Id IN:filteredCases.values()]) {
		populateAdvisorMap(accObj);
	}
}

public static void populateAdvisorMap(Account accObj){

	for( AccountTeamMember accMemObj : accObj.AccountTeamMembers ) {
		if(generalQueueAdvisorSet.contains(accMemObj.UserId)) {
			if(!preferredAdvisorAccountMap.containsKey(accObj.Id)) {
				preferredAdvisorAccountMap.put(accObj.Id, new set<Id> {accMemObj.UserId});
			}else{
				preferredAdvisorAccountMap.get(accObj.Id).add(accMemObj.UserId);
			}
			preferredAdvisorUserSet.add(accMemObj.UserId);
		}
	}
}

public static void getGeneralQueueAdvisorList(){
	Set<Id> queuIdSet = new Set<Id>();

	for( Group queueObj :  [Select Id from Group where type='Queue' and Name IN ('ELT Advice')]) {
		queuIdSet.add(queueObj.Id);
	}

	for(GroupMember gmObj : [Select UserOrGroupId From GroupMember where GroupId =:queuIdSet]) {
		generalQueueAdvisorSet.add(gmObj.UserOrGroupId);
	}
}

public static void getEligibleAdvisors(Map<Id, Case> filteredCases, DateTime assignedDateTime){


	/* 	BusinessHoursCalculator bhcObj = new BusinessHoursCalculator();
	   Boolean isWorkingDay = bhcObj.isBusinessDay(assignedDateTime.date());

	   Date dt = System.today(); //current date
	   Integer day = dt.Day(); //get day
	   Integer month = dt.Month(); //get month
	   Integer year = dt.Year(); //get year

	   DateTime cutOffTime = DateTime.newInstance(year, month, day, 16, 30, 00);*/
	AAassignmentWrapper aaWrap = new AAassignmentWrapper();
	// if(  assignedDateTime <= cutOffTime){//IF CASES ASSIGNED TO QUEUE BEFORE 16:30 UK TIME
	aaWrap.filteredCases = filteredCases;
	aaWrap.preferredAdvisorAccountMap = preferredAdvisorAccountMap;
	aaWrap.assignedDateTime = assignedDateTime;
	aaWrap.allAdvisorAvailability = allAdvisorAvailability;

	CaseAssignmentELTHelper.aaAssignmentLogic(aaWrap);
	/*  }else{
	      aaWrap.filteredCases = filteredCases;
	      aaWrap.preferredAdvisorAccountMap = preferredAdvisorAccountMap;
	      aaWrap.assignedDateTime = bhcObj.nextBusinessDay(assignedDateTime);
	      aaWrap.allAdvisorAvailability = allAdvisorAvailability;
	      CaseAssignmentELTHelper.aaAssignmentLogic(aaWrap);
	   }*/
}

public class AAassignmentWrapper {

public Map<Id, Case> filteredCases;
public DateTime assignedDateTime;
public Map<Id,Set<Id> > preferredAdvisorAccountMap;
public Map<Id, Advisor_Availability__c> allAdvisorAvailability;

public AAassignmentWrapper(){
	filteredCases = new Map<Id, Case>();
	preferredAdvisorAccountMap = new Map<Id,Set<Id> >();
	allAdvisorAvailability = new Map <Id, Advisor_Availability__c>();
}
}

}