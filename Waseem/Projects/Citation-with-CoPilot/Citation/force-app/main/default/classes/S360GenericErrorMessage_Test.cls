@isTest
public class S360GenericErrorMessage_Test {
    
    @testSetup static void setupData() {
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('FSL__Work_Rule__c').getDescribe().getRecordTypeInfosByName().get('Field Service - Working Territories').getRecordTypeId();
        FSL__Work_Rule__c wrObj = new FSL__Work_Rule__c(
            Name = 'Test1',
            RecordTypeId=devRecordTypeId
        );
        insert wrObj;
        
        FSL__Scheduling_Policy__c sp = new FSL__Scheduling_Policy__c(Name='Test1');
        insert sp;
        FSL__Scheduling_Policy__c sp1 = new FSL__Scheduling_Policy__c(Name='Test2');
        insert sp1;
        
        operatingHours hObj = new Operatinghours(Name = 'New_Operating_Hour');
        insert hObj;
        
        operatingHours hObj1 = new Operatinghours(Name = 'Operating_Hour');
        insert hObj1;
        
        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'Atlas On-Boarding',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        insert stObj;
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = 'firstName',  
            LastName = 'lastName',  
            email = uniqueName + '@citation.co.uk',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = [Select Id From Profile Where Name ='System Administrator'].Id
        );   
        
        insert tempUser;
        FSL__User_Territory__c UT = new FSL__User_Territory__c(FSL__ServiceTerritory__c=stObj.Id,FSL__User__c=tempUser.Id);
        insert UT;
    }
    
    @isTest
    public static void TestMethodForCheckDeletePermissions(){
        
        ServiceTerritory stObj=[select Id from ServiceTerritory where Name = 'Atlas On-Boarding' limit 1];

        Test.startTest();
        User systemTestUser = TestHarness.createTestUser();
        systemTestUser.UserRoleId=[select UserRoleId from user where id=: UserInfo.getUserId()].UserRoleId;
        update systemTestUser;
        System.runAs(systemTestUser){
            delete [select Id from FSL__User_Territory__c where FSL__ServiceTerritory__c=:stObj.Id limit 1];
            delete stObj;
            delete [select Id from Operatinghours where Name = 'Operating_Hour' limit 1];
            delete [select Id from FSL__Scheduling_Policy__c where Name = 'Test2' limit 1];
            delete [select Id from FSL__Work_Rule__c where Name = 'Test1' limit 1];
        }
        Test.stopTest();
    }

}