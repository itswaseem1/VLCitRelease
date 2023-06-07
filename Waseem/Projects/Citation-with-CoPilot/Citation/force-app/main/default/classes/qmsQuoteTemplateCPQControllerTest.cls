@isTest
public class qmsQuoteTemplateCPQControllerTest {
	@isTest
	static void given_QMSQuoteLines_with_Certification_And_AuditProducts_And_RegularPayment_Available_When_QuoteDocument_Generated_Then_ServiceTotalCalculated() {
		//Creating ISO Quote & Quote lines

		Account account = new Account();
		account.Name = 'IS0 90001 Regular Payment Test';
		account.Phone = '09876543210';
		account.AnnualRevenue = 50000;
		account.BillingStreet = 'sector';
		account.BillingCity = 'fullTimeEmployees';
		account.BillingState = 'partTimeEmployees';
		account.BillingPostalCode = 'SK9 6BS';

		insert account;

		date closedate = date.newInstance(2023, 10, 20);

		opportunity opportunity = new opportunity();
		opportunity.Name = 'ISO Cert & Audit Opportunity';
		opportunity.AccountId = account.id;
		opportunity.StageName = 'Quoted QMS';
		opportunity.CloseDate = closedate;
		insert opportunity;

		User salesRep = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Citation Data Admin'].Id, LastName = 'last', Email = 'tuser000@citation.co.uk', Username = 'tuser000@citation.co.uk' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', TimeZoneSidKey = 'Europe/London', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_GB');
		insert salesRep;

		List<Product2> productsList = new List<Product2>();

		Product2 parentProduct1 = new product2();
		parentProduct1.Name = 'ISO 9001';
		parentProduct1.ProductCode = 'ISO 9001';
		parentProduct1.Family = 'QMS';
		parentProduct1.SBQQ__BillingFrequency__c = 'Monthly';
		parentProduct1.SBQQ__BillingType__c = 'Advance';

		productsList.add(parentProduct1);

		Product2 certificationProduct = new product2();
		certificationProduct.Name = 'ISO 9001 - Premium - Consultancy & Certification';
		certificationProduct.ProductCode = 'ISO 9001-A';
		certificationProduct.Service_Type__c = 'Premium';
		certificationProduct.Family = 'QMS';
		certificationProduct.SBQQ__BillingType__c = 'Advance';

		productsList.add(certificationProduct);

		Product2 auditProduct = new product2();
		auditProduct.Name = 'ISO 9001 - Premium - Surveillance Audit';
		auditProduct.ProductCode = 'ISO 9001-A';
		auditProduct.Family = 'QMS';
		auditProduct.Service_Type__c = 'Premium';

		productsList.add(auditProduct);

		insert productsList;

		// Create a new standard pricebook
		Pricebook2 standardPricebook = new Pricebook2();
		standardPricebook.Name = 'Standard Pricebook';
		standardPricebook.IsActive = true;
		insert standardPricebook;

		// Create a new custom pricebook
		Pricebook2 customPricebook = new Pricebook2();
		customPricebook.Name = 'QMS CPQ';
		customPricebook.IsActive = true;
		insert customPricebook;

		List<PricebookEntry> entries = new List<PricebookEntry>();
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), parentProduct1.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(customPricebook.Id, parentProduct1.Id, 1000.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), certificationProduct.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(customPricebook.Id, certificationProduct.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), auditProduct.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(customPricebook.Id, auditProduct.Id, 0.0, 0.0, 0.0));

		insert entries;

		SBQQ__Quote__c quote = new SBQQ__Quote__c();
		quote.SBQQ__BillingName__c = 'ISO 9001 Quote';
		quote.SBQQ__Account__c = account.Id;
		quote.SBQQ__SalesRep__c = salesRep.Id;
		quote.SBQQ__Opportunity2__c = opportunity.id;
		quote.SBQQ__PriceBook__c = customPricebook.id;

		insert quote;

		SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id);
		quoteLineGroup.Name = 'Option 1';
		quoteLineGroup.SBQQ__SubscriptionTerm__c = 36;
		quoteLineGroup.SBQQ__Quote__c = quote.id;
		insert quoteLineGroup;

		List<SBQQ__Quoteline__c> quotelinestoInsert = new List<SBQQ__Quoteline__c>();
		SBQQ__Quoteline__c qLine1 = new SBQQ__Quoteline__c(sbqq__quote__c = quote.id, sbqq__group__c = quoteLineGroup.id, sbqq__product__c = productsList[0].id, SBQQ__Quantity__c = 1.0, SBQQ__CustomerPrice__c = 10.0, SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 36, SBQQ__ProratedListPrice__c = 10.0);
		insert qLine1;

		SBQQ__Quoteline__c qLine2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qLine1.id, sbqq__quote__c = quote.id, sbqq__group__c = quoteLineGroup.id, sbqq__product__c = productsList[1].id, SBQQ__Quantity__c = 1.0, SBQQ__CustomerPrice__c = 152964, SBQQ__ListPrice__c = 4249, SBQQ__NetPrice__c = 152964, SBQQ__SpecialPrice__c = 4249, Billing_frequency__c = 'Monthly', Sites__c = 1, sbqq__subscriptionterm__c = 36, Cert_Days__c = 2, Deposit__c = 2099.5, Gap_Analysis_Days__c = 2, Presentation_Days__c = 0.5, QMS_Connect_Term__c = '3', SBQQ__BundledQuantity__c = 1);
		quotelinestoInsert.add(qLine2);

		SBQQ__Quoteline__c qLine3 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qLine1.id, sbqq__quote__c = quote.id, sbqq__group__c = quoteLineGroup.id, sbqq__product__c = productsList[2].id, SBQQ__Quantity__c = 2, SBQQ__CustomerPrice__c = 69696, SBQQ__ListPrice__c = 1936, SBQQ__NetPrice__c = 69696, SBQQ__SpecialPrice__c = 1936, Billing_frequency__c = 'Monthly', Sites__c = 1, sbqq__subscriptionterm__c = 36, Audit_Days__c = 1, Deposit__c = 2, QMS_Connect_Term__c = '3', SBQQ__BundledQuantity__c = 1);
		quotelinestoInsert.add(qLine3);

		insert quotelinestoInsert;

		//This method Create a Template and Initializes the Vf Page with this QuoteId and Created templateId
		SBQQ__QuoteTemplate__c testTemplate = new SBQQ__QuoteTemplate__c();
		insert testTemplate;

		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;

		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', quote.id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);

		Test.startTest();
		qmsQuoteTemplateCPQController quoteController = new qmsQuoteTemplateCPQController();
		Test.stopTest();

		system.assertEquals(4249, quoteController.serviceCostTotal);
		system.assertEquals(1936, quoteController.recurringServiceCostTotal);
	}

	@isTest
	static void given_QMSQuoteLines_with_Certification_And_Products_And_RegularPayment_IsZero_When_QuoteDocument_Generated_Then_ServiceTotalCalculated_From_CustomerPrice() {
		//Creating ISO Quote & Quote lines

		Account account = new Account();
		account.Name = 'ISO 9001 Customer Price Test';
		account.Phone = '09876543210';
		account.AnnualRevenue = 50000;
		account.BillingStreet = 'sector';
		account.BillingCity = 'fullTimeEmployees';
		account.BillingState = 'partTimeEmployees';
		account.BillingPostalCode = 'SK9 6BS';

		insert account;

		date closedate = date.newInstance(2023, 10, 20);

		opportunity opportunity = new opportunity();
		opportunity.Name = 'ISO Cert & Audit Opportunity';
		opportunity.AccountId = account.id;
		opportunity.StageName = 'Quoted QMS';
		opportunity.CloseDate = closedate;
		insert opportunity;

		User salesRep = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Citation Data Admin'].Id, LastName = 'last', Email = 'tuser000@citation.co.uk', Username = 'tuser000@citation.co.uk' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', TimeZoneSidKey = 'Europe/London', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_GB');
		insert salesRep;

		List<Product2> productsList = new List<Product2>();

		Product2 parentProduct1 = new product2();
		parentProduct1.Name = 'ISO 9001';
		parentProduct1.ProductCode = 'ISO 9001';
		parentProduct1.Family = 'QMS';
		parentProduct1.SBQQ__BillingFrequency__c = 'Monthly';
		parentProduct1.SBQQ__BillingType__c = 'Advance';

		productsList.add(parentProduct1);

		Product2 certificationProduct = new product2();
		certificationProduct.Name = 'ISO 9001 - Premium - Consultancy & Certification';
		certificationProduct.ProductCode = 'ISO 9001-A';
		certificationProduct.Service_Type__c = 'Premium';
		certificationProduct.Family = 'QMS';
		certificationProduct.SBQQ__BillingType__c = 'Advance';

		productsList.add(certificationProduct);

		Product2 auditProduct = new product2();
		auditProduct.Name = 'ISO 9001 - Premium - Surveillance Audit';
		auditProduct.ProductCode = 'ISO 9001-A';
		auditProduct.Family = 'QMS';
		auditProduct.Service_Type__c = 'Premium';

		productsList.add(auditProduct);

		insert productsList;

		// Create a new standard pricebook
		Pricebook2 standardPricebook = new Pricebook2();
		standardPricebook.Name = 'Standard Pricebook';
		standardPricebook.IsActive = true;
		insert standardPricebook;

		// Create a new custom pricebook
		Pricebook2 customPricebook = new Pricebook2();
		customPricebook.Name = 'QMS CPQ';
		customPricebook.IsActive = true;
		insert customPricebook;

		List<PricebookEntry> entries = new List<PricebookEntry>();
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), parentProduct1.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(customPricebook.Id, parentProduct1.Id, 1000.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), certificationProduct.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(customPricebook.Id, certificationProduct.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), auditProduct.Id, 0.0, 0.0, 0.0));
		entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(customPricebook.Id, auditProduct.Id, 0.0, 0.0, 0.0));

		insert entries;

		SBQQ__Quote__c quote = new SBQQ__Quote__c();
		quote.SBQQ__BillingName__c = 'ISO 9001 Quote';
		quote.SBQQ__Account__c = account.Id;
		quote.SBQQ__SalesRep__c = salesRep.Id;
		quote.SBQQ__Opportunity2__c = opportunity.id;
		quote.SBQQ__PriceBook__c = customPricebook.id;

		insert quote;

		SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id);
		quoteLineGroup.Name = 'Option 1';
		quoteLineGroup.SBQQ__SubscriptionTerm__c = 36;
		quoteLineGroup.SBQQ__Quote__c = quote.id;
		insert quoteLineGroup;

		List<SBQQ__Quoteline__c> quotelinestoInsert = new List<SBQQ__Quoteline__c>();
		SBQQ__Quoteline__c qLine1 = new SBQQ__Quoteline__c(sbqq__quote__c = quote.id, sbqq__group__c = quoteLineGroup.id, sbqq__product__c = productsList[0].id, SBQQ__Quantity__c = 1.0, SBQQ__CustomerPrice__c = 10.0, SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 36, SBQQ__ProratedListPrice__c = 10.0);
		insert qLine1;

		SBQQ__Quoteline__c qLine2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qLine1.id, sbqq__quote__c = quote.id, sbqq__group__c = quoteLineGroup.id, sbqq__product__c = productsList[1].id, SBQQ__Quantity__c = 1.0, SBQQ__CustomerPrice__c = 152964, SBQQ__ListPrice__c = 152964, SBQQ__NetPrice__c = 152964, SBQQ__SpecialPrice__c = 152964, Billing_frequency__c = 'One-Off', Sites__c = 1, sbqq__subscriptionterm__c = 36, Cert_Days__c = 2, Gap_Analysis_Days__c = 2, Presentation_Days__c = 0.5, QMS_Connect_Term__c = '3', SBQQ__BundledQuantity__c = 1);
		quotelinestoInsert.add(qLine2);

		SBQQ__Quoteline__c qLine3 = new SBQQ__Quoteline__c(sbqq__requiredby__c = qLine1.id, sbqq__quote__c = quote.id, sbqq__group__c = quoteLineGroup.id, sbqq__product__c = productsList[2].id, SBQQ__Quantity__c = 2, SBQQ__CustomerPrice__c = 69696, SBQQ__ListPrice__c = 1936, SBQQ__NetPrice__c = 69696, SBQQ__SpecialPrice__c = 1936, Billing_frequency__c = 'Monthly', Sites__c = 1, sbqq__subscriptionterm__c = 36, Audit_Days__c = 1, Deposit__c = 2, QMS_Connect_Term__c = '3', SBQQ__BundledQuantity__c = 1);
		quotelinestoInsert.add(qLine3);

		insert quotelinestoInsert;

		//This method Create a Template and Initializes the Vf Page with this QuoteId and Created templateId
		SBQQ__QuoteTemplate__c testTemplate = new SBQQ__QuoteTemplate__c();
		insert testTemplate;

		PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;

		Test.setCurrentPage(CPQGeneratePage);

		ApexPages.currentPage().getParameters().put('qid', quote.id);
		ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);

		Test.startTest();
		qmsQuoteTemplateCPQController quoteController = new qmsQuoteTemplateCPQController();
		Test.stopTest();

		system.assertEquals(152964, quoteController.serviceCostTotal);
		system.assertEquals(1936, quoteController.recurringServiceCostTotal);
		system.assertEquals(null, quotelinestoInsert[0].Regular_Payment__c);
		system.assertEquals('sector,fullTimeEmployees,partTimeEmployees,SK9 6BS', quoteController.BillingAddress);
		system.assertEquals('ISO 9001 Quote', quote.SBQQ__BillingName__c);
	}

	private static Account createAccount(String accName, String BillingPostalCode) {
		Account acc = new Account();
		acc.Name = accName;
		acc.Phone = '09876543210';
		acc.AnnualRevenue = 50000;
		acc.BillingStreet = 'sector';
		acc.BillingCity = 'fullTimeEmployees';
		acc.BillingState = 'partTimeEmployees';
		acc.BillingPostalCode = BillingPostalCode;

		insert acc;
		return acc;
	}
}