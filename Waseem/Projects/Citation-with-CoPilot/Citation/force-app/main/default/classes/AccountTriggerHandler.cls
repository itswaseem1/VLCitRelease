public without sharing class AccountTriggerHandler extends DefaultTriggerHandler
{
    public AccountTriggerHandler(IDomainService service, ITriggerHandler legacyCode)
    {
        super(service, legacyCode);
    }
}