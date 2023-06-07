public without sharing class PartnershipCallBatch implements Database.Batchable<SObject>
{
    private IAccountService service;

    public PartnershipCallBatch(IAccountService service)
    {
        this.service = service;
    }

    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date referenceDate = Date.today().addDays(-30);

        return Database.getQueryLocator([SELECT ID 
                                            FROM Account 
                                            WHERE LastParternshipCheckIn__c <= :referenceDate]);
    }
  
    public void execute(Database.BatchableContext BC, List<Account> scope)
    {
        Set<Id> ids = new Map<Id, Account>(scope).keySet();

        service.createPartnershipCall(ids);
    }
  
    public void finish(Database.BatchableContext BC)
    {
    }
}