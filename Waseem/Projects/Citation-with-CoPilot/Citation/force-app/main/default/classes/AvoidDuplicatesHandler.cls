/**
 * @File Name          : AvoidDuplicatesHandler.cls
 * @Description        : Avoids any Duplicates while Work Schedule Record Creation
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka                Initial Version
 **/
public without sharing class AvoidDuplicatesHandler {
    //Checks for duplicate Work Schedule records on insert operation
    public static void checkForDuplicates(List<Work_Schedule__c> workschedule){
        Set<Id> userIds = new Set<Id>();
        for(Work_Schedule__c wrk : workschedule){
            userIds.add(wrk.Advisor__c);
        }
        if(userIds.size() > 0){
            checkForErrors(userIds,workschedule);
        }
    }

    //Checks for duplicate Work Schedule records on update operation
    public static void checkForDuplicatesonUpdate(Map<Id, Work_Schedule__c> newWorkschedule,Map<Id, Work_Schedule__c> oldWorkschedule){
        Set<Id> userIds = new Set<Id>();
        for(Work_Schedule__c wrk : newWorkschedule.values()){
            if(newWorkschedule.get(wrk.Id).Advisor__c != oldWorkschedule.get(wrk.Id).Advisor__c){
                userIds.add(newWorkschedule.get(wrk.Id).Advisor__c);
            }
        }
        if(userIds.size()>0){
            checkForErrors(userIds,newWorkschedule.values());
        }
    }

    //Displays an error when duplicate Work Schedule records found
    public static void checkForErrors(Set<Id> userIds,List<Work_Schedule__c> newWrkRecs){
        try{
            List<Work_Schedule__c> lstWrk = [Select Id,Advisor__c from Work_Schedule__c where Advisor__c in :userIds WITH SECURITY_ENFORCED];
            if(lstWrk != null && lstWrk.size() > 0){
                Map<Id ,Work_Schedule__c> mapUsers = new Map<Id ,Work_Schedule__c>();
                for(Work_Schedule__c wrksch: lstWrk){
                    mapUsers.put(wrksch.Advisor__c ,wrksch);
                }
                for(Work_Schedule__c wrk1 : newWrkRecs){
                    if(mapUsers.containsKey(wrk1.Advisor__c)){
                        wrk1.addError('Work Schedule for the user already exist. Please update the existing record.');
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception occured -->'+ex.getStackTraceString());
        }
    }
}