@isTest
public class AssetExpireMonthCheckBatchTest {

    @testSetup
    static void dataSetup(){
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
        
    Product2 prod = new Product2(Name='test Product',Business_Type__c='Citation');
    insert prod;
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
      
    Asset asset = new Asset();
        asset.name='Test asset';
        asset.AccountId=acc.id;
        asset.ContactId=con.id;
        asset.Service_Start_Date__c=system.today()-210;
        asset.Service_End_date__c=system.today()-1;
        asset.Product2Id=prod.id;
        insert asset;
 
        Case assetcase = new Case();
        assetcase.AccountId=acc.Id;
        assetcase.AssetId = asset.id;
        assetcase.Status='New';
        insert assetcase;
        
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
    List<WorkType> worTList = new List<WorkType>();    
    WorkType workTypeObj1 = new WorkType(
      Name = 'Documentation',
      EstimatedDuration = 2.00,
      DurationType = 'Hours',
      ShouldAutoCreateSvcAppt = true
    );
    worTList.add(workTypeObj1);

    WorkType workTypeObj2 = new WorkType(
      Name = 'Non Documentation',
      EstimatedDuration = 2.00,
      DurationType = 'Hours',
      ShouldAutoCreateSvcAppt = false
    );
    worTList.add(workTypeObj2);

    WorkType workTypeObj3 = new WorkType(
      Name = 'Non Documentation',
      EstimatedDuration = 2.00,
      DurationType = 'Hours',
      ShouldAutoCreateSvcAppt = false
    );
     worTList.add(workTypeObj3);
    insert worTList;


    operatingHours hObj = new Operatinghours(Name = 'Test');
    insert hObj;
	List<ServiceTerritory> stList = new List<ServiceTerritory>();   
    ServiceTerritory stObj = new ServiceTerritory(
      Name = 'H&S Territory',
      OperatingHoursId = hObj.Id,
      isActive = true
    );
    stList.add(stObj);
    ServiceTerritory stObj1 = new ServiceTerritory(
      Name = 'Noviqa Territory',
      OperatingHoursId = hObj.Id,
      isActive = true
    );
    stList.add(stObj1);
    ServiceTerritory stObj2 = new ServiceTerritory(
      Name = 'QMS Territory',
      OperatingHoursId = hObj.Id,
      isActive = true
    );
    stList.add(stObj2);
    insert stList;

    Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
      Milestone_Template__c = milestoneList[0].Id,
      Work_Type__c = worTList[0].Id,
      subject__c = 'Test subject',
      Description__c = 'Test Description',
      ServiceTerritory__c = stObj.Id,
      Site_Repeat_Rule__c = 'All',
      Service_Contact__c = 'Main User',
      WorkOrder_Record_Type__c='Citation Standard',
      meeting_type__c = 'HR 1st New',
      Customer_Friendly_Meeting_Name__c = 'test'
    );

    insert mwtObj;
	List<workOrder> woList = new List<workOrder>();  
	workOrder wo = new workOrder();
	wo.Status = 'New';
	wo.Priority = 'Low';
	wo.Duration =2.00;
    wo.CaseId=assetcase.id;
    woList.add(wo);
        
    workOrder wo1 = new workOrder();
	wo1.Status = 'New';
	wo1.Priority = 'Low';
	wo1.Duration =2.00;
    wo1.CaseId = assetcase.id;
    wo1.ServiceTerritoryId = stObj2.id;
    wo1.Visit_Type__c = 'Face-To-Face';
    wo1.AccountSite__c = siteList[0].id;
    woList.add(wo1);
	insert woList;
	
    List<ServiceAppointment> saList = new List<ServiceAppointment>();  
	ServiceAppointment sa = new ServiceAppointment();
	sa.Status = 'none';
	sa.ParentRecordId = woList[0].Id;
	sa.EarliestStartTime = DateTime.now();
	sa.DueDate = DateTime.now();
	sa.Duration = 2.00;
	sa.Milestone_Work_Type__c = mwtObj.id;
	sa.Meeting_Type__c = 'HR System Training';
	sa.ServiceTerritoryId = stList[0].id;
	sa.ContactId = con.Id;
	//sa.Visit_Type__c = 'Face-To-Face';
	sa.SchedStartTime = system.today()+3;
	sa.SchedEndTime = system.today() +5;
	saList.add(sa);
        
    ServiceAppointment saTeri = new ServiceAppointment();
	saTeri.Status = 'none';
	saTeri.ParentRecordId = woList[1].Id;
	saTeri.EarliestStartTime = DateTime.now();
	saTeri.DueDate = DateTime.now();
	saTeri.Duration = 2.00;
	saTeri.Milestone_Work_Type__c = mwtObj.id;
	//saTeri.Meeting_Type__c = 'HR System Training (F2F)';
	saTeri.ServiceTerritoryId = stList[2].id;
	saTeri.ContactId = con.Id;
	//saTeri.Visit_Type__c = 'Face-To-Face';
	saTeri.SchedStartTime = system.today()+3;
	saTeri.SchedEndTime = system.today() +5;
    saList.add(saTeri);
	insert saList ;    
    }
   
    static testmethod void testAssetExpiryBatch()
    {
        test.startTest();
        try{
        AssetExpireMonthCheckBatchScheduler obj = new AssetExpireMonthCheckBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, obj );
        }
        catch (DmlException e){
                //Assert Error Message 
               System.assert( e.getMessage().contains('Update failed'),e.getMessage() );
        }
        test.stopTest();
    }
}