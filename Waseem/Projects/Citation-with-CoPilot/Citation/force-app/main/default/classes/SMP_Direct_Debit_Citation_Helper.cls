public with sharing class SMP_Direct_Debit_Citation_Helper {
   
    public static List<Income_Direct_Debit__c> recalculateAmounts(List<Income_Direct_Debit__c> directDebits)
    {
        System.debug('#### recalculateAmounts');
        System.debug('#### directDebits: ' + directDebits);

        //1. Get the Sales Invoices with the same company on the accounts attached to the direct debit.
        Set<Id> accountIds = new Set<Id>();
        for(Income_Direct_Debit__c dd : directDebits)
        {
            accountIds.add(dd.Account__c);
        }

        Map<Id, Account> accountsWithPostedInvoices = new Map<Id, Account>([SELECT Id,
                                                                                (SELECT Id, c2g__OwnerCompany__c, c2g__DueDate__c, c2g__InvoiceStatus__c, c2g__OutstandingValue__c
                                                                                FROM c2g__Invoices__r 
                                                                                WHERE ((c2g__PaymentStatus__c =: 'Unpaid' OR c2g__PaymentStatus__c =: 'Part Paid') AND c2g__InvoiceStatus__c =: 'Complete') 
                                                                                    AND c2g__OutstandingValue__c > 0) 
                                                                            FROM Account WHERE Id IN :accountIds]);

        
        System.debug('#### postedInvoices: ' + accountsWithPostedInvoices);                                                                    

        //Find all the invoices which link to each direct debit and recalculate the collection amounts accordingly  
        for (Income_Direct_Debit__c dd : directDebits)
        {
            Decimal newOutstanding = 0;

            if(dd.Default_Company_Direct_Debit__c == true)
            {
                Account acc = accountsWithPostedInvoices.get(dd.Account__c);

                if(acc != null)
                {
                    for (c2g__codaInvoice__c invoice : acc.c2g__Invoices__r) 
                    {
                        if(invoice.c2g__OwnerCompany__c == dd.Company__c)
                        {
                            //If the direct debit status is 'New Instruction' or 'First Collection' then we need to check that the Due Date is in the past from the First Collection Date. If the status is set to anything else, we check the Next Collection Date instead
                            if(((dd.DD_Status__c == 'New Instruction' || dd.DD_Status__c == 'First Collection')  && (dd.DD_First_Collection_Date__c >= invoice.c2g__DueDate__c)) || 
                                (!(dd.DD_Status__c == 'New Instruction' || dd.DD_Status__c == 'First Collection') && (dd.DD_Next_Collection_Date__c >= invoice.c2g__DueDate__c)))
                            {
                                    newOutstanding += invoice.c2g__OutstandingValue__c;
                            }
                        }
                    }
                }                
            }
        
            //Update the amount which correlates to the correct status
            if(dd.DD_Status__c == 'First Collection' || dd.DD_Status__c == 'New Instruction')
            {
                dd.DD_First_Collection_Amount__c = newOutstanding;
                dd.DD_Ongoing_Collection_Amount__c = newOutstanding;
            }
            else if(dd.DD_Status__c == 'Ongoing Collection')
            {
                dd.DD_Ongoing_Collection_Amount__c = newOutstanding;
            }
            else if(dd.DD_Status__c == 'Final Collection')
            {
                dd.DD_Final_Collection_Amount__c = newOutstanding;
            }
            else if(dd.DD_Status__c == 'First Represent')
            {
                dd.DD_Ongoing_Collection_Amount__c = newOutstanding;
            }
            else if(dd.DD_Status__c == 'Second Represent')
            {
                dd.DD_Ongoing_Collection_Amount__c = newOutstanding;
            }
            else if(dd.DD_Status__c == 'Third Represent')
            {
                dd.DD_Ongoing_Collection_Amount__c = newOutstanding;
            }
            else
            {
                dd.DD_First_Collection_Amount__c = 0;
                dd.DD_Ongoing_Collection_Amount__c = 0;
                dd.DD_Final_Collection_Amount__c = 0;

                dd.DD_First_Collection_Date__c = null;
                dd.DD_Next_Collection_Date__c = null;
            }
        }

        System.debug('#### directDebits: ' + directDebits);

        return directDebits;
    }
    
    @future(callout=true)
    public static void updateNextCollection(Set<Id> directDebitsIDs, String noOfDaysToWait)
    {
        Map<Id,Income_Direct_Debit__c> directDebits = new Map<Id, Income_Direct_Debit__c>([SELECT Id, DD_Start_Date__c, Account__c, DD_Next_Collection_Date__c, DD_First_Collection_Date__c, DD_Status__c,
                                                                                                Company__c, Company__r.Direct_Debit_Collection_Dates__c 
                                                                                           FROM Income_Direct_Debit__c WHERE Id IN : directDebitsIDs]);
        System.debug('##### directDebits ' + directDebits);

        Map<Date, Map<Id,Income_Direct_Debit__c>> ddsByStartDate = new Map<Date, Map<Id,Income_Direct_Debit__c>>();
        ddsByStartDate.put(Date.today(), new Map<Id,Income_Direct_Debit__c>());

        for(Income_Direct_Debit__c dd : directDebits.values())
        {
            if(dd.DD_Start_Date__c > Date.Today())
            {
                if(ddsByStartDate.get(dd.DD_Start_Date__c) == null)
                {
                    ddsByStartDate.put(dd.DD_Start_Date__c, new Map<Id,Income_Direct_Debit__c>());
                }

                ddsByStartDate.get(dd.DD_Start_Date__c).put(dd.Id, dd);
            }
            else
            {
                ddsByStartDate.get(Date.today()).put(dd.Id, dd);
            }
        }

        for(Date d : ddsByStartDate.keySet())
        {
            setNextCollection(ddsByStartDate.get(d), d, noOfDaysToWait);
        }

        System.debug('##### directDebits ' + directDebits);

        update directDebits.values();
        
        System.debug('##### directDebits ' + directDebits);
    }

    public static void setNextCollection(Map<Id,Income_Direct_Debit__c> directDebits, Date startDate, String noOfDaysToWait)
    {
        System.debug('##### setNextCollection');
        System.debug('##### directDebits ' + directDebits);
        System.debug('##### startDate ' + startDate);

        Map<String, Date> bestDateByCollectionSchedule = new Map<String, Date>();
        Set<String> datesToCheck = new Set<String>();

        for (Income_Direct_Debit__c dd : directDebits.values()) 
        {
            datesToCheck.addAll(dd.Company__r.Direct_Debit_Collection_Dates__c.split(';'));            
            bestDateByCollectionSchedule.put(dd.Company__r.Direct_Debit_Collection_Dates__c, null);
        }

        System.debug('##### datesToCheck ' + datesToCheck);

        List<SMP_DDServiceHandler.SingleCollectionDateWrapper> collectionWrapper = new List<SMP_DDServiceHandler.SingleCollectionDateWrapper>();
        
        for(String d : datesToCheck)
        {
            SMP_DDServiceHandler.SingleCollectionDateWrapper date1 = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
            date1.CollectionDay = d;
            date1.StartDate = String.valueOf(startDate);
            date1.CollectionPeriod = 'Monthly';
            date1.NumberOfDaysToWaitFromNewInstruction = noOfDaysToWait;

            collectionWrapper.add(date1);
        }
        
        System.debug('##### collectionWrapper ' + collectionWrapper);

        SMP_DDServiceNextCollectionModelList reponseList = SMP_DDServiceHandler.getNextCollectionDate(collectionWrapper);

        System.debug('##### reponseList ' + reponseList);
       
        for (String collectionSchedule : bestDateByCollectionSchedule.keySet())
        {
            System.debug('##### collectionSchedule ' + collectionSchedule);

            Date bestDate = null;
            List<String> scheduleDates = collectionSchedule.split(';');

            for (SMP_DDServiceNextCollectionModelList.CollectionDatesResult response : reponseList.CollectionDatesResult) 
            {
                if(scheduleDates.contains(response.request_collectionday))
                {
                    if(bestDate == null)
                    {
                        if (!Test.isRunningTest()) 
                        {
                            bestDate = Date.valueOf(response.CollectionDate);
                        }
                        else 
                        {
                            bestDate = Date.today();    
                        }
                        continue;
                    }

                    if (!Test.isRunningTest()) 
                    {
                        if(Date.valueOf(response.CollectionDate) < bestDate)
                        {
                            bestDate = Date.valueOf(response.CollectionDate);
                        }
                    }
                }                
            }
            
            System.debug('##### bestdate ' + bestDate);

            bestDateByCollectionSchedule.put(collectionSchedule, bestDate);
        }
        
        

        for (Income_Direct_Debit__c dd : directDebits.values()) 
        {
            Date bestDate = bestDateByCollectionSchedule.get(dd.Company__r.Direct_Debit_Collection_Dates__c);

            if(dd.DD_Status__c == 'First Collection' || dd.DD_Status__c == 'New Instruction')
            {
                dd.DD_First_Collection_Date__c = bestDate;            
            }
            
            dd.DD_Next_Collection_Date__c = bestDate;            
        }

        System.debug('##### directDebits ' + directDebits);
    }
    
    public static void createCashEntries(List<Income_Debit_History__c> directDebitHistories)
    {
        System.debug('#### createCashEntries');
        System.debug('#### directDebitHistories: ' + directDebitHistories);

        List<c2g.CODAAPICashEntryTypes_7_0.CashEntry> cashEntries = new List<c2g.CODAAPICashEntryTypes_7_0.CashEntry>();
        List<String> documentRefs = new List<String>();
        Set<Id> companyIds = new Set<Id>();

        c2g.CODAAPICommon_7_0.Context cashEntryContext = new c2g.CODAAPICommon_7_0.Context();

        for(Income_Debit_History__c directDebit : directDebitHistories)
        {
            companyIds.add(directDebit.Income_Direct_Debit__r.Company__c);
        }

        Map<Id, c2g__codaCompany__c> companies = new Map<Id, c2g__codaCompany__c>([SELECT Id, Name, c2g__BankAccount__c, Direct_Debit_Bank_Account__c, c2g__BankAccount__r.c2g__BankChargesGLA__c, 
                                                                                        (SELECT Id FROM c2g__Periods__r WHERE c2g__StartDate__c <= Today AND c2g__EndDate__c >= Today Limit 1), 
                                                                                        (SELECT Id FROM c2g__AccountingCurrencies__r WHERE Name = 'GBP')
                                                                                  FROM c2g__codaCompany__c
                                                                                  WHERE Id IN :companyIds]);


        for(Income_Debit_History__c directDebit : directDebitHistories)
        {
            System.debug('#### directDebit: ' + directDebit);

            c2g__codaCompany__c company = companies.get(directDebit.Income_Direct_Debit__r.Company__c);

            cashEntryContext.CompanyName = company.Name;
            System.debug('#### company: ' + company);

            c2g.CODAAPICashEntryTypes_7_0.CashEntry entry = new c2g.CODAAPICashEntryTypes_7_0.CashEntry();
            entry.BankAccount = c2g.CODAAPICommon.getRef(company.Direct_Debit_Bank_Account__c, null);
            entry.ChargesGLA = c2g.CODAAPICommon.getRef(company.c2g__BankAccount__r.c2g__BankChargesGLA__c, null);
            entry.CashEntryCurrency = c2g.CODAAPICommon.getRef(company.c2g__AccountingCurrencies__r[0].Id, null);
            entry.Period = c2g.CODAAPICommon.getRef(company.c2g__Periods__r[0].Id, null);
            entry.PaymentMethod = 'Electronic';
            entry.TypeRef = c2g.CODAAPICashEntryTypes_7_0.enumType.Receipt;
            entry.Status = c2g.CODAAPICashEntryTypes_7_0.enumStatus.InProgress;
            entry.Reference = directDebit.Name;
            entry.BankAccountValue = directDebit.Amount__c;
            entry.NetValue = directDebit.Amount__c;
            entry.NetBanked = directDebit.Amount__c;
            entry.DateValue = Date.Today();

            entry.LineItems = new c2g.CODAAPICashEntryLineItemTypes_7_0.CashEntryLineItems();
            entry.LineItems.LineItemList = new List<c2g.CODAAPICashEntryLineItemTypes_7_0.CashEntryLineItem>();

            c2g.CODAAPICashEntryLineItemTypes_7_0.CashEntryLineItem item = new c2g.CODAAPICashEntryLineItemTypes_7_0.CashEntryLineItem();
            item.Account = c2g.CODAAPICommon.getRef(directDebit.Income_Direct_Debit__r.Account__c, null);
            item.CashEntryValue = directDebit.Amount__c;
            item.BankAccountValue = directDebit.Amount__c;
            item.AccountPaymentMethod = 'Electronic';
            item.Charges = 0.00;

            entry.LineItems.LineItemList.add(item);

            for(Sales_Invoice_Direct_Debit_Payment__c invoiceDDPayment :  directDebit.Sales_Invoice_Direct_Debit_Payments__r)
            {
                documentRefs.add(invoiceDDPayment.Sales_Invoice__r.Name);
            }            

            cashEntries.add(entry);
        }

        System.debug('#### cashEntries to insert: ' + cashEntries);

        List<c2g.CODAAPICommon.Reference> cashEntryRefs = c2g.CODAAPICashEntry_7_0.BulkCreateCashEntry(cashEntryContext, cashEntries);

        System.debug('#### cashEntryRefs: ' + cashEntryRefs);

        c2g.CODAAPICashEntry_7_0.BulkPostCashEntry(null, cashEntryRefs);

        System.debug('#### Update directDebitHistories: ' + directDebitHistories);
        
        Set<Id> cashEntryIds = new Set<Id>();

        for(c2g.CODAAPICommon.Reference cashEntry : cashEntryRefs)
        {
            cashEntryIds.add(cashEntry.Id);
        }

        Map<Id, c2g__codaCashEntry__c> insertedCashEntries = new Map<Id, c2g__codaCashEntry__c>([SELECT Id, Name, c2g__Reference__c, c2g__Account__c, c2g__Period__c FROM c2g__codaCashEntry__c WHERE Id IN :cashEntryIds]);
        
        System.debug('#### insertedCashEntries: ' + insertedCashEntries);

        for(c2g__codaCashEntry__c entry : insertedCashEntries.values())
        {
            documentRefs.add(entry.Name);
        }
        
        List<c2g__codaTransactionLineItem__c> transactionLinesToMatch = [SELECT Id, c2g__AccountValue__c, c2g__AccountOutstandingValue__c, c2g__Transaction__r.c2g__DocumentNumber__c  
                                                                        FROM c2g__codaTransactionLineItem__c
                                                                        WHERE c2g__Transaction__r.c2g__DocumentNumber__c in :documentRefs 
                                                                            AND c2g__LineType__c = 'Account'
        ];

        System.debug('#### transactionLinesToMatch: ' + transactionLinesToMatch);

        for(Income_Debit_History__c directDebit : directDebitHistories)
        {
            for(c2g__codaCashEntry__c cashEntry : insertedCashEntries.values())
            {
                if(directDebit.Name == cashEntry.c2g__Reference__c)
                {
                    directDebit.Cash_Entry__c = cashEntry.Id;

                    try
                    {
                        c2g.CODAAPICommon_8_0.Context context = new c2g.CODAAPICommon_8_0.Context();
                        context.CompanyName = directDebit.Income_Direct_Debit__r.Company__r.Name;
                        
                        Set<String> references = new Set<String>();
                        references.add(cashEntry.Name);

                        for(Sales_Invoice_Direct_Debit_Payment__c invoiceDDPayment :  directDebit.Sales_Invoice_Direct_Debit_Payments__r)
                        {
                            references.add(invoiceDDPayment.Sales_Invoice__r.Name);                        
                        }

                        c2g.CODAAPICashMatchingTypes_8_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_8_0.Configuration();
                        configuration.Account = c2g.CODAAPICommon.getRef(directDebit.Income_Direct_Debit__r.Account__c, null);
                        configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_8_0.enumMatchingCurrencyMode.Account; 
                        configuration.MatchingDate = System.today();
                        configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(cashEntry.c2g__Period__c, null);

                        List<c2g.CODAAPICashMatchingTypes_8_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_8_0.Item>();
                        for (c2g__codaTransactionLineItem__c transactionLine : transactionLinesToMatch)
                        {
                            if(references.contains(transactionLine.c2g__Transaction__r.c2g__DocumentNumber__c))
                            {
                                c2g.CODAAPICashMatchingTypes_8_0.Item item = new c2g.CODAAPICashMatchingTypes_8_0.Item();
                                item.TransactionLineItem = c2g.CODAAPICommon.getRef(transactionLine.Id, null);
                                item.Paid = transactionLine.c2g__AccountOutstandingValue__c;
                                item.Discount = 0;
                                item.WriteOff = 0;
                                items.add(item);
                            }                
                        }                    
                    
                        c2g.CODAAPICashMatchingTypes_8_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_8_0.Analysis();
                        c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_8_0.Match(context, configuration, items, analisysInfo);
                        directDebit.Cash_Entry_Matching_Reference__c = matchReference.Id;
                    } 
                    catch (Exception e)
                    {
                        System.debug('#### Exception during cash matching');
                        System.debug('#### Exception: ' + e);
                        directDebit.Cash_Matching_Error__c = String.valueOf(e);
                    }                    
                }                
            }            
        }
        
        update directDebitHistories;
    }

    public static void unmatchCashEntries(List<Income_Debit_History__c> directDebitHistories)
    {        
        System.debug('#### unmatchCashEntries');
        System.debug('#### directDebitHistories: ' + directDebitHistories);
        
        List<c2g.CashEntryService.CancelCashEntryInfo> cashEntryCancels = new List<c2g.CashEntryService.CancelCashEntryInfo>();

        for(Income_Debit_History__c directDebit : directDebitHistories)
        {
            c2g.CODAAPICommon_8_0.Context context = new c2g.CODAAPICommon_8_0.Context();
            context.CompanyName = directDebit.Income_Direct_Debit__r.Company__r.Name;

            c2g.CODAAPICashMatchingTypes_8_0.Configuration configuration = new c2g.CODAAPICashMatchingTypes_8_0.Configuration();
            configuration.Account = c2g.CODAAPICommon.getRef(directDebit.Income_Direct_Debit__r.Account__c, null);
            configuration.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_8_0.enumMatchingCurrencyMode.Account; 
            configuration.MatchingDate = System.today();
            configuration.MatchingPeriod = c2g.CODAAPICommon.getRef(directDebit.Cash_Entry__r.c2g__Period__c, null);

            c2g.CODAAPICashMatchingTypes_8_0.Analysis analisysInfo = new c2g.CODAAPICashMatchingTypes_8_0.Analysis();
            c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_8_0.Unmatch(context, configuration, c2g.CODAAPICommon.getRef(directDebit.Cash_Entry_Matching_Reference__c, null), c2g.CODAAPICashMatchingTypes_8_0.enumUndoReason.RemittanceAdviceIncorrect);

            directDebit.Cash_Entry_UnMatching_Reference__c = matchReference.Id;

            c2g.CashEntryService.CancelCashEntryInfo cancelCashEntryInfo = new c2g.CashEntryService.CancelCashEntryInfo();
            cancelCashEntryInfo.OriginalCashEntryId = directDebit.Cash_Entry__c;
            cancelCashEntryInfo.PeriodId = directDebit.Cash_Entry__r.c2g__Period__c;
            cancelCashEntryInfo.Reference = directDebit.Name;

            cashEntryCancels.add(cancelCashEntryInfo);
        }         

        List<Id> cancellingCashEntryIdList = c2g.CashEntryService.cancelCashEntries(cashEntryCancels);

        List<c2g__codaCashEntry__c> insertedCashEntries = [SELECT Id, Name, c2g__Reference__c FROM c2g__codaCashEntry__c WHERE Id IN :cancellingCashEntryIdList];
        
        System.debug('#### insertedCashEntries: ' + insertedCashEntries);

        for(Income_Debit_History__c directDebit : directDebitHistories)
        {
            for(c2g__codaCashEntry__c cashEntry : insertedCashEntries)
            {
                if(directDebit.Name == cashEntry.c2g__Reference__c)
                {
                    directDebit.Cash_Entry_Refund__c = cashEntry.Id;
                }                
            }            
        }

        update directDebitHistories;
    }

    public static List<c2g__codaCompany__c> getCompanies()
    {
        return [SELECT Id FROM c2g__codaCompany__c WHERE Direct_Debit_Bank_Account__c != null order by Name ASC];
    }
}