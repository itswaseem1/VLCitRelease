@isTest
global class iHASCOTopUpOrderSendMailTest {
    
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default iHASCO';
    public static final Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    public static final Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    
    @testSetup
    static void setUp(){
        
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        
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
        
        Product2 p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'IH-RPM-1000';
        p1.IsActive = True;
        p1.SBQQ__SubscriptionType__c = 'Renewable';
        P1.SBQQ__BillingFrequency__c ='Annual';
        
        Product2 p = new Product2();
        p.Name = 'User based Pricing';
        p.ProductCode = 'IH-RPM-1222';
        p.IsActive = True;
        p.SBQQ__SubscriptionType__c = 'Renewable';
        P.SBQQ__BillingFrequency__c ='Annual';
        insert new list<Product2>{p};
            
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
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Product__c = p1.Id;
        ql1.SBQQ__Quantity__c = 1;
        ql1.Custom_Discount_Percentage__c = 10;
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.SBQQ__StartDate__c = Date.today();
        ql1.SBQQ__EndDate__c = Date.today().addYears(5);
        ql1.Service_Start_Date__c = Date.today();
        
        ql1.Billing_Frequency__c = 'Annual';
        ql1.SBQQ__BillingFrequency__c = 'Annual';
        ql1.SBQQ__NetPrice__c = 600;
        ql1.SBQQ__SubscriptionTerm__c = 60;
        ql1.FOC_Period__c = 'Start';
        Test.startTest();
        insert new list<SBQQ__QuoteLine__c>{ql};
            
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHascoUser.LastName = 'iHASCOTopUpOrderSendMailTest';
        insert iHASCOUser;
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        system.runAs(iHASCOUser)
        {            
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today();
            con.ContractTerm = 24;
            //con.Contract_Term_Years__c = 2 ;
            //con.SBQQ__Quote__c = quote.Id;
            con.AccountId = acc.Id;
            con.Source_Opportunity__c = opp.Id;
            con.SBQQ__Opportunity__c =opp.Id;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.CustomerSignedId = c.id;
            con.Total_Contract_Value__c = 1000;
            
            Order ord = new Order();
            ord.AccountId = acc.Id;
            ord.SBQQ__Quote__c = quote.id;
            ord.EffectiveDate = System.today();
            ord.CustomerAuthorizedById = c.id;
            ord.RecordTypeId = orderRecordType;
            ord.status = 'Draft';
            ord.Pricebook2Id = pb.id;
            
            OrderItem oItem = new OrderItem();
            oItem.Product2Id = p.id;
            oItem.Quantity = 1;
            oItem.UnitPrice = 2000;
            oItem.PricebookEntryId = entries[1].id;
            
            insert con;
            insert ord;
            
            oItem.OrderId = ord.id;
            insert oItem;
            
            Test.stopTest();
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
            sb.SBQQ__Contract__c = con.id;
            sb.SBQQ__Product__c = p.id;
            sb.SBQQ__Quantity__c = 1;
            sb.SBQQ__ListPrice__c = 2000; 
            insert sb;
        }
    }
        
    @isTest static void testOrder() {
        
        //Initialise page variables
        List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        if(!ordList.isEmpty()){
            for(Order c : ordList){
                c.status = 'Activated';
            }
            update ordList;
        }
        Test.stopTest();
    }
    
    @isTest static void testOrderCreditBased() {
        
        //Initialise page variables
        List<product2> pList = new List<product2>();
        For(Product2 p : [select id, productcode from product2]){
            p.ProductCode = 'IHCBP';
            plist.add(p); 
        }
        update pList;
        SBQQ__Quote__C quote=[Select id,PO_reference__c from SBQQ__Quote__C limit 1 ];
        quote.PO_reference__c = UserInfo.getUserId();
        update quote;
        List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        if(!ordList.isEmpty()){
            for(Order c : ordList){
                c.status = 'Activated';
            }
            update ordList;
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
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"response":{"status":ok}}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            System.debug('mock req: ' + req);
            
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"response":{"status":Not ok}}]');
            res.setStatusCode(404);
            return res;
        }
    }
    
    @isTest static void testOrder2(){
        List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
        SBQQ__Quote__C quote=[Select id,PO_reference__c from SBQQ__Quote__C limit 1 ];
        quote.PO_reference__c = [Select id from Contact Limit 1].id;
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        if(!ordList.isEmpty()){
            for(Order c : ordList){
                c.status = 'Activated';
            }
            update quote;
            update ordList;
        }
        Test.stopTest();
    }
}