@isTest
public class WorkOrderSMASEmailHandlerTest {
     @testSetup
  public static void setup() { 
      /*List<Account> accList = new List<Account>();
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
        
        insert acc;*/
      
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
      
      Contact con = new Contact();
      con.LastName='test';
      con.AccountId =acc2.id;
      con.Main_User__c = 'yes';
      con.Email ='test@citation.co.uk';
      con.Phone ='565656565656';
      con.MobilePhone = '6767676767676';
      con.Position__c='Manager';   
      insert con;
      
      Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(
          Name = 'Account 1 Citation Service Delivery Plan',
          Business__c = 'Citation',
          Account__c = acc2.Id
      );
      
      insert servicedelPlanObj;
      
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
      Milestone_Template__c milestone2 = new Milestone_Template__c(
          Name = 'Annual for each site + FRAr',
          Business__c = 'Citation',
          Start_Date_Days__c = 31,
          Due_Date_Days__c = 92,
          Reference_Date_field__c = 'StartDate',
          Recurrence__c = 3,
          Start_after_x_months__c = 1,
          Case_Type__c = 'Non Visits',
          Status__c = 'Active'
      );
      
      milestoneList.add(milestone1);
      milestoneList.add(milestone2);
      
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
      
            
      operatingHours hObj = new Operatinghours(Name = 'Test');
      insert hObj;
      
      ServiceTerritory stObj = new ServiceTerritory(
          Name = 'Atlas On-Boarding',
          OperatingHoursId = hObj.Id,
          isActive = true
      );
      insert stObj;
      
      Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
          Milestone_Template__c = milestoneList[0].Id,
          Work_Type__c = workTypeObj1.Id,
          subject__c = 'Test subject',
          Description__c = 'Test Description',
          ServiceTerritory__c = stObj.Id,
          WorkOrder_Record_Type__c='Citation Standard',
          Site_Repeat_Rule__c = 'All',
          Service_Contact__c = 'Main Site Contact',
          Customer_Friendly_Meeting_Name__c ='Test',
          Meeting_Type__c='HR Review'
      );
      
      insert mwtObj;
      
      Milestone_Work_Type__c mwtObj1 = new Milestone_Work_Type__c(
          Milestone_Template__c = milestoneList[0].Id,
          Work_Type__c = workTypeObj2.Id,
          subject__c = 'Test subject2',
          Description__c = 'Test Description2',
          ServiceTerritory__c = stObj.Id,
          Dependency__c = mwtObj.Id,
          Service_Contact__c = 'PEL Service Contact'
      );
      
      Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(
          Milestone_Template__c = milestoneList[0].Id,
          Work_Type__c = workTypeObj1.Id,
          subject__c = 'Test subject2',
          Description__c = 'Test Description2',
          ServiceTerritory__c = stObj.Id,
          Service_Contact__c = 'Main User'  
      );
      Milestone_Work_Type__c mwtObj11 = new Milestone_Work_Type__c(
          Milestone_Template__c = milestoneList[1].Id,
          Work_Type__c = workTypeObj2.Id,
          subject__c = 'Test subject2',
          Description__c = 'Test Description2',
          ServiceTerritory__c = stObj.Id,
          Dependency__c = mwtObj.Id,
          Site_Repeat_Rule__c = '',
          Service_Contact__c = 'Contract Signatory'
      );
      
      List<Product2> prodList = new List<Product2>();
      Product2 prod = new Product2();
      prod.put('Name', 'Fire Risk Assessment - Tailored Package');
      prod.put('ProductCode', 'FRA-TP');
      prod.put('IsActive', true);
      insert prod; 
      
      Product2 prod2 = new Product2();
      prod2.put('Name', 'On-Site HR – Training – Full Day');
      prod2.put('ProductCode', 'OSHR-TFD');
      prod2.put('IsActive', true);
      insert prod2;
      
      insert prodList;
      
      List<Product_Milestone__c> pmList = new List<Product_Milestone__c>();
      Product_Milestone__c pmObj = new Product_Milestone__c(
          Milestone_Template__c = milestoneList[0].Id,
          Product__c = prod.id,
          Type__c = 'New'
      );
      Product_Milestone__c pmObj2 = new Product_Milestone__c(
          Milestone_Template__c = milestoneList[1].Id,
          Product__c = prod2.id,
          Type__c = 'New'
      );
      pmList.add(pmObj);
      pmList.add(pmObj2);
      insert pmList;
      
      
      customSettings();  
      
  }
     

  public static testMethod void activateContracts() {
      Profile pf = [SELECT Id FROM Profile WHERE Name ='Citation Data Admin'];
      UserRole ur = new UserRole(Name = 'Citation Client Support Manager');
      insert ur;
      User u = new User(
          UserRoleId = ur.Id,
          ProfileId = pf.Id,
          Username = 'testtermsconditions1234423@citation.co.uk',
          Alias = 'batman',
          Email='testtermsconditions1234423@citation.co.uk',
          EmailEncodingKey='UTF-8',
          Firstname='Bruce1',
          Lastname='Wayne1',
          LanguageLocaleKey='en_US',
          LocaleSidKey='en_US',
          TimeZoneSidKey='America/Chicago');
      insert u; 
      
      List<PermissionSetAssignment> psa1 = new  List<PermissionSetAssignment>();
      List<PermissionSet> permissionList = [select id from Permissionset where name='General_S360_Permission_Set' OR name='SDP_PermissionSet' OR name='Citation_Support_Admin'];
      for(PermissionSet p:permissionList){
          psa1.add(new PermissionSetAssignment(AssigneeId=u.id, PermissionSetId=p.id));
      }
      insert psa1;
      System.runAs(u) {
          //ARRANGE
          List<Product2> testProducts = [
              SELECT id, Name
              FROM product2
              WHERE NAME IN ('Fire Risk Assessment - Tailored Package', 'On-Site HR – Training – Full Day')
          ];
          EntitlementTemplate eTobj = new EntitlementTemplate(
              Name = 'Test',
              Type = 'Web Support'
          );
          
          insert eTobj;
          
          Productentitlementtemplate petObj = new Productentitlementtemplate(
              EntitlementTemplateId = eTobj.Id,
              Product2Id = testProducts[0].Id
          );
          insert petObj;
          
          Account testAccount = TestHarness.createAccount(true);
          
          Contact cons = new Contact();
          cons.LastName='test';
          cons.AccountId =testAccount.id;
          cons.Main_User__c = 'yes';
          cons.Email ='test@citation.co.uk';
          cons.Phone ='565656565656';
          cons.MobilePhone = '6767676767676';
          cons.Position__c='Manager';   
          insert cons;
          //added ss-983
          Service_Delivery_Plan_Template__c sdptObj = new Service_Delivery_Plan_Template__c(
              Name = 'Service Delivery Plan Template Citation Business',
              Status__c = 'Active',
              Owning_Business__c = 'Citation'
          );
          contract contractObj = new contract(
              accountid = testAccount.id,
              FOC_Period_Mths__c = 2,
              FOC_Period_Mths_End__c = 0,
              startdate = date.today(),
              Agreement_Type__c = 'Auto',
              Service_Delivery_Plan_Template__c = sdptObj.Id,
              ContractTerm = 72,
              CustomerSignedId = cons.Id
          );
          insert contractObj;
          EnhancedLetterhead enhancLetter = new EnhancedLetterhead();
          enhancLetter.name = 'Citation service appointment dispatch letterhead';
          enhancLetter.LetterheadFooter = 'test';
          enhancLetter.LetterheadHeader = 'test';
          insert enhancLetter; 
          
          Opportunity testOpportunity = TestHarness.createOpportunity(
              true,
              testAccount.id
          );
          
          ffbc__SoftDate__c softDate = TestHarness.createSoftDate(true);
          fferpcore__Company__c billingCompany = TestHarness.createBillingCompany(
              true
          );
          ffbc__Contract__c billingContract = TestHarness.createBillingContract(
              false,
              testAccount,
              billingCompany,
              testOpportunity
          );
          List<ffbc__Contract__c> bb = new List<ffbc__Contract__c>();
          billingContract.Contract_Type__c = 'New';
          billingContract.SF_Contract__c = contractObj.id;
          insert billingContract;
          ffbc__ContractLineItem__c billingContractLine = TestHarness.createBillingContractLine(
              false,
              testProducts[0],
              softDate,
              billingContract
          );
          Test.startTest(); 
          billingContractLine.Service_Start_Date__c = date.today();
          billingContractLine.Service_End_Date__c = date.today().AddMonths(64);
          insert billingContractLine;
          
          
          
          
          
          
          ffbc.ContractsService.ActivationRequest activateReq = new ffbc.ContractsService.ActivationRequest();
          activateReq.ContractIds = new Set<Id>{ billingContract.id };
              
              //ACT
              
              // ffbc.ContractsService.Activation(activateReq);
              ffbc__Contract__c billingContractObj = [
                  SELECT Id, ffbc__Status__c
                  FROM ffbc__Contract__c
                  LIMIT 1
              ];
          
          
          
          Case caseObj = new Case();
          caseObj.STart_date__c = date.today();
          caseObj.ContactId = cons.Id;
          caseObj.AccountId = testAccount.id;  
          caseObj.Origin = 'Field Support - Phone';
          caseObj.Status = 'New';
          caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
              .get('Field Support')
              .getRecordTypeId();
          
          insert caseObj;
          System.assertEquals(
              'Draft',
              billingContractObj.ffbc__Status__c,
              'success'
          );
          
          Case caseObj1 = new Case();
          caseObj1.STart_date__c = date.today();
          caseObj1.Origin = 'Service Delivery Milestone';
          caseObj1.Status = 'Pending Start';
          //caseObj.Milestone_Template__c = mt.Id;
          caseObj1.Billing_Contract__c = billingContract.Id;
          //caseObj.Billing_Contract_Line_Item__c = billingContractLine.Id;
          caseObj1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
              .get('H&S Visits')
              .getRecordTypeId();
          
          insert caseObj1;
          
          workOrder woObj = new workOrder();
          woObj.StartDate = date.today();
          woObj.EndDate = date.today().adddays(10);
          woObj.Description = 'test';
          woObj.Subject = 'test';
          woObj.AccountId = testAccount.Id;
          // woObj.WorkTypeId = workTypeObj1.Id;
          woObj.CaseId = caseObj1.id;
          // woObj.Milestone_Work_Type__c = mwt[0].Id;
          woObj.subject = 'SMAS Welcome Call';
          
          insert woObj;
          
          Test.stopTest();
          
          
    }
 }

 
  public static void customSettings() {
    c2g__codaGeneralLedgerAccount__c gl = new c2g__codaGeneralLedgerAccount__c();
    gl.Name = '45100 - Trade Debtors Control';
    gl.Account_Description__c = 'Trade Debtors Control';
    gl.c2g__ReportingCode__c = '45100';
    gl.c2g__ExternalId__c = '45100 - Trade Debtors Control';
    gl.Sub_Ledger_Required__c = 'Tax';
    gl.c2g__TrialBalance1__c = 'Balance Sheet';
    gl.c2g__Type__c = 'Balance Sheet';
    gl.c2g__TrialBalance2__c = 'Current Assets';
    gl.c2g__TrialBalance3__c = 'Trade debtors';
    insert gl;

    c2g__codaTaxCode__c tc = new c2g__codaTaxCode__c();
    tc.c2g__ExternalId__c = 'GB-O-STD';
    tc.CurrencyIsoCode = 'GBP';
    tc.ffvat__NetBox__c = 'Box 6';
    tc.ffvat__TaxBox__c = 'Box 1';
    tc.c2g__Description__c = 'UK Output Standard Rated';
    tc.c2g__GeneralLedgerAccount__c = gl.Id;
    insert tc;

    c2g__codaTaxCode__c tc1 = new c2g__codaTaxCode__c();
    tc1.c2g__ExternalId__c = 'GB-I-STD';
    tc1.CurrencyIsoCode = 'GBP';
    tc1.ffvat__NetBox__c = 'Box 7';
    tc1.ffvat__TaxBox__c = 'Box 4';
    tc1.c2g__Description__c = 'UK Input Standard Rated';
    tc1.c2g__GeneralLedgerAccount__c = gl.Id;
    insert tc1;

    ffbc__BackgroundProcessSettings__c settings = new ffbc__BackgroundProcessSettings__c();
    settings.ffbc__GenerateSchedulesQueueSize__c = 5;
    settings.ffbc__GenerateSchedulesSchedulesPerLine__c = 100;
    settings.ffbc__GenerateSchedulesScopeSize__c = 5;

    insert settings;
  }
}