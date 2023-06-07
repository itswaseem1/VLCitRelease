@isTest
public class TaskTriggerTest 
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private Task record;

        Factory()
        {
            Lead ld = new Lead(lastName = 'smith', company = 'acme');
            insert ld;

            record = new Task(
                ownerId = userinfo.getUserId(),
                whoId = ld.Id,
                Subject = 'Outbound Call',
                Status = 'Completed',
                Priority = 'Normal'
            );
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
            record.Subject = 'Inbound call';
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