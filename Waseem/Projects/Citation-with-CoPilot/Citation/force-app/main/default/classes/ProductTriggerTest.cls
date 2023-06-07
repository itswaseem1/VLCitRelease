@isTest
public class ProductTriggerTest
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private Product2 record = new Product2(Name = 'smith');

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