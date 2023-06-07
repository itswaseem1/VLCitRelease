global class SMP_Direct_Debit_CashMatchingBatch implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String companyId;
    private Date dateToRun;

    global SMP_Direct_Debit_CashMatchingBatch()
    {
    }

    global SMP_Direct_Debit_CashMatchingBatch(String companyIdIn, Date dateToRunIn)
    {
        System.debug('#### SMP_Direct_Debit_CashMatchingBatch');
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

        return Database.getQueryLocator([SELECT Id, Name, Cash_Entry_Matching_Reference__c, Cash_Entry_UnMatching_Reference__c, Amount__c, DD_Stage__c, 
                                            Income_Direct_Debit__r.Company__c, Income_Direct_Debit__r.Name, Income_Direct_Debit__r.Company__r.Name, 
                                            Cash_Entry__c, Income_Direct_Debit__r.Account__c, Cash_Entry__r.c2g__Period__c, Cash_Entry_Refund__c, 
                                            (SELECT Id, Sales_Invoice__c, Sales_Invoice__r.Name, Sales_Invoice__r.c2g__Account__c, Sales_Invoice__r.c2g__OutstandingValue__c 
                                            FROM Sales_Invoice_Direct_Debit_Payments__r) 
                                        FROM Income_Debit_History__c 
                                        WHERE DD_Stage__c = 'Submitted' AND 
                                            (DD_Status__c = 'First Collection' OR DD_Status__c = 'Ongoing Collection')
                                            AND Cash_Entry__c = null 
                                            AND Income_Direct_Debit__r.Company__c = :companyId
                                            AND DAY_ONLY(CreatedDate) = :dateToRun]);
    }
 
    global void execute(Database.BatchableContext BC, List<Income_Debit_History__c> scope)
    {
        System.debug('#### execute');
        System.debug('#### scope: ' + scope);

        SMP_Direct_Debit_Citation_Helper.createCashEntries(scope);      
    }
 
    global void finish(Database.BatchableContext BC){
        System.debug('#### finish');
        System.debug('#### Checking for more companies');
        
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
            Database.executeBatch(new SMP_Direct_Debit_CashMatchingBatch(nextCompany, Date.Today()), 2);
        }        
    }

    global void execute(SchedulableContext sc) {        
        Database.executeBatch(new SMP_Direct_Debit_CashMatchingBatch(SMP_Direct_Debit_Citation_Helper.getCompanies()[0].Id, Date.Today()), 2);
    }
}