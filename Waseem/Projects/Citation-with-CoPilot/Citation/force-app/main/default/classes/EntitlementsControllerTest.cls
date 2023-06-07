@isTest
public class EntitlementsControllerTest {
	@isTest
    public static void testEntitlements() {
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User citationUser = new User(Alias = 'standt',Email = 'standarduser@citation.co.uk',EmailEncodingKey = 'UTF-8',
                                     LastName = 'citationUser',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = CitationProfile.Id,
                                     TimeZoneSidKey = 'Europe/London',UserName = 'citationFSLTestUser@testorg.com');
        insert citationUser;
        Account account = new Account(Name = 'Test Account',phone= '01123123',billingcity='London',billingpostalcode='SW1635HJ',billingcountry='United Kingdom',billingstreet='address 1');
        insert account;
        Contact c = new Contact(AccountId = account.ID,FirstName = 'test',LastName = 'test',email = 'test@test.com');
        insert c;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=account.Id, 
    					StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    	insert ent;
        EntitlementContact ec = new EntitlementContact(EntitlementId=ent.Id,ContactId=c.Id);
        insert ec;
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        System.runAs(u) {
            List<EntitlementContact> entCnts = EntitlementsController.getEntitlements(c.Id);
            system.assertEquals(1, entCnts.size(), 'Fetched Entitlement Contacts');
        }
        Test.stopTest();
    }
}