@isTest
global class StripeCalloutServiceTest {
    
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default iHASCO';
    public static final Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    public static final Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    @testSetup
    static void setUp(){
        
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.isActive = true;
        iHASCOUser.LastName = 'StripeCalloutServiceTest';
        insert iHASCOUser;
        
        System.runAs(iHASCOUser){
            
            Account acc = new Account();
            acc.Name = 'Test Acc';
            acc.BillingStreet = 'Harvey street';
            acc.BillingCity = 'Manchester';
            acc.BillingCountry = 'England';
            acc.BillingPostalCode = 'NXJ001';
            acc.Sites__c = 5.0;
            acc.FT_Employees__c = 20.0;
            acc.PT_Employees__c = 10.0;
            insert acc;
            
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact';
            c.AccountId = acc.Id;
            c.Phone = '01912553955';
            c.MobilePhone = '70875327792';
            c.Email = 'testcontact@email.com';
            insert c;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.id;
            opp.Deposit_Payment_Method__c = 'Direct Debit';
            opp.RecordTypeId = oppRecordType;
            opp.CloseDate = Date.newInstance(2021, 09, 30);
            opp.StageName = 'In Progress';
            insert opp;
            
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.IsActive = True;
            p.SBQQ__SubscriptionType__c = 'Renewable';
            P.SBQQ__BillingFrequency__c ='Annual';
            insert p;
            
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'iHASCO';
            pb.IsActive = True;
            insert pb;
            
            List<PricebookEntry> entries = new List<PricebookEntry>();
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
            insert entries; 
            
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = quoteRecordType;
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__StartDate__c = Date.today();
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__PrimaryContact__c = c.Id;
            quote.Preferred_Payment_Date__c = '7';
            quote.Initial_Payment__c = 200;
            quote.Initial_Payment_Date__c = Date.today();
            quote.SBQQ__SubscriptionTerm__c = 24;
            quote.License_Model__c = 'User Based';
            insert quote;
            
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = p.Id;
            ql.SBQQ__Quantity__c = 1;
            ql.Custom_Discount_Percentage__c = 10;
            ql.SBQQ__Quote__c = quote.Id;
            ql.SBQQ__StartDate__c = Date.today();
            ql.SBQQ__EndDate__c = Date.today().addYears(5);
            ql.Service_Start_Date__c = Date.today();            
            ql.Billing_Frequency__c = 'Annual';
            ql.SBQQ__BillingFrequency__c = 'Annual';
            ql.SBQQ__NetPrice__c = 600;
            ql.SBQQ__SubscriptionTerm__c = 60;
            ql.FOC_Period__c = 'Start';
            insert ql;
            
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today();
            con.ContractTerm = 24;
            con.AccountId = acc.Id;
            con.Source_Opportunity__c = opp.Id;
            con.SBQQ__Opportunity__c =opp.Id;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.CustomerSignedId = c.id;
            con.Total_Contract_Value__c = 1000;
            con.Annual_Contract_Value__c = 500;   
            con.StripePaymentLinkExpiryDateTime__c = System.Now().addDays(3);
            con.Payment_Status__c = 'Payment Link Sent';
            
            Order ord = new Order();
            ord.AccountId = acc.Id;
            ord.SBQQ__Quote__c = quote.id;
            ord.EffectiveDate = System.today();
            ord.CustomerAuthorizedById = c.id;
            ord.RecordTypeId = orderRecordType;
            ord.status = 'Draft';
            ord.Pricebook2Id = pb.id;
            ord.StripePaymentLinkExpiryDateTime__c = System.Now().addDays(3);
            ord.Payment_Status__c = 'Payment Link Sent';
            
            OrderItem oItem = new OrderItem();
            oItem.Product2Id = p.id;
            oItem.Quantity = 1;
            oItem.UnitPrice = 2000;
            oItem.PricebookEntryId = entries[1].id;
            Test.startTest();
            
            insert con;
            insert ord;
            
            oItem.OrderId = ord.id;
            insert oItem;
            Test.stopTest();
        }        
    }
    
    @isTest static void testStripeLinkSendingContract() {
        
        //Initialise page variables
        List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        if(!conList.isEmpty()){
            
            System.runAs(iHASCOUsr){
                StripeCalloutService.sendEmail(conList[0].id);
            }
        }
        Test.stopTest();
    }
    
    
    @isTest static void testStripeLinkSendingOrder() {
        
        //Initialise page variables
        List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        if(!ordList.isEmpty()){
            System.runAs(iHASCOUsr){
                StripeCalloutService.sendEmail(ordList[0].id);
            }
        }
        Test.stopTest();
    }
    
    @isTest static void testPaymentLinkContract() {
        
        //Initialise page variables
        List<Contract> conList = [SELECT id,StripePaymentLinkExpiryDateTime__c from Contract where recordTypeId = :contractRecordType AND StripePaymentLinkExpiryDateTime__c != NULL];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        if(!conList.isEmpty()){
            System.runAs(iHASCOUsr){
                string parm = String.valueOf(conList[0].Id + '-' + conList[0].StripePaymentLinkExpiryDateTime__c);
                Blob blobData=Blob.valueOf(parm);
                String parmEncode = EncodingUtil.base64Encode(blobData);                      
                ApexPages.currentPage().getParameters().put('contractOrderId', parmEncode);
                StripeCalloutService scs = new StripeCalloutService();
                scs.validateStripePayementDetails();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                StripeCalloutService.createPaymentIntent(String.valueOf(conList[0].Id),'TEST TEST');
            }
        }
        Test.stopTest();
    }
    
    @isTest static void testPaymentLinkOrder() {
        
        //Initialise page variables
        List<Order> ordList = [SELECT id,StripePaymentLinkExpiryDateTime__c from Order where recordTypeId = :orderRecordType  AND StripePaymentLinkExpiryDateTime__c != NULL];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        if(!ordList.isEmpty()){
            System.runAs(iHASCOUsr){
                string parm = String.valueOf(ordList[0].Id + '-' + ordList[0].StripePaymentLinkExpiryDateTime__c);
                Blob blobData=Blob.valueOf(parm);
                String parmEncode = EncodingUtil.base64Encode(blobData);  
                ApexPages.currentPage().getParameters().put('contractOrderId', parmEncode);
                StripeCalloutService scs = new StripeCalloutService();
                scs.validateStripePayementDetails();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                StripeCalloutService.createPaymentIntent(String.valueOf(ordList[0].Id),'TEST TEST');
            }
        }
        Test.stopTest();
    }
    @isTest static void testprocessPaymentConfirmation() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        try{
            System.runAs(iHASCOUsr){
                StripeCalloutService.processPaymentConfirmation('undefined',[select id from contract limit 1].id,false);
            }
        }
        Catch(Exception e){}
        Test.stopTest();
        
    }
    
    @isTest static void testprocessPaymentConfirmationOrder() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        try{
            System.runAs(iHASCOUsr){
                StripeCalloutService.processPaymentConfirmation('undefined',[select id from Order limit 1].id,false);
            }
        }
        Catch(Exception e){}
        Test.stopTest();
        
    }
    
    @isTest static void testStripePaymentPage()
    {
        List<Contract> contr = [SELECT Id FROM Contract where recordTypeid = :contractRecordType LIMIT 1 ];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Organization org = StripeCalloutService.getinstanceInfo();
        StripeAPI__mdt stripeKey = StripeCalloutService.getStripeAPIDetails();
        Datetime expiryDateTime = System.now().AddDays(3);
        String sourceLink = '';
        String param = contr[0].id + '-' + expiryDateTime;
        Blob blobData=Blob.valueOf(String.valueof(param));
        String encodedString = EncodingUtil.base64Encode(blobData);
        if(org != null && org.isSandbox){               
            sourceLink = 'https://';
            sourceLink = sourceLink + 'uat';//UserInfo.getUserName().substringAfterLast('.');
            sourceLink = sourceLink + '-citation.' + org.InstanceName + '.force.com/iHASCO/StripePayment?contractOrderId=' + encodedString; 
        }  else if(org != null) {
            sourceLink = stripeKey.siteAddress__c +  encodedString;
        }      
        PageReference pageRef = Page.StripePayment;  
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('contractOrderId', sourceLink);
        Test.startTest();
        //Load controller
        System.runAs(iHASCOUsr){
            StripeCalloutService testController = new StripeCalloutService();
            testController.validateStripePayementDetails();    
        }
        Test.stopTest();
    }
    
    
    @isTest static void testPayments() {
        
        //Initialise page variables
        List<Order> ordList = [SELECT id,StripePaymentLinkExpiryDateTime__c from Order where recordTypeId = :orderRecordType  AND StripePaymentLinkExpiryDateTime__c != NULL];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [Select id from User where Division = 'iHASCO' AND LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        if(!ordList.isEmpty()){
            System.runAs(iHASCOUsr){
                string parm = String.valueOf(ordList[0].Id + '-' + ordList[0].StripePaymentLinkExpiryDateTime__c);
                Blob blobData=Blob.valueOf(parm);
                String parmEncode = EncodingUtil.base64Encode(blobData);  
                ApexPages.currentPage().getParameters().put('contractOrderId', parmEncode);
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                StripeCalloutService.PaymentIntentWrapper piw = StripeCalloutService.createPaymentIntent(String.valueOf(ordList[0].Id),'Test iHASCO');
                System.assertEquals(piw.amount, 240000);
            }
        }
        Test.stopTest();
    }
    
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            System.debug('mock req: ' + req);
            
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            String endpoint = req.getEndpoint();
            if((endpoint.contains('https://login.microsoftonline.com') 
                && endpoint.contains('token'))){
                    System.debug('-->Entered the setter');
                    res.setHeader('Content-Type', 'application/json; charset=utf-8');
                    res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImpTMVhvMU9XRGpfNTJ2YndHTmd2UU8yVnpNYyIsImtpZCI6ImpTMVhvMU9XRGpfNTJ2YndHTmd2UU8yVnpNYyJ9.eyJhdWQiOiJodHRwczovL3ZhdWx0LmF6dXJlLm5ldCIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzI5NTdiYTc0LWM5NTUtNGI4Ny1iNDk3LTMwMmE1NzA2MzA3OS8iLCJpYXQiOjE2NTUxMjY1MjgsIm5iZiI6MTY1NTEyNjUyOCwiZXhwIjoxNjU1MTMwNDI4LCJhaW8iOiJFMlp"}');
                } else if (endpoint.contains(AzureVault.azureStripeCredAppEndpoint) || endpoint.contains(AzureVault.azureTestStripeCredAppEndpoint) ){
                    String res2 = '{"value":"rk_test_516MEbhLEOOW8UA80M5YXBPaM3afg8VXwWrGtV4MmOiQy5rqKDjJkrZOUdkQwRcLoyoQSyM4cOrX1QZdlkAwheeyx002UgBrFy8","id":"https://salesforce-stripe-azkv.vault.azure.net/secrets/TestRestrictedSecretKey/a362ce3e34e3432e994e4332e01f5936","attributes":{"enabled":true,"created":1654525173,"updated":1654525173,"recoveryLevel":"Recoverable+Purgeable"},"tags":{}}';
                    res.setBody(res2);
                } else if(endpoint.contains('/payment_intents')){
                    StripeCalloutService.PaymentIntentWrapper piw = new StripeCalloutService.PaymentIntentWrapper();
                    List<String> listParam = req.getBody().Split('&');
                    Map<String,String> keyVAlue = new Map<String,String>();
                    For(String param :listParam){     
                        keyVAlue.put(param.subStringBefore('='),param.subStringAfter('='));   
                    }
                    piw.amount = Double.valueof(keyVAlue.get('amount'));
                    piw.status = 'success';
                    res.setBody(json.serialize(piw));
                    res.setStatusCode(200);
                } else {
                    res.setBody('{"StatusCode":"200","Status":"Success"}');
                }
            res.setStatusCode(200);         
            return res;
        }
    }
    
    @isTest static void testgetSandboxName() {
        EnvironmentHelper.getSandboxName();
    }
    
    @isTest static void testStripeLinkSendingAmendContract() {
        
        List<Contract> conList = [SELECT id,status FROM Contract WHERE recordTypeId = :contractRecordType];
        conList[0].status = 'In Amendment';
        conList[0].Annual_Contract_Value__c = 800;
        update conList[0];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
        User iHASCOUsr = [SELECT id FROM User WHERE Division = 'iHASCO' and LastName = 'StripeCalloutServiceTest' LIMIT 1];
        Test.startTest();
        if(!conList.isEmpty())
        {            
            System.runAs(iHASCOUsr){
                StripeCalloutService.sendEmail(conList[0].id);
            }
        }
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(1, invocations,  ' An email should be sent');
        
    }
    
}