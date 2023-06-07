@isTest
public class ContactAdviceDetailsHandlerTest {
    @testSetup
    static void dataCreation() {
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='Jitterbit Integration'];
        User citationUser = new User(Alias = 'standt',Email = 'standarduser@citation.co.uk',EmailEncodingKey = 'UTF-8',
                                     LastName = 'citationUser',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = CitationProfile.Id,
                                     TimeZoneSidKey = 'Europe/London',UserName = 'citationFSLTestUser@testorg.com');
        insert citationUser;
        Account account = new Account(Name = 'Test Account',phone= '01123123',billingcity='London',billingpostalcode='SW1635HJ',billingcountry='United Kingdom',billingstreet='address 1');
        insert account;
        Contact c = new Contact(AccountId = account.ID,FirstName = 'test',LastName = 'test',email = 'test@test.com',Advice_Card_Number__c='0001A',Pin_Set_Date__c=System.today(),Advice_Pin__c=1234,
                                TimePeriodBeforeAdviceNumberBlock__c=30,Can_Access_Advice__c=true);
        insert c;
    }
    @isTest
    private static void testPinUpdate(){
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser'];
        System.runAs(citationUser) {
            Contact c = [Select Advice_Pin__c,Pin_Set_Date__c from Contact where Email='test@test.com' Limit 1];
            Test.startTest();
            c.Advice_Pin__c = 12345;
            update c;
            c.Pin_Set_Date__c = System.today()+5;
            update c;
            Test.stopTest();
            system.assertEquals(null, [Select Pin_Set_Date__c from Contact where Id=:c.Id Limit 1].Pin_Set_Date__c,'Pin Set Date Updated');
        }
    }
}