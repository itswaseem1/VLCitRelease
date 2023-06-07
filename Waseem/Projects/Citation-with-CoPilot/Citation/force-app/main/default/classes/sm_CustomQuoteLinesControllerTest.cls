/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Last Modified By: KH 01/10/2017 (Test Data Setup Fix, no Pricebook was created)
 */
@isTest
private class sm_CustomQuoteLinesControllerTest {

    @testSetup static void setup()
	{
		List<Product2> products = new List<Product2>();
		Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
		products.add(combinedProduct);
		Product2 healthAndSafetyProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, 'Consultation', 'Premium');
		products.add(healthAndSafetyProduct);
		Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
		products.add(employementLawProduct);
		Product2 consultancyProduct = bg_Product_TestUtils.createProduct('Consultancy Day', 'Consultation', 'Premium');
		products.add(consultancyProduct);

		insert products;
        
        Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ');
        insert qmsNewPB;
	}
		
		
     @isTest static void myUnitTest()
     {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
 
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
		SBQQ__Quote__c testQuote = createQuote('TestQuote');
		SBQQ__QuoteTemplate__c testTemplate = createTemplate();
		
        //Initialise page variables
		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
       
        Test.startTest();
		//Load controller
		sm_CustomQuoteLinesController testController = new sm_CustomQuoteLinesController();
				
		
		Test.stopTest();
    }
    
    @isTest static void QuoteLineMonthly()
     {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
 		
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
		SBQQ__Quote__c testQuote = createQuote('TestQuote');
		SBQQ__QuoteTemplate__c testTemplate = createTemplate();
         
        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
         
        product2 employementLawProduct = [SELECT ID FROM Product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW LIMIT 1];
        product2 combinedproduct = [SELECT ID FROM Product2 where name = :Bg_Constants.PRODUCT_COMBINED_SERVICE  LIMIT 1];
         
        
         
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = combinedproduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        insert quoteLine;
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Product__c = employementLawProduct.Id;
        quoteLine2.SBQQ__Group__c = testGroup.Id;
        quoteLine2.SBQQ__Quote__c = testQuote.Id;
        quoteLine2.SBQQ__RequiredBy__c = quoteLine.Id;
        quoteline2.sbqq__specialprice__c = 90 ;
        quoteline2.sbqq__quantity__c = 1 ;
        quoteline2.billing_Frequency__c = 'Monthly' ;
        insert quoteLine2;
		
        //Initialise page variables
		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
       
        Test.startTest();
		//Load controller
		sm_CustomQuoteLinesController testController = new sm_CustomQuoteLinesController();
				
		
		Test.stopTest();
    }
    
    @isTest static void QuoteLineOneOff()
     {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
 		
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);
		SBQQ__Quote__c testQuote = createQuote('TestQuote');
		SBQQ__QuoteTemplate__c testTemplate = createTemplate();
         
        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
         
        product2 employementLawProduct = [SELECT ID FROM Product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW LIMIT 1];
        product2 combinedproduct = [SELECT ID FROM Product2 where name = :Bg_Constants.PRODUCT_COMBINED_SERVICE  LIMIT 1];
         
        
         
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = combinedproduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.SBQQ__CustomerPrice__c = 100;
        quoteline.billing_Frequency__c = 'One-Off';
        insert quoteLine;
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Product__c = employementLawProduct.Id;
        quoteLine2.SBQQ__Group__c = testGroup.Id;
        quoteLine2.SBQQ__Quote__c = testQuote.Id;
        quoteLine2.SBQQ__RequiredBy__c = quoteLine.Id;
        quoteline2.sbqq__specialprice__c = 90 ;
        quoteline2.sbqq__quantity__c = 1 ;
        quoteline2.SBQQ__CustomerPrice__c = 100;
        quoteline2.billing_Frequency__c = 'One-Off';
        insert quoteLine2;
		
        //Initialise page variables
		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
       
        Test.startTest();
		//Load controller
		sm_CustomQuoteLinesController testController = new sm_CustomQuoteLinesController();
				
		
		Test.stopTest();
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
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        return q;            
      
    }
    
    
    private static SBQQ__QuoteTemplate__c createTemplate()
    {
    	SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
    
    	insert t;
    	return t;    
    
    }
}