@isTest
public class AccountServiceTest
{
    @isTest
    private static void whenwRenewalDateChanges_captureOldDate()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Renewal_Date__c = Date.today().addDays(-30)),

            new Account(Renewal_Date__c = Date.today().addDays(-20))
        };
        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id,
                        Renewal_Date__c = Date.today()),

            new Account(Id = oldActs[1].Id,
                        Renewal_Date__c = Date.today())
        };

        MockSelector selector = new MockSelector();  

        Test.startTest();
        new AccountService(selector).processChangedValues(newActs, new Map<Id,Account>(oldActs));
        Test.stopTest();

        System.assertEquals(oldActs[0].Renewal_Date__c, newActs[0].Old_Renewal_Date__c);
        System.assertEquals(oldActs[1].Renewal_Date__c, newActs[1].Old_Renewal_Date__c);
    }

    @isTest
    private static void whenwRenewalDoesNotChange_OldDateNotChanged()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Renewal_Date__c = Date.today().addDays(-30)),

            new Account(Renewal_Date__c = Date.today().addDays(-20))
        };
        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id,
                        Renewal_Date__c = Date.today().addDays(-30)),

            new Account(Id = oldActs[1].Id,
                        Renewal_Date__c = Date.today().addDays(-20))
        };

        MockSelector selector = new MockSelector();  

        Test.startTest();
        new AccountService(selector).processChangedValues(newActs, new Map<Id,Account>(oldActs));
        Test.stopTest();

        System.assertEquals(null, newActs[0].Old_Renewal_Date__c);
        System.assertEquals(null, newActs[1].Old_Renewal_Date__c);
    }

	@isTest
    private static void whenRemainingCoreContractMonthChanges_SetHasCoreContratOrOpp()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name='Test', CoreCitationContractMonths__c=2),
            new Account(Name='Test1', CoreCitationContractMonths__c=1)
        };
        TestUtility.setIDs(oldActs);
        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id,CoreCitationContractMonths__c = 1),
            new Account(Id = oldActs[1].Id,CoreCitationContractMonths__c = 0)
        };
        MockSelector selector = new MockSelector();  	
        Test.startTest();	
        new AccountService(selector).processChangedValues(newActs, new Map<Id,Account>(oldActs));	
        Test.stopTest();	
        System.assertEquals(true, newActs[0].Open_Core_Opportunities__c);
        System.assertEquals(false, newActs[1].Open_Core_Opportunities__c);
    }
    
    @isTest
    private static void whenHasCoreContractOrOppChanges_UpdateRelatedContacts()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred', Open_Core_Opportunities__c=true),
            new Account(Name = 'Mary', Open_Core_Opportunities__c=false)
        };
        TestUtility.setIDs(oldActs);
		
        List<Contact> contacts = new List<Contact>{
            new Contact(lastName = 'Smith', AccountId=oldActs[0].Id, Open_Core_Opportunities__c='True'),
            new Contact(lastName = 'Jones', AccountId=oldActs[0].Id, Open_Core_Opportunities__c='False'),
            new Contact(lastName = 'Hales', AccountId=oldActs[1].Id,  Open_Core_Opportunities__c='True'),
            new Contact(lastName = 'Jhonny', AccountId=oldActs[1].Id,  Open_Core_Opportunities__c='False')
        };
		TestUtility.setIDs(contacts);
        
        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Open_Core_Opportunities__c=false),
            new Account(Id = oldActs[1].Id, Name = 'Mary', Open_Core_Opportunities__c=true)
        };
		
        Map<Id, List<Contact>> relatedContactsMap = new Map<Id, List<Contact>>();
        relatedContactsMap.put(newActs[0].Id, new List<Contact>{contacts[0], contacts[1]});
        relatedContactsMap.put(newActs[1].Id, new List<Contact>{contacts[2], contacts[3]});
        
        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.accIdContactsMap = relatedContactsMap;
        MockUOW uow = new MockUOW();	
        UnitOfWork.setInstance(uow);		
        Test.startTest();		
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));		
        Test.stopTest();		
        System.assertEquals(2, uow.getRecords(Contact.SObjectType).size());		
        Contact objCon1 = (Contact)uow.getRecords(Contact.SObjectType)[0];
        System.assertEquals(objCon1.Open_Core_Opportunities__c,String.valueOf(newActs[0].Open_Core_Opportunities__c).capitalize());
        Contact objCon2 = (Contact)uow.getRecords(Contact.SObjectType)[1];
        System.assertEquals(objCon2.Open_Core_Opportunities__c,String.valueOf(newActs[1].Open_Core_Opportunities__c).capitalize());
    }
    
    @isTest
    private static void whenwPartnerShipDateCheckOld_CreateTask_UpdateDate()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred', 
                        BDC_del__c = UserInfo.getUserId() , 
                        LastParternshipCheckIn__c = Date.today().addDays(-30)),

            new Account(Name = 'Mary', 
                        BDC_del__c = UserInfo.getUserId() , 
                        LastParternshipCheckIn__c = Date.today().addDays(-30))
        };
        TestUtility.setIDs(oldActs);

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.recordType = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
        selector.partnershipAccounts = oldActs;

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).createPartnershipCall(new Map<Id,Account>(oldActs).keySet());
        Test.stopTest();

        System.assertEquals(2, uow.getRecords(Task.SObjectType).size()); 
        System.assertEquals(2, uow.getRecords(Account.SObjectType).size());

        List<Account> acts = (List<Account>)uow.getRecords(Account.SObjectType);
        for(Account act: acts)
        {
            System.assertEquals(Date.today(), act.LastParternshipCheckIn__c);
        }

        List<Task> tasks = (List<Task>)uow.getRecords(Task.SObjectType);
        for(Task task: tasks)
        {
            System.assertEquals(UserInfo.getUserId(), task.OwnerId);
            System.assertEquals(Date.today().addDays(7), task.ActivityDate);
            System.assertEquals('Introducer Check In', task.Subject);
            System.assertEquals(selector.recordType, task.RecordTypeID);
        }

        Set<Id> actIds = new Map<Id,Account>(oldActs).keySet();
        for(Task task: tasks)
        {
            actIds.remove(task.WhatId);
        }
        System.assertEquals(0, actIds.size(), 'not generated tasks for : ' + actIds);
    }

    @isTest
    private static void whenNoPartnershipAccountsToUpdate_DoesNotCreateTasks()
    {
        List<Account> oldActs = new List<Account>();

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.partnershipAccounts = oldActs;

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).createPartnershipCall(new Map<Id,Account>(oldActs).keySet());
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Task.SObjectType).size()); 
    }

    @isTest
    private static void whenNewAccountHasAccountant_CreateProspect()
    {
        List<Account> newActs = new List<Account>{
            new Account(Name = 'Fred', Accountant_Name__c = 'Test 1'),
            new Account(Name = 'Mary', Accountant_Name__c = 'Test 2')
        };

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.recordType = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnNew(newActs);
        Test.stopTest();

        System.assertEquals(2, uow.getRecords(Lead.SObjectType).size()); 

        Lead prospect = (Lead)uow.getRecords(Lead.SObjectType)[0];
        System.assertEquals('Test 1', prospect.LastName);
        System.assertEquals('Open', prospect.Status);
        System.assertEquals('Potential Introducer', prospect.PartnerType__c);
        System.assertEquals(selector.recordType, prospect.RecordTypeID);
    }

    @isTest
    private static void whenNewAccountDoesNotHasAccountant_DoesNotCreateProspect()
    {
        List<Account> newActs = new List<Account>{
            new Account(Name = 'Fred'),
            new Account(Name = 'Mary')
        };

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.recordType = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnNew(newActs);
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Lead.SObjectType).size()); 
    }

    @isTest
    private static void whenUpdateAccountHasAccountantChangeFromNull_CreateProspect()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred'),
            new Account(Name = 'Mary', Accountant_Name__c = 'Test 2')
        };

        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Accountant_Name__c = 'Test 1'),
            new Account(Id = oldActs[1].Id, Name = 'Mary', Accountant_Name__c = 'Test 3')
        };

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.recordType = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(Lead.SObjectType).size()); 

        Lead prospect = (Lead)uow.getRecords(Lead.SObjectType)[0];
        System.assertEquals(oldActs[0].Id, prospect.Referred_By_Company_lookup__c);
        System.assertEquals('Test 1', prospect.LastName);
        System.assertEquals('Open', prospect.Status);
        System.assertEquals('Potential Introducer', prospect.PartnerType__c);
        System.assertEquals(selector.recordType, prospect.RecordTypeID);
    }

    @isTest
    private static void whenUpdateAccountHasNoAccountantChangeFromNull_DoesNotCreateProspect()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred', Accountant_Name__c = 'Test 1'),
            new Account(Name = 'Mary', Accountant_Name__c = 'Test 2')
        };

        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Accountant_Name__c = 'Test 3'),
            new Account(Id = oldActs[1].Id, Name = 'Mary', Accountant_Name__c = 'Test 2')
        };

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.recordType = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Lead.SObjectType).size()); 
    }

    @isTest
    private static void whenUpdateAccountHasMixedAccountantChange_CreateProspectForCorrectRecord()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred'),
            new Account(Name = 'Mary', Accountant_Name__c = 'Test 2')
        };

        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Accountant_Name__c = 'Test 1'),
            new Account(Id = oldActs[1].Id, Name = 'Mary', Accountant_Name__c = 'Test 2')
        };

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.recordType = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(Lead.SObjectType).size()); 

        Lead prospect = (Lead)uow.getRecords(Lead.SObjectType)[0];
        System.assertEquals(oldActs[0].Id, prospect.Referred_By_Company_lookup__c);
        System.assertEquals('Test 1', prospect.LastName);
        System.assertEquals('Open', prospect.Status);
        System.assertEquals('Potential Introducer', prospect.PartnerType__c);
        System.assertEquals(selector.recordType, prospect.RecordTypeID);
    }

    @isTest
    private static void whenSpecifiedFieldChanges_createHistoryRecord()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred'),
            new Account(Name = 'Mary')
        };
        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Reason_1__c = 'Test'),
            new Account(Id = oldActs[1].Id, Name = 'Mary', Reason_2__c = 'Another Test')
        };

        Set<String> fieldsToTrack = new Set<String>{'Reason_1__c', 'Reason_2__c'};

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.fieldsToTrack = fieldsToTrack;

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));
        Test.stopTest();

        System.assertEquals(2, uow.getRecords(Account_History__c.SObjectType).size()); 

        Account_History__c history = (Account_History__c)uow.getRecords(Account_History__c.SObjectType)[0];
        System.assertEquals(oldActs[0].Id, history.Account__c);
        System.assertEquals('Test', history.New_Value__c);
        System.assertEquals(null, history.Old_Value__c);

        history = (Account_History__c)uow.getRecords(Account_History__c.SObjectType)[1];
        System.assertEquals(oldActs[1].Id, history.Account__c);
        System.assertEquals('Another Test', history.New_Value__c);
        System.assertEquals(null, history.Old_Value__c);
    }

    @isTest
    private static void whenNoSpecifiedFieldChanges_doesNotCreateHistoryRecord()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred'),
            new Account(Name = 'Mary')
        };
        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Reason_1__c = 'Test'),
            new Account(Id = oldActs[1].Id, Name = 'Mary', Reason_2__c = 'Another Test')
        };

        Set<String> fieldsToTrack = new Set<String>{'Reason_3__c'};

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.fieldsToTrack = fieldsToTrack;

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Account_History__c.SObjectType).size()); 
    }

    @isTest
    private static void whenSpecifiedFieldsNotChanged_doesNotCreateHistoryRecord()
    {
        List<Account> oldActs = new List<Account>{
            new Account(Name = 'Fred', Reason_1__c = 'Test'),
            new Account(Name = 'Mary')
        };
        TestUtility.setIDs(oldActs);

        List<Account> newActs = new List<Account>{
            new Account(Id = oldActs[0].Id, Name = 'Fred', Reason_1__c = 'Test'),
            new Account(Id = oldActs[1].Id, Name = 'Mary')
        };

        Set<String> fieldsToTrack = new Set<String>{'Reason_1__c', 'Reason_2__c'};

        MockSelector selector = new MockSelector();  // set our selector to return fields we specify.
        selector.fieldsToTrack = fieldsToTrack;

        MockUOW uow = new MockUOW();                // set the uow mock to avoid DB and allow us to capture.
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Account_History__c.SObjectType).size()); 
    }

    @isTest
    public static void whenSegmentChanges_TaskUpdated()
    {
        // new account with silver status
        List<Account> newActs = new List<Account>();
        newActs.add(new Account(CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 200));
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newActs);
        TestUtility.setIDs(newActs);

        System.assertEquals('Silver', newActs[0].S__c, results);

        // old account with bronze status
        List<Account> oldActs = new List<Account>();
        oldActs.add(new Account(Id = newActs[0].Id, CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 10));
        Formula.recalculateFormulas(oldActs);

        System.assertEquals('Bronze', oldActs[0].S__c);
        
        // task to be updated.
        Map<Id, List<Task>> tasks = new Map<Id, List<Task>>();
        Task t = new Task();
        tasks.put(newActs[0].Id, new List<Task>{t});

        // prevent database stuff, capture records.
        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();

        // mock selector to return task above.
        MockSelector selector = new MockSelector();
        selector.tasks = tasks;

        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));

        Test.stopTest();

        System.assertEquals(newActs[0].S__c, t.Segmentation_Status__c);
        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
    }

    @isTest
    public static void whenBulkSegmentChanges_AllTaskUpdated()
    {
        // new account with silver status
        List<Account> newActs = new List<Account>();
        newActs.add(new Account(CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 200));
        newActs.add(new Account(CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 600));
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newActs);
        TestUtility.setIDs(newActs);

        // old account with bronze status
        List<Account> oldActs = new List<Account>();
        oldActs.add(new Account(Id = newActs[0].Id, CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 600));
        oldActs.add(new Account(Id = newActs[1].Id, CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 10));
        Formula.recalculateFormulas(oldActs);
        
        // task to be updated.
        Map<Id, List<Task>> tasks = new Map<Id, List<Task>>();
        Task t1 = new Task();
        Task t0 = new Task();
        tasks.put(newActs[0].Id, new List<Task>{t0});
        tasks.put(newActs[1].Id, new List<Task>{t1});

        // prevent database stuff, capture records.
        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();

        // mock selector to return task above.
        MockSelector selector = new MockSelector();
        selector.tasks = tasks;

        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));

        Test.stopTest();

        System.assertEquals(newActs[0].S__c, t0.Segmentation_Status__c);
        System.assertEquals(newActs[1].S__c, t1.Segmentation_Status__c);
        System.assertEquals(2, uow.getRecords(Task.SObjectType).size());
    }


    @isTest
    public static void whenSegmentDoesNotChange_TaskNotUpdated()
    {
        // new account with silver status
        List<Account> newActs = new List<Account>();
        newActs.add(new Account(CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 200));
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newActs);
        TestUtility.setIDs(newActs);

        System.assertEquals('Silver', newActs[0].S__c, results);

        // old account with bronze status
        List<Account> oldActs = new List<Account>();
        oldActs.add(new Account(Id = newActs[0].Id, CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 200));
        Formula.recalculateFormulas(oldActs);

        System.assertEquals('Silver', oldActs[0].S__c);
        
        // task to be updated.
        Map<Id, List<Task>> tasks = new Map<Id, List<Task>>();
        Task t = new Task();
        tasks.put(newActs[0].Id, new List<Task>{t});

        // prevent database stuff, capture records.
        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();

        // mock selector to return task above.
        MockSelector selector = new MockSelector();
        selector.tasks = tasks;

        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));

        Test.stopTest();

        System.assertEquals(null, t.Segmentation_Status__c);
        System.assertEquals(0, uow.getRecords(Task.SObjectType).size());

    }

    @isTest
    public static void whenSomeSegementationChanges_OnlyRelevantTaskUpdated()
    {
        // new account with silver status
        List<Account> newActs = new List<Account>();
        newActs.add(new Account(CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 200));
        newActs.add(new Account(CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 600)); //won't change
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(newActs);
        TestUtility.setIDs(newActs);

        // old account with bronze status
        List<Account> oldActs = new List<Account>();
        oldActs.add(new Account(Id = newActs[0].Id, CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 600));
        oldActs.add(new Account(Id = newActs[1].Id, CurrencyIsoCode='GBP', PACV__c = 0, MACV__c = 600));
        Formula.recalculateFormulas(oldActs);
        
        // task to be updated.
        Map<Id, List<Task>> tasks = new Map<Id, List<Task>>();
        Task t1 = new Task();
        Task t0 = new Task();
        tasks.put(newActs[0].Id, new List<Task>{t0});
        tasks.put(newActs[1].Id, new List<Task>{t1});

        // prevent database stuff, capture records.
        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();

        // mock selector to return task above.
        MockSelector selector = new MockSelector();
        selector.tasks = tasks;

        new AccountService(selector).processRelatedRecordsOnChange(newActs, new Map<Id, Account>(oldActs));

        Test.stopTest();

        System.assertEquals(newActs[0].S__c, t0.Segmentation_Status__c);
        System.assertEquals(null, t1.Segmentation_Status__c);
        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());

    }

    @isTest
    private static void testSelector_FindsTaskForAccount()
    {
        Account act  = new Account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
        insert act;

        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = Case.SobjectType.getDescribe().getRecordTypeInfosByID();
        Id caseType = recordTypeInfos.values().get(0).getRecordTypeId();

        Case c = new Case(AccountId = act.Id, RecordTypeId = caseType);
        insert c;

        Id taskType = new RecordTypeSelector().getRecordTypeId(Task.SObjectType, 'Service_360_Default');
        Task t = new Task(WhatId = c.Id, RecordTypeId = taskType);
        insert t;

        AccountService.AccountServiceSelector selector = new AccountService.AccountServiceSelector();
        Map<Id, List<Task>> results = selector.getTasksWithCaseRecordTypes(new List<ACcount>{act}, new List<Id>{caseType});

        System.assertEquals(1, results.get(act.Id).size());
        System.assertEquals(t.Id, results.get(act.Id).get(0).Id);
    }

    @isTest
    private static void testSelectorBulk_FindsTasksForAccounts()
    {
        Account act0  = new Account(name='test0',c2g__CODAInvoiceEmail__c = 'test0@test.com') ; // 2 cases, 2 tasks
        Account act1  = new Account(name='test1',c2g__CODAInvoiceEmail__c = 'test1@test.com') ; // 1 case, 3 tasks
        Account act2  = new Account(name='test2',c2g__CODAInvoiceEmail__c = 'test2@test.com') ; // 1 case, no tasks
        insert new List<Account>{act0, act1, act2};

        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = Case.SobjectType.getDescribe().getRecordTypeInfosByID();
        Id caseType = recordTypeInfos.values().get(0).getRecordTypeId();

        Case c0 = new Case(AccountId = act0.Id, RecordTypeId = caseType);
        Case c1 = new Case(AccountId = act0.Id, RecordTypeId = caseType);
        Case c2 = new Case(AccountId = act1.Id, RecordTypeId = caseType);
        Case c3 = new Case(AccountId = act2.Id, RecordTypeId = caseType);
        insert new List<Case>{c0, c1, c2, c3};

        Id taskType = new RecordTypeSelector().getRecordTypeId(Task.SObjectType, 'Service_360_Default');
        Task t0 = new Task(WhatId = c0.Id, RecordTypeId = taskType);
        Task t1 = new Task(WhatId = c1.Id, RecordTypeId = taskType);
        Task t2 = new Task(WhatId = c2.Id, RecordTypeId = taskType);
        Task t3 = new Task(WhatId = c2.Id, RecordTypeId = taskType);
        Task t4 = new Task(WhatId = c2.Id, RecordTypeId = taskType);
        insert new List<Task>{t0, t1, t2, t3, t4};

        AccountService.AccountServiceSelector selector = new AccountService.AccountServiceSelector();
        Map<Id, List<Task>> results = selector.getTasksWithCaseRecordTypes(new List<ACcount>{act0, act1, act2}, new List<Id>{caseType});

        System.assertEquals(2, results.get(act0.Id).size());
        System.assertEquals(3, results.get(act1.Id).size());
        System.assertEquals(0, results.get(act2.Id).size());
    }

    @isTest
    private static void testSelector_FindsNoCaseForAccount()
    {
        Account act  = new Account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
        insert act;

        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = Case.SobjectType.getDescribe().getRecordTypeInfosByID();
        Id caseType = recordTypeInfos.values().get(0).getRecordTypeId();

        Case c = new Case(AccountId = act.Id);  // no type, so no join to task
        insert c;

        Id taskType = new RecordTypeSelector().getRecordTypeId(Task.SObjectType, 'Service_360_Default');
        Task t = new Task(WhatId = c.Id, RecordTypeId = taskType);
        insert t;

        AccountService.AccountServiceSelector selector = new AccountService.AccountServiceSelector();
        Map<Id, List<Task>> results = selector.getTasksWithCaseRecordTypes(new List<ACcount>{act}, new List<Id>{caseType});

        System.assertEquals(0, results.get(act.Id).size());
    }

    @isTest
    private static void testSelector_FindsNoTaskForAccount()
    {
        Account act  = new Account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
        insert act;

        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = Case.SobjectType.getDescribe().getRecordTypeInfosByID();
        Id caseType = recordTypeInfos.values().get(0).getRecordTypeId();

        Case c = new Case(AccountId = act.Id, RecordTypeId = caseType);
        insert c;

        Id taskType = new RecordTypeSelector().getRecordTypeId(Task.SObjectType, 'Service_360_Default');
        Task t = new Task(WhatId = c.Id);  // not correct type, so won't
        insert t;

        AccountService.AccountServiceSelector selector = new AccountService.AccountServiceSelector();
        Map<Id, List<Task>> results = selector.getTasksWithCaseRecordTypes(new List<ACcount>{act}, new List<Id>{caseType});

        System.assertEquals(0, results.get(act.Id).size());
    }
	
    @isTest
    private static void testSelector_FindRelatedContactsForAccount()
    {
        Account act  = new Account(name='test');
        insert act;

        List<Contact> contacts = new List<Contact>{
            new Contact(firstName = 'bob', lastName = 'smith', AccountId = act.Id),
            new Contact(firstName = 'robert', lastName = 'smith', AccountId = act.Id)
        };
        insert contacts;
        
        Map<Id,List<Contact>> response = new AccountService.AccountServiceSelector().getAccountRelatedContacts(new List<Account>{act});
        
        System.assertEquals(2, response.get(act.Id).size());
    }
    
    @isTest
    private static void testSelector_NoContactsForAccount()
    {
        Account act  = new Account(name='test');
        insert act;

        Map<Id,List<Contact>> response = new AccountService.AccountServiceSelector().getAccountRelatedContacts(new List<Account>{act});
        
        System.assertEquals(0, response.size());
    }
    
    @isTest
    private static void wheniHASCOManagerAddedInsertTest()
    {
        Id iHASCOManagerId= TestUtility.getFakeId(User.SObjectType);
        
        List<Account> newActs = new List<Account>{
            new Account(iHASCO_Account_Manager__c =iHASCOManagerId ,iHASCO_Client__c = False),
            new Account(iHASCO_Account_Manager__c =iHASCOManagerId ,iHASCO_Client__c = False)                 
        };

        MockSelector selector = new MockSelector();  

        Test.startTest();
        new AccountService(selector).setDefaults(newActs);
        Test.stopTest();

        System.assertEquals(True, newActs[0].iHASCO_Client__c);
        System.assertEquals(True, newActs[1].iHASCO_Client__c);
    }
    
    @isTest
    private static void wheniHASCOManagerNotAddedInsertTest()
    {
        List<Account> newActs = new List<Account>{
            new Account(iHASCO_Account_Manager__c =NULL ,iHASCO_Client__c = False),
            new Account(iHASCO_Account_Manager__c =NULL ,iHASCO_Client__c = False)                 
        };

        MockSelector selector = new MockSelector();  

        Test.startTest();
        new AccountService(selector).setDefaults(newActs);
        Test.stopTest();

        System.assertEquals(False, newActs[0].iHASCO_Client__c);
        System.assertEquals(False, newActs[1].iHASCO_Client__c);
    }
	
    @isTest
    private static void testSelector_FindExpectedRelatedServiceDeliveryPlansForAccount()
    {
        Account accountforTest = new Account(name='accountforTest');
        insert accountforTest;
        
        Service_Delivery_Plan__c serviceDeliveryPlanforTest = new Service_Delivery_Plan__c(Name = 'Citation SDP accountforTest', Business__c = 'Citation', Account__c = accountforTest.Id);
        insert serviceDeliveryPlanforTest;
        
        List<Service_Delivery_Plan__c> serviceDeliveryPlanReturned = new AccountService.AccountServiceSelector().getAccountswithServiceDeliveryPlan(new Set<Id>{accountforTest.Id});
        
        System.assertEquals(1, serviceDeliveryPlanReturned.size(), 'Service Delivery Plan didn\'t Return or Returned more than Expected ' + serviceDeliveryPlanReturned.size());
        System.assertEquals(accountforTest.Id, serviceDeliveryPlanReturned[0].Account__c, 'Different Accounts Service Delivery Plans Returned');
    }
    
    @isTest
    private static void testSelector_FindNoRelatedServiceDeliveryPlansForAccount()
    {
        Account accountforTest = new Account(name='accountforTest');
        insert accountforTest;
        
        Service_Delivery_Plan__c serviceDeliveryPlanforTest = new Service_Delivery_Plan__c(Name = 'accountforTest', Business__c = 'Citation', Account__c = accountforTest.Id);
        insert serviceDeliveryPlanforTest;
        
        List<Service_Delivery_Plan__c> serviceDeliveryPlanReturned = new AccountService.AccountServiceSelector().getAccountswithServiceDeliveryPlan(new Set<Id>{accountforTest.Id});
        
        System.assertEquals(0, serviceDeliveryPlanReturned.size(), 'Service Delivery Plan Returned even though Name doesn\'t Start with Citation SDP');
    }
    
    @isTest
    private static void whenAccountNameUpdated_VerifySDPNamethatStartsWithCitationSDP(){
        List<Account> accountforTest = new List<Account>{ new Account(Name = 'accountforTest') };	
        TestUtility.setIDs(accountforTest);	
        
        List<Service_Delivery_Plan__c> serviceDeliveryPlanforTest = new List<Service_Delivery_Plan__c>();	
        Service_Delivery_Plan__c  serviceDeliveryPlanforTestRecord = new Service_Delivery_Plan__c(Name = 'Citation SDP accountforTest', Business__c = 'Citation', Account__c = accountforTest[0].Id);	
        TestUtility.setIDs(serviceDeliveryPlanforTest);	
        
        List<Account> accountforTestUpdated = new List<Account>{ new Account(Id = accountforTest[0].Id, Name = 'accountforTestUpdated') };	
        serviceDeliveryPlanforTestRecord.Account__r = accountforTestUpdated[0];
        serviceDeliveryPlanforTest.add(serviceDeliveryPlanforTestRecord);
        
        MockSelector selector = new MockSelector(); 	
        selector.serviceDeliveryPlans = serviceDeliveryPlanforTest;	
        
        MockUOW uow = new MockUOW();	
        UnitOfWork.setInstance(uow);
        
        Test.startTest();		
        new AccountService(selector).processRelatedRecordsOnChange(accountforTestUpdated, new Map<Id, Account>(accountforTest));		
        Test.stopTest();
        
        System.assertEquals(1, uow.getRecords(Service_Delivery_Plan__c.SObjectType).size());		
        Service_Delivery_Plan__c serviceDeliveryPlanforAssert = (Service_Delivery_Plan__c)uow.getRecords(Service_Delivery_Plan__c.SObjectType)[0];		
        System.assertEquals('Citation SDP accountforTestUpdated', serviceDeliveryPlanforAssert.Name, 'Service Delivery Plan Name not Updated');
    }
    
    @isTest
    private static void whenAccountNameUpdated_VerifySDPNamethatdoesnotStartsWithCitationSDP(){
        List<Account> accountforTest = new List<Account>{new Account(Name = 'accountforTest')};	
        TestUtility.setIDs(accountforTest);	
        
        List<Service_Delivery_Plan__c> serviceDeliveryPlanforTest = new List<Service_Delivery_Plan__c>();	
        Service_Delivery_Plan__c serviceDeliveryPlanforTestRecord = new Service_Delivery_Plan__c(Name = 'Citation SDP accountforTest', Business__c = 'Citation', Account__c = accountforTest[0].Id);		
        TestUtility.setIDs(serviceDeliveryPlanforTest);	
        
        List<Account> accountforTestUpdated = new List<Account>{ new Account(Id = accountforTest[0].Id, Name = 'accountforTestUpdated') };	
        serviceDeliveryPlanforTestRecord.Account__r = accountforTestUpdated[0];
        serviceDeliveryPlanforTest.add(serviceDeliveryPlanforTestRecord);
        
        MockSelector selector = new MockSelector(); 	
        MockUOW uow = new MockUOW();	
        UnitOfWork.setInstance(uow);
        
        Test.startTest();		
        new AccountService(selector).processRelatedRecordsOnChange(accountforTestUpdated, new Map<Id, Account>(accountforTest));		
        Test.stopTest();	
        
        System.assertEquals(0, uow.getRecords(Service_Delivery_Plan__c.SObjectType).size());	
    }
    
    class MockSelector implements AccountService.ISelector
    {
        List<Account> partnershipAccounts = new List<Account>();
        List<Service_Delivery_Plan__c> serviceDeliveryPlans=new List<Service_Delivery_Plan__c>();
        Map<Id, List<Task>> tasks = new Map<Id, List<Task>>();
        Map<Id, List<Contact>> accIdContactsMap = new Map<Id, List<Contact>>();
        Set<String> fieldsToTrack = new Set<String>();
        Id recordType;

        public Map<Id, List<Task>> getTasksWithCaseRecordTypes(List<Account> accounts, List<Id> caseRecordtypes)
        {
            return tasks;
        }

        public Set<String> getFieldsForHistoryTracking()
        {
            return fieldsToTrack;
        }

        public Id getRecordTypeId(SObjectType objType, String devName)
        {
            return recordType;
        }

        public List<Account> getAccountsDueForPartnershipCall(Set<Id> accountIds)
        {   
            return partnershipAccounts;
        }
        
        public Map<Id,List<Contact>> getAccountRelatedContacts(List<Account> accounts)
        {   
            return accIdContactsMap;
        }
        
        public List<Service_Delivery_Plan__c> getAccountswithServiceDeliveryPlan(Set<Id> accountIds){
           return serviceDeliveryPlans;
        }
    }
}