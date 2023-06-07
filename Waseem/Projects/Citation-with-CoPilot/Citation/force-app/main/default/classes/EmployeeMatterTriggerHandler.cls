public with sharing class EmployeeMatterTriggerHandler {
    // update appropriate Employee__c field value after related Employee_Matter__c is updated
    public static void updateRelatedEmployeeRecord(Map<Id, Employee_Matter__c> oldMatters, Map<Id, Employee_Matter__c> newMatters) {
        if (!Schema.sObjectType.Employee__c.isUpdateable()) {
            return;
        }
        Map<String, Schema.SObjectField> employeeFields = Schema.SObjectType.Employee__c.fields.getMap();
        Map<String, Schema.SObjectField> employeeMatterFields = Schema.SObjectType.Employee_Matter__c.fields.getMap();
        Map<Id, Employee__c> employeesMapForUpdate = new Map<Id, Employee__c>();
        for (Employee_Matter__c emplMatter : newMatters.values()) {
            employeesMapForUpdate.put(emplMatter.Employee__c, new Employee__c(Id = emplMatter.Employee__c));
            for (String fieldName : employeeMatterFields.keySet()) {
                Boolean canUpdateField =
                    employeeFields.containsKey(fieldName) &&
                    employeeFields.get(fieldName).getDescribe().isUpdateable() &&
                    emplMatter.get(fieldName) != oldMatters.get(emplMatter.Id).get(fieldName);
                if (canUpdateField) {
                    employeesMapForUpdate.get(emplMatter.Employee__c).put(fieldName, emplMatter.get(fieldName));
                }
            }
        }

        update employeesMapForUpdate.values();
    }
}