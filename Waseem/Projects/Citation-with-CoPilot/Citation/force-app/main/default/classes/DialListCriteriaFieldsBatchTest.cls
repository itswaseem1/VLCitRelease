@isTest
public class DialListCriteriaFieldsBatchTest {
    @testSetup
    public static void makeData(){
        List<Lead> leadList = new List<Lead>();
        List<Job_Execution_Status_Update__mdt> errorList = new List<Job_Execution_Status_Update__mdt>();
        //Inserting User
        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        List<User> usrList = new List<User>();
        usrList.add(createUser('Waseem','Test 1','mohammadwaseem@citation.co.uk','test1sahashgjh@test.com',u.ProfileId  ));
        usrList.add(createUser('Waseem','Test 2','mohammadwaseem@citation.co.uk','test1sahashgjh@test.com',u.ProfileId ));
        //Inserting Leads
        String defaultCitationRecordTypeName = DataConstants.LEAD_DEFAULT_CITATION_RECORD_TYPE;
        id defaultCitationRecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(defaultCitationRecordTypeName).getRecordTypeId();
        
        System.runAs(usrList[0]){
            for(Integer i=1;i<=5;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 1 '+i;
                l.Company = 'Citation Test 1 '+i;
                l.CitationSector__c = 'Education';
                l.OwnerId = usrList[0].Id;
                l.NVMConnect__NextContactTime__c = Date.today().addDays(10);
                leadList.add(l);
            }
            for(Integer i=1;i<=5;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 2 '+i;
                l.Company = 'Citation Test 2 '+i;
                l.Source__c = 'Closed Lost';
                l.PostalCode = 'BT93 BMP';
                l.OutboundCallCount__c = 2;
                l.Data_Supplier__c = 'ALL';
                l.CitationSector__c = 'CARE';
                l.Partner_CC_Exclusion__c = true;
                l.LeadSource='Add on';
                l.OwnerId = usrList[0].Id;
                leadList.add(l);
            }
            for(Integer i=1;i<=5;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 3 '+i;
                l.Company = 'Citation Test 3 '+i;
                l.Source__c = 'Closed Lost';
                l.PostalCode = 'BT93 BMP';
                l.OutboundCallCount__c = 2;
                l.Data_Supplier__c = 'keysector';
                l.CitationSector__c = 'DAY NURSERY';
                l.Partner_CC_Exclusion__c = true;
                l.Partner_CC_Exclusion__c = true;
                l.LeadSource='Add on';
                l.List_ID__c = 2;
                l.OwnerId = usrList[0].Id;
                l.NVMConnect__NextContactTime__c = Date.today().addDays(-10);
                leadList.add(l);
            }
            for(Integer i=1;i<=5;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 2 '+i;
                l.Company = 'Citation Test 2 '+i;
                l.Source__c = 'Closed Lost';
                l.RecordTypeId = defaultCitationRecordTypeId;
                l.IsTPS__c = 'No';
                l.Phone = '12345';
                l.PostalCode = 'BT93 BMP';
                l.OutboundCallCount__c = 2;
                l.Data_Supplier__c = 'ALL';
                l.PostalCode = 'BT01 011';
                l.CitationSector__c = 'CARE';
                l.Partner_CC_Exclusion__c = true;
                l.OwnerId = usrList[0].Id;
                leadList.add(l);
            }
        }
        if(leadList.size()>0 && leadList!=null){
            insert leadList;
        }
        TestDataFactory.buildCustomSettingsForDialListJobs('DialListCriteriaFieldsBatch');
        //Inserting Automation Confiuration records
        List<Automation_Configuration__c> aucRecords = TestDataFactory.createAutomationConfigurationRecords();
    }
    
    @isTest
    public static void executescheduleBatch(){
        String cronExp = '00 00 22 12 12 ? 2025';
        Test.startTest();
        System.schedule('DialList Job 1', cronExp, new DialListCriteriaFieldsBatch());
        Test.stopTest();
    }
    
     @isTest
    public static void executeBatch(){
        Test.startTest();
        Database.executeBatch(new DialListCriteriaFieldsBatch());
        Test.stopTest();
    }
    
    public static user createUser(String fn, string ln,string email, string username,id profileid){
        user u = new user();
        u.FirstName       = fn;
        u.LastName        = ln;
        u.Email           = email;
        u.Username        = username;
        u.CompanyName     = 'Citation Company';
        u.Title           = 'Captian';
        u.Alias           = 'glem';
        u.TimeZoneSidKey  = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey    = 'en_US';
        u.ProfileId = profileid;
        
        return u;
    }

}