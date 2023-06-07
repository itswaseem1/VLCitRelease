public virtual without sharing class DefaultTriggerHandler implements ITriggerHandler
{
    // the service we will call to handle defaulting, validation etc.
    private IDomainService service;

    // optional trigger handler, to call pre-existing code.
    // this allows 1 trigger handler with new patterns/code and
    // a second one with old code that doesn't fit.
    private ITriggerHandler legacyCode;

    public DefaultTriggerHandler(IDomainService service)
    {
        this(service, null);
    }

    /* 
    *   this constructor will instruct the handler to not only call the IdomainService
    *   but also the other trigger handler.
    *
    *   This allows refactoring to this new set of patterns, and putting the old legacy
    *   trigger calls in a 2nd trigger handler; ensuring both new code and old code
    *   get called, without polluting the new code with old stuff (making testing hard).
    */
    public DefaultTriggerHandler(IDomainService service, ITriggerHandler legacyCode)
    {
        this.service = service;
        this.legacyCode = legacyCode;
    }

    public virtual void beforeInsert(List<SObject> newRecords)
    {
        service.setDefaults(newRecords);

        if(legacyCode != null)
            legacyCode.beforeInsert(newRecords);
    }

    public virtual void afterInsert(List<SObject> newRecords)
    {
        List<ValidationError> errors = service.validate(newRecords);
        handleValidationErrors(errors);

        service.processRelatedRecordsOnNew(newRecords);

        if(legacyCode != null)
            legacyCode.afterInsert(newRecords);
    }

    public virtual void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        service.processChangedValues(newRecords.values(), oldRecords);

        if(legacyCode != null)
            legacyCode.beforeUpdate(newRecords, oldRecords);
    }

    public virtual void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        List<ValidationError> errors = service.validate(newRecords.values());
        handleValidationErrors(errors);

        service.processRelatedRecordsOnChange(newRecords.values(), oldRecords);

        if(legacyCode != null)
            legacyCode.afterUpdate(newRecords, oldRecords);
    }
    
    public virtual void beforeDelete(List<SObject> oldRecords)
    {
        if(legacyCode != null)
            legacyCode.beforeDelete(oldRecords);
    }
    public virtual void afterDelete(List<SObject> oldRecords)
    {
        service.processRelatedRecordsOnDelete(oldRecords);
        if(legacyCode != null)
            legacyCode.afterDelete(oldRecords);
    }

    public virtual void afterUnDelete(List<SObject> newRecords)
    {
        if(legacyCode != null)
            legacyCode.afterUnDelete(newRecords);
    }

    protected void handleValidationErrors(List<ValidationError> errors)
    {
        if(errors == null)
            return;
            
        for(ValidationError error: errors)
            error.convertToAddError();
    }
}