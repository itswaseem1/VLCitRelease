@isTest
public class qms_ContractProductPricesTest {
    @testSetup static void setup(){
        List<Product2> products = new List<Product2>();
        Product2 QMSProduct = bg_Product_TestUtils.createProduct('ISO-9001', 'QMS', 'Premium');
        QMSProduct.ProductCode = 'ISO 9001-CPQ-A' ;
        QMSProduct.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct);
        Product2 QMSProduct2 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Multi-Site - Surveillance Audit', 'QMS', 'Premium');
        QMSProduct2.ProductCode = 'ISO 9001-AS' ;
        QMSProduct2.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct2);
        Product2 QMSProduct3 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Consultancy & Certification', 'QMS', 'Premium');
        QMSProduct3.ProductCode = 'ISO 9001-A' ;
        QMSProduct3.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct3);
        Product2 QMSProduct4 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Surveillance Audit', 'QMS', 'Premium');
        QMSProduct4.ProductCode = 'eLearning-CPQ-E' ;
        QMSProduct4.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct4);
        Product2 QMSProduct5 = bg_Product_TestUtils.createProduct('ISO 9001 - Upgrade - QMS Management System', 'QMS', 'Upgrade');
        QMSProduct5.ProductCode = 'ISO 9001-A' ;
        QMSProduct5.SBQQ__BillingFrequency__c = 'Monthly';
        products.add(QMSProduct5);
        Product2 QMSProduct6 = bg_Product_TestUtils.createProduct('ISO 9001 - Premium - Multi-Site - Compliance Audit', 'QMS', 'Premium');
        QMSProduct6.ProductCode = 'ISO 9001-AS' ;
        products.add(QMSProduct6);
        Product2 QMSProduct7 = bg_Product_TestUtils.createProduct('9001 - Premium IMNOTSURE', 'QMS', 'Premium');
        QMSProduct7.ProductCode = 'eLearning-CPQ-E' ;
        products.add(QMSProduct7);
        Product2 QMSProduct8 = bg_Product_TestUtils.createProduct('Business Continuity', 'QMS', 'Premium');
        QMSProduct8.ProductCode = 'Business Continuity' ;
        products.add(QMSProduct8);
        Product2 QMSProduct9 = bg_Product_TestUtils.createProduct('ISOMentor', 'QMS', 'Premium');
        QMSProduct9.ProductCode = 'ISOtrain' ;
        products.add(QMSProduct9);
        insert products;
    
        List<Service_Detail__c> serviceDetailtoInsert = new List<Service_Detail__c>();
        serviceDetailtoInsert.add(createServiceDetail(QMSProduct4.Id,'Test service Details'));
        serviceDetailtoInsert.add(createServiceDetail(QMSProduct9.Id,'Test service Details ISOMentor'));
        insert serviceDetailtoInsert;
         
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
    }
    
         @isTest static void myUnitTest(){
             
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
             
             
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
        
             
        
             
             
        qms_ContractProductPrices qmstestcontroller = new qms_ContractProductPrices();
            
         Test.stopTest();
         
         
         
         
         }
    @isTest static void isoMentorTest(){
        List<Service_Detail__c> serviceDetailsList = [Select Billing_frequency__c,Product__c,Type_of_Service__c,Service_Details__c from Service_Detail__c];
        
        Account testAccount = createAccount('ISOMentorAccount','PROFESSIONAL ACTIVITIES',10,10);
        SBQQ__Quote__c testQuote = createQuote('ISOMentorQuote');
        SBQQ__QuoteTemplate__c testTemplate = createTemplate();
        
        //Initialise page variables
        PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
        Test.setCurrentPage(CPQGeneratePage);
        
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
        
        Test.startTest();    
        qms_ContractProductPrices qmstestcontroller = new qms_ContractProductPrices();
        List<List<qms_ContractProductPrices.wrapQLI>> parentWQLIList=qmstestcontroller.parentWQLIList;
        System.assertEquals('Test service Details ISOMentor', parentWQLIList[2][0].serviceDetails);
        System.assertEquals('ISOMentor', parentWQLIList[2][0].Product);
        Test.stopTest();
    }        
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
        q.RecordTypeId='012D00000007V8xIAE';
        q.SBQQ__StartDate__c=system.TODAY();
        q.Preferred_Payment_Date__c='7';
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        
        insert qg;
        
        List<SBQQ__Quoteline__c> quoteLineRecordsInsert2=new List<SBQQ__Quoteline__c>();
        List<SBQQ__Quoteline__c> quoteLineRecordsInsert1=new List<SBQQ__Quoteline__c>();
        
        
        Product2 QMSProduct1= [Select Id from Product2 where name ='ISO-9001'];
        Product2 QMSProduct2= [Select Id from Product2 where name ='ISO 9001 - Premium - Consultancy & Certification'];
        Product2 QMSProduct3= [Select Id from Product2 where name ='ISO 9001 - Premium - Surveillance Audit'];
        Product2 QMSProduct4 = [Select Id from Product2 where name ='ISO 9001 - Premium - Multi-Site - Surveillance Audit'];
        Product2 QMSProduct5 = [Select Id from Product2 where name ='ISO 9001 - Premium - Multi-Site - Compliance Audit'];
        Product2 QMSProduct6 = [Select Id from Product2 where name ='Business Continuity'];
        Product2 QMSProduct7 = [Select Id from Product2 where name ='9001 - Premium IMNOTSURE'];
        Product2 QMSProduct8 = [Select Id from Product2 where name ='ISO 9001 - Upgrade - QMS Management System'];
        Product2 QMSProduct9 = [Select Id from Product2 where name ='ISOMentor'];
        
            
            
        SBQQ__Quoteline__c qmsql1 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct1.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000, Service__c='Premium',SBQQ__ListPrice__c=0) ;
        quoteLineRecordsInsert1.add(qmsql1) ;
        //insert qmsql1;
        //
        SBQQ__Quoteline__c qmsql6 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct6.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000, Service__c='Premium',SBQQ__ListPrice__c=0) ;
        quoteLineRecordsInsert1.add(qmsql6) ;
        //insert qmsql6;
        //
        insert quoteLineRecordsInsert1;
        
		SBQQ__Quoteline__c qmsql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qmsql1.id,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct2.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000,SBQQ__ListPrice__c=0,Service__c='Upgrade') ;
        quoteLineRecordsInsert2.add(qmsql2) ;
        
        SBQQ__Quoteline__c qmsql3 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qmsql1.id,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct3.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=200000,SBQQ__ListPrice__c=0) ;
        quoteLineRecordsInsert2.add(qmsql3) ;
        
        SBQQ__Quoteline__c qmsql4 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qmsql1.id,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct4.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000, Service__c='Upgrade',SBQQ__ListPrice__c=0) ;
        quoteLineRecordsInsert2.add(qmsql4) ;
        
        SBQQ__Quoteline__c qmsql5 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qmsql1.id,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct5.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000, SBQQ__ListPrice__c=0) ;
        quoteLineRecordsInsert2.add(qmsql5) ;
        
        
        SBQQ__Quoteline__c qmsql7 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qmsql6.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct7.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000, Service__c='eLearning-CPQ-E',SBQQ__ListPrice__c=0) ;
        quoteLineRecordsInsert2.add(qmsql7) ;
        
        SBQQ__Quoteline__c qmsql8 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qmsql1.id,sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct8.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000,SBQQ__ListPrice__c=0,Service__c='Additional Site Compliance audit – Existing Client') ;
        quoteLineRecordsInsert2.add(qmsql8) ;
        SBQQ__Quoteline__c qmsql9 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = QMSProduct9.id,SBQQ__Quantity__c = 1.0,  Billing_frequency__c = 'Monthly',Initial_payment__c=599 ,SBQQ__SubscriptionTerm__c=60,SBQQ__CustomerPrice__c=2000000,SBQQ__ListPrice__c=0,Service__c='Premium') ;
        quoteLineRecordsInsert2.add(qmsql9) ;
        
        
        insert quoteLineRecordsInsert2;
        
        
        return q;     
     
     
     }
        private static SBQQ__QuoteTemplate__c createTemplate()
    {
        SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
    
        insert t;
        return t;    
    }
    private static Service_Detail__c createServiceDetail(Id productId,String serviceDetail)
    {
        Service_Detail__c objServiceDetail=new Service_Detail__c();
        objServiceDetail.Product__c = productId;
        objServiceDetail.Billing_frequency__c = 'Monthly';
        objServiceDetail.Type_of_Service__c = 'Premium';
        objServiceDetail.Service_Details__c = serviceDetail;
        return objServiceDetail;    
    }
}