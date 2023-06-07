@isTest
public with sharing class ServiceAppointmentTriggerEmailHelperTest {
    class JitterbitServer implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}');
            response.setStatusCode(200);
            return response;
        }
    } 
    @TestSetup
    static void makeData(){
        
        UserRole userRole = new UserRole(Name = 'System Admin');
        insert userRole;

        Profile citationProfile = [SELECT Id FROM Profile WHERE Name='Citation Data admin'limit 1];
        User citationUser = new User(
            Alias = 'standt',
            Email = 'standarduser@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'citationUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = CitationProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'citationFSLTestUser@testorg.com',
            UserPermissionsKnowledgeUser = True,
            userRoleId = userRole.Id,
            IsActive = True
            
        );
        insert citationUser;
         
        User citationUser2 = new User(
            Alias = 'standt2',
            Email = 'standarduser2@citation.co.uk',
            EmailEncodingKey = 'UTF-8',
            LastName = 'citationUser2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = CitationProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'citationFSLTestUser2@testorg.com',
            UserPermissionsKnowledgeUser = True,
            IsActive = True
            
        );
        insert citationUser2;
        
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
                permissionsLicense.add(new PermissionSetLicenseAssign(AssigneeId=citationUser2.id,PermissionSetLicenseId=per.Id)); 
            }
            insert permissionsLicense;
            
            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            
            for (PermissionSet permSet : [SELECT Id FROM PermissionSet WHERE Name = 'SDP_PermissionSet' OR Name = 'General_s360_permission_set' OR Name = 'FSL_Admin_License' OR Name = 'FSL_Admin_Permissions'
                                          OR Name = 'Citation_Support_Admin' OR Name = 'FSL_Dispatcher_License' OR Name = 'FSL_Dispatcher_Permissions'
                                          OR Name = 'Referrals_Access' OR Name = 'FSL_Resource_License' OR Name = 'FSL_Resource_Permissions']) {
                                              psas.add(new PermissionSetAssignment(
                                                  AssigneeId = citationUser.Id,
                                                  PermissionSetId = permSet.Id
                                              ));
                                              psas.add(new PermissionSetAssignment(
                                                  AssigneeId = citationUser2.Id,
                                                  PermissionSetId = permSet.Id
                                              ));
                                              
                                          }
            insert psas;
            
        }
        
        System.runAs(citationUser){
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = 'PROFESSIONAL ACTIVITIES';
        acc.FT_Employees__c = 6;
        acc.PT_Employees__c = 1;
        acc.Sites__c = 2;
        acc.BillingCity = 'City';
        acc.BillingCountry = 'GA';
        acc.BillingPostalCode = '12345';
        acc.BillingState = 'state';
        acc.BillingStreet = 'street';
        
        insert acc;
        List<Site__c> siteList = new List<Site__c>();
        Site__c accSite1 = new Site__c(
            Account__c = acc.Id,
            Active__c = false,
            Country__c = 'ROI',
            Postcode__c = 'BT098',
            Street__c = 'test',
            Site_Type__c = 'Main Site'
        );
        siteList.add(accSite1);   
        
        insert siteList;
        
        Contact con = new Contact();
        con.LastName='test';
        con.AccountId =acc.id;
        con.Main_User__c = 'yes';
        con.Email = 'poonamdevi@citation.co.uk';
        insert con;
        
        
        
        List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
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
        
        milestoneList.add(milestone1);
        insert milestoneList;
        
        List<WorkType> workTypeList = new List<WorkType>();   
        WorkType workTypeObj1 = new WorkType(
            Name = 'Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = true
        );
        workTypeList.add(workTypeObj1);
        
        WorkType workTypeObj2 = new WorkType(
            Name = 'Non Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = false
        );
        workTypeList.add(workTypeObj2);
        
        WorkType workTypeObj3 = new WorkType(
            Name = 'Non Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = false
        );
        workTypeList.add(workTypeObj3);
        insert workTypeList;
        
        
        operatingHours hObj = new Operatinghours(Name = 'Test');
        insert hObj;
        List<ServiceTerritory> serviceTerritoryList = new List<ServiceTerritory>(); 
        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'H&S Territory',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        serviceTerritoryList.add(stObj);
        
        ServiceTerritory stObj1 = new ServiceTerritory(
            Name = 'Noviqa Territory',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        serviceTerritoryList.add(stObj1); 
        ServiceTerritory stObj2 = new ServiceTerritory(
            Name = 'QMS Territory',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        serviceTerritoryList.add(stObj2); 
        insert serviceTerritoryList;
        
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[0].Id,
            Work_Type__c = WorkTypeList[0].Id,
            subject__c = 'Test subject',
            Description__c = 'Test Description',
            ServiceTerritory__c = ServiceTerritoryList[0].Id,
            Site_Repeat_Rule__c = 'All',
            Service_Contact__c = 'Main User',
            WorkOrder_Record_Type__c='Citation Standard',
            meeting_type__c = 'HR 1st New',
            Customer_Friendly_Meeting_Name__c = 'test'
        ); 
        
        insert mwtObj;
        List<workOrder> workOrderList = new List<workOrder>(); 
        workOrder wo = new workOrder();
        wo.Status = 'New';
        wo.Priority = 'Low';
        wo.Duration =2.00;
        workOrderList.add(wo);
        
        workOrder wo1 = new workOrder();
        wo1.Status = 'New';
        wo1.Priority = 'Low';
        wo1.Duration =2.00;
        wo1.ServiceTerritoryId = serviceTerritoryList[2].id;
        wo1.Visit_Type__c = 'Face-To-Face';
        wo1.AccountSite__c = siteList[0].id;
        workOrderList.add(wo1);
        insert workOrderList;
        
        User citationUser1 = [SELECT Id FROM User WHERE LastName = 'citationUser' Limit 1];
        ServiceResource serRes = new ServiceResource();       // first service resource 
        serRes.name = 'test';
        serRes.RelatedRecordId = citationUser1.id;
        serRes.IsActive = True;
        serRes.IsOptimizationCapable =True;
        serRes.FSL__Priority__c = 1;
        insert serRes;
        
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
        
        ServiceTerritoryMember stMem1 = new ServiceTerritoryMember();
        stMem1.ServiceResourceId = serviceResourceRecord.id;
        stMem1.ServiceTerritoryId = serviceTerritoryList[0].id;
        stMem1.EffectiveStartDate = system.today();
        insert stMem1;
        
        ServiceTerritoryMember stMem = new ServiceTerritoryMember();
        stMem.ServiceResourceId = serRes.id;
        stMem.ServiceTerritoryId = serviceTerritoryList[0].id;
        stMem.EffectiveStartDate = system.today();
        insert stMem;
        
        List<FSL__Scheduling_Policy__c> fspList = new List<FSL__Scheduling_Policy__c>();    
        FSL__Scheduling_Policy__c fslSchPol = new FSL__Scheduling_Policy__c();
        fslSchPol.Business_Area__c =  serviceTerritoryList[0].id;  
        fslSchPol.Name = 'H&S est';
        fspList.add(fslSchPol);
        
        FSL__Scheduling_Policy__c fslSchPol2 = new FSL__Scheduling_Policy__c();
        fslSchPol2.Business_Area__c =  serviceTerritoryList[1].id;  
        fslSchPol2.Name = 'Noviqa Test';
        fspList.add(fslSchPol2);
        
        FSL__Scheduling_Policy__c fslSchPol3 = new FSL__Scheduling_Policy__c();
        fslSchPol3.Business_Area__c =  serviceTerritoryList[2].id;  
        fslSchPol3.Name = 'QMS Test';
        fspList.add(fslSchPol3);
        insert fspList;
        
        List<ServiceAppointment> saList = new List<ServiceAppointment>();   
        ServiceAppointment sa = new ServiceAppointment();
        sa.Status = 'none';
        sa.ParentRecordId = workOrderList[0].Id;
        sa.EarliestStartTime = DateTime.now();
        sa.DueDate = DateTime.now();
        sa.Duration = 2.00;
        sa.Meeting_ID__c = '434456';
        sa.Business__c = 'Citation';
        sa.Milestone_Work_Type__c = mwtObj.id;
        sa.Meeting_Type__c = 'HR System Training';
        sa.ServiceTerritoryId = serviceTerritoryList[0].id;
        sa.ContactId = con.Id;
        sa.Visit_Type__c = 'Face-To-Face';
        sa.SchedStartTime = system.today()+3;
        sa.SchedEndTime = system.today() +5;
        sa.FSL__Scheduling_Policy_Used__c = fspList[0].id;
        saList.add(sa);
        // insert sa;   
        ServiceAppointment saTeri = new ServiceAppointment();
        saTeri.Status = 'none';
        saTeri.ParentRecordId = workOrderList[1].Id;
        saTeri.EarliestStartTime = DateTime.now();
        saTeri.DueDate = DateTime.now();
        saTeri.Duration = 2.00;
        saTeri.Meeting_ID__c = '435256';
        saTeri.Business__c = 'QMS';
        saTeri.Milestone_Work_Type__c = mwtObj.id;
        //saTeri.Meeting_Type__c = 'HR System Training (F2F)';
        saTeri.ServiceTerritoryId = serviceTerritoryList[2].id;
        saTeri.ContactId = con.Id;
        saTeri.Visit_Type__c = 'Face-To-Face';
        saTeri.SchedStartTime = system.today()+3;
        saTeri.SchedEndTime = system.today() +5;
        saTeri.FSL__Scheduling_Policy_Used__c = fspList[1].id;
        //insert saTeri;
        saList.add(saTeri);
        insert saList;
        
        
        Test.setMock(HttpCalloutMock.class, new TeamsNotifictionCallout_Test()); 
        
        AssignedResource assRes = new AssignedResource();
        assRes.ServiceAppointmentId =saList[0].id;
        assRes.ServiceResourceId = serRes.id;
        insert assRes;
        
        assRes.ServiceResourceId = serviceResourceRecord.id;
        update assRes; 
        
        FSL.GlobalAPIS.addStatusTransition('none','Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled','Confirmed');
        //FSL.GlobalAPIS.addStatusTransition('Confirmed','Dispatched');
        FSL.GlobalAPIS.addStatusTransition('Scheduled','Dispatched');
        // FSL.GlobalAPIS.addStatusTransition('Scheduled','Canceled');
        FSL.GlobalAPIS.addStatusTransition('Dispatched','Canceled');
        
        
        FSL__Time_Dependency__c obj = new FSL__Time_Dependency__c();
        obj.FSL__Root_Service_Appointment__c=saList[1].id;
        obj.FSL__Service_Appointment_1__c=saList[1].id;
        obj.FSL__Service_Appointment_2__c=saList[0].id;
        insert obj;
        
        EnhancedLetterhead enhancLetter = new EnhancedLetterhead();
        enhancLetter.name = 'Citation service appointment dispatch letterhead';
        enhancLetter.LetterheadFooter = 'test';
        enhancLetter.LetterheadHeader = 'test';
        insert enhancLetter;
        }
    }
    
    @isTest
    public static void updateServiceApp(){
        test.startTest();
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser' Limit 1];
        System.runAs(citationUser) {
            
            ServiceAppointment sa1= [Select Id from ServiceAppointment  Limit 1];
            try{
                sa1.status = 'scheduled';
                update sa1;
                
            }catch (DmlException e){
                //Assert Error Message 
                System.assert( e.getMessage().contains('Insert failed'),e.getMessage() );
            }
            test.stopTest();
        }
        
    }   
    @isTest
    public static void updateServiceAppConfirm(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser' limit 1];
        System.runAs(citationUser) {
            
            ServiceAppointment sa1= [Select Id from ServiceAppointment Limit 1];
            try{
                sa1.Meeting_Type__c = 'H&S 1st New';
                sa1.status = 'Confirmed';
                sa1.SchedStartTime = system.today()+4;
                sa1.SchedEndTime = system.today() +6;
                update sa1;
            }catch (DmlException e){
                //Assert Error Message 
                System.assert( e.getMessage().contains('Insert failed'),e.getMessage() );
            }       
            test.stopTest();
        }
        
    }
    @isTest
    public static void updateServiceAppDispatch(){
        test.startTest();
        User citationUser = [SELECT Id FROM User WHERE LastName = 'citationUser' AND username = 'citationFSLTestUser@testorg.com' limit 1];
        
        System.runAs(citationUser) {
            ServiceAppointment sa1= [Select Id, status, Meeting_Type__c from ServiceAppointment Limit 1];
            try{
                sa1.Meeting_Type__c = 'H&S 1st New';
                sa1.status = 'Dispatched';
                update sa1;
                SAEmailReminderBatchScheduler testsche = new SAEmailReminderBatchScheduler();
                String sch = '0 0 23 * * ?';
                system.schedule('Test status Check', sch, testsche );
            }catch (DmlException e){
                //Assert Error Message 
                System.assert( e.getMessage().contains('Insert failed'),e.getMessage() );
            }
            test.stopTest();
        }
        
    }  
}