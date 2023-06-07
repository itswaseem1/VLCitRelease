@isTest
public class QuoteGroupLineTriggerHandlerTest {
    
    public static Id quoteQmsRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(DataConstants.Quote_QMS_RECORDTYPENAME).getRecordTypeId();
    public static Id opportunityQmsRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS').getRecordTypeId();        
        
   @TestSetup static void setup() {
         Pricebook2 pricebook = new PriceBook2(Name = 'QMS CPQ');
        insert pricebook;
       
       Pricebook2 pricebookcOld = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebookcOld;

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
		testAccount.AnnualRevenue = 5000;
       	update testAccount;
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
         
    Id qmsCPQquoteRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('QMS Quote Standard').getRecordTypeId();
	Test.startTest();
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
         testGroup.SBQQ__Optional__c = true;
        insert testGroup;
		
	Test.stopTest();
        
                
    }
    
    @isTest
    public static void testQuotegroupchange(){
        SBQQ__Quote__c testQuote = [select id from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLineGroup__c testGroup = [select id,SBQQ__Optional__c from SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :testQuote.Id Limit 1 ];
        product2 QMSProduct = [select id from product2 where Family = 'QMS' limit 1];
        Test.startTest();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = QMSProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        insert quoteLine;
        test.stopTest();
       
       testGroup.SBQQ__Optional__c = false;
       update testGroup;

        
    }
   
    
    
    
    private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc)
    {
        Opportunity o = new Opportunity();
        o.Name = opportunityName;
        o.RecordTypeId =  opportunityQmsRecTypeId; 
        o.AccountId = acc.id;
        o.Type = 'New Business';
        o.CloseDate = system.now().addMonths(1).date();
        o.Deal_Type__c = 'Combined';
        o.StageName = 'Draft';
        o.Term__c = '5';

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