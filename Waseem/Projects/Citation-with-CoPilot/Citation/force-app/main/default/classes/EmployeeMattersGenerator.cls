public without sharing class EmployeeMattersGenerator {
    // create Employee_Matter__c for new Advise Generic cases (Employee__c not null)
    public static void createEmployeeMatterForNewAdviceCases(List<Case> adviseGenericCases) {
        Map<Id, Case> casesWithEmployee = new Map<Id, Case>();
        for (Case caseItem : adviseGenericCases) {
            if (caseItem.Employee__c != null) {
                casesWithEmployee.put(caseItem.Id, caseItem);
            }
        }
        createEmployeeMatters(casesWithEmployee.values(), adviseGenericCases);
    }
    // create Employee_Matter__c for updated Advise Generic cases (Employee__c was changed)
    public static void updateEmployeeMatterForAdviceCases(Map<Id, Case> oldCases, List<Case> adviseGenericCases) {
        List<Case> casesWithUpdatedEmployee = new List<Case>();
        Set<Id> caseIdsForMatterDelete = new Set<Id>();
        for (Case caseItem : adviseGenericCases) {
            if (oldCases.get(caseItem.Id) != null && caseItem.Employee__c != oldCases.get(caseItem.Id).Employee__c) {
                if (caseItem.Employee__c != null) {
                    casesWithUpdatedEmployee.add(caseItem);
                }
                caseIdsForMatterDelete.add(caseItem.Id);
            }
        }

        delete [SELECT Id FROM Employee_Matter__c WHERE Case__c IN :caseIdsForMatterDelete WITH SECURITY_ENFORCED];

        createEmployeeMatters(casesWithUpdatedEmployee, adviseGenericCases);
    }

    private static void createEmployeeMatters(List<Case> cases, List<Case> adviseGenericCases) {
        Map<String, Schema.SObjectField> employeeFields = Schema.SObjectType.Employee__c.fields.getMap();
        Map<String, Schema.SObjectField> employeeMatterFields = Schema.SObjectType.Employee_Matter__c.fields.getMap();
        Map<Id, Employee__c> employeesMap = getEmployees(employeeFields, adviseGenericCases);
        List<Employee_Matter__c> newEmplMatters = new List<Employee_Matter__c>();
        for (Case caseItem : cases) {
            Employee_Matter__c newEmplMatter = new Employee_Matter__c();
            newEmplMatter.Employee__c = caseItem.Employee__c;
            newEmplMatter.Case__c = caseItem.Id;
            for (String fieldName : employeeFields.keySet()) {
                Boolean canCopyField =
                    employeeMatterFields.containsKey(fieldName) &&
                    employeeMatterFields.get(fieldName).getDescribe().isUpdateable();
                if (canCopyField) {
                    Object oldValue = newEmplMatter.put(
                        fieldName, employeesMap.get(caseItem.Employee__c).get(fieldName)
                    );
                }
            }
            newEmplMatters.add(newEmplMatter);
        }
        if (Employee_Matter__c.SObjectType.getDescribe().isCreateable()) {
            insert newEmplMatters;
        }
    }

    private static Map<Id, Employee__c> getEmployees(Map<String, Schema.SObjectField> employeeFields, List<Case> adviseGenericCases) {
        Set<Id> employeeIds = new Set<Id>();
        for (Case caseItem : adviseGenericCases) {
            employeeIds.add(caseItem.Employee__c);
        }
        List<Employee__c> employees = Database.query(
            String.format(
                'SELECT {0} FROM Employee__c WHERE Id IN :employeeIds',
                new List<String>{ String.join(new List<String>(employeeFields.keySet()), ',') }
            )
        );
        Map<Id, Employee__c> employeesMap = new Map<Id, Employee__c>();
        for (Employee__c empl : employees) {
            employeesMap.put(empl.Id, empl);
        }

        return employeesMap;
    }
}