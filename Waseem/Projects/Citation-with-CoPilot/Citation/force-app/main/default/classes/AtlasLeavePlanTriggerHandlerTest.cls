@isTest
public class AtlasLeavePlanTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User citationUser = new User(
            Alias = 'standt',
            Email = 'standarduser@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'citationUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = CitationProfile.Id,
            TimeZoneSidKey = 'Europe/London',
            UserName = 'citationFSLTestUser@testorg.com'
        );
        insert citationUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            for (PermissionSet permSet : [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Admin_Permissions' OR Name = 'FSL_Admin_License']) {
                psas.add(new PermissionSetAssignment(
                    AssigneeId = citationUser.Id,
                    PermissionSetId = permSet.Id
                ));
            }
            insert psas;
        }
        ServiceResource testResource = new ServiceResource(
            Name = 'testResource',
            ResourceType = 'T',
            RelatedRecordId = citationUser.Id,
            IsActive = true
        );
        insert testResource;
    }

    @isTest
    private static void testCreateNewAtlasLeavePlan() {
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser'];
        System.runAs(citationUser) {
            Atlas_Leave_Plan__c newPlan = new Atlas_Leave_Plan__c();
                newPlan.From_Date__c = datetime.now();
                newPlan.To_Date__c = datetime.now().addDays(1);
                newPlan.User_email__c = citationUser.Id;
            Test.startTest();
            insert newPlan;
            Test.stopTest();
    
            ResourceAbsence testAbsence = [SELECT Id, Start, End FROM ResourceAbsence][0];
            System.assertEquals(
                true,
                Datetime.newInstance(testAbsence.Start.dateGmt(), testAbsence.Start.timeGmt()).date() == newPlan.From_Date__c.date() && Datetime.newInstance(testAbsence.End.dateGmt(), testAbsence.End.timeGmt()).date() == newPlan.To_Date__c.date(),
                'Resource Absence wasn\'t created'
            );
        }
    }

    @isTest
    private static void testUpdateAtlasLeavePlan() {
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser'];
        System.runAs(citationUser) {
            Atlas_Leave_Plan__c newPlan = new Atlas_Leave_Plan__c();
                newPlan.From_Date__c = datetime.now();
                newPlan.To_Date__c = datetime.now().addDays(1);
                newPlan.User_email__c = citationUser.Id;
            insert newPlan;
            Test.startTest();
            newPlan.From_Date__c = newPlan.From_Date__c.addDays(1);
            newPlan.To_Date__c = newPlan.To_Date__c.addDays(1);
            update newPlan;
            ResourceAbsence testAbsence = [SELECT Id, Start,FSL__Approved__c, End FROM ResourceAbsence][0];
            //When ResourceAbsence updates with atlas leave plan
            System.assertEquals(testAbsence.Start.date(), newPlan.From_Date__c.date(), 'Start date was updated');
            System.assertEquals(testAbsence.End.date(), newPlan.To_Date__c.date(), 'End date was updated');
            testAbsence.Start=datetime.now();
            testAbsence.End=datetime.now().addDays(1);
            update testAbsence;
            newPlan.From_Date__c = newPlan.From_Date__c.addDays(1);
            newPlan.To_Date__c = newPlan.To_Date__c.addDays(1);
            update newPlan;
            //When ResourceAbsence not updates with atlas leave plan
            System.assertNotEquals(testAbsence.Start.date(), newPlan.From_Date__c.date(), 'Start date was\'t updated');
            System.assertNotEquals(testAbsence.End.date(), newPlan.To_Date__c.date(), 'End date was\'t updated');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testUpdateAtlasLeavePlanStatus() {
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser'];
        System.runAs(citationUser) {
            Atlas_Leave_Plan__c newPlan = new Atlas_Leave_Plan__c();
                newPlan.From_Date__c = datetime.now();
                newPlan.To_Date__c = datetime.now().addDays(1);
                newPlan.User_email__c = citationUser.Id;
            insert newPlan;
            Test.startTest();
            newPlan.Status__c = 'Cancelled';
            update newPlan;
            Test.stopTest();
    
            System.assertEquals(newPlan.Status__c, 'Cancelled', 'Resource Absence was deleted');
        }
    }
}