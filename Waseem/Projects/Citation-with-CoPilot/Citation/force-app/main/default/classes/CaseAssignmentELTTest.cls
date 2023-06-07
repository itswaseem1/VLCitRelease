@isTest
public class CaseAssignmentELTTest {
    @testSetup
    static void setup() {
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.put('Name', '$$$$$$$Product Services$$$$$$$');
        acc.put('CurrencyIsoCode', 'USD');
        acc.put('AccountNumber', 'CD656092');
        acc.put('Type', 'Customer - Direct');
        acc.put('Industry', 'Apparel');
        acc.put('AnnualRevenue', 350000000);
        acc.put('Ownership', 'Public');
        acc.put('Rating', 'Warm');
        acc.put('Phone', '(336) 222-7000');
        acc.put('Fax', '(336) 222-8000');
        acc.put('Website', 'http://www.financialforce.com');
        acc.put('TickerSymbol', 'BTXT');
        acc.put('NumberOfEmployees', 9000);
        acc.put('SIC', '546732');
        
        insert acc;
        
      /*  AccountTeamMember acmObj = new AccountTeamMember(TeamMemberRole ='Preferred ELT Advisor', AccountId=acc.Id, userId = userinfo.getuserId(), OpportunityAccessLevel ='None', CaseAccessLevel='Edit', AccountAccessLevel ='Read');
        insert acmObj;*/
        
        List<Case> caselist  = new list<Case>();
        Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();
        Case casephone = new Case();
        casephone.RecordTypeId=rTId;
        casephone.Origin='Phone - Atlas Support';
        casephone.Status='New';
        caselist.add(casephone);
        Case cemail = new Case();
        cemail.RecordTypeId=rTID;
        cemail.Origin='Email - Atlas Support';
        cemail.Status='New';
        caselist.add(cemail);
        insert(caselist);
        
        List<Advisor_Availability__c> aaList = new List<Advisor_Availability__c>();
        Advisor_Availability__c aaObj = new Advisor_Availability__c(Advisor__c = userinfo.getUserId(), Availability__c='Available');
        insert aaObj;
        
        operatingHours hObj = new Operatinghours(Name = 'Test');
        insert hObj;
        
        work_Schedule__c wsObj = new work_Schedule__c(Advisor__c =userinfo.getUserId(), operating_hours__c = hObj.Id);
        
        insert wsObj;
        
        List<TimeSlot> timeSlotList;
        TimeSlot monday = new TimeSlot(DayOfWeek='Monday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );  
        TimeSlot tuesday = new TimeSlot(DayOfWeek='Tuesday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );   
        TimeSlot wednesday = new TimeSlot(DayOfWeek='Wednesday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );  
        TimeSlot thursday = new TimeSlot(DayOfWeek='Thursday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );  
        TimeSlot friday = new TimeSlot(DayOfWeek='Friday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );  
        TimeSlot saturday = new TimeSlot(DayOfWeek='Saturday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );  
        TimeSlot sunday = new TimeSlot(DayOfWeek='Sunday', startTime=time.newInstance(00, 00, 00,0), endTime=time.newInstance(23, 59, 59,0),OperatingHoursId=hObj.Id );  
        
        TimeSlotList = new List<TimeSlot>{monday,tuesday,wednesday,thursday,friday,saturday,sunday}; 
        insert TimeSlotList;
        
    }
    
    static testMethod void transfercase(){
        
        Account acc =[SELECT Id FROM Account LIMIT 1];
        User systemTestUser = TestHarness.createTestUser();
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'ELT_HS_Transfer_Manager_Permission_Set'
        ];
        insert new PermissionSetAssignment(
            AssigneeId = systemTestUser.id,
            PermissionSetId = ps.Id
        );
        
        
      //  User systemTestUser2 = TestHarness.createTestUser();
        
        Profile p = [select id from profile where name='System Administrator'];
        User testUser = new User();
        testUser.put('FirstName' , '$hhhhghj');
        testUser.put('LastName' , ' Developer$hgkm');
        testUser.put('Alias' , '$mdeyh');
        testUser.put('Email' , 'productservices2345@financialforce.com');
        testUser.put('Username' , 'financialforce666productservicesdevloper@financialforce.com');
        testUser.put('CommunityNickname' , '$FFPSDMD777T$');
        testUser.put('Phone' , '555.555.5555');
        testUser.put('IsActive' , true);
        testUser.put('ProfileId' , p.id);
        testUser.put('TimeZoneSidKey' , 'America/New_York');
        testUser.put('LocaleSidKey' , 'en_US');
        testUser.put('EmailEncodingKey' , 'ISO-8859-1');
        testUser.put('LanguageLocaleKey' , 'en_US');
        testUser.put('Title' , 'Product Service Developer and Tester11');
        testUser.put('CompanyName' , 'FinancialForce Test Company PS');

        insert testUser;
        PermissionSet ps2 = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'ELT_HS_Transfer_Manager_Permission_Set'
        ];
        insert new PermissionSetAssignment(
            AssigneeId = testUser.id,
            PermissionSetId = ps2.Id
        );
        
     operatinghours hOp =[SELECT Id from OperatingHours LIMIT 1];
        
        System.runAs(systemTestUser) {
            
                 
              work_Schedule__c wsObj = new work_Schedule__c(Advisor__c =systemTestUser.Id, operating_hours__c = hOp.Id);
        
        insert wsObj;
            
           
              work_Schedule__c wsObj2 = new work_Schedule__c(Advisor__c =testUser.Id, operating_hours__c = hOp.Id);
        
        insert wsObj2;

             AccountTeamMember acmObj = new AccountTeamMember(TeamMemberRole ='Preferred ELT Advisor', AccountId=acc.Id, userId = systemTestUser.Id, OpportunityAccessLevel ='None', CaseAccessLevel='Edit', AccountAccessLevel ='Read');
        	insert acmObj;
            Test.startTest();
             Advisor_Availability__c aaObj = new Advisor_Availability__c(Advisor__c = systemTestUser.Id, Availability__c='Available');
        	insert aaObj;
            Group edQueue = [select Id from Group where DeveloperName='ELT_Advice' AND Type = 'Queue'];
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = systemTestUser.Id;
            member.GroupId = edQueue.Id;
            
            insert member;
            
            Group hsQueue = [select Id from Group where DeveloperName='H_S_Advice' AND Type = 'Queue'];
            GroupMember member2 = new GroupMember();
            member2.UserOrGroupId = testUser.Id;
            member2.GroupId = hsQueue.Id;
            
            insert member2;
           //Id etQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'ELT_Advice' and Type = 'Queue'].Id;
            case caseObj =[SELECT Id, ownerId from Case LIMIT 1];
            caseObj.ownerId = edQueue.Id;
            update caseObj;
            System.assertEquals(edQueue.Id, caseObj.ownerId , 'success');
            Test.stopTest();    
        }
        
    }
     static testMethod void advisorAvailTest(){
        
         test.startTest();
          User systemTestUser = TestHarness.createTestUser();
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'ELT_HS_Transfer_Manager_Permission_Set'
        ];
         
         List<AdvisorAvailabilityWrapper> aaList = new List<AdvisorAvailabilityWrapper>();
         AdvisorAvailabilityWrapper aaObj1 = new AdvisorAvailabilityWrapper(userinfo.getuserId(), datetime.newInstance(2000, 01, 01, 00, 00, 00));
         AdvisorAvailabilityWrapper aaObj2 = new AdvisorAvailabilityWrapper(systemTestUser.Id, datetime.newInstance(2001, 01, 01, 00, 00, 00));
         BusinessHoursCalculator bObj = new BusinessHoursCalculator();
         bObj.isBusinessDay(Date.today());
         bObj.getStartTime(system.now());
         bObj.nextBusinessDay(system.now());
         aaList.add(aaObj1);
         aaList.add(aaObj2);
         aaList.sort();
         System.assertEquals(2,aaList.size() , 'success');
         test.stopTest();
    }
    
    static testMethod void testMethod2(){
        
        test.startTest();
        Advisor_Availability__c aaObj = new Advisor_Availability__c(Advisor__c = userinfo.getUserId(), Availability__c='Available');
        insert aaObj;
        Map <Id, Advisor_Availability__c> p = new Map<Id, Advisor_Availability__c>();
        p.put(aaObj.Id, aaObj);
        Set<id> userId = new Set<Id>{userinfo.getUserId()};
            
            case caseObj =[SELECT Id, ownerId from Case LIMIT 1];
        CaseAssignmentELTHelper.assignmentForPreferredAdvisors(caseObj, p, userId);
        System.assertEquals('Available',aaObj.Availability__c , 'success');
        test.stopTest();
    }
   
}