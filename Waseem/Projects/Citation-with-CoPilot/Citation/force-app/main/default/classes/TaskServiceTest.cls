@isTest
public class TaskServiceTest
{
    // basic class to handle what are many similar tests around status checking
    // and lead updating.
    class StatusProcess
    {
        Lead lead = new Lead();
        Task task = new Task();
        Task oldTask = new Task();


        StatusProcess()
        {
            TestUtility.setId(lead);
            task.OwnerId = TestUtility.getFakeId(User.SObjectType);
            task.whoId = lead.Id;

            oldTask.OwnerId = task.OwnerId;
            oldTask.WhoID = task.WhoID;
        }
        
        StatusProcess withCallObject()
        {
            task.CallObject = 'xxx';
            oldTask.CallObject = 'xxx';
            return this;
        }

        StatusProcess withRenewalDate(Date value)
        {
            task.Renewal_Date__c = value;
            oldTask.Renewal_Date__c = value;
            return this;
        }

        StatusProcess withSuspendedClose(String value)
        {
            task.Suspended_Close__c = value;
            oldTask.Suspended_Close__c = value;
            return this;
        }

        StatusProcess withChangedSuspendedClose()
        {
            oldTask.Suspended_Close__c = 'oldxxxx';
            return this;
        }

        StatusProcess withStatus(String value)
        {
            task.Status__c = value;
            oldTask.Status__c = value;
            return this;
        }

        StatusProcess withChangedStatus()
        {
            oldTask.Status__c = 'oldxxxx';
            return this;
        }

        StatusProcess withRating(String value)
        {
            task.Rating__c = value;
            oldTask.Rating__c = value;
            return this;
        }

        StatusProcess withFullTimeEmployees(Integer value)
        {
            task.FullTimeEmployees__c = value;
            oldTask.FullTimeEmployees__c = value;
            return this;
        }

        StatusProcess withCallbackDateTime(DateTime value)
        {
            task.CallbackDateTime__c = value;
            oldTask.CallbackDateTime__c = value;
            return this;
        }

        ID getTaskOwner()
        {
            return task.OwnerId;
        }

        Lead processInsert(Integer expectedLeadCount)
        {
            MockSelector selector = new MockSelector();
            selector.relatedLeads = new List<Lead>{lead};

            MockUOW uow = new MockUOW();
            UnitOfWork.setInstance(uow);

            new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});

            System.assertEquals(expectedLeadCount, uow.getRecords(lead.getSobjectType()).size());

