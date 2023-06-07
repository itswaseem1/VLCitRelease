//Testclass
@isTest
public class ihasco_Pilot_FullSuite_Test {
    
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default IHASCO';
    public static final Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    public static final Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    
    @testSetup
    static void setUp() {
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ihasco_Pilot_FullSuite_Test';
        iHASCOuser.isActive = True;
        
        insert iHASCOUser;
        
        system.runAs(iHASCOUser){
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
            quote.License_Model__c = 'Open License';
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
            Test.startTest();
            insert con;
            insert ord;
            oItem.OrderId = ord.id;
            insert oItem;
            Test.stopTest();
        }
        
    }
    
    @isTest static void myUnitTest()
    {
        id profileid1=[select id from Profile where name='System Administrator'].id;          
        User iHASCOUser1 =[select id from USER where Division='iHASCO' and isactive = true and LastName = 'ihasco_Pilot_FullSuite_Test' LIMIT 1];
        
        
        system.runAs(iHASCOUser1){
            Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
            
            pricebook.Term__c = '3';
            insert pricebook;
            id pbid = pricebook.id;
            list<pricebook2>   lsp = [select id,name from pricebook2];
            Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
            Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);
            Test.startTest();
            SBQQ__Quote__c testQuote = [Select id from SBQQ__Quote__c limit 1];
            SBQQ__QuoteTemplate__c testTemplate = createTemplate();
            Test.stopTest();
            //Initialise page variables
            PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
            Test.setCurrentPage(CPQGeneratePage);
            
            ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
            ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
            
            
            //Load controller
            ihasco_Pilot_FullSuite_Order testController = new ihasco_Pilot_FullSuite_Order();
            
            list<account> tst = testcontroller.getBlank() ;
        }
    }
    
    /*
*   Helper methods for creating data for tests
*       Account
*       Opportunity
*       Quote
*/
    private static Account createAccount(String accName, String sector, Decimal fullTimeEmployees, Decimal partTimeEmployees)
    {
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
        
        insert acc;
        return acc;     
    }
    
    private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc,id pid)
    {
        id cpid = pid;
        bg_RecordTypeMap opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');         
        Opportunity o = new Opportunity();
        o.Name = opportunityName;
        if (recordtype == 'Default Citation Opportunity') {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Default Citation Opportunity'); 
        } else {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('QMS');
        } 
        o.AccountId = acc.id;
        o.Type = 'New Business';
        o.CloseDate = system.now().addMonths(1).date();
        o.Deal_Type__c = 'Combined';
        o.StageName = 'Provisional Approval';
        o.Term__c = '3';
        o.pricebook2id = cpid;
        insert(o);
        return o;
    }
    
    private static SBQQ__Quote__c createQuote(String qName)
    {
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        User salesRep = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Citation Data Admin'].Id,
            LastName = 'last',
            Email = 'tuser000@citation.co.uk',
            Username = 'tuser000@citation.co.uk' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Europe/London',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_GB'
        );
        
        
        insert salesRep;
        
        q.SBQQ__SalesRep__c = salesRep.Id;       
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        product2 prod = [select id from product2 where  sbqq__billingfrequency__C = 'Annual' limit 1] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(initial_payment__c=10,Ihasco_Term__c='2',sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;
        
        SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(initial_payment__c=10,Ihasco_Term__c='2',sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
        insert ql2 ;
        
        return q;            
        
    }
    
    private static SBQQ__Quote__c createQuote2(String qName)
    {
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        User salesRep = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Citation Data Admin'].Id,
            LastName = 'last',
            Email = 'tuser000@citation.co.uk',
            Username = 'tuser000@citation.co.uk' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Europe/London',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_GB'
        );
        
        
        insert salesRep;
        
        q.SBQQ__SalesRep__c = salesRep.Id;       
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg1.Name = 'Option 2';
        insert qg1;
        
        product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        product2 prod2 = [select id from product2 where sbqq__billingfrequency__C ='One-Off'  limit 1] ;
        //product2 prod3 = [select id from product2 where name =:Bg_Constants.PRODUCT_COMBINED_SERVICE and sbqq__billingfrequency__C = 'Monthly' ] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(initial_payment__c=10,Ihasco_Term__c='2',sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,Billing_Frequency__c = 'Monthly',SBQQ__NetPrice__c=10 ) ;
        insert ql ;
        
        SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(initial_payment__c=10,Ihasco_Term__c='2',sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod2.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        insert ql2 ;
        
        //SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = prod3.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        //insert ql3 ;        
        
        
        return q;            
        
    }
    
    private static SBQQ__Quote__c createQuote3(String qName)
    {
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        User salesRep = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Citation Data Admin'].Id,
            LastName = 'last',
            Email = 'tuser000@citation.co.uk',
            Username = 'tuser000@citation.co.uk' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Europe/London',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_GB'
        );
        
        
        insert salesRep;
        
        q.SBQQ__SalesRep__c = salesRep.Id;       
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg1.Name = 'Option 2';
        insert qg1;
        
        //product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        product2 prod2 = [select id from product2 where name ='CNCQMSTest' ] ;
        product2 prod3 = [select id from product2 where sbqq__billingfrequency__C = 'Annual' limit 1 ] ;
        
        //SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,Billing_Frequency__c = 'Monthly',SBQQ__NetPrice__c=10 ) ;
        //        insert ql ;
        
        //SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod2.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        //insert ql2 ;
        
        SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(Ihasco_Term__c='2',sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = prod3.id,SBQQ__Quantity__c = 1.0 ,initial_payment__c=10, SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        insert ql3 ;        
        
        
        return q;            
        
    }
    
    private static SBQQ__QuoteTemplate__c createTemplate()
    {
        SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
        
        insert t;
        return t;    
        
    }
}