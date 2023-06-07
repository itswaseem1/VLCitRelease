@isTest
global class ihascoContractHandlerCreditBasedTest{
    
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default IHASCO';
    public static final Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    public static final Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    public  static Account acc;
    public  static Opportunity opp;
    public  static Pricebook2 pb;
    public  static SBQQ__Quote__c quote;
    public  static Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    public  static Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    public  static Contact c;
    public  static Product2 p2;
    public  static Product2 p;
    
    @testsetup static void setUp(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ihascoContractHandlerCreditBasedTest';
        insert iHASCOUser;
        //User iHASCOUser =[select id from USER where Division='iHASCO' and isactive = true LIMIT 1];
        system.runAs(iHASCOUser) {
            
            List<Product2> prd = new List<Product2>();
            Product2 p = new Product2();
            p.Name = '10 Course Access Key';
            p.ProductCode = 'AccessKEY10';
            p.IsActive = True;
            p.SBQQ__SubscriptionType__c = 'Renewable';
            p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            P.SBQQ__BillingFrequency__c ='Annual';
            prd.add(p);
            
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'iHASCO';
            pb.IsActive = True;
            insert pb;
            
            Product2 p2 = new Product2();
            p2.Name = 'Credit based Pricing';
            p2.ProductCode = 'HUBP';
            p2.IsActive = True;
            p2.SBQQ__SubscriptionType__c = 'Renewable';
            p2.SBQQ__BillingFrequency__c ='Annual';
            prd.add(p2);
            
            Product2 p3 = new Product2();
            p3.Name = 'Restricted Pricing Model';
            p3.ProductCode = 'IHRPM';
            p3.IsActive = True;
            p3.SBQQ__SubscriptionType__c = 'Renewable';
            p3.SBQQ__BillingFrequency__c ='Annual';
            prd.add(p3);
            
            Product2 p4 = new Product2();   
            p4.Name = 'Restricted Pricing Model sub';   
            p4.ProductCode = 'IHRPM';   
            p4.IsActive = True; 
            p4.SBQQ__SubscriptionType__c = 'Renewable'; 
            p4.SBQQ__BillingFrequency__c ='Annual'; 
            prd.add(p4);
            
            insert prd;
            
            List<PricebookEntry> entries = new List<PricebookEntry>();
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p2.Id, 1000.0, 0.0, 0.0));
            insert entries; 
            
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
            opp.Pricebook2Id = pb.id;
            opp.Type = 'New Business';
            insert opp;
            
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
            quote.SBQQ__PriceBook__c = pb.Id;
            quote.Initial_Payment_Date__c = Date.today();
            quote.SBQQ__SubscriptionTerm__c = 24;
            quote.License_Model__c = 'User Based';
            quote.PO_reference__c = '1234';
            insert quote;
            
            list<SBQQ__QuoteLineGroup__c> Grouplist=new list<SBQQ__QuoteLineGroup__c>();
            SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id);    
            qg.Name = 'Option 1';
            Grouplist.add(qg);
            
            SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id);   
            qg1.Name = 'Option 1';  
            Grouplist.add(qg1);
            
            SBQQ__QuoteLineGroup__c qg2 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id);   
            qg2.Name = 'Option 1';  
            Grouplist.add(qg2);
            insert Grouplist;
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = p2.Id;
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
            ql.Ihasco_Term__c='4';
            ql.SBQQ__CustomerPrice__c=2200;
            ql.sbqq__group__c = qg.id; 
            
            Test.startTest();
            insert ql;
            
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Product__c = p.Id;
            ql1.SBQQ__Quantity__c = 1;
            ql1.Custom_Discount_Percentage__c = 10;
            ql1.SBQQ__Quote__c = quote.Id;
            ql1.SBQQ__StartDate__c = Date.today();
            ql1.SBQQ__EndDate__c = Date.today().addYears(5);
            ql1.Service_Start_Date__c = Date.today();
            ql1.SBQQ__RequiredBy__c = ql.id;
            ql1.Ihasco_Number_of_Credits__c = 50;
            ql1.Billing_Frequency__c = 'Annual';
            ql1.SBQQ__BillingFrequency__c = 'Annual';
            ql1.SBQQ__NetPrice__c = 600;
            ql1.SBQQ__SubscriptionTerm__c = 60;
            ql1.SBQQ__PricebookEntryId__c = pb.id;
            ql1.FOC_Period__c = 'Start';
            ql1.Custom_Discount_Amount__c = 150;
            ql1.SBQQ__CustomerPrice__c=200;
            ql1.Ihasco_Term__c='2'; 
            ql1.sbqq__group__c = qg.id;
            
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            ql2.SBQQ__Product__c = p3.Id;
            ql2.SBQQ__Quantity__c = 1;
            ql2.Custom_Discount_Percentage__c = 10;
            ql2.SBQQ__Quote__c = quote.Id;
            ql2.SBQQ__StartDate__c = Date.today();
            ql2.SBQQ__EndDate__c = Date.today().addYears(5);
            ql2.Service_Start_Date__c = Date.today();
            ql2.SBQQ__RequiredBy__c = ql.id;
            ql2.Ihasco_Number_of_Credits__c = 50;
            ql2.Billing_Frequency__c = 'One-Off';
            ql2.SBQQ__BillingFrequency__c = 'Annual';
            ql2.SBQQ__NetPrice__c = 600;
            ql2.SBQQ__SubscriptionTerm__c = 60;
            ql2.SBQQ__PricebookEntryId__c = pb.id;
            ql2.FOC_Period__c = 'Start';
            ql2.Custom_Discount_Amount__c = 150;
            ql2.Ihasco_Term__c='5';
            ql2.SBQQ__CustomerPrice__c=2200;
            ql2.sbqq__group__c = qg1.id; 
            
            SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();  
            ql3.SBQQ__Product__c = p4.Id;   
            ql3.SBQQ__Quantity__c = 1;  
            ql3.Custom_Discount_Percentage__c = 10; 
            ql3.SBQQ__Quote__c = quote.Id;  
            ql3.SBQQ__StartDate__c = Date.today();  
            ql3.SBQQ__EndDate__c = Date.today().addYears(5);    
            ql3.Service_Start_Date__c = Date.today();   
            ql3.Ihasco_Number_of_Credits__c = 50;   
            ql3.Billing_Frequency__c = 'One-Off';   
            ql3.SBQQ__BillingFrequency__c = 'Annual';   
            ql3.SBQQ__NetPrice__c = 600;    
            ql3.SBQQ__SubscriptionTerm__c = 60; 
            ql3.SBQQ__PricebookEntryId__c = pb.id;  
            ql3.FOC_Period__c = 'Start';    
            ql3.Custom_Discount_Amount__c = 150;    
            ql3.Ihasco_Term__c='5'; 
            ql3.SBQQ__CustomerPrice__c=2200;    
            ql3.sbqq__group__c = qg2.id;
            
            quoteLines.add(ql1);
            quoteLines.add(ql2);
            quoteLines.add(ql3);    
            insert quoteLines;
            
            test.stopTest(); 
            
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.OpportunityId = opp.id;
            ocr.ContactId = c.id;
            ocr.IsPrimary = true;
            ocr.Role = 'Decision Maker';
            insert ocr;
            
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
            
            
        }
        
    }
    @isTest static void testContract() {
        Test.startTest();
        User iHASCOUser =[select id from USER where Division='iHASCO' and LastName = 'ihascoContractHandlerCreditBasedTest' LIMIT 1];
        system.runAs(iHASCOUser){
            SBQQ__Quote__c   quotei = [select id,SBQQ__Account__c, SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c from SBQQ__Quote__C limit 1];
            Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today();
            con.ContractTerm = 24;
            //con.Contract_Term_Years__c = 2 ;
            con.SBQQ__Quote__c = quotei.Id;
            con.AccountId = quotei.SBQQ__Account__c;
            con.Source_Opportunity__c = quotei.SBQQ__Opportunity2__c;
            con.SBQQ__Opportunity__c =quotei.SBQQ__Opportunity2__c;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.CustomerSignedId = quotei.SBQQ__PrimaryContact__c;
            con.Total_Contract_Value__c = 1000;
            insert con;
            id  prd = [select id from product2 where name ='Credit based Pricing' limit 1].id;
            id  prd2 = [select id from product2 where name ='10 Course Access Key' limit 1].id;
            list<SBQQ__Subscription__c>    subList = new list<SBQQ__Subscription__c>();
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
            sb.SBQQ__Contract__c = con.id;
            sb.SBQQ__Product__c = prd;
            sb.SBQQ__Quantity__c = 1;
            sb.SBQQ__ListPrice__c = 2000; 
            subList.add(sb);
            SBQQ__Subscription__c sb1 = new SBQQ__Subscription__c();
            sb1.SBQQ__Contract__c = con.id;
            sb1.SBQQ__Product__c = prd2;
            sb1.SBQQ__Quantity__c = 1;
            sb1.SBQQ__ListPrice__c = 2000;
            subList.add(sb1);
            insert subList; 
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType ];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
            System.assertEquals([select id,recordTypeId from contract ].recordTypeId,contractRecordType);
            
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            agreement.Name = 'TEst';
            Contract contr=[Select id,recordTypeID,SBQQ__Opportunity__r.ACCountId,Status,SBQQ__Quote__r.Quotelines_Max_Term__c,SBQQ__Quote__r.License_Model__c from Contract limit 1];
            agreement.echosign_dev1__Account__c = contr.SBQQ__Opportunity__r.AccountId;
            agreement.echosign_dev1__Contract__c = contr.id;
            
            insert agreement;
        }
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
    
    //Below test method is to cover iHASCOQuoteTemplateController(to print values in VF page) apex class as part of SPB-
    @isTest static void testiHascoQuoteTemplate()
    {
        Test.startTest();
        User iHASCOUser =[select id from USER where Division='iHASCO' and LastName = 'ihascoContractHandlerCreditBasedTest' LIMIT 1];
        system.runAs(iHASCOUser){
            SBQQ__Quote__c   quote = [select id,SBQQ__Account__c, SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c from SBQQ__Quote__C limit 1];
            list<SBQQ__QuoteLine__c> quotelines=[select id,name,SBQQ__Product__r.ProductCode,Billing_Frequency__c,SBQQ__RequiredBy__c,SBQQ__CustomerPrice__c,Ihasco_Term__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quote.id];
            Account account=[SELECT Id, Name from account limit 1];
            Opportunity opportunity=[Select id,name,AccountId from Opportunity limit 1];
            SBQQ__QuoteTemplate__c testTemplate = createTemplate();
            system.debug('cpu time='+limits.getCpuTime());
            system.debug('Query='+limits.getQueries());
            //Initialise page variables
            PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
            Test.setCurrentPage(CPQGeneratePage);
            
            ApexPages.currentPage().getParameters().put('qid', quote.Id);
            ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
            
            
            //Load controller
            iHASCOQuoteTemplateController testController = new iHASCOQuoteTemplateController();
            
            list<account> tst = testcontroller.getBlank() ;
            
            Test.stopTest();
            
            System.assertEquals('One-Off', quotelines[2].Billing_Frequency__c);
            system.assertEquals('Annual', quotelines[1].Billing_Frequency__c);
            system.assertNotEquals(null, quotelines[0].Ihasco_Term__c);
            system.assertEquals('IHRPM', quotelines[2].SBQQ__Product__r.ProductCode);
            
        }
    }
    
    private static SBQQ__QuoteTemplate__c createTemplate()
    {
        SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
        
        insert t;
        return t;    
        
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
            res.setBody('[{"response":{"status":ok}}]');
            res.setStatusCode(404);
            return res;
        }  
    }   
    
    @isTest   public static void ihascoSendEmailContractAmendActivationCreditBasedProd(){   
        User U=[Select id,name from User where Division='iHASCO' and LastName = 'ihascoContractHandlerCreditBasedTest' limit 1];
        system.runAs(U){
            SBQQ__Quote__c quotee=[select id,name from SBQQ__Quote__c limit 1 ];    
            Account acc=[select id from account limit 1];  
            opportunity opp=[select id from opportunity limit 1];   
            
            Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();   
            
            Contract con = new Contract();  
            con.Name = 'Test contract'; 
            con.RecordTypeId = contractRecordType;  
            con.StartDate =  Date.today();  
            con.ContractTerm = 24;  
            con.SBQQ__Quote__c = quotee.Id; 
            con.AccountId =acc.Id;  
            con.Source_Opportunity__c = opp.id; 
            con.SBQQ__Opportunity__c =opp.id;   
            con.Status = 'Draft';   
            con.Renewal_Type__c = 'Non-Auto';   
            con.Initial_Payment2__c = 200;  
            con.Agreement_Type__c = 'Auto'; 
            con.Annual_Contract_Value__c = 1000;    
            
            test.startTest();   
            
            insert con; 
            
            id  prd = [select id from product2 where name ='Credit based Pricing' limit 1].id;  
            id  prd2 = [select id from product2 where name ='10 Course Access Key' limit 1].id; 
            list<SBQQ__QuoteLine__c> Quotelines=[select id from SBQQ__QuoteLine__c];    
            
            list<SBQQ__Subscription__c>    subList = new list<SBQQ__Subscription__c>(); 
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c(); 
            sb.SBQQ__Contract__c = con.id;  
            sb.SBQQ__QuoteLine__c=Quotelines[0].id; 
            sb.SBQQ__Product__c = prd;  
            sb.SBQQ__Quantity__c = 1;   
            sb.SBQQ__ListPrice__c = 2000;   
            sb.SBQQ__CustomerPrice__c=4000; 
            subList.add(sb);    
            
            SBQQ__Subscription__c sb1 = new SBQQ__Subscription__c();    
            sb1.SBQQ__Contract__c = con.id; 
            sb1.SBQQ__QuoteLine__c=Quotelines[1].id;    
            sb1.SBQQ__Product__c = prd2;    
            sb1.SBQQ__Quantity__c = 1;  
            sb1.SBQQ__ListPrice__c = 2000;  
            sb1.SBQQ__CustomerPrice__c=6000;    
            subList.add(sb1);   
            
            SBQQ__Subscription__c sb2 = new SBQQ__Subscription__c();    
            sb2.SBQQ__Contract__c = con.id; 
            sb2.SBQQ__QuoteLine__c=Quotelines[2].id;    
            sb2.SBQQ__Product__c = prd2;    
            sb2.SBQQ__Quantity__c = 1;  
            sb2.SBQQ__ListPrice__c = 2000;  
            sb2.SBQQ__CustomerPrice__c=6000;    
            sb2.SBQQ__RevisedSubscription__c=sb1.id;    
            subList.add(sb2);   
            insert subList;
            
            con.status = 'Active';
            update con;
            
            con.status = 'In Amendment';
            update con;
            
            SBQQ__Subscription__c sb3 = new SBQQ__Subscription__c();
            sb3.SBQQ__Contract__c = con.id;
            sb3.SBQQ__QuoteLine__c=Quotelines[2].id;
            sb3.SBQQ__Product__c = prd2;
            sb3.SBQQ__Quantity__c = 3;
            sb3.SBQQ__ListPrice__c = 2000;
            sb3.SBQQ__CustomerPrice__c=6000;
            insert sb3;
            
            sb2.SBQQ__Quantity__c=-1;
            update sb2;
            
            con.status = 'Active';
            update con;
            
            Set<id> contracts = new Set<Id>();  
            contracts.add(con.id);  
            Boolean amendmentContract=True;
            ihascoContractHandler.getAmendContractToBuildEmailBody(contracts,amendmentContract);
            //System.assertEquals(3, Limits.getEmailInvocations(), 'Emails should be sent');
            system.assertNOTEquals(null, con.SBQQ__Quote__c);
            system.assertEquals(True,  amendmentContract);
            system.assertEquals(3,  sb3.SBQQ__Quantity__c, 'Amended contract change in quantity');
            system.assertEquals(-1, sb2.SBQQ__Quantity__c);
            system.assertEquals('Active', con.Status );  
            Test.stopTest();
        }
    }
}