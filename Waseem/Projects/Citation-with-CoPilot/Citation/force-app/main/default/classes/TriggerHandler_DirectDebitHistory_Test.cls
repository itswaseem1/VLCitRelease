@isTest
public with sharing class TriggerHandler_DirectDebitHistory_Test
{
    @isTest static void testInsert() 
    {
        String responseBody = '{"CollectionDatesResult":[{"Error":"","CollectionDate":"2022-05-07", "request_collectionday":"7"},{"Error":"","CollectionDate":"2022-11-14", "request_collectionday":"14"},{"Error":"","CollectionDate":"2022-05-21", "request_collectionday":"21"},{"Error":"","CollectionDate":"2022-11-28", "request_collectionday":"28"}]}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock (200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        SMP_Citation_Test_Helper.generateCustomSettings();
        SMP_Citation_Test_Helper.createFinancialForceData();

        Account acc = SMP_Citation_Test_Helper.createAccount('Test Account');
        Income_Direct_Debit__c IDD = new Income_Direct_Debit__c(
            Company__c = SMP_Citation_Test_Helper.company.Id,                            // Company
            Default_Company_Direct_Debit__c = true,                    // Default Company Direct Debit
            Name = 'DD00000001',                                       // AUDDIS Ref
            DD_Status__c = 'First Collection',                          // Status
            Account__c = acc.Id,                            // Account
            DD_Collection_Day__c = '7',                                // Collection Day
            DD_Bank_Sort_Code__c = '200000',                           // Bank Sort Code
            DD_Collection_Period__c = 'Monthly',                       // Collection Period
            DD_Bank_Account_Number__c = '55779911',                    // Bank Account Number
            DD_Collection_Stretch__c = '1',                            // Collection Stretch
            DD_Bank_Account_Name__c = 'Mr William Smith',              // Bank Account Name
            DD_Collection_Type__c = 'Fixed',                           // Collection Type
            DD_First_Collection_Amount__c = 0.00,                      // First Collection Amount
            DD_Collection_Reference__c = 'Monthly Subscription',       // Collection Reference
            DD_Ongoing_Collection_Amount__c = 0.00,                    // Ongoing Collection Amount
            DD_Final_Collection_Amount__c = 0.00,                      // Final Collection Amount
            DD_Start_Date__c = Date.today(),             // Start Date
            DD_First_Collection_Date__c = Date.today(),  // First Collection Date
            DD_Next_Collection_Date__c = Date.today()   // Next Collection Date
            );
        insert IDD;

        c2g__codaInvoice__c invoice = SMP_Citation_Test_Helper.createInvoice(SMP_Citation_Test_Helper.company.Id,acc.Id, System.today().addDays(8),10.0, IDD.Id);

        SMP_Citation_Test_Helper.postInvoice(invoice.Id);
        
        Income_Debit_History__c IDDH = new Income_Debit_History__c(
        Income_Direct_Debit__c = IDD.Id,        // Income Direct Debit
        Amount__c = 10.00,                                   // Amount
        DD_Status__c = 'First Collection',                   // DD Status
        DD_Collection_Date__c = Date.today(),  // DD Collection Date
        DD_Stage__c = 'Submitted'                              // DD Stage
        );
        insert IDDH;
    }
}