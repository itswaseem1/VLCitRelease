//NB beware of changing case of first letter, copado doesn't play well with git.
// kept this class here even though it doesn't do much as deleting this will
// mean we can't recreate it.
public without sharing class contactTriggerHandler extends DefaultTriggerHandler
{
    public contactTriggerHandler(IDomainService service, ITriggerHandler legacyCode)
    {
        super(service, legacyCode);
    }
}