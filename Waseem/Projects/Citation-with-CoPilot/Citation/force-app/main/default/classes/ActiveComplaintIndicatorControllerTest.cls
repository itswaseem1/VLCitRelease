@isTest
public class ActiveComplaintIndicatorControllerTest {
    @testSetup static void setupmethod(){
        Account acc = new Account( name='Client query account');
        insert acc;
        List<Case> cases = new List<case>();
        Id queueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Query').getRecordTypeId();
        Case cs = New Case();
        cs.Subject='Client Query Concern';
        cs.Department__c='ELT';
        cs.Company__c='EPM';
        cs.AccountId=acc.id;
        cs.Concern__c=true;
        cs.Description='Case to test email';
        cs.RecordTypeId=queueRecordTypeId;
        cases.add(cs);
        Case cs1 = New Case();
        cs1.Subject='Client Query';
        cs1.Department__c='ELT';
        cs1.Company__c='EPM';
        cs1.AccountId=acc.id;
        cs1.Description='Case to test email';
        cs1.RecordTypeId=queueRecordTypeId;
        cases.add(cs1);
        Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
        Case casephone = new Case();
        casephone.RecordTypeId=rTId;
        casephone.Origin='ELT Advice - Phone';
        casephone.Status='New';
        casephone.Concern__c=true;
        casephone.Department__c='ELT';
        casephone.Company__c='EPM';
        casephone.AccountId=acc.id;
        casephone.Description='Case to test email';
        cases.add(casephone);
        insert cases;
    }
    @isTest
    public static void checkConcernCases(){
        account acc = [select id from account where name='Client query account' limit 1];
        Test.startTest();
        List<case> cases = ActiveComplaintIndicatorController.findCases(acc.id);
        Test.stopTest();
        System.assertEquals(1, cases.size());
        System.assertEquals('Client Query Concern', cases[0].Subject);
    }
}