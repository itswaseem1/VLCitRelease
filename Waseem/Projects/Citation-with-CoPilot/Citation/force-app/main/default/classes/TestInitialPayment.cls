@isTest
public class TestInitialPayment {
    public static testMethod void sampleData(){
        
        List<SBQQ__QuoteLine__c> lineVal1 = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lineVal2 = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> allRecords = new List<SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> mapLine1 = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> mapLine2 = new Map<Id,SBQQ__QuoteLine__c>();
        InitialPayment_Quote init = new InitialPayment_Quote();
        
        Account acc = new Account();
            acc.Name = 'ValueLabs LLP';
            acc.FT_Employees__c = 10;
            acc.PT_Employees__c = 5;
            acc.Directors__c = 4;
            acc.Subcontractors__c = 3;
            acc.Sites__c = 10;
            acc.CitationSector__c = 'CARE';
            acc.Sector__c = 'CARE';
            insert acc;
        
        Contact cont = new Contact();
            cont.FirstName = 'Sai';
            cont.LastName = 'Karthik';
            cont.AccountId = acc.Id;
            insert cont;
        
        Opportunity opp = new Opportunity();
            opp.Name = 'ValueLabs Oppo';
            opp.AccountId = acc.Id;
            opp.CloseDate = Date.newInstance(2019, 05, 10);
            opp.StageName = 'Appointment';
            opp.Type = 'New Business';
            opp.Event_Outcome__c = 'Not attended yet';
            insert opp;
        
        Pricebook2 price = new Pricebook2();
            price.Name = '£0 - £75,000 (CPQ)';
            price.IsActive = true;
            insert price;
        
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c();
            cpqQuote.SBQQ__Primary__c = true;
            cpqQuote.SBQQ__StartDate__c = Date.today();
            cpqQuote.SBQQ__Status__c = 'Draft';
            cpqQuote.SBQQ__Account__c = acc.Id;
            cpqQuote.SBQQ__Opportunity2__c = opp.Id;
            cpqQuote.SBQQ__PrimaryContact__c = cont.Id;
            cpqQuote.Preferred_Payment_Date__c = '7';
            cpqQuote.SBQQ__PriceBook__c = price.Id;
        	cpqQuote.Initial_Payment_Date__c = Date.newInstance(2018, 01, 07);
            insert cpqQuote;
        
        SBQQ__QuoteLineGroup__c groupName1 = new SBQQ__QuoteLineGroup__c();
            groupName1.Name = 'Option 1';
            groupName1.SBQQ__Quote__c = cpqQuote.Id;
            insert groupName1;

        Product2 pro1 = new Product2();
            pro1.Name = 'Additional Law Posters';
            pro1.ProductCode = 'ADD';
        	pro1.Family = 'Care';
            insert pro1;

        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
            quoteLine1.SBQQ__Product__c = pro1.Id;
            quoteLine1.SBQQ__Quote__c = cpqQuote.Id;
            quoteLine1.SBQQ__Quantity__c = 2;
            quoteLine1.FOC_Period__c = 'Start';
            quoteLine1.SBQQ__StartDate__c = Date.newInstance(2020, 03, 10);
            quoteLine1.Service_Start_Date__c = Date.today();
            quoteLine1.SBQQ__Group__c = groupName1.Id;
            quoteLine1.Billing_Frequency__c = 'Monthly';
            quoteLine1.SBQQ__BillingFrequency__c = 'Monthly';

        SBQQ__QuoteLineGroup__c groupName2 = new SBQQ__QuoteLineGroup__c();
            groupName2.Name = 'Option 1';
            groupName2.SBQQ__Quote__c = cpqQuote.Id;
            insert groupName2;

        Product2 pro2 = new Product2();
            pro2.Name = 'Free Month';
            pro2.ProductCode = 'Free-Month';
        	pro2.Family = 'Health';
            insert pro2;
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
            quoteLine2.SBQQ__Product__c = pro2.Id;
            quoteLine2.SBQQ__Quote__c = cpqQuote.Id;
            quoteLine2.SBQQ__Quantity__c = 2;
            quoteLine2.FOC_Period__c = 'Start';
            quoteLine2.SBQQ__StartDate__c = Date.newInstance(2019, 03, 10);
            quoteline2.Service_Start_Date__c = Date.today();
            quoteline2.SBQQ__Group__c = groupName2.Id;
            quoteLine2.Billing_Frequency__c = 'Annual';
            quoteLine2.SBQQ__BillingFrequency__c = 'Annual';
        	allRecords.add(quoteLine2);
        	//allRecords.add(quoteLine1);
            insert allRecords;
        
        	//mapLine1.put(quoteLine1.Id,quoteLine1);
        	lineVal1.add(quoteLine1);
        	init.autoPopulateQuoteLine(lineVal1,true,mapLine1,true);
        
        	mapLine2.put(quoteLine2.Id,quoteLine2);
			lineVal2.add(quoteLine2);
			init.autoPopulateQuoteLine(lineVal2,true,mapLine2,true);
        
            init.conditionCheckviaCal(2,'7', Date.newInstance(2018,12,5), 'Annual', 2, 'Start');
        	init.conditionCheckviaCal(2,'7', Date.newInstance(2018,12,5), 'Annual', 2, 'End');
            init.conditionCheckviaCal(1,'7', Date.newInstance(2018,11,14), 'Annual', 3, 'End');
            init.conditionCheck(2,'7', Date.newInstance(2018,11,5), 'Monthly','Start');
            init.conditionCheck(2,'7', Date.newInstance(2018,11,14), 'Annual','Start');
    }
    
