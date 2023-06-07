@isTest
public class UnitOfWorkTest
{
    @isTest private static void whenInsert_inserts()
    {
        Account act = new Account(Name = 'bob');

        UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity()).insertRecords(new List<Account>{act});

        List<Account> dbAct = [SELECT Id FROM Account WHERE Name = 'bob'];

        System.assertEquals(1, dbAct.size());
    }

    @isTest private static void whenUpdate_updates()
    {
        Account act = new Account(Name = 'bob');
        insert act;

        act.Name = 'bob X';

        UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity()).updateRecords(new List<Account>{act});

        List<Account> dbAct = [SELECT Id FROM Account WHERE Name = 'bob X'];

        System.assertEquals(1, dbAct.size());
    }

    @isTest private static void whenDelete_deletes()
    {
        Account act = new Account(Name = 'bob');
        insert act;

        UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity()).deleteRecords(new List<Account>{act});

        List<Account> dbAct = [SELECT Id FROM Account WHERE Name = 'bob'];

        System.assertEquals(0, dbAct.size());
    }

    @isTest private static void whenInsert_checksSecurity()
    {
        Account act = new Account(Name = 'bob');

        MockSecurity security = new MockSecurity();
        UnitOfWork.createInstance(security).insertRecords(new List<Account>{act});

        System.assertEquals(true, security.insertCalled, 'did not check insert security');
    }

    @isTest private static void whenUpdate_checksSecurity()
    {
        Account act = new Account(Name = 'bob');
        insert act;

        MockSecurity security = new MockSecurity();
        UnitOfWork.createInstance(security).updateRecords(new List<Account>{act});

        System.assertEquals(true, security.updateCalled, 'did not check update security');
    }

    @isTest private static void whenUpsert_checksSecurity()
    {
        Account act = new Account(Name = 'bob');

        MockSecurity security = new MockSecurity();
        UnitOfWork.createInstance(security).upsertRecords(new List<Account>{act});

        System.assertEquals(true, security.insertCalled, 'did not check upsert security');
        System.assertEquals(true, security.updateCalled, 'did not check upsert security');
    }

    @isTest private static void whenDelete_checksSecurity()
    {
        Account act = new Account(Name = 'bob');
        insert act;

        MockSecurity security = new MockSecurity();
        UnitOfWork.createInstance(security).deleteRecords(new List<Account>{act});

        System.assertEquals(true, security.deleteCalled, 'did not check delete security');
    }

    public class MockSecurity extends SecurityCheck
    {
        boolean insertCalled = false;
        boolean updateCalled = false;
        boolean deleteCalled = false;

        public override void canInsert(List<SObject> records)
        {
            insertCalled = true;
        }

        public override void canUpdate(List<SObject> records)
        {
            updateCalled = true;
        }

        public override void canDelete(List<SObject> records)
        {
            deleteCalled = true;
        }
    }
}