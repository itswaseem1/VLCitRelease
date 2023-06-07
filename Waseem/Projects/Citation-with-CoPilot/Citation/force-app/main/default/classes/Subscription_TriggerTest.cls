@isTest
private class Subscription_TriggerTest{
    
     @testSetup static void setup()
    {
         Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
        
        List<Product2> products = new List<Product2>();
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedproduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        products.add(combinedProduct);
        Product2 healthAndSafetyProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, 'Consultation', 'Premium');
        HealthAndSafetyProduct.SBQQ__BillingFrequency__C = 'Annual' ;
        products.add(healthAndSafetyProduct);
        Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
        EmployementLawPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        products.add(employementLawProduct);
        Product2 consultancyProduct = bg_Product_TestUtils.createProduct('Consultancy Day', 'Consultation', 'Premium');
        ConsultancyProduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        products.add(consultancyProduct);

        insert products;
        
    }
    
    
       static testMethod void Test1_AfterInsert() {
         Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        contract c = new contract(accountid=testaccount.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0,Agreement_Type__c ='Auto') ;
        insert c ;
        
        
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
        
        product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        
        Test.starttest();
           
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;
        
         SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1) ;
        insert ql2 ;
        
        
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(SBQQ__Contract__c=c.id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1) ;
        
        
        
        insert subs ;
        
        test.stoptest() ;
        
        
        
        contract cont = [select id, FOC_Period_Mths__c from contract where id = :c.id] ;
        
        system.assertequals(2,cont.FOC_Period_Mths__c) ;
        
      
        
    }

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
    
    

}