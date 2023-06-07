@isTest
public class ServiceAppointmentTriggerTest {

    @testsetup
    static void datacreation()
    {
        User u = new User();
        u.FirstName='test';
        u.LastName='user';
        u.Username='testusersa@citation.co.uk';
        u.ProfileId=[select id from Profile where name='Citation Data Admin'].id;
        u.UserRoleId=[SELECT Id From UserRole WHERE Name ='System Admin'].Id;
        u.Email='testusersa@citation.co.uk';
        u.Alias='tuser';
        u.TimeZoneSidKey='Europe/London';
        u.LocaleSidKey='en_GB';
        u.EmailEncodingKey='ISO-8859-1';
        u.LanguageLocaleKey='en_US';
        insert u;
        
        PermissionSetAssignment psa = new  PermissionSetAssignment();
        psa.PermissionSetId = [select id from Permissionset where name='FSL_Resource_Permissions'].id;
        psa.AssigneeId=u.id;
        insert psa;
        PermissionSetAssignment psa1 = new  PermissionSetAssignment();
        psa1.PermissionSetId = [select id from Permissionset where name='Citation_Support_Admin'].id;
        psa1.AssigneeId=u.id;
        insert psa1;
        PermissionSetAssignment psa2 = new  PermissionSetAssignment();
        psa2.PermissionSetId = [select id from Permissionset where name='SDP_PermissionSet'].id;
        psa2.AssigneeId=u.id;
        insert psa2;

        system.runAs(u)
        {
        OperatingHours oh = new OperatingHours();
        oh.Name='testoperatinghours';
        oh.TimeZone='Europe/London';
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory();
        st.Name='testterritory';
        st.OperatingHoursId=oh.id;
        st.IsActive=true;
        insert st;
        
        ServiceResource sr = new ServiceResource();
        sr.Name='testresource';
        sr.RelatedRecordId=u.id;
        sr.ResourceType='T';
        sr.IsActive=true;
        insert sr;
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId=sr.id;
        stm.ServiceTerritoryId=st.id;
        stm.Street='teststreet';
        stm.City='testcity';
        stm.State='teststate';
        stm.Country='testcountry';
        stm.PostalCode='testcode';
        stm.TerritoryType='P';
        stm.EffectiveStartDate=system.now();
        insert stm;
            
                     
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
        
               Contact con = new Contact();
    con.LastName='test';
    con.AccountId =acc2.id;
	con.Main_User__c = 'yes';
    insert con;    
            
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
        WorkOrder workOrderObj  = new WorkOrder();
        workOrderObj.StartDate = date.today();
        workOrderObj.Description = 'Test';
        workOrderObj.Subject =  'Test';
        insert workOrderObj;
        ServiceAppointment sa =  new ServiceAppointment();
        sa.EarliestStartTime=system.today();
        sa.DueDate=system.today()+10;
        sa.Visit_Type__c='Virtual';
        sa.ParentRecordId=workOrderObj.id;
        sa.Status='In Progress';
        sa.ActualEndTime = system.now();
        sa.SchedStartTime=system.today()+1;
        sa.SchedEndTime=system.today()+2;
            sa.AccountSite__c = siteList[0].Id;
            sa.ContactId = con.Id;
            sa.ActualStartTime =system.now();
        insert sa;
        AssignedResource ar = new AssignedResource();
        ServiceAppointment saupdate = [select id,Visit_Type__c,status from ServiceAppointment];
        ar.ServiceResourceId=[select id from ServiceResource].id;
        ar.ServiceAppointmentId=saupdate.id;
        insert ar;
        
    }
    }  
    @istest 
    static void testaddressupdate()
    {
        
   
        ServiceAppointment  sa = [select id,status,ActualEndTime from ServiceAppointment];
      //  sa.status ='Dispatched';
        
        
        update sa;
        test.startTest();
         sa.status ='Completed';
        
        update sa;
        System.assertEquals('Completed', [select id,street,status from ServiceAppointment].status, 'success');
        test.stopTest();
    }
    
    
}