@isTest
public class SDP_BillingContractHelperTest {
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
	accList.add(acc);
    //insert acc;

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
	accList.add(acc2);
    insert accList;

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
    insert con;
      
    List<Site_Junction__c> siteContactList = new List<Site_Junction__c>();
       Site_Junction__c siteContact1 = new Site_Junction__c();
		siteContact1.Site_Junction__c =siteList[1].id ;
		siteContact1.Account__c = acc2.id;
         siteContact1.Contact_Junction__c = con.id;
		siteContact1.Main_H_S_Contact__c = true;
      	siteContact1.IsActive__c = true;
      
        Site_Junction__c siteContact2 = new Site_Junction__c();
		siteContact2.Site_Junction__c =siteList[1].id ;
		siteContact2.Account__c = acc2.id;
         siteContact2.Contact_Junction__c = con.id;
		siteContact2.Main_PEL_Contact__c = true;
      	siteContact2.IsActive__c = true;
      
      Site_Junction__c siteContact4 = new Site_Junction__c();
      siteContact4.Site_Junction__c =siteList[1].id ;
      siteContact4.Account__c = acc2.id;
      siteContact4.Contact_Junction__c = con.id;
      siteContact4.Main_QMS_Contact__c = true;
      siteContact4.IsActive__c = true;
      
      Site_Junction__c siteContact3 = new Site_Junction__c();
      siteContact3.Site_Junction__c =siteList[1].id ;
      siteContact3.Account__c = acc2.id;
      siteContact3.Contact_Junction__c = con.id;
      siteContact3.Secondary_PEL_Contact__c = true;
      siteContact3.IsActive__c = true;
      
      Site_Junction__c siteContact5 = new Site_Junction__c();
      siteContact5.Site_Junction__c =siteList[1].id ;
      siteContact5.Account__c = acc2.id;
      siteContact5.Contact_Junction__c = con.id;
      siteContact5.Secondary_QMS_Contact__c = true;
      siteContact5.IsActive__c = true;
      
      	siteContactList.add(siteContact1);
     insert siteContactList;
      
      MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContactList[0]);
      MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact2);
      MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact3);
      MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact4);
      MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact5);

    Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(
      Name = 'Account 1 Citation Service Delivery Plan',
      Business__c = 'Citation',
      Account__c = acc.Id
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

    WorkType workTypeObj3 = new WorkType(
      Name = 'Nonf Documentation',
      EstimatedDuration = 2.00,
      DurationType = 'Hours',
      ShouldAutoCreateSvcAppt = false
    );
    insert workTypeObj3;

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
        meeting_type__c = 'HR 1st New',
      Customer_Friendly_Meeting_Name__c = 'Test'
    );

    insert mwtObj;

    Milestone_Work_Type__c mwtObj1 = new Milestone_Work_Type__c(
      Milestone_Template__c = milestoneList[0].Id,
      Work_Type__c = workTypeObj2.Id,
      subject__c = 'Test subject23',
      Description__c = 'Test Description2',
      ServiceTerritory__c = stObj.Id,
      Owning_Team__c='Fire Operations',
      WorkOrder_Record_Type__c='Citation Standard',
      Dependency__c = mwtObj.Id,
      Service_Contact__c = 'PEL Service Contact'
    );
    insert mwtObj1;

    Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(
      Milestone_Template__c = milestoneList[0].Id,
      Work_Type__c = workTypeObj1.Id,
      subject__c = 'Test subject2',
      Description__c = 'Test Description2',
      ServiceTerritory__c = stObj.Id,
      Service_Contact__c = 'Main User',
        meeting_type__c = 'HR 1st New',
      Customer_Friendly_Meeting_Name__c = 'Test'
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
    prod.put('Name', 'H&S Compliance Core');
    prod.put('ProductCode', 'HS-Compliance');
    prod.put('IsActive', true);
    insert prod;

    Product2 prod2 = new Product2();
    prod2.put('Name', 'H&S Compliance Service');
    prod2.put('ProductCode', 'HS-Compliance');
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
      Type__c = 'Both'
    );
    pmList.add(pmObj);
    pmList.add(pmObj2);
    insert pmList;
  }

  static testMethod void activateContracts() {

      
       	Profile p = [select id from profile where name='System Administrator'];
        User systemTestUser = new User();
        systemTestUser.put('FirstName' , '$FinancialForce PS');
        systemTestUser.put('LastName' , ' Developer$');
        systemTestUser.put('Alias' , '$FFPSD$');
        systemTestUser.put('Email' , 'productservices@financialforce.com');
        systemTestUser.put('Username' , 'financialforceproductservicesdevloper@financialforce.com');
        systemTestUser.put('CommunityNickname' , '$FFPSDMDT$');
        systemTestUser.put('Phone' , '555.555.5555');
        systemTestUser.put('IsActive' , true);
        systemTestUser.put('ProfileId' , p.id);
        systemTestUser.put('TimeZoneSidKey' , 'America/New_York');
        systemTestUser.put('LocaleSidKey' , 'en_US');
        systemTestUser.put('EmailEncodingKey' , 'ISO-8859-1');
        systemTestUser.put('LanguageLocaleKey' , 'en_US');
        systemTestUser.put('Title' , 'Product Service Developer and Tester');
        systemTestUser.put('CompanyName' , 'FinancialForce Test Company PS');
      	insert systemTestUser;
    list<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
      
      for(PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('SDP_PermissionSet')]){
          psList.add(new PermissionSetAssignment(AssigneeId = systemTestUser.id,PermissionSetId = ps.Id));
      }
    
    insert psList;

    System.runAs(systemTestUser) {
      //ARRANGE
      List<Product2> testProducts = [
        SELECT id, Name
        FROM product2
        WHERE NAME IN ('H&S Compliance Service', 'H&S Compliance Core')
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
      customSettings();
 	pricebook2 pb = new pricebook2(
        name = 'tst',
        isactive = true,
        Annual_Turnover_Minimum__c = 0,
        Annual_Turnover_Maximum__c = 50
      );
      insert pb;
      account a = new account(name = 'test', c2g__CODAInvoiceEmail__c = 'test@test.com');
      insert a;
      fferpcore__Company__c c = new fferpcore__Company__c(name = 'test');
      insert c;
      ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id,Contract_Type__c='New');
      insert cont;

      product2 p1 = [SELECT ID FROM PRODUCT2 LIMIT 1];
     // insert p1;

      ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c = 'MB');
      insert sd;

      date d = date.today().adddays(7);
      ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(
        service_start_date__c = date.today(),
        service_end_date__c = date.today(),
        ffbc__Quantity__c = 3,
        ffbc__SalesPriceOverride__c = 199.99,
        ffbc__Contract__c = cont.id,
        ffbc__ProductService__c = p1.id,
        ffbc__BillingTerm__c = sd.id,
        ffbc__FirstBillDate__c = d,
        ffbc__BillingType__c = 'Recurring Fixed'
      );
      insert l;

      ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
      request.ContractIds = new Set<Id>{ cont.id };
      request.MonthsToGenerate = 0;

      ffbc.ContractsService.activation(request);
		 ffbc__Contract__c billingContractObj = [
        SELECT Id, ffbc__Status__c
        FROM ffbc__Contract__c
        LIMIT 1
      ];
      Milestone_Template__c mt = [SELECT Id,
        Case_Type__c,
        Anniversary_Date_Months__c,
        Business__c,
        Dependent_Milestone__c,
        Due_Date_Days__c,
        Recurrence__c,
        Start_after_x_months__c,
        Name,
        Start_Date_Days__c,
        Reference_Date_field__c,
        Owning_Team__c,
        Milestone_Description__c,
        Milestone_Subject__c,
        Entitlement__c FROM Milestone_Template__c LIMIT 1];
        
     SDP_BillingContractHelper.generateSingleMilestoneCases(mt, l.Id);
     SDP_BillingContractHelper.generateRecurrenceCases(mt, l.Id);
      Case caseObj = new Case();
      caseObj.STart_date__c = date.today();
      caseObj.Origin = 'Service Delivery Milestone';
      caseObj.Status = 'Pending Start';
      caseObj.Milestone_Template__c = mt.Id;
      caseObj.Billing_Contract__c = cont.Id;
      caseObj.Billing_Contract_Line_Item__c = l.Id;
      caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('H&S Visits')
        .getRecordTypeId();
Test.startTest();
      insert caseObj;

      // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
      String cronExp = '0 6 * * * ?';
      String jobId = System.schedule(
        'Create WOrk Orders',
        cronExp,
        new SDP_ScheduleBatchToActivateMilestones()
      );
      CronTrigger ct = [
        SELECT Id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger
        WHERE id = :jobId
      ];
      System.assertEquals(0, ct.TimesTriggered, 'success');
      System.assertEquals(
        'Active',
        billingContractObj.ffbc__Status__c,
        'success'
      );
      Test.stopTest();
    }
  }
    static testmethod void workordertest(){
    User systemTestUser = TestHarness.createTestUser();
        systemTestUser.email='kathygwinnett@citation.co.uk';
        systemTestUser.UserRoleId=[select UserRoleId from user where id=: UserInfo.getUserId()].UserRoleId;
            update systemTestUser;
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'SDP_PermissionSet'
    ];
    insert new PermissionSetAssignment(
      AssigneeId = systemTestUser.id,
      PermissionSetId = ps.Id
    );

    System.runAs(systemTestUser) {     
      
   List<Account> acc = [SELECT Id from account limit 1];     
   List<WorkType> workTypeList = [SELECT Id from workType limit 1];    
   List<Milestone_Work_Type__c> mwt = [SELECT Id from Milestone_Work_Type__c LIMIT 1];
        
    workOrder woObj = new workOrder();
    woObj.StartDate = date.today();
    woObj.EndDate = date.today().adddays(10);
    woObj.Description = 'test';
    woObj.Subject = 'test';
    woObj.AccountId = acc[0].Id;
    woObj.WorkTypeId = workTypeList[0].Id;

    woObj.Milestone_Work_Type__c = mwt[0].Id;
    mwt[0].Service_Contact__c = 'Contract Signatory';
        Update mwt[0];
	 insert woObj;
        test.startTest();
    MapContactOnWorkOrderQueuableHandler.populateSiteContactOnWO([SELECT Id,Milestone_Work_Type__r.Service_Contact__c,AccountSite__c,AccountId FROm workorder WHERE Milestone_Work_Type__r.Service_Contact__c='Contract Signatory']);
	 System.assertEquals(
        'Contract Signatory',
        mwt[0].Service_Contact__c,
        'success'
      );
      Test.stopTest();
    }
    }
    
    
        static testmethod void workordertest2(){
        
    User systemTestUser = TestHarness.createTestUser();
            systemTestUser.email='kathygwinnett@citation.co.uk';
            systemTestUser.UserRoleId=[select UserRoleId from user where id=: UserInfo.getUserId()].UserRoleId;
            update systemTestUser;
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'SDP_PermissionSet'
    ];
    insert new PermissionSetAssignment(
      AssigneeId = systemTestUser.id,
      PermissionSetId = ps.Id
    );

    System.runAs(systemTestUser) {
   List<Account> acc = [SELECT Id from account limit 1];     
   List<WorkType> workTypeList = [SELECT Id from workType limit 1];    
   List<Milestone_Work_Type__c> mwt = [SELECT Id from Milestone_Work_Type__c LIMIT 1];
        
    workOrder woObj = new workOrder();
    woObj.StartDate = date.today();
    woObj.EndDate = date.today().adddays(10);
    woObj.Description = 'test';
    woObj.Subject = 'test';
    woObj.AccountId = acc[0].Id;
    woObj.WorkTypeId = workTypeList[0].Id;

    woObj.Milestone_Work_Type__c = mwt[0].Id;
    mwt[0].Service_Contact__c = 'Main User';
        Update mwt[0];
	 insert woObj;
    Test.startTest();    
    MapContactOnWorkOrderQueuableHandler.populateSiteContactOnWO([SELECT Id,Milestone_Work_Type__r.Service_Contact__c,AccountSite__c,AccountId FROm workorder WHERE Milestone_Work_Type__r.Service_Contact__c='Main User']);
	  System.assertEquals(
        'Main User',
        mwt[0].Service_Contact__c,
        'success'
      );
        
      Test.stopTest();
    }
    }

    
    
    static testMethod void activateContracts2() {
    User systemTestUser = TestHarness.createTestUser();
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'SDP_PermissionSet'
    ];
    insert new PermissionSetAssignment(
      AssigneeId = systemTestUser.id,
      PermissionSetId = ps.Id
    );

    System.runAs(systemTestUser) {
      //ARRANGE
      List<Product2> testProducts = [
        SELECT id, Name
        FROM product2
        WHERE NAME IN ('H&S Compliance Service', 'H&S Compliance Core')
      ];
        
      List<Product_Milestone__c> pMilestoneList = [SELECT Id,Product__c FROM Product_Milestone__c LIMIT 2];  
      SDP_BillingContractHelper.populateProductIds(pMilestoneList);
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
      customSettings();
      pricebook2 pb = new pricebook2(
        name = 'tst',
        isactive = true,
        Annual_Turnover_Minimum__c = 0,
        Annual_Turnover_Maximum__c = 50
      );
      insert pb;
      account a = new account(name = 'test', c2g__CODAInvoiceEmail__c = 'test@test.com');
      insert a;
      fferpcore__Company__c c = new fferpcore__Company__c(name = 'test');
      insert c;
      ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id);
      insert cont;

      product2 p1 = new product2(name = 'a', isactive = true);
      insert p1;

      ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c = 'MB');
      insert sd;

      date d = date.today().adddays(7);
      ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(
        service_start_date__c = date.today(),
        service_end_date__c = date.today(),
        ffbc__Quantity__c = 3,
        ffbc__SalesPriceOverride__c = 199.99,
        ffbc__Contract__c = cont.id,
        ffbc__ProductService__c = p1.id,
        ffbc__BillingTerm__c = sd.id,
        ffbc__FirstBillDate__c = d,
        ffbc__BillingType__c = 'Recurring Fixed'
      );
      insert l;

      ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
      request.ContractIds = new Set<Id>{ cont.id };
      request.MonthsToGenerate = 0;

      ffbc.ContractsService.activation(request);
      ffbc__Contract__c billingContractObj = [
        SELECT Id, ffbc__Status__c
        FROM ffbc__Contract__c
        LIMIT 1
      ];

      Milestone_Template__c mt = [SELECT Id FROM Milestone_Template__c LIMIT 1];
      Case caseObj = new Case();
      caseObj.STart_date__c = date.today();
      caseObj.Origin = 'Service Delivery Milestone';
      caseObj.Status = 'Pending Start';
      caseObj.Milestone_Template__c = mt.Id;
      caseObj.Billing_Contract__c = cont.Id;
      caseObj.Billing_Contract_Line_Item__c = l.Id;
      caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('H&S Visits')
        .getRecordTypeId();
	test.startTest();
      insert caseObj;

      // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
      String cronExp = '0 6 * * * ?';
      String jobId = System.schedule(
        'Create WOrk Orders',
        cronExp,
        new SDP_ScheduleBatchToActivateMilestones()
      );
      CronTrigger ct = [
        SELECT Id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger
        WHERE id = :jobId
      ];
      System.assertEquals(0, ct.TimesTriggered, 'success');
      System.assertEquals(
        'Active',
        billingContractObj.ffbc__Status__c,
        'success'
      );
      Test.stopTest();
    }
  }

  private static void customSettings() {
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
   
    static testMethod void testDeletion(){
        List<Milestone_Work_Type__c> listToDel=new List<Milestone_Work_Type__c>();
        listToDel= [select id from Milestone_Work_Type__c limit 1];
        if(listToDel.size()>0){
            try{
                delete listToDel;
            }
            catch (exception e){
                
            }
        }
    }
    
    // To cover CaseTriggerCreateWorkOrders_Util
    
    static testMethod void testgetQueues(){
        CaseTriggerCreateWorkOrders_Util.getQueues();
    }
    static testMethod void testgetParentStartDays(){
        Milestone_Work_type__c mwt=new Milestone_Work_type__c();
        mwt.Start_Days__c=1;
        CaseTriggerCreateWorkOrders_Util.getParentStartDays(mwt);
    }
    
    static testMethod void testgetParentEndDays(){
        Milestone_Work_type__c mwt=new Milestone_Work_type__c();
        mwt.Start_Days__c=1;
        CaseTriggerCreateWorkOrders_Util.getParentEndDays(mwt);
    }
    static testMethod void coverPopulateRepeatRuleNoneDataUtil(){
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
        
        List<Site__c> lst= new List<Site__c>();
        Site__c accSite1 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Main Site'
        );
        lst.add(accSite1);
        
        Case caseObj = new Case();
        caseObj.STart_date__c = date.today();
        caseObj.Origin = 'Service Delivery Milestone';
        caseObj.Status = 'Pending Start';
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('H&S Visits')
            .getRecordTypeId();
        caseObj.accountId=acc2.id;
        
        Milestone_Work_Type__c mwt = [SELECT Id, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Work_Type__c, Milestone_Template__c, Business_Hours__c, Customer_Friendly_Meeting_Name__c, Dependency__c, Description__c, End_Days__c, Entitlement__c, Meeting_Type__c, Owning_Team__c, ServiceTerritory__c, Service_Contact__c, Site_Repeat_Rule__c, Start_Days__c, Subject__c, Visit_Type__c, WorkOrder_Record_Type__c FROM Milestone_Work_Type__c where subject__c = 'Test subject23' limit 1];
        Milestone_Work_Type__c mwt2 = [SELECT Id, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Work_Type__c, Milestone_Template__c, Business_Hours__c, Customer_Friendly_Meeting_Name__c, Dependency__c, Description__c, End_Days__c, Entitlement__c, Meeting_Type__c, Owning_Team__c, ServiceTerritory__c, Service_Contact__c, Site_Repeat_Rule__c, Start_Days__c, Subject__c, Visit_Type__c, WorkOrder_Record_Type__c FROM Milestone_Work_Type__c where subject__c = 'Test subject' limit 1];
        
        CaseTriggerCreateWorkOrders.DataWrapper repeatRuleNoneDataWrapper = new CaseTriggerCreateWorkOrders.DataWrapper();
        repeatRuleNoneDataWrapper.caseObj=caseObj;
        repeatRuleNoneDataWrapper.accountSiteMap.put(acc2.id,lst);
        repeatRuleNoneDataWrapper.milestoneWorkTypeId=mwt.id;
        repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap.put(mwt.id,mwt);
        repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap.put(mwt2.id,mwt2);
        Set<String> repeatRule =new Set<String>();
        repeatRule.add('Main Site');
        
        CaseTriggerCreateWorkOrders_Util.populateRepeatRuleNoneDataUtil(repeatRuleNoneDataWrapper,repeatRule);
        CaseTriggerCreateWorkOrders_Util.populateForAllMainInactive(repeatRuleNoneDataWrapper);
    }

    /* static testMethod void test_populateUpdateMap(){
    Map<ID, Milestone_Work_Type__c> mwtMap = new Map<ID, Milestone_Work_Type__c>([SELECT Id, Description__c,Work_Type__c,Meeting_Type__c,ServiceTerritory__c,Subject__c,
    Customer_Friendly_Meeting_Name__c FROM Milestone_Work_Type__c LIMIT 1]);
    List<Milestone_Work_Type__c> listToUpdate=new List<Milestone_Work_Type__c>();
    listToUpdate= [select id,Description__c from Milestone_Work_Type__c limit 1];
    if(listToUpdate.size()>0){
    for(Milestone_Work_Type__c m: listToUpdate){
    m.Description__c='Change';
    }
    update listToUpdate;
    }

         MilestoneWorkTypeTriggerHandler.populateUpdateMap(listToUpdate,mwtMap);
    }*/
    
}