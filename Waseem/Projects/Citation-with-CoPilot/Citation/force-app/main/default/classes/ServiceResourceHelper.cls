/**
 * @File Name          : RefferalAccessHandler.cls
 * @Description        : Creates the Resource Absences based on the Public Holidays
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021                  Priyanka               Initial Version
 **/
public without sharing class ServiceResourceHelper {
    //Creates new Resource Absences based on Public Holidays
    public static void createNewAbsenceRecs(Map<Id,Id> advisors,Set<Date> holidayDates){
        try{
            Map<Id,ServiceResource> res = new Map<ID, ServiceResource>([Select Id,RelatedRecordId from ServiceResource where IsActive = true and RelatedRecordId IN: advisors.keySet()]);
            if(!res.isEmpty()){
                WorkScheduleHandler.ServiceResourcesWrap sr = WorkScheduleHandler.serviceResOpHrMapping(res.values(),advisors);
                if(sr.opHrsId.size()>0){
                    List<Public_Holiday__c> publicHolidays = [Select Id,Name,Holiday_Date__c,Holiday_Working_Profile__c from Public_Holiday__c where Holiday_Working_Profile__c IN: sr.opHrsId and Holiday_Date__c>= Today and Holiday_Date__c IN: holidayDates WITH SECURITY_ENFORCED];
                    List<ResourceAbsence> resAbsences = WorkScheduleHandler.getResourceAbsences(publicHolidays,sr.opHrUserMapping,sr.serResMap);
                    if(resAbsences.size()>0 && ResourceAbsence.sObjectType.getDescribe().isCreateable()){
                        insert resAbsences;
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }

    //Fetches the Resource Absence records
    public static List<ResourceAbsence> fetchResAbsencesRecs(PublicHolidayTriggerHandler.PublicHolidayWrap pw,Set<Date> publicHolidayDates){
        List<ResourceAbsence> resAbs = [Select Id,Start,Resource.RelatedRecordId,Start_Date__c from ResourceAbsence where type='Public Holiday' and Resource.RelatedRecordId IN: pw.advisorIds and Start_Date__c IN:publicHolidayDates WITH SECURITY_ENFORCED];
        return resAbs;
    }

    //Deletes the existing Resource Absence records
    public static void delResAbsences(PublicHolidayTriggerHandler.PublicHolidayDateWrap pw,Set<Date> publicHolidayDates){
        List<ResourceAbsence> resAbs = [Select Id,Start,Resource.RelatedRecordId,Start_Date__c from ResourceAbsence where type='Public Holiday' and Resource.RelatedRecordId IN: pw.advisorIds and Start_Date__c IN:publicHolidayDates WITH SECURITY_ENFORCED];
        List<ResourceAbsence> resToDelete = new List<ResourceAbsence>();
        for(ResourceAbsence res : resAbs){
            if(pw.userHolidayDatesMap.get(res.Resource.RelatedRecordId).contains(res.Start_Date__c)){
                resToDelete.add(res);
            }
        }
        if(resToDelete.size() > 0 && ResourceAbsence.sObjectType.getDescribe().isDeletable()){
            delete resToDelete;
        }
    }

    public static DateWrap fetchDateMap(List<Public_Holiday__c> delHolidays){
        Map<Id,Set<Date>> phMap = new Map<Id,Set<Date>>();
        Set<Date> publicHolidayDates = new Set<Date>();
        for(Public_Holiday__c holiday : delHolidays){
            if(holiday.Holiday_Date__c >= System.today()){
                publicHolidayDates.add(holiday.Holiday_Date__c);
                if(phMap.containsKey(holiday.Holiday_Working_Profile__c)){
                    phMap.get(holiday.Holiday_Working_Profile__c).add(holiday.Holiday_Date__c);
                }else{
                    phMap.put(holiday.Holiday_Working_Profile__c,new Set<Date>{holiday.Holiday_Date__c});
                }
            }
        }
        return new DateWrap(publicHolidayDates,phMap,null);
    }

    public static DateWrap fetchPHMap(Map<Id,Public_Holiday__c> oldMap,Map<Id,Public_Holiday__c> newMap){
        Map<Id,List<Public_Holiday__c>> phMap = new Map<Id,List<Public_Holiday__c>>();
        Set<Date> publicHolidayDates = new Set<Date>();
        for(Public_Holiday__c holiday : newMap.values()){
            if(holiday.Holiday_Date__c >= System.today()){
                publicHolidayDates.add(oldMap.get(holiday.Id).Holiday_Date__c);
                if(phMap.containsKey(holiday.Holiday_Working_Profile__c)){
                    phMap.get(holiday.Holiday_Working_Profile__c).add(holiday);
                }else{
                    phMap.put(holiday.Holiday_Working_Profile__c,new List<Public_Holiday__c>{holiday});
                }
            }
        }
        return new DateWrap(publicHolidayDates,null,phMap);
    }
    
    public class DateWrap {
        public Map<Id,Set<Date>> phDateMap {get; set;}
        public Set<Date> publicHolidayDates {get; set;}
        public Map<Id,List<Public_Holiday__c>> holidayMap {get; set;}
        
        public DateWrap(Set<Date> phDates,Map<Id,Set<Date>> phDtMap,Map<Id,List<Public_Holiday__c>> phMap){
            publicHolidayDates = phDates;
            phDateMap = phDtMap;
            holidayMap = phMap;
        }
    }
    
}