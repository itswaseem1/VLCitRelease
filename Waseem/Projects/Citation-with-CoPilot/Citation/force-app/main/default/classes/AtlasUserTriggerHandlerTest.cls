@isTest
public class AtlasUserTriggerHandlerTest {
    @testSetup
    static void dataCreation() {
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User citationUser = new User(Alias = 'standt',Email = 'standarduser@citation.co.uk',EmailEncodingKey = 'UTF-8',
                                     LastName = 'citationUser',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = CitationProfile.Id,
                                     TimeZoneSidKey = 'Europe/London',UserName = 'citationFSLTestUser@testorg.com');
        insert citationUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Citation_Support_Admin' Limit 1];
            PermissionSetAssignment psas = new PermissionSetAssignment(AssigneeId = citationUser.Id,
                    PermissionSetId = permSet.Id);
            insert psas;
        }
        Account account = new Account(Name = 'Test Account',phone= '01123123',billingcity='London',billingpostalcode='SW1635HJ',billingcountry='United Kingdom',billingstreet='address 1');
        insert account;
        Contact c = new Contact(AccountId = account.ID,FirstName = 'test',LastName = 'test',email = 'test@test.com');
        insert c;
        Atlas_User__c atlasUser = new Atlas_User__c(Account__c=account.ID,Contact__c=c.Id,Can_Access_Communities__c=true,UserID__c='1234',Name='0001');
        insert atlasUser;
    }
   @isTest
    public static void testContactUpdates() {
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        System.runAs(u) {
            Atlas_User__c atlasUser = [Select Id, Can_Access_Communities__c from Atlas_User__c Limit 1];
            atlasUser.Can_Access_Communities__c = false;
            update atlasUser;
        }
        Test.stopTest();
        User uss = [Select Id,IsActive from User where Email ='test@test.com.invalid' Limit 1 ];
        system.assertEquals(false, uss.IsActive, 'Community User Updated');
    }
    
}