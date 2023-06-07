@isTest
public class ServiceAppointmentSentEmailQmsHelperTest {
    class JitterbitServer implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}');
            response.setStatusCode(200);
            return response;
        }
    } 
    @istest
    static void createData()
    {
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
            IsActive = True
            
        );
        insert citationUser;
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            permissionSetLicense perLincense =[ select id, masterLabel from permissionSetLicense where masterLabel = 'Field Service Scheduling' limit 1];
            for (PermissionSet permSet : [SELECT Id FROM PermissionSet WHERE Name = 'SDP_PermissionSet' OR Name = 'General_s360_permission_set' OR Name = 'FSL_Admin_License' OR Name = 'FSL_Admin_Permissions'
                                          OR Name = 'Knowledge_article_author_permission' OR Name = 'Citation_Support_Admin' OR Name = 'FSL_Dispatcher_License' OR Name = 'FSL_Dispatcher_Permissions'
                                          OR Name = 'Referrals_Access' OR Name = 'FSL_Resource_License']) {
                                              psas.add(new PermissionSetAssignment(
                                                  AssigneeId = citationUser.Id,
                                                  PermissionSetId = permSet.Id
                                              ));
                                          }
            insert psas;
            
        }
        
        
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
        con.Email = 'abc@def.co.uk.invalid';
        insert con;
        
        
        
        List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
        Milestone_Template__c milestone1 = new Milestone_Template__c(
            Name = 'Welcome Call',
            Business__c = 'QMS',
            Start_Date_Days__c = 0,
            Due_Date_Days__c = 2,
            Reference_Date_field__c = 'StartDate',
            Anniversary_Date_Months__c = 0,
            Case_Type__c = 'Non Visits',
            Status__c = 'Active'
        );
        
        milestoneList.add(milestone1);
        insert milestoneList;
        
        WorkType workTypeObj1 = new WorkType(
            Name = 'Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = true
        );
        insert workTypeObj1;
        
        WorkType workTypeObj2 = new WorkType(
            Name = 'Non Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = false
        );
        insert workTypeObj2;
        
        WorkType workTypeObj3 = new WorkType(
            Name = 'Non Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = false
        );
        insert workTypeObj3;
        
        
        operatingHours hObj = new Operatinghours(Name = 'Test');
        insert hObj;
        
        List<ServiceTerritory> sTlist = new List<ServiceTerritory>();
        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'test',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        sTlist.add(stObj);
        ServiceTerritory stObj1 = new ServiceTerritory(
            Name = 'Noviqa Territory',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        sTlist.add(stObj1);
        ServiceTerritory stObj2 = new ServiceTerritory(
            Name = 'QMS Territory',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        sTlist.add(stObj2);
        insert sTlist;
        
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[0].Id,
            Work_Type__c = workTypeObj1.Id,
            subject__c = 'Test subject',
            Description__c = 'Test Description',
            ServiceTerritory__c = stObj.Id,
            Site_Repeat_Rule__c = 'All',
            Service_Contact__c = 'Main User',
            WorkOrder_Record_Type__c='QMS Visit Work',
            meeting_type__c = 'HR 1st New',
            Customer_Friendly_Meeting_Name__c = 'test'
        );
        
        insert mwtObj;
        
        workOrder wo1 = new workOrder();
        wo1.Status = 'New';
        wo1.Priority = 'Low';
        wo1.Duration =2.00;
        wo1.ServiceTerritoryId = stObj2.id;
        wo1.AccountSite__c = siteList[0].id;
        insert wo1;
        List<FSL__Scheduling_Policy__c> fslPolicyList = new List<FSL__Scheduling_Policy__c>();
        FSL__Scheduling_Policy__c fslSchPol = new FSL__Scheduling_Policy__c();
        fslSchPol.Business_Area__c =  sTlist[1].id;  
        fslSchPol.Name = 'Test';
        fslPolicyList.add(fslSchPol);
        FSL__Scheduling_Policy__c fslSchPol2 = new FSL__Scheduling_Policy__c();
        fslSchPol.Business_Area__c =  sTlist[1].id;  
        fslSchPol.Name = 'Test1';
        fslPolicyList.add(fslSchPol2);
        
        FSL__Scheduling_Policy__c fslSchPol3 = new FSL__Scheduling_Policy__c();
        fslSchPol.Business_Area__c =  sTlist[1].id;  
        fslSchPol.Name = 'Test';
        fslPolicyList.add(fslSchPol3);
        insert fslPolicyList;
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        ServiceAppointment sa = new ServiceAppointment();
        sa.Status = 'none';
        sa.ParentRecordId = wo1.Id;
        sa.EarliestStartTime = DateTime.now();
        sa.DueDate = DateTime.now();
        sa.Duration = 2.00;
        sa.Milestone_Work_Type__c = mwtObj.id;
        sa.Meeting_Type__c = 'HR System Training';
        sa.ServiceTerritoryId = stObj1.id;
        sa.ContactId = con.Id;
        sa.Visit_Type__c = 'Face-To-Face';
        sa.SchedStartTime = system.today()+3;
        sa.SchedEndTime = system.today() +5;
        sa.FSL__Scheduling_Policy_Used__c = fslPolicyList[0].id;
        sa.Business__c='QMS';
        saList.add(sa);
        ServiceAppointment saTeri = new ServiceAppointment();
        saTeri.Status = 'none';
        saTeri.ParentRecordId = wo1.Id;
        saTeri.EarliestStartTime = DateTime.now();
        saTeri.DueDate = DateTime.now();
        saTeri.Duration = 2.00;
        saTeri.Milestone_Work_Type__c = mwtObj.id;
        saTeri.ServiceTerritoryId = stObj2.id;
        saTeri.ContactId = con.Id;
        saTeri.Visit_Type__c = 'Face-To-Face';
        saTeri.SchedStartTime = system.today()+3;
        saTeri.SchedEndTime = system.today() +5;
        saTeri.FSL__Scheduling_Policy_Used__c = fslPolicyList[0].id;
        saList.add(saTeri);
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        insert saList;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        FSL.GlobalAPIS.addStatusTransition('none','Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled','Confirmed');
        FSL.GlobalAPIS.addStatusTransition('Confirmed','Dispatched');
        FSL__Time_Dependency__c obj = new FSL__Time_Dependency__c();
        obj.FSL__Root_Service_Appointment__c=saTeri.id;
        obj.FSL__Service_Appointment_1__c=saTeri.id;
        obj.FSL__Service_Appointment_2__c=sa.id;
        insert obj;
        sa.Status='Scheduled';
        sa.Shadow__c=true;
        sa.FSL__Scheduling_Policy_Used__c=fslPolicyList[0].id;
        sa.ServiceTerritoryId=stObj1.id;
        sa.SchedStartTime=system.today();
        sa.SchedEndTime=system.today()+1;
        sa.Business__c='QMS';
        update sa;
        sa.Status='Confirmed';
        update sa;
        system.assertEquals('Confirmed',[select status from serviceappointment limit 1].status,'success');
        test.stopTest();
    }
    
    
}