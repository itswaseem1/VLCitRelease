/*
Name of Class:WorkOrderTriggerHandler_Test
Purpose:Test Class for WorkOrderTriggerHandler Class
Creation Date and Consultant Name: 11March21 by Atul Chougule
---------------------------------------------------------------------------------------
Update History: 1

*/
@isTest
public class WorkOrderTriggerHandler_Test {
    
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
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.id;
        insert con;
              
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
    
    
    
    @isTest
    static void insertWorkOrders(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
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
            UserName='AtestUser20210917@test.com'
        );
        insert testUser;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SDP_PermissionSet'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        
        System.runAs(testUser)
        {
            workOrder wo = new workOrder();
            wo.Status = 'New';
            wo.Priority = 'Low';
            wo.Duration =2.00;
            
            insert wo;
            
            
            ServiceAppointment sa = new ServiceAppointment();
            sa.Status = 'None';
            sa.ParentRecordId = wo.Id;
            sa.EarliestStartTime = DateTime.now();
            sa.DueDate = DateTime.now();
            sa.Duration = 2.00;
            insert sa;
            
            wo.Status ='Canceled';
            try{
                update wo;
            }catch (DmlException e){
                //Assert Error Message 
                System.assert( e.getMessage().contains('Insert failed'),e.getMessage() );
            }
        }
    }
    
      @isTest
    public static void workOrderCreationTest() {
        
        Test.startTest();
        WorkType wType = [SELECT Id from WorkType WHERE ShouldAutoCreateSvcAppt = false LIMIT 1 ];
        Account acc = [SELECT Id, BillingCity ,BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account LIMIT 1];
        Contact con = [Select id from Contact Limit 1];
        Site__c accSite = New Site__c( Account__c= acc.Id, Active__c= true );
        insert accSite;
        WorkOrder workOrderObj  = new WorkOrder();
        
        workOrderObj.StartDate = date.today();
        workOrderObj.EndDate = date.today();
        workOrderObj.Description = 'Test';
        workOrderObj.Subject =  'Test';
        workOrderObj.AccountSite__c = accSite.Id;
        workOrderObj.AccountId =acc.Id; 
        workOrderObj.WorkTypeId =wType.Id;
        workOrderObj.EndDate = workOrderObj.StartDate.addDays(2);
        
        insert workOrderObj;
        
       
        
        ServiceAppointment sa = new ServiceAppointment();
            sa.Status = 'None';
            sa.ParentRecordId = workOrderObj.Id;
            sa.EarliestStartTime = DateTime.now();
            sa.DueDate = DateTime.now();
            sa.Duration = 2.00;
            insert sa;
        
        WorkOrder wo1 = [select id, accountId from WorkOrder where accountId =: acc.id limit 1];
        wo1.ContactId = con.id;
        wo1.status = 'New';
        update wo1;
        WorkOrder wo2 = [select id, accountId from WorkOrder where accountId =: acc.id limit 1];
        
        wo2.status = 'Closed';
        update wo2;
        
        System.assertEquals('Test', workOrderObj.Description,'success');
        Test.StopTest();

        
    }
    
    // Positive scenario
    
    @isTest
    public static void workOrderRecursivePositiveTesting() {
        
        Test.startTest();
        WorkType workTypeObj1 = [SELECT Id from WorkType WHERE ShouldAutoCreateSvcAppt = false LIMIT 1 ];
        Account acc = [SELECT Id, BillingCity ,BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account LIMIT 1];
        Contact con = [Select id from Contact Limit 1];
        
        Site__c accSite = New Site__c( Account__c= acc.Id, Active__c= true );
        insert accSite;
        
        WorkOrder workOrderObj1  = new WorkOrder();
        
        workOrderObj1.StartDate = date.today();
        workOrderObj1.EndDate = date.today();
        workOrderObj1.Description = 'Test';
        workOrderObj1.Subject =  'Work order for positive';
        workOrderObj1.AccountSite__c = accSite.Id;
        workOrderObj1.AccountId =acc.Id; 
        workOrderObj1.WorkTypeId =workTypeObj1.Id;
        workOrderObj1.EndDate = workOrderObj1.StartDate.addDays(2);
        
        insert workOrderObj1;
        
        
        
        
        Datetime myDateTime = Datetime.now();
        
        ServiceAppointment sa = new ServiceAppointment();
        sa.Status = 'None';
        sa.ParentRecordId = workOrderObj1.Id;
        sa.EarliestStartTime = DateTime.now();
        sa.DueDate = myDateTime.addDays(1);
        sa.Subject='Positive SA test';
        sa.Duration = 2.00;
        insert sa;
        
        
        workOrderObj1.ContactId = con.id;
        workOrderObj1.status = 'New';
        update workOrderObj1;
        
        
        // when the status of work order is changed to new and contact id is not equal to null then the related service appointment's contact would be updated to that of the work order
        String con1=con.id;
        String con2= [select id, contactId from ServiceAppointment where Subject='Positive SA test' limit 1].contactId;
        
        System.assertEquals(con1,con2);
        Test.StopTest();
        
        
    }
    
    // Negative scenario
    
    @isTest
    public static void workOrderRecursiveNegativeTesting() {
        
        Test.startTest();
        WorkType workTypeObj1 = [SELECT Id from WorkType WHERE ShouldAutoCreateSvcAppt = false LIMIT 1 ];
        Account acc = [SELECT Id, BillingCity ,BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account LIMIT 1];
        Contact con = [Select id from Contact Limit 1];
        Site__c accSite = New Site__c( Account__c= acc.Id, Active__c= true );
        insert accSite;
        WorkOrder workOrderObj3  = new WorkOrder();
        
        workOrderObj3.StartDate = date.today();
        workOrderObj3.EndDate = date.today();
        workOrderObj3.Description = 'Test';
        workOrderObj3.Subject =  'Work order for negative';
        workOrderObj3.AccountSite__c = accSite.Id;
        workOrderObj3.AccountId =acc.Id; 
        workOrderObj3.WorkTypeId =workTypeObj1.Id;
       
        
        insert workOrderObj3;
        
       
            
        Datetime myDateTime1 = Datetime.newInstance(1960, 2, 17);
        ServiceAppointment sa1 = new ServiceAppointment();
            sa1.Status = 'None';
            sa1.ParentRecordId = workOrderObj3.Id;
            sa1.EarliestStartTime = myDateTime1;
            sa1.DueDate = myDateTime1.addDays(4);
            sa1.Subject='Negative SA test';
            sa1.Duration = 2.00;
        insert sa1;
        
        
        workOrderObj3.status = 'New';
        update workOrderObj3;
        // when the status of work order is changed to new and contact id is equal to null then the related service appointment will not be updated
        System.assert(con.id!=[select id, contactId from ServiceAppointment where Subject='Negative SA test' limit 1].contactId);
        
        Test.StopTest();
  
    }
    
    
    public class PassThroughUOW implements IUnitOfWork
    {
        public Map<SObjectType, List<SObject>> recordMap = new Map<SObjectType,List<SObject>>();
        
        public List<SObject> getRecords(SObjectType type)
        {
            List<SObject> ret = recordMap.get(type);
            if(ret == null)
                ret = new List<SObject>();
            
            return ret;
        }
        
        private void captureRecords(List<SObject> records)
        {
            if(records == null || records.isEmpty())
                return;
            
            SobjectType type = records[0].getSobjectType();
            List<SObject> recs = recordMap.get(type);
            if(recs == null)
            {
                recs = new List<SObject>();
                recordMap.put(type, recs);
            }
            recs.addAll(records);
        }
        
        public void insertRecords(List<SObject> records)
        {
            captureRecords(records);
        }
        
        public void updateRecords(List<SObject> records)
        {
            captureRecords(records);
        }
        
        public void upsertRecords(List<SObject> records)
        {
            captureRecords(records);
        }
        
        public void deleteRecords(List<SObject> records)
        {
            captureRecords(records);
        }
    }
    
    @isTest
    public static void testRelatedWONotUpdated() {
        
        WorkType workTypeObj1 = [SELECT Id from WorkType WHERE ShouldAutoCreateSvcAppt = false LIMIT 1 ];
        Account acc = [SELECT Id, BillingCity ,BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account LIMIT 1];
        Contact con = [Select id from Contact Limit 1];
        Site__c accSite = New Site__c( Account__c= acc.Id, Active__c= true );
        insert accSite;
        
        WorkOrder workOrderObj6  = new WorkOrder();
        
        workOrderObj6.StartDate = date.today();
        workOrderObj6.EndDate = date.today();
        workOrderObj6.Description = 'Test';
        workOrderObj6.Status = 'New';
        workOrderObj6.Subject =  'Work order for positive recursive';
        workOrderObj6.AccountSite__c = accSite.Id;
        workOrderObj6.AccountId =acc.Id; 
        workOrderObj6.WorkTypeId =workTypeObj1.Id;
        workOrderObj6.EndDate = workOrderObj6.StartDate.addDays(2);
        
        insert workOrderObj6;
        
        WorkOrder workOrderObj5  = new WorkOrder();
        
        workOrderObj5.Description = 'Test';
        workOrderObj5.Subject =  'Test';
        workOrderObj5.AccountSite__c = accSite.Id;
        workOrderObj5.AccountId =acc.Id; 
        workOrderObj5.WorkTypeId =workTypeObj1.Id;
        workOrderObj5.Dependent_Work_Order__c =workOrderObj6.Id;
        
        insert workOrderObj5;
        
        
        PassThroughUOW uow= new PassThroughUOW();
        UnitOfWork.setInstance(uow);
        
        Test.startTest();

        workOrderObj6.status = 'Closed';
        update workOrderObj6;
        Test.StopTest();
        /*Check that the code does not update any WO where the current WO is a dependent one
         A temporary fix has been done so thet the WO where the closed/completed WO is a 
         dependent WO does not get update*/
        System.assertEquals(0,uow.getRecords(WorkOrder.sobjectType).size());
       
        
    }
    
    @isTest
    public static void serviceAppointmentRecursiveTesting() {

        Test.startTest();
        WorkType workTypeObj1 = [SELECT Id from WorkType WHERE ShouldAutoCreateSvcAppt = false LIMIT 1 ];
        Account acc = [SELECT Id, BillingCity ,BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account LIMIT 1];
        Contact con = [Select id from Contact Limit 1];
                
        Site__c accSite = New Site__c( Account__c= acc.Id, Active__c= true );
        insert accSite;
        
        WorkOrder workOrderObj1  = new WorkOrder();
        
        workOrderObj1.StartDate = date.today();
        workOrderObj1.EndDate = date.today();
        workOrderObj1.Description = 'Test';
        workOrderObj1.Subject =  'Work order for positive for SA';
        workOrderObj1.AccountSite__c = accSite.Id;
        workOrderObj1.AccountId =acc.Id; 
        workOrderObj1.WorkTypeId =workTypeObj1.Id;
        workOrderObj1.EndDate = workOrderObj1.StartDate.addDays(2);
        
        insert workOrderObj1;
        
        Datetime myDateTime = Datetime.now();
        
        ServiceAppointment sa = new ServiceAppointment();
            sa.Status = 'None';
            sa.ParentRecordId = workOrderObj1.Id;
            sa.EarliestStartTime = DateTime.now();
            sa.DueDate = myDateTime.addDays(1);
            sa.Subject='Positive SA test recursive';
            sa.Duration = 2.00;
        insert sa;
        PassThroughUOW uow= new PassThroughUOW();
        UnitOfWork.setInstance(uow);
        
        workOrderObj1.ContactId = con.id;
        workOrderObj1.status = 'New';
        update workOrderObj1;
        
        Test.StopTest();
        // To check how many service appointments are updated using unit of work concept
        System.assertEquals(1,uow.getRecords(ServiceAppointment.sobjectType).size());
        System.assertEquals(sa.id, uow.getRecords(ServiceAppointment.sobjectType)[0].id);
   
    } 
    //Work order skill requirment testing
    @isTest
    public static void addSkillRequirementInWOPositiveTesting() {

        Test.startTest();
        OperatingHours oh = new OperatingHours();
        oh.Name = 'TestOH';
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory();
        st.Name='FRA Territory';
        st.OperatingHoursId=oh.id;
        st.IsActive=true;
        insert st;
        List<WorkOrder> wos = new List<WorkOrder>();
        for(integer i=1;i<=200;i++){
            WorkOrder workOrderObj1  = new WorkOrder();
            workOrderObj1.ServiceTerritoryId = st.id;
            workOrderObj1.Subject='Teat Positive'+i;
            wos.add(workOrderObj1);
        }
        insert wos;
        
        Test.stopTest();
        System.assertEquals(200,[select id from SkillRequirement where RelatedRecordId=:wos].size());
        
    } 
    @isTest
    public static void addSkillRequirementInWONegativeTesting() {

        Test.startTest();
        OperatingHours oh = new OperatingHours();
        oh.Name = 'TestOH';
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory();
        st.Name='FRA Region';
        st.OperatingHoursId=oh.id;
        st.IsActive=true;
        insert st;
        List<WorkOrder> wos = new List<WorkOrder>();
        for(integer i=1;i<=200;i++){
            WorkOrder workOrderObj1  = new WorkOrder();
            workOrderObj1.ServiceTerritoryId = st.id;
            workOrderObj1.Subject='Teat negative '+i;
            wos.add(workOrderObj1);
        }
        insert wos;
        
        Test.stopTest();
        System.assertEquals(0,[select id from SkillRequirement where RelatedRecordId=:wos].size());
        
    } 
}