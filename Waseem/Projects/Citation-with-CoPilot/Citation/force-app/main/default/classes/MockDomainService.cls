public inherited sharing class MockDomainService implements IDomainService
{
    public Map<String, Boolean> calledMethods = new Map<String, Boolean>();

    public void setDefaults(List<SObject> objects)
    {
        calledMethods.put('setDefaults', true);
    }

    public void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        calledMethods.put('processChangedValues', true);
    }

    public List<ValidationError> validate(List<SObject> objects)
    {
        calledMethods.put('validate', true);
        return null;
    }

    public void processRelatedRecordsOnNew(List<SObject> newRecords)
    {
        calledMethods.put('processRelatedRecordsOnNew', true);
    }

    public void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        calledMethods.put('processRelatedRecordsOnChange', true);
    }

    public void processRelatedRecordsOnDelete(List<SObject> newRecords)
    {
        calledMethods.put('processRelatedRecordsOnDelete', true);
    }
}