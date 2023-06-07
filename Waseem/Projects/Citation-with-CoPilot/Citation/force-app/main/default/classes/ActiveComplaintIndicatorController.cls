public without sharing class ActiveComplaintIndicatorController {
    @AuraEnabled(cacheable=true)
    public static List<Case> findCases(String recordId) {
        Id queueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Query').getRecordTypeId();
        return [
            SELECT Id,Subject
            FROM Case
            WHERE RecordTypeId=:queueRecordTypeId and Concern__c=true and AccountId=:recordId limit 100
        ];
    }
}