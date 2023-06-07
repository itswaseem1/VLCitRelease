@isTest
public class AdviceBoxUIControllerTest {
    @isTest
    public static void testUpdateRelatedAdviceRecord() {
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'shaws');
        List<Contact> cList = new List<Contact>(); 
        cList.add(testContact); 
        insert cList;
        
        
        Employee__c newEmployee = new Employee__c(LastName__c = 'Test employee',FirstName__c = 'TestEmp', Account_Name__c = testAccount.Id);
        insert newEmployee;
        
        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;
        System.assertEquals(1, [SELECT COUNT() FROM Case], ' Case records amount');
        
        Advice__c advice = new Advice__c(
            Case__c = newCase.Id,
            Matter_Type__c='Agency Workers',
            Sub_Matter__c='Discrimination'
        );
        insert advice;
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        Test.startTest();
        Case a = [SELECT Id, subject FROM Case WHERE subject='test subject' LIMIT 1];
        
       // AdviceBoxUIController.fetchAdvice(a.Id) ;
        AdviceBoxUIController.adviceInsert('{"Advice__c":"<p>m4</p>","Sensitive_Case__c":true,"Matter_Type__c":"Agency Workers","Sub_Matter__c":"Discrimination","Advice_Guarantee__c":true,"Case__c":"' +  a.Id+ '","Advice_contact__c":""}');
       // AdviceBoxUIController.adviceDelete(advice.id);
        Test.stopTest();
    }
    /*----------------------test method for fetchAdvice-----------------------*/
    @isTest
    public static void testMethodForFetchAdvice()
    {
        //SPA-107 Change
        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;
        
        Advice__c advice = new Advice__c(
            Case__c = newCase.Id,
            Matter_Type__c='Agency Workers',
            Sub_Matter__c='Discrimination'
        );
        insert advice;
        //User usr = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'ELT Advisor Manager') AND isActive = TRUE LIMIT 1];
        List<Advice__c> ad;
        Test.startTest();
        //System.runAs(usr)
        {
        ad = AdviceBoxUIController.fetchAdvice(newCase.Id) ;
        }
        Test.stopTest();
        System.assertEquals('Agency Workers',ad[0].Matter_Type__c);
    }
    /*----------------------test method for getCaseData----------------------------*/
    @isTest
    public static void testMethodForGetCaseData(){
        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;
        Test.startTest();
        case ad = AdviceBoxUIController.getCaseData(newCase.Id) ;
        Test.stopTest();
        System.assertEquals('ELT Advice - Generic',ad.RecordTypeName__c );
        }
    
     @isTest
    public static void testMethodAdviceDelete() {
 
        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;
        
        Advice__c advice = new Advice__c(
            Case__c = newCase.Id,
            Matter_Type__c='Agency Workers',
            Sub_Matter__c='Discrimination'
        );
        insert advice;
        
        Profile testProfile = [SELECT Id 
                           FROM profile
                           WHERE Name = 'System Administrator' 
                           LIMIT 1];

        User testUser = new User(LastName = 'test user 1', 
                             Username = 'test.user.4321@example.com', 
                             Email = 'test.1@citation.co.uk', 
                             Alias = 'testu12', 
                             TimeZoneSidKey = 'GMT', 
                             LocaleSidKey = 'en_GB', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             ProfileId = testProfile.Id, 
                             LanguageLocaleKey = 'en_US'); 
        
        System.runas(testUser) {
        
        Test.startTest();
        
        boolean del = AdviceBoxUIController.adviceDelete(advice.id);
            
        System.debug(del);
        Test.stopTest();
       
        }
        
        System.assertEquals(0,[select id from Advice__c where Matter_Type__c='Agency Workers' and Sub_Matter__c='Discrimination' ].size());
        
        
    }
    /*----------------------test method for fetchAdvice-----------------------*/
    
    @isTest
    public static void testMethodForGetRecordType(){
        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;
        Test.startTest();
        string ad = AdviceBoxUIController.getRecordTypeName(newCase.Id) ;
        Test.stopTest();
        System.assertEquals('ELT Advice - Generic',ad);

        }
    
    @isTest
    public static void testUpdateRelatedAdviceRecordWithException() {
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'shaws');
        List<Contact> cList = new List<Contact>(); 
        cList.add(testContact); 
        insert cList;
        
        
        Employee__c newEmployee = new Employee__c(LastName__c = 'Test employee',FirstName__c = 'TestEmp', Account_Name__c = testAccount.Id);
        insert newEmployee;
        
        Case newCase = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId(),
            subject = 'test subject'
        );
        insert newCase;
        System.assertEquals(1, [SELECT COUNT() FROM Case], ' Case records amount');
        
        Advice__c advice = new Advice__c(
            Case__c = newCase.Id,
            Matter_Type__c='Agency Workers',
            Sub_Matter__c='Discrimination'
        );
        insert advice;
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        Test.startTest();
        Case a = [SELECT Id, subject FROM Case WHERE subject='test subject' LIMIT 1];
        
       // AdviceBoxUIController.fetchAdvice(a.Id) ;
        AdviceBoxUIController.adviceInsert('{"Advice__c":"<p>m4</p>","Sensitive_Case__c":true,"Advice_Guarantee__c":true,"Case__c":"' +  a.Id+ '","Advice_contact__c":""}');
       // AdviceBoxUIController.adviceDelete(advice.id);
        Test.stopTest();
    }
    
}