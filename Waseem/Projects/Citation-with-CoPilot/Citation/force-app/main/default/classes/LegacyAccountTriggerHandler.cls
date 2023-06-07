public without sharing class LegacyAccountTriggerHandler implements ITriggerHandler
{
    private boolean isIHasco()
    {
        return iHASCOUtility.userDivison == 'iHASCO';
    }

    public void beforeInsert(List<SObject> newRecords)
    {
        TriggerAccountHandler.getInstance().onBeforeInsert((List<Account>)newRecords);
    }

    public void afterInsert(List<SObject> newRecords)
    {
    }

    public void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {       
        TriggerAccountHandler.getInstance().onBeforeUpdate((Map<Id,Account>)newRecords, (Map<Id,Account>)oldRecords);
    }

    public void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        AccountHandler.accountProcessor((Map<Id,Account>)oldRecords, (Map<Id,Account>)newRecords);
    }

    public void beforeDelete(List<SObject> oldRecords)
    {
    }
    public void afterDelete(List<SObject> oldRecords)
    {
    }

    public void afterUnDelete(List<SObject> newRecords)
    {
    }
}