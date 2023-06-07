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
 */
@isTest
private class cc_CustomQuoteLinesControllerTest {

  
    @testSetup static void setup()
	{
		List<Product2> products = new List<Product2>();
		Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
		combinedproduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        combinedproduct.FOC_Months_Eligible__c=true;
        Product2 combinedProduct1 = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
		combinedproduct1.SBQQ__BillingFrequency__c = 'Annual' ;
		products.add(combinedProduct);
        products.add(combinedProduct1);
		Product2 healthAndSafetyProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_HEALTH_AND_SAFETY, 'Consultation', 'Premium');
		HealthAndSafetyProduct.SBQQ__BillingFrequency__C = 'Annual' ;
		products.add(healthAndSafetyProduct);
		Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
		EmployementLawPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        employementLawProduct.FOC_Months_Eligible__c=false;
        employementLawProduct.ProductCode='Part-Comm1';
		products.add(employementLawProduct);
		Product2 consultancyProduct = bg_Product_TestUtils.createProduct('Consultancy Day', 'Consultation', 'Premium');
		ConsultancyProduct.SBQQ__BillingFrequency__c = 'Monthly' ;
		products.add(consultancyProduct);
        
        Product2 QMSPRoduct  = bg_Product_TestUtils.createProduct('CNCQMSTest', 'Consultation', 'Premium');
        QMSProduct.Business_Type__c = 'QMS' ;        
        QMSProduct.SBQQ__Hidden__c = True;
		QMSPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        QMSPRoduct.FOC_Months_Eligible__c=true;
        QMSPRoduct.ProductCode='Part-Comm';
		products.add(QMSPRoduct);

