@IsTest
public class ServiceAppointmentMeetingCreationTest {
    class JitterbitServer implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}');
            response.setStatusCode(200);
            return response;
        }
    }
    @testSetup
    static void dataCreation() {
        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='Citation Data admin'limit 1];
        User citationUser = new User(Alias = 'standt',Email = 'standarduser@citation.co.uk',EmailEncodingKey = 'UTF-8',LastName = 'citationUser',
                                     LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = CitationProfile.Id,TimeZoneSidKey = 'America/Los_Angeles',UserName = 'citationDataAdminTestUser@testorg.com',
                                     UserPermissionsKnowledgeUser = True,IsActive = True);
        insert citationUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();
            List<PermissionSetLicenseAssign> permissionsLicense = new List<PermissionSetLicenseAssign>();
            //SST-118 Change by Siddhartha-ValueLabs
            Set<String> setOfFSLLicense = new Set<String>{'Salesforce CPQ License', 'Field Service Scheduling','Field Service Mobile','Field Service Standard','Field Service Dispatcher','CRM User'};
            Set<Id> setOfFSLLicenseIds=new Set<Id>();
            for(PermissionSetLicense p: [select id  from PermissionSetLicense where MasterLabel in:setOfFSLLicense])
            {
                setOfFSLLicenseIds.add(p.id);
            }
            List<PermissionSetLicense> perSetsLicense = [SELECT Id,MasterLabel  FROM PermissionSetLicense where id in:setOfFSLLicenseIds];
            
            for(PermissionSetLicense per : perSetsLicense){
                permissionsLicense.add(new PermissionSetLicenseAssign(AssigneeId=citationUser.id,PermissionSetLicenseId=per.Id));            
            }
            insert permissionsLicense;
            
            List<Permissionset> perSets = [select id from Permissionset where name='Citation_Support_Admin' or name='SDP_PermissionSet'
                                           or name='FSL_Admin_Permissions'];
            for(Permissionset per : perSets){
                permissions.add(new PermissionSetAssignment(AssigneeId=citationUser.id,PermissionSetId=per.Id));            
            }
            insert permissions;
        }
        
        Account testAccount1 = new Account(Name = 'Test Account 1');
        insert testAccount1;
        Contact con = new Contact(LastName='test',AccountId =testAccount1.id,Main_User__c = 'yes',Email = 'abc@def.co.uk.invalid');
        insert con;
        workOrder wo1 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00,AccountId=testAccount1.id);
        insert wo1;
        workOrder wo2 = new workOrder(Status = 'New',Subject='FRA',Priority = 'Low',Duration =2.00);
        insert wo2;
        List<ServiceAppointment> servAppts = new List<ServiceAppointment>();
        ServiceAppointment saApp1 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS');
        servAppts.add(saApp1);
        ServiceAppointment saApp2 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Face-to-Face',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS');
        servAppts.add(saApp2);
        ServiceAppointment saApp3 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Face-to-Face',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'Citation');
        servAppts.add(saApp3);
        ServiceAppointment saApp4 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'Citation');
        servAppts.add(saApp4);
        ServiceAppointment saApp5 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Home Remote Audit',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'Citation',Meeting_ID__c = '12345');
        servAppts.add(saApp5);
        ServiceAppointment saApp6 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Home Remote Audit',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',Meeting_ID__c = '67890');
        servAppts.add(saApp6);
        ServiceAppointment saApp7 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Home Remote Audit',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',Meeting_ID__c = '12121');
        servAppts.add(saApp7);
        insert servAppts;
        FSL.GlobalAPIS.addStatusTransition('none','Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled','Confirmed');
        FSL.GlobalAPIS.addStatusTransition('Scheduled','Canceled');
        FSL.GlobalAPIS.addStatusTransition('Confirmed','Canceled');
        EnhancedLetterhead enhancLetter = new EnhancedLetterhead(name = 'Citation service appointment dispatch letterhead',LetterheadFooter = 'test',
                                                                 LetterheadHeader = 'test');
        insert enhancLetter;
        
        
    }
    @IsTest
    public static void testFetchCitationEmailBodyForFRA() {
        operatingHours hObj = new Operatinghours(Name = 'Test11');
        insert hObj;
        
        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'FRA Territory',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        insert stObj;
        FSL__Scheduling_Policy__c sp = new FSL__Scheduling_Policy__c(Business_Area__c=stObj.id,FSL__Description__c='FRA Territory');
        insert sp;
        WorkOrder w = [select id from WorkOrder where subject='FRA' limit 1];
        Contact con = [select id from contact where LastName='test' limit 1];
        ServiceAppointment saApp = new ServiceAppointment( FSL__Scheduling_Policy_Used__c=sp.id,ServiceTerritoryId=stObj.id,Status = 'none',ParentRecordId = w.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now().AddDays(6),ContactId = con.Id,Visit_Type__c = 'Face-to-Face',Meeting_Type__c='Fire Risk Assessment',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'Citation');
        insert saApp;
      //  User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
       // system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Confirmed';
            update saApp;
            system.assertEquals('Confirmed',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where  Meeting_Type__c='Fire Risk Assessment' and Business__c = 'Citation' and Visit_Type__c = 'Face-to-Face' limit 1].status,'success');
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Canceled';
        	saApp.Reason__c='Other';
            update saApp;
            system.assertEquals('Canceled',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where  Meeting_Type__c='Fire Risk Assessment' and Business__c = 'Citation' and Visit_Type__c = 'Face-to-Face' limit 1].status,'success');
            test.stopTest();
    //    }
    }
    @IsTest
    public static void testQMSOnlineMeetingCreation() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Virtual' and Business__c = 'QMS' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Confirmed';
            update saApp;
            system.assertEquals('Confirmed',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Virtual' and Business__c = 'QMS' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testQMSOfflineMeetingCreation() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Face-to-Face' and Business__c = 'QMS' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Confirmed';
            update saApp;
            system.assertEquals('Confirmed',[select status,Visit_Type__c,Business__c from serviceappointment where Visit_Type__c = 'Face-to-Face' and Business__c = 'QMS' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testCitOnlineMeetingCreation() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Virtual' and Business__c = 'Citation' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Confirmed';
            update saApp;
            system.assertEquals('Confirmed',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Virtual' and Business__c = 'Citation' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testCitOfflineMeetingCreation() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Face-to-Face' and Business__c = 'Citation' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Confirmed';
            update saApp;
            system.assertEquals('Confirmed',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Face-to-Face' and Business__c = 'Citation' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testCancelCITMeeting() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c,Reason__c from ServiceAppointment where Visit_Type__c = 'Home Remote Audit' and Business__c = 'Citation' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Canceled';
            saApp.Reason__c = 'Sickness';
            update saApp;
            system.assertEquals('Canceled',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Visit_Type__c = 'Home Remote Audit' and Business__c = 'Citation' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testCancelQMSMeeting() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c,Reason__c from ServiceAppointment where Meeting_ID__c = '67890' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Status = 'Canceled';
            saApp.Reason__c = 'Sickness';
            update saApp;
            system.assertEquals('Canceled',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Meeting_ID__c = '67890' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testUpdateQMSMeeting() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c,Reason__c from ServiceAppointment where Meeting_ID__c = '67890' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Visit_Type__c = 'Virtual';
            saApp.Status = 'Confirmed';
            saApp.SchedEndTime = System.today()+10;
            update saApp;
            /*operatingHours hObj = new Operatinghours(Name = 'Test');
          insert hObj;
            ServiceTerritory stObj = new ServiceTerritory(Name = 'QMS Territory',OperatingHoursId = hObj.Id,isActive = true);
            insert stObj;
            ServiceResource serRes = new ServiceResource(Name = 'test1',RelatedRecordId = u.id,IsActive = True);
                    insert serRes;  
            
            ServiceTerritoryMember stMem = new ServiceTerritoryMember(ServiceResourceId = serRes.id,ServiceTerritoryId = stObj.id,EffectiveStartDate = system.today());
           insert stMem;
            
            List<AssignedResource> assRes = new List<AssignedResource>{new AssignedResource(ServiceAppointmentId=saApp.id,ServiceResourceId=serRes.id)};
              insert assRes;
            delete assRes;*/
            system.assertEquals('Confirmed',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Meeting_ID__c = '67890' limit 1].status,'success');
            test.stopTest();
        }
    }
    @IsTest
    public static void testUpdateCITMeeting() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c,Reason__c,Account.name from ServiceAppointment where Meeting_ID__c = '12345' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Visit_Type__c = 'Virtual';
            update saApp;
            saApp.SchedStartTime = system.today()+5;
            saApp.SchedEndTime = system.today() +10;
            saApp.Status = 'Confirmed';
            update saApp;
            system.assertEquals('Confirmed',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Meeting_ID__c = '12345' limit 1].status,'success');
            system.assertEquals('Test Account 1', saApp.Account.name);
            test.stopTest();
        }
    }
    @IsTest
    public static void testUpdateCIT1Meeting() {
        ServiceAppointment saApp = [Select Status,Visit_Type__c,Business__c,Reason__c from ServiceAppointment where Meeting_ID__c = '12121' Limit 1];
        User u = [Select Id from User where Username='citationDataAdminTestUser@testorg.com' Limit 1];
        system.runAs(u){
            saApp.Status = 'Scheduled';
            update saApp;
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new JitterbitServer());
            saApp.Visit_Type__c = 'Face-to-Face';
            update saApp;
            system.assertEquals('Scheduled',[Select Status,Visit_Type__c,Business__c from ServiceAppointment where Meeting_ID__c = '12121' limit 1].status,'success');
            test.stopTest();
        }
    }
    
    @IsTest
    public static void testMethodForCommunityUser(){
        
        Id profileId = [Select Id From Profile Where Name ='Citation Customer Community Login User'].Id;
        Account acc = TestUtility.createAccount('Test Account');
        insert acc;
        Contact con = TestUtility.createContact('test','Contact','test@gmail.com',acc.Id);
        insert con;
        User u = TestUtility.createCommunityUser(con.Id,profileId,'Amit','Singh');
        
        workOrder wo1 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00);
        insert wo1;
        List<ServiceAppointment> servAppts = new List<ServiceAppointment>();
        ServiceAppointment saApp1 = new ServiceAppointment(Status = 'Scheduled',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS');
        servAppts.add(saApp1);
        ServiceAppointment saApp2 = new ServiceAppointment(Status = 'Confirmed',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),ContactId = con.Id,Visit_Type__c = 'Face-to-Face',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS');
        servAppts.add(saApp2);
        test.startTest();
        System.runAs( u ){
            ServiceAppointmentTriggerHandler.checkCommunityUser(servAppts);
            
        }
        insert servAppts;
        test.stopTest();
    }
    
    @IsTest
    public static void testMethodForMapResourcePref(){
        
        workOrder wo1 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00);
        insert wo1;
        
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
        
        ServiceResource serviceResourceRecord 
                        = new ServiceResource(Name='ResourceName2'
                                           , ResourceType ='T'
                                           , RelatedRecordId=tempUser.Id
                                           , IsActive=true);
    insert serviceResourceRecord;
        
        ServiceAppointmentTriggerHandler.mapResourcePref(serviceResourceRecord.Id,wo1.Id);
        
        
    }
    
    /*@IsTest
    public static void testMethodForCheckStatus() {
       
        workOrder wo2 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00);
        insert wo2;
        

        
        ServiceAppointment saApp2 = new ServiceAppointment(Status = 'Scheduled',ParentRecordId = wo2.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',
                                                           Subject=Label.s360_Scheduling_Priority_Subject
                                                          );
        
        insert saApp2;
        saApp2.Status='Completed';
        update saApp2;
        
       
    }   */
    
   /* @IsTest
    public static void testMethodForSchedulingPriority(){
        
        
        Account acc2 = new Account();
        acc2.put('Name', 'test123');
        acc2.put('CurrencyIsoCode', 'USD');
        acc2.put('AccountNumber', 'CD656092');
        acc2.put('Type', 'Customer - Direct');
        acc2.put('Industry', 'Apparel');
        acc2.put('AnnualRevenue', 350000000);
        acc2.put('Ownership', 'Public');
        acc2.put('Rating', 'Warm');
        acc2.put('Phone', '(336) 222-7000');
        acc2.put('Fax', '(336) 222-8000');
        acc2.put('Website', 'http://www.financialforce.com');
        acc2.put('TickerSymbol', 'BTXT');
        acc2.put('NumberOfEmployees', 9000);
        acc2.put('SIC', '546732');
        
        
        
        insert acc2;
        
        List<Site__c> siteList = new List<Site__c>();
        Site__c accSite1 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Main Site'
        );
        siteList.add(accSite1);
        Site__c accSite2 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Other Site'
        );
        siteList.add(accSite2);
        
        
        
        insert siteList;
        
        Milestone_Template__c milestone1 = new Milestone_Template__c(
            Name = 'Welcome Call',
            Business__c = 'Citation',
            Start_Date_Days__c = 0,
            Due_Date_Days__c = 2,
            Reference_Date_field__c = 'StartDate',
            Anniversary_Date_Months__c = 0,
            Case_Type__c = 'Non Visits',
            Status__c = 'Active'
        );
        insert milestone1;  
        
        WorkType workTypeObj1 = new WorkType(
            Name = 'Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = true
        );
        insert workTypeObj1;
        
        operatingHours hObj = new Operatinghours(Name = 'Test');
        insert hObj;
        
        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'Atlas On-Boarding',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        insert stObj;
        
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
            Milestone_Template__c = milestone1.Id,
            Work_Type__c = workTypeObj1.Id,
            subject__c = Label.s360_Scheduling_Priority_Subject,
            Description__c = Label.s360_Scheduling_Priority_Subject,
            ServiceTerritory__c = stObj.Id,
            WorkOrder_Record_Type__c='Citation Standard',
            Site_Repeat_Rule__c = 'All',
            Service_Contact__c = 'Main Site Contact',
            meeting_type__c = 'HR 1st New',
            Customer_Friendly_Meeting_Name__c = 'Test'
        );
        
        insert mwtObj;
        
        
        
        
        workOrder wo1 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00,AccountSite__c=siteList[0].Id,Milestone_Work_Type__c=mwtObj.Id);
        insert wo1;
        
        workOrder wo2 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00,AccountSite__c=siteList[1].Id,Milestone_Work_Type__c=mwtObj.Id);
        insert wo2;
        
        ServiceAppointment saApp1 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',
                                                           Subject=Label.s360_Scheduling_Priority_Subject , AccountSite__c=siteList[0].Id
                                                          );
        
        ServiceAppointment saApp2 = new ServiceAppointment(Status = 'none',ParentRecordId = wo2.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',
                                                           Subject=Label.s360_Scheduling_Priority_Subject , AccountSite__c=siteList[1].Id
                                                          );
        
        
        
        test.startTest();
        insert saApp1;
        insert saApp2;
       
        test.stopTest();
        
        
        
    }  
    
    
     @IsTest
    public static void testMethodForSchedulingPriority3(){
        
        
        Account acc2 = new Account();
        acc2.put('Name', 'test123');
        acc2.put('CurrencyIsoCode', 'USD');
        acc2.put('AccountNumber', 'CD656092');
        acc2.put('Type', 'Customer - Direct');
        acc2.put('Industry', 'Apparel');
        acc2.put('AnnualRevenue', 350000000);
        acc2.put('Ownership', 'Public');
        acc2.put('Rating', 'Warm');
        acc2.put('Phone', '(336) 222-7000');
        acc2.put('Fax', '(336) 222-8000');
        acc2.put('Website', 'http://www.financialforce.com');
        acc2.put('TickerSymbol', 'BTXT');
        acc2.put('NumberOfEmployees', 9000);
        acc2.put('SIC', '546732');
        
        
        
        insert acc2;
        
        List<Site__c> siteList = new List<Site__c>();
        Site__c accSite1 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Main Site'
        );
        siteList.add(accSite1);
        Site__c accSite2 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Other Site'
        );
        siteList.add(accSite2);
        
        
        
        insert siteList;
        
        Milestone_Template__c milestone1 = new Milestone_Template__c(
            Name = 'Welcome Call',
            Business__c = 'Citation',
            Start_Date_Days__c = 0,
            Due_Date_Days__c = 2,
            Reference_Date_field__c = 'StartDate',
            Anniversary_Date_Months__c = 0,
            Case_Type__c = 'Non Visits',
            Status__c = 'Active'
        );
        insert milestone1;  
        
        WorkType workTypeObj1 = new WorkType(
            Name = 'Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = true
        );
        insert workTypeObj1;
        
        operatingHours hObj = new Operatinghours(Name = 'Test');
        insert hObj;
        
        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'Atlas On-Boarding',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        insert stObj;
        
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
            Milestone_Template__c = milestone1.Id,
            Work_Type__c = workTypeObj1.Id,
            subject__c = 'Test Subject',
            Description__c = 'Test Subject',
            ServiceTerritory__c = stObj.Id,
            WorkOrder_Record_Type__c='Citation Standard',
            Site_Repeat_Rule__c = 'All',
            Service_Contact__c = 'Main Site Contact',
            meeting_type__c = 'HR 1st New',
            Customer_Friendly_Meeting_Name__c = 'Test'
        );
        
        insert mwtObj;
        
        
        
        
        workOrder wo1 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00,AccountSite__c=siteList[0].Id,Milestone_Work_Type__c=mwtObj.Id);
        insert wo1;
        
        workOrder wo2 = new workOrder(Status = 'New',Priority = 'Low',Duration =2.00,AccountSite__c=siteList[1].Id,Milestone_Work_Type__c=mwtObj.Id);
        insert wo2;
        
        ServiceAppointment saApp1 = new ServiceAppointment(Status = 'none',ParentRecordId = wo1.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',
                                                           Subject='Test Subject' , AccountSite__c=siteList[0].Id
                                                          );
        
        ServiceAppointment saApp2 = new ServiceAppointment(Status = 'none',ParentRecordId = wo2.Id,EarliestStartTime = DateTime.now(),
                                                           DueDate = DateTime.now(),Visit_Type__c = 'Virtual',
                                                           SchedStartTime = system.today()+3,SchedEndTime = system.today() +5,Business__c = 'QMS',
                                                           Subject='Test Subject' , AccountSite__c=siteList[1].Id
                                                          );
        
        
        
        test.startTest();
        insert saApp1;
        insert saApp2;
       
        test.stopTest();
        
        
        
    }  */
}