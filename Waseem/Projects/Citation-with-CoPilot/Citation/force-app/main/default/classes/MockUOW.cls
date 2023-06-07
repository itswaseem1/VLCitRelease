/*
* this is a test Class utility used for Mocking the DML
*/
@isTest
public class MockUOW implements IUnitOfWork
{
    public Map<SObjectType, List<SObject>> recordMap = new Map<SObjectType,List<SObject>>();

    public List<SObject> getRecords(SObjectType type)
    {
        List<SObject> ret = recordMap.get(type);
        if(ret == null)
            ret = new List<SObject>();

        return ret;
    }

    private void captureRecords(List<SObject> records)
    {
        if(records == null || records.isEmpty())
            return;
        
        SobjectType type = records[0].getSobjectType();
        List<SObject> recs = recordMap.get(type);
        if(recs == null)
        {
            recs = new List<SObject>();
            recordMap.put(type, recs);
        }
        recs.addAll(records);
    }

    public void insertRecords(List<SObject> records)
    {
        TestUtility.setIDs(records);
        captureRecords(records);
    }

    public void updateRecords(List<SObject> records)
    {
        captureRecords(records);
    }

    public void upsertRecords(List<SObject> records)
    {
        captureRecords(records);
    }

    public void deleteRecords(List<SObject> records)
    {
        captureRecords(records);
    }
}