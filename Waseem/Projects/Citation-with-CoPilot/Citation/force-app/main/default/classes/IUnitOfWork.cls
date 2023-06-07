public interface IUnitOfWork
{
    void insertRecords(List<SObject> records);

    void updateRecords(List<SObject> records);

    void upsertRecords(List<SObject> records);

    void deleteRecords(List<SObject> records);
}