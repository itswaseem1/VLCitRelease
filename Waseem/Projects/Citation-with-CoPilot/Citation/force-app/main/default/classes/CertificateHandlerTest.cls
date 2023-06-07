@IsTest
private class CertificateHandlerTest {
    class JitterbitServer implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}');
            response.setStatusCode(200);
            return response;
        }
    }
    @testSetup
    static void dataCreation() {
        Account testAccount1 = new Account(Name = 'Test Account 1');
        insert testAccount1;
        Account testAccount2 = new Account(Name = 'Test Account 2',IRQAO_Registrant_ID__c = 16595);
        insert testAccount2;
        IRQAO_Standard_Code__c sc = new IRQAO_Standard_Code__c(Name='1',Standard_Name__c='BS 15713 : 2009');
        insert sc;
        IRQAO_Country_Code__c cn = new IRQAO_Country_Code__c(Name='United Kingdom',Country_Id__c=1);
        insert cn;
        List<IRQAO_Status_Code__c> st = new List<IRQAO_Status_Code__c>{new IRQAO_Status_Code__c(Name='In-Progress',Status_Id__c=1),
            														   new IRQAO_Status_Code__c(Name='Enquire',Status_Id__c=2)};
        insert st;
        IRQAO_Certificate_Defaults__c cd = new IRQAO_Certificate_Defaults__c(Name='NewCertificate',CertificateTemplate__c=3,HideCertificateDetails__c=false,
                                                                            HideRegistrantAddress__c=false,Private__c=true,SuppressEmail__c=true,AutoRenew__c=true,
                                                                            ExpiryPeriod__c=13.0,HideName__c=true,HideRegistrantDetails__c=false,ShowInSearchResults__c=true);
        insert cd;
    }
    @IsTest
    public static void testNewCertReg() {
        Account testAccount = [Select Id,Name from Account where Name='Test Account 1' Limit 1];
        Certificate__c c = new Certificate__c(Account__c = testAccount.Id, Status__c='In-Progress',Standard__c='BS 15713 : 2009',Country__c='United Kingdom');
        insert c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        c.Status__c = 'Enquire';
        c.Connect_Reference_ID__c = 'ABC';
        update c;
        Test.stopTest();
        system.assertEquals([Select Id,Status__c from Certificate__c where Id=:c.Id].Status__c, 'Enquire','Status updated');
    }
    @IsTest
    public static void testNewCert() {
        Account testAccount = [Select Id,Name,IRQAO_Registrant_ID__c from Account where Name='Test Account 2' Limit 1];
        Certificate__c c = new Certificate__c(Account__c = testAccount.Id, Status__c='Enquire',Standard__c='BS 15713 : 2009',Country__c='United Kingdom');
        insert c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        c.Notes__c = 'Test Notes';
        update c;
        Test.stopTest();
        system.assertEquals([Select Id,Notes__c from Certificate__c where Id=:c.Id].Notes__c, 'Test Notes','Notes updated');
    }
    @IsTest
    public static void testExistingReg() {
        Account testAccount = [Select Id,Name,IRQAO_Registrant_ID__c from Account where Name='Test Account 2' Limit 1];
        Certificate__c c = new Certificate__c(Account__c = testAccount.Id, Status__c='Enquire',Standard__c='BS 15713 : 2009',Country__c='United Kingdom',Certificate_ID__c = 13596);
        insert c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        c.Notes__c = 'Test Notes';
        c.Address1__c = 'Test Addr1';
        c.Address2__c = 'Test Addr2';
        c.Address3__c = 'Test Addr3';
        update c;
        Test.stopTest();
        system.assertEquals([Select Id,Notes__c from Certificate__c where Id=:c.Id].Notes__c, 'Test Notes','Notes updated');
    }
     @IsTest
    public static void testExistingCert() {
        Account testAccount = [Select Id,Name,IRQAO_Registrant_ID__c from Account where Name='Test Account 2' Limit 1];
        Certificate__c c = new Certificate__c(Account__c = testAccount.Id, Status__c='Enquire',Standard__c='BS 15713 : 2009',Country__c='United Kingdom',Certificate_ID__c = 13597);
        insert c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new JitterbitServer());
        c.Scope__c = 'Test Scope';
        c.Town__c = 'Abc';
        c.Postcode__c = '1234';
        c.Region__c = '12345';
        update c;
        Test.stopTest();
        system.assertEquals([Select Id,Scope__c from Certificate__c where Id=:c.Id].Scope__c, 'Test Scope','Scope updated');
    }
    
    @IsTest
    public static void testIncorrectStatus() {
        Account testAccount = [Select Id,Name,IRQAO_Registrant_ID__c from Account where Name='Test Account 2' Limit 1];
        Certificate__c c = new Certificate__c(Account__c = testAccount.Id, Status__c='Enquire',Standard__c='BS 15713 : 2009',Country__c='United Kingdom',Certificate_ID__c = 13597);
        insert c;
        Test.startTest();
        c.Status__c = 'Pending';
        update c;
        Test.stopTest();
        system.assertEquals([Select Id,Error_Msg__c  from Certificate__c where Id=:c.Id].Error_Msg__c , 'Status not listed in IRQAO','Error msg updated');
    }
     @IsTest
    public static void testIncorrectCountry() {
        Account testAccount = [Select Id,Name,IRQAO_Registrant_ID__c from Account where Name='Test Account 2' Limit 1];
        Certificate__c c = new Certificate__c(Account__c = testAccount.Id, Status__c='Enquire',Standard__c='BS 15713 : 2009',Country__c='United Kingdom',Certificate_ID__c = 13597);
        insert c;
        Test.startTest();
        c.Country__c = 'Afghanistan';
        update c;
        Test.stopTest();
        system.assertEquals([Select Id,Error_Msg__c  from Certificate__c where Id=:c.Id].Error_Msg__c , 'Country not listed in IRQAO','Error msg updated');
    }
}