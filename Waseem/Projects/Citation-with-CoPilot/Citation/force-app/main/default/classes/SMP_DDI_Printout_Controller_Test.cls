@isTest
public with sharing class SMP_DDI_Printout_Controller_Test {
    @isTest static void controller_Test() 
    {
        Income_Direct_Debit__c IDD = new Income_Direct_Debit__c(
            DD_Bank_Sort_Code__c = '200000', 
            DD_Bank_Account_Number__c = '55779911',
            DD_Status__c = 'First Collection'
        );
        insert IDD;

        ApexPages.StandardController sc = new ApexPages.StandardController(IDD);

        SMP_DDI_Printout_Controller controller = new SMP_DDI_Printout_Controller(sc);
        System.assert(controller.directDebitRecord != null);

    }

    @isTest static void assignValues_Test() 
    {
        Income_Direct_Debit__c IDD = new Income_Direct_Debit__c(
            DD_Bank_Sort_Code__c = '200000', 
            DD_Bank_Account_Number__c = '55779911',
            DD_Status__c = 'First Collection'
        );
        insert IDD;

        ApexPages.StandardController sc = new ApexPages.StandardController(IDD);

        SMP_DDI_Printout_Controller controller = new SMP_DDI_Printout_Controller(sc);
        controller.assignValues();

        System.assert(controller.directDebitRecord != null);
        System.assert(controller.setting != null);

    }
}