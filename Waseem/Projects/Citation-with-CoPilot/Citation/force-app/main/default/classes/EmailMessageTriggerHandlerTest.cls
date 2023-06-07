@IsTest
private class EmailMessageTriggerHandlerTest {

    @TestSetup
    static void init() {

        Account testAccount = new Account(Name = 'Test');
        insert testAccount;

        Contact testContact = new Contact(
                FirstName = 'test',
                LastName = 'test',
                AccountId = testAccount.Id
        );
        insert testContact;

        List<Case> testCaseItems = new List<Case>();

        testCaseItems.add(new Case(
                Subject = 'test1',
                Description = 'test1',
                RecordTypeId = EmailMessageTriggerHandler.RT_TO_CHECK.get(0),
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Status = EmailMessageTriggerHandler.CASE_STATUS_FOR_CHECK,
                Sub_Status__c = EmailMessageTriggerHandler.CASE_SUB_STATUS_FOR_CHECK
        ));

        System.runAs(getTestUser()) {
            insert testCaseItems;
        }

    }

    static User getTestUser() {
        return new User(
                Alias = 'standt',
                Email = 'standarduser@citation.co.uk',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = UserInfo.getProfileId(),
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'standarduser' + Datetime.now().getTime() + '@citation.co.uk'
        );
    }


    static Id getCaseId(String name) {
        return [SELECT Id FROM Case WHERE Subject = :name LIMIT 1].Id;
    }

    @IsTest
    static void testEmailMessageCreation() {

        Id caseId = getCaseId('test1');

        Test.startTest();


        EmailMessage testEmail = new EmailMessage(
                Subject = 'test',
                TextBody = 'test',
                ToAddress = UserInfo.getUserEmail(),
                FromAddress = UserInfo.getUserEmail(),
                ValidatedFromAddress = UserInfo.getUserEmail(),
                ParentId = caseId,
                RelatedToId = caseId,
                Incoming = true
        );
        insert testEmail;

        Test.stopTest();

        Case caseItem = [SELECT Status, Sub_Status__c FROM Case WHERE Id = :caseId LIMIT 1];

        System.assertEquals(EmailMessageTriggerHandler.CASE_STATUS_TO_CHANGE, caseItem.Status, 'Wrong Case Status');
        System.assertEquals(EmailMessageTriggerHandler.CASE_SUB_STATUS_TO_CHANGE, caseItem.Sub_Status__c, 'Wrong Case Status');
    }
}