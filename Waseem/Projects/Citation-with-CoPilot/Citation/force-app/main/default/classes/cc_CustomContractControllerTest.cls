@isTest
private class cc_CustomContractControllerTest {

     @testSetup static void setup()
    {
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
        Product2 SMASProduct = bg_Product_TestUtils.createProduct('SMAS Accreditation', 'SMAS Accreditation', '');
        SMASProduct.business_Type__c = 'Citation' ;
        SMASProduct.ProductCode = 'SMAS-ACC' ;
        products.add(SMASProduct);
        Product2 QMSProduct = bg_Product_TestUtils.createProduct('ISO-9001', 'QMS', 'Premium');
        QMSProduct.ProductCode = 'ISO 9001-CPQ-A' ;
        QMSProduct.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct);
        Product2 QMSProduct2 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Multi-Site - Compliance Audit', 'QMS', 'Premium');
        QMSProduct2.ProductCode = 'ISO 9001-AS' ;
        QMSProduct2.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct2);
        Product2 QMSProduct3 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Consultancy & Certification', 'QMS', 'Premium');
        QMSProduct3.ProductCode = 'ISO 9001-A' ;
        QMSProduct3.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct3);
        Product2 QMSProduct4 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Surveillance Audit', 'QMS', 'Premium');
        QMSProduct4.ProductCode = 'ISO 9001-A' ;
        QMSProduct4.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct4);
        Product2 QMSProduct5 = bg_Product_TestUtils.createProduct('ISO 9001 - Upgrade - QMS Management System', 'QMS', 'Upgrade');
        QMSProduct5.ProductCode = 'ISO 9001-A' ;
        QMSProduct5.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct5);
        insert products;
        
        Service_Detail__c objServiceDetail = new Service_Detail__c();
        objServiceDetail.Product__c = QMSProduct4.Id;
        objServiceDetail.Billing_frequency__c = 'Monthly';
        objServiceDetail.Type_of_Service__c = 'Premium';
        objServiceDetail.Service_Details__c = 'Test service Details';
        insert objServiceDetail;  
    }
        
        
     @isTest static void contractControllerQLValuesTest()
     {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
         
        Map<String, Product2> prdMap = new Map<String, Product2>();
        List<product2> prdtList = [SELECT ID , SBQQ__BillingFrequency__c FROM Product2];
         For(Product2 p: prdtList){
             prdMap.put(p.SBQQ__BillingFrequency__c,p);
        }
        
        List<Service_Detail__c> serviceDetailsList = [Select Billing_frequency__c,Product__c,Type_of_Service__c,Service_Details__c from Service_Detail__c];
        
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        //Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount);
        SBQQ__Quote__c testQuote = createQuote('TestQuote');
        SBQQ__QuoteTemplate__c testTemplate = createTemplate();
         
        //Initialise page variables
        PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
        Test.setCurrentPage(CPQGeneratePage);

        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
        
        Test.startTest();
        
        product2 prod9 = [select id from product2 where ProductCode = 'ISO 9001-AS'];
        
        SBQQ__QuoteLineGroup__c objGroup = [Select Id from SBQQ__QuoteLineGroup__c];
        
        product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        
        SBQQ__Quoteline__c objQL = [Select id from SBQQ__Quoteline__c where sbqq__product__c =:prod.Id];
        
        Service_Detail__c objServiceDetail = new Service_Detail__c();
        objServiceDetail.Product__c = prod9.Id;
        objServiceDetail.Billing_frequency__c = 'Monthly';
        objServiceDetail.Type_of_Service__c = 'Premium';
        objServiceDetail.Service_Details__c = 'Test service Details';
        insert objServiceDetail;  
        
        SBQQ__Quoteline__c ql9 = new SBQQ__Quoteline__c(sbqq__requiredby__c = objQL.id,sbqq__quote__c = testQuote.id, sbqq__group__c = objGroup.id, sbqq__product__C = prod9.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Monthly',SBQQ__CustomerPrice__c=2000, Service__c='Premium') ;
        //quoteLineRecordsInsert.add(ql9) ;
        insert ql9;
        
        //Load controller
        cc_CustomContractController testController = new cc_CustomContractController();
        //qms_ContractProductPrices qmstestcontroller = new qms_ContractProductPrices();
                
        
        Test.stopTest();
        system.assertEquals(1189.0, testcontroller.OneOffTotal);
        system.assertEquals(98.25, testcontroller.MonthlyTotal);
        system.assertEquals(2358.0, testcontroller.AnnualTotal);
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
        acc.AnnualRevenue = 50000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
        
        insert acc;
        return acc;     
    }

    private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc)
    {
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
        q.Number_of_Part_Time_Employees__c = 10;
        q.Number_of_full_Time_Employees__c = 12;
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        
        insert qg;
        
         product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0 , Billing_frequency__c = 'Monthly',Initial_Payment__c=10 ) ;
        insert ql ;
        
         SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0 , Billing_frequency__c = 'Annual', Initial_Payment__c=10,SBQQ__SubscriptionTerm__c=1,Billing_Term__c='Annually',SBQQ__SpecialPrice__c = 10.0,SBQQ__NetPrice__c=10.0) ;
        //insert ql2 ;
        List<SBQQ__Quoteline__c> quoteLineRecordsInsert=new List<SBQQ__Quoteline__c>();
        
        product2 sMASprod = [select id from product2 where name = 'SMAS Accreditation'] ;
        
        
        SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='Annual',  Billing_frequency__c = 'Annual', SmasRollUp__c=1179,Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Annually') ;
        quoteLineRecordsInsert.add(ql3) ;
        SBQQ__Quoteline__c ql4 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='One-Off',  Billing_frequency__c = 'One-Off', SmasRollUp__c=1179,SBQQ__SubscriptionTerm__c=60) ;
        quoteLineRecordsInsert.add(ql4) ;
        SBQQ__Quoteline__c ql5 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='Monthly',  Billing_frequency__c = 'Monthly', SmasRollUp__c=98.25,SBQQ__SubscriptionTerm__c=60) ;
        quoteLineRecordsInsert.add(ql5) ;
        SBQQ__Quoteline__c ql6 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Annual',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Annually',SBQQ__CustomerPrice__c=2000000, Service__c='Support') ;
        quoteLineRecordsInsert.add(ql6) ;
        SBQQ__Quoteline__c ql7 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Annual',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Annually',SBQQ__CustomerPrice__c=2000000, Service__c='Additional Site Compliance audit – Existing Client') ;
        quoteLineRecordsInsert.add(ql7) ;
        SBQQ__Quoteline__c ql8 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Annual',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Annually',SBQQ__CustomerPrice__c=2000000, Service__c='Premium') ;
        quoteLineRecordsInsert.add(ql8) ;
        
        insert quoteLineRecordsInsert;
        
        return q;    
        
      
    }
    
    
    private static SBQQ__QuoteTemplate__c createTemplate()
    {
        SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
    
        insert t;
        return t;    
    }
}