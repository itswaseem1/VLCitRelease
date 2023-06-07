public without sharing class PartnershipCallSchedule implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        IAccountService srv = new AccountService(new AccountService.AccountServiceSelector());
        Database.executeBatch(new PartnershipCallBatch(srv), 1);
    }
}