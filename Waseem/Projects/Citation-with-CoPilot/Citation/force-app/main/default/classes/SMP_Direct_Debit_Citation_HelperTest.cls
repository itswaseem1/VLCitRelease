@isTest
public with sharing class SMP_Direct_Debit_Citation_HelperTest
{
    @testSetup static void testCreateCashEntries() 
    {
        TriggerSettings__c config = new TriggerSettings__c(Direct_Debit_History_Trigger__c = false, 
                                                            Direct_Debit_Trigger__c = false,
                                                            Sale_Invoice_Trigger__c = false,
                                                            Transaction_Trigger__c = false);
        insert config;
        SMP_Citation_Test_Helper.createFinancialForceData();

        Account acc = SMP_Citation_Test_Helper.createAccount('Test Account');

        Income_Direct_Debit__c IDD = new Income_Direct_Debit__c(
            Company__c = SMP_Citation_Test_Helper.company.Id,                            
            Default_Company_Direct_Debit__c = true,                    
            Name = 'DD00000001',                                       
            DD_Status__c = 'First Collection',                          
            Account__c = acc.Id,                            
            DD_Collection_Day__c = '7',                                
            DD_Bank_Sort_Code__c = '200000',                           
            DD_Collection_Period__c = 'Monthly',                       
            DD_Bank_Account_Number__c = '55779911',                    
            DD_Collection_Stretch__c = '1',                            
            DD_Bank_Account_Name__c = 'Mr William Smith',              
            DD_Collection_Type__c = 'Fixed',                           
            DD_First_Collection_Amount__c = 0.00,                      
            DD_Collection_Reference__c = 'Monthly Subscription',       
            DD_Ongoing_Collection_Amount__c = 0.00,                    
            DD_Final_Collection_Amount__c = 0.00,                      
            DD_Start_Date__c = Date.today(),             
            DD_First_Collection_Date__c = Date.today().addDays(8),  
            DD_Next_Collection_Date__c = Date.today().addDays(8)   
            );
        insert IDD;

        c2g__codaInvoice__c invoice = SMP_Citation_Test_Helper.createInvoice(SMP_Citation_Test_Helper.company.Id,acc.Id, System.today(), 10.0, IDD.Id);

        SMP_Citation_Test_Helper.postInvoice(invoice.Id);

        Income_Debit_History__c IDDH = new Income_Debit_History__c(
            Income_Direct_Debit__c = IDD.Id,        // Income Direct Debit
            Amount__c = 10.00,                                   // Amount
            DD_Status__c = 'First Collection',                   // DD Status
            DD_Collection_Date__c = Date.today(),  // DD Collection Date
            DD_Stage__c = 'Submitted'                              // DD Stage
          );
        insert IDDH;

        Sales_Invoice_Direct_Debit_Payment__c junc = new Sales_Invoice_Direct_Debit_Payment__c();
        junc.Income_Debit_History__c = IDDH.Id;
        junc.Sales_Invoice__c = invoice.Id;
        insert junc;
    }   

    @isTest
    private static void testExcuteBatch() {
        Test.startTest();
        SMP_Direct_Debit_CashMatchingBatch cashBatch = new SMP_Direct_Debit_CashMatchingBatch();
        cashBatch.execute(null);

        SMP_Direct_Debit_CashUnMatchingBatch cashUnBatch = new SMP_Direct_Debit_CashUnMatchingBatch();
        cashUnBatch.execute(null);
        Test.stopTest();        
    }

    @isTest
    private static void testExcuteBatchUnMatch2() {    
        Test.startTest();    

        List<Id> idhId = new List<Id>();

        for(Income_Debit_History__c idh : [SELECT Id FROM Income_Debit_History__c])
        {
            idhId.add(idh.Id);
        }

        Database.executeBatch(new SMP_Direct_Debit_CashUnMatchingBatch(idhId, [SELECT Id FROM c2g__codaCompany__c WHERE Direct_Debit_Bank_Account__c != null order by Name ASC][0].Id), 2);
        Test.stopTest();
    }
}