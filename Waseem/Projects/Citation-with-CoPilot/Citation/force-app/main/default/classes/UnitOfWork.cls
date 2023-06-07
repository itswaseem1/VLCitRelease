public inherited sharing class UnitOfWork implements IUnitOfWork
{
    // use this instance property to set a test mock or other impl, it will be
    // picked up or a real instance returned. Isolates live code
    // from explicit test behaviour.
    private static IUnitOfWork INSTANCE;
    public static void setInstance(IUnitOfWork impl)
    {
        INSTANCE = impl;
    }
    public static IUnitOfWork createInstance(SecurityCheck security)
    {
        if(INSTANCE != null)
            return INSTANCE;
        return new UnitOfWork(security);
    }

    private SecurityCheck security;
    private UnitOfWork(SecurityCheck security)
    {
        this.security = security;
    }

    public void insertRecords(List<SObject> records)
    {
        security.canInsert(records);
        insert records;
    }

    public void updateRecords(List<SObject> records)
    {
        security.canUpdate(records);
        update records;
    }

    public void upsertRecords(List<SObject> records)
    {
        security.canInsert(records);
        security.canUpdate(records);
        upsert records;
    }

    public void deleteRecords(List<SObject> records)
    {
        security.canDelete(records);
        delete records;
    }
}