/**
 * @File Name          : PublicHolidayTriggerHandler.cls
 * @Description        : Updates the Resource Absence records of Service Resources based on Public Holidays 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class PublicHolidayTriggerHandler {
    //Deletes the existing Resource Absences associated to Service Resource when a Public Holiday is deleted
    public static void deleteExistingResAbsences(List<Public_Holiday__c> delHolidays){
        try{
            ServiceResourceHelper.DateWrap dw = ServiceResourceHelper.fetchDateMap(delHolidays);
            Map<Id,Set<Date>> phMap = dw.phDateMap;
            Set<Date> publicHolidayDates = dw.publicHolidayDates;
            if(!phMap.isEmpty()){
                Map<Id, OperatingHours> mp = new Map<ID, OperatingHours>([Select Id,Name,(Select Advisor__c from Work_Schedules__r) from OperatingHours where Id IN: phMap.keySet()]);
                PublicHolidayDateWrap pw = PublicHolidayHelper.getPubHolidayMap(mp.values(),phMap);
                if(pw.advisorIds.size()>0){
                    ServiceResourceHelper.delResAbsences(pw,publicHolidayDates);
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }
    
    //Updates existing Resource Absence Records based on the updates made to the Public Holiday
    public static void updateExistingResAbsences(Map<Id,Public_Holiday__c> oldMap,Map<Id,Public_Holiday__c> newMap){
        try{
            ServiceResourceHelper.DateWrap dw = ServiceResourceHelper.fetchPHMap(oldMap,newMap);
            Map<Id,List<Public_Holiday__c>> phMap = dw.holidayMap;
            Set<Date> publicHolidayDates = dw.publicHolidayDates;
            
            if(!phMap.isEmpty()){
                Map<Id, OperatingHours> mp = new Map<ID, OperatingHours>([Select Id,Name,(Select Advisor__c from Work_Schedules__r) from OperatingHours where Id IN: phMap.keySet()]);
                PublicHolidayWrap pw = getPubHolidayMapping(mp.values(),phMap);
                if(pw.advisorIds.size()>0){
                    updateResAbsences(pw,publicHolidayDates,oldMap);
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }

    public static PublicHolidayWrap getPubHolidayMapping(List<OperatingHours> mp,Map<Id,List<Public_Holiday__c>> phMap){
        Map<Id,List<Public_Holiday__c>> userDatesMap = new Map<Id,List<Public_Holiday__c>>();
        PublicHolidayWrap phwp = getWrkSchMapping(mp);
        if(!phwp.userMap.isEmpty()){
            userDatesMap = PublicHolidayHelper.getUserDatesMap(phwp.userMap,phMap);
        }
        return new PublicHolidayWrap(phwp.userMap,phwp.advisorIds,userDatesMap);
    }

    public static PublicHolidayWrap getWrkSchMapping(List<OperatingHours> mp){
        Map<Id,Set<Id>> userMap = new Map<Id,Set<Id>>();
        Set<Id> advisorIds = new Set<Id>();
        for(OperatingHours opHrs : mp){
            if(opHrs.Work_Schedules__r != null){
                for(Work_Schedule__c wrkSch : opHrs.Work_Schedules__r){
                    advisorIds.add(wrkSch.Advisor__c);
                    if(userMap.containsKey(opHrs.Id)){
                        userMap.get(opHrs.Id).add(wrkSch.Advisor__c);
                    }else{
                        userMap.put(opHrs.Id,new Set<Id>{wrkSch.Advisor__c});
                    }
                }
            }
        }
        return new PublicHolidayWrap(userMap,advisorIds,null);
    }

    //Updates the list of Resource Absence records
    public static void updateResAbsences(PublicHolidayWrap pw,Set<Date> publicHolidayDates,Map<Id,Public_Holiday__c> oldMap){
        List<ResourceAbsence> resAbs = ServiceResourceHelper.fetchResAbsencesRecs(pw,publicHolidayDates);
        if(resAbs!= null && resAbs.size()>0){
            List<ResourceAbsence> resToUpdate = PublicHolidayHelper.getResToUpdate(resAbs,pw.userDatesMap,oldMap);
            if(resToUpdate.size() > 0 && ResourceAbsence.sObjectType.getDescribe().isUpdateable()){
                update resToUpdate;
            } 
        }
    }

    //Creates new Resource Absences when a new Public Holiday is created
    public static void createResAbsences(List<Public_Holiday__c> publicHolidays){
        try{
            Set<Id> opHrsId = new Set<Id>();
            Set<Date> holidayDates = new Set<Date>();
            for(Public_Holiday__c ph : publicHolidays){
                if(ph.Holiday_Date__c >= System.today()){
                    opHrsId.add(ph.Holiday_Working_Profile__c);
                    holidayDates.add(ph.Holiday_Date__c);
                }
            }
            if(opHrsId.size()>0){
                Map<Id,Work_Schedule__c> wrkSch = new Map<Id,Work_Schedule__c>([Select Id,Operating_Hours__c,Advisor__c from Work_Schedule__c where Operating_Hours__c IN: opHrsId]);
                if(wrkSch != null && !wrkSch.isEmpty()){
                    Map<Id,Id> advisors = WorkScheduleHandler.getAdvisorsMap(wrkSch);
                    ServiceResourceHelper.createNewAbsenceRecs(advisors,holidayDates);
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }  

    public class PublicHolidayWrap {
        public Map<Id,Set<Id>> userMap {get; set;}
        public Set<Id> advisorIds {get; set;}
        public Map<Id,List<Public_Holiday__c>> userDatesMap {get; set;}
        
        public PublicHolidayWrap(Map<Id,Set<Id>> usrMap,Set<Id> advIds,Map<Id,List<Public_Holiday__c>> usrDtsMap){
            userMap = usrMap;
            advisorIds = advIds;
            userDatesMap = usrDtsMap;
        }
    }
    
    public class PublicHolidayDateWrap {
        public Map<Id,Set<Id>> userMap {get; set;}
        public Set<Id> advisorIds {get; set;}
        public Map<Id,Set<Date>> userHolidayDatesMap {get; set;}
        
        public PublicHolidayDateWrap(Map<Id,Set<Id>> usrMap,Set<Id> advIds,Map<Id,Set<Date>> usrHolidayDtsMap){
            userMap = usrMap;
            advisorIds = advIds;
            userHolidayDatesMap = usrHolidayDtsMap;
        }
    }
}