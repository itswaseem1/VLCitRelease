@isTest
public class NVMTriggerTest
{
class Factory implements TriggerFrameworkTest.IFactory
    {
        private NVMContactWorld__InteractionEventNote__c record;

        Factory()
        {
            NVMContactWorld__InteractionEvent__c event = new NVMContactWorld__InteractionEvent__c();
            event.NVMContactWorld__Type__c = 'deliver';
            event.NVMContactWorld__TimeStamp__c = system.now();
            event.NVMContactWorld__IndexedCallObjectIdentifier__c = 'asdff';
            insert event;

            record = new NVMContactWorld__InteractionEventNote__c(NVMContactWorld__Event__c = event.Id);
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
            record.NVMContactWorld__Detail__c = 'More Stuff';
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