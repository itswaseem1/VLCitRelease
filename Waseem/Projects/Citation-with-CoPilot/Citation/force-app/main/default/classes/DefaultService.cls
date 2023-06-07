public inherited sharing virtual class DefaultService implements IDomainService
{
    /*
    *   see IDomainService
    */
    public virtual void setDefaults(List<SObject> objects)
    {
    }

    public virtual void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
    }

    /*
    *   see IDomainService
    */
    public virtual List<ValidationError> validate(List<SObject> objects)
    {
        return new List<ValidationError>();
    }

    /*
    *   see IDomainService
    */
    public virtual void processRelatedRecordsOnNew(List<SObject> newRecords)
    {

    }

    /*
    *   see IDomainService
    */
    public virtual void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
    }
    
    /*
     * see IDomainService
    */
    public virtual void processRelatedRecordsOnDelete(List<SObject> newRecords)
    {
    }
}