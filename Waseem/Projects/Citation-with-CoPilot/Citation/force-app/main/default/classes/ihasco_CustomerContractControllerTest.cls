@isTest
public class ihasco_CustomerContractControllerTest {
    @testSetup static void setup() {
        List<Product2> products = new List<Product2>();
        Product2 QMSPRoduct  = bg_Product_TestUtils.createProduct('CNCQMSTest', 'Consultation', 'Premium');
        QMSProduct.Business_Type__c = 'QMS' ;        
        QMSProduct.SBQQ__Hidden__c = True;
        QMSPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        //QMSPRoduct.FOC_Months_Eligible__c=true;
        QMSPRoduct.ProductCode='Part-Comm';
        products.add(QMSPRoduct);
        insert products;
    }
    
    @isTest static void myUnitTest() {
        SBQQ__Quote__c testQuote = createQuote('TestQuote');
        SBQQ__QuoteTemplate__c testTemplate = createTemplate();
        
        //Initialise page variables
        PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
        Test.setCurrentPage(CPQGeneratePage);
        
        ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
        ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
        
        Test.startTest();
        //Load controller
        ihasco_CustomerContractController testController = new ihasco_CustomerContractController();
        Test.stopTest();
    }
    private static SBQQ__Quote__c createQuote(String qName) {
        Date startDate = Date.newInstance(2025, 1, 1);
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__StartDate__c=startDate;
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
        
        Account a = new Account(Name='New Account');
        insert a;
        
        Contact cnt = new Contact(LastName='New Contact');
        cnt.AccountId=a.id;
        cnt.Email='dominicneau@citation.co.uk';
        insert cnt;
        
        
        
        Contract c= new Contract();
        c.CustomerSignedId = cnt.id;
        c.AccountId=a.id;
        c.Name='Name of Contract';
        c.SBQQ__Quote__c=q.id;
        c.Agreement_Type__c='Auto';
        c.RecordTypeId='0124G0000003MNSQA2';
        system.debug('The Contract'+c);
        insert c;
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        //name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and
        product2 prod = [select id from product2 where sbqq__billingfrequency__C = 'One-Off'] ;
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__ProratedListPrice__c = 10.0 ) ;
        insert ql;
        
        /*SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0,Billing_frequency__c = 'Annual', sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
        insert ql2; */ 
        return q;
        
    }
    private static SBQQ__QuoteTemplate__c createTemplate() {
        SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
        insert t; return t;    
        
    }
    
}