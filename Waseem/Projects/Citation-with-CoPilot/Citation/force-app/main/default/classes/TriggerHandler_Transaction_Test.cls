@isTest 
public with sharing class TriggerHandler_Transaction_Test {
    
    @isTest static void testUpdate() 
    {

        TriggerSettings__c config = new TriggerSettings__c(Direct_Debit_History_Trigger__c = false, 
                                                            Direct_Debit_Trigger__c = false,
                                                            Sale_Invoice_Trigger__c = false,
                                                            Transaction_Trigger__c = false);
        insert config;
        // SMP_Citation_Test_Helper.generateCustomSettings();
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

        //invoice = [SELECT Id, c2g__Transaction__c FROM c2g__codaInvoice__c];
        //System.debug('#### invoice'+ invoice);

        // c2g__codaInvoice__c invoice2 = SMP_Citation_Test_Helper.createInvoice(SMP_Citation_Test_Helper.company.Id,acc.Id, System.today().addDays(8),5.0, IDD.Id);
        
        // SMP_Citation_Test_Helper.postInvoice(invoice2.Id);

        // invoice2 = [SELECT Id, c2g__Transaction__c FROM c2g__codaInvoice__c WHERE  Id =: invoice2.Id];

        // invoice.c2g__Transaction__c = invoice2.c2g__Transaction__c;

        // Test.startTest();
        // update invoice;
        // Test.stopTest();
        // Change invoice
        // ASSERT diff amounts on DD System.assertEquals(expected, actual);
    }
}