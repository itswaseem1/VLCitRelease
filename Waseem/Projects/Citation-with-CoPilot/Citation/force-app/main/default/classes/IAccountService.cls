public interface IAccountService extends IDomainService
{
    /*
    *   Handles the check to see whether someone should be
    *   making a checkin call with an account.
    */
    void createPartnershipCall(Set<Id> accountIds);
}