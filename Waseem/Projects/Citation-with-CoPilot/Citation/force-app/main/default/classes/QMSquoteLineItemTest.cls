@isTest
public class QMSquoteLineItemTest {
    @isTest static void myUnitTest1() {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;
        
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedProduct.business_Type__c = 'Citation' ;
        combinedProduct.ProductCode = 'CB1' ;
        insert combinedProduct;
        
        PriceBookEntry stdpbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), combinedProduct.id, 100, 0, 0) ;
        insert stdpbe ;
        
        PriceBookEntry pbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(pricebook.id, combinedProduct.id, 100, 0, 0) ;
        insert pbe ;
        
        Product2 QMSProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        QMSProduct.Family = 'QMS';
        QMSProduct.Business_Type__c = 'QMS';
        insert QMSProduct;
        
        PriceBookEntry qmsstdpbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), QMSProduct.id, 100, 0, 0) ;
        insert qmsstdpbe ;
        
        PriceBookEntry qmspbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(pricebook.id, QMSProduct.id, 100, 0, 0) ;
        insert qmspbe ;
        
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
        Id iHascoCPQquoteRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        Id qmsCPQquoteRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('QMS Quote Standard').getRecordTypeId();
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
        testQuote.SBQQ__Status__c = 'Draft';
        testQuote.SBQQ__Type__c = 'Quote';
        testQuote.RecordTypeId = qmsCPQquoteRecTypeId;
        insert testQuote;
        
        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
        
        Test.startTest();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = QMSProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        quoteline.iHasco_Subscription_Term__c = 12;
        insert quoteLine;
        
        system.debug('Quote record type = '+[Select RecordTypeId from SBQQ__Quote__c limit 1]);
        
        Test.stopTest();
        
        
    }
    @isTest static void myUnitTest2() {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;
        
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedProduct.business_Type__c = 'Citation' ;
        combinedProduct.ProductCode = 'CB1' ;
        insert combinedProduct;
        
        PriceBookEntry stdpbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), combinedProduct.id, 100, 0, 0) ;
        insert stdpbe ;
        
        PriceBookEntry pbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(pricebook.id, combinedProduct.id, 100, 0, 0) ;
        insert pbe ;
        
        Product2 QMSProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        QMSProduct.Family = 'iHasco';
        insert QMSProduct;
        
        PriceBookEntry qmsstdpbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), QMSProduct.id, 100, 0, 0) ;
        insert qmsstdpbe ;
        
        PriceBookEntry qmspbe = bg_PriceBookEntry_TestUtils.createPricebookEntry(pricebook.id, QMSProduct.id, 100, 0, 0) ;
        insert qmspbe ;
        
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
        Id iHascoCPQquoteRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        Id qmsCPQquoteRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('QMS Quote Standard').getRecordTypeId();
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
        testQuote.SBQQ__Status__c = 'Draft';
        testQuote.SBQQ__Type__c = 'Quote';
        testQuote.RecordTypeId = iHascoCPQquoteRecTypeId;
        insert testQuote;
        
        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
        
        Test.startTest();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = QMSProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        quoteline.iHasco_Subscription_Term__c = 12;
        insert quoteLine;
        
        
        SBQQ__QuoteLine__c resultQL = [Select Id, iHasco_Subscription_Term__c, SBQQ__Quote__r.SBQQ__SubscriptionTerm__c from SBQQ__QuoteLine__c limit 1];
        system.assertEquals(resultQL.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, quoteLine.iHasco_Subscription_Term__c);
        Test.stopTest();
        
    }
    private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc)
    {
        bg_RecordTypeMap opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');         
        Opportunity o = new Opportunity();
        o.Name = opportunityName;
        if (recordtype == 'Default Citation Opportunity') {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Default Citation Opportunity'); 
        } else {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Small Business Package');
        } 
        o.AccountId = acc.id;
        o.Type = 'New Business';
        o.CloseDate = system.now().addMonths(1).date();
        o.Deal_Type__c = 'Combined';
        o.StageName = 'Provisional Approval';
        
        insert(o);
        return o;
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