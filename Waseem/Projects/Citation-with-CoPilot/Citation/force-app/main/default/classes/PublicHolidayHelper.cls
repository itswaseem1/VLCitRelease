/**
 * @File Name          : PublicHolidayHelper.cls
 * @Description        : Helper class for PublicHolidayTriggerHandler.cls
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class PublicHolidayHelper {
    //Creates the Map of User and associated Public Holidays
    public static Map<Id,List<Public_Holiday__c>> getUserDatesMap(Map<Id,Set<Id>> userMap,Map<Id,List<Public_Holiday__c>> phMap){
        Map<Id,List<Public_Holiday__c>> userDatesMap = new Map<Id,List<Public_Holiday__c>>();
        for(Id opHrId : userMap.keySet()){
            for(Id userId : userMap.get(opHrId)){
                userDatesMap.put(userId,phMap.get(opHrId));
            }
        }
        return userDatesMap;
    }

    //Fetches the list of the existing Resource Absences for update
    public static List<ResourceAbsence> getResToUpdate(List<ResourceAbsence> resAbs,Map<Id,List<Public_Holiday__c>> userDatesMap,Map<Id,Public_Holiday__c> oldMap){
        List<ResourceAbsence> resToUpdate = new List<ResourceAbsence>();
        for(ResourceAbsence res : resAbs){
            if(userDatesMap.containsKey(res.Resource.RelatedRecordId)){
                for(Public_Holiday__c pb : userDatesMap.get(res.Resource.RelatedRecordId)){
                    ResWrap rw = checkResAbsUpdate(res,pb,oldMap);
                    if(rw.isUpdated){
                        resToUpdate.add(rw.resAbsence);
                    }
                }
            }
        }
        return resToUpdate;
    }

    public static ResWrap checkResAbsUpdate(ResourceAbsence res,Public_Holiday__c pb,Map<Id,Public_Holiday__c> oldMap){
        if(res.Start_Date__c == pb.Holiday_Date__c ){
            res.FSL__GanttLabel__c = pb.Name;
            return new ResWrap(true,res);
        }else if(res.Start_Date__c != pb.Holiday_Date__c && res.Start_Date__c == oldMap.get(pb.Id).Holiday_Date__c){
            res.Start = Datetime.newInstance(pb.Holiday_Date__c, time.newInstance(0, 0, 0, 0));
            res.End = Datetime.newInstance(pb.Holiday_Date__c, time.newInstance(23, 59, 59, 0));
            return new ResWrap(true,res);
        }else{
            return new ResWrap(false,res);
        }
    }

    public static PublicHolidayTriggerHandler.PublicHolidayDateWrap getPubHolidayMap(List<OperatingHours> mp,Map<Id,Set<Date>> phMap){
        PublicHolidayTriggerHandler.PublicHolidayWrap phwp = PublicHolidayTriggerHandler.getWrkSchMapping(mp);
        Map<Id,Set<Date>> userHolidayDatesMap = new Map<Id,Set<Date>>();
        if(!phwp.userMap.isEmpty()){
            for(Id opHrId : phwp.userMap.keySet()){
                for(Id userId : phwp.userMap.get(opHrId)){
                    userHolidayDatesMap.put(userId,phMap.get(opHrId));
                }
            }
        }
        return new PublicHolidayTriggerHandler.PublicHolidayDateWrap(phwp.userMap,phwp.advisorIds,userHolidayDatesMap);
    }

    public class ResWrap{
        public Boolean isUpdated {get; set;}
        public ResourceAbsence resAbsence {get; set;}
        
        public ResWrap(Boolean updt,ResourceAbsence resAbs){
            isUpdated = updt;
            resAbsence = resAbs;
        }
    }
}