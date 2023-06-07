@istest
public class CaseTriggerTest {
    
    @testSetup
    static  void testDataSetup() {
		Profile usersProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'S360 Citation Client Support'
        ];
    
            User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'CaseTriggerTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = usersProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'AGtestUser170921201@test.com'
        );
        insert testUser;
    }

    @isTest
    public static void checkStatusChanges() {
        Id atlasSupportRecorTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('S360_Atlas_Support')
            .getRecordTypeId();
        
        user testUser =[SELECT Id FROM User Where UserName = 'AGtestUser170921201@test.com' AND LastName = 'CaseTriggerTest' LIMIT 1];
        Case newCase = new Case(
            recordTypeId = atlasSupportRecorTypeId,
            Type = 'Atlas Support',
            Status = 'New',
            Origin = 'Phone - Atlas Support',
            Subject = 'test Subject',
            Description = 'test Description',
            OwnerId = testUser.Id
        );
        insert newCase;

        Test.startTest();
        newCase.Status = 'Awaiting Information';
        update newCase;
        Test.stopTest();

        System.assertEquals(
            true,
            [SELECT Id, isStopped FROM Case WHERE Id = :newCase.Id]
            .isStopped,
            'Milestone timer wasn\'t stopped'
        );
    }

    @isTest
    public static void testAssigningBusinessHours() {
        Id atlasSupportRecorTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('S360_Atlas_Support')
            .getRecordTypeId();
        String businessHoursForAtlasCases = Label.Business_hours_for_Atlas_support;
          user testUser =[SELECT Id FROM User Where UserName = 'AGtestUser170921201@test.com' AND LastName = 'CaseTriggerTest' LIMIT 1];
        List<Case> casesToInsert = new List<Case>();

        casesToInsert.add(
            new Case(
                recordTypeId = atlasSupportRecorTypeId,
                Type = 'Atlas Support',
                Status = 'New',
                Origin = 'Phone - Atlas Support',
                Subject = 'test Subject',
                Description = 'test Description',
                OwnerId = testUser.Id
            )
        );

        casesToInsert.add(
            new Case(
                recordTypeId = Case.SObjectType.getDescribe()
                    .recordTypeInfosByDeveloperName.get('ELT_Advice_Generic')
                    .getRecordTypeId(),
                Type = 'ELT Advice',
                Status = 'New',
                Origin = 'Phone',
                Subject = 'test Subject 001',
                Description = 'test Description 001',
                OwnerId = testUser.Id
            )
        );

        casesToInsert.add(
            new Case(
                recordTypeId = Case.SObjectType.getDescribe()
                    .recordTypeInfosByDeveloperName.get('HS_Advice_Generic')
                    .getRecordTypeId(),
                Type = 'H&S Advice',
                Status = 'New',
                Origin = 'Phone',
                Subject = 'test Subject 002',
                Description = 'test Description 002',
                OwnerId = testUser.Id
            )
        );

        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        System.assertEquals(
            businessHoursForAtlasCases,
            [
                SELECT Id, BusinessHours.Name
                FROM Case
                WHERE Id = :casesToInsert.get(0).Id
            ]
            .BusinessHours.Name,
            'Business hours haven\'t been assigned'
        );
    }

    @isTest
    public static void testEmployeeMatterCreationForNewAdvice() {
        Id adviseRecorTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('ELT_Advice_Generic')
            .getRecordTypeId();
        user testUser =[SELECT Id FROM User Where UserName = 'AGtestUser170921201@test.com' AND LastName = 'CaseTriggerTest' LIMIT 1];

        Account testAccount = new Account(Name = 'Test');
        insert testAccount;

        Employee__c newEmpl = new Employee__c(
            FirstName__c = 'test Name',
			      LastName__c = 'testEmp',
            Account_Name__c = testAccount.Id
        );
        insert newEmpl;

        Case newCase = new Case(
            recordTypeId = adviseRecorTypeId,
            Status = 'New',
            Subject = 'test Subject',
            Employee__c = newEmpl.Id,
            AccountId = testAccount.Id,
            OwnerId = testUser.Id
        );
        insert newCase;

        System.assertEquals(
            1,
            [SELECT Id FROM Employee_Matter__c].size(),
            'Employee matter record wasn\'t created'
        );

        newCase.Employee__c = null;
        update newCase;

        System.assertEquals(
            0,
            [SELECT Id FROM Employee_Matter__c].size(),
            'Employee matter record wasn\'t deleted'
        );
    }

    @isTest
    public static void testEmployeeMatterCreationForNewHSAdvice() {
        Id adviseRecorTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('HS_Advice_Generic')
            .getRecordTypeId();
        user testUser =[SELECT Id FROM User Where UserName = 'AGtestUser170921201@test.com' AND LastName = 'CaseTriggerTest' LIMIT 1];

        Account testAccount = new Account(Name = 'Test');
        insert testAccount;

        Employee__c newEmpl = new Employee__c(
            FirstName__c = 'test Name',
			      LastName__c = 'testEmp',
            Account_Name__c = testAccount.Id
        );
        insert newEmpl;

        Case newCase = new Case(
            recordTypeId = adviseRecorTypeId,
            Status = 'New',
            Subject = 'test Subject',
            Employee__c = newEmpl.Id,
            AccountId = testAccount.Id,
            OwnerId = testUser.Id
        );
        insert newCase;

        System.assertEquals(
            1,
            [SELECT Id FROM Employee_Matter__c].size(),
            'Employee matter record wasn\'t created'
        );

        newCase.Employee__c = null;
        update newCase;

        System.assertEquals(
            0,
            [SELECT Id FROM Employee_Matter__c].size(),
            'Employee matter record wasn\'t deleted'
        );
    }

    @isTest
    public static void testCaseTriggerNotification() {
        Id receptionTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Reception_General')
            .getRecordTypeId();
        user testUser =[SELECT Id FROM User Where UserName = 'AGtestUser170921201@test.com' AND LastName = 'CaseTriggerTest' LIMIT 1];
        Case newCase = new Case(
            recordTypeId = receptionTypeId,
            Type = 'Reception Case',
            Status = 'New',
            Origin = 'Phone - Atlas Support',
            Subject = 'test Subject',
            Description = 'test Description',
            OwnerId = testUser.Id
        );
        insert newCase;

        Test.startTest();
        newCase.Status = 'New Info Available';
        update newCase;
        Test.stopTest();
        system.assertEquals(
            'New Info Available',
            [SELECT Status FROM Case WHERE Id = :newCase.Id]
            .Status,
            'Status Updated'
        );
    }

    @isTest
    public static void testAutoResponseCases() {
        Case newCase = new Case(
            Type = 'Reception Case',
            Status = 'New',
            Origin = 'Phone - Atlas Support',
            Subject = 'test Subject',
            Description = 'test Description',
            SuppliedEmail = 'noreply@test.com'
        );
        insert newCase;
        system.assertEquals(
            [SELECT Id FROM Group WHERE type = 'Queue' AND Name = 'Quarantine']
            .Id,
            [SELECT OwnerId FROM Case WHERE Id = :newCase.Id]
            .OwnerId,
            'Queue assigned successfully'
        );
        Case newCase1 = new Case(
            Type = 'Reception Case',
            Status = 'New',
            Origin = 'Phone - Atlas Support',
            Subject = 'Test Auto Response Email',
            Description = 'Test Description',
            SuppliedEmail = 'test1@abc.com'
        );
        insert newCase1;
        system.assertEquals(
            [SELECT Id FROM Group WHERE type = 'Queue' AND Name = 'Quarantine']
            .Id,
            [SELECT OwnerId FROM Case WHERE Id = :newCase1.Id]
            .OwnerId,
            'Queue assigned successfully'
        );
    }
    /* @isTest
    public static void testOfUpdateOwnershipChange(){
        Id hrCYJrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HR_CYJ').getRecordTypeId();
        Case newCase1 = new Case(
            Type = 'Reception Case',
            Status = 'New',
            Origin = 'Phone - Atlas Support',
            Subject = 'Auto Response Email For Testing',
            Description = 'Test Description',
            SuppliedEmail = 'test1@abc.com',
            RecordTypeId=hrCYJrecordTypeId
        );
        insert newCase1;
        Test.startTest();
        Profile usersProfile = [
            SELECT Id,Name
            FROM Profile
            WHERE Name = 'citation data admin'
        ];
        user usr = [ select id from user where profileId = :usersProfile.Id limit 1 ];
        newCase1.OwnerId=usr.id;
        update newCase1;
        Test.stopTest();
        
        case c = [select id,ownership_change__c from case where subject = 'Auto Response Email For Testing' ];
        System.debug(c.Ownership_Change__c);
        System.assertEquals(true, c.Ownership_Change__c);
        
    }  */

    
}