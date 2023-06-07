@isTest
public class CertificateTriggerTest {
	
      @testSetup
  static void setup() {
  
        
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
        con.LastName='test';
        con.AccountId =acc.id;
        insert con;
        
        Product2 pro = new Product2();
        pro.Name = 'ProductTest';
        insert Pro;
        
        
        List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
        Milestone_Template__c milestone1 = new Milestone_Template__c( Name ='Welcome Call', Business__c ='Citation', Start_Date_Days__c= 0, Due_Date_Days__c = 2, Reference_Date_field__c = 'StartDate', Anniversary_Date_Months__c = 0, Case_Type__c = 'Non Visits');
        milestone1.Owning_Team__c='HR_Field_Support';
        Milestone_Template__c milestone2 = new Milestone_Template__c( Name ='Annual for each site + FRAr', Business__c ='Citation', Start_Date_Days__c= 31, Due_Date_Days__c = 92 , Reference_Date_field__c = 'StartDate', Recurrence__c = 12,Start_after_x_months__c = 24, Case_Type__c = 'Non Visits');

        milestoneList .add(milestone1);
        milestoneList .add(milestone2);  
        
        insert milestoneList;
        
        WorkType workTypeObj1 = new WorkType (Name='Documentation', EstimatedDuration=2.00, DurationType='Hours', ShouldAutoCreateSvcAppt  = false );
        insert workTypeObj1;
          
        WorkType workTypeObj2 = new WorkType (Name='Non Documentation', EstimatedDuration=2.00, DurationType='Hours', ShouldAutoCreateSvcAppt  = false );
        insert workTypeObj2;
        
        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c (Milestone_Template__c= milestoneList[0].Id, Work_Type__c = workTypeObj1.Id, subject__c ='Test subject',/* Description__c='Test Description',*/Owning_Team__c='HR Field Support');
        
        insert mwtObj;
           
       certificate__c cobj = new certificate__c(Account__c= acc.Id, Status__c = 'Probationary', Standard__c='BS 15713 : 2009');
      insert cObj;        
      
        
        Asset ass2 = new Asset();
        ass2.name= 'test22';
        ass2.accountid = acc.id;
        ass2.contactid = con.id;
        ass2.Product2Id =pro.id;
      ass2.Certificate__c = cObj.id;
        insert ass2;
        
        
		Entitlement en = new Entitlement();
		en.name = 'test';
        en.AssetId = ass2.id;
        en.AccountId = acc.id;
        insert en;
        en.StartDate = system.today() - 1;
		en.EndDate = system.today()+5;
        update en;
                
		
		Case sdpCase = new Case();
        sdpCase.recordTypeId = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Non_Visits').getRecordTypeId();
        
        sdpCase.Milestone_Template__c=milestone1.id;
        sdpCase.status='Active';
		sdpCase.AssetId = ass2.id;
        Insert sdpCase;
        
        Case sdpCase1 = new Case();
        sdpCase.recordTypeId = Case.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('Non_Visits').getRecordTypeId();
        
        sdpCase1.Milestone_Template__c=milestone1.id;
        sdpCase1.status='On Hold';
		sdpCase1.AssetId = ass2.id;
        Insert sdpCase1;

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
        workOrderObj.Milestone_Work_Type__c = mwtObj.id;
        insert workOrderObj;
		
		WorkOrder workOrderObj1  = new WorkOrder();
 
        workOrderObj1.StartDate = date.today();
        workOrderObj1.EndDate = date.today();
        workOrderObj1.Description = 'Test';
        workOrderObj1.Subject =  'Test';
        workOrderObj1.AccountId = acc.Id;
        workOrderObj1.Account_Site__c =acc.Id;
        workOrderObj1.WorkTypeId =workTypeObj1.Id;
        workOrderObj1.EndDate = workOrderObj.StartDate.addDays(2);
        workOrderObj1.caseId = sdpCase1.id;
		workOrderObj1.Status = 'On Hold';
        workOrderObj1.Milestone_Work_Type__c = mwtObj.id;
        insert workOrderObj1;
        
        ServiceAppointment sr = new ServiceAppointment();
        sr.ParentRecordId = workOrderObj.id;
        sr.status = 'None';
        insert sr;
		ServiceAppointment sr1 = new ServiceAppointment();
        sr1.ParentRecordId = workOrderObj1.id;
        sr1.status = 'Canceled';
        sr1.reason__c ='Service On-hold';
        insert sr1;
        
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = workOrderObj.id;
        sa.EarliestStartTime = system.today()-2;
        sa.DueDate = system.today()+2;
        sa.Status = 'canceled';  
        sa.reason__c ='Service On-hold';        
        insert sa;
        
  }

    static testMethod void suspendCertificateTest() {
	 Test.startTest();
          certificate__c cobj = [SELECT Id,status__c from certificate__c limit 1];
    
          cObj.Status__c = 'Suspension';
            update cObj;
            
               cObj.Status__c = 'Full';
            update cObj;
              System.assertEquals(
            'Full',
            cObj.Status__c,
            'success'
          );
     Test.stopTest();
    }
    
     /*   static testMethod void FULLCertificateTest() {

      certificate__c cobj = [SELECT Id,status__c from certificate__c limit 1];    
      Test.startTest();
      cObj.Status__c = 'Full';
        update cObj;
       System.assertEquals(
        'Full',
        cObj.Status__c,
        'success'
      );
      Test.stopTest();
    }*/
  
}