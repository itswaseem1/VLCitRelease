public interface IDomainService
{
    /*
    *   This method is for setting deafault values on sobjects.
    *   It will be called by beforeInsert when accounts are inserted,
    *   but may be called from elsewhere as well.
    *   It should not assume the presence of Ids on the records, as they 
    *   are likely new.
    */
    void setDefaults(List<SObject> objects);

    /*
    *   This method is for the handling of any programmatic 'formula' or recalculations
    *   based on old values when a field changes. 
    *   Only fields on the newRecords should be changed during this call. This method 
    *   can be called by anything, but it will be called by beforeUpdate and so should adhere 
    *   to the constraints of that.
    */
    void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords);

    /*
    *   This method os for any validation that is needed against a record.
    *   This is for checking values or combination of values are correct etc.
    *   for any errors it should return a list of validation errors, and not 
    *   use addError or throw an exception, the caller of this method will handle
    *   the validation error as needed.
    *   This method will be called by after insert/update, but can be called from elsewhere.
    *   This method should not be inserting or updating anything, only running validation.
    */
    List<ValidationError> validate(List<SObject> objects);

    /*
    *   This method should handle the insert/update of related objects to the accounts in 
    *   question. 
    *   This will be called by after insert, but may be called from elsewhere.
    *   Avoid updating the accounts themselves if at all possible.
    */
    void processRelatedRecordsOnNew(List<SObject> newRecords);
    
    /*
    *   This method should handle the insert/update of related objects to the accounts in 
    *   question. 
    *   This will be called by after update, but may be called from elsewhere.
    *   Avoid updating the accounts themselves if at all possible.
    */
    void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords);
    
    /*
     * This method should handle the delete of the records 
     * This will be called when a record is deleted (after delete)
    */
    void processRelatedRecordsOnDelete(List<SObject> newRecords);


}