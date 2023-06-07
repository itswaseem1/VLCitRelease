public class TriggerHandler_SalesInvoice {

    public static void OnBeforeInsert(List<c2g__codaInvoice__c> newRecords)
    {
        System.debug('#### TriggerHandler_SalesInvoice:OnBeforeInsert');
    }

    public static void OnAfterInsert(Map<Id, c2g__codaInvoice__c> newRecords)
    {        
    }

    public static void OnBeforeUpdate(Map<Id, c2g__codaInvoice__c> newRecords, Map<Id, c2g__codaInvoice__c> oldRecords)
    {
    }
    
    public static void OnAfterUpdate(Map<Id, c2g__codaInvoice__c> newRecords, Map<Id, c2g__codaInvoice__c> oldRecords)
    {
        System.debug('#### TriggerHandler_SalesInvoice:OnAfterUpdate');

        Set<Id> accountIds = new Set<Id>();
        Set<Id> companyIds = new Set<Id>();

        for (c2g__codaInvoice__c newRecord : newRecords.values()) 
        {
            for (c2g__codaInvoice__c oldRecord : oldRecords.values()) 
            {
                if(newRecord.Id == oldRecord.Id)
                {
                    if(newRecord.c2g__OwnerCompany__c != oldRecord.c2g__OwnerCompany__c ||
                        newRecord.c2g__InvoiceStatus__c != oldRecord.c2g__InvoiceStatus__c ||
                        newRecord.c2g__PaymentStatus__c != oldRecord.c2g__PaymentStatus__c ||
                        newRecord.c2g__OutstandingValue__c != oldRecord.c2g__OutstandingValue__c ||
                        newRecord.c2g__Transaction__c != oldRecord.c2g__Transaction__c ||
                        newRecord.c2g__DueDate__c != oldRecord.c2g__DueDate__c)
                    {
                        accountIds.add(newRecord.c2g__Account__c);
                        companyIds.add(newRecord.c2g__OwnerCompany__c);
                    }
                }
                
            }
        }

        System.debug('#### accountIds: ' + accountIds);

        if(accountIds.Size() > 0)
        {
            List<Income_Direct_Debit__c> finalDDs = [SELECT Id, Account__c, Company__c, Default_Company_Direct_Debit__c, DD_Account_Email__c, DD_Status__c, DD_First_Collection_Date__c, DD_Last_Collected_Date__c, DD_Next_Collection_Date__c,
                                                        DD_Final_Collection_Amount__c, DD_First_Collection_Amount__c, DD_Ongoing_Collection_Amount__c
                                                    FROM Income_Direct_Debit__c 
                                                    WHERE Account__c IN :accountIds AND Company__c IN :companyIds AND Default_Company_Direct_Debit__c = true];

            System.debug('#### finalDDs: ' + finalDDs);

            if (finalDDs.size() > 0) 
            {
                update SMP_Direct_Debit_Citation_Helper.recalculateAmounts(finalDDs);
            }
        }        
    }

    public static void OnAfterDelete(Map<Id, c2g__codaInvoice__c> newRecords)
    {
        // List<Id> filterDDs = new List<Id>();

        // for (c2g__codaInvoice__c newRecord : newRecords.values()) 
        // {
        //     filterDDs.add(newRecord.Income_Direct_Debit__c);
        // }
        // Map<Id,Income_Direct_Debit__c> finalDDs = new Map<Id,Income_Direct_Debit__c>([SELECT Id, DD_Account_Email__c, DD_Status__c, DD_First_Collection_Date__c, DD_Last_Collected_Date__c, DD_Next_Collection_Date__c,
        //                                                                               DD_Final_Collection_Amount__c, DD_First_Collection_Amount__c, DD_Ongoing_Collection_Amount__c
        //                                                                               FROM Income_Direct_Debit__c WHERE Id IN : filterDDs ]);
        // if (finalDDs.values().size() > 0) 
        // {
        //     update SMP_Direct_Debit_Citation_Helper.recalculateAmounts(finalDDs).values();
        // }
    }

    public static void OnAfterUndelete(Map<Id, c2g__codaInvoice__c> newRecords)
    {
        // List<Id> filterDDs = new List<Id>();

        // for (c2g__codaInvoice__c newRecord : newRecords.values()) 
        // {
        //     filterDDs.add(newRecord.Income_Direct_Debit__c);
        // }
        // Map<Id,Income_Direct_Debit__c> finalDDs = new Map<Id,Income_Direct_Debit__c>([SELECT Id, DD_Account_Email__c, DD_Status__c, DD_First_Collection_Date__c, DD_Last_Collected_Date__c, DD_Next_Collection_Date__c,
        //                                                                               DD_Final_Collection_Amount__c, DD_First_Collection_Amount__c, DD_Ongoing_Collection_Amount__c
        //                                                                               FROM Income_Direct_Debit__c WHERE Id IN : filterDDs ]);
        // if (finalDDs.values().size() > 0) 
        // {
        //     update SMP_Direct_Debit_Citation_Helper.recalculateAmounts(finalDDs).values();
        // }
    }
}