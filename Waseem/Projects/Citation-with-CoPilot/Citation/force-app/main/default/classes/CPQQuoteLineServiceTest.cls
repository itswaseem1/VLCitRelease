@isTest
public class CPQQuoteLineServiceTest {
	@isTest
	private static void given_QuoteLine_ChildrenPrice_Per_Billing_And_SpecialPriceCondMet_And_NotQMSProduct_When_QuoteLine_Inserted_Then_InitialPaymentNotChanged()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 QMSProduct = new Product2(Name = 'Product 1', sbqq__billingfrequency__c = 'Monthly');
		TestUtility.setId(QMSProduct);
		
		Map<Id, Product2> prodMap = new Map<Id, Product2>{QMSProduct.Id => QMSProduct};
		
		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.Sum_of_Children_Price_Per_Billing__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.sbqq__specialprice__c = 0 ;
		quoteline.SBQQ__Product__c = QMSProduct.Id;
		quoteline.Sub_Line_Total__c = 1200;
		quoteline.SBQQ__SubscriptionTerm__c = 12;
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteline};
		
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = prodMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals(null, quoteline.initial_payment__c, 'Initial Payment set');
	}
	
	@isTest
	private static void given_QuoteLine_ChildrenPrice_Per_Billing_And_SpecialPriceCondNotMet_WhenNotQMSProduct_And_QuoteLine_Inserted_Then_InitialPaymentNotSet()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 QMSProduct = new Product2(Name = 'Product 1');
		TestUtility.setId(QMSProduct);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(QMSProduct.id, QMSProduct);

		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.Sum_of_Children_Price_Per_Billing__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.sbqq__specialprice__c = 90 ;
		quoteline.SBQQ__Product__c = QMSProduct.Id;
		quoteline.Sub_Line_Total__c = 1200;
		quoteline.SBQQ__SubscriptionTerm__c = 12;
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteline};
		
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();

		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals(null, quotelines[0].initial_payment__c);
	}
	
	@isTest
	private static void given_QuoteLine_ChildrenPrice_Per_Billing_And_SpecialPriceCondMet_WhenQMSProduct_QuoteLine_Inserted_Then_InitialPaymentChanged()
	{
		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Sum_of_Children_Price_Per_Billing__c":90, "Sub_Lines_Total_Monthly_Payment__c":200, "sbqq__specialprice__c":0, "Product_Business_Type__c":"QMS"}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals(200, quoteLine.initial_payment__c, 'Initial Payment not set');
	}
	
	@isTest
	private static void given_QuoteLine_ChildrenPricing_CondNotMet_And_NotQMSProduct_When_QuoteLine_Updated_Then_InitialPaymentNotChanged()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 QMSProduct = new Product2(Name = 'Product 1');
		TestUtility.setId(QMSProduct);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(QMSProduct.id, QMSProduct);

		SBQQ__QuoteLine__c oldquoteLine = new SBQQ__QuoteLine__c();
		oldquoteLine.SBQQ__Quote__c = testQuote.Id;
		oldquoteLine.Sum_of_Children_Price_Per_Billing__c = 200 ;
		oldquoteLine.sbqq__quantity__c = 1 ;
		oldquoteLine.SBQQ__Product__c = QMSProduct.Id;
		oldquoteLine.Sub_Line_Total__c = 1200;
		oldquoteLine.SBQQ__SubscriptionTerm__c = 12;
		oldquoteLine.initial_payment__c = 200;
		TestUtility.setId(oldquoteLine);
		
		Map<Id, SBQQ__QuoteLine__c>   oldQuoteLineMap = new Map<ID, SBQQ__QuoteLine__c> {oldQuoteLine.Id => oldQuoteLine};
		
		SBQQ__QuoteLine__c newquoteLine = new SBQQ__QuoteLine__c();
		newquoteLine = oldquoteLine;
		newquoteLine.Sum_of_Children_Price_Per_Billing__c = 300;
		List<SBQQ__QuoteLine__c> newquoteLines = new List<SBQQ__QuoteLine__c>{newquoteLine};
					
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow); 

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineMap);
		
		Test.stopTest();
		
		System.assertEquals(200, newquoteLines[0].initial_payment__c);
	}
	
	@isTest
	private static void given_QuoteLine_ChildrenPricingAndSpecialPriceCondMet_And_QMSProduct_When_QuoteLine_Updated_Then_InitialPaymentChanged()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 QMSProduct = new Product2(Name = 'QMS Product', Business_Type__c = 'QMS');
		TestUtility.setId(QMSProduct);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Sum_of_Children_Price_Per_Billing__c":90, "Sub_Lines_Total_Monthly_Payment__c":200, "sbqq__specialprice__c":0, "Product_Business_Type__c":"QMS"}';
		SBQQ__QuoteLine__c oldQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(oldQuoteLine);
		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{oldQuoteLine.Id => oldQuoteLine};
		
		String jobj2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Sum_of_Children_Price_Per_Billing__c":90, "Sub_Lines_Total_Monthly_Payment__c":300, "sbqq__specialprice__c":0, "Product_Business_Type__c":"QMS"}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj2, SBQQ__QuoteLine__c.class);
		newQuoteLine.Id = oldQuoteLine.Id;
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		 
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();

		Test.startTest();		
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(newQuoteLine.initial_payment__c, 300, 'Initial Payment not set');
	}
	
	@isTest
	private static void given_QuoteLine_Has_QMSProduct_And_ParentQuoteLine_And_Custom_Discount_Amount_When_QuoteLine_Updated_Then_SetinitialPayment_Excluding_DiscountedAmount()
	{
		Product2 QMSProduct = new Product2(Name = 'Product 1');
		TestUtility.setId(QMSProduct);

		Map<Id, Product2> productMap = new Map<Id, Product2>{QMSProduct.Id => QMSProduct};

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}}';
		SBQQ__QuoteLine__c parentQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(parentQuoteLine);

		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"SBQQ__Product__c":"'+QMSProduct.id+'", "Custom_Discount_Amount__c":0,"SBQQ__Listprice__c":900,"SBQQ__Quantity__c":2, "Product_Business_Type__c":"QMS","SBQQ__RequiredBy__c":"'+parentQuoteLine.id+'","Initial_Payment__c":0}';
		SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobj1, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine1);

		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{quoteLine1.Id => quoteLine1};

		//QuoteLine Updated with Discount Amount
		quoteLine1.Custom_Discount_Amount__c = 100;

		List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>{quoteLine1};

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newquotelines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(700, newquotelines[0].initial_payment__c);
	}

	@isTest
	private static void given_QuoteLine_Has_QMSProduct_And_ParentQuoteLine_And_Custom_Discount_Percentage_When_QuoteLine_Updated_Then_SetinitialPayment_Excluding_DiscountedPercentage()
	{
		Product2 QMSProduct = new Product2(Name = 'Product 1');
		TestUtility.setId(QMSProduct);

		Map<Id, Product2> productMap = new Map<Id, Product2>{QMSProduct.Id => QMSProduct};

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}}';
		SBQQ__QuoteLine__c parentQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(parentQuoteLine);

		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"SBQQ__Product__c":"'+QMSProduct.id+'", "Custom_Discount_Percentage__c":0,"SBQQ__Listprice__c":1000,"SBQQ__Quantity__c":2, "Product_Business_Type__c":"QMS","SBQQ__RequiredBy__c":"'+parentQuoteLine.id+'","Initial_Payment__c":0}';
		SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobj1, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine1);

		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{quoteLine1.Id => quoteLine1};

		//QuoteLine Updated with Discount Amount
		quoteLine1.Custom_Discount_Percentage__c = 10;

		List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>{quoteLine1};

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newquotelines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(900, newquotelines[0].initial_payment__c);
	}
	
	@isTest
	private static void given_QuoteLine_Has_QMSProduct_And_ParentQuoteLine_And_No_Discount_When_QuoteLine_Updated_Then_SetinitialPayment_To_List_Price()
	{
		Product2 QMSProduct = new Product2(Name = 'Product 1');
		TestUtility.setId(QMSProduct);

		Map<Id, Product2> productMap = new Map<Id, Product2>{QMSProduct.Id => QMSProduct};

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}}';
		SBQQ__QuoteLine__c parentQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(parentQuoteLine);

		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"SBQQ__Product__c":"'+QMSProduct.id+'", "Custom_Discount_Amount__c":200,"SBQQ__Listprice__c":1000,"SBQQ__Quantity__c":2, "Product_Business_Type__c":"QMS","SBQQ__RequiredBy__c":"'+parentQuoteLine.id+'","Initial_Payment__c":0}';
		SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobj1, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine1);

		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{quoteLine1.Id => quoteLine1};

		//QuoteLine Updated with Discount Amount
		quoteLine1.Custom_Discount_Amount__c = 0;

		List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>{quoteLine1};

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newquotelines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(1000, newquotelines[0].initial_payment__c);
	}

	@isTest
	private static void given_QuoteLine_Has_NoQMSProduct_And_ParentQuoteLine_And_Custom_Discount_Amount_When_QuoteLine_Updated_Then_SetinitialPayment_Excluding_DiscountedAmount_From_SpecialPrice()
	{
		Product2 ProductRecord = new Product2(Name = 'Product 1');
		TestUtility.setId(ProductRecord);

		Map<Id, Product2> productMap = new Map<Id, Product2>{ProductRecord.Id => ProductRecord};

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}}';
		SBQQ__QuoteLine__c parentQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(parentQuoteLine);

		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"SBQQ__Product__c":"'+ProductRecord.id+'", "Custom_Discount_Amount__c":0,"SBQQ__Listprice__c":1000,"SBQQ__SpecialPrice__c":1000,"SBQQ__Quantity__c":2, "Product_Business_Type__c":"Citation","SBQQ__RequiredBy__c":"'+parentQuoteLine.id+'","Initial_Payment__c":0}';
		SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobj1, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine1);

		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{quoteLine1.Id => quoteLine1};

		//QuoteLine Updated with Discount Amount
		quoteLine1.Custom_Discount_Amount__c = 100;

		List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>{quoteLine1};

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newquotelines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(1800, newquotelines[0].initial_payment__c);
	}

	@isTest
	private static void given_QuoteLine_Has_NoQMSProduct_And_ParentQuoteLine_And_Custom_Discount_Percentage_When_QuoteLine_Updated_Then_SetinitialPayment_Excluding_DiscountedPercentage_From_SpecialPrice()
	{
		Product2 ProductRecord = new Product2(Name = 'Product 1');
		TestUtility.setId(ProductRecord);

		Map<Id, Product2> productMap = new Map<Id, Product2>{ProductRecord.Id => ProductRecord};

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}}';
		SBQQ__QuoteLine__c parentQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(parentQuoteLine);

		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"SBQQ__Product__c":"'+ProductRecord.id+'", "Custom_Discount_Percentage__c":0,"SBQQ__Listprice__c":1000,"SBQQ__SpecialPrice__c":1000,"SBQQ__Quantity__c":2, "Product_Business_Type__c":"Citation","SBQQ__RequiredBy__c":"'+parentQuoteLine.id+'","Initial_Payment__c":0}';
		SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobj1, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine1);

		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{quoteLine1.Id => quoteLine1};

		//QuoteLine Updated with Discount Amount
		quoteLine1.Custom_Discount_Percentage__c = 10;

		List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>{quoteLine1};

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newquotelines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(1800, newquotelines[0].initial_payment__c);
	}
	
	@isTest
	private static void given_QuoteLine_Has_NoQMSProduct_And_ParentQuoteLine_And_No_Discount_When_QuoteLine_Updated_Then_SetinitialPayment_From_SpecialPrice()
	{
		Product2 ProductRecord = new Product2(Name = 'Product 1');
		TestUtility.setId(ProductRecord);

		Map<Id, Product2> productMap = new Map<Id, Product2>{ProductRecord.Id => ProductRecord};

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}}';
		SBQQ__QuoteLine__c parentQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(parentQuoteLine);

		//Used JSON String to set the formula field(Product Business Type) on quote line that looks up to a field on quote.
		String jobj1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"SBQQ__Product__c":"'+ProductRecord.id+'", "Custom_Discount_Percentage__c":10,"SBQQ__Listprice__c":1000,"SBQQ__SpecialPrice__c":1000,"SBQQ__Quantity__c":2, "Product_Business_Type__c":"Citation","SBQQ__RequiredBy__c":"'+parentQuoteLine.id+'","Initial_Payment__c":0}';
		SBQQ__QuoteLine__c quoteLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobj1, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine1);

		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{quoteLine1.Id => quoteLine1};

		//QuoteLine Updated with Discount Amount
		quoteLine1.Custom_Discount_Percentage__c = 0;

		List<SBQQ__QuoteLine__c> newquotelines = new List<SBQQ__QuoteLine__c>{quoteLine1};

		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newquotelines, oldQuoteLineMap);
		
 		Test.stopTest();
		
		System.assertEquals(2000, newquotelines[0].initial_payment__c);
	}

	@isTest
	private static void given_ParentQuoteLine_whenGetRelatedLinesCalled_Then_Selector_ReturnsChildLines()
	{
		Id profileId = UserInfo.getProfileId();
		User usr = new User(
				ProfileId = UserInfo.getProfileId(), 
				LastName = 'selectorGetsRelatedQuoteLines', 
				Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk', 
				Username = 'testmnb@test.com' + System.currentTimeMillis(), 
				Alias = 'alias', 
				TimeZoneSidKey = 'America/Los_Angeles', 
				EmailEncodingKey = 'UTF-8', 
				LanguageLocaleKey = 'en_US', 
				LocaleSidKey = 'en_US'
				);
		insert usr;
		
		Account act = new Account(Name = 'CPQ Hogwarts');
		insert act;
		
		Contact cont = new Contact(Lastname = 'CPQHarry', accountid =act.id );
		insert cont;
		
		List<Product2>  prdtoInsertList =  new List<Product2>();
		
		Product2 prd1 = new Product2(name = 'cpq Product1');
		prdtoInsertList.add(prd1);
		
		Product2 prd2 = new Product2(name = 'cpq Product2');
		prdtoInsertList.add(prd2);
		
		Product2 prd3 = new Product2(name = 'cpq Product3');
		prdtoInsertList.add(prd3);
		
		insert prdtoInsertList;
		
		Pricebook2 prb = new Pricebook2(name = 'Product Pricebook');
		insert prb;
		
		list<PricebookEntry> PbentryList = new list<PricebookEntry>();
		
		PricebookEntry spbEntryProduct1 = new 	PricebookEntry(Product2id=prdtoInsertList[0].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct1);
		
		PricebookEntry spbEntryProduct2 = new 	PricebookEntry(Product2id=prdtoInsertList[1].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct2);
		
	 	PricebookEntry spbEntryProduct3 = new 	PricebookEntry(Product2id=prdtoInsertList[2].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct3);
		
		
		insert PbentryList;
		
		SBQQ__Quote__c CPQQuote = new SBQQ__Quote__c(SBQQ__PrimaryContact__c = cont.id, 
													 SBQQ__Account__c = act.Id, 
													 SBQQ__StartDate__c = Date.today()+1, SBQQ__PricebookId__c = prb.id);
		insert CPQQuote;
		
		SBQQ__QuoteLineGroup__c CPQQuoteGroup = new SBQQ__QuoteLineGroup__c(name = 'Group 1', SBQQ__Quote__c = CPQQuote.id);
		insert CPQQuoteGroup;    
		
		List<SBQQ__QuoteLine__c>   QuoteLineList = new List<SBQQ__QuoteLine__c>();
		
		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 1000, SBQQ__SpecialPrice__c = 1000, SBQQ__Product__c = prdtoInsertList[0].id, SBQQ__PricebookEntryId__c = PbentryList[0].id);
		Insert QuoteLine1;
		
		SBQQ__QuoteLine__c childLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 700, SBQQ__SpecialPrice__c = 700, SBQQ__Product__c = prdtoInsertList[1].id, SBQQ__PricebookEntryId__c = PbentryList[1].id, SBQQ__RequiredBy__c = QuoteLine1.id);
		QuoteLineList.add(childLine1);
		SBQQ__QuoteLine__c childLine2= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 400, SBQQ__SpecialPrice__c = 400, SBQQ__Product__c = prdtoInsertList[2].id, SBQQ__PricebookEntryId__c = PbentryList[2].id, SBQQ__RequiredBy__c = QuoteLine1.id);
		QuoteLineList.add(childLine2);
		
		insert QuoteLineList;
		
		Set<ID>	parentID = new Set<ID>();
		parentID.add(QuoteLine1.id);
		
		Test.startTest();
		
		Map<Id, List<SBQQ__QuoteLine__c>> parentandChildLinesMap = new CPQQuoteLineService.CPQQuoteLineServiceSelector().getRelatedQuoteLines(parentID);
		
		Test.stopTest();

		system.assertEquals(1, parentandChildLinesMap.size());
		system.assertEquals(2, parentandChildLinesMap.get(QuoteLine1.id).size());
	}
	
	@isTest
	private static void given_NoParentLine_whenGetRelatedLinesCalled_Then_Selector_ReturnsNoChildLines()
	{
		Id profileId = UserInfo.getProfileId();
		User usr = new User(
				ProfileId = UserInfo.getProfileId(), 
				LastName = 'selectorGetsRelatedQuoteLines', 
				Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk', 
				Username = 'testmnb@test.com' + System.currentTimeMillis(), 
				Alias = 'alias', 
				TimeZoneSidKey = 'America/Los_Angeles', 
				EmailEncodingKey = 'UTF-8', 
				LanguageLocaleKey = 'en_US', 
				LocaleSidKey = 'en_US'
				);
		insert usr;
		
		Account act = new Account(Name = 'CPQ Hogwarts');
		insert act;
		
		Contact cont = new Contact(Lastname = 'CPQHarry', accountid =act.id );
		insert cont;
		
		List<Product2>  prdtoInsertList =  new List<Product2>();
		
		Product2 prd1 = new Product2(name = 'cpq Product1');
		prdtoInsertList.add(prd1);
		
		Product2 prd2 = new Product2(name = 'cpq Product2');
		prdtoInsertList.add(prd2);
		
		Product2 prd3 = new Product2(name = 'cpq Product3');
		prdtoInsertList.add(prd3);
		
		insert prdtoInsertList;
		
		Pricebook2 prb = new Pricebook2(name = 'Product Pricebook');
		insert prb;
		
		list<PricebookEntry> PbentryList = new list<PricebookEntry>();
		
		PricebookEntry spbEntryProduct1 = new 	PricebookEntry(Product2id=prdtoInsertList[0].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct1);
		
		PricebookEntry spbEntryProduct2 = new 	PricebookEntry(Product2id=prdtoInsertList[1].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct2);
		
	 	PricebookEntry spbEntryProduct3 = new 	PricebookEntry(Product2id=prdtoInsertList[2].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct3);
		
		
		insert PbentryList;
		
		SBQQ__Quote__c CPQQuote = new SBQQ__Quote__c(SBQQ__PrimaryContact__c = cont.id, 
													 SBQQ__Account__c = act.Id, 
													 SBQQ__StartDate__c = Date.today()+1, SBQQ__PricebookId__c = prb.id);
		insert CPQQuote;
		
		SBQQ__QuoteLineGroup__c CPQQuoteGroup = new SBQQ__QuoteLineGroup__c(name = 'Group 1', SBQQ__Quote__c = CPQQuote.id);
		insert CPQQuoteGroup;    
		
		List<SBQQ__QuoteLine__c>   QuoteLineList = new List<SBQQ__QuoteLine__c>();
		
		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 1000, SBQQ__SpecialPrice__c = 1000, SBQQ__Product__c = prdtoInsertList[0].id, SBQQ__PricebookEntryId__c = PbentryList[0].id);
		Insert QuoteLine1;
		
		SBQQ__QuoteLine__c childLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 700, SBQQ__SpecialPrice__c = 700, SBQQ__Product__c = prdtoInsertList[1].id, SBQQ__PricebookEntryId__c = PbentryList[1].id, SBQQ__RequiredBy__c = QuoteLine1.id);
		QuoteLineList.add(childLine1);
		SBQQ__QuoteLine__c childLine2= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 400, SBQQ__SpecialPrice__c = 400, SBQQ__Product__c = prdtoInsertList[2].id, SBQQ__PricebookEntryId__c = PbentryList[2].id, SBQQ__RequiredBy__c = QuoteLine1.id);
		QuoteLineList.add(childLine2);
		
		insert QuoteLineList;
		
		SBQQ__QuoteLine__c invalidChildLineID = new SBQQ__QuoteLine__c();
		TestUtility.setId(invalidChildLineID);
		
		Set<ID>	parentID = new Set<ID>();
		parentID.add(invalidChildLineID.id);
		
		Test.startTest();
		
		Map<Id, List<SBQQ__QuoteLine__c>> parentandChildLinesMap = new CPQQuoteLineService.CPQQuoteLineServiceSelector().getRelatedQuoteLines(parentID);
		
		Test.stopTest();
		
		system.assertEquals(0, parentandChildLinesMap.size());
	}

	@isTest
	private static void processRelatedRecordsOnDelete_ChildLineDeleted_RollupCalculation()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3);
		TestUtility.setId(QuoteLine1);
		
		
		Set<ID> parentLineIds = new Set<ID>();
		parentLineIds.add(QuoteLine1.id);
		
		string parentId = '"'+QuoteLine1.id+'"';
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__Quantity__c":90, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__RequiredBy__c":'+parentId+', "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Total_Quote_Line__c":2100}';
		
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
		QuoteLinesMap.put(QuoteLine1.id, new List<SBQQ__QuoteLine__c>{childLine1});
		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__Quantity__c":90, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__RequiredBy__c":'+parentId+', "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Total_Quote_Line__c":1200}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		QuoteLinesMap.get(QuoteLine1.id).add(childLine2);
		
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		MockSelector selector = new MockSelector();
		selector.parentChildLinesMap = QuoteLinesMap;		
		
		Test.startTest();
		
		new CPQQuoteLineService(selector).rollUpAmountToParentLine(parentLineIds);
		
		Test.stopTest();
		
		List<SBQQ__QuoteLine__c>  updatedParentRecords = (uow.getRecords(SBQQ__QuoteLine__c.SObjectType));
		system.assertEquals(3300, updatedParentRecords[0].Sub_Line_Total__c);
	}
	
	@isTest
	private static void given_Parent_And_Child_QuoteLine_When_ChildQuoteLine_Deleted_Then_MakeFutureCall()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3);
		TestUtility.setId(QuoteLine1);
		
		
		Set<ID> parentLineIds = new Set<ID>();
		parentLineIds.add(QuoteLine1.id); 
		
		string parentId = '"'+QuoteLine1.id+'"';
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__Quantity__c":90, "SBQQ__ListPrice__c":700, "SBQQ__RequiredBy__c":'+parentId+', "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Total_Quote_Line__c":2100}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__Quantity__c":90, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__RequiredBy__c":'+parentId+', "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Total_Quote_Line__c":1200}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		QuoteLinesMap.put(QuoteLine1.id, new List<SBQQ__QuoteLine__c>{childLine2});
		
		List<SBQQ__QuoteLine__c>   deletedLine = new List<SBQQ__QuoteLine__c>();
		deletedLine.add(childLine1);
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		MockSelector selector = new MockSelector();
		selector.parentChildLinesMap = QuoteLinesMap;
		
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnDelete(deletedLine);
		system.assertEquals(1, Limits.getFutureCalls());
		
		Test.stopTest();
	}
	
	@isTest
	private static void given_ChildQuoteLine_Without_ParentQuoteLine_When_ChildQuoteLine_Deleted_Then_DonotMakeFutureCall()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__Quantity__c":90, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Total_Quote_Line__c":2100}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__Quantity__c":90, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Total_Quote_Line__c":1200}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		QuoteLinesMap.put(QuoteLine1.id, new List<SBQQ__QuoteLine__c>{childLine2});
		
		List<SBQQ__QuoteLine__c>   deletedLine = new List<SBQQ__QuoteLine__c>();
		deletedLine.add(childLine1);
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		MockSelector selector = new MockSelector();
		selector.parentChildLinesMap = QuoteLinesMap;		
		
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnDelete(deletedLine);
		system.assertEquals(0, Limits.getFutureCalls());
		
		Test.stopTest();

	}
	
	@isTest
	private static void given_productOnQuoteLineIsChanged_when_quoteLineHasInvalidCPQProd_then_setFieldOnQuoteToTrue()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
				
		List<Product2> productList = new List<Product2>{
			new Product2(Name = 'Product 1'),
			new Product2(Name = 'Product 2')
		};
		TestUtility.setIds(productList);
	
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true}';
		SBQQ__QuoteLine__c oldQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		oldQuoteLine.SBQQ__Quote__c = testQuote.Id;
		oldquoteLine.SBQQ__Product__c = productList[0].Id;
		TestUtility.setId(oldquoteLine);
		Map<Id,SBQQ__QuoteLine__c> oldQlMap = new Map<Id,SBQQ__QuoteLine__c>{oldquoteLine.Id => oldquoteLine};

		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		newQuoteLine.SBQQ__Quote__c = testQuote.Id;
		newQuoteLine.SBQQ__Product__c = productList[1].Id;
		newQuoteLine.Id = oldquoteLine.id;
		List<SBQQ__QuoteLine__c> newQlList = new List<SBQQ__QuoteLine__c>{newQuoteLine};

		String jobj2 = '{"attributes":{"type":"SBQQ__Quote__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__LineItems__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"},{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"}]}}';
		testQuote = (SBQQ__Quote__c)JSON.deserialize(jobj2,SBQQ__Quote__c.class);
		TestUtility.setId(testQuote);
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{testQuote};
			
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.quotesToUpdate = quoteList;
			
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnChange(newQlList, oldQlMap);

		Test.stopTest();
		
		list<SBQQ__Quote__c> updatedQuoteList = uow.getRecords(SBQQ__Quote__c.SObjectType);
		System.assertEquals(1, updatedQuoteList.size());
		System.assertEquals(true, updatedQuoteList[0].Invalid_CPQ_Product__c, 'Quote not updated');

	}
	
	@isTest
	private static void given_productOnQuoteLineIsChanged_when_quoteLineHasValidCPQProd_Then_setFieldOnQuoteToFalse()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		
		List<Product2> productList = new List<Product2>{
			new Product2(Name = 'Product 1'),
			new Product2(Name = 'Product 2')
		};
		TestUtility.setIds(productList);

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false}';
		SBQQ__QuoteLine__c oldQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		oldQuoteLine.SBQQ__Quote__c = testQuote.Id;
		oldquoteLine.SBQQ__Product__c = productList[0].Id;
		TestUtility.setId(oldquoteLine);
		Map<Id,SBQQ__QuoteLine__c> oldQlMap = new Map<Id,SBQQ__QuoteLine__c>{oldquoteLine.Id => oldquoteLine};

		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		newQuoteLine.SBQQ__Quote__c = testQuote.Id;
		newQuoteLine.Id = oldquoteLine.Id;
		newQuoteLine.SBQQ__Product__c = productList[1].Id;
		List<SBQQ__QuoteLine__c> newQlList = new List<SBQQ__QuoteLine__c>{newQuoteLine};

		String jobj2 = '{"attributes":{"type":"SBQQ__Quote__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP","SBQQ__LineItems__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"},{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"}]}}';
		testQuote = (SBQQ__Quote__c)JSON.deserialize(jobj2,SBQQ__Quote__c.class);
		TestUtility.setId(testQuote);
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{testQuote};
			
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.quotesToUpdate = quoteList;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnChange(newQlList, oldQlMap);

		Test.stopTest();
		
		List<SBQQ__Quote__c> updatedQuoteList = uow.getRecords(SBQQ__Quote__c.SObjectType);
		System.assertEquals(1, updatedQuoteList.size());
		System.assertEquals(false, updatedQuoteList[0].Invalid_CPQ_Product__c, 'Quote not updated');

	}
	@isTest
	private static void given_quoteLineIsDeleted_when_quoteHasNoQuoteLine_then_ensureFieldOnQuoteIsFalse()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		
		Product2 prod1 = new Product2(Name = 'Test Prod');
		TestUtility.setId(prod1);

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true}';
		SBQQ__QuoteLine__c deletedQl = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		deletedQl.SBQQ__Quote__c = testQuote.Id;
		deletedQl.SBQQ__Product__c = prod1.Id;
		List<SBQQ__QuoteLine__c> deletedQuoteLineList = new List<SBQQ__QuoteLine__c>{deletedQl};

		String jobj3 = '{"attributes":{"type":"SBQQ__Quote__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP"}';
		testQuote = (SBQQ__Quote__c)JSON.deserialize(jobj3,SBQQ__Quote__c.class);
		TestUtility.setId(testQuote);
		
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{testQuote};
			
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.quotesToUpdate = quoteList;
			
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnDelete(deletedQuoteLineList);

		Test.stopTest();
		
		List<SBQQ__Quote__c> updatedQuoteList  = uow.getRecords(SBQQ__Quote__c.SObjectType);
		System.assertEquals(1, updatedQuoteList.size());
		System.assertEquals(false, updatedQuoteList[0].Invalid_CPQ_Product__c, 'Quote not updated');

	}
	@isTest
	private static void given_quoteLineIsDeleted_when_invalidCPQQuoteLineIsDeleted_then_setFieldOnQuoteToFalse()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		
		Product2 prod1 = new Product2(Name = 'Test Prod');
		TestUtility.setId(prod1);

		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true}';
		SBQQ__QuoteLine__c deletedQl = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		deletedQl.SBQQ__Quote__c = testQuote.Id;
		deletedQl.SBQQ__Product__c = prod1.Id;
		List<SBQQ__QuoteLine__c> deletedQuoteLineList = new List<SBQQ__QuoteLine__c>{deletedQl};
			
		String jobj2 = '{"attributes":{"type":"SBQQ__Quote__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP","SBQQ__LineItems__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"},{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"}]}}';
		testQuote = (SBQQ__Quote__c)JSON.deserialize(jobj2,SBQQ__Quote__c.class);
		TestUtility.setId(testQuote);
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{testQuote};
			
	   	MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.quotesToUpdate = quoteList;
			
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnDelete(deletedQuoteLineList);

		Test.stopTest(); 
		
		List<SBQQ__Quote__c> updatedQuoteList = uow.getRecords(SBQQ__Quote__c.SObjectType);
		System.assertEquals(1, updatedQuoteList.size());
		System.assertEquals(false, updatedQuoteList[0].Invalid_CPQ_Product__c, 'Quote not updated');
	}
	
	@isTest
	private static void given_quoteLineIsInserted_when_productOnQuoteLineIsInvalidCPQProduct_then_setFieldOnQuoteToTrue()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		
		Product2 prod1 = new Product2(Name = 'Test Prod');
		TestUtility.setId(prod1);
	
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		newQuoteLine.SBQQ__Quote__c = testQuote.Id;
		newQuoteLine.SBQQ__Product__c = prod1.Id;
		List<SBQQ__QuoteLine__c> newQlList = new List<SBQQ__QuoteLine__c>{newQuoteLine};

		String jobj2 = '{"attributes":{"type":"SBQQ__Quote__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__LineItems__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"},{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"}]}}';
		testQuote = (SBQQ__Quote__c)JSON.deserialize(jobj2,SBQQ__Quote__c.class);
		TestUtility.setId(testQuote);
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{testQuote};
			
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.quotesToUpdate = quoteList;
			
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnNew(newQlList);

		Test.stopTest();

		List<SBQQ__Quote__c> updatedQuoteList = uow.getRecords(SBQQ__Quote__c.SObjectType);
		System.assertEquals(1, updatedQuoteList.size());
		System.assertEquals(true, updatedQuoteList[0].Invalid_CPQ_Product__c, 'Quote not updated');
	}

	@isTest
	private static void given_invalidCPQProductOnQuoteIsTrue_when_invalidCPQQLineIsInserted_then_quoteShouldNotUpdate()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		String jobj2 = '{"attributes":{"type":"SBQQ__Quote__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP","SBQQ__LineItems__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"},{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":false,"CurrencyIsoCode":"GBP","SBQQ__Quote__c":"'+testQuote.Id+'"}]}}';
		testQuote = (SBQQ__Quote__c)JSON.deserialize(jobj2,SBQQ__Quote__c.class);
		TestUtility.setId(testQuote);
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{testQuote};
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"},"Invalid_CPQ_Product__c":true}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj,SBQQ__QuoteLine__c.class);
		newQuoteLine.SBQQ__Quote__c = testQuote.Id;
		List<SBQQ__QuoteLine__c> newQlList = new List<SBQQ__QuoteLine__c>{newQuoteLine};
			
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);

		MockSelector selector = new MockSelector();
		selector.quotesToUpdate = quoteList;
			
		Test.startTest();
		
		new CPQQuoteLineService(selector).processRelatedRecordsOnNew(newQlList);

		Test.stopTest();

		List<SBQQ__Quote__c> updatedQuoteList = uow.getRecords(SBQQ__Quote__c.SObjectType);
		System.assertEquals(0, updatedQuoteList.size());
	}
	
	@isTest
	private static void given_quoteIds_when_GetQuotesIsCalled_then_selectorReturnListOfQuote_With_QuoteLines()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
		insert testQuote;
		Set<id> quoteIds = new Set<Id>{testQuote.Id};
			
		Product2 testProd = new Product2();
		testProd.Name = 'Test Product';
		testProd.ProductCode = 'CB1' ;
		insert testProd;
		
		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Product__c = testProd.Id;
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.sbqq__specialprice__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.billing_Frequency__c = 'Monthly' ;
		insert quoteLine;
				
		CPQQuoteLineService.CPQQuoteLineServiceSelector selector = new CPQQuoteLineService.CPQQuoteLineServiceSelector();
		List<SBQQ__Quote__c> quoteList = selector.getQuotesToUpdate(quoteIds);
		
		System.assertEquals(1, quoteList.size(), 'Query result incorrect');
		System.assertEquals(1, quoteList[0].SBQQ__LineItems__r.size(), 'Query result is incorrect');
	}
	
	@isTest
	private static void given_QuoteLineHasQuoteAndGroupIsNull_When_QuoteLine_Inserted_Then_GroupInserted_And_AssingedTo_Line()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);
		
		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.Sum_of_Children_Price_Per_Billing__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.sbqq__specialprice__c = 0 ;
		quoteline.SBQQ__Product__c = Product1.Id;
		quoteline.Sub_Line_Total__c = 1200;
		quoteline.SBQQ__SubscriptionTerm__c = 12;
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteline};
		
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow); 
		
		Map<ID, Product2> productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertNotEquals(null, quoteline.SBQQ__Group__c);
	}

	@isTest
	private static void given_QuoteLineHasQuoteAndGroupIsNull_When_QuoteLine_Updated_Then_GroupInserted_And_AssingedTo_Line()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);
		
		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.Sum_of_Children_Price_Per_Billing__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.sbqq__specialprice__c = 0 ;
		quoteline.SBQQ__Product__c = Product1.Id;
		quoteline.Sub_Line_Total__c = 1200;
		quoteline.SBQQ__SubscriptionTerm__c = 12;
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteline};
		
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow); 

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
 		Test.stopTest();
		
		System.assertNotEquals(null, quoteline.SBQQ__Group__c);
	}

	@isTest
	private static void given_QuoteLineHasQuoteAndGroupIsNotNull_When_QuoteLine_Inserted_Then_GroupNotInserted_And_NotAssingedTo_Line()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

			
		SBQQ__QuoteLineGroup__c	lineItemGroup = new SBQQ__QuoteLineGroup__c();
		lineItemGroup.SBQQ__Quote__c = testQuote.id;
		lineItemGroup.name = 'Test Group1';
		TestUtility.setId(lineItemGroup);
		
		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.Sum_of_Children_Price_Per_Billing__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.sbqq__specialprice__c = 0 ;
		quoteline.SBQQ__Product__c = Product1.Id;
		quoteline.Sub_Line_Total__c = 1200;
		quoteline.SBQQ__SubscriptionTerm__c = 12;
		quoteline.SBQQ__Group__c = lineItemGroup.id;

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteline};
		
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow); 
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals(0, uow.getRecords(SBQQ__QuoteLineGroup__c.SObjectType).size());
	}

	@isTest
	private static void given_QuoteLineHasQuoteAndGroupIsNotNull_When_QuoteLine_Updated_Then_GroupNotInserted_And_NotAssingedNotTo_Line()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

			
		SBQQ__QuoteLineGroup__c	lineItemGroup = new SBQQ__QuoteLineGroup__c();
		lineItemGroup.SBQQ__Quote__c = testQuote.id;
		lineItemGroup.name = 'Test Group1';
		TestUtility.setId(lineItemGroup);
		
		SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
		quoteLine.SBQQ__Quote__c = testQuote.Id;
		quoteline.Sum_of_Children_Price_Per_Billing__c = 90 ;
		quoteline.sbqq__quantity__c = 1 ;
		quoteline.sbqq__specialprice__c = 0 ;
		quoteline.SBQQ__Product__c = Product1.Id;
		quoteline.Sub_Line_Total__c = 1200;
		quoteline.SBQQ__SubscriptionTerm__c = 12;
		quoteline.SBQQ__Group__c = lineItemGroup.id;

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteline};
		
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow); 
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
 		Test.stopTest();
		
		System.assertEquals(0, uow.getRecords(SBQQ__QuoteLineGroup__c.SObjectType).size());
	}
	
	@isTest
	private static void given_QuoteLine_WithProducts_And_BillingFrequency_Is_Null_And_QuotePriceBook_Not_QMS_When_QuoteLineInserted_Then_Selector_Returns_Products()
	{
		Id profileId = UserInfo.getProfileId();
		User usr = new User(
				ProfileId = UserInfo.getProfileId(), 
				LastName = 'selectorGetsRelatedQuoteLines', 
				Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk', 
				Username = 'testmnb@test.com' + System.currentTimeMillis(), 
				Alias = 'alias', 
				TimeZoneSidKey = 'America/Los_Angeles', 
				EmailEncodingKey = 'UTF-8', 
				LanguageLocaleKey = 'en_US', 
				LocaleSidKey = 'en_US'
				);
		insert usr;
		
		Account act = new Account(Name = 'CPQ Hogwarts');
		insert act;
		
		Contact cont = new Contact(Lastname = 'CPQHarry', accountid =act.id );
		insert cont;
		
		List<Product2>  prdtoInsertList =  new List<Product2>();
		
		Product2 prd1 = new Product2(name = 'cpq Product1');
		prdtoInsertList.add(prd1);
		
		Product2 prd2 = new Product2(name = 'cpq Product2');
		prdtoInsertList.add(prd2);
		
		Product2 prd3 = new Product2(name = 'cpq Product3');
		prdtoInsertList.add(prd3);
		
		insert prdtoInsertList;
		
		Pricebook2 prb = new Pricebook2(name = 'Product Pricebook');
		insert prb;
		
		list<PricebookEntry> PbentryList = new list<PricebookEntry>();
		
		PricebookEntry spbEntryProduct1 = new 	PricebookEntry(Product2id=prdtoInsertList[0].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct1);
		
		PricebookEntry spbEntryProduct2 = new 	PricebookEntry(Product2id=prdtoInsertList[1].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct2);
		
	 	PricebookEntry spbEntryProduct3 = new 	PricebookEntry(Product2id=prdtoInsertList[2].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct3);
		
		
		insert PbentryList;
		
		SBQQ__Quote__c CPQQuote = new SBQQ__Quote__c(SBQQ__PrimaryContact__c = cont.id, 
													 SBQQ__Account__c = act.Id, 
													 SBQQ__StartDate__c = Date.today()+1, SBQQ__PricebookId__c = prb.id);
		insert CPQQuote;
		
		SBQQ__QuoteLineGroup__c CPQQuoteGroup = new SBQQ__QuoteLineGroup__c(name = 'Group 1', SBQQ__Quote__c = CPQQuote.id);
		insert CPQQuoteGroup;    
		
		List<SBQQ__QuoteLine__c>   QuoteLineList = new List<SBQQ__QuoteLine__c>();
		
		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 1000, SBQQ__SpecialPrice__c = 1000, SBQQ__Product__c = prdtoInsertList[0].id, SBQQ__PricebookEntryId__c = PbentryList[0].id, Billing_Frequency__c = null);
		Insert QuoteLine1;
		
		SBQQ__QuoteLine__c childLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 700, SBQQ__SpecialPrice__c = 700, SBQQ__Product__c = prdtoInsertList[1].id, SBQQ__PricebookEntryId__c = PbentryList[1].id, SBQQ__RequiredBy__c = QuoteLine1.id, Billing_Frequency__c = null);
		QuoteLineList.add(childLine1);
		SBQQ__QuoteLine__c childLine2 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 400, SBQQ__SpecialPrice__c = 400, SBQQ__Product__c = prdtoInsertList[2].id, SBQQ__PricebookEntryId__c = PbentryList[2].id, SBQQ__RequiredBy__c = QuoteLine1.id, Billing_Frequency__c = null);
		QuoteLineList.add(childLine2);
		
		insert QuoteLineList;
		
		Test.startTest();
		
		Map<ID, Product2> QuoteLineProducts = new CPQQuoteLineService.CPQQuoteLineServiceSelector().getProducts(QuoteLineList);
		
		Test.stopTest();
		
		system.assertEquals(2, QuoteLineProducts.size());
	}	

    @isTest
	private static void given_QuoteLine_WithProducts_And_BillingFrequency_IsNot_Null_When_QuoteLineInserted_Then_Selector_Returns_No_Products()
	{
		Id profileId = UserInfo.getProfileId();
		User usr = new User(
				ProfileId = UserInfo.getProfileId(), 
				LastName = 'selectorGetsRelatedQuoteLines', 
				Email = System.currentTimeMillis() + 'usercreatetest@citation.co.uk', 
				Username = 'testmnb@test.com' + System.currentTimeMillis(), 
				Alias = 'alias', 
				TimeZoneSidKey = 'America/Los_Angeles', 
				EmailEncodingKey = 'UTF-8', 
				LanguageLocaleKey = 'en_US', 
				LocaleSidKey = 'en_US'
				);
		insert usr;
		
		Account act = new Account(Name = 'CPQ Hogwarts');
		insert act;
		
		Contact cont = new Contact(Lastname = 'CPQHarry', accountid =act.id );
		insert cont;
		
		List<Product2>  prdtoInsertList =  new List<Product2>();
		
		Product2 prd1 = new Product2(name = 'cpq Product1');
		prdtoInsertList.add(prd1);
		
		Product2 prd2 = new Product2(name = 'cpq Product2');
		prdtoInsertList.add(prd2);
		
		Product2 prd3 = new Product2(name = 'cpq Product3');
		prdtoInsertList.add(prd3);
		
		insert prdtoInsertList;
		
		Pricebook2 prb = new Pricebook2(name = 'Product Pricebook');
		insert prb;
		
		list<PricebookEntry> PbentryList = new list<PricebookEntry>();
		
		PricebookEntry spbEntryProduct1 = new 	PricebookEntry(Product2id=prdtoInsertList[0].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct1);
		
		PricebookEntry spbEntryProduct2 = new 	PricebookEntry(Product2id=prdtoInsertList[1].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct2);
		
	 	PricebookEntry spbEntryProduct3 = new 	PricebookEntry(Product2id=prdtoInsertList[2].id, pricebook2id = Test.getStandardPricebookId(), UnitPrice = 100);
		PbentryList.add(spbEntryProduct3);
		
		
		insert PbentryList;
		
		SBQQ__Quote__c CPQQuote = new SBQQ__Quote__c(SBQQ__PrimaryContact__c = cont.id, 
													 SBQQ__Account__c = act.Id, 
													 SBQQ__StartDate__c = Date.today()+1, SBQQ__PricebookId__c = prb.id);
		insert CPQQuote;
		
		SBQQ__QuoteLineGroup__c CPQQuoteGroup = new SBQQ__QuoteLineGroup__c(name = 'Group 1', SBQQ__Quote__c = CPQQuote.id);
		insert CPQQuoteGroup;    
		
		List<SBQQ__QuoteLine__c>   QuoteLineList = new List<SBQQ__QuoteLine__c>();
		
		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 1000, SBQQ__SpecialPrice__c = 1000, SBQQ__Product__c = prdtoInsertList[0].id, SBQQ__PricebookEntryId__c = PbentryList[0].id, Billing_Frequency__c = 'Monthly');
		Insert QuoteLine1;
		
		SBQQ__QuoteLine__c childLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 700, SBQQ__SpecialPrice__c = 700, SBQQ__Product__c = prdtoInsertList[1].id, SBQQ__PricebookEntryId__c = PbentryList[1].id, SBQQ__RequiredBy__c = QuoteLine1.id, Billing_Frequency__c = 'Monthly');
		QuoteLineList.add(childLine1);
		SBQQ__QuoteLine__c childLine2 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__Quote__c = CPQQuote.id, SBQQ__ListPrice__c = 400, SBQQ__SpecialPrice__c = 400, SBQQ__Product__c = prdtoInsertList[2].id, SBQQ__PricebookEntryId__c = PbentryList[2].id, SBQQ__RequiredBy__c = QuoteLine1.id, Billing_Frequency__c = 'Monthly');
		QuoteLineList.add(childLine2);
		
		insert QuoteLineList;
		
		Test.startTest();
		
		Map<ID, Product2> QuoteLineProducts = new CPQQuoteLineService.CPQQuoteLineServiceSelector().getProducts(QuoteLineList);
		
		Test.stopTest();
		
		system.assertEquals(0, QuoteLineProducts.size());
	}
    
	@isTest
	private static void given_QuoteLineHasQMSProduct_And_ParentOn_Not_QMSPriceBook_When_QuotelineInserted_Then_SpecialPriceShouldChange()
	{

		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
				
		new CPQQuoteLineService(selector).setDefaults(quoteLines);
		
		Test.stopTest();	

		system.assertEquals(quoteLines[1].Price_per_Billing_Frequency__c, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(quoteLines[2].Price_per_Billing_Frequency__c, quoteLines[1].SBQQ__SpecialPrice__c);
	}

	@isTest
	private static void given_QuoteLineNotHavingQMSProduct_And_ParentOn_Not_QMSPriceBook_When_QuotelineInserted_Then_SpecialPriceShouldChange_To_LineListPrice()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2> productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
	
		Test.startTest();
				
		new CPQQuoteLineService(selector).setDefaults(quoteLines);
		
		Test.stopTest();	

		system.assertEquals(quoteLines[1].SBQQ__ListPrice__c, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(quoteLines[2].SBQQ__ListPrice__c, quoteLines[2].SBQQ__SpecialPrice__c);
	}

	private static void given_QuoteLineHasQMSProduct_And_NotParentOn_Not_QMSPriceBook_When_QuotelineInserted_Then_SpecialPriceShouldChange_To_LineListPrice()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;		

		Test.startTest();
				
		new CPQQuoteLineService(selector).setDefaults(quoteLines);
		
		Test.stopTest();	

		system.assertEquals(quoteLines[1].SBQQ__ListPrice__c, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(quoteLines[2].SBQQ__ListPrice__c, quoteLines[2].SBQQ__SpecialPrice__c);
	}

	private static void given_QuoteLineHasQMSProduct_And_ParentOn_Not_QMSPriceBook_When_QuotelineUpdated_Then_SpecialPriceShouldChange()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		
		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
				
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
		Test.stopTest();	

		system.assertEquals(quoteLines[1].SBQQ__ListPrice__c, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(quoteLines[2].SBQQ__ListPrice__c, quoteLines[2].SBQQ__SpecialPrice__c);
	}

	private static void given_QuoteLineNotHavingQMSProduct_And_ParentOn_Not_QMSPriceBook_When_QuotelineUpdated_Then_SpecialPriceShouldChange_To_LineListPrice()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"'+QuoteLine1.id+'", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
				
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
		Test.stopTest();	

		system.assertEquals(quoteLines[1].SBQQ__ListPrice__c, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(quoteLines[2].SBQQ__ListPrice__c, quoteLines[2].SBQQ__SpecialPrice__c);
	}

	private static void given_QuoteLineHasQMSProduct_And_NotParentOn_Not_QMSPriceBook_When_QuotelineUpdated_Then_SpecialPriceShouldChange_To_LineListPrice()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2 = (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
				
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
		Test.stopTest();	

		system.assertEquals(quoteLines[1].SBQQ__ListPrice__c, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(quoteLines[2].SBQQ__ListPrice__c, quoteLines[2].SBQQ__SpecialPrice__c);		
	}

	private static void given_QuoteLineHasQMSProduct_And_NotParentOn_QMSPriceBook_When_QuotelineUpdated_Then_SpecialPriceShouldNotChange()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__SpecialPrice__c":0, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__SpecialPrice__c":0, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"QMS", "SBQQ__RequiredBy__c":"", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		

		Test.startTest();
				
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
		Test.stopTest();	

		system.assertEquals(0, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(0, quoteLines[2].SBQQ__SpecialPrice__c);
	}

	private static void given_QuoteLineNotHavingQMSProduct_And_NotParentOn_QMSPriceBook_When_QuotelineUpdated_Then_SpecialPriceShouldChangeNotChange()
	{
		Map<ID, List<SBQQ__QuoteLine__c>>   QuoteLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();
		
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Product2 Product2 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product2);

		Product2 Product3 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product3);

		SBQQ__QuoteLine__c QuoteLine1= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine1);
		
		String jobjChild1 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":700, "SBQQ__SpecialPrice__c":0, "SBQQ__CustomerPrice__c":2100, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"", "SBQQ__Product__c":"'+product2.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';
		SBQQ__QuoteLine__c childLine1= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild1, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine1);
	   		
		String jobjChild2 = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__ListPrice__c":400, "SBQQ__SpecialPrice__c":0, "SBQQ__CustomerPrice__c":1200, "SBQQ__SubscriptionTerm__c":36, "SBQQ__DefaultSubscriptionTerm__c":3, "Product_Business_Type__c":"Citation", "SBQQ__RequiredBy__c":"", "SBQQ__Product__c":"'+product3.id+'", "SBQQ__Quantity__c":90, "Price_per_Billing_Frequency__c" : 250}';        
		SBQQ__QuoteLine__c childLine2= (SBQQ__QuoteLine__c)JSON.deserialize(jobjChild2, SBQQ__QuoteLine__c.Class);
		TestUtility.setID(childLine2);
		
		
		List<SBQQ__QuoteLine__c>   quoteLines = new List<SBQQ__QuoteLine__c>();
		quoteLines.add(QuoteLine1);
		quoteLines.add(childLine1);
		quoteLines.add(childLine2);

		// prevent database stuff, capture records.
		MockUOW uow = new MockUOW();
		UnitOfWork.setInstance(uow);
		
		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		productMap.put(Product2.id, Product2);
		productMap.put(Product3.id, Product3);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;
		
		Test.startTest();
				
		new CPQQuoteLineService(selector).processChangedValues(quotelines, null);
		
		Test.stopTest();	

		system.assertEquals(0, quoteLines[1].SBQQ__SpecialPrice__c);
		system.assertEquals(0, quoteLines[2].SBQQ__SpecialPrice__c);
	}

	@isTest
	private static void given_QuoteLine_HasQMSPriceBook_When_LineInserted_SpecialPriceTyeValueIsSet()
	{
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"QMS CPQ"}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};

		MockSelector selector = new MockSelector();
		
		Test.startTest();		
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertNotEquals('Custom Script', quoteLine.SBQQ__SpecialPriceType__c);
	}

	@isTest
	private static void given_QuoteLine_HasQMSPriceBook_When_LineUpdated_SpecialPriceTyeValueIsSet()
	{
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"QMS CPQ"}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertNotEquals('Custom Script', quoteLine.SBQQ__SpecialPriceType__c);	
	}

	@isTest
	private static void given_QuoteLine_NotQMSPriceBook_When_LineInserted_SpecialPriceTyeValueIsNotSet()
	{
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation"}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);
	
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);
		
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Custom', quoteLine.SBQQ__SpecialPriceType__c);	
	}

	@isTest
	private static void given_QuoteLine_NotQMSPriceBook_When_LineUpdated_SpecialPriceTyeValueIsNotSet()
	{
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation"}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals('Custom', quoteLine.SBQQ__SpecialPriceType__c);	
	}

	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFreqNull_When_LineInserted_Then_BilingFreqIsSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		SBQQ__QuoteLine__c QuoteLine= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();		

		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Monthly', quoteLine.billing_Frequency__c);	
		System.assertEquals('Monthly', quoteLine.sbqq__BillingFrequency__c);	
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFreqNotNull_When_LineInserted_Then_BilingFreqIsSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		SBQQ__QuoteLine__c QuoteLine= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id, billing_Frequency__c='Annual');
		TestUtility.setId(QuoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals(quoteLine.billing_Frequency__c, quoteLine.sbqq__BillingFrequency__c);	
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsMonthly_And_RegularAndInititalPayments_Are_Different_When_LineInserted_Then_BillingfieldsAreSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Monthly", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4200}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Variable', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsAnnual_And_RegularAndInititalPayments_Are_Different_When_LineInserted_Then_BillingfieldsAreSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Annual Frequency', SBQQ__BillingFrequency__c = 'Annual');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Annual", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4200}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Variable', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsOneOff_When_LineInserted_Then_BillingfieldsAreSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 one-Off', SBQQ__BillingFrequency__c = 'One-Off');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"One-Off", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4200}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);
		
		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('One Off', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsMonthly_And_RegularAndInititalPayments_Are_Same_When_LineInserted_Then_BillingfieldsAreSetToDifferentValue()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Monthly", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4000}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap= productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Fixed', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsAnnual_And_RegularAndInititalPayments_Are_Same_When_LineInserted_Then_BillingfieldsAreSetToDifferentValue()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Annual Frequency', SBQQ__BillingFrequency__c = 'Annual');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Annual", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4000}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Fixed', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsOneOff_When_LineUpdated_Then_BillingfieldsAreSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 one-Off', SBQQ__BillingFrequency__c = 'One-Off');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"One-Off", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4200}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals('One Off', quoteLine.FF_Billing_Type__c);
	}

	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFreqNull_When_LineUpdated_Then_BilingFreqIsSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		SBQQ__QuoteLine__c QuoteLine= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id);
		TestUtility.setId(QuoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals('Monthly', quoteLine.billing_Frequency__c);	
		System.assertEquals('Monthly', quoteLine.sbqq__BillingFrequency__c);	
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFreqNotNull_When_LineUpdated_Then_BilingFreqIsSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		SBQQ__QuoteLine__c QuoteLine= new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, Sub_Line_Total__c = 0, SBQQ__DefaultSubscriptionTerm__c = 3, SBQQ__Product__c = Product1.id, billing_Frequency__c='Annual');
		TestUtility.setId(QuoteLine);

		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(quotelines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertNotEquals('Monthly', quoteLine.billing_Frequency__c);	
		System.assertEquals('Annual', quoteLine.billing_Frequency__c);	
		System.assertEquals(quoteLine.billing_Frequency__c, quoteLine.sbqq__BillingFrequency__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsMonthly_And_RegularAndInititalPayments_Are_Different_When_LineUpdated_Then_BillingfieldsAreSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Monthly", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4200}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Variable', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsAnnual_And_RegularAndInititalPayments_Are_Different_When_LineUpdated_Then_BillingfieldsAreSet()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Annual Frequency', SBQQ__BillingFrequency__c = 'Annual');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Annual", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4200}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Variable', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsMonthly_And_RegularAndInititalPayments_Are_Same_When_LineUpdated_Then_BillingfieldsAreSetToDifferentValue()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Monthly Frequency', SBQQ__BillingFrequency__c = 'Monthly');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Monthly", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4000}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Fixed', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineisNotQMSPriceBook_And_BillingFrequencyIsAnnual_And_RegularAndInititalPayments_Are_Same_When_LineUpdated_Then_BillingfieldsAreSetToDifferentValue()
	{
		Product2 Product1 = new Product2(Name = 'Product 1 Annual Frequency', SBQQ__BillingFrequency__c = 'Annual');
		TestUtility.setId(Product1);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "SBQQ__SpecialPriceType__c":"Non Custom", "Quote_Price_book__c":"Default Citation", "billing_Frequency__c":"Annual", "SBQQ__Product__c":"'+product1.id+'", "Regular_Payment__c":4000, "Initial_Payment__c":4000}';
		SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(quoteLine);

		Map<ID, Product2>   productMap = new Map<ID, Product2>();
		productMap.put(Product1.id, Product1);
		
		List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>{quoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(quotelines);

		MockSelector selector = new MockSelector();
		selector.productMap = productMap;

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(quotelines);
		
 		Test.stopTest();
		
		System.assertEquals('Recurring Fixed', quoteLine.FF_Billing_Type__c);
	}
	
	@isTest
	private static void given_QuoteLineIsQMSBusinessType_And_GroupTerm_And_SubscriptionTerm_Are_Different_When_QuoteLineInserted_Then_SubscriptionTermIsSet()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Group_Term__c":36, "sbqq__SubscriptionTerm__c":24}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(newQuoteLines);
		
 		Test.stopTest();
		
		System.assertEquals(newQuoteLines[0].Group_Term__c, newQuoteLines[0].sbqq__SubscriptionTerm__c);
	}

	@isTest
	private static void given_QuoteLineIsQMSBusinessType_And_GroupTerm_And_SubscriptionTerm_Are_Same_When_QuoteLineInserted_Then_SubscriptionTermIsNotUpdated()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Group_Term__c":24, "sbqq__SubscriptionTerm__c":24}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).setDefaults(newQuoteLines);
		
 		Test.stopTest();
		
		System.assertEquals(24, newQuoteLines[0].sbqq__SubscriptionTerm__c);
	}

	@isTest
	private static void given_QuoteLineIsQMSBusinessType_And_GroupTerm_And_SubscriptionTerm_Are_Different_When_QuoteLine_Updated_Then_SubscriptionTermIsSet()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Group_Term__c":36, "sbqq__SubscriptionTerm__c":24}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(newQuoteLines);
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals(newQuoteLines[0].Group_Term__c, newQuoteLines[0].sbqq__SubscriptionTerm__c);
	}

	@isTest
	private static void given_QuoteLineIsQMSBusinessType_And_GroupTerm_And_SubscriptionTerm_Are_Same_When_QuoteLine_Updated_Then_SubscriptionTermIsNotUpdated()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Group_Term__c":24, "sbqq__SubscriptionTerm__c":24}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(newQuoteLines);
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals(24, newQuoteLines[0].sbqq__SubscriptionTerm__c);
	}

	@isTest
	private static void given_QuoteLine_PriceBook_isNotQMSCPQ_When_QuoteLineInserted_Then_SetTheEndDate_With_ServiceEndDate()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Service_End_Date__c":"2025-11-16"}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(newQuoteLines);
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals(newQuoteLines[0].Service_End_Date__c, newQuoteLines[0].SBQQ__EndDate__c);
	}

	@isTest
	private static void given_QuoteLine_PriceBook_isNotQMSCPQ_When_QuoteLine_Updated_Then_UpdateTheEndDate_With_ServiceEndDate()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Service_End_Date__c":"2025-11-16"}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(newQuoteLines);
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertEquals(newQuoteLines[0].Service_End_Date__c, newQuoteLines[0].SBQQ__EndDate__c);
	}	

	@isTest
	private static void given_QuoteLine_PriceBook_isQMSCPQ_When_QuoteLine_Updated_Then_UpdateTheEndDate_With_ServiceEndDate()
	{
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		TestUtility.setId(testQuote);
		
		String jobj = '{"attributes":{"type":"SBQQ__QuoteLine__c"}, "Product_Business_Type__c":"QMS", "Service_End_Date__c":"2025-11-16", "Quote_Price_book__c":"QMS CPQ", "SBQQ__EndDate__c":"2025-11-12"}';
		SBQQ__QuoteLine__c newQuoteLine = (SBQQ__QuoteLine__c)JSON.deserialize(jobj, SBQQ__QuoteLine__c.class);
		TestUtility.setId(newQuoteLine);
		
		List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>{newQuoteLine};
		Map<ID, SBQQ__QuoteLine__c> oldQuoteLineRecordsMap = new Map<Id, SBQQ__QuoteLine__c>(newQuoteLines);
		 
		MockSelector selector = new MockSelector();

		Test.startTest();
		
		new CPQQuoteLineService(selector).processChangedValues(newQuoteLines, oldQuoteLineRecordsMap);
		
 		Test.stopTest();
		
		System.assertNotEquals(newQuoteLines[0].Service_End_Date__c, newQuoteLines[0].SBQQ__EndDate__c);
		System.assertEquals(date.newinstance(2025, 11, 12), newQuoteLines[0].SBQQ__EndDate__c);
	}

	class MockSelector implements CPQQuoteLineService.ISelector
	{
		Map<Id, List<SBQQ__QuoteLine__c>> parentChildLinesMap = new Map<ID, List<SBQQ__QuoteLine__c>>();	
		List<Product2> quoteLineProducts = new List<Product2>();
		List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
		Map<ID, Product2> productMap = new Map<Id, Product2>();
				
		public Map<Id, List<SBQQ__QuoteLine__c>> getRelatedQuoteLines(Set<ID> ids)
		{
			return parentChildLinesMap;
		}
		
		public List<Product2> getQuoteLineProducts(Set<ID> productIds)
		{
			return quoteLineProducts;
		}
		public List<SBQQ__Quote__c> getQuotesToUpdate(Set<Id> quoteIds)
		{
			return quotesToUpdate;
		}
		public Map<Id, Product2> getProducts(List<SBQQ__QuoteLine__c> quoteLines)
		{
			return productMap;
		}
	}
}