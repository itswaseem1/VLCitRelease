@isTest
Private class bg_CustomQuoteLinesController_Test {

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
        
        Product2 QMSPRoduct  = bg_Product_TestUtils.createProduct('CNCQMSTest', 'Consultation', 'Premium');
        QMSProduct.Business_Type__c = 'QMS' ;        
        QMSProduct.SBQQ__Hidden__c = True;
		QMSPRoduct.SBQQ__BillingFrequency__c = 'Monthly' ;
		products.add(QMSPRoduct);

		insert products;
	}
    
    @isTest static void myUnitTest()
     {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
 
        List<Account> testAccount = TestDataFactory.getAccounts(1,'TestAccount',true);
		List<Opportunity> testOpportunity = TestDataFactory.generateOppsForAccount(testAccount[0].Id,1000,1,true);
         Test.startTest();
		SBQQ__Quote__c testQuote = TestDataFactory.createCPQ_Quote_With_Group_and_QLIs('TestQuote');
		
        //Initialise page variables
		PageReference QuoteLines = Page.bg_CustomQuoteLines;
		Test.setCurrentPage(QuoteLines);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
       
        //Test.startTest();
		//Load controller
		bg_CustomQuoteLinesController testController = new bg_CustomQuoteLinesController();
         String testGroupName=new bg_CustomQuoteLinesController.QuoteLineGroup().groupName;
				
         SYSTEM.assertEquals(null,testController.quoteGroups);
         SYSTEM.assertNotEquals(null,testController.quoteLineGroups);
	
		Test.stopTest();
    }
    
		
}