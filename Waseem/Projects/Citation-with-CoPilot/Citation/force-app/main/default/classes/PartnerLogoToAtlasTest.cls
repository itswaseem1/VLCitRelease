@isTest
public class PartnerLogoToAtlasTest {
    @isTest
    static void partnerLogoTestMethod(){
        
        Account acc=new Account();
        acc.Name='test';
        insert acc;
        PartnerLogoToAtlas.accountDetails(acc.Id);
          Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        System.debug('test -'+contentVersion_2.ContentDocumentId);
        acc.Partner_Logo_Link__c = 'https://ContentDocument/'+contentVersion_2.ContentDocumentId+'/view';
        update acc;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PartnerLogoToAtlas.sendPartnerLogo(acc.Id);
        Test.stopTest();
    }
}