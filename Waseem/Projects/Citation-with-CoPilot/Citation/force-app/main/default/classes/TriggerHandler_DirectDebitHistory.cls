public with sharing class TriggerHandler_DirectDebitHistory {

  /*  public static void OnBeforeInsert(List<Income_Debit_History__c> newRecords)
    {  
    }*/

    public static void OnAfterInsert(Map<Id, Income_Debit_History__c> newRecords)
    {
        System.debug('#### TriggerHandler_DirectDebitHistory.OnAfterInsert');
        System.debug('#### newRecords ' + newRecords.values());                    

        Set<String> submittedStages = new Set<String>();
        submittedStages.add('Submitted');
        List<Income_Debit_History__c> submittedCollections = SMP_DirectDebitHelper.getCollectionsByStage(newRecords.values(), null, submittedStages);

        // 1. Find sales invoice that have just been paid for. Use the query that we use for recalculation.
        Map<Id,Income_Direct_Debit__c> directDebits = SMP_DirectDebitHelper.getParentDirectDebitsFromHistories(submittedCollections);

        Set<Id> accountIds = new Set<Id>();
        for(Income_Direct_Debit__c dd : directDebits.values())
        {
            accountIds.add(dd.Account__c);
        }

        Map<Id, Account> accountsWithPostedInvoices = new Map<Id, Account>([SELECT Id,
                                                                                (SELECT Id, c2g__OwnerCompany__c, c2g__DueDate__c, c2g__InvoiceStatus__c, c2g__OutstandingValue__c
                                                                                FROM c2g__Invoices__r 
                                                                                WHERE ((c2g__PaymentStatus__c =: 'Unpaid' OR c2g__PaymentStatus__c =: 'Part Paid') AND c2g__InvoiceStatus__c =: 'Complete') 
                                                                                    AND c2g__OutstandingValue__c > 0)
                                                                            FROM Account WHERE Id IN :accountIds]);


        System.debug('#### submittedCollections ' + submittedCollections);                    

        System.debug('#### postedInvoices ' + accountsWithPostedInvoices);                    
        List<Sales_Invoice_Direct_Debit_Payment__c> SIDDPList= new List<Sales_Invoice_Direct_Debit_Payment__c>();
        for (Income_Debit_History__c history : submittedCollections) 
        {
            Income_Direct_Debit__c directDebit = directDebits.get(history.Income_Direct_Debit__c);
            
            if(directDebit != null)
            {
                Account acc = accountsWithPostedInvoices.get(directDebit.Account__c);

                if(acc != null)
                {
                    for (c2g__codaInvoice__c invoice : acc.c2g__Invoices__r) 
                    {
                        if(invoice.c2g__OwnerCompany__c == directDebit.Company__c
                            && invoice.c2g__DueDate__c <= history.DD_Collection_Date__c)
                        {
                            Sales_Invoice_Direct_Debit_Payment__c SIDDP = new Sales_Invoice_Direct_Debit_Payment__c();
                            SIDDP.Income_Debit_History__c = history.Id;
                            SIDDP.Sales_Invoice__c = invoice.Id;            
                            SIDDPList.add(SIDDP);
                        }
                    }
                }
            }
        }            
        System.debug('#### SIDDPList ' + SIDDPList);                    

        if(SIDDPList.size() > 0)
        {
            insert SIDDPList;
        }

        System.debug('#### directDebits ' + directDebits);

        if(directDebits.values().size() > 0)
        {
            update SMP_Direct_Debit_Citation_Helper.recalculateAmounts(directDebits.values());
            SMP_Direct_Debit_Citation_Helper.updateNextCollection(directDebits.keySet(), '3');
        }
    }
/*
    public static void OnBeforeUpdate(Map<Id, Income_Debit_History__c> newRecords, Map<Id, Income_Debit_History__c> oldRecords)
    {
        
    }

    public static void OnAfterUpdate(Map<Id, Income_Debit_History__c> newRecords, Map<Id, Income_Debit_History__c> oldRecords)
    { 
        
    }

    public static void OnAfterUndelete(Map<Id, Income_Debit_History__c> newRecords)
    {
        System.debug('#### TriggerHandler_DirectDebitHistory.OnBeforeUndelete');        
    }

    public static void OnBeforeDelete(Map<Id, Income_Debit_History__c> oldRecords)
    { 
    }
    
    public static void OnAfterDelete(Map<Id, Income_Debit_History__c> oldRecords)
    { 
    }*/
}