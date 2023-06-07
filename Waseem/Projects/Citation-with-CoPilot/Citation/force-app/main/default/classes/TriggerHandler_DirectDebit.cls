public without sharing class TriggerHandler_DirectDebit {
    public static void OnBeforeInsert(List<Income_Direct_Debit__c> newRecords)
    {
        System.debug('#### TriggerHandler_DirectDebit:OnBeforeInsert');

        List<Income_Direct_Debit__c> defaultedDirectDebits = new List<Income_Direct_Debit__c>();

        for(Income_Direct_Debit__c dd : newRecords)
        {     
            if(dd.Default_Company_Direct_Debit__c == true)
            {
                // Need to check its the only default dd for the company on the account.                
                defaultedDirectDebits.add(dd);
            }
        }
        
        if(defaultedDirectDebits.Size() > 0)
        {
            checkForDefaultDirectDebits(defaultedDirectDebits);
        }        

        SMP_Direct_Debit_Citation_Helper.recalculateAmounts(newRecords);
    }

    public static void OnAfterInsert(Map<Id, Income_Direct_Debit__c> newRecords)
    {
    }

    public static void OnBeforeUpdate(Map<Id, Income_Direct_Debit__c> newRecords, Map<Id, Income_Direct_Debit__c> oldRecords)
    {
        system.debug('#### newRecords ' + newRecords);
        List<Income_Direct_Debit__c> ddsToRecalculate = new List<Income_Direct_Debit__c>();
        Set<Id> ddsToSetCollectionDates = new Set<Id>();
        List<Income_Direct_Debit__c> defaultedDirectDebits = new List<Income_Direct_Debit__c>();

        for (Income_Direct_Debit__c directDebit : newRecords.values()) 
        {
            if(directDebit.Default_Company_Direct_Debit__c == true && oldRecords.get(directDebit.Id).Default_Company_Direct_Debit__c == false)
            {
                defaultedDirectDebits.add(directDebit);
            }

            if((directDebit.Default_Company_Direct_Debit__c != oldRecords.get(directDebit.Id).Default_Company_Direct_Debit__c)
                || (directDebit.DD_First_Collection_Date__c != oldRecords.get(directDebit.Id).DD_First_Collection_Date__c)
                || (directDebit.DD_Next_Collection_Date__c != oldRecords.get(directDebit.Id).DD_Next_Collection_Date__c)
                || (directDebit.DD_Status__c != oldRecords.get(directDebit.Id).DD_Status__c))
            {
                ddsToRecalculate.add(directDebit);
            }

            // If the collection has a 0.00 amount the dd software will set it to on-hold. 
            // This code bypasses that and resets it to a collection and recalculates the collection dates.
            if(directDebit.DD_Status__c == 'On Hold' && directDebit.DD_Hold_Reason__c == 'Failed to send to BACS')
            {
                directDebit.DD_Status__c = oldRecords.get(directDebit.Id).DD_Status__c;
                directDebit.DD_Hold_Reason__c = '';
                
                ddsToSetCollectionDates.add(directDebit.Id);               
            }            
        }

        if(defaultedDirectDebits.Size() > 0)
        {
            checkForDefaultDirectDebits(defaultedDirectDebits);
        }

        System.debug('#### ddsToRecalculate ' + ddsToRecalculate);
        if (ddsToRecalculate.size() > 0 ) 
        {
            SMP_Direct_Debit_Citation_Helper.recalculateAmounts(ddsToRecalculate);
        }

        System.debug('#### ddsToSetCollectionDates ' + ddsToSetCollectionDates);
        if(ddsToSetCollectionDates.size() > 0)
        {
            SMP_Direct_Debit_Citation_Helper.updateNextCollection(ddsToSetCollectionDates, '3');
        }
    }
    
    public static void OnAfterUpdate(Map<Id, Income_Direct_Debit__c> newRecords, Map<Id, Income_Direct_Debit__c> oldRecords)
    {
        Set<Id> ddResetToNewInstruction = new Set<Id>();
        Set<Id> ddRecalculateDate = new Set<Id>();

        for (Income_Direct_Debit__c directDebit : newRecords.values()) 
        {
            // This covers if a user manually switches back to new instruction or an ADDACS causes the reset to new instruction.
            if(directDebit.DD_Status__c == 'New Instruction' && oldRecords.get(directDebit.Id).DD_Status__c != 'New Instruction')
            {                
                ddResetToNewInstruction.add(directDebit.Id);               
            }

            // This covers if an ARUDD sets to On Hold but the user then sets it back to a collection.            
            if((directDebit.DD_Status__c == 'First Collection' || directDebit.DD_Status__c == 'Ongoing Collection') 
                && oldRecords.get(directDebit.Id).DD_Status__c == 'On Hold')
            {                
                ddRecalculateDate.add(directDebit.Id);               
            }

            // This also covers if the Start Date changes.
            if(directDebit.DD_Start_Date__c != oldRecords.get(directDebit.Id).DD_Start_Date__c) 
            {                
                ddRecalculateDate.add(directDebit.Id);               
            }
        }

        System.debug('#### ddResetToNewInstruction ' + ddResetToNewInstruction);
        if(ddResetToNewInstruction.size() > 0)
        {
            SMP_Direct_Debit_Citation_Helper.updateNextCollection(ddResetToNewInstruction, '10');
        }

        System.debug('#### ddRecalculateDate ' + ddRecalculateDate);
        if(ddRecalculateDate.size() > 0)
        {
            SMP_Direct_Debit_Citation_Helper.updateNextCollection(ddRecalculateDate, '3');
        }
    }

    private static void checkForDefaultDirectDebits(List<Income_Direct_Debit__c> defaultedDirectDebits)
    {
        Set<Id> defaultDDAccountsToCheck = new Set<Id>();

        for(Income_Direct_Debit__c dd : defaultedDirectDebits)
        {
            if(dd.Account__c != null)
            {
                defaultDDAccountsToCheck.add(dd.Account__c);
            }            
        }
        

        Map<Id, Account> defaultDDsByAccount = new Map<Id, Account>([SELECT Id,
                                                                        (SELECT Id, Company__c, Default_Company_Direct_Debit__c
                                                                        FROM Income_Direct_Debit__r 
                                                                        WHERE Default_Company_Direct_Debit__c = true) 
                                                                    FROM Account 
                                                                    WHERE Id IN :defaultDDAccountsToCheck]);

        for (Income_Direct_Debit__c dd : defaultedDirectDebits) 
        {
            Account acc = defaultDDsByAccount.get(dd.Account__c);

            if(acc != null)
            {
                for(Income_Direct_Debit__c existingDDs : acc.Income_Direct_Debit__r)
                {
                    if(dd.Company__c == existingDDs.Company__c)
                    {
                        dd.Default_Company_Direct_Debit__c.addError('You can only have one default direct debit on an account per company. Please unassign the existing default direct debit.');
                    }
                }                
            }            
        }
    }
}