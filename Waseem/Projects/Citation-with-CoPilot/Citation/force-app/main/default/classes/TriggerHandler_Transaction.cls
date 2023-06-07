public with sharing class TriggerHandler_Transaction {

    public static void OnBeforeInsert(List<c2g__codaTransaction__c> newRecords)
    {

    }

    public static void OnAfterInsert(Map<Id, c2g__codaTransaction__c> newRecords)
    {
          
    }

    public static void OnBeforeUpdate(Map<Id, c2g__codaTransaction__c> newRecords, Map<Id, c2g__codaTransaction__c> oldRecords)
    {

    }
    
    public static void OnAfterUpdate(Map<Id, c2g__codaTransaction__c> newRecords, Map<Id, c2g__codaTransaction__c> oldRecords)
    {
        System.debug('#### TriggerHandler_Transaction:OnAfterUpdate');
        Set<Id> salesInvoiceIds = new Set<Id>();
        for (c2g__codaTransaction__c trans : newRecords.values()) 
        {            
            System.debug('#### trans: ' + trans);

            if(trans.c2g__SalesInvoice__c != oldRecords.get(trans.Id).c2g__SalesInvoice__c)
            {
                salesInvoiceIds.add(trans.c2g__SalesInvoice__c);
                salesInvoiceIds.add(oldRecords.get(trans.Id).c2g__SalesInvoice__c);

            }
            else if(trans.c2g__DocumentOutstandingTotal__c != oldRecords.get(trans.Id).c2g__DocumentOutstandingTotal__c)
            {
                salesInvoiceIds.add(trans.c2g__SalesInvoice__c);
            }
        }
        System.debug('#### salesInvoiceIds: ' + salesInvoiceIds);


        Map<Id,c2g__codaInvoice__c> salesInvoice = new Map<Id,c2g__codaInvoice__c>([SELECT Id, c2g__Account__c, c2g__OwnerCompany__c
                                                                                            FROM c2g__codaInvoice__c WHERE Id IN : salesInvoiceIds]);

        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> companyIds = new Set<Id>();

        for (c2g__codaInvoice__c invoice : salesInvoice.values()) 
        {
            accountIds.add(invoice.c2g__Account__c);
            companyIds.add(invoice.c2g__OwnerCompany__c);
        }

        List<Income_Direct_Debit__c> directDebits = [SELECT Id, Account__c, Company__c, Default_Company_Direct_Debit__c, DD_Account_Email__c, DD_Status__c, DD_First_Collection_Date__c, DD_Last_Collected_Date__c, DD_Next_Collection_Date__c,
                                                        DD_Final_Collection_Amount__c, DD_First_Collection_Amount__c, DD_Ongoing_Collection_Amount__c
                                                    FROM Income_Direct_Debit__c 
                                                    WHERE Account__c IN :accountIds AND Company__c IN :companyIds AND Default_Company_Direct_Debit__c = true];

        System.debug('#### directDebits: ' + directDebits);

        if(directDebits.size() > 0)
        {
            update SMP_Direct_Debit_Citation_Helper.recalculateAmounts(directDebits);
        }
    }

    public static void OnAfterDelete(Map<Id, c2g__codaTransaction__c> newRecords)
    {
        
    }

    public static void OnAfterUndelete(Map<Id, c2g__codaTransaction__c> newRecords)
    {
       
    }

}