@isTest
global class iHASCOResendLMSFailedPayloadsTest {
    
    //Test Class for iHASCOResendLMSFailedPayloads
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default IHASCO';
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
        acc.iHASCO_Finance_Status__c = 'Active';
        acc.SBQQ__RenewalModel__c = 'Contract Based';
        insert acc;
        
        Site__c acs = new Site__c();
        acs.Account__c = acc.id;
        acs.City__c = 'test';
        acs.Name = 'test';
        insert acs;
        
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
        p.ProductCode = 'IH-RPM-1000';
        p.IsActive = True;
        p.SBQQ__SubscriptionType__c = 'Renewable';
        p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
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
        quote.Payment_Method__c = 'Invoice';
        quote.iHASCO_Payment_Terms__c = '30 Days';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__PrimaryContact__c = c.id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = c.Id;
        quote.Preferred_Payment_Date__c = '7';
        quote.Initial_Payment__c = 200;
        //quote.SBQQ__PriceBook__c = pb.Id;
        quote.Initial_Payment_Date__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 24;
        quote.License_Model__c = 'Restricted License';
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
        Test.startTest();
        insert ql;

        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'iHASCOResendLMSFailedPayloadsTest';
        insert iHASCOUser;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.id;
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        system.runAs(iHASCOUser){
            
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today();
            con.ContractTerm = 24;
            //con.Contract_Term_Years__c = 2 ;
            con.SBQQ__Quote__c = quote.Id;
            con.AccountId = acc.Id;
            con.Source_Opportunity__c = opp.Id;
            con.SBQQ__Opportunity__c =opp.Id;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.CustomerSignedId = c.id;
            con.Total_Contract_Value__c = 1000;
            insert con;
            
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
    
    @isTest
    public static void testFailedpayloadBatch(){
        List<Contract> records = [SELECT id,License_Model__c,ContractNumber,StartDate,EndDate,
                                  SBQQ__Opportunity__c,AccountId,Account.Name,Account.LMS_ID__c,SBQQ__Quote__r.SBQQ__PrimaryContact__c,
                                  SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName,
                                  SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone,
                                  Owner.FirstName,Owner.LastName,Owner.Email,Owner.Phone,Account.ParentId,Account.Parent.LMS_ID__c,
                                  (SELECT Id,CreatedDate,SBQQ__Quantity__c,Name,SBQQ__Contract__c,SBQQ__ContractNumber__c,
                                   SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__ProductName__c,ProductCode__c,
                                   ParentProductCode__c,Service_Start_Date__c,Service_End_Date__c,SBQQ__RequiredById__c,Purchase_Data_Time__c,
                                   Ihasco_Number_of_Credits__c,iHasco_Number_of_Users__c,SBQQ__RevisedSubscription__c,SBQQ__Contract__r.ActivatedDate
                                   FROM sbqq__Subscriptions__r)
                                  FROM Contract where recordTypeId = :contractRecordType LIMIT 1];
        List<site__c> sites = new List<site__c>();
        For(Site__c site: [SELECT id,name,city__c, street__c,Active__c from Site__c where Account__c = :records[0].AccountId]){
            sites.add(site);
        }
        iHASCOLmsWrapper wrap = new iHASCOLmsWrapper(records[0] , sites, SYSTEM.Label.iHASCOEventContractActivated);
        String JSONString = (JSON.serializePretty(wrap));
        
        ApplicationLog__c apl = new ApplicationLog__c();
        apl.Name = 'Test';
        apl.Retry__c = true;
        apl.Message__c = JSONString;
        apl.Response__c = 'Failed';
        apl.RecordId__c = records[0].id;
        insert apl;
        
        String CRON_EXP = '0 0 0 3 9 ? 2099';
        String jobID = '';
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        iHASCOResendLMSFailedPayloads schjob = new iHASCOResendLMSFailedPayloads();
        jobID = System.schedule('LMS Failed payload Job', CRON_EXP, schjob);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(CRON_EXP,ct.CronExpression);
        
        
    }
    
    @isTest
    public static void testFailedpayloadBatchResend(){
        List<Contract> records = [SELECT id,License_Model__c,ContractNumber,StartDate,EndDate,
                                  SBQQ__Opportunity__c,AccountId,Account.Name,Account.LMS_ID__c,SBQQ__Quote__r.SBQQ__PrimaryContact__c,
                                  SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName,
                                  SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone,
                                  Owner.FirstName,Owner.LastName,Owner.Email,Owner.Phone,Account.ParentId,Account.Parent.LMS_ID__c,
                                  (SELECT Id,CreatedDate,SBQQ__Quantity__c,Name,SBQQ__Contract__c,SBQQ__ContractNumber__c,
                                   SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__ProductName__c,ProductCode__c,
                                   ParentProductCode__c,Service_Start_Date__c,Service_End_Date__c,SBQQ__RequiredById__c,Purchase_Data_Time__c,
                                   Ihasco_Number_of_Credits__c,iHasco_Number_of_Users__c,SBQQ__RevisedSubscription__c,SBQQ__Contract__r.ActivatedDate
                                   FROM sbqq__Subscriptions__r)
                                  FROM Contract where recordTypeId = :contractRecordType LIMIT 1];
        List<site__c> sites = new List<site__c>();
        For(Site__c site: [SELECT id,name,city__c, street__c,Active__c from Site__c where Account__c = :records[0].AccountId]){
            sites.add(site);
        }
        iHASCOLmsWrapper wrap = new iHASCOLmsWrapper(records[0] , sites, SYSTEM.Label.iHASCOEventContractActivated);
        String JSONString = (JSON.serializePretty(wrap));
        
        ApplicationLog__c apl = new ApplicationLog__c();
        apl.Name = 'Test';
        apl.Retry__c = true;
        apl.Message__c = JSONString;
        apl.Response__c = 'Failed';
        apl.RecordId__c = records[0].id;
        insert apl;
        
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        iHASCOResendLMSFailedPayloads iHASCOpayloadbatch = new iHASCOResendLMSFailedPayloads();
        Database.executeBatch(iHASCOpayloadbatch, 1);
        Test.stopTest();
        List<ApplicationLog__c> logList = [select id from ApplicationLog__c where Retry__c = true]; 
        System.assertEquals(0,logList.size());
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
    
    
}