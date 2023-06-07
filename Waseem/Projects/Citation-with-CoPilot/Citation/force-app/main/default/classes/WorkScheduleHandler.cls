/**
 * @File Name          : WorkScheduleHandler.cls
 * @Description        : Creates Resource Absence Records based on Public Holidays and assigns Operating Hours
 *                       to Service Territory members based on Work Schedules when Work Schedules records are created
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021                  Priyanka               Initial Version
 **/
public without sharing class WorkScheduleHandler {
    public static void createNewAbsenceRecords(Map<Id,Work_Schedule__c> newWrkSch){
        try{
            Map<Id,Id> advisors = getAdvisorsMap(newWrkSch);
            updateServiceTerritoryMemberRecords(advisors);
            createNewAbsenceRecs(advisors);
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }

    //Updates the Operating Hours of Service Territoy Members based on the Work Schedule records
    public static void updateServiceTerritoryMemberRecords(Map<Id,Id> advisors){
        try{
            List<ServiceTerritoryMember> serMembers = [Select Id,ServiceResource.RelatedRecordId,OperatingHoursId from ServiceTerritoryMember  where (EffectiveEndDate >= today or EffectiveEndDate = null) and ServiceResource.RelatedRecordId IN: advisors.keySet() WITH SECURITY_ENFORCED];
            List<ServiceTerritoryMember> stmMemtoUpdate = new List<ServiceTerritoryMember>();
            if(serMembers!= null && serMembers.size()>0){
                for(ServiceTerritoryMember stm : serMembers){
                    if(advisors.containsKey(stm.ServiceResource.RelatedRecordId)){
                        stm.OperatingHoursId = advisors.get(stm.ServiceResource.RelatedRecordId);
                        stmMemtoUpdate.add(stm);
                    }
                }
                if(stmMemtoUpdate.size()>0 && ServiceTerritoryMember.sObjectType.getDescribe().isUpdateable()){
                    update stmMemtoUpdate;
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }

    //Updates the existing Resource Absences based on the Work Schedule Records
    public static void updateExistingResAbsences(Map<Id,Work_Schedule__c> newWrkSch){
        try{
            Map<Id,Id> advisors = getAdvisorsMap(newWrkSch);
            updateServiceTerritoryMemberRecords(advisors);
            deleteExistingPublicHolidays(advisors.keySet());
            createNewAbsenceRecs(advisors);
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }

    //Creates new absences if no resource absences are found for the public holidays
    public static void createNewAbsenceRecs(Map<Id,Id> advisors){
        try{
            Map<Id,ServiceResource> res = new Map<ID, ServiceResource>([Select Id,RelatedRecordId from ServiceResource where IsActive = true and RelatedRecordId IN: advisors.keySet()]);
            if(!res.isEmpty()){
                ServiceResourcesWrap sr = serviceResOpHrMapping(res.values(),advisors);
                if(sr.opHrsId.size()>0){
                    List<Public_Holiday__c> publicHolidays = [Select Id,Name,Holiday_Date__c,Holiday_Working_Profile__c from Public_Holiday__c where Holiday_Working_Profile__c IN: sr.opHrsId and Holiday_Date__c>= Today WITH SECURITY_ENFORCED];
                    List<ResourceAbsence> resAbsences = getResourceAbsences(publicHolidays,sr.opHrUserMapping,sr.serResMap);
                    if(resAbsences.size()>0 && ResourceAbsence.sObjectType.getDescribe().isCreateable()){
                        insert resAbsences;
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }


    public static ServiceResourcesWrap serviceResOpHrMapping(List<ServiceResource> res,Map<Id,Id> advisors){
        Set<Id> opHrsId = new Set<Id>();
        Map<Id,Id> serResMap = new Map<Id,Id>();
        Map<Id,Set<Id>> opHrUserMapping = new Map<Id,Set<Id>>();
        for(ServiceResource serRes : res){
            if(advisors.containsKey(serRes.RelatedRecordId)){
                opHrsId.add(advisors.get(serRes.RelatedRecordId));
                serResMap.put(serRes.RelatedRecordId,serRes.Id);
                if(opHrUserMapping.containsKey(advisors.get(serRes.RelatedRecordId))){
                    opHrUserMapping.get(advisors.get(serRes.RelatedRecordId)).add(serRes.RelatedRecordId);
                }else{
                    opHrUserMapping.put(advisors.get(serRes.RelatedRecordId), new Set<Id>{serRes.RelatedRecordId});
                }
            }
        }
        return new ServiceResourcesWrap(opHrsId,serResMap,opHrUserMapping);
    }

    //Fetches the Resource Absence records related to Public Holidays
    public static List<ResourceAbsence> getResourceAbsences(List<Public_Holiday__c> publicHolidays,Map<Id,Set<Id>> opHrUserMapping,Map<Id,Id> serResMap){
        List<ResourceAbsence> resAbsences = new List<ResourceAbsence>();
        for(Public_Holiday__c ph : publicHolidays){
            for(Id resId : opHrUserMapping.get(ph.Holiday_Working_Profile__c)){
                ResourceAbsence rs = new ResourceAbsence(ResourceId= serResMap.get(resId),
                                                         Type='Public Holiday',
                                                         FSL__GanttLabel__c = ph.Name,
                                                         FSL__Approved__c = true, 
                                                         RecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId(),
                                                         Start = Datetime.newInstance(ph.Holiday_Date__c, time.newInstance(0, 0, 0, 0)),
                                                         End = Datetime.newInstance(ph.Holiday_Date__c, time.newInstance(23, 59, 59, 0)));
                resAbsences.add(rs);
            }
        }
        return resAbsences;
    }

    public static Map<Id,Id> getAdvisorsMap(Map<Id,Work_Schedule__c> newWrkSch){
        Map<Id,Id> advisors = new Map<Id,Id>();
        for(Work_Schedule__c wrk : newWrkSch.values()){
            advisors.put(wrk.Advisor__c,wrk.Operating_Hours__c);
        }
        return advisors;
    }

    //Deletes the existing Resource Absences associated to Public Holidays
    public static void deleteExistingPublicHolidays(Set<Id> advisorIds){
        try{
            List<ResourceAbsence> res = [Select Id from ResourceAbsence where Start_Date__c >= today and type='Public Holiday' and Resource.RelatedRecordId IN: advisorIds WITH SECURITY_ENFORCED];
            if(res.size()>0 && ResourceAbsence.sObjectType.getDescribe().isDeletable()){
                delete res;
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString());
        }
    }

    public class ServiceResourcesWrap {
        public Set<Id> opHrsId {get; set;}
        public Map<Id,Id> serResMap {get; set;}
        public Map<Id,Set<Id>> opHrUserMapping{get; set;}
        
        public ServiceResourcesWrap(Set<Id> opsId,Map<Id,Id> serRes,Map<Id,Set<Id>> opHrUser){
            opHrsId = opsId;
            serResMap = serRes;
            opHrUserMapping = opHrUser;
        }
    }
}