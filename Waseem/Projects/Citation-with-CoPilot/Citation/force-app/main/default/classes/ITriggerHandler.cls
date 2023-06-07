public interface ITriggerHandler 
{
    void beforeInsert(List<SObject> newRecords);
    void afterInsert(List<SObject> newRecords);

    void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords);
    void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords);

    void beforeDelete(List<SObject> oldRecords);
    void afterDelete(List<SObject> oldRecords);

    void afterUnDelete(List<SObject> newRecords);
}