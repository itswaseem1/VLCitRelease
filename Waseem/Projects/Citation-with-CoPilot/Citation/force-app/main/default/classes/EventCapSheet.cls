public with sharing class EventCapSheet {
     @AuraEnabled(cacheable=true)
     public static List<Contact> getContacts(String eventid){
        List<String> eid      = new List<String>();
        List<Id> whoIds       = new List<Id>();
        List<Contact> conList = new List<Contact>();
        eid.add(eventid);
        for(Event ev:[SELECT Id,WhoId FROM Event WHERE Id IN:eid]){
             whoIds.add(ev.WhoId);
        }
        for(EventRelation erl:[SELECT Id,EventId,Event.WhoId,RelationId,Status,Relation.Name,Relation.Type FROM EventRelation WHERE Relation.Type='Contact' AND EventId IN:eid]){
            whoIds.add(erl.RelationId);
        }
        conList = [SELECT Id,Name,Position__c,Phone,MobilePhone,Email FROM Contact WHERE Id IN:whoIds];
        return conList;
    }
}