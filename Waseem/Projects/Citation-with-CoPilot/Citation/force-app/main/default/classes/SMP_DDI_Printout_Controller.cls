public with sharing class SMP_DDI_Printout_Controller 
{   
    public Income_Direct_Debit__c directDebitRecord {get;set;}
    public SmarterPay_Direct_Debit_Setting__mdt setting  {get;set;}
    public SMP_DDI_Printout_Controller (ApexPages.StandardController sc)
    {
        directDebitRecord = (Income_Direct_Debit__c ) sc.getRecord();   
    }

    public void assignValues()
    {
        setting = [SELECT Mandate_Address__c, Mandate_Company_Name__c, Mandate_Email_Address__c, Mandate_Service_User_Number__c FROM SmarterPay_Direct_Debit_Setting__mdt WHERE Active__c = true LIMIT 1];
    }
    
}