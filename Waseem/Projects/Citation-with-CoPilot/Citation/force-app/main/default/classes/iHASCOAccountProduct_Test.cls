@IsTest
public class iHASCOAccountProduct_Test {
    @IsTest
    public static void activeProdcuts(){
        
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
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
        //quote.SBQQ__PriceBook__c = pb.Id;
        quote.Initial_Payment_Date__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 24;
        //quote.Quotelines_Max_Term__c = 24;
        insert quote;
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.IsActive = True;
        insert p;
        
        List<Pricebook2> pbs = new list<Pricebook2>();
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Test book';
        pb.IsActive = True;
        pbs.add(pb);
        
        Pricebook2 std = new Pricebook2();
        std.Id = Test.getStandardPricebookId();
        std.IsActive = True;
        pbs.add(std);
        insert pb;
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
        insert entries; 

        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>();
        groups = TestDataFactory.getQuoteLine(quote.Id);
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Product__c = p.Id;
        ql.SBQQ__Quantity__c = 1;
        ql.Custom_Discount_Percentage__c = 10;
        ql.SBQQ__Quote__c = quote.Id;
        ql.SBQQ__StartDate__c = Date.newInstance(2021, 10, 01);
        ql.Service_Start_Date__c = Date.today();
        ql.SBQQ__EndDate__c = Date.newInstance(2022, 12, 31);
        ql.Billing_Frequency__c = 'Annual';
        ql.SBQQ__BillingFrequency__c = 'Monthly';
        ql.SBQQ__NetPrice__c = 600;
        ql.SBQQ__SubscriptionTerm__c = 60;
        ql.FOC_Period__c = 'Start';
        insert ql;

        Contract con = new Contract();
        con.Name = 'Test contract';
        con.StartDate = Date.newInstance(2021, 10, 1);
        con.ContractTerm = 12;
        con.AccountId = acc.Id;
        con.Source_Opportunity__c = opp.Id;
        con.Status = 'Draft';
        con.Renewal_Type__c = 'Non-Auto';
        con.Initial_Payment2__c = 200;
        Con.CustomerSignedId = c.id;
        con.FOC_Period_Mths__c =1 ;
        con.FOC_Period_Mths_End__c = 3;
 
        Test.startTest();
 
        insert con;
        SBQQ__Subscription__c subs1 = new SBQQ__Subscription__c(SBQQ__Contract__c=con.id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='Monthly',Subscription_Term_m__c=12) ;
        insert subs1;
        
        iHASCOAccountProducts.getSubscriptions(con.AccountId);
        Test.stopTest();
        
    }
     @IsTest
    public static void activeOrders(){
        
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
        insert quote;
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.IsActive = True;
        insert p;
        
        List<Pricebook2> pbs = new list<Pricebook2>();
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Test book';
        pb.IsActive = True;
        pbs.add(pb);
        
        Pricebook2 std = new Pricebook2();
        std.Id = Test.getStandardPricebookId();
        std.IsActive = True;
        pbs.add(std);
        insert pb;
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
        insert entries; 

        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>();
        groups = TestDataFactory.getQuoteLine(quote.Id);
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Product__c = p.Id;
        ql.SBQQ__Quantity__c = 1;
        ql.Custom_Discount_Percentage__c = 10;
        ql.SBQQ__Quote__c = quote.Id;
        ql.SBQQ__StartDate__c = Date.newInstance(2021, 10, 01);
        ql.Service_Start_Date__c = Date.today();
        ql.SBQQ__EndDate__c = Date.newInstance(2022, 12, 31);
        ql.Billing_Frequency__c = 'Annual';
        ql.SBQQ__BillingFrequency__c = 'Monthly';
        ql.SBQQ__NetPrice__c = 600;
        ql.SBQQ__SubscriptionTerm__c = 60;
        ql.FOC_Period__c = 'Start';
        
        Order con = new Order();
        con.Name = 'Test contract';
        con.EffectiveDate = Date.newInstance(2021, 10, 1);
        con.AccountId = acc.Id;
        con.OpportunityId = opp.Id;
        con.Status = 'Draft';
        con.Pricebook2Id = pb.id;
    
        OrderItem oItem = new OrderItem();
        oItem.Product2Id = p.id;
        oItem.Quantity = 1;
        oItem.UnitPrice = 2000;
        oItem.PricebookEntryId = entries[1].id;
        oItem.ServiceDate = System.today();
        oItem.EndDate = System.today().addyears(1);
       
        Test.startTest();
        insert con;
        
        oItem.OrderId = con.id;
        insert oItem;
        
        iHASCOAccountProducts.getOrderDetails(con.AccountId);
        Test.stopTest();
    }
}