            return expectedLeadCount == 0 ? null : (Lead)uow.getRecords(lead.getSobjectType())[0];
        }

        Lead processUpdate(Integer expectedLeadCount)
        {
            TestUtility.setId(oldTask);
            task.Id = oldTask.Id;

            MockSelector selector = new MockSelector();
            selector.relatedLeads = new List<Lead>{lead};

            MockUOW uow = new MockUOW();
            UnitOfWork.setInstance(uow);

            new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));

            System.assertEquals(expectedLeadCount, uow.getRecords(lead.getSobjectType()).size());

            return expectedLeadCount == 0 ? null : (Lead)uow.getRecords(lead.getSobjectType())[0];
        }
    }


    @isTest
    private static void selector_SelectsRelatedLeads()
    {
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'Test Task 1', Company = 'Test', email= 'test@citation.co.uk'),
            new Lead(LastName = 'Test Task 2', Company = 'Test', email= 'test@citation.co.uk'),
            new Lead(LastName = 'Test Task 3', Company = 'Test', email= 'test@citation.co.uk')
        };

        insert leads;

        List<Task> tasks = new List<Task>{
            new Task(WhoId = leads[0].Id),
            new Task(WhoId = leads[2].Id)
        };


        Test.startTest();
        Map<Id, Lead> selectedLeads = new TaskService.DefaultSelector().getRelatedLeads(tasks);
        Test.stopTest();

        System.assertEquals(2, selectedLeads.size());
        System.assert(selectedLeads.keySet().contains(leads[0].Id), 'Not loaded lead for first task');
        System.assert(selectedLeads.keySet().contains(leads[2].Id), 'Not loaded lead for second task');
    }

    @isTest
    private static void whenLeadUpdatedManyTimes_only1DML()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        // task updates for dialler outcome and outbound call logic
        Task task = new Task(OwnerId = TestUtility.getFakeId(User.SObjectType),
                            WhoId = lead.Id,
                            Renewal_Date__c = Date.today().addDays(7), 
                            Status__c = 'open', 
                            Suspended_Close__c = 'Future Third Party',
                            CallType = 'Outbound', 
                            CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        // only 1 dml
        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());

        //dialler outcome
        System.assertEquals(task.OwnerId, lead.Assigned_BDC__c);
        System.assertEquals(task.Renewal_Date__c, lead.Renewal_Date__c);
        System.assertEquals(task.Status__c, lead.Status);
        System.assertEquals(task.Suspended_Close__c, lead.Suspended_Closed_Reason__c);

        //outbound call outcome
        System.assertEquals(true, lead.OutboundCallCheck__c);
        System.assertEquals(task.OwnerId , lead.Last_Outbound_Caller__c);
    }

    @isTest
    private static void whenUpdate_ChangeStatus_CallbackReturned_UpdateLeadUpdate()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withStatus('Callback Requested').withSuspendedClose('Returned Callback');
        Lead lead = process.withChangedStatus().processUpdate(1);

        System.assertEquals('Callback Requested', lead.Status);
        System.assertEquals('Returned Callback', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenUpdate_NoChange_CallbackReturned_NoLeadUpdate()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withStatus('Callback Requested').withSuspendedClose('Returned Callback').processUpdate(0);
    }

    @isTest
    private static void whenInsert_SuspendedClose_CallbackReturned_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withStatus('Callback Requested').withSuspendedClose('Returned Callback').processInsert(1);

        System.assertEquals('Callback Requested', lead.Status);
        System.assertEquals('Returned Callback', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_Status_InternalCall_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withStatus('Internal Call').withSuspendedClose('blah').processInsert(1);

        System.assertEquals('Internal Call', lead.Status);
        System.assertEquals('blah', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenUpdate_NoChange_MemberOfPublic_NoLeadUpdate()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withSuspendedClose('Member of public').processUpdate(0);
    }

    @isTest
    private static void whenUpdate_ChangeStatus_MemberOfPublic_NoLeadUpdate()
    {
        // status change not relevant to this update, so it changing
        // should not trigger lead update
        StatusProcess process = new StatusProcess();

        process.withCallObject().withSuspendedClose('Member of public');
        Lead lead = process.withChangedStatus().processUpdate(0);
    }

    @isTest
    private static void whenUpdate_ChangeSuspenseClosed_MemberOfPublic_UpdateLeadUpdate()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withSuspendedClose('Member of public');
        Lead lead = process.withChangedSuspendedClose().processUpdate(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Member of the public', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_MemberOfPublic_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Member of public').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Member of the public', lead.Suspended_Closed_Reason__c);
    }


    @isTest
    private static void whenInsert_SuspendedClose_Employee_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Employee').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Employee', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_LocalAuthority_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Local Authority').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Local Authority', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_Client_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Client').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Client', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_Duplicate_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Duplicate').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Duplicate', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_DoNotCall_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Do Not Call').processInsert(1);

        System.assertEquals('Yes', lead.IsTPS__c);
        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Do Not Call', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_Branch_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Branch').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Branch', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_CeaseTrading_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Ceased Trading').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Ceased Trading', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_AreaNotCovered_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Area Not Covered').processInsert(1);

        System.assertEquals('Closed', lead.Status);
        System.assertEquals('Area Not Covered', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_SoleTrader_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Sole Trading').processInsert(1);

        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('Sole Trader', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_ThirdPartyRenew_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Third Party Renewal').withRenewalDate(Date.today().addDays(7)).processInsert(1);
        System.assertEquals('Suspended', lead.Status);
        System.assertEquals(Date.today().addDays(7), lead.Renewal_Date__c);
        System.assertEquals('Third Party Renewal', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_DMRefusal_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('DM Refusal').processInsert(1);

        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('DM Refusal', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_BadCompany_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Bad Company').processInsert(1);

        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('Bad Company', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_BadSector_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Bad Sector').processInsert(1);

        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('Bad Sector', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_NotInterested_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Not Interested').processInsert(1);

        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('Not Interested', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_OverCriteria_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withFullTimeEmployees(2).withSuspendedClose('Over Criteria').processInsert(1);

        System.assertEquals(2, lead.FT_Employees__c);
        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('Over Criteria', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_UnderCriteria_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withFullTimeEmployees(2).withSuspendedClose('Under Criteria').processInsert(1);

        System.assertEquals(2, lead.FT_Employees__c);
        System.assertEquals('Suspended', lead.Status);
        System.assertEquals('Under Criteria', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_Status_Appointment_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withStatus('Appointment').withSuspendedClose('Blah').processInsert(1);

        System.assertEquals('Appointment', lead.Status);
        System.assertEquals('Blah', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_Callback_UpdatesLeadStatus()
    {
        DateTime now = System.now();

        StatusProcess process = new StatusProcess();

        process.withCallObject().withStatus('Callback Requested').withSuspendedClose('DM Callback');
        process.withRating('Hot').withCallbackDateTime(now);
        Lead lead =process.processInsert(1);

        System.assertEquals(now, lead.Callback_Date_Time__c);
        System.assertEquals('Hot', lead.Rating);
        System.assertEquals(process.getTaskOwner(), lead.BDC__c);
        System.assertEquals('Callback Requested', lead.Status);
        System.assertEquals('DM Callback', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_Disconnect_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Disconnect').processInsert(1);

        System.assertEquals(true, lead.OutboundDisconnectCallCheck__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('Disconnect', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_Busy_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Busy').processInsert(1);

        System.assertEquals(true, lead.OutboundBusyCheck__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('Busy', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_NoAnswer_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('No Answer').processInsert(1);

        System.assertEquals(true, lead.OutboundNoAnswerCheck__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('No Answer', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_GateKeeper_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('Gatekeeper Refusal').processInsert(1);

        System.assertEquals(true, lead.OutboundGKCheck__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('Gatekeeper Refusal', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_SuspendedClose_DMU_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        Lead lead = process.withCallObject().withSuspendedClose('DMU').processInsert(1);
        
        System.assertEquals(true, lead.OutboundDMUnavailableCheck__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('Decision Maker Unavailable', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenUpdate_FutureThirdParty_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withStatus('Open').withSuspendedClose('Future Third Party').withRenewalDate(Date.today().addDays(7));
        Lead lead = process.withChangedStatus().processUpdate(1);

        System.assertEquals(process.getTaskOwner(), lead.Assigned_BDC__c);
        System.assertEquals(Date.today().addDays(7), lead.Renewal_Date__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('Future Third Party', lead.Suspended_Closed_Reason__c);

    }

    private static void whenUpdate_FutureThirdPartyNotChanges_doesNotupdateLead()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withStatus('Open').withSuspendedClose('Future Third Party').withRenewalDate(Date.today().addDays(7));
        Lead lead = process.processUpdate(0);
    }

    @isTest
    private static void whenInsert_FutureThirdParty_StatusOpen_UpdatesLeadStatus()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withStatus('Open').withSuspendedClose('Future Third Party').withRenewalDate(Date.today().addDays(7));
        Lead lead = process.processInsert(1);

        System.assertEquals(process.getTaskOwner(), lead.Assigned_BDC__c);
        System.assertEquals(Date.today().addDays(7), lead.Renewal_Date__c);
        System.assertEquals('Open', lead.Status);
        System.assertEquals('Future Third Party', lead.Suspended_Closed_Reason__c);
    }

    @isTest
    private static void whenInsert_FutureThirdParty_StatusNotOpen_doesNotupdateLead()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withStatus('something').withSuspendedClose('Future Third Party').withRenewalDate(Date.today().addDays(7));
        Lead lead = process.processInsert(0);
    }

    @isTest
    private static void whenInsert_UnknownSuspenseClose_doesNotupdateLead()
    {
        StatusProcess process = new StatusProcess();

        process.withCallObject().withSuspendedClose('Unknown').processInsert(0);
    }

    @isTest
    private static void whenCallObject_insert_updatesRunTime()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Datetime dt = Datetime.newInstance(2022, 1, 1, 1, 1, 0);
        Task task = new Task(WhoId = lead.Id, NVMContactWorld__CW_Call_End_Time__c = dt, CallObject = 'xxx');

        MockSelector selector = new MockSelector();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).setDefaults(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(dt.addMinutes(65), task.Process_Run_Time__c);
    }

    @isTest
    private static void whenCallObject_update_updatesRunTime()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Task oldTask = new Task(WhoId = lead.Id);
        TestUtility.setId(oldTask);

        Datetime dt = Datetime.newInstance(2022, 1, 1, 1, 1, 0);
        Task task = new Task(Id = oldTask.Id, WhoId = lead.Id, NVMContactWorld__CW_Call_End_Time__c = dt, CallObject = 'xxx');

        MockSelector selector = new MockSelector();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processChangedValues(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(dt.addMinutes(65), task.Process_Run_Time__c);
    }


    @isTest
    private static void whenHasFulltimEmployee_insert_updatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Task task = new Task(WhoId = lead.Id, FullTimeEmployees__c = 5, CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());
        System.assertEquals(5, lead.FT_Employees__c);
    }

    @isTest
    private static void whenHasFulltimEmployeeChanges_update_updatesLead()
    {
        Lead lead = new Lead(FT_Employees__c = 4);
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);

        Task oldTask = new Task(WhoId = lead.Id, FullTimeEmployees__c = 4, CallObject = 'xxx');
        TestUtility.setId(oldTask);

        Task task = new Task(Id = oldTask.Id, WhoId = lead.Id, FullTimeEmployees__c = 5, CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());
        System.assertEquals(5, lead.FT_Employees__c);
    }

    @isTest
    private static void whenFulltimEmployee_DoesNotChanges_update_doesNotupdatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Task oldTask = new Task(WhoId = lead.Id, FullTimeEmployees__c = 5, CallObject = 'xxx');
        TestUtility.setId(oldTask);

        Task task = new Task(Id = oldTask.Id, WhoId = lead.Id, FullTimeEmployees__c = 5, CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void whenInBoundLeadWithCallObject_insert_updatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Task task = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Inbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());
        System.assert(lead.LastInboundCall__c >= now, 'should have set time to at start of test time');
        System.assertEquals(true, lead.InboundCallCheck__c);
    }

    @isTest
    private static void whenChangeInBoundLeadWithCallObject_update_updatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);

        Task oldTask = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Inbound', CallObject = null);
        TestUtility.setId(oldTask);

        Task task = new Task(Id = oldTask.Id, OwnerId = userId, WhoId = lead.Id, CallType = 'Inbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());
        System.assert(lead.LastInboundCall__c >= now, 'should have set time to at start of test time');
        System.assertEquals(true, lead.InboundCallCheck__c);
    }

    @isTest
    private static void whenInBoundLeadWithNoChange_update_doesNotUpdateLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);

        Task oldTask = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Inbound', CallObject = 'xxx');
        TestUtility.setId(oldTask);

        Task task = new Task(Id = oldTask.Id, OwnerId = userId, WhoId = lead.Id, CallType = 'Inbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void whenInBoundLeadWith_NoCallObject_insert_doesNotupdatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Task task = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Inbound');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void whenOutBoundLeadWithCallObject_insert_updatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Task task = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Outbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());
        System.assert(lead.LastOutboundCall__c >= now, 'should have set time to at start of test time');
        System.assertEquals(true, lead.OutboundCallCheck__c);
        System.assertEquals(task.OwnerId , lead.Last_Outbound_Caller__c);
    }

    @isTest
    private static void whenChangeOutBoundLeadWithCallObject_update_updatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);

        Task oldTask = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Outbound', CallObject = null);
        TestUtility.setId(oldTask);

        Task task = new Task(Id = oldTask.Id, OwnerId = userId, WhoId = lead.Id, CallType = 'Outbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(lead.getSobjectType()).size());
        System.assert(lead.LastOutboundCall__c >= now, 'should have set time to at start of test time');
        System.assertEquals(true, lead.OutboundCallCheck__c);
        System.assertEquals(task.OwnerId , lead.Last_Outbound_Caller__c);
    }

    @isTest
    private static void whenOutBoundLeadWithNoChange_update_doesNotUpdateLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);

        Task oldTask = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Outbound', CallObject = 'xxx');
        TestUtility.setId(oldTask);

        Task task = new Task(Id = oldTask.Id, OwnerId = userId, WhoId = lead.Id, CallType = 'Outbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnChange(new List<Task>{task}, new Map<Id, Task>(new List<Task>{oldTask}));
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void whenOutBoundLeadWith_NoCallObject_insert_doesNotupdatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Task task = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'Outbound');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void when_NotOutBound_LeadWithNoCallObject_insert_doesNotupdatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Task task = new Task(OwnerId = userId, WhoId = lead.Id, CallType = 'xbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void whenOutBound_NotLead_WithNoCallObject_insert_doesNotupdatesLead()
    {
        Lead lead = new Lead();
        TestUtility.setId(lead);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        ID contactId = TestUtility.getFakeId(Contact.SObjectType);
        Task task = new Task(OwnerId = userId, WhoId = contactId, CallType = 'Outbound', CallObject = 'xxx');

        MockSelector selector = new MockSelector();
        selector.relatedLeads = new List<Lead>{lead};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        DateTime now = System.now();

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processRelatedRecordsOnNew(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(lead.getSobjectType()).size());
    }

    @isTest
    private static void givenDescription_whenDefaultsSet_thenCopiestoComments()
    {
        Task task = new Task(Description = 'TestComment');

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new TaskService(selector, new MockNoteService()).setDefaults(new List<Task>{task});
        Test.stopTest();

        System.assertEquals('TestComment', task.Comment__c);
    }

    @isTest
    private static void givenLongDescription_whenDefaultsSet_thenCopiestoCommentsTruncated()
    {
        String description = '';
        for(Integer i = 0; i < 300; i++)
        {
            description += 'a';
        }

        Task task = new Task(Description = description);

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new TaskService(selector, new MockNoteService()).setDefaults(new List<Task>{task});
        Test.stopTest();

        System.assertEquals(255, task.Comment__c.length());
        System.assert(task.Comment__c.endsWith('...'));
    }

    @isTest
    private static void givenDescription_whenProcessChangedValues_thenCopiestoComments()
    {
        Task oldTask = new Task(Description = 'TestComment');
        TestUtility.setID(oldTask);
        Task newTask = new Task(Id = oldTask.Id, Description = 'New TestComment');

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processChangedValues(new List<Task>{newTask}, new Map<Id, Task>{oldTask.Id => oldTask});
        Test.stopTest();

        System.assertEquals('New TestComment', newTask.Comment__c);
    }

    @isTest
    private static void givenNoDescription_whenDefaultsSet_thenLeavesComments()
    {
        Task task = new Task(Comment__c = 'TestComment');

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new TaskService(selector, new MockNoteService()).setDefaults(new List<Task>{task});
        Test.stopTest();

        System.assertEquals('TestComment', task.Comment__c);
    }

    @isTest
    private static void givenNoDescription_whenProcessChangedValues_thenLeavesComments()
    {
        Task oldTask = new Task(Comment__c = 'TestComment');
        TestUtility.setID(oldTask);
        Task newTask = new Task(Id = oldTask.Id, Comment__c = 'TestComment');

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new TaskService(selector, new MockNoteService()).processChangedValues(new List<Task>{newTask}, new Map<Id, Task>{oldTask.Id => oldTask});
        Test.stopTest();

        System.assertEquals('TestComment', newTask.Comment__c);
    }

    @isTest
    private static void givenNewNote_whenNoteServiceCalled_thenSetDescription()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'A message';

        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(CallObject = '111', Description = null)
        };
        TestUtility.setIds(tasks.values());

        MockSelector selector = new MockSelector();
        selector.tasks = tasks;
        selector.user = 'Bob';

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        TaskService srv = new TaskService(selector, new MockNoteService());
        new NoteService(selector, srv).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
        System.assertEquals(expectedMessage, ((Task)uow.getRecords(Task.SObjectType)[0]).Description);
    }

    @isTest
    private static void givenAnExistingDescription_whenNoteServiceCalled_thenAddsToDescription()
    {
        SObjectNote note = new SObjectNote();
        note.noteSource = '111';
        note.key = 'Key : 2022-12-10';
        note.note = 'A message';

        String oldMessage = '--\n[Key : 2022-12-09] Harry | \n\nprior message\n';
        Map<String, Task> tasks = new Map<String, Task>{
            '111' => new Task(CallObject = '111', Description = oldMessage)
        };
        TestUtility.setIds(tasks.values());

        MockSelector selector = new MockSelector();
        selector.tasks = tasks;
        selector.user = 'Bob';

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        TaskService srv = new TaskService(selector, new MockNoteService());
        new NoteService(selector, srv).setNotes(new List<SObjectNote>{note});
        Test.stopTest();

        String expectedMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n' + oldMessage;
        System.assertEquals(1, uow.getRecords(Task.SObjectType).size());
        System.assertEquals(expectedMessage, ((Task)uow.getRecords(Task.SObjectType)[0]).Description);
    }

    @isTest
    private static void givenCallTask_whenNewDescription_thenCallNoteService()
    {
        String oldMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
        Id fakeLeadId = TestUtility.getFakeId(Lead.SObjectType);

        List<Task> tasks = new List<Task>{
            new Task(CallObject = '111', Description = oldMessage, whoId = fakeLeadId )
        };
        TestUtility.setIds(tasks);

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new TaskService(selector, noteService).processRelatedRecordsOnNew(tasks);
        Test.stopTest();

        System.assertEquals(oldMessage, noteService.sentNotes);
        System.assertEquals(tasks[0].Id, noteService.sentSource);
    }

    @isTest
    private static void givenCallTask_whenChangeOfWhoId_thenCallNoteService()
    {
        String oldMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
        List<Task> oldTasks = new List<Task>{
            new Task(CallObject = '111', Description = oldMessage)
        };
        TestUtility.setIds(oldTasks);

        Id fakeLeadId = TestUtility.getFakeId(Lead.SObjectType);
        List<Task> newTasks = new List<Task>{
            new Task(Id = oldTasks[0].id, CallObject = '111', Description = oldMessage, whoId = fakeLeadId)
        };

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new TaskService(selector, noteService).processRelatedRecordsOnChange(newTasks, new Map<Id, Task>(oldTasks));
        Test.stopTest();

        System.assertEquals(oldMessage, noteService.sentNotes);
        System.assertEquals(newTasks[0].Id, noteService.sentSource);
    }

    @isTest
    private static void givenNormalTask_whenNewDescription_thenNotCallNoteService()
    {
        String oldMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
        List<Task> tasks = new List<Task>{
            new Task(CallObject = null, Description = oldMessage)
        };
        TestUtility.setIds(tasks);

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new TaskService(selector, noteService).processRelatedRecordsOnNew(tasks);
        Test.stopTest();

        System.assertEquals(null, noteService.sentNotes);
        System.assertEquals(null, noteService.sentSource);
    }

    @isTest
    private static void givenUpdatedCallTask_whenNewDescription_thenCallNoteService()
    {
        String oldMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';
        String editedMessage = '--\n[Key : 2022-12-10] Harry | \n\nedited message\n';    

        List<Task> oldTasks = new List<Task>{
            new Task(CallObject = '111', Description = oldMessage)
        };
        TestUtility.setIds(oldTasks);

        List<Task> newTasks = new List<Task>{
            new Task(Id = oldTasks[0].Id, CallObject = '111', Description = editedMessage)
        };

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new TaskService(selector, noteService).processRelatedRecordsOnChange(newTasks, new Map<Id, Task>(oldTasks));
        Test.stopTest();

        System.assertEquals(editedMessage, noteService.sentNotes);
        System.assertEquals(newTasks[0].Id, noteService.sentSource);
    }

    @isTest
    private static void givenUpdatedCallTask_whenSameDescription_thenNotCallNoteService()
    {
        String oldMessage = '--\n[Key : 2022-12-10] Bob | \n\nA message\n';  

        List<Task> oldTasks = new List<Task>{
            new Task(CallObject = '111', Description = oldMessage)
        };
        TestUtility.setIds(oldTasks);

        List<Task> newTasks = new List<Task>{
            new Task(Id = oldTasks[0].Id, CallObject = '111', Description = oldMessage)
        };

        MockSelector selector = new MockSelector();

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        MockNoteService noteService = new MockNoteService();

        Test.startTest();
        new TaskService(selector, noteService).processRelatedRecordsOnChange(newTasks, new Map<Id, Task>(oldTasks));
        Test.stopTest();

        System.assertEquals(null, noteService.sentNotes);
        System.assertEquals(null, noteService.sentSource);
    }

    class MockSelector implements TaskService.ISelector, NoteService.ISelector
    {
        private List<Lead> relatedLeads;
        private String user;
        private Map<String, Task> tasks;

        public Map<Id, Lead> getRelatedLeads(List<Task> tasks)
        {
            return relatedLeads == null ? new Map<Id, Lead>() : new Map<Id, Lead>(relatedLeads);
        }

        public String getCurrentUserName()
        {
            return user == null ? UserInfo.getName() : user;
        }

        public Map<String, Task> getTasksByCallObjects(Set<String> callObjects)
        {
            return tasks == null ? new Map<String, Task>() : tasks;
        }
    }

    class MockNoteService implements INoteService
    {
        String sentNotes;
        String sentSource;
        public void setNotes(List<SObjectNote> notes)
        {
        }

        public void fixManualEdits(List<Sobject> objs, SObjectField noteField)
        {

        }

        public List<SObjectNote> convertToNotes(String existingNotes, String noteSource)
        {
            sentNotes = existingNotes;
            sentSource = noteSource;
            return new List<SObjectNote>();
        }
    }
}