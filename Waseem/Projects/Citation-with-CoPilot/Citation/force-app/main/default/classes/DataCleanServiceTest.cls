@isTest
public class DataCleanServiceTest
{

    @isTest
    public static void givenActiveConfig_whenRunAsync_QueuesJob()
    {
        Clean_Archive__mdt config = new Clean_Archive__mdt(Active__c = true, ClassName__c = 'DataCleanService.JobCleaner');

        System.assertEquals(0, [SELECT Id FROM AsyncApexJob].size());

        Test.startTest();
        DataCleanService.runAsync(new List<Clean_Archive__mdt>{config});

        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM AsyncApexJob].size());
    }

    @isTest
    public static void givenNoconfig_whenRunAsync_DoesNotQueueJob()
    {
        System.assertEquals(0, [SELECT Id FROM AsyncApexJob].size());

        Test.startTest();
        DataCleanService.runAsync(new List<Clean_Archive__mdt>());
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM AsyncApexJob].size());
    }

    @isTest
    public static void givenOneJob_whenCleanupCalled_DelegatesToCurrentJob()
    {
        MockCleaner mockCleaner = new MockCleaner();

        Test.startTest();

        DataCleanService service = new DataCleanService(new List<IDataCleaner>{mockCleaner});
        service.cleanUp();

        Test.stopTest();

        System.assertEquals(true, mockCleaner.cleanUpCalled);
    }

    @isTest
    public static void givenManyJobs_whenCleanupCalled_DelegatesToCurrentJob()
    {
        List<MockCleaner> mockCleaners = new List<MockCleaner>{
            new mockCleaner(),
            new MockCleaner()
        };

        Test.startTest();

        DataCleanService service = new DataCleanService(mockCleaners);
        service.cleanUp();

        Test.stopTest();

        System.assertEquals(true, mockCleaners[0].cleanUpCalled);
        System.assertEquals(false, mockCleaners[1].cleanUpCalled);
    }

    @isTest
    public static void givenOneJobWithMoreWork_whenHasMoreCalled_ReturnsTrue()
    {
        MockCleaner mockCleaner = new MockCleaner();
        mockCleaner.moreWork = true;

        Test.startTest();

        DataCleanService service = new DataCleanService(new List<IDataCleaner>{mockCleaner});
        Boolean moreWork = service.hasMore();

        Test.stopTest();

        System.assertEquals(true, moreWork);
    }

    @isTest
    public static void givenOneJobWithNoMoreWork_whenHasMoreCalled_ReturnsFalse()
    {
        MockCleaner mockCleaner = new MockCleaner();
        mockCleaner.moreWork = false;

        Test.startTest();

        DataCleanService service = new DataCleanService(new List<IDataCleaner>{mockCleaner});
        Boolean moreWork = service.hasMore();

        Test.stopTest();

        System.assertEquals(false, moreWork);
    }

    @isTest
    public static void givenManyJobsCurrentFalse_whenCleanupCalled_DelegatesToNextJob()
    {
        List<MockCleaner> mockCleaners = new List<MockCleaner>{
            new mockCleaner(),
            new MockCleaner()
        };

        mockCleaners[0].moreWork = false;
        mockCleaners[1].moreWork = true;

        Test.startTest();

        DataCleanService service = new DataCleanService(mockCleaners);
        Boolean moreWork = service.hasMore();

        Test.stopTest();

        System.assertEquals(true, moreWork);
    }

    @isTest
    public static void givenManyJobsCurrentFalse_whenCleanupCalled_NextCleanUpGoesToNextJob()
    {
        List<MockCleaner> mockCleaners = new List<MockCleaner>{
            new mockCleaner(),
            new MockCleaner()
        };

        mockCleaners[0].moreWork = false;
        mockCleaners[1].moreWork = true;

        // service maniplulates list, so copy elements into new list
        List<MockCleaner> listForService = new List<MockCleaner>{
            mockCleaners[0],
            mockCleaners[1]
        };

        Test.startTest();

        
        DataCleanService service = new DataCleanService(listForService);
        service.hasMore();
        service.cleanUp();

        Test.stopTest();

        System.assertEquals(false, mockCleaners[0].cleanUpCalled);
        System.assertEquals(true, mockCleaners[1].cleanUpCalled);
    }

    @isTest
    private static void givenJobOlderThanRetentionPeriod_whenCleanUpCalled_thenDeletesRecord()
    {
        // ffbc__RecordId__c = mandatory field. 
        // test can set the create/lastmodifed date
        Date oldDate = Date.today() - 100;
        ffbc__Job__c record = new ffbc__Job__c(CreatedDate = oldDate, 
                                                lastModifiedDate = oldDate,
                                                ffbc__RecordId__c = TestUtility.getFakeId(Task.SObjectType));
        insert record;

        Clean_Archive__mdt config = new Clean_Archive__mdt(Retention_Period__c = 10);

        DataCleanService.JobCleaner cleaner = new DataCleanService.JobCleaner();
        cleaner.setConfig(config);

        Test.startTest();
        cleaner.cleanUp();
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM ffbc__Job__c].size());
    }

    @isTest
    private static void givenJobNewerThanRetentionPeriod_whenCleanUpCalled_thenIgnoresRecord()
    {
        // ffbc__RecordId__c = mandatory field. 
        // test can set the create/lastmodifed date
        Date oldDate = Date.today() - 1;
        ffbc__Job__c record = new ffbc__Job__c(CreatedDate = oldDate, 
                                                lastModifiedDate = oldDate,
                                                ffbc__RecordId__c = TestUtility.getFakeId(Task.SObjectType));
        insert record;

        Clean_Archive__mdt config = new Clean_Archive__mdt(Retention_Period__c = 10);

        DataCleanService.JobCleaner cleaner = new DataCleanService.JobCleaner();
        cleaner.setConfig(config);

        Test.startTest();
        cleaner.cleanUp();
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM ffbc__Job__c].size());
    }

    @isTest
    private static void givenJobOlderThanRetentionPeriod_whenHasMoreCalled_thenReturnsTrue()
    {
        // ffbc__RecordId__c = mandatory field. 
        // test can set the create/lastmodifed date
        Date oldDate = Date.today() - 100;
        ffbc__Job__c record = new ffbc__Job__c(CreatedDate = oldDate, 
                                                lastModifiedDate = oldDate,
                                                ffbc__RecordId__c = TestUtility.getFakeId(Task.SObjectType));
        insert record;

        Clean_Archive__mdt config = new Clean_Archive__mdt(Retention_Period__c = 10);

        DataCleanService.JobCleaner cleaner = new DataCleanService.JobCleaner();
        cleaner.setConfig(config);

        Test.startTest();
        Boolean more = cleaner.hasMore();
        Test.stopTest();

        System.assertEquals(true, more);
    }

    @isTest
    private static void givenJobNewerThanRetentionPeriod_whenHasMoreCalled_thenReturnsFalse()
    {
        // ffbc__RecordId__c = mandatory field. 
        // test can set the create/lastmodifed date
        Date oldDate = Date.today() - 1;
        ffbc__Job__c record = new ffbc__Job__c(CreatedDate = oldDate, 
                                                lastModifiedDate = oldDate,
                                                ffbc__RecordId__c = TestUtility.getFakeId(Task.SObjectType));
        insert record;

        Clean_Archive__mdt config = new Clean_Archive__mdt(Retention_Period__c = 10);

        DataCleanService.JobCleaner cleaner = new DataCleanService.JobCleaner();
        cleaner.setConfig(config);

        Test.startTest();
        Boolean more = cleaner.hasMore();
        Test.stopTest();

        System.assertEquals(false, more);
    }

    class MockCleaner implements IDataCleaner
    {
        Boolean cleanUpCalled = false;
        Boolean moreWork = false;

        public void cleanUp()
        {
            cleanUpCalled = true;
        }

        public Boolean hasMore()
        {
            return moreWork;
        }
    }
}