global class SMP_Direct_Debit_CashUnMatchingBatch implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String companyId;
    private Date dateToRun;
    private List<Id> directDebitHistoryIds;

    global SMP_Direct_Debit_CashUnMatchingBatch()
    {
    }

    global SMP_Direct_Debit_CashUnMatchingBatch(List<Id> directDebitHistoryIdsIn, String companyIdIn)
    {
        System.debug('#### SMP_Direct_Debit_CashUnMatchingBatch');
        System.debug('#### companyIdIn: ' + companyIdIn);
        System.debug('#### directDebitHistoryIdsIn: ' + directDebitHistoryIdsIn);

        companyId = companyIdIn;
        directDebitHistoryIds = directDebitHistoryIdsIn;

        c2g__codaCompany__c company = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Id = :companyId];
        System.debug('#### company: ' + company);

        c2g.CODAAPICompany_2_0.SetCurrentCompanies(new List<String>{company.Name});
    }

    global SMP_Direct_Debit_CashUnMatchingBatch(String companyIdIn, Date dateToRunIn)
    {
        System.debug('#### SMP_Direct_Debit_CashUnMatchingBatch');
        System.debug('#### companyIdIn: ' + companyIdIn);

        companyId = companyIdIn;
        dateToRun = dateToRunIn;

        c2g__codaCompany__c company = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Id = :companyId];
        System.debug('#### company: ' + company);

        c2g.CODAAPICompany_2_0.SetCurrentCompanies(new List<String>{company.Name});
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('#### Start');
        System.debug('#### companyId: ' + companyId);
        System.debug('#### dateToRun: ' + dateToRun);
        System.debug('#### directDebitHistoryIds: ' + directDebitHistoryIds);

        if(directDebitHistoryIds != null)
        {
            return Database.getQueryLocator([SELECT Id, Cash_Entry__c
                                            FROM Income_Debit_History__c 
                                            WHERE Id IN : directDebitHistoryIds]);
        }
        else 
        {
            return Database.getQueryLocator([SELECT Id, Name, Cash_Entry_Matching_Reference__c, Cash_Entry_UnMatching_Reference__c, Amount__c, DD_Stage__c, 
                                                Income_Direct_Debit__r.Company__c, Income_Direct_Debit__r.Name, Income_Direct_Debit__r.Company__r.Name, 
                                                Cash_Entry__c, Income_Direct_Debit__r.Account__c, Cash_Entry__r.c2g__Period__c, Cash_Entry_Refund__c, 
                                                (SELECT Id, Sales_Invoice__c, Sales_Invoice__r.Name, Sales_Invoice__r.c2g__Account__c, Sales_Invoice__r.c2g__OutstandingValue__c 
                                                FROM Sales_Invoice_Direct_Debit_Payments__r) 
                                            FROM Income_Debit_History__c 
                                            WHERE DD_Stage__c = 'Failed' AND 
                                                (DD_Status__c = 'First Collection' OR DD_Status__c = 'Ongoing Collection')
                                                AND Cash_Entry__c != null 
                                                AND Cash_Entry_Matching_Reference__c != null 
                                                AND Cash_Entry_Refund__c = null 
                                                AND Income_Direct_Debit__r.Company__c = :companyId
                                                AND DAY_ONLY(LastModifiedDate) = :dateToRun]);
        }        
    }
 
    global void execute(Database.BatchableContext BC, List<Income_Debit_History__c> scope)
    {
        System.debug('#### execute');
        System.debug('#### scope: ' + scope);
        
        if(directDebitHistoryIds != null)
        {
            Set<Id> cashEntryIds = new Set<Id>();

            for(Income_Debit_History__c idh : scope)
            {
                cashEntryIds.add(idh.Cash_Entry__c);
            }

            List<c2g__codaCashEntry__c> cashEntries = [SELECT Id, c2g__Period__c FROM c2g__codaCashEntry__c WHERE Id IN :cashEntryIds];

            List<c2g.CashEntryService.CancelCashEntryInfo> cashEntryCancels = new List<c2g.CashEntryService.CancelCashEntryInfo>();

            for(c2g__codaCashEntry__c cashEntry : cashEntries)
            {
                c2g.CashEntryService.CancelCashEntryInfo cancelCashEntryInfo = new c2g.CashEntryService.CancelCashEntryInfo();
                cancelCashEntryInfo.OriginalCashEntryId = cashEntry.Id;
                cancelCashEntryInfo.PeriodId = cashEntry.c2g__Period__c;
                //cancelCashEntryInfo.Reference = directDebit.Name;

                cashEntryCancels.add(cancelCashEntryInfo);
            }

            List<Id> cancellingCashEntryIdList = c2g.CashEntryService.cancelCashEntries(cashEntryCancels);

            System.debug('#### New Ids: ' + cancellingCashEntryIdList);
        }
        else
        {
            SMP_Direct_Debit_Citation_Helper.unmatchCashEntries(scope);
        }        
    }
 
    global void finish(Database.BatchableContext BC){
        System.debug('#### finish');
        System.debug('#### Checking for more companies');

        if(directDebitHistoryIds == null)
        {
            String nextCompany;

            List<c2g__codaCompany__c> companies = SMP_Direct_Debit_Citation_Helper.getCompanies();

            for(Integer i = 0; i < companies.Size(); i++)
            {
                if(companyId == companies[i].Id)
                {
                    if(companies.Size() > i + 1)
                    {
                        nextCompany = companies[i + 1].Id;
                        break;
                    }
                }
            }

            System.debug('#### nextCompany: ' + nextCompany);
            
            if(nextCompany != null)
            {
                Database.executeBatch(new SMP_Direct_Debit_CashUnMatchingBatch(nextCompany, Date.Today()), 2);
            }
        }
    }

    global void execute(SchedulableContext sc) {        
        Database.executeBatch(new SMP_Direct_Debit_CashUnMatchingBatch(SMP_Direct_Debit_Citation_Helper.getCompanies()[0].Id, Date.Today()), 2);
    }
}