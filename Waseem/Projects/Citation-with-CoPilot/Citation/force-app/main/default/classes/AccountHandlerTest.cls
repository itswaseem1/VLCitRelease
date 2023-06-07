@isTest
public with sharing class AccountHandlerTest {
   
   
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
          
        contract contractObj = new contract(accountid=acc.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, startdate = date.today() , Agreement_Type__c = 'Auto', ContractTerm = 72 ) ;
        
        insert contractObj ;  
          
        List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
        Milestone_Template__c milestone1 = new Milestone_Template__c( Name ='Welcome Call', Business__c ='Citation', Start_Date_Days__c= 0, Due_Date_Days__c = 2, Reference_Date_field__c = 'StartDate', Anniversary_Date_Months__c = 0, Case_Type__c = 'Non Visits');
        milestone1.Owning_Team__c='HR_Field_Support';
        Milestone_Template__c milestone2 = new Milestone_Template__c( Name ='Annual for each site + FRAr', Business__c ='Citation', Start_Date_Days__c= 31, Due_Date_Days__c = 92 , Reference_Date_field__c = 'StartDate', Recurrence__c = 12,Start_after_x_months__c = 24, Case_Type__c = 'Non Visits');

        milestoneList .add(milestone1);
        milestoneList .add(milestone2);  
        
        insert milestoneList;
        
          
        WorkType workTypeObj1 = new WorkType (Name='Documentation', EstimatedDuration=2.00, DurationType='Hours', ShouldAutoCreateSvcAppt  = true );
        insert workTypeObj1;
          
        WorkType workTypeObj2 = new WorkType (Name='Non Documentation', EstimatedDuration=2.00, DurationType='Hours', ShouldAutoCreateSvcAppt  = false );
        insert workTypeObj2;
        
        operatingHours hObj =new Operatinghours(Name='Test');
        insert hObj;
          
        ServiceTerritory stObj = new ServiceTerritory(Name ='Atlas On-Boarding', OperatingHoursId =hObj.Id);
        insert stObj;
          
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c (Milestone_Template__c= milestoneList[0].Id, Work_Type__c = workTypeObj1.Id,meeting_type__c = 'HR 1st New',
      Customer_Friendly_Meeting_Name__c = 'Test', subject__c ='Test subject', Description__c='Test Description',ServiceTerritory__c = stObj.Id,Owning_Team__c='HR Field Support',WorkOrder_Record_Type__c='Citation Standard');
        
        insert mwtObj;
        
        List<Case> caseList=new List<Case>();
        Case sdpCase = new Case();
        sdpCase.recordTypeId = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Non_Visits').getRecordTypeId();
        sdpCase.Service_Delivery_Plan__c = servicedelPlanObj.id;
        sdpCase.Milestone_Template__c=milestone1.id;
        sdpCase.status='Active';
        caseList.add(sdpCase);
        Case sdpCase1 = new Case();
        sdpCase1.recordTypeId = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Non_Visits').getRecordTypeId();
        sdpCase1.Service_Delivery_Plan__c = servicedelPlanObj.id;
        sdpCase1.Milestone_Template__c=milestone1.id;
        sdpCase1.status='Pending Start';
        caseList.add(sdpCase1);
        Insert caseList;

       WorkOrder workOrderObj  = new WorkOrder();
 
        workOrderObj.StartDate = date.today();
        workOrderObj.EndDate = date.today();
        workOrderObj.Description = 'Test';
        workOrderObj.Subject =  'Test';
        workOrderObj.AccountId = acc.Id;
        workOrderObj.Account_Site__c =acc.Id;
        workOrderObj.WorkTypeId =workTypeObj1.Id;
        workOrderObj.EndDate = workOrderObj.StartDate.addDays(2);
        workOrderObj.caseId = sdpCase.id;
        workOrderObj.Milestone_Work_Type__c=mwtObj.id;
        insert workOrderObj;
        
        ServiceAppointment sr = new ServiceAppointment();
        sr.ParentRecordId = workOrderObj.id;
        sr.status = 'In Progress';
        insert sr;
        

    }
    @isTest
    public static void accountOnHoldTest() {
        
        Test.startTest();
        Account acc = [select id ,name,HasContractOnHold__c from account limit 1];

        
        acc.HasContractOnHold__c = 1;
        update acc;
        
        List<Case> caseObj = [Select Id,Status FROM CASE];
        System.assertEquals('On Hold',caseObj[0].Status,'success');
        System.assertEquals('On Hold',caseObj[1].Status,'success');
        list<WOrkOrder> wo=[select id,Previous_Status__c from WorkOrder];
        system.assertEquals('New', wo[0].Previous_Status__c, 'success');
        acc.HasContractOnHold__c = 0;
        update acc;
        List<Case> caseObj1 = [Select Id,Status FROM CASE];
        System.assertEquals('Active',caseObj1[0].Status,'success');
        System.assertEquals('Pending Start',caseObj1[1].Status,'success');
        list<WOrkOrder> workOrder=[select id,status from WorkOrder];
        system.assertEquals('New', workOrder[0].status, 'success');
        delete acc;
        Test.stopTest();
    }
}