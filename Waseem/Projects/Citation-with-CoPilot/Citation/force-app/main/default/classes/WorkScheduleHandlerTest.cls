@isTest
public class WorkScheduleHandlerTest {
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
        OperatingHours op2 = new OperatingHours(Name='Test Operating Hours 02',TimeZone = 'Europe/London');
        insert op2;
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            for (PermissionSet permSet : [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Admin_Permissions' OR Name = 'FSL_Admin_License' OR Name='Citation_Support_Admin']) {
                psas.add(new PermissionSetAssignment(
                    AssigneeId = citationUser.Id,
                    PermissionSetId = permSet.Id
                ));
            }
            insert psas;
        }
        ServiceResource serRes=new ServiceResource(Name='Test Resource',RelatedRecordId=citationUser.Id,ResourceType='T',IsActive=True);
        insert serRes;
        ServiceTerritory st = new ServiceTerritory(Name='HS Territory',OperatingHoursId=op.Id,IsActive=true);
        insert st;
        Datetime dt = Datetime.newInstance(System.today(), time.newInstance(0, 0, 0, 0));
        ServiceTerritoryMember sm = new ServiceTerritoryMember(ServiceResourceId=serRes.Id,ServiceTerritoryId=st.Id,EffectiveStartDate=dt);
        insert sm;
        Public_Holiday__c pb = new Public_Holiday__c(Name='Holiday 1',Holiday_Date__c=System.today(),Holiday_Working_Profile__c=op.Id,Public_Holiday_External_Id__c='001A');
        insert pb;
        Work_Schedule__c ws = new Work_Schedule__c(Advisor__c = citationUser.Id,Operating_Hours__c = op.Id);
        insert ws;
        Work_Schedule__c ws2 = new Work_Schedule__c(Advisor__c = citationUser2.Id,Operating_Hours__c = op.Id);
        insert ws2;
    }
    @isTest
    public static void testPublicHolidayUpdates() {
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        System.runAs(u) {
            Public_Holiday__c pb = [Select Id, Holiday_Date__c from Public_Holiday__c Limit 1];
            pb.Holiday_Date__c = System.today()+5;
            update pb;
        }
        Test.stopTest();
        Public_Holiday__c pb1 = [Select Id, Holiday_Date__c from Public_Holiday__c Limit 1 ];
        system.assertEquals(pb1.Holiday_Date__c, System.today()+5, 'Public Holidays Updated');
    }
    @isTest
    public static void testUpdates() {
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        OperatingHours op = [Select Id from OperatingHours where Name='Test Operating Hours 02' Limit 1];
        System.runAs(u) {
            Work_Schedule__c wrk = [Select Id,Operating_Hours__c from Work_Schedule__c where Advisor__c =:u.Id Limit 1];
            wrk.Operating_Hours__c=op.Id;
            update wrk;
        }
        Test.stopTest();
        Work_Schedule__c wk = [Select Id,Operating_Hours__c from Work_Schedule__c where Advisor__c =:u.Id Limit 1];
        system.assertEquals(wk.Operating_Hours__c, op.Id, 'Updated operating hours');
    }
   
    @isTest
    public static void testPublicHolidayDelete() {
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        System.runAs(u) {
            Public_Holiday__c pb = [Select Id, Holiday_Date__c from Public_Holiday__c Limit 1];
            delete pb;
        }
        Test.stopTest();
        List<Public_Holiday__c> pb = [Select Id, Holiday_Date__c from Public_Holiday__c];
        system.assertEquals(0, pb.size(), 'Public Holidays Deleted');
    }
     @isTest
    public static void testPublicHoliday() {
        Test.startTest();
        User u = [Select Id from User where Email = 'standarduser@citation.co.uk' Limit 1];
        OperatingHours op = [Select Id from OperatingHours where Name='Test Operating Hours 01' Limit 1];
        Work_Schedule__c wrk = [Select Id,Operating_Hours__c from Work_Schedule__c where Advisor__c =:u.Id Limit 1];
        wrk.Operating_Hours__c=op.Id;
        update wrk;
        Public_Holiday__c pb1 = new Public_Holiday__c(Name='Holiday 2',Holiday_Date__c=System.today(),Holiday_Working_Profile__c=op.Id,Public_Holiday_External_Id__c='001B');
        insert pb1;
        System.runAs(u) {
            Public_Holiday__c pb = [Select Id,Holiday_Date__c, Name from Public_Holiday__c where Public_Holiday_External_Id__c='001B' Limit 1];
            pb.Name = 'Updated Holiday';
            update pb;
            pb.Holiday_Date__c = pb.Holiday_Date__c+15;
            update pb;
        }
        Test.stopTest();
        Public_Holiday__c pb2 = [Select Id, Name from Public_Holiday__c where Public_Holiday_External_Id__c='001B' Limit 1 ];
        system.assertEquals(pb2.Name, 'Updated Holiday', 'Public Holidays Updated');
    }
    
}