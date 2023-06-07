@isTest
public class ContactNoteUIControllerTest {
    @isTest
    public static void testUpdateRelatedContactNoteRecord() {
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'shaws');
        List<Contact> cList = new List<Contact>(); 
        cList.add(testContact); 
        insert cList;
        
         Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject',
            ContactId = cList[0].id
             
        );
        insert newCase;
         System.assertEquals(1, [SELECT COUNT() FROM Case], ' Case records amount');
        
        ContentVersion contVersion = new ContentVersion ();
        contVersion.Title = 'testTitle';
        contVersion.PathOnClient = 'testTitle'; 
        contVersion.VersionData = EncodingUtil.base64Decode('Test Version Data');
        List<ContentVersion> cvList = new List<ContentVersion>(); 
        cvList.add(contVersion); 
        insert cvList;
        Set<Id> verId = new Set<Id>();
        for(ContentVersion cvr : cvList) {
            verId.add(cvr.Id);
        }
        List<ContentVersion> versions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN:verId];
        List<Id> versIdList = new List<Id>(verId);
        List<ContentDocument> contDoc = [SELECT Id,LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId IN : verId];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cList[0].id;
        cdl.ContentDocumentId = contDoc[0].Id;
        cdl.shareType = 'V';
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>(); 
        cdList.add(cdl); 
        insert cdList;
        Test.startTest();
        Case a = [SELECT Id, subject FROM Case WHERE subject='test subject' LIMIT 1];
        ContactNoteUIController.fetchContactNotes(a.Id) ;
        Test.stopTest();
    }

}