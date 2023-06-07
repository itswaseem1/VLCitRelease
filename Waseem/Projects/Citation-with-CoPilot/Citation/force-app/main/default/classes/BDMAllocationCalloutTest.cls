@isTest
public class BDMAllocationCalloutTest {
    @testSetup static void setup() {
        // Create common test accounts
        Id recType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
        List<Lead> testLead = new List<Lead>();
         Lead l = new Lead();
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         System.runAs (thisUser){
           User u = TestDataFactory.generateUser();
            l.RecordTypeId = recType;
           l.Email = 'test123@gmail.com';
           l.CurrencyIsoCode = 'GBP';
           l.FirstName = 'Test';
           l.Salutation = 'Mr';
           l.LastName = 'BDMProspectwithDataQuality';
           l.Company = 'Citation';
           l.Status = 'Data Quality';
           l.Appointment_Type__c = 'Combined';
           l.LeadSource = 'Add on';
           l.MADE_Criteria__c = 'Inbound - 1';
           l.Street = 'North Avenue';
           l.PostalCode = '112233';
           l.BDC__c = u.Id;
           l.CitationSector__c = 'CARE';
           l.Position__c = 'Accountant';
           l.Visit_Type__c = 'Virtual';
           testLead.add(l);
          insert testLead; 
             List<Account> testAcc=TestDataFactory.getAccounts(1,'TestAcccountwithBDM',false);
        if(!testAcc.isEmpty() && testAcc.size()>0){
          testAcc[0].FT_Employees__c=10;
          testAcc[0].PT_Employees__c=10;
          testAcc[0].CitationSector__c='AGRICULTURE';
          testAcc[0].BillingPostalCode='12345';
          insert testAcc[0];
            System.debug('Hi Account Name '+testAcc[0].Name);
          List<Opportunity> testOpp=TestDataFactory.generateOppsForAccount(testAcc[0].Id,1000,1,false);
          testOpp[0].MADE_Criteria__c='Inbound - 1';
          //testOpp[0].Appointment_Type__c='Combined';
          testOpp[0].LeadSource='Add on';
          insert testOpp[0];
        }
        }       
   }
    
    @isTest
    static void getAvailabilitypositiveTest(){
        BDMAllocationTest book = new BDMAllocationTest();
        string res = '{"body":"Postal Code cannot be empty;Prospect Source;Citation Sector;MADE Criteria;Appointment Type;"}';
    List<Lead> testlead = TestDataFactory.getLeads(1,'TestLeadwithDataQuality','Citation',true);
        
        //Lead testlead = [select Id,LeadSource,PostalCode, Company, CitationSector__c,Marketing_Channel__c,  MADE_Criteria__c,Appointment_Type__c, FT_Employees__c from lead where Lead.PostalCode!=null AND Lead.Company!=null AND Lead.CitationSector__c!=null AND Lead.MADE_Criteria__c!=null AND Lead.Marketing_Channel__c!=null AND Lead.Appointment_Type__c!=null AND Lead.FT_Employees__c!=null limit 1];
         String s = testlead[0].Id;
        List<Opportunity> testOpp=[select Id from Opportunity where Account.Name LIKE 'TestAcccountwithBDM%'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, book);
    String response = BDMAllocation.getAvailability(s,'Lead');
        if(!testOpp.isEmpty() && testOpp.size()>0){
            String oppId = testOpp[0].Id;
            String responseforOpp = BDMAllocation.getAvailability(oppId,'Opportunity');
        }        
        Test.stopTest();
        system.assertNotEquals(res, response);
    }
  @isTest
    static void getAvailabilitynegativeTest(){
        List<Lead> testlead = TestDataFactory.getLeads(1,'TestLeadwithoutDataQuality','Citation',true);        
        String s = testlead[0].Id;
        /*BookYourAppointment.MissingFieldsinfo bm = new BookYourAppointment.MissingFieldsinfo();
        bm.Postalcode = 'Postalcode';
        bm.LeadSource = 'Prospect Source';
        bm.Company = 'Company';
        bm.CitationSector ='CitationSector';
        bm.MADECriteria = 'MADE Criteria';
        bm.MarketingChannel = 'Marketing Channel';
        bm.AppointmentType = 'Appointment Type';
        bm.FT_Employees = 'FT Employees';*/
        BDMAllocationTest book = new BDMAllocationTest();
        Test.setMock(HttpCalloutMock.class, book);
        BDMAllocation bappt = new BDMAllocation();
    String result = BDMAllocation.getAvailability(s,'Lead');                
        system.assertNotEquals('200', result);
    }
    @isTest
    static void testConfirmBooking(){
        BDMAllocationTest book = new BDMAllocationTest();
        Lead testlead = [select Id from lead where Name='Test BDMProspectwithDataQuality' limit 1];
        Opportunity testOpp=[select Id from Opportunity where Account.Name LIKE 'TestAcccountwithBDM%' limit 1];
        User u = [select Id, Name from User where Username like '%glennmaxwell@citation.co.uk%'];
        //User u = TestDataFactory.generateUser();
        String s = testlead.Id;
        String oppId=testOpp.Id;
        String reqId = '729d8cc4-ec66-4e91-be87-4e97d76a6323';
        BDMAllocation.confirmbookingparam bcparam = new BDMAllocation.confirmbookingparam();
        bcparam.BDMId = u.Id;
        bcparam.BDMName = u.Name;
    bcparam.Date_Z = '2021-05-24';
        bcparam.Day = 'Wednesday';
        bcparam.Score = 90;
        bcparam.Slot_End_Time = '09:30:00';
        bcparam.Slot_Start_Time = '17:00:00';
        Test.startTest();
         String res = BDMAllocation.ConfirmBooking(s, reqId, bcparam, '10:30:00', '11:00:00', 30,'Lead');
        Test.setMock(HttpCalloutMock.class, book);        
    	BDMAllocation.makecallout(s); 
        String resOpp = BDMAllocation.ConfirmBooking(oppId, reqId, bcparam, '10:30:00', '11:00:00', 30,'Opportunity');      
    	BDMAllocation.makecallout(oppId); 
        Test.stopTest();
        system.assertEquals('{"status":200,"body":"Event Created Sucessfully for BDM Glenn Maxwell"}', res);
    }
    /*@isTest
    static void testConfirmBookingwithoutDataquality(){
        BDMAllocationTest book = new BDMAllocationTest();
         List<Lead> testlead1 = TestDataFactory.getLeads(1,'TestLeadwithoutDataQuality','Citation',true);
        //Lead testlead1 = [select Id from lead where Lead.Status!= 'Data Quality' limit 1];          
        User u = [select Id, FirstName, LastName, Name from User where Username like '%glennmaxwell@citation.co.uk%'];                  
        string s1 = testlead1[0].Id;
        string testbody;
        BDMAllocation.confirmbookingparam bcparam = new BDMAllocation.confirmbookingparam();
        bcparam.BDMId = u.Id;
        bcparam.BDMName = u.FirstName+u.LastName;
    bcparam.Date_Z = '2021-05-24';
        bcparam.Day = 'Wednesday';
        bcparam.Score = 90;
        bcparam.Slot_End_Time = '09:30:00';
        bcparam.Slot_Start_Time = '17:00:00';
        testbody = 'Event Created Sucessfully for BDM'+''+bcparam.BDMName;
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, book);
        String result = BDMAllocation.ConfirmBooking(s1, bcparam, '10:30:00', '11:00:00', 30);
        system.debug('result+++'+result);
        Test.stopTest();
    }*/
    
    @isTest
    public static void getAvailabilityErrorTest(){
        //Insert an User Role
        UserRole userRole = new UserRole(DeveloperName = 'SystemAdmin', Name = 'Citation Limited');
        insert userRole;
        //Insert an User
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Citation Data Admin' LIMIT 1].Id,
            LastName        = 'Salesforce Admin',
            Email           = 'SalesforceAdminTest@citation.co.uk',
            Username        = 'SalesforceAdminTest@citation.co.uk',
            CompanyName     = 'Citation Company',
            Title           = 'Captian',
            Alias           = 'SAT',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US',
            UserRoleId      = userRole.Id
        );
        insert u;
        //Get Lead and Update Owner and LeadSource
         BDMAllocationTest book = new BDMAllocationTest();
         Lead leadstoUpdateSource=[Select Id,LeadSource From Lead Where Email='test123@gmail.com'];
        System.runAs(u){
            leadstoUpdateSource.OwnerId=u.Id;
            leadstoUpdateSource.LeadSource='BDM_BDC_SelfGen';
            Update leadstoUpdateSource;
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, book);
                String response = BDMAllocation.getAvailability(leadstoUpdateSource.Id,'Lead'); 
            Test.stopTest();
        }
    }
}