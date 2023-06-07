@isTest
public class OpportunityTriggerTest
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private Opportunity record;

        Factory()
        {
            Account act = new Account(Name = 'Bub');
            insert act;

            record = new Opportunity(Name = 'Stuff', 
                                        AccountId = act.Id, 
                                        StageName = 'Renewal Contact Due', 
                                        CloseDate = Date.today()+740);
        }

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
            record.Name = 'More Stuff';
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