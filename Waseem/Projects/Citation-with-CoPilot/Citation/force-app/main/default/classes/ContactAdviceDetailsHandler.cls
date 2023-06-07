public without sharing class ContactAdviceDetailsHandler {
    public static void updatePinSetDate(Map<Id,Contact> oldMap,Map<Id,Contact> newMap){
        try{
            for(Contact cont : newMap.values()){
                if(oldMap.get(cont.Id).Advice_Pin__c != null && cont.Advice_Pin__c != oldMap.get(cont.Id).Advice_Pin__c){
                    cont.Pin_Set_Date__c = null;
                }else if(cont.Pin_Set_Date__c != oldMap.get(cont.Id).Pin_Set_Date__c && oldMap.get(cont.Id).Advice_Card_Number__c != null && oldMap.get(cont.Id).Pin_Set_Date__c == null){
                    cont.Pin_Set_Date__c = null;
                }
            } 
        }catch(Exception ex){
            system.debug('Exception occured->'+ex.getStackTraceString()+ex.getMessage());
        }
    }
}