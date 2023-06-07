@isTest
public class QueueableCPQliRollupTest {

    @testSetup static void setup() { 
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
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
 
        List<Account> testAccount = TestDataFactory.getAccounts(1,'TestAccount',true);
		List<Opportunity> testOpportunity = TestDataFactory.generateOppsForAccount(testAccount[0].Id,1000,1,true);
	    Test.startTest();
    	TestDataFactory.createCPQ_Quote_With_Group_and_QLIs('TestQuote');
	    Test.stopTest();
    }
    
    static testMethod void Testexecute() {
        SBQQ__Quoteline__c q = [SELECT Id, sbqq__requiredby__c from SBQQ__Quoteline__c where sbqq__requiredby__c != null];
        Test.startTest();
        	Delete q;
        Test.stopTest();
            
    }
}