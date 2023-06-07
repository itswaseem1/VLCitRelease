@isTest
public class CPQQuoteService_Test {
	public static Account acc;
	public static Opportunity opp;
	public static Pricebook2 pb;
	public static SBQQ__Quote__c quote;
	public static Contact c;
	public static Product2 p2;
	public static Product2 p;
	@isTest
	public static void getProductListTest() {
		MockSelector selector = new MockSelector();
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put('5 Course', prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		CPQQuoteService service = new CPQQuoteService(selector);
		Map<string, SBQQ__ProductOption__c> prodOptMapResult = service.getProductList(DataConstants.QUOTE_OPEN_LICENSE);
		System.assertEquals(prodOptMap, prodOptMapResult);
	}
	@isTest
	public static void createQuickQuote_Quote_OppValues_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = prodName;
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			System.assertEquals(oppId, quote[0].SBQQ__Opportunity2__c);
			System.assertEquals(selector.oppRec.AccountId, quote[0].SBQQ__Account__c);
			System.assertEquals(system.today(), quote[0].SBQQ__StartDate__c);
			System.assertEquals(selector.oppRec.Type, quote[0].Quote_type__c);
			System.assertEquals(DataConstants.QUOTE_USER_BASED, quote[0].License_Model__c);
		}
	}
	@isTest
	public static void createQuickQuote_Quote_ContactandOther_Test() {
		String prodName = '5 Course Access';
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = prodName;
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			System.assertEquals(selector.conId, quote[0].SBQQ__PrimaryContact__c);
			System.assertEquals(selector.priceBookId, quote[0].SBQQ__PriceBook__c);
			System.assertEquals(true, quote[0].SBQQ__Primary__c);
			System.assertEquals(selector.quoteRecordTypeId, quote[0].RecordTypeId);
			System.assertEquals(DataConstants.QUOTE_USER_BASED, quote[0].License_Model__c);
		}
	}
	@isTest
	public static void createQuickQuote_QL_Product_Test() {
		String prodName = '5 Course Access';
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '5 Course Access';
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		Prod.SBQQ__PricingMethod__c = 'List';
		prod.SBQQ__BillingType__c = 'Advance';
		Prod.SBQQ__BillingFrequency__c = 'Monthly';
		prod.SBQQ__SubscriptionPricing__c = 'Fixed Price';
		prod.SBQQ__SubscriptionBase__c = 'List';
		prod.SBQQ__SubscriptionType__c = 'Renewable';
		prod.Id = TestUtility.getFakeId(Product2.SObjectType);
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(2, quoteLines.size());
			System.assertEquals(36, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(36, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(100, quoteLines[1].iHasco_Number_of_Users__c);
			System.assertEquals(prod.SBQQ__PricingMethod__c, quoteLines[0].SBQQ__PricingMethod__c);
			System.assertEquals(prod.SBQQ__BillingType__c, quoteLines[0].SBQQ__BillingType__c);
			System.assertEquals(prod.SBQQ__BillingFrequency__c, quoteLines[0].SBQQ__BillingFrequency__c);
			System.assertEquals(prod.SBQQ__SubscriptionPricing__c, quoteLines[0].SBQQ__SubscriptionPricing__c);
			System.assertEquals(prod.SBQQ__SubscriptionBase__c, quoteLines[0].SBQQ__SubscriptionBase__c);
			System.assertEquals(prod.SBQQ__SubscriptionType__c, quoteLines[0].SBQQ__SubscriptionType__c);
			System.assertEquals(prod.Id, quoteLines[0].SBQQ__Product__c);
			System.assertEquals(prod.SBQQ__SubscriptionType__c, quoteLines[0].SBQQ__ProductSubscriptionType__c);
		}
	}
	@isTest
	public static void createQuickQuote_QL_RequiredByValues_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '5 Course Access';
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		prod.Id = TestUtility.getFakeId(Product2.SObjectType);
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(2, quoteLines.size());
			System.assertEquals(36, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(36, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(100, quoteLines[1].iHasco_Number_of_Users__c);
			System.assertEquals(quoteLines[0].Id, quoteLines[1].SBQQ__RequiredBy__c);
			//System.assertEquals(selector.featureId+':'+ prod.Id, quoteLines[1].SBQQ__DynamicOptionId__c);
			System.assertEquals(DataConstants.OPTION_TYPE_RELATED_PRODUCT, quoteLines[1].SBQQ__OptionType__c);
		}
	}
	@isTest
	public static void createQuickQuote_QL_OtherValues_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '5 Course Access';
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		prod.Id = TestUtility.getFakeId(Product2.SObjectType);
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(2, quoteLines.size());
			System.assertEquals(36, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(36, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(100, quoteLines[1].iHasco_Number_of_Users__c);
			System.assertEquals(DataConstants.DEFAULT_SUB_TERM_12, quoteLines[0].SBQQ__DefaultSubscriptionTerm__c);
			System.assertEquals(1, quoteLines[0].SBQQ__Quantity__c);
			System.assertEquals(1, quoteLines[0].SBQQ__BundledQuantity__c);
			System.assertEquals('3', quoteLines[0].Ihasco_Term__c);
			System.assertEquals(quote[0].Id, quoteLines[0].SBQQ__Quote__c);
		}
	}
	@isTest
	public static void createQuickQuote_QuoteGroup_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '5 Course Access';
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		prod.Id = TestUtility.getFakeId(Product2.SObjectType);
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			List<SBQQ__QuoteLineGroup__c> quoteGroup = uow.getRecords(SBQQ__QuoteLineGroup__c.SObjectType);
			System.assertEquals(quote[0].Id, quoteGroup[0].SBQQ__Quote__c);
			System.assertEquals('Group 1', quoteGroup[0].Name);
			System.assertEquals(36, quoteGroup[0].SBQQ__SubscriptionTerm__c);
		}
	}
	@isTest
	public static void createQuickQuote_With_UserBased_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '5 Course Access';
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		prodOptMap.put(DataConstants.OPENCREDITS_PRODUCT, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', AccountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			System.assertEquals(DataConstants.QUOTE_USER_BASED, quote[0].License_Model__c);
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(2, quoteLines.size());
			System.assertEquals(36, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(36, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(100, quoteLines[1].iHasco_Number_of_Users__c);
		}
	}
	@isTest
	public static void createQuickQuote_With_OpenLicense_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '20 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = prodName;
		Prod.ProductCode = '20Course';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		prodOptMap.put(DataConstants.OPENCREDITS_PRODUCT, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', accountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_OPEN_LICENSE, prodName, '3', '500', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			System.assertEquals(DataConstants.QUOTE_OPEN_LICENSE, quote[0].License_Model__c);
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(3, quoteLines.size());
			System.assertEquals(36, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(36, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(500, quoteLines[2].Ihasco_Number_of_Credits__c);
		}
	}
	@isTest
	public static void createQuickQuote_With_UserBased_OneYear_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		// selector.featureId = TestUtility.getFakeId(Account.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '5 Course Access';
		Prod.ProductCode = 'IR-HUBP';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', accountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '1', '2000', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			System.assertEquals(DataConstants.QUOTE_USER_BASED, quote[0].License_Model__c);
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(2, quoteLines.size());
			System.assertEquals(12, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(12, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(2000, quoteLines[1].iHasco_Number_of_Users__c);
		}
	}
	@isTest
	public static void createQuickQuote_With_OpenLicense_TwoYears_Test() {
		Map<string, SBQQ__ProductOption__c> prodOptMap = new Map<string, SBQQ__ProductOption__c>();
		String prodName = '5 Course Access';
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		selector.conId = TestUtility.getFakeId(Contact.SObjectType);
		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		selector.priceBookId = TestUtility.getFakeId(PriceBook2.SObjectType);
		selector.priceEntryId = TestUtility.getFakeId(PricebookEntry.SObjectType);
		Product2 Prod = new Product2();
		Prod.Name = '20 Course Access';
		Prod.ProductCode = '20Course';
		Prod.IsActive = true;
		Prod.SBQQ__SubscriptionType__c = 'Renewable';
		Prod.SBQQ__BillingFrequency__c = 'Annual';
		selector.prodRec = Prod;
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(prodName, prodOpt);
		SBQQ__ProductOption__c prodOpt1 = new SBQQ__ProductOption__c();
		prodOpt1.Id = TestUtility.getFakeId(SBQQ__ProductOption__c.SObjectType);
		prodOpt1.SBQQ__Feature__c = TestUtility.getFakeId(SBQQ__ProductFeature__c.SObjectType);
		prodOptMap.put(DataConstants.OPENCREDITS_PRODUCT, prodOpt1);
		selector.pordNameVsProdOptMap = prodOptMap;
		Id accountId = TestUtility.getFakeId(Account.SObjectType);
		selector.oppRec = new Opportunity(Type = 'Top-Up', accountId = accountId);
		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);
		User iHASCOUser = [SELECT Id FROM USER WHERE Division = 'iHASCO' AND isactive = TRUE LIMIT 1];
		System.runAs(iHASCOUser) {
			Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
			test.startTest();
			service.createQuickQuote(DataConstants.QUOTE_OPEN_LICENSE, prodName, '2', '3000', oppId);
			test.stopTest();
			List<SBQQ__Quote__c> quote = uow.getRecords(SBQQ__Quote__c.SObjectType);
			System.assertEquals(1, quote.size());
			System.assertEquals(DataConstants.QUOTE_OPEN_LICENSE, quote[0].License_Model__c);
			List<SBQQ__QuoteLine__c> quoteLines = uow.getRecords(SBQQ__QuoteLine__c.SObjectType);
			System.assertEquals(3, quoteLines.size());
			System.assertEquals(24, quoteLines[0].iHasco_Subscription_Term__c);
			System.assertEquals(24, quoteLines[1].iHasco_Subscription_Term__c);
			System.assertEquals(3000, quoteLines[2].Ihasco_Number_of_Credits__c);
		}
	}
	@isTest
	public static void getPrimaryContact_FindsPrimaryCon_Test() {
		List<Account> acList = TestDataFactory.getAccounts(1, 'iHASCO TEST', true);
		Contact c = new Contact();
		c.FirstName = 'Test';
		c.LastName = 'Contact';
		c.AccountId = acList[0].Id;
		c.Phone = '01912553955';
		c.MobilePhone = '70875327792';
		c.Email = 'testcontact@email.com';
		insert c;
		List<Opportunity> oppList = TestDataFactory.generateOppsForAccount(acList[0].Id, 100, 1, false);
		oppList[0].type = 'New Business';
		insert oppList[0];
		OpportunityContactRole oppContRole = new OpportunityContactRole();
		oppContRole.ContactId = c.Id;
		oppContRole.IsPrimary = true;
		oppContRole.OpportunityId = oppList[0].Id;
		insert oppContRole;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Id primaryConId = selector.getPrimaryContact(oppList[0].Id);
		system.assertEquals(c.Id, primaryConId);
	}
	@isTest
	public static void getPrimaryContact_FindsNoPrimaryCon_Test() {
		List<Account> acList = TestDataFactory.getAccounts(1, 'iHASCO TEST', true);
		Contact c = new Contact();
		c.FirstName = 'Test';
		c.LastName = 'Contact';
		c.AccountId = acList[0].Id;
		c.Phone = '01912553955';
		c.MobilePhone = '70875327792';
		c.Email = 'testcontact@email.com';
		insert c;
		List<Opportunity> oppList = TestDataFactory.generateOppsForAccount(acList[0].Id, 100, 1, false);
		oppList[0].type = 'New Business';
		insert oppList[0];
		OpportunityContactRole oppContRole = new OpportunityContactRole();
		oppContRole.ContactId = c.Id;
		oppContRole.IsPrimary = false;
		oppContRole.OpportunityId = oppList[0].Id;
		insert oppContRole;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Id primaryConId = selector.getPrimaryContact(oppList[0].Id);
		system.assertEquals(null, primaryConId);
	}
	@isTest
	public static void getOppDetails_FindsOpp_Test() {
		List<Account> acList = TestDataFactory.getAccounts(1, 'iHASCO TEST', true);
		List<Opportunity> oppList = TestDataFactory.generateOppsForAccount(acList[0].Id, 100, 1, false);
		oppList[0].type = 'New Business';
		insert oppList[0];
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Opportunity selectorOpp = selector.getOppDetails(oppList[0].Id);
		system.assertEquals(oppList[0].AccountId, selectorOpp.AccountId);
		system.assertEquals(oppList[0].Type, selectorOpp.Type);
	}
	@isTest
	public static void getOppDetails_FindsNoOpp_Test() {
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		String oppId;
		try {
			Opportunity selectorOpp = selector.getOppDetails(oppId);
			System.assert(false, 'Should have thrown an exception');
		} catch (Exception e) {
			system.assertEquals('No Opportunity found with id ' + oppId, e.getMessage());
		}
	}
	@isTest
	public static void getPriceBook_FindsPriceBook_Test() {
		Pricebook2 pb = new Pricebook2();
		pb.Name = DataConstants.QUOTE_iHASCO_PRICEBOOKNAME;
		pb.IsActive = true;
		insert pb;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Id iHASCOPriceBookId = selector.getPriceBook(DataConstants.QUOTE_iHASCO_PRICEBOOKNAME);
		system.assertEquals(pb.Id, iHASCOPriceBookId);
	}
	@isTest
	public static void getPriceBook_FindsNoPriceBook_Test() {
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'test';
		pb.IsActive = true;
		insert pb;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Id iHASCOPriceBookId = selector.getPriceBook(DataConstants.QUOTE_iHASCO_PRICEBOOKNAME);
		system.assertEquals(null, iHASCOPriceBookId);
	}
	@isTest
	public static void getProductDetails_FindsProduct_Test() {
		Product2 p = new Product2();
		p.Name = '10 Course Access Key';
		p.ProductCode = 'AccessKEY10';
		p.IsActive = true;
		p.SBQQ__SubscriptionType__c = 'Renewable';
		p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
		P.SBQQ__BillingFrequency__c = 'Annual';
		insert P;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		product2 Prod = selector.getProductDetails('10 Course Access Key');
		system.assertEquals(p.Id, Prod.Id);
		system.assertEquals(p.SBQQ__BillingFrequency__c, Prod.SBQQ__BillingFrequency__c);
		system.assertEquals(p.SBQQ__SubscriptionPricing__c, Prod.SBQQ__SubscriptionPricing__c);
		system.assertEquals(p.SBQQ__SubscriptionType__c, Prod.SBQQ__SubscriptionType__c);
	}
	@isTest
	public static void getProductDetails_FindsNoProduct_Test() {
		Product2 p = new Product2();
		p.Name = '10 Course Access Key';
		p.ProductCode = 'AccessKEY10';
		p.IsActive = true;
		p.SBQQ__SubscriptionType__c = 'Renewable';
		p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
		P.SBQQ__BillingFrequency__c = 'Annual';
		insert P;
		String productName = '20 Course Access Key';
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		try {
			product2 Prod = selector.getProductDetails(productName);
			System.assert(false, 'Should have thrown an exception');
		} catch (Exception e) {
			system.assertEquals('No Product found with Product Name ' + productName, e.getMessage());
		}
	}
	@isTest
	public static void getPriceBookEntry_FindsPBEntry_Test() {
		Product2 p = new Product2();
		p.Name = '10 Course Access Key';
		p.ProductCode = 'AccessKEY10';
		p.IsActive = true;
		p.SBQQ__SubscriptionType__c = 'Renewable';
		p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
		P.SBQQ__BillingFrequency__c = 'Annual';
		insert P;
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'iHASCO';
		pb.IsActive = true;
		insert pb;
		List<PricebookEntry> entries = new List<PricebookEntry>();
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
		insert entries;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Id pbEntryId = selector.getPriceBookEntry(p.Id, pb.Id);
		system.assertEquals(entries[1].Id, pbEntryId);
	}
	@isTest
	public static void getPriceBookEntry_FindsNOPBEntry_Test() {
		Product2 p = new Product2();
		p.Name = '10 Course Access Key';
		p.ProductCode = 'AccessKEY10';
		p.IsActive = true;
		p.SBQQ__SubscriptionType__c = 'Renewable';
		p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
		P.SBQQ__BillingFrequency__c = 'Annual';
		insert P;
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'iHASCO';
		pb.IsActive = true;
		insert pb;
		List<PricebookEntry> entries = new List<PricebookEntry>();
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
		insert entries; //No iHasco Price Book entry inserted
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Id pbEntryId = selector.getPriceBookEntry(p.Id, pb.Id);
		system.assertEquals(null, pbEntryId);
	}
	@isTest
	public static void getProductOptionList_FindsProdOptions_Test() {
		List<Product2> prdList = new List<Product2>();
		Product2 p2 = new Product2();
		p2.Name = DataConstants.USERBASED_PRODUCT;
		p2.ProductCode = 'HUBP';
		p2.IsActive = true;
		p2.SBQQ__SubscriptionType__c = 'Renewable';
		p2.SBQQ__BillingFrequency__c = 'Annual';
		prdList.add(p2);
		Product2 p3 = new Product2();
		p3.Name = '5 Course Access';
		p3.ProductCode = 'IR-HUBP';
		p3.IsActive = true;
		p3.SBQQ__SubscriptionType__c = 'Renewable';
		p3.SBQQ__BillingFrequency__c = 'Annual';
		prdList.add(p3);
		insert prdList;
		List<SBQQ__ProductOption__c> prodOptList = new List<SBQQ__ProductOption__c>();
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.SBQQ__OptionalSKU__c = p3.Id;
		prodOpt.SBQQ__ConfiguredSKU__c = p2.Id;
		prodOpt.SBQQ__Number__c = 10;
		prodOpt.SBQQ__Type__c = 'Related Product';
		insert prodOpt;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		Map<string, SBQQ__ProductOption__c> prodOptionMap = selector.getProductOptionList(DataConstants.USERBASED_PRODUCT);
		List<SBQQ__ProductOption__c> prodOption = prodOptionMap.values();
		system.assertEquals(1, prodOption.size());
		system.assertEquals(p3.Name, prodOption[0].SBQQ__ProductName__c);
	}
	@isTest
	public static void getProductOptionList_FindsNoProdOptions_Test() {
		List<Product2> prdList = new List<Product2>();
		Product2 p2 = new Product2();
		p2.Name = DataConstants.USERBASED_PRODUCT;
		p2.ProductCode = 'HUBP';
		p2.IsActive = true;
		p2.SBQQ__SubscriptionType__c = 'Renewable';
		p2.SBQQ__BillingFrequency__c = 'Annual';
		prdList.add(p2);
		Product2 p3 = new Product2();
		p3.Name = '5 Course Access';
		p3.ProductCode = 'IR-HUBP';
		p3.IsActive = true;
		p3.SBQQ__SubscriptionType__c = 'Renewable';
		p3.SBQQ__BillingFrequency__c = 'Annual';
		prdList.add(p3);
		insert prdList;
		List<SBQQ__ProductOption__c> prodOptList = new List<SBQQ__ProductOption__c>();
		SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c();
		prodOpt.SBQQ__OptionalSKU__c = p3.Id;
		prodOpt.SBQQ__ConfiguredSKU__c = p2.Id;
		prodOpt.SBQQ__Number__c = 10;
		prodOpt.SBQQ__Type__c = 'Related Product';
		insert prodOpt;
		CPQQuoteService.CPQQuoteServiceSelector selector = new CPQQuoteService.CPQQuoteServiceSelector();
		//Giving wrong inputs to method
		try {
			Map<string, SBQQ__ProductOption__c> prodOption = selector.getProductOptionList(DataConstants.OPEN_LICENSE_PRODUCT);
			System.assert(false, 'Should have thrown an exception');
		} catch (Exception e) {
			system.assertEquals('No Product Options found with Product Name ' + DataConstants.OPEN_LICENSE_PRODUCT, e.getMessage());
		}
	}

	@isTest
	private static void givenCitationQuoteDetails_WhenQuoteStatus_AgreementIssued_ThenSetOpportunityStage_ProvisionalAgreement() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
		Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>();

		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		Id quoteId = TestUtility.getFakeId(SBQQ__Quote__c.SObjectType);
		Id opportunityId = TestUtility.getFakeId(Opportunity.SObjectType);
		quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = DataConstants.QUOTE_STATUS_AGREEMENT_ISSUED, RecordTypeId = selector.quoteRecordTypeId, Id = quoteId, SBQQ__Opportunity2__c = opportunityId));
		SBQQ__Quote__c oldquote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'new');
		oldQuoteMap.put(quoteId, oldquote);

		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnChange(quotes, oldQuoteMap);
		test.stopTest();
		List<Opportunity> opportunities = uow.getRecords(Opportunity.SObjectType);
		Assert.areEqual(DataConstants.OPPORTUNITY_STAGE_PROVISIONAL_AGREEMENT, opportunities[0].StageName);
	}

	private static void givenCitationQuoteDetails_WhenQuoteStatus_NotAgreementIssued_ThenSetOpportunityStage_NotProvisionalAgreement() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
		Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>();

		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		Id quoteId = TestUtility.getFakeId(SBQQ__Quote__c.SObjectType);
		Id opportunityId = TestUtility.getFakeId(Opportunity.SObjectType);
		quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', RecordTypeId = selector.quoteRecordTypeId, Id = quoteId, SBQQ__Opportunity2__c = opportunityId));
		SBQQ__Quote__c oldquote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'new');
		oldQuoteMap.put(quoteId, oldquote);

		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnChange(quotes, oldQuoteMap);
		test.stopTest();
		List<Opportunity> opportunities = uow.getRecords(Opportunity.SObjectType);
		Assert.areEqual(opportunities.size(), 0);
	}

	@isTest
	private static void givenOtherQuoteDetails_WhenQuoteStatus_AgreementIssued_ThenSetOpportunityStage_NotProvisionalAgreement() {
		MockSelector selector = new MockSelector(); // Using Mock selector to avoid SOQL
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
		Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>();

		selector.quoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		Id otherQuoteRecordTypeId = TestUtility.getFakeId(SObjectType.RecordType.SObjectType);
		Id quoteId = TestUtility.getFakeId(SBQQ__Quote__c.SObjectType);
		Id opportunityId = TestUtility.getFakeId(Opportunity.SObjectType);
		quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = DataConstants.QUOTE_STATUS_AGREEMENT_ISSUED, RecordTypeId = otherQuoteRecordTypeId, Id = quoteId, SBQQ__Opportunity2__c = opportunityId));
		SBQQ__Quote__c oldquote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'new');
		oldQuoteMap.put(quoteId, oldquote);

		CPQQuoteService service = new CPQQuoteService(selector);
		MockUOW uow = new MockUOW(); // set the uow mock to avoid DB and allow us to capture.
		UnitOfWork.setInstance(uow);

		test.startTest();
		service.processRelatedRecordsOnChange(quotes, oldQuoteMap);
		test.stopTest();
		List<Opportunity> opportunities = uow.getRecords(Opportunity.SObjectType);
		Assert.areEqual(opportunities.size(), 0);
	}
	class MockSelector implements CPQQuoteService.ISelector {
		String conId;
		Id quoteRecordTypeId;
		Id priceBookId;
		Id priceEntryId;
		opportunity oppRec = new opportunity();
		Product2 prodRec = new Product2();
		Map<string, SBQQ__ProductOption__c> pordNameVsProdOptMap = new Map<string, SBQQ__ProductOption__c>();

		public Id getPrimaryContact(String oppoId) {
			return conId;
		}
		public Id getRecordTypeId(SObjectType objType, String devName) {
			return quoteRecordTypeId;
		}
		public Opportunity getOppDetails(String oppoId) {
			return oppRec;
		}
		public Id getPriceBook(String priceBookName) {
			return priceBookId;
		}
		public product2 getProductDetails(String productName) {
			return prodRec;
		}
		public Id getPriceBookEntry(Id prodId, Id iHASCOPBId) {
			return priceEntryId;
		}
		public Map<string, SBQQ__ProductOption__c> getProductOptionList(String productName) {
			return pordNameVsProdOptMap;
		}
	}
}