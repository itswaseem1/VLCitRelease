public inherited sharing abstract class SecurityCheck
{
    public virtual void canInsert(List<SObject> records)
    {
        if(records.size() > 0)
        {
            failure('insert', records[0].getSObjectType());
        }
    }

    public virtual void canUpdate(List<SObject> records)
    {
        if(records.size() > 0)
        {
            failure('update', records[0].getSObjectType());
        }
    }

    public virtual void canDelete(List<SObject> records)
    {
        if(records.size() > 0)
        {
            failure('delete', records[0].getSObjectType());
        }
    }

    private void failure(String op, SObjectType t)
    {
        String message = 'Cannot ' + op + ' records of type ' + t;
        throw new SecurityException(message);
    }

    class SecurityException extends Exception
    {
    }

    public class AllowAllSecurity extends SecurityCheck
    {
        public override void canInsert(List<SObject> records)
        {
        }

        public override void canUpdate(List<SObject> records)
        {
        }

        public override void canDelete(List<SObject> records)
        {
        }
    }
}