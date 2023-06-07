@IsTest
private class SplitCaseCtrlTest {

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

        Id atlasSupportRTId =
                Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();

        List<Case> testCaseItems = new List<Case>();

        testCaseItems.add(new Case(
                Subject = 'test1',
                Description = 'test1',
                RecordTypeId = atlasSupportRTId,
                AccountId = testAccount.Id,
                ContactId = testContact.Id
        ));

        testCaseItems.add(new Case(
                Subject = 'test2',
                Description = 'test2',
                RecordTypeId = atlasSupportRTId,
                AccountId = testAccount.Id,
                ContactId = testContact.Id
        ));

        insert testCaseItems;
		
        List<EmailMessage> messageList = new List<EmailMessage>();
        EmailMessage testEmail = new EmailMessage(
                Subject = 'test',
                TextBody = 'test',
                ToAddress = UserInfo.getUserEmail(),
                FromAddress = UserInfo.getUserEmail(),
                ValidatedFromAddress = UserInfo.getUserEmail(),
                ParentId = testCaseItems.get(0).Id,
                RelatedToId = testCaseItems.get(0).Id
        );
        messageList.add(testEmail);
        EmailMessage testEmail2 = new EmailMessage(
                Subject = 'test2',
                TextBody = 'test2',
                ToAddress = UserInfo.getUserEmail(),
                FromAddress = UserInfo.getUserEmail(),
            	Incoming = True,
                ValidatedFromAddress = UserInfo.getUserEmail(),
                ParentId = testCaseItems.get(0).Id,
                RelatedToId = testCaseItems.get(0).Id
        );
        messageList.add(testEmail2);
        insert messageList;

        ContentVersion cvItem = new ContentVersion(
                Title = 'Test1',
                PathOnClient = 'Test1.txt',
                VersionData = Blob.valueOf('test')
        );
        insert cvItem;

        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvItem.Id LIMIT 1].ContentDocumentId;

        insert new ContentDocumentLink(
                LinkedEntityId = testEmail.Id,
                ContentDocumentId = cdId
        );
        
        Attachment attach = new Attachment(ParentId = testEmail2.Id, body = Blob.valueOf('Test Data'), Name = 'test', Description = 'test Des');
        insert attach;
    }

    static Id getEmailMessageId(String name) {
        return [SELECT Id FROM EmailMessage WHERE Subject = :name LIMIT 1].Id;
    }

    static Id getCaseId(String name) {
        return [SELECT Id FROM Case WHERE Subject = :name LIMIT 1].Id;
    }

    @IsTest
    static void testOption1() {
        Id recordId = getEmailMessageId('test');

        Test.startTest();

        Map<String, Object> initParams = SplitCaseCtrl.getInitParams(recordId);
        System.assert((Boolean) initParams.get('hasEditAccess'), 'Has no access');

        Id result = SplitCaseCtrl.doSplit(recordId, null, 'option1');

        Test.stopTest();

        System.assert(result != null, 'Result is Empty');
        System.assert(result.getSobjectType() == Case.SObjectType, 'Id has wrong type');

        System.assertEquals(3, [SELECT COUNT() FROM Case], 'Wrong Case records amount');
        System.assertEquals(2, [SELECT COUNT() FROM EmailMessage], 'Wrong EmailMessage records amount');

    }

    @IsTest
    static void testOption2() {
        Id recordId = getEmailMessageId('test');

        Test.startTest();

        Map<String, Object> initParams = SplitCaseCtrl.getInitParams(recordId);
        System.assert((Boolean) initParams.get('hasEditAccess'), 'Has no access');

        Id result = SplitCaseCtrl.doSplit(recordId, null, 'option2');

        Test.stopTest();

        System.assert(result != null, 'Result is Empty');
        System.assert(result.getSobjectType() == Case.SObjectType, 'Id has wrong type');

        System.assertEquals(3, [SELECT COUNT() FROM Case], 'Wrong Case records amount');
        System.assertEquals(3, [SELECT COUNT() FROM EmailMessage], 'Wrong EmailMessage records amount');

    }

    @IsTest
    static void testOption3() {
        Id recordId = getEmailMessageId('test');
        Id existingCaseId = getCaseId('test2');

        Test.startTest();

        Map<String, Object> initParams = SplitCaseCtrl.getInitParams(recordId);
        System.assert((Boolean) initParams.get('hasEditAccess'), 'Has no access');

        Id result = SplitCaseCtrl.doSplit(recordId, existingCaseId, 'option3');

        Test.stopTest();

        System.assert(result != null, 'Result is Empty');
        System.assert(result.getSobjectType() == EmailMessage.SObjectType, 'Id has wrong type');

        System.assertEquals(2, [SELECT COUNT() FROM Case], 'Wrong Case records amount');
        System.assertEquals(2, [SELECT COUNT() FROM EmailMessage], 'Wrong EmailMessage records amount');

    }

    @IsTest
    static void testOption4() {
        Id recordId = getEmailMessageId('test');
        Id existingCaseId = getCaseId('test2');

        Test.startTest();

        Map<String, Object> initParams = SplitCaseCtrl.getInitParams(recordId);
        System.assert((Boolean) initParams.get('hasEditAccess'), 'Has no access');

        Id result = SplitCaseCtrl.doSplit(recordId, existingCaseId, 'option4');

        Test.stopTest();

        System.assert(result != null, 'Result is Empty');
        System.assert(result.getSobjectType() == EmailMessage.SObjectType, 'Id has wrong type');

        System.assertEquals(2, [SELECT COUNT() FROM Case], 'Wrong Case records amount');
        System.assertEquals(3, [SELECT COUNT() FROM EmailMessage], 'Wrong EmailMessage records amount');

    }
    
    @IsTest
    static void testAttachmentOption1() {
        Id recordId = getEmailMessageId('test2');

        Test.startTest();

        Map<String, Object> initParams = SplitCaseCtrl.getInitParams(recordId);
        System.assert((Boolean) initParams.get('hasEditAccess'), 'Has no access');

        Id result = SplitCaseCtrl.doSplit(recordId, null, 'option1');

        Test.stopTest();

        System.assert(result != null, 'Result is Empty');
        System.assert(result.getSobjectType() == Case.SObjectType, 'Id has wrong type');

        System.assertEquals(3, [SELECT COUNT() FROM Case], 'Wrong Case records amount');
        System.assertEquals(2, [SELECT COUNT() FROM EmailMessage], 'Wrong EmailMessage records amount');
        System.assertEquals(1, [SELECT COUNT() FROM ATTACHMENT], 'Wrong attachment count');
    }
    
    @IsTest
    static void testAttachmentOption4() {
        Id recordId = getEmailMessageId('test2');
        Id existingCaseId = getCaseId('test2');

        Test.startTest();

        Map<String, Object> initParams = SplitCaseCtrl.getInitParams(recordId);
        System.assert((Boolean) initParams.get('hasEditAccess'), 'Has no access');

        Id result = SplitCaseCtrl.doSplit(recordId, existingCaseId, 'option4');

        Test.stopTest();

        System.assert(result != null, 'Result is Empty');
        System.assert(result.getSobjectType() == EmailMessage.SObjectType, 'Id has wrong type');

        System.assertEquals(2, [SELECT COUNT() FROM Case], 'Wrong Case records amount');
        System.assertEquals(3, [SELECT COUNT() FROM EmailMessage], 'Wrong EmailMessage records amount');
        System.assertEquals(2, [SELECT COUNT() FROM Attachment], 'Wrong attachment count');

    }

    @IsTest
    static void testException() {

        Boolean hasException = false;
        try {
            SplitCaseCtrl.doSplit(UserInfo.getUserId(), null, 'option1');
        } catch (Exception e) {
            hasException = true;
        }
        System.assert(hasException, 'There is no exception');

    }

}