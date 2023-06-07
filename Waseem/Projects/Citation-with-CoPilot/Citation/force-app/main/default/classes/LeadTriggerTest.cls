@isTest
public class LeadTriggerTest 
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private Lead record = new Lead(lastName = 'smith', company = 'acme');

        public ITriggerHandler getTriggerHandler(IDomainService service)
        {
            return new DefaultTriggerHandler(service, null);
        }

        public SObject getRecordToInsert()
        {
            return record;
        }

        public SObject getRecordToUpdate()
        {
            record.lastName = 'Jones';
            return record;
        }

        public SObject getRecordToDelete()
        {
            return record;
        }

        public SObject getRecordToUndelete()
        {
            return record;
        }
    }

    @isTest
    private static void testFramework()
    {
        TriggerFrameworkTest.testDMLToService(new Factory());
    }
}