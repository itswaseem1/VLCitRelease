@isTest
public class DefaultTriggerHandlerTest
{
    @isTest
    private static void beforeInsert_callsServiceBeforeInsert()
    {
        MockService service = new MockService();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service);
        handler.beforeInsert(acts);
        Test.stopTest();

        System.assertEquals(true, service.setDefaultsCalled);
    }

    @isTest
    private static void beforeInsert_callsLegacyHandlerBeforeInsert()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.beforeInsert(acts);
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('beforeInsert'));
    }

    @isTest
    private static void beforeUpdate_callsServiceBeforeUpdate()
    {
        MockService service = new MockService();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};
        TestUtility.setIDs(acts);
        List<Account> oldActs = new List<Account>{new Account(Id = acts[0].id, Name='bob')};

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service);
        handler.beforeUpdate(new Map<Id, SObject>(acts), new Map<Id, SObject>(oldActs));
        Test.stopTest();

        System.assertEquals(true, service.processChangedValuesCalled);
    }

    @isTest
    private static void beforeUpdate_callsLegacyHandlerBeforeUpdate()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};
        TestUtility.setIDs(acts);
        List<Account> oldActs = new List<Account>{new Account(Id = acts[0].id, Name='bob')};


        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.beforeUpdate(new Map<Id, SObject>(acts), new Map<Id, SObject>(oldActs));
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('beforeUpdate'));
    }

    @isTest
    private static void afterInsert_callsServiceAfterInsert()
    {
        MockService service = new MockService();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service);
        handler.afterInsert(acts);
        Test.stopTest();

        System.assertEquals(true, service.validateCalled);
        System.assertEquals(true, service.processRelatedRecordsOnNewCalled);
    }
    
    @isTest
    private static void afterInsert_callsLegacyHandlerAfterInsert()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.afterInsert(acts);
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('afterInsert'));
    }

    @isTest
    private static void afterInsert_whenErrors_recordsHaveErrors()
    {
        List<Account> acts = new List<Account>{new Account(Name='bob'), new Account(Name='fred')};

        ValidationError error = new ValidationError(acts[1], 'BadAct');
        List<ValidationError> errors = new List<ValidationError>{error};

        MockService service = new MockService();
        service.errorsToReturn = errors;

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service);
        handler.afterInsert(acts);
        Test.stopTest();

        System.assertEquals(1, acts[1].getErrors().size());
        System.assertEquals('BadAct', acts[1].getErrors().get(0).getMessage());
    }

    @isTest
    private static void afterUpdate_callsServiceAfterInsert()
    {
        MockService service = new MockService();
       
        List<Account> acts = new List<Account>{new Account(Name='fred')};
        TestUtility.setIDs(acts);
        List<Account> oldActs = new List<Account>{new Account(Id = acts[0].id, Name='bob')};

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service);
        handler.afterUpdate(new Map<Id, SObject>(acts), new Map<Id, SObject>(oldActs));
        Test.stopTest();

        System.assertEquals(true, service.validateCalled);
        System.assertEquals(true, service.processRelatedRecordsOnChangeCalled);
    }
    
    @isTest
    private static void afterUpdate_callsLegacyHandlerAfterUpdate()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> acts = new List<Account>{new Account(Name='fred')};
        TestUtility.setIDs(acts);
        List<Account> oldActs = new List<Account>{new Account(Id = acts[0].id, Name='bob')};


        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.afterUpdate(new Map<Id, SObject>(acts), new Map<Id, SObject>(oldActs));
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('afterUpdate'));
    }

    @isTest
    private static void afterUpdate_whenErrors_recordsHaveErrors()
    {
        List<Account> acts = new List<Account>{new Account(Name='bob'), new Account(Name='fred')};
        TestUtility.setIDs(acts);
        List<Account> oldActs = new List<Account>{new Account(Id = acts[0].id, Name='bob1'), new Account(Id = acts[1].id, Name='fred1')};

        ValidationError error = new ValidationError(acts[1], 'BadAct');
        List<ValidationError> errors = new List<ValidationError>{error};

        MockService service = new MockService();
        service.errorsToReturn = errors;        

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service);
        handler.afterUpdate(new Map<Id, SObject>(acts), new Map<Id, SObject>(oldActs));
        Test.stopTest();

        System.assertEquals(1, acts[1].getErrors().size());
        System.assertEquals('BadAct', acts[1].getErrors().get(0).getMessage());
    }

    @isTest
    private static void beforeDelete_callsLegacyHandlerBeforeDelete()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> oldActs = new List<Account>{new Account(Name='bob')};
        TestUtility.setIDs(oldActs);

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.beforeDelete(oldActs);
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('beforeDelete'));
    }

    @isTest
    private static void afterDelete_callsLegacyHandlerAfterDelete()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> oldActs = new List<Account>{new Account(Name='bob')};
        TestUtility.setIDs(oldActs);

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.afterDelete(oldActs);
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('afterDelete'));
    }

    @isTest
    private static void afterUndelete_callsLegacyHandlerAfterUndelete()
    {
        MockService service = new MockService();
        MockTriggerHandler legacyMock = new MockTriggerHandler();
        
        List<Account> oldActs = new List<Account>{new Account(Name='bob')};
        TestUtility.setIDs(oldActs);

        Test.startTest();
        ITriggerHandler handler = new DefaultTriggerHandler(service, legacyMock);
        handler.afterUnDelete(oldActs);
        Test.stopTest();

        System.assertEquals(true, legacyMock.calledMethods.get('afterUnDelete'));
    }

    class MockService extends DefaultService
    {
        Boolean setDefaultsCalled = false;
        Boolean validateCalled = false;
        Boolean processRelatedRecordsOnNewCalled = false;
        Boolean processRelatedRecordsOnChangeCalled = false;
        Boolean processChangedValuesCalled = false;
        List<ValidationError> errorsToReturn;

        public override void setDefaults(List<SObject> objects)
        {
            setDefaultsCalled  = true;
        }

        public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
        {
            processChangedValuesCalled = true;
        }

        public override List<ValidationError> validate(List<SObject> objects)
        {
            validateCalled = true;
            return errorsToReturn;
        }

        public override void processRelatedRecordsOnNew(List<SObject> newRecords)
        {
            processRelatedRecordsOnNewCalled = true;
        }

        public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
        {
            processRelatedRecordsOnChangeCalled = true;
        }
    }
}