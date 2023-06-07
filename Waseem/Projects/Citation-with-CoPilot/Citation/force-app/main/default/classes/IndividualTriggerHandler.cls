/**
* @author Raghunath Utpala
* @date April 10 2019 
* @description this class contains methods to handle trigger events for Individual object.ApexPages
*/

public class IndividualTriggerHandler {
    public IndividualTriggerHandler() {

    }
    /**
    * @author Raghunath Utpala
    * @date April 10 2019
    * @description fired on before update of Indiviudal from Prospect Center - SDT-768
    * @return void
    * @param mapNewIndividuals: trigger.newMap contains new Individual records 
             oldIndividualMap : trigger.oldMap contains Old Individual recors
      When ever the prospect/client preferences are updated from Preference Centre ,then 
      the Soft-opt ins and Legitimate Interests should be unchecked.
    */
    public static void onBeforeUpdate(Map<Id,Individual> mapNewIndividuals,Map<Id,Individual> oldIndividualMap) {
    	User apiUser=[SELECT Id FROM  User WHERE Name=:System.Label.API_User_Name and isActive=true limit 1];
        for(Individual ind:mapNewIndividuals.values()){
            if(apiUser.Id==UserInfo.getUserId()){
                if(ind.News_service_updates__c!=oldIndividualMap.get(ind.Id).News_service_updates__c){
                     ind.News_service_updates_legit_soft__c=false;
                 }
                 if(ind.Eventswebinars__c!=oldIndividualMap.get(ind.Id).Eventswebinars__c){
                     ind.Events_webinars_legit_soft__c=false;
                 }
                 if(ind.Special_Offers__c!=oldIndividualMap.get(ind.Id).Special_Offers__c){
                     ind.New_product_offer_legit_soft__c=false;
                 }
                 if(ind.Atlas_platform_updates__c!=oldIndividualMap.get(ind.Id).Atlas_platform_updates__c){
                     ind.Atlas_platform_updates_legit_soft__c=false;
                 }
                 if(ind.Referral_scheme_updates__c!=oldIndividualMap.get(ind.Id).Referral_scheme_updates__c){
                     ind.Referral_scheme_updates_legit_soft__c=false;
                 }
                 if(ind.Citation_Partner_Offers__c!=oldIndividualMap.get(ind.Id).Citation_Partner_Offers__c){
                     ind.Citation_Partner_Offers_Soft_Opt_in__c=false;
                 }
                 if(ind.PR_Surveys__c!=oldIndividualMap.get(ind.Id).PR_Surveys__c){
                     ind.PR_Surveys_legit_soft__c=false;
                 }
            }
        }
    }
    /**
    * @author Raghunath Utpala
    * @date April 25 2019
    * @description fired on After update of Indiviudal
    * @return void
    * @param mapNewIndividuals: trigger.newMap contains new Individual records 
             oldIndividualMap : trigger.oldMap contains Old Individual recors
    */
    public static void  onAfterUpdate(Map<Id,Individual> oldObjectsMap,Map<Id,Individual> newObjectsMap){
        createIndividualHistory(oldObjectsMap, newObjectsMap);
    }
    /**
    * @author Raghunath Utpala
    * @date 25 April 2019
    * @description creates Individual History Records when Individual gets updated
    * @return void
    * @param newObjects: trigger.OldMap - map of all records before the change to update 
    * @param newObjectsMap: trigger.new -  map of all changed records to update
    */
    public static void createIndividualHistory(Map<Id, Individual> oldObjectsMap, Map<Id, Individual> newObjectsMap) {
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Individual.fields.getMap();
        List<Individual_History_Field__mdt> indHistoryMDTypes=new List<Individual_History_Field__mdt>();
        indHistoryMDTypes=[SELECT DeveloperName FROM Individual_History_Field__mdt];
        Set<String> fieldAPINames=new Set<String>();
        for(Individual_History_Field__mdt indmdt:indHistoryMDTypes){
            if(indmdt.DeveloperName!=null){
                fieldAPINames.add(indmdt.DeveloperName+'__c');
            }
        }
        List<Individual> individualsToProcess=new List<Individual>();
        List<Individual_History__c> individualHistoryList=new List<Individual_History__c>();
        for(Individual ind: newObjectsMap.values()){
            for(Schema.SObjectField sfield : schemaFieldMap .Values()){
                if(fieldAPINames.contains(sfield.getDescribe().getName())
                    && ind.get(sfield)!=oldObjectsMap.get(ind.Id).get(sfield)){
                        Individual_History__c indh=new Individual_History__c();
                        indh.Individual__c=ind.Id;
                        indh.Field_Name__c=sfield.getDescribe().getLabel();
                        indh.Modified_By__c=UserInfo.getUserId();
                        indh.Modified_Date_Time__c=System.now();
                        indh.New_Value__c=String.valueOf(ind.get(sfield));
                        indh.Old_Value__c=String.valueof(oldObjectsMap.get(ind.Id).get(sfield));
                        individualHistoryList.add(indh);
                }
            }
        }
        if(!individualHistoryList.isEmpty()){
            try{
                insert individualHistoryList;
            }
            catch(Exception e){
                throw e;
            }
        }
    }
}