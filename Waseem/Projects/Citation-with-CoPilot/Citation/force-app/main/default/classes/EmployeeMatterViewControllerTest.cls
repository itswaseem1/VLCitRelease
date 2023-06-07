@isTest
public class EmployeeMatterViewControllerTest {
    @isTest
    public static void testUpdateRelatedEmployeeRecord() {
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        
        Employee__c newEmployee = new Employee__c(LastName__c = 'Test employee',FirstName__c = 'Steve', Account_Name__c = testAccount.Id);
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
        
        newCase.Employee__c = newEmployee.Id;
        newCase.AccountId =testAccount.id;
        update newCase;
         System.assertEquals(1, [SELECT COUNT() FROM Case], 'Case records amount');
       
        Test.startTest();
        Case a = [SELECT Id, subject FROM Case WHERE subject='test subject' LIMIT 1];
        
        EmployeeMattterViewController.fetchEmployeeMatter(a.Id) ;
        EmployeeMattterViewController.mapEmpfetchEmployee(a.Id) ;
        EmployeeMattterViewController.getEmployeeMatter(a.Id);
        Test.stopTest();
    }
}