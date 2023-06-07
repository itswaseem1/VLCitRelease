@isTest
public with sharing class ServiceResourceTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User citationUser = new User(
            Alias = 'standt',
            Email = 'standarduser@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'ServiceResourceTriggerHandlerTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = CitationProfile.Id,
            UserRoleId = [SELECT Id From UserRole WHERE Name ='System Admin'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
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
        
        insertLeavePlan();
        
    }

    @isTest
    private static void testCreateNewServiceResource() {
        User citationUser = [SELECT Id FROM User WHERE LastName = 'ServiceResourceTriggerHandlerTest'];
        System.runAs(citationUser) {
            ServiceResource testResource = new ServiceResource(
                Name = 'testResource',
                ResourceType = 'T',
                RelatedRecordId = citationUser.Id,
                IsActive = true
            );
            Test.startTest();
            insert testResource;
            Test.stopTest();
            List<ResourceAbsence> testAbsences = [SELECT Id, Start, End FROM ResourceAbsence];
            System.assertEquals(1, testAbsences.size(), 'Resource Absence wasn\'t created');
        }
    }

    @isTest
    private static void testUpdateNewServiceResource() {
        User citationUser = [SELECT Id FROM User WHERE LastName = 'ServiceResourceTriggerHandlerTest'];
        System.runAs(citationUser) {
            ServiceResource testResource = new ServiceResource(
                Name = 'testResource',
                ResourceType = 'T',
                RelatedRecordId = citationUser.Id,
                IsActive = false
            );
            insert testResource;
            Test.startTest();
            testResource.IsActive = true;
            update testResource;
            Test.stopTest();
    
            List<ResourceAbsence> testAbsences = [SELECT Id, Start, End FROM ResourceAbsence];
            System.assertEquals(1, testAbsences.size(), 'Resource Absence wasn\'t created');
        }
    }
    
    @future
    static void insertLeavePlan()
    {
        Atlas_Leave_Plan__c newPlan = new Atlas_Leave_Plan__c();
        newPlan.From_Date__c = datetime.now();
        newPlan.To_Date__c = datetime.now().addDays(1);
        newPlan.User_email__c = [SELECT Id FROM User WHERE LastName = 'ServiceResourceTriggerHandlerTest'].Id;   
        insert newPlan;
    }
}