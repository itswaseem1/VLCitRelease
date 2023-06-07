@isTest
public class TriggerFrameworkTest
{
    public interface IFactory
    {
        ITriggerHandler getTriggerHandler(IDomainService service);
        SObject getRecordToInsert();
        SObject getRecordToUpdate();
        SObject getRecordToDelete();
        SObject getRecordToUndelete();
    }

    public static void testDMLToService(IFactory factory)
    {
        testInsert(factory);
        testUpdate(factory);
        testDelete(factory);
    }

    private static void testInsert(IFactory factory)
    {
        SObject record = factory.getRecordToInsert();

        MockDomainService service = new MockDomainService();
        ITriggerHandler handler = factory.getTriggerHandler(service);
        TriggerHandlerFactory.registerInstance(record.getSObjectType(), handler);

        insert record;

        System.assertEquals(true, service.calledMethods.get('setDefaults'));
        System.assertEquals(true, service.calledMethods.get('validate'));
        System.assertEquals(true, service.calledMethods.get('processRelatedRecordsOnNew'));
    }

    private static void testUpdate(IFactory factory)
    {
        SObject record = factory.getRecordToUpdate();

        MockDomainService service = new MockDomainService();
        ITriggerHandler handler = factory.getTriggerHandler(service);
        TriggerHandlerFactory.registerInstance(record.getSObjectType(), handler);

        update record;

        System.assertEquals(null, service.calledMethods.get('setDefaults'));
        System.assertEquals(null, service.calledMethods.get('processRelatedRecordsOnNew'));

        System.assertEquals(true, service.calledMethods.get('validate'));
        System.assertEquals(true, service.calledMethods.get('processChangedValues'));
        System.assertEquals(true, service.calledMethods.get('processRelatedRecordsOnChange'));
    }

    private static void testDelete(IFactory factory)
    {
        SObject record = factory.getRecordToDelete();

        MockDomainService service = new MockDomainService();
        ITriggerHandler handler = factory.getTriggerHandler(service);
        TriggerHandlerFactory.registerInstance(record.getSObjectType(), handler);

        delete record;

        System.assertEquals(true, service.calledMethods.get('processRelatedRecordsOnDelete'));

        System.assertEquals(null, service.calledMethods.get('setDefaults'));
        System.assertEquals(null, service.calledMethods.get('processRelatedRecordsOnNew'));

        System.assertEquals(null, service.calledMethods.get('validate'));
        System.assertEquals(null, service.calledMethods.get('processChangedValues'));
        System.assertEquals(null, service.calledMethods.get('processRelatedRecordsOnChange'));
    }

}