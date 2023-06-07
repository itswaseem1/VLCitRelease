@isTest
private class iHASCOQuoteTemplateController_Test {
    
    
    @testSetup static void setup()
    {
        List<Product2> products = new List<Product2>();
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedproduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        Product2 combinedProduct1 = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedproduct1.SBQQ__BillingFrequency__c = 'Annual' ;
        products.add(combinedProduct);
        products.add(combinedProduct1);
        Product2 healthAndSafetyProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, 'Consultation', 'Premium');
        HealthAndSafetyProduct.SBQQ__BillingFrequency__C = 'Annual' ;
        products.add(healthAndSafetyProduct);
        Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
        EmployementLawPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        products.add(employementLawProduct);
        Product2 consultancyProduct = bg_Product_TestUtils.createProduct('Consultancy Day', 'Consultation', 'Premium');
        ConsultancyProduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        products.add(consultancyProduct);
        
        Product2 QMSPRoduct  = bg_Product_TestUtils.createProduct('CNCQMSTest', 'Consultation', 'Premium');
        QMSProduct.Business_Type__c = 'QMS' ;        
        QMSProduct.SBQQ__Hidden__c = True;
        QMSPRoduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        products.add(QMSPRoduct);
        
        insert products;
    }
    
    
    @isTest static void myUnitTest()
    {
        User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
         iHASCOUser.profileid=[select id from Profile where name='Citation Data Admin'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        system.runAs(iHASCOUser){
            Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
            pricebook.Term__c = '3';
            insert pricebook;
            id pbid = pricebook.id;
            list<pricebook2>   lsp = [select id,name from pricebook2];
            Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
            Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);
             Test.startTest();
            SBQQ__Quote__c testQuote = createQuote('TestQuote');
            SBQQ__QuoteTemplate__c testTemplate = createTemplate();
            system.debug('cpu time='+limits.getCpuTime());
            system.debug('Query='+limits.getQueries());
            //Initialise page variables
            PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
            Test.setCurrentPage(CPQGeneratePage);
            
            ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
            ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
            
            
            //Load controller
            iHASCOQuoteTemplateController testController = new iHASCOQuoteTemplateController();
            
            list<account> tst = testcontroller.getBlank() ;
            
            Test.stopTest();
        }
        system.debug('cpu time='+limits.getCpuTime());
        system.debug('cpu time='+limits.getQueries());
    } 
    
    @isTest static void myUnitTest2()
    {
        User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
         iHASCOUser.profileid=[select id from Profile where name='Citation Data Admin'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        system.runAs(iHASCOUser){
            Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
            pricebook.Term__c = '3';
            
            insert pricebook;
            list<pricebook2>   lsp = [select id,name from pricebook2];
            id pbid = pricebook.id;
            
            Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
            Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);
            Test.startTest();
            SBQQ__Quote__c testQuote = createQuote2('TestQuote');
            SBQQ__QuoteTemplate__c testTemplate = createTemplate();
            system.debug('cpu time='+limits.getCpuTime());
            system.debug('query='+limits.getQueries());
            //Initialise page variables
            PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
            Test.setCurrentPage(CPQGeneratePage);
            
            ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
            ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
            
            
            //Load controller
            iHASCOQuoteTemplateController testController = new iHASCOQuoteTemplateController();
            iHASCOQuoteTemplateController test1Controller = new iHASCOQuoteTemplateController();			
            list<account> tst = testcontroller.getBlank() ;
            
            Test.stopTest();
        }
        system.debug('cpu time='+limits.getCpuTime());
        system.debug('query='+limits.getQueries());
    }
    
    @isTest static void myUnitTest3()
    {
       User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
         iHASCOUser.profileid=[select id from Profile where name='Citation Data Admin'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        system.runAs(iHASCOUser){
            Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
            pricebook.Term__c = '3';
            
            insert pricebook;
            list<pricebook2>   lsp = [select id,name from pricebook2];
            id pbid = pricebook.id;
           
            Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
            Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);
             Test.startTest();
            SBQQ__Quote__c testQuote = createQuote3('TestQuote');
            SBQQ__QuoteTemplate__c testTemplate = createTemplate();
            system.debug('cpu time='+limits.getCpuTime());
            system.debug('query='+limits.getQueries());
            //Initialise page variables
            PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
            Test.setCurrentPage(CPQGeneratePage);
            
            ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
            ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
            
            
            //Load controller
            iHASCOQuoteTemplateController testController = new iHASCOQuoteTemplateController();
            
            list<account> tst = testcontroller.getBlank() ;
            
            Test.stopTest();
        }
        system.debug('cpu time='+limits.getCpuTime());
        system.debug('query='+limits.getQueries());
    }
    
    
    /*
*	Helper methods for creating data for tests
*		Account
*		Opportunity
*		Quote
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
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(initial_payment__c=100,Ihasco_Term__c='2',sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;
        
         SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(initial_payment__c=200,Ihasco_Term__c='2',sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
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
        product2 prod2 = [select id from product2 where name ='CNCQMSTest' ] ;
        //product2 prod3 = [select id from product2 where name =:Bg_Constants.PRODUCT_COMBINED_SERVICE and sbqq__billingfrequency__C = 'Monthly' ] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(Ihasco_Term__c='2',sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,Billing_Frequency__c = 'Monthly',SBQQ__NetPrice__c=10 ) ;
        insert ql ;
        
        SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(Ihasco_Term__c='2',sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod2.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
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
        product2 prod3 = [select id from product2 where name =:Bg_Constants.PRODUCT_COMBINED_SERVICE and sbqq__billingfrequency__C = 'Annual' ] ;
        
        //SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,Billing_Frequency__c = 'Monthly',SBQQ__NetPrice__c=10 ) ;
        //        insert ql ;
        
        //SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod2.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        //insert ql2 ;
        
        SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(Ihasco_Term__c='2',sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = prod3.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
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