@isTest
public without sharing class MockTriggerHandler implements ITriggerHandler
{    
    public Map<String, Boolean> calledMethods = new Map<String, Boolean>();
    public void beforeInsert(List<SObject> newRecords)
    {
        calledMethods.put('beforeInsert', true);
    }
    public void afterInsert(List<SObject> newRecords)
    {
        calledMethods.put('afterInsert', true);
    }

    public void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        calledMethods.put('beforeUpdate', true);
    }
    public void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        calledMethods.put('afterUpdate', true);
    }

    public void beforeDelete(List<SObject> oldRecords)
    {
        calledMethods.put('beforeDelete', true);
    }
    public void afterDelete(List<SObject> oldRecords)
    {
        calledMethods.put('afterDelete', true);
    }

    public void afterUnDelete(List<SObject> newRecords)
    {
        calledMethods.put('afterUnDelete', true);
    }
}