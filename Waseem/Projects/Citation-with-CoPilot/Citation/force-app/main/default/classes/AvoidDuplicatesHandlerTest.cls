@isTest
public class AvoidDuplicatesHandlerTest {
    @testSetup
    static void dataCreation() {
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User citationUser = new User(Alias = 'standt',Email = 'standarduser@citation.co.uk',EmailEncodingKey = 'UTF-8',
                                     LastName = 'citationUser',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = CitationProfile.Id,
                                     TimeZoneSidKey = 'Europe/London',UserName = 'citationFSLTestUser@testorg.com');
        insert citationUser;
        User citationUser2 = new User(Alias = 'standt2',Email = 'standarduser2@citation.co.uk',EmailEncodingKey = 'UTF-8',
                                      LastName = 'citationUser2',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = CitationProfile.Id,
                                      TimeZoneSidKey = 'Europe/London',UserName = 'citationFSLTestUser2@testorg.com');
        insert citationUser2;
        OperatingHours op = new OperatingHours(Name='Test Operating Hours 01',TimeZone = 'Europe/London');
        insert op;
        Work_Schedule__c ws = new Work_Schedule__c(Advisor__c = citationUser.Id,Operating_Hours__c = op.Id);
        insert ws;
        Work_Schedule__c ws2 = new Work_Schedule__c(Advisor__c = citationUser2.Id,Operating_Hours__c = op.Id);
        insert ws2;
    }
    @isTest
    public static void testDuplicatesInsertOp() {
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        System.runAs(u) {
            OperatingHours op = [Select Id from OperatingHours Limit 1];
            Work_Schedule__c ws2 = new Work_Schedule__c(Advisor__c = u.Id,Operating_Hours__c = op.Id);
            try{
        		insert ws2;
            }catch(Exception e){
                List<Work_Schedule__c> wrksch = [Select Id from Work_Schedule__c where Advisor__c =: u.Id];
                system.assertEquals(1, wrksch.size(), 'Record not inserted');
            }
        }
        Test.stopTest();
    }
    @isTest
    public static void testDuplicatesUpdateOp() {
       Test.startTest();
        User u1 = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        User u2 = [Select Id from User where Email = 'standarduser2@citation.co.uk' Limit 1];
        System.runAs(u1) {
            Work_Schedule__c wrk = [Select Id from Work_Schedule__c where Advisor__c =:u2.Id Limit 1];
            try{
                wrk.Advisor__c = u1.Id;
                update wrk;
            }catch(Exception e){
                List<Work_Schedule__c> wrksch = [Select Id from Work_Schedule__c where Advisor__c =: u2.Id];
                system.assertEquals(1, wrksch.size(), 'Record not inserted');
            }
        }
        Test.stopTest();
    }
}