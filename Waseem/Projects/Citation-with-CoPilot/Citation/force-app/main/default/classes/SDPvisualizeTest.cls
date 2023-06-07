/*
Name of Class:SdpvisualizeTest
Purpose:Test Class for Sdpvisualize Class
Creation Date and Consultant Name: 05May21 by Atul Chougule
---------------------------------------------------------------------------------------
Update History: 
Update Date:
*/
@isTest
public class SDPvisualizeTest {
    
       @testSetup static void setup(){
                 
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = 'PROFESSIONAL ACTIVITIES';
        acc.FT_Employees__c = 6;
        acc.PT_Employees__c = 1;
        acc.Sites__c = 1;
        acc.BillingCity ='City';
        acc.BillingCountry ='GA';
        acc.BillingPostalCode ='12345';
        acc.BillingState ='state';
        acc.BillingStreet ='street';
        
        insert acc;
          
        Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(Name = 'Account 1 Citation Service Delivery Plan', Business__c ='Citation', Account__c = acc.Id);
        
        insert servicedelPlanObj;
          
        Service_Delivery_Plan_Template__c sdptObj = new Service_Delivery_Plan_Template__c(Name= 'Service Delivery Plan Template Citation Business', Status__c = 'Active', Owning_Business__c='Citation');
        
        insert sdptObj;
          
        contract contractObj = new contract(accountid=acc.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, startdate = date.today() , Agreement_Type__c = 'Auto', Service_Delivery_Plan_Template__c = sdptObj.Id , ContractTerm = 72 ) ;
        
        insert contractObj ;  
          
        List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
        Milestone_Template__c milestone1 = new Milestone_Template__c( Name ='Welcome Call', Business__c ='Citation', Start_Date_Days__c= 0, Due_Date_Days__c = 2, Reference_Date_field__c = 'StartDate', Anniversary_Date_Months__c = 0, Case_Type__c = 'Non Visits');
        Milestone_Template__c milestone2 = new Milestone_Template__c( Name ='Annual for each site + FRAr', Business__c ='Citation', Start_Date_Days__c= 31, Due_Date_Days__c = 92 , Reference_Date_field__c = 'StartDate', Recurrence__c = 12,Start_after_x_months__c = 24, Case_Type__c = 'Non Visits');

        milestoneList .add(milestone1);
        milestoneList .add(milestone2);  
        
        insert milestoneList;
        
        List<Service_Delivery_Template_Milestones__c> sdtmList = new List <Service_Delivery_Template_Milestones__c>();
        Service_Delivery_Template_Milestones__c sdtmObj = new Service_Delivery_Template_Milestones__c( Service_Delivery_Plan_Template__c = sdptObj.Id, Order__c = 1, Milestone_Template__c = milestone1.Id);
        Service_Delivery_Template_Milestones__c sdtmObj2 = new Service_Delivery_Template_Milestones__c( Service_Delivery_Plan_Template__c = sdptObj.Id, Order__c = 1, Milestone_Template__c = milestone2.Id);  
          
        sdtmList.add(sdtmObj);
        sdtmList.add(sdtmObj2);
          
        insert sdtmList;
          
        WorkType workTypeObj1 = new WorkType (Name='Documentation', EstimatedDuration=2.00, DurationType='Hours', ShouldAutoCreateSvcAppt  = true );
        insert workTypeObj1;
          
        WorkType workTypeObj2 = new WorkType (Name='Non Documentation', EstimatedDuration=2.00, DurationType='Hours', ShouldAutoCreateSvcAppt  = false );
        insert workTypeObj2;
        
        operatingHours hObj =new Operatinghours(Name='Test');
		insert hObj;
          
        ServiceTerritory stObj = new ServiceTerritory(Name ='Atlas On-Boarding', OperatingHoursId =hObj.Id);
        insert stObj;
          
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c (Milestone_Template__c= milestoneList[0].Id, Work_Type__c = workTypeObj1.Id, meeting_type__c = 'HR 1st New',
      Customer_Friendly_Meeting_Name__c = 'Test', subject__c ='Test subject', Description__c='Test Description',ServiceTerritory__c = stObj.Id );
        
        insert mwtObj;
          
       
    }
    
   
    static testMethod void insertWorkOrders(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Citation Data Admin'];
        UserRole r = new UserRole(Name = 'Field Service');
        insert r;
        User testUser = new User(
            Alias = 'standt',
            Email='standarduser@citation.co.uk',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='AtestUser1709@test.com'
        );
        insert testUser;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SDP_PermissionSet'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Dispatcher_Permissions'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);
        System.runAs(testUser)
        {
        
        Account acc = new Account();   
        acc.Name = 'testAcc';
        Service_Delivery_Plan__c testSdp = new Service_Delivery_Plan__c(Name = 'Account 1 Citation Service Delivery Plan', Business__c ='Citation', Account__c = acc.Id);
        insert testSdp;    
            
        List<Case> caselist  = new list<Case>();
        Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();
        Case casephone = new Case();
        casephone.RecordTypeId=rTId;
        casephone.Origin='Phone - Atlas Support';
        casephone.Status='New';
        casephone.Service_Delivery_Plan__c = testSdp.Id;
        casephone.Anniversary_Date__c  = Date.Today();
        casephone.Start_Date__c = Date.Today();
        casephone.Due_Date__c = Date.Today()+10;
        caselist.add(casephone);
        
        Case case2 = new Case();
        case2.RecordTypeId=rTId;
        case2.Origin='Phone - Atlas Support1';
        case2.Status='New1';
        case2.Service_Delivery_Plan__c = testSdp.Id;
        case2.Anniversary_Date__c  = Date.Today();
        case2.Start_Date__c = Date.Today();
        case2.Due_Date__c = Date.Today();
        caselist.add(case2);
        
        Case cemail = new Case();
        cemail.RecordTypeId=rTID;
        cemail.Origin='Email - Atlas Support';
        cemail.Status='New';
        cemail.Service_Delivery_Plan__c = testSdp.Id;
        caselist.add(cemail);
        insert(caselist);
            
            
           workOrder wo = new workOrder();
            wo.Status = 'New';
            wo.Priority = 'Low';
            wo.Duration =2.00;
        	wo.Subject = 'Test Subject';
            wo.StartDate = Date.today();
            wo.EndDate = Date.today() + 1;
            wo.caseId = caselist[0].id;
            insert wo;
            
            ServiceAppointment sa = new ServiceAppointment();
            sa.Status = 'None';
            sa.ParentRecordId = wo.Id;
            sa.EarliestStartTime = DateTime.now();
            sa.DueDate = Date.today() + 10;
            sa.Duration = 2.00;
            insert sa;
           List<Case> casetoupdate1 = [SELECT Id from Case WITH SECURITY_ENFORCED Limit 3];
         String abc;
         For(Case c1 : casetoupdate1){
         c1.Service_Delivery_Plan__c = testSdp.Id;
         abc = c1.Id;}
         wo.CaseId = abc; 
            
         Test.startTest();
         //Service_Delivery_Plan__c testSdp = new Service_Delivery_Plan__c();
         string tId = testSdp.Id;
         Sdpvisualize.fetchCase(tId);
            Sdpvisualize.getFilteredRecordDetails(tId, 0000, 'Allproduct', 'AllSite' );
         //Sdpvisualize.CaseWrapperSort wrap = new SDPvisualize.CaseWrapperSort();
         System.assertEquals('Account 1 Citation Service Delivery Plan', testSdp.Name, 'success');
         Test.StopTest();
        }
    }   
}