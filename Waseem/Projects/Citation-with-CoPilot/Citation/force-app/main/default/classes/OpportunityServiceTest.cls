@isTest
public with sharing class OpportunityServiceTest
{
    @isTest
    private static void selectorGetNorthSouthBDMS_LoadOnlyNorthSouthBDMs()
    {
        List<UserRole> roles = new List<UserRole>{
            new UserRole(DeveloperName = 'Test1', Name = 'My Role'),
            new UserRole(DeveloperName = 'Test2', Name = 'BDM North'),
            new UserRole(DeveloperName = 'Test3', Name = 'BDM South')
        };
        insert roles;

        Id profileId = UserInfo.getProfileId();

        List<User> users = new List<User>{
            new User(
                ProfileId = UserInfo.getProfileId(),
                LastName = 'Test1',
                Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk',
                Username = 'testmnb@test.com' + System.currentTimeMillis(),
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = roles[0].Id
            ),
            new User(
                ProfileId = UserInfo.getProfileId(),
                LastName = 'Test2',
                Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk',
                Username = 'testvcx@test.com' + System.currentTimeMillis(),
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = roles[1].Id
            ),
            new User(
                ProfileId = UserInfo.getProfileId(),
                LastName = 'Test3',
                Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk',
                Username = 'testlkj@test.com' + System.currentTimeMillis(),
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = roles[2].Id
            )
        };
        insert users;

        Test.startTest();
        Map<Id, String> mappedRoles = new OpportunityService.DefaultSelector().getNorthSouthBDMS();
        Test.stopTest();

        System.assertEquals('BDM South', mappedRoles.get(users[2].Id));
        System.assertEquals('BDM North', mappedRoles.get(users[1].Id));
    }
    
    @isTest
    private static void selectorGetIHasocPriceBook_ReturnsPriceBook()
    {
        PriceBook2 pb = new PriceBook2(
            Name = 'iHasco'
        );
        insert pb;

        Test.startTest();
        ID pbId = new OpportunityService.DefaultSelector().getIHascoPriceBook();
        Test.stopTest();

        System.assertEquals(pb.Id, pbId);
    }

    @isTest
    private static void selectorGetContract_WhenRenewalContracts_ReturnsContract()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith'),
            new Account(Name = 'Jones')
        };
        insert acts;

        List<Contact> cons = new List<Contact>{
            new Contact(lastName = 'smith', AccountId = acts[0].Id),
            new Contact(lastName = 'jones', AccountId = acts[1].Id)
        };
        insert cons;

        List<Contract> contracts = new List<Contract>
        {
            new Contract(
                AccountId = acts[0].Id,
                CustomerSignedId = cons[0].Id,
                FOC_Period_Mths__c = 0,
                FOC_Period_Mths_End__c = 0
            ),
            new Contract(
                AccountId = acts[1].Id,
                CustomerSignedId = cons[1].Id,
                FOC_Period_Mths__c = 0,
                FOC_Period_Mths_End__c = 0
            )
        };
        insert contracts;

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(SBQQ__RenewedContract__c = contracts[0].Id),
            new Opportunity(SBQQ__RenewedContract__c = contracts[1].Id)
        };

        Test.startTest();
        Map<Id, Contract> loadedContracts = new OpportunityService.DefaultSelector().getContracts(Opps);
        Test.stopTest();

        System.assertEquals(2, loadedContracts.size());
    }

    @isTest
    private static void selectorGetContract_WhenAmendedContracts_ReturnsContract()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith'),
            new Account(Name = 'Jones')
        };
        insert acts;

        List<Contact> cons = new List<Contact>{
            new Contact(lastName = 'smith', AccountId = acts[0].Id),
            new Contact(lastName = 'jones', AccountId = acts[1].Id)
        };
        insert cons;

        List<Contract> contracts = new List<Contract>
        {
            new Contract(
                AccountId = acts[0].Id,
                CustomerSignedId = cons[0].Id,
                FOC_Period_Mths__c = 0,
                FOC_Period_Mths_End__c = 0
            ),
            new Contract(
                AccountId = acts[1].Id,
                CustomerSignedId = cons[1].Id,
                FOC_Period_Mths__c = 0,
                FOC_Period_Mths_End__c = 0
            )
        };
        insert contracts;

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(SBQQ__AmendedContract__c = contracts[0].Id),
            new Opportunity(SBQQ__AmendedContract__c = contracts[1].Id)
        };

        Test.startTest();
        Map<Id, Contract> loadedContracts = new OpportunityService.DefaultSelector().getContracts(Opps);
        Test.stopTest();

        System.assertEquals(2, loadedContracts.size());
    }

    @isTest
    private static void selectorGetContract_WhenNoNontractIDs_DoesNotRunQuery()
    {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(),
            new Opportunity()
        };

        Test.startTest();
        Map<Id, Contract> loadedContracts = new OpportunityService.DefaultSelector().getContracts(Opps);
        Test.stopTest();

        System.assertEquals(0, Limits.getQueries());
    }

    @isTest
    private static void selectorGetAccounts_WhenHasAccounts_ReturnsAccounts()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith', Payroll_Amt__c = 10, BillingCountry = 'UK', BillingPostalCode = 'NE1 4FG'),
            new Account(Name = 'Jones', iHASCO_Account_Manager__c = UserInfo.getUserId())
        };
        insert acts;

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(AccountId = acts[0].Id),
            new Opportunity(AccountId = acts[1].Id)
        };

        Test.startTest();
        Map<Id, Account> loadedActs = new OpportunityService.DefaultSelector().getAccounts(Opps);
        Test.stopTest();

        System.assertEquals(2, acts.size());
        System.assert(loadedActs.get(opps[0].AccountId) != null, 'Did not find expected Account for first opportunity');
        System.assert(loadedActs.get(opps[1].AccountId) != null, 'Did not find expected Account for second opportunity');

        System.assertEquals('NE1 4FG', loadedActs.get(opps[0].AccountId).BillingPostalCode);
        System.assertEquals('UK', loadedActs.get(opps[0].AccountId).BillingCountry);
        System.assertEquals(10, loadedActs.get(opps[0].AccountId).Payroll_Amt__c);
        System.assertEquals(UserInfo.getUserId(), loadedActs.get(opps[1].AccountId).iHASCO_Account_Manager__c);
    }

    @isTest
    private static void selectorGetAccounts_WhenHasNoAccounts_ReturnsNothing()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith'),
            new Account(Name = 'Jones')
        };
        insert acts;

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(AccountId = null),
            new Opportunity(AccountId = null)
        };

        Test.startTest();
        Map<Id, Account> loadedActs = new OpportunityService.DefaultSelector().getAccounts(Opps);
        Test.stopTest();

        System.assertEquals(0, loadedActs.size());
    }

    @isTest
    private static void setDefaults_IHascoRecordType_SetsValues()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith', 
                        iHASCO_Account_Manager__c = TestUtility.getFakeId(User.SObjectType),
                        OwnerId = TestUtility.getFakeId(User.SObjectType))
        };
        TestUtility.setIds(acts);

        Map<String, Id> recordTypes = new Map<String, Id>{
            'IHASCO' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType)
        };

        Id ihascoPricebook = TestUtility.getFakeId(PriceBook2.SObjectType);

        MockSelector selector = new MockSelector();
        selector.recordTypes = recordTypes;
        selector.accountsToUse = acts;
        selector.iHascoPricebook = ihascoPricebook;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            RecordTypeID = recordTypes.get('IHASCO'))
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals(recordTypes.get('IHASCO'), opps[0].RecordTypeID);
        System.assertEquals(ihascoPricebook, opps[0].PriceBook2Id);
    }

    @isTest
    private static void setDefaults_IHascoRecordType_whenConverted_SetsType()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith', 
                        iHASCO_Account_Manager__c = TestUtility.getFakeId(User.SObjectType),
                        OwnerId = TestUtility.getFakeId(User.SObjectType))
        };
        TestUtility.setIds(acts);

        Map<String, Id> recordTypes = new Map<String, Id>{
            'IHASCO' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType)
        };

        Id ihascoPricebook = TestUtility.getFakeId(PriceBook2.SObjectType);

        MockSelector selector = new MockSelector();
        selector.recordTypes = recordTypes;
        selector.accountsToUse = acts;
        selector.iHascoPricebook = ihascoPricebook;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            RecordTypeID = recordTypes.get('IHASCO'),
                            isConverted__c = true)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('New Business', opps[0].Type);
    }

    @isTest
    private static void setDefaults_IHascoAmendedContract_SetValues()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith', 
                        iHASCO_Account_Manager__c = TestUtility.getFakeId(User.SObjectType),
                        OwnerId = TestUtility.getFakeId(User.SObjectType))
        };
        TestUtility.setIds(acts);

        Map<String, Id> recordTypes = new Map<String, Id>{
            'IHASCO' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType),
            'RandomTestType' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType),
            'iHASCO_Contract' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType)
        };

        List<Contract> contracts = new List<Contract>
        {
            new Contract (RecordTypeID = recordTypes.get('iHASCO_Contract'))
        };
        TestUtility.setIds(contracts);

        Id ihascoPricebook = TestUtility.getFakeId(PriceBook2.SObjectType);

        MockSelector selector = new MockSelector();
        selector.recordTypes = recordTypes;
        selector.accountsToUse = acts;
        selector.contractToUse = contracts;
        selector.iHascoPricebook = ihascoPricebook;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            SBQQ__AmendedContract__c = contracts[0].Id,
                            AccountId = acts[0].Id,
                            RecordTypeID = recordTypes.get('RandomTestType'))
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals(recordTypes.get('IHASCO'), opps[0].RecordTypeID);
        System.assertEquals(ihascoPricebook, opps[0].PriceBook2Id);
    }

    @isTest
    private static void setDefaults_IHascoRenewalContract_SetValues()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith', 
                        iHASCO_Account_Manager__c = TestUtility.getFakeId(User.SObjectType),
                        OwnerId = TestUtility.getFakeId(User.SObjectType))
        };
        TestUtility.setIds(acts);

        Map<String, Id> recordTypes = new Map<String, Id>{
            'IHASCO' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType),
            'RandomTestType' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType),
            'iHASCO_Contract' => TestUtility.getFakeId(SObjectType.RecordType.SObjectType)
        };

        List<Contract> contracts = new List<Contract>
        {
            new Contract (RecordTypeID = recordTypes.get('iHASCO_Contract'))
        };
        TestUtility.setIds(contracts);

        Id ihascoPricebook = TestUtility.getFakeId(PriceBook2.SObjectType);

        MockSelector selector = new MockSelector();
        selector.recordTypes = recordTypes;
        selector.accountsToUse = acts;
        selector.contractToUse = contracts;
        selector.iHascoPricebook = ihascoPricebook;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            SBQQ__RenewedContract__c = contracts[0].Id,
                            AccountId = acts[0].Id,
                            RecordTypeID = recordTypes.get('RandomTestType'))
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('Test-Smith', opps[0].Name);
        System.assertEquals('Renewal', opps[0].Type);
        System.assertEquals(acts[0].iHASCO_Account_Manager__c, opps[0].OwnerId);
    }

    @isTest
    private static void setDefaults_WhenNorthBDM_SetsNorth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'BDM North'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('North', opps[0].North_South__c);
    }

    @isTest
    private static void setDefaults_WhenSouthBDM_SetsSouth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'BDM South'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('South', opps[0].North_South__c);
    }

    @isTest
    private static void setDefaults_WhenNorthernRegion_SetsNorth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith',
                        BillingPostalCode = 'NE30 3DH')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'RandomDude'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('North', opps[0].North_South__c);
    }

    @isTest
    private static void setDefaults_WhenSouthernRegion_SetsSouth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith',
                        BillingPostalCode = 'BN3 3DH')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'RandomDude'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('South', opps[0].North_South__c);
    }

    @isTest
    private static void setDefaults_WhenNoAddress_SetsSouth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'RandomDude'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('South', opps[0].North_South__c);
    }

    @isTest
    private static void processChangedValues_WhenNorthBDM_SetsNorth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'BDM North'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        List<Opportunity> oldOpps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };
        TestUtility.setIds(oldOpps);

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test1',
                            AccountId = acts[0].Id,
                            OwnerId = userId,
                            Id = oldOpps[0].Id)
        };

        new OpportunityService(selector).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        Test.stopTest();

        System.assertEquals('North', opps[0].North_South__c);
    }

    @isTest
    private static void processChangedValues_WhenSouthBDM_SetsSouth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'BDM South'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        List<Opportunity> oldOpps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };
        TestUtility.setIds(oldOpps);

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test1',
                            AccountId = acts[0].Id,
                            OwnerId = userId,
                            Id = oldOpps[0].Id)
        };

        new OpportunityService(selector).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        Test.stopTest();

        System.assertEquals('South', opps[0].North_South__c);
    }

    @isTest
    private static void processChangedValues_WhenNorthernRegion_SetsNorth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith',
                        BillingPostalCode = 'NE30 3DH')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'RandomDude'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        List<Opportunity> oldOpps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };
        TestUtility.setIds(oldOpps);

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test1',
                            AccountId = acts[0].Id,
                            OwnerId = userId,
                            Id = oldOpps[0].Id)
        };

        new OpportunityService(selector).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        Test.stopTest();

        System.assertEquals('North', opps[0].North_South__c);
    }

    @isTest
    private static void processChangedValues_WhenSouthernRegion_SetsSouth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith',
                        BillingPostalCode = 'BN3 3DH')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'RandomDude'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        List<Opportunity> oldOpps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };
        TestUtility.setIds(oldOpps);

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test1',
                            AccountId = acts[0].Id,
                            OwnerId = userId,
                            Id = oldOpps[0].Id)
        };

        new OpportunityService(selector).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals('South', opps[0].North_South__c);
    }

    @isTest
    private static void processChangedValues_WhenNoAddress_SetsSouth()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith')
        };
        TestUtility.setIds(acts);

        Id userId = TestUtility.getFakeId(User.SObjectType);
        Map<Id, String> userRole = new Map<Id, String>{
            userId => 'RandomDude'
        };

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;
        selector.userRole = userRole;

        List<Opportunity> oldOpps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            OwnerId = userId)
        };
        TestUtility.setIds(oldOpps);

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test1',
                            AccountId = acts[0].Id,
                            OwnerId = userId,
                            Id = oldOpps[0].Id)
        };

        new OpportunityService(selector).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        Test.stopTest();

        System.assertEquals('South', opps[0].North_South__c);
    }

    @isTest
    private static void setDefaults_WhenPayrollZero_SetsPayroll()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith',
                        Payroll_Amt__c = 10)
        };
        TestUtility.setIds(acts);

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            Payroll_Amt__c = 0)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals(10, opps[0].Payroll_Amt__c);
    }

    @isTest
    private static void setDefaults_WhenPayrollNonZero_DoesNotEdit()
    {
        List<Account> acts = new List<Account>{
            new Account(Name = 'Smith',
                        Payroll_Amt__c = 10)
        };
        TestUtility.setIds(acts);

        MockSelector selector = new MockSelector();
        selector.accountsToUse = acts;

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test',
                            AccountId = acts[0].Id,
                            Payroll_Amt__c = 20)
        };

        new OpportunityService(selector).setDefaults(opps);

        Test.stopTest();

        System.assertEquals(20, opps[0].Payroll_Amt__c);
    }

    @isTest
    private static void setDefaults_SetFMCreatedDate()
    {
        Datetime now = System.now();
        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test')
        };

        new OpportunityService(new MockSelector()).setDefaults(opps);

        Test.stopTest();

        // we can't get exact enough to an equals check, but it will be no earlier than start of test.
        System.assert(opps[0].FMCreatedDate__c >= now, 'FMCreatedDate__c not set correct');
    }
	
    @isTest
    private static void setDefaults_WhenCoreAppointmentType_SetIsCore()
    {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test 1', Appointment_Type__c='Combined'),
            new Opportunity(Name = 'Test 2', Appointment_Type__c='ISO')
        };

        Test.startTest();
        new OpportunityService(new MockSelector()).setDefaults(opps);
        Test.stopTest();
        
        System.assertEquals(opps[0].Is_Core__c, true);
        System.assertEquals(opps[1].Is_Core__c, false);
    }
    
    @isTest
    private static void processChangedValues_WhenAppointmentTypeChanges_SetIsCore()
    {
        List<Opportunity> oldOpps = new List<Opportunity>{
            new Opportunity(Name = 'Test', Appointment_Type__c='Combined'),
            new Opportunity(Name = 'Test1', Appointment_Type__c='PEL'),
            new Opportunity(Name = 'Test2')
        };
        TestUtility.setIds(oldOpps);

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test', Appointment_Type__c = 'PEL', Id = oldOpps[0].Id),
            new Opportunity(Name = 'Test1', Appointment_Type__c = '', Id = oldOpps[1].Id),
            new Opportunity(Name = 'Test2', Appointment_Type__c = 'H&S', Id = oldOpps[2].Id)
        };

        new OpportunityService(new MockSelector()).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        Test.stopTest();

        System.assertEquals(True, opps[0].Is_Core__c);
        System.assertEquals(False, opps[1].Is_Core__c);
        System.assertEquals(True, opps[2].Is_Core__c);
    }
    
    @isTest
    private static void processChangedValues_WhenNumberOfCoreProductChanges_SetIsCore()
    {
        String jOldOpp1 = '{"attributes":{"type":"Opportunity"}, "Name":"Test1", "Number_of_Core_Products__c":3}';
        String jOldOpp2 = '{"attributes":{"type":"Opportunity"}, "Name":"Test2", "Number_of_Core_Products__c":1}';
		
        Opportunity oldOpp1 =  (Opportunity)json.deserialize(jOldOpp1, Opportunity.class);
        Opportunity oldOpp2 =  (Opportunity)json.deserialize(jOldOpp2, Opportunity.class);
        
        List<Opportunity> oldOpps = new List<Opportunity>{oldOpp1,oldOpp2};
        TestUtility.setIds(oldOpps);

        Test.startTest();
		
        String jOpp1 = '{"attributes":{"type":"Opportunity"}, "Name":"Test1", "Number_of_Core_Products__c":2, "Id":"'+oldOpp1.Id+'"}';
        String jOpp2 = '{"attributes":{"type":"Opportunity"}, "Name":"Test2", "Number_of_Core_Products__c":1, "Id":"'+oldOpp2.Id+'"}';
		
        Opportunity opp1 =  (Opportunity)json.deserialize(jOpp1, Opportunity.class);
        Opportunity opp2 =  (Opportunity)json.deserialize(jOpp2, Opportunity.class);
        
        List<Opportunity> opps = new List<Opportunity>{opp1, opp2};

        new OpportunityService(new MockSelector()).processChangedValues(opps, new Map<Id, Opportunity>(oldOpps));

        Test.stopTest();

        System.assertEquals(True, opps[0].Is_Core__c);
        System.assertEquals(True, opps[1].Is_Core__c);
    }
    
    class MockSelector implements OpportunityService.ISelector
    {
        List<Account> accountsToUse = new List<Account>();
        List<Contract> contractToUse = new List<Contract>();
        Map<String, Id> recordTypes = new Map<String, ID>();
        private Id iHascoPricebook;
        private Map<Id, String> userRole = new Map<Id, String>();

        public Id getRecordTypeId(SObjectType objType, String devName)
        {
            return recordTypes.get(devName);
        }

        public Map<Id, Account> getAccounts(List<Opportunity> opps)
        {
            return new Map<Id, Account>(accountsToUse);
        }

        public Id getIHascoPriceBook()
        {
            return iHascoPricebook;
        }

        public Map<Id, Contract> getContracts(List<Opportunity> opps)
        {
            return new Map<Id, Contract>(contractToUse);
        }

        public Map<Id, String> getNorthSouthBDMS()
        {
            return userRole;
        }
    }
}