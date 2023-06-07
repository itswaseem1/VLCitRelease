/**************************************************************
* bg_QuoteLineItem_Tests - A test class used to verify the quote line item calculation funcitonlity.
*
* Created By: Cameron Stewart
* Created Date: 2016-02-15
*
* Changes:
*
***************************************************************/
@isTest
private class bg_QuoteLineItem_Tests {
    @testSetup static void setupData() {
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebook;
        
        Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ');
        insert qmsNewPB;

		List<Product2> productRecords = new List<Product2>();
		productRecords.add(bg_Product_TestUtils.createProduct('A', 'Consultation', 'Premium'));
		productRecords.add(bg_Product_TestUtils.createProduct(bg_Constants.REDUCTION_PRODUCT_TYPE, 'Consultation', 'Premium'));
		insert productRecords;

		List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();
		stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[0].Id, 1000.0, 500.0, 600.0));
		stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[1].Id, 1000.0, 500.0, 600.0));
		insert stdPricebookEntries;

		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pricebook.Id, productRecords[0].Id, 1000.0, 500.0, 600.0));
		pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pricebook.Id, productRecords[1].Id, 1000.0, 500.0, 600.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[1].Id, 1000.0, 500.0, 600.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[0].Id, 1000.0, 500.0, 600.0));
		insert pricebookEntries;

		Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert account;

		List<quotesync__QuoteSyncField__c> quoteSyncFields = new List<quotesync__QuoteSyncField__c>();
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Consultancy_Fee__c', 	quotesync__OppSyncField__c = 'Consultancy_Fee__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Contract_End_Date__c', 	quotesync__OppSyncField__c = 'Contract_End_Date__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Contract_Length_Years__c', 	quotesync__OppSyncField__c = 'Contract_Length_Years__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Implementation_Fee__c', 	quotesync__OppSyncField__c = 'Implementation_Fee__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Ref_Number__c', 	quotesync__OppSyncField__c = 'Ref_Number__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Sites__c', 	quotesync__OppSyncField__c = 'Sites__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Travel_Miles_Per_Day__c', 	quotesync__OppSyncField__c = 'Travel_Miles_Per_Day__c'));
		quoteSyncFields.add(new quotesync__QuoteSyncField__c(Name = 'Same_Standard_On_All_Sites__c', 	quotesync__OppSyncField__c = 'Same_Standard_On_All_Sites__c'));
		insert quoteSyncFields;

		List<quotesync__QuoteLineSyncField__c> quoteLinteItemSyncFields = new List<quotesync__QuoteLineSyncField__c>();
		quoteLinteItemSyncFields.add(new quotesync__QuoteLineSyncField__c(Name = 'Additional_Sites_Price__c', quotesync__OppLineSyncField__c	= 'Additional_Sites_Price__c'));
		quoteLinteItemSyncFields.add(new quotesync__QuoteLineSyncField__c(Name = 'Travel_Cost_Hotel_Flights__c', quotesync__OppLineSyncField__c	= 'Travel_Cost_Hotel_Flights__c'));
		quoteLinteItemSyncFields.add(new quotesync__QuoteLineSyncField__c(Name = 'User_Sales_Price__c', quotesync__OppLineSyncField__c	= 'User_Sales_Price__c'));
		insert quoteLinteItemSyncFields;
	}

	/*
	 * Calculate prices tests
	 */

	@isTest static void Given_AnyInputForAQMSUser_When_PricesAreCalculatedOnTheLineItem_Then_TheCorrectPricesAreCalculatedWithoutError() {
		User userToRunAs = bg_User_TestUtils.createBusinessSolutionsTeamUser('1');

		System.runAs(userToRunAs)
		{
			Account account = [Select Id From Account];

			List<Opportunity> opportunityRecords = new List<Opportunity>();
			opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, false, 3));
			opportunityRecords.add(bg_Opportunity_TestUtils.createDefaultCitationOpportunity('2', account.Id, false, 3));
			opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('3', account.Id, true, 3));
			opportunityRecords.add(bg_Opportunity_TestUtils.createDefaultCitationOpportunity('4', account.Id, true, 3));
			insert opportunityRecords;

			/*
			 * Create quote records
			 */
            Pricebook2 priceBook;
            if(System.Label.EnableQMSCPQ == 'true'){
				priceBook = [Select Id From Pricebook2 Where Id != :Test.getStandardPricebookId() AND Name = 'QMS CPQ'];
            } else {
                priceBook = [Select Id From Pricebook2 Where Id != :Test.getStandardPricebookId() AND Name != 'QMS CPQ'];
            }

			List<Quote> quoteRecords = new List<Quote>();
			quoteRecords.add(bg_Quote_TestUtils.generateBasicQuoteRecord(opportunityRecords[0].Id, '1', priceBook.Id));
			quoteRecords.add(bg_Quote_TestUtils.generateDefaultQuoteRecord(opportunityRecords[1].Id, '1', priceBook.Id));
			quoteRecords.add(bg_Quote_TestUtils.generateBasicQuoteRecord(opportunityRecords[2].Id, '1', priceBook.Id));
			quoteRecords.add(bg_Quote_TestUtils.generateDefaultQuoteRecord(opportunityRecords[3].Id, '1', priceBook.Id));
			insert quoteRecords;

			Test.startTest();

			/*
			 * Check the quotes have 3 sites to visit
			 */
			quoteRecords = [Select Id, Sites__c, RecordType.DeveloperName From Quote Where Id IN : quoteRecords];
			System.assertEquals(3, quoteRecords[0].Sites__c);
			System.assertEquals(3, quoteRecords[1].Sites__c);
			System.assertEquals(3, quoteRecords[2].Sites__c);
			System.assertEquals(3, quoteRecords[3].Sites__c);
			System.assertEquals('QMS_Quote', quoteRecords[0].RecordType.DeveloperName);
			System.assertEquals('Default_Quote', quoteRecords[1].RecordType.DeveloperName);
			System.assertEquals('QMS_Quote', quoteRecords[2].RecordType.DeveloperName);
			System.assertEquals('Default_Quote', quoteRecords[3].RecordType.DeveloperName);

			opportunityRecords = [Select Id, Sites_Visited__c, RecordTypeId, Same_Standard_On_All_Sites__c, RecordType.DeveloperName From Opportunity Order By Name ASC];
			System.assertEquals('QMS', opportunityRecords[0].RecordType.DeveloperName);
			System.assertEquals('Default_Citation_Opportunity', opportunityRecords[1].RecordType.DeveloperName);
			System.assertEquals('QMS', opportunityRecords[2].RecordType.DeveloperName);
			System.assertEquals('Default_Citation_Opportunity', opportunityRecords[3].RecordType.DeveloperName);

			PricebookEntry priceBookEntry = [Select Id, Product2Id, Product2.Name, Additional_Sites_Mixed_P_P__c From PriceBookEntry Where 
                                             Pricebook2Id =: priceBook.Id AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE LIMIT 1];

			PricebookEntry priceBookEntryReduction = [Select Id, Product2Id, Product2.Name, Additional_Sites_Mixed_P_P__c From PriceBookEntry Where Pricebook2Id =: priceBook.Id 
			AND Product2.Name = :bg_Constants.REDUCTION_PRODUCT_TYPE LIMIT 1];

			List<QuoteLineItem> quoteLineItemRecords = new List<QuoteLineItem>();
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[0].Id, pricebookEntry.Id, 5.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[1].Id, pricebookEntry.Id, 6.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[2].Id, pricebookEntry.Id, 7.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[3].Id, pricebookEntry.Id, 8.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[0].Id, priceBookEntryReduction.Id, 9.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[1].Id, priceBookEntryReduction.Id, 10.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[2].Id, priceBookEntryReduction.Id, 11.0, 1, 0.0));
			quoteLineItemRecords.add(bg_QuoteLineItem_TestUtils.createQuoteLineItem(quoteRecords[3].Id, priceBookEntryReduction.Id, 12.0, 1, 0.0));
			insert quoteLineItemRecords;

			Test.stopTest();
			
			quoteLineItemRecords = [Select Id, Additional_Sites_Price__c, UnitPrice, User_Sales_Price__c From QuoteLineItem Where
										  PriceBookEntry.Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE Order By Quote.Opportunity.Name ASC];

			/*
			 * Check the calculations
			 */
			/*
			 * QMS & not the same standaed on all sites
			 */ 
			System.assertEquals(600, quoteLineItemRecords[0].Additional_Sites_Price__c);
			System.assertEquals(1205, quoteLineItemRecords[0].UnitPrice);
			System.assertEquals(5, quoteLineItemRecords[0].User_Sales_Price__c);

			/*
			 * Non-QMS & not the same standaed on all sites
			 */ 
			System.assertEquals(0, quoteLineItemRecords[1].Additional_Sites_Price__c);
			System.assertEquals(6, quoteLineItemRecords[1].UnitPrice);
			System.assertEquals(0, quoteLineItemRecords[1].User_Sales_Price__c);

			/*
			 * QMS & the same standaed on all sites
			 */ 
			System.assertEquals(500, quoteLineItemRecords[2].Additional_Sites_Price__c);
			System.assertEquals(7, quoteLineItemRecords[2].UnitPrice);
			System.assertEquals(7, quoteLineItemRecords[2].User_Sales_Price__c);

			/*
			 * Non-QMS & the same standaed on all sites
			 */ 
			System.assertEquals(0, quoteLineItemRecords[3].Additional_Sites_Price__c);
			System.assertEquals(8, quoteLineItemRecords[3].UnitPrice);
			System.assertEquals(0, quoteLineItemRecords[3].User_Sales_Price__c);

			quoteLineItemRecords = [Select Id, Additional_Sites_Price__c, UnitPrice, User_Sales_Price__c From QuoteLineItem Where
										  PriceBookEntry.Product2.Name = :bg_Constants.REDUCTION_PRODUCT_TYPE Order By Quote.Opportunity.Name];
			/*
			 * Reduction & QMS & not the same standaed on all sites
			 */ 
			System.assertEquals(0, quoteLineItemRecords[0].Additional_Sites_Price__c);
			System.assertEquals(9, quoteLineItemRecords[0].UnitPrice);
			System.assertEquals(0, quoteLineItemRecords[0].User_Sales_Price__c);

			/*
			 * Reduction & Non-QMS & not the same standaed on all sites
			 */ 
			System.assertEquals(0, quoteLineItemRecords[1].Additional_Sites_Price__c);
			System.assertEquals(10, quoteLineItemRecords[1].UnitPrice);
			System.assertEquals(0, quoteLineItemRecords[1].User_Sales_Price__c);

			/*
			 * Reduction & QMS & the same standaed on all sites
			 */ 
			System.assertEquals(0, quoteLineItemRecords[2].Additional_Sites_Price__c);
			System.assertEquals(11, quoteLineItemRecords[2].UnitPrice);
			System.assertEquals(0, quoteLineItemRecords[2].User_Sales_Price__c);

			/*
			 * Reduction & Non-QMS & the same standaed on all sites
			 */ 
			System.assertEquals(0, quoteLineItemRecords[3].Additional_Sites_Price__c);
			System.assertEquals(12, quoteLineItemRecords[3].UnitPrice);
			System.assertEquals(0, quoteLineItemRecords[3].User_Sales_Price__c);
		}
	}

	/*
		Test creating a quote from an opp with line items.
	*/
	@isTest static void testCreateQuoteFromOppWithLineItems(){
		Account account = [Select Id From Account];
		
        Pricebook2 priceBook;
        if(System.Label.EnableQMSCPQ == 'true'){
            priceBook = [Select Id From Pricebook2 Where Id != :Test.getStandardPricebookId() AND Name = 'QMS CPQ'];
        } else {
            priceBook = [Select Id From Pricebook2 Where Id != :Test.getStandardPricebookId() AND Name != 'QMS CPQ'];
        }
        
		

		PricebookEntry priceBookEntry = [Select Id From PriceBookEntry Where Pricebook2Id =: priceBook.Id limit 1];

		Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 9);
		insert opportunity;
		OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, priceBookEntry.Id, 1000.0, 1, 0.0);
		insert oppLineItem;

		Quote quote = bg_Quote_TestUtils.generateBasicQuoteRecord(opportunity.Id, '1', priceBook.Id);
		insert quote;

		QuoteLineItem quotelineitem = bg_QuoteLineItem_TestUtils.createQuoteLineItem(quote.Id, pricebookEntry.Id, 5.0, 1, 0.0);
		insert quotelineitem;

		System.assertEquals(5, quotelineitem.UnitPrice);
		
	}

}