    public static testMethod void childQuoteLinesTesting(){
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c();
        cpqQuote.SBQQ__Primary__c = true;
        cpqQuote.SBQQ__StartDate__c = Date.today();
        cpqQuote.SBQQ__Status__c = 'Draft';
        cpqQuote.Preferred_Payment_Date__c = '7';
        cpqQuote.Initial_Payment_Date__c = Date.newInstance(2018, 01, 07);
        insert cpqQuote;
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = cpqQuote.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedProduct.business_Type__c = 'Citation' ;
        combinedProduct.ProductCode = 'CB1' ;
        insert combinedProduct;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = cpqQuote.id, sbqq__group__c = qg.id, sbqq__product__C = combinedProduct.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;
        
        SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = cpqQuote.id, sbqq__group__c = qg.id, sbqq__product__C = combinedProduct.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0,Billing_frequency__c = 'Annual', sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
        insert ql2 ;
    }
  
    public static testMethod void populateCarePoliciesChildCountTesting(){
        List<Product2> productList = new List<Product2>();
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c();
        cpqQuote.SBQQ__Primary__c = true;
        cpqQuote.SBQQ__StartDate__c = Date.today();
        cpqQuote.SBQQ__Status__c = 'Draft';
        cpqQuote.Preferred_Payment_Date__c = '7';
        cpqQuote.Initial_Payment_Date__c = Date.newInstance(2018, 01, 07);
        insert cpqQuote;
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = cpqQuote.Id);
        qg.Name = 'Option 1';
        insert qg;

        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedProduct.business_Type__c = 'Citation' ;
        combinedProduct.ProductCode = 'CARE-POLICIES' ;
        productList.add(combinedProduct);

        Product2 clinicalProduct = bg_Product_TestUtils.createProduct('Clinical England', 'Consultation', 'Premium');
        clinicalProduct.business_Type__c = 'Citation' ;
        clinicalProduct.ProductCode = 'CARE-POL-CLIN-ENGLAND' ;
        productList.add(clinicalProduct);
        insert productList;
        Test.startTest();
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = cpqQuote.id, sbqq__group__c = qg.id, sbqq__product__c = combinedProduct.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;

        SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = cpqQuote.id, sbqq__group__c = qg.id, sbqq__product__C = clinicalProduct.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0,Billing_frequency__c = 'Annual', sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
        insert ql2 ;
        Test.stopTest();
    }
}