         Product2 SMASProduct = bg_Product_TestUtils.createProduct('SMAS Accreditation', 'SMAS Accreditation', '');
        SMASProduct.business_Type__c = 'Citation' ;
        SMASProduct.ProductCode = 'SMAS-ACC' ;
		products.add(SMASProduct);
		insert products;
	}
		
		
     @isTest static void QuoteLinesControllerPriceValuesTest()
     {
       /* Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        
        pricebook.Term__c = '3';
        insert pricebook;
        id pbid = pricebook.id;
        list<pricebook2>   lsp = [select id,name from pricebook2];
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);*/
		SBQQ__Quote__c testQuote = createQuote('TestQuote');
		SBQQ__QuoteTemplate__c testTemplate = createTemplate();
		
        //Initialise page variables
		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
       
        Test.startTest();
		//Load controller
		cc_CustomQuoteLinesController testController = new cc_CustomQuoteLinesController();
				
		list<account> tst = testcontroller.getBlank() ;
		
		system.debug(testcontroller.getQuoteGroups()) ;
		
		system.debug(testcontroller.getQuoteGroupsSize()) ;
		
		
        List<Double> totalOneOffValues= testcontroller.groupTotalsOneOff.values();
        system.assertEquals(1179.0, totalOneOffValues[0]);
        List<Double> totalMonthlyValues= testcontroller.groupTotalsMonthly.values();
        system.assertEquals(196.5, totalMonthlyValues[0]);
        List<Double> totalAnnualValues= testcontroller.groupTotalsAnnual.values();
        system.assertEquals(2178.0, totalAnnualValues[0]);
		
		Test.stopTest();
    }
    
    @isTest static void QuoteLinesControllerTest()
     {
          
       /* Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        
        insert pricebook;
         list<pricebook2>   lsp = [select id,name from pricebook2];
 		id pbid = pricebook.id;
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);     */
		SBQQ__Quote__c testQuote = createQuote2('TestQuote');
		SBQQ__QuoteTemplate__c testTemplate = createTemplate();
		
        //Initialise page variables
		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
       
        Test.startTest();
		//Load controller
		cc_CustomQuoteLinesController testController = new cc_CustomQuoteLinesController();
				
		list<account> tst = testcontroller.getBlank() ;
		
		system.debug(testcontroller.getQuoteGroups()) ;
		
		system.debug(testcontroller.getQuoteGroupsSize()) ;
		
		System.assertEquals(1,testcontroller.getQuoteGroupsSize());
		
		
		Test.stopTest();
    }
	
	    @isTest static void QuoteLinesControllerGroupTest()
     {
         
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        
        insert pricebook;
         list<pricebook2>   lsp = [select id,name from pricebook2];
 		id pbid = pricebook.id;
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		Opportunity testOpportunity = createOpportunity('TestOpp', 'Default Citation Opportunity', testAccount,pbid);
		SBQQ__Quote__c testQuote = createQuote3('TestQuote');
		SBQQ__QuoteTemplate__c testTemplate = createTemplate();
		
        //Initialise page variables
		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', testQuote.Id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
       
        Test.startTest();
		//Load controller
		cc_CustomQuoteLinesController testController = new cc_CustomQuoteLinesController();
				
		list<account> tst = testcontroller.getBlank() ;
		
		system.debug(testcontroller.getQuoteGroups()) ;
		
		system.debug(testcontroller.getQuoteGroupsSize()) ;
		System.assertEquals(1,testcontroller.getQuoteGroupsSize());				         
		
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

    private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc,id pid)
    {
        id cpid = pid;
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
		o.pricebook2id = cpid;
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
        List<SBQQ__QuoteLineGroup__c> groupQuolineRecords=new List<SBQQ__QuoteLineGroup__c>();
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        groupQuolineRecords.add(qg);
        SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg1.Name = 'Option 2';
        qg1.SBQQ__SubscriptionTerm__c=60;
        groupQuolineRecords.add(qg1);
		insert    groupQuolineRecords; 
        
        product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;
        
        List<SBQQ__Quoteline__c> quotelinesInsert=new List<SBQQ__Quoteline__c>();
         SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0,Billing_frequency__c = 'Annual', sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
        quotelinesInsert.add(ql2);
        
        product2 sMASprod = [select id from product2 where name = 'SMAS Accreditation'] ;
        SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='Annual',  Billing_frequency__c = 'Annual', SmasRollUp__c=1179,Initial_payment__c=1179 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Annually') ;
        quotelinesInsert.add(ql3);
        SBQQ__Quoteline__c ql4 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='One-Off',  Billing_frequency__c = 'One-Off', SmasRollUp__c=1179,SBQQ__SubscriptionTerm__c=60) ;
        quotelinesInsert.add(ql4);
        SBQQ__Quoteline__c ql5 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='One-Off',  Billing_frequency__c = 'One-Off', SmasRollUp__c=1179,SBQQ__SubscriptionTerm__c=60) ;
        quotelinesInsert.add(ql5);
        SBQQ__Quoteline__c ql6 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '0 - 1',Billing_Frequency_SMAS__c='Annual',  Billing_frequency__c = 'Annual', SmasRollUp__c=999,Initial_payment__c=999 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Annually') ;
        quotelinesInsert.add(ql6);
        SBQQ__Quoteline__c ql7 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='Monthly',  Billing_frequency__c = 'Monthly', SmasRollUp__c=98.25,Initial_payment__c=98.25 ,SBQQ__SubscriptionTerm__c=60,Billing_Term__c='Monthly',Sub_Line_Total__c=5895) ;
        quotelinesInsert.add(ql7);
        SBQQ__Quoteline__c ql8 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '5 - 15',Billing_Frequency_SMAS__c='Monthly',  Billing_frequency__c = 'Monthly', SmasRollUp__c=98.25,SBQQ__SubscriptionTerm__c=60,Sub_Line_Total__c=5895) ;
        quotelinesInsert.add(ql8);
        SBQQ__Quoteline__c ql9 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = sMASprod.id,SBQQ__Quantity__c = 1.0, Employee_Numbers_Picklist__c = '0 - 1',Billing_Frequency_SMAS__c='Monthly',  Billing_frequency__c = 'Monthly', SmasRollUp__c=83.25,SBQQ__SubscriptionTerm__c=60,SBQQ__NetPrice__c=0) ;
        quotelinesInsert.add(ql9);
        insert quotelinesInsert;
        return q;            
    }
    
    private static SBQQ__Quote__c createQuote2(String qName)
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
        q.FOC_Months__c=2;
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg1.Name = 'Option 2';
        insert qg1;
        
        product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        product2 prod2 = [select id from product2 where name ='CNCQMSTest' ] ;
       // product2 prod3 = [select id from product2 where name =:Bg_Constants.PRODUCT_COMBINED_SERVICE and sbqq__billingfrequency__C = 'Monthly' ] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,Billing_Frequency__c = 'Monthly',SBQQ__NetPrice__c=10) ;
       insert ql ;
        
         SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod2.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        insert ql2 ;
        
       // SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = prod3.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
       // insert ql3 ;     
        
        return q;            
      
    }
    
    private static SBQQ__Quote__c createQuote3(String qName)
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
        q.FOC_Months__c=3;
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        SBQQ__QuoteLineGroup__c qg1 = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg1.Name = 'Option 2';
        insert qg1;
        
        //product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        product2 prod2 = [select id from product2 where name ='CNCQMSTest' ] ;
        product2 prod3 = [select id from product2 where name =:Bg_Constants.PRODUCT_COMBINED_SERVICE and sbqq__billingfrequency__C = 'Annual' ] ;
        
        //SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,Billing_Frequency__c = 'Monthly',SBQQ__NetPrice__c=10 ) ;
//        insert ql ;
        
         //SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod2.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
        //insert ql2 ;
        
         SBQQ__Quoteline__c ql3 = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg1.id, sbqq__product__C = prod3.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10) ;
         insert ql3 ;        
        
        
        return q;            
      
    }
    
    private static SBQQ__QuoteTemplate__c createTemplate()
    {
    	SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
    
    	insert t;
    	return t;    
    
    }
}