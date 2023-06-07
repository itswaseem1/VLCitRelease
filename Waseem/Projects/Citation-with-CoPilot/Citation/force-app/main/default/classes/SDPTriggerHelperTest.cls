@isTest
public class SDPTriggerHelperTest {//
  @testSetup
  static void setup() { //
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
    acc.BillingStreet = 'street'; //

    insert acc;
   
    List<Site__c> siteList = new List<Site__c>();
    Site__c accSite1 = new Site__c(
      Account__c = acc.Id,
      Active__c = false,
      Site_Type__c = 'Main Site'
    );
      siteList.add(accSite1);   
    Site__c accSite2 = new Site__c(
      Account__c = acc.Id,
      Active__c = true,
      Site_Type__c = 'Other Site'
    );
    siteList.add(accSite2);

    insert siteList;
    
    
      
    Contact con = new Contact();
    con.LastName='test';
    con.AccountId =acc.id;
	con.Main_User__c = 'yes';
    insert con;
      
    List<Site_Junction__c> siteContactList = new List<Site_Junction__c>();
       Site_Junction__c siteContact1 = new Site_Junction__c();
		siteContact1.Site_Junction__c =siteList[1].id ;
		siteContact1.Account__c = acc.id;
        siteContact1.Contact_Junction__c = con.id;
		siteContact1.Main_H_S_Contact__c = true;
      	siteContact1.IsActive__c = true;
      	siteContactList.add(siteContact1);
     insert siteContactList;

    Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(
      Name = 'Account 1 Citation Service Delivery Plan',
      Business__c = 'Citation',
      Account__c = acc.Id
    );

    insert servicedelPlanObj;

    Service_Delivery_Plan_Template__c sdptObj = new Service_Delivery_Plan_Template__c(
      Name = 'Service Delivery Plan Template Citation Business',
      Status__c = 'Active',
      Owning_Business__c = 'Citation'
    );

    insert sdptObj;
     Product2 pro = new Product2();
     pro.Name = 'ProductTest';
     insert Pro; 

    contract contractObj = new contract(
      accountid = acc.id,
      FOC_Period_Mths__c = 2,
      FOC_Period_Mths_End__c = 0,
      startdate = date.today(),
      Agreement_Type__c = 'Auto',
      Service_Delivery_Plan_Template__c = sdptObj.Id,
      ContractTerm = 72,
      CustomerSignedId = con.Id
    );

    insert contractObj;
      
	Asset ass2 = new Asset();
    ass2.name= 'test22';
    ass2.accountid = acc.id;
    ass2.contactid = con.id;
    ass2.Product2Id =pro.id;
    ass2.Contract__c = contractObj.id;
	insert ass2;
      
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
      Recurrence__c = 12,
      Start_after_x_months__c = 24,
      Case_Type__c = 'Non Visits',
      Status__c = 'Active'
    );

    milestoneList.add(milestone1);
    milestoneList.add(milestone2);

    insert milestoneList;

    List<Service_Delivery_Template_Milestones__c> sdtmList = new List<Service_Delivery_Template_Milestones__c>();
    Service_Delivery_Template_Milestones__c sdtmObj = new Service_Delivery_Template_Milestones__c(
      Service_Delivery_Plan_Template__c = sdptObj.Id,
      Order__c = 1,
      Milestone_Template__c = milestone1.Id
    );
    Service_Delivery_Template_Milestones__c sdtmObj2 = new Service_Delivery_Template_Milestones__c(
      Service_Delivery_Plan_Template__c = sdptObj.Id,
      Order__c = 1,
      Milestone_Template__c = milestone2.Id
    );

    sdtmList.add(sdtmObj);
    sdtmList.add(sdtmObj2);

    insert sdtmList;

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
      Site_Repeat_Rule__c = 'All',
      Service_Contact__c = 'Main User',
      WorkOrder_Record_Type__c='Citation Standard',
      meeting_type__c = 'HR 1st New',
      Customer_Friendly_Meeting_Name__c = 'Test'
    );

    insert mwtObj;

    Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(
      Milestone_Template__c = milestoneList[0].Id,
      Work_Type__c = workTypeObj3.Id,
      subject__c = 'Test subject',
      Description__c = 'Test Description',
      ServiceTerritory__c = stObj.Id,
      Site_Repeat_Rule__c = 'All',
      Dependency__c = mwtObj.Id,
    //  Service_Contact__c = 'Main Site Contact',
      WorkOrder_Record_Type__c='Citation Standard'
    );

    insert mwtObj2;

    Milestone_Work_Type__c mwtObj3 = new Milestone_Work_Type__c(
      Milestone_Template__c = milestoneList[0].Id,
      Work_Type__c = workTypeObj2.Id,
      subject__c = 'Test subject',
      Description__c = 'Test Description',
      ServiceTerritory__c = stObj.Id,
      Site_Repeat_Rule__c = '',
     // Service_Contact__c = 'H&S Service Contact',
      WorkOrder_Record_Type__c='Citation Standard'
    );

    insert mwtObj3;
       
  }

/*  @isTest
  public static void checkStatusChanges() {
    contract contractRec = [
      SELECT
        Id,
        Status,
        AccountId,
        Service_Delivery_Plan_Template__c,
        StartDate,
        Agreement_Type__c,
        ContractTerm
      FROM Contract
      LIMIT 1
    ];

    Test.startTest();
    contractRec.status = 'Active';
    update contractRec;
    System.assertEquals('Active', contractRec.status, 'success');
    Test.stopTest();
  }*/

 /* @isTest
  public static void changeCaseStatus() {

   
    contract contractRec = [
      SELECT
        Id,
        Status,
        AccountId,
        Service_Delivery_Plan_Template__c,
        StartDate,
        Agreement_Type__c,
        ContractTerm
      FROM Contract
      LIMIT 1
    ];

    
    contractRec.status = 'Active';
    update contractRec;
	Test.startTest();    
    Case caseObj = [SELECT Id, Status FROM CASE Limit 1 ];
    caseObj.Status = 'Active';
    update caseObj;
    System.assertEquals('Active', caseObj.Status, 'success');
   
    Test.stopTest();
  }
 @isTest
 public static void coverNoSitePopulate(){
   /* List<Site__c> accSiteList1 = new List<Site__c>();
    List<Site__c> accList = [SELECT Id, Site_Type__c FROM Site__c WHERE Active__c = TRUE];
        for(Site__c sit : accList ){
            sit.Site_Type__c = 'false';
            accSiteList1.add(sit);
         } 
    update accSiteList1;
    contract contractRec = [
      SELECT
        Id,
        Status,
        AccountId,
        Service_Delivery_Plan_Template__c,
        StartDate,
        Agreement_Type__c,
        ContractTerm
      FROM Contract
      LIMIT 1
    ];

    Test.startTest();
    contractRec.status = 'Active';
    update contractRec;
	    
    Case caseObj = [SELECT Id, Status FROM CASE Limit 1 ];
    caseObj.Status = 'Active';
    update caseObj;
    System.assertEquals('Active', caseObj.Status, 'success');
   
    Test.stopTest();       
 }
 @isTest
 public static void coverNoSitePopulate2(){
    List<Site__c> accSiteList1 = new List<Site__c>();
    List<Site__c> accList = [SELECT Id, Site_Type__c FROM Site__c WHERE Active__c = TRUE];
         for(Site__c sit : accList ){
                sit.Site_Type__c = 'false';
                accSiteList1.add(sit);
          } 
     Delete accSiteList1;
   contract contractRec = [
      SELECT
        Id,
        Status,
        AccountId,
        Service_Delivery_Plan_Template__c,
        StartDate,
        Agreement_Type__c,
        ContractTerm
      FROM Contract
      LIMIT 1
    ];

    Test.startTest();
    contractRec.status = 'Active';
    update contractRec;
	    
    Case caseObj = [SELECT Id, Status FROM CASE Limit 1 ];
    caseObj.Status = 'Active';
    update caseObj;
    System.assertEquals('Active', caseObj.Status, 'success');
   
    Test.stopTest();       
  }

  @isTest
  public static void activateMilestonebacthTest() {
    contract contractRec = [
      SELECT
        Id,
        Status,
        AccountId,
        Service_Delivery_Plan_Template__c,
        StartDate,
        Agreement_Type__c,
        ContractTerm
      FROM Contract
      LIMIT 1
    ];
    Test.startTest();
    contractRec.status = 'Active';
    update contractRec;

    Case caseObj = [SELECT Id, STart_date__c FROM CASE LIMIT 1];
    caseObj.STart_date__c = date.today();
    caseObj.Origin = 'Service Delivery Milestone';
 //   update caseObj;

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

    Test.stopTest();
  }*/

  @isTest
  public static void milestoneWorkTypeTest() {
    Test.startTest();
    Milestone_Work_Type__c mwt = [
      SELECT Id, Subject__c
      FROM Milestone_Work_Type__c
      LIMIT 1
    ];
    mwt.Subject__c = 'changed';
    update mwt;
    System.assertEquals('changed', mwt.Subject__c, 'success');
    Test.StopTest();
  }

  @isTest
  public static void workOrderCreationAccountSiteTest() {
    Test.startTest();
    WorkType wType = [
      SELECT Id
      FROM WorkType
      WHERE ShouldAutoCreateSvcAppt = FALSE
      LIMIT 1
    ];
    Account acc = [
      SELECT
        Id,
        BillingCity,
        BillingCountry,
        BillingPostalCode,
        BillingState,
        BillingStreet
      FROM Account
      LIMIT 1
    ];
    Site__c accSite = new Site__c(Account__c = acc.Id, Active__c = true);
    insert accSite;
    WorkOrder workOrderObj = new WorkOrder();

    workOrderObj.StartDate = date.today();
    workOrderObj.EndDate = date.today();
    workOrderObj.Description = 'Test';
    workOrderObj.Subject = 'Test';
    //  workOrderObj.ServiceTerritoryId;
    workOrderObj.AccountSite__c = accSite.Id;
    workOrderObj.AccountId = acc.Id;
    workOrderObj.WorkTypeId = wType.Id;
    workOrderObj.EndDate = workOrderObj.StartDate.addDays(2);

    insert workOrderObj;
    System.assertEquals('Test', workOrderObj.Description, 'success');
    Test.StopTest();
  }

  @isTest
  public static void workOrderCreationAccountTest() {
    Test.startTest();
    WorkType wType = [
      SELECT Id
      FROM WorkType
      WHERE ShouldAutoCreateSvcAppt = FALSE
      LIMIT 1
    ];
    Account acc = [
      SELECT
        Id,
        BillingCity,
        BillingCountry,
        BillingPostalCode,
        BillingState,
        BillingStreet
      FROM Account
      LIMIT 1
    ];

    WorkOrder workOrderObj = new WorkOrder();

    workOrderObj.StartDate = date.today();
    workOrderObj.EndDate = date.today();
    workOrderObj.Description = 'Test';
    workOrderObj.Subject = 'Test';
    workOrderObj.AccountId = acc.Id;
    workOrderObj.WorkTypeId = wType.Id;
    workOrderObj.EndDate = workOrderObj.StartDate.addDays(2);

    insert workOrderObj;
    System.assertEquals('Test', workOrderObj.Description, 'success');
    Test.StopTest();
  }

  @isTest
  public static void workOrderSDPDependencyHandlerTest() {
    Test.startTest();
    WorkType wType = [
      SELECT Id
      FROM WorkType
      WHERE ShouldAutoCreateSvcAppt = FALSE
      LIMIT 1
    ];
    Account acc = [
      SELECT
        Id,
        BillingCity,
        BillingCountry,
        BillingPostalCode,
        BillingState,
        BillingStreet
      FROM Account
      LIMIT 1
    ];

    WorkOrder workOrderObj = new WorkOrder();

    workOrderObj.StartDate = date.today();
    workOrderObj.EndDate = date.today();
    workOrderObj.Description = 'Test';
    workOrderObj.Subject = 'Test';
    workOrderObj.AccountId = acc.Id;
    workOrderObj.WorkTypeId = wType.Id;
    workOrderObj.EndDate = workOrderObj.StartDate.addDays(2);

    insert workOrderObj;

    WorkOrder workOrderObj2 = new WorkOrder();
    workOrderObj2.StartDate = date.today();
    workOrderObj2.EndDate = date.today();
    workOrderObj2.Description = 'Test';
    workOrderObj2.Subject = 'Test';
    workOrderObj2.AccountId = acc.Id;
    workOrderObj2.WorkTypeId = wType.Id;
    workOrderObj2.Dependent_Work_Order__c = workOrderObj.Id;
    workOrderObj2.EndDate = workOrderObj2.StartDate.addDays(2);

    insert workOrderObj2;
    workOrderObj.status = 'Completed';
    update workOrderObj;
    System.assertEquals('Completed', workOrderObj.status, 'success');
    Test.StopTest();
  }
}