public with sharing class CaseELTWorkScheduleHelper {
    
    public static List <Id> filteredAfterAtlasLeaveAgent;
    public static List <Id> filteredAfterPublicHolidayAgent;
    public static List <Id> filteredAfterTimeSlotAgent;
    public static Map<Id, Id> advisorWorkSceduleMap = new Map<Id,Id>();
    public static Map<Id, List<TimeSlot>> operatingHrTimeSlotMap = new Map<Id,List<TimeSlot>>();
    public static Map<Id, List<Public_Holiday__c>> operatingHrPublicHolidayMap = new Map<Id,List<Public_Holiday__c>>();
    
    public static List<Id> assigneCasesWorkSchedule(Map<Case,List<Id>> eligibleListMap, DateTime assignedDtTime, Map<Id, Advisor_Availability__c> allAdvisorAvailability){
        List<Id> allEligibleAgents = new List<Id>();
        Map<Id,User> usermap ;
        filteredAfterAtlasLeaveAgent = new List <Id>();
        filteredAfterPublicHolidayAgent = new List <Id>();
        filteredAfterTimeSlotAgent = new List<Id>();
        for(Case caseObj : eligibleListMap.keyset()){
            system.debug('eligibleListMap.get(caseObj)'+ eligibleListMap.get(caseObj));
            allEligibleAgents.addAll(eligibleListMap.get(caseObj));
        }
        
        if( allEligibleAgents != NUll && allEligibleAgents.size() > 0 ){
            filterOnAtlasleavePlan(allEligibleAgents, assignedDtTime);
        }
        
        
        if(null != filteredAfterAtlasLeaveAgent && filteredAfterAtlasLeaveAgent.size()> 0 ){
            usermap = new Map<Id,User>([Select Id, Name from user where ID IN:filteredAfterAtlasLeaveAgent ]);
        }
        
        
        system.debug('filtered after atlas leaveplan');
        for(integer i=0; i< filteredAfterAtlasLeaveAgent.size(); i++ ){
            system.debug('prferred Ad atlas leave plan'+ i+ ': ' +filteredAfterAtlasLeaveAgent[i] + ' Username::: '+ usermap.get(filteredAfterAtlasLeaveAgent[i]).name + ' ::: Dateime:: '+ allAdvisorAvailability.get(filteredAfterAtlasLeaveAgent[i]).Reference_Date_Time__c);
        }
         system.debug('filteredAfterAtlasLeaveAgent'+filteredAfterAtlasLeaveAgent);
        
        getUserWorkScheduleOHMap(filteredAfterAtlasLeaveAgent);
        
        workprofileCheckPublicHoliday(filteredAfterAtlasLeaveAgent, assignedDtTime);
        
        system.debug('filtered after public holiday');
         for(integer i=0; i< filteredAfterPublicHolidayAgent.size(); i++ ){
            system.debug('prferred Ad public holiday'+ i+ ': ' +filteredAfterPublicHolidayAgent[i] + ' Username::: '+ usermap.get(filteredAfterPublicHolidayAgent[i]).name + ' ::: Dateime:: '+ allAdvisorAvailability.get(filteredAfterPublicHolidayAgent[i]).Reference_Date_Time__c);
        }
        system.debug('filteredAfterPublicHolidayAgent'+filteredAfterPublicHolidayAgent);
        
        
        workprofileTimeSlotCheck(filteredAfterPublicHolidayAgent,assignedDtTime );
         system.debug('filtered after TimeSlot');
              for(integer i=0; i< filteredAfterTimeSlotAgent.size(); i++ ){
            system.debug('prferred Ad time slot'+ i+ ': ' +filteredAfterTimeSlotAgent[i] + ' Username::: '+ usermap.get(filteredAfterTimeSlotAgent[i]).name + ' ::: Dateime:: '+ allAdvisorAvailability.get(filteredAfterTimeSlotAgent[i]).Reference_Date_Time__c);
        }
        system.debug('filteredAfterTimeSlotAgent'+filteredAfterTimeSlotAgent);
        return filteredAfterTimeSlotAgent;
        
    }
    
    public static void filterOnAtlasleavePlan(List<Id> allEligibleAgents, DateTime assignedDtTime){
        
        set<Id> usersWithPlannedLeave = new Set<Id>();
        
        for( Atlas_Leave_Plan__c atlasObj : [SELECT Id, User_email__c FROM Atlas_Leave_Plan__c WHERE User_email__c IN:allEligibleAgents AND From_Date__c<=: assignedDtTime AND To_Date__c>= : assignedDtTime  ]){
            usersWithPlannedLeave.add(atlasObj.User_email__c);
        }
        
        for(Id  elAgent : allEligibleAgents){
            if(!usersWithPlannedLeave.contains(elAgent)){
                filteredAfterAtlasLeaveAgent.add(elAgent);
                system.debug('elAgent'+elAgent);
            }
        }
    }
    
    public static void getUserWorkScheduleOHMap(List <Id> filteredAfterAtlasLeaveAgent){
        
        Set<Id> operatingHoursSet = new Set<id>();
        for( Work_Schedule__c wsObj : [ SELECT Id, Advisor__c, Operating_Hours__c FROM Work_Schedule__c WHERE Advisor__c IN:filteredAfterAtlasLeaveAgent ]){
            advisorWorkSceduleMap.put(wsObj.Advisor__c, wsObj.Operating_Hours__c);
            operatingHoursSet.add( wsObj.Operating_Hours__c);
        }
        
        system.debug('advisorWorkSceduleMap'+advisorWorkSceduleMap);
        if(NULL !=  operatingHoursSet && operatingHoursSet.size() > 0 ){
            getWorkDays(operatingHoursSet);
        }
    }
    
    public static void getWorkDays(Set<Id> operatingHoursSet){
        
        for( OperatingHours ooObj : [SELECT Id, (SELECT Id, DayOfWeek,OperatingHoursId, StartTime,EndTime FROM TimeSlots), (SELECT Id,Holiday_Working_Profile__c,Name, Holiday_Date__c FROM  Public_Holidays__r) FROM OperatingHours WHERE Id IN:operatingHoursSet]){
            operatingHrTimeSlotMap.put(ooObj.Id, ooObj.Timeslots);
            operatingHrPublicHolidayMap.put(ooObj.Id, ooObj.Public_Holidays__r);
        }
    }
    
    
    public static void workprofileCheckPublicHoliday(List<Id> filteredAfterAtlasLeaveAgent, DateTime assignedDtTime ){
	
        for( Id agentId : filteredAfterAtlasLeaveAgent){
            if(advisorWorkSceduleMap.containskey(agentId)){
                if( !checkPublicHoliday(advisorWorkSceduleMap.get(agentId), assignedDtTime) ){
                    system.debug('filteredAfterPublicHolidayAgent aad');
                    
                    filteredAfterPublicHolidayAgent.add(agentId);
                    system.debug('filteredAfterPublicHolidayAgent' + filteredAfterPublicHolidayAgent);
                }
            }
        }
        
    }
    
    
    public static Boolean checkPublicHoliday(Id operatingHoursId, DateTime assignedDtTime){
        Date assignedDate = assignedDtTime.date();
        system.debug('inside checkPublicHoliday');
        system.debug('operatingHrPublicHolidayMap.get(operatingHoursId)' + operatingHrPublicHolidayMap.get(operatingHoursId));
        for( Public_Holiday__c holiday : operatingHrPublicHolidayMap.get(operatingHoursId)){
            
            if( assignedDate == holiday.Holiday_Date__c){
                return true;
            }
        }
        
        return false;
    }
    
    public static void workprofileTimeSlotCheck(List<Id> filteredAfterPublicHolidayAgent, DateTime assignedDtTime){
        
        for( Id agentId : filteredAfterPublicHolidayAgent){
            if(advisorWorkSceduleMap.containskey(agentId)){
                if( checkTimeSlot(advisorWorkSceduleMap.get(agentId), assignedDtTime)){
                    filteredAfterTimeSlotAgent.add(agentId);
                }
            }
        }        
    }
    
    public static Boolean checkTimeSlot(Id operatingHoursId, DateTime assignedDtTime){
        String dayofWeek = assignedDtTime.format('EEEE');
        system.debug(dayofWeek);
        for( TimeSlot tmslotObj : operatingHrTimeSlotMap.get(operatingHoursId)){
            system.debug('tmslotObj.DayOfWeek'+tmslotObj.DayOfWeek);
            system.debug('assignedDtTime.time()'+ assignedDtTime.time());
            system.debug('tmslotObj.StartTime'+tmslotObj.StartTime);
            system.debug('tmslotObj.EndTime'+tmslotObj.EndTime);
            if(tmslotObj.DayOfWeek == dayofWeek && assignedDtTime.time() >= tmslotObj.StartTime  && assignedDtTime.time() <= tmslotObj.EndTime){
                return true;
            }
        }
        return false;
    } 
    
    
}