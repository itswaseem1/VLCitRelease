@isTest
public class ContactTriggerTest 
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private Contact record = new Contact(lastName = 'smith');

        public ITriggerHandler getTriggerHandler(IDomainService service)
        {
            return new ContactTriggerHandler(service, null);
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