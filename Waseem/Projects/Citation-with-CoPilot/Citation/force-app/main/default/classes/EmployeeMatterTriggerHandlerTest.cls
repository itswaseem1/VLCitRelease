@isTest
public class EmployeeMatterTriggerHandlerTest {
    @isTest
    private static void testUpdateRelatedEmployeeRecord() {
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;

        Employee__c newEmployee = new Employee__c(LastName__c = 'Test employee',FirstName__c = 'TestEmp', Account_Name__c = testAccount.Id);
        insert newEmployee;

        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;

        Employee_Matter__c newEmplMatter = new Employee_Matter__c(
            Employee__c = newEmployee.Id,
            Case__c = newCase.Id
        );
        insert newEmplMatter;

        newEmplMatter.LastName__c = 'new Last Name';
        update newEmplMatter;

        System.assertEquals(
            'new Last Name',
            [SELECT Id, LastName__c FROM Employee__c WHERE Id = :newEmployee.Id].LastName__c,
            'Related Employee record wasn\'t changed'
        );
    }
}