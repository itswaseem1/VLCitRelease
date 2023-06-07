@isTest
public class AccountTriggerTest
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private Account record = new Account(Name = 'smith');

        public ITriggerHandler getTriggerHandler(IDomainService service)
        {
            return new AccountTriggerHandler(service, null);
        }

        public SObject getRecordToInsert()
        {
            return record;
        }

        public SObject getRecordToUpdate()
        {
            record.Name = 'Jones';
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