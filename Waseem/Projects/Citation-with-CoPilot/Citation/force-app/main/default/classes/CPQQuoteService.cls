public class CPQQuoteService extends DefaultService implements ICPQQuoteService {
	public interface ISelector {
		/*
		 *  Returns the primaryContact of Opportunity.
		 *  PrimaryContact is a Primary Opportunitycontactrole.
		 */
		Id getPrimaryContact(String oppoId);

		/*
		 *  Returns the RecordTypeId of Object based on
		 *  RecordType Developer Name.
		 */
		Id getRecordTypeId(SObjectType objType, String devName);

		/*
		 *  Returns the Opportunity details like type and Account based
		 *  on opportunity Id
		 */
		Opportunity getOppDetails(String oppoId);

		/*
		 * Returns the PriceBook Id based on Price Book Name
		 */
		Id getPriceBook(String priceBookName);

		/*
		 * Returns Product Details based on Product Name
		 */
		Product2 getProductDetails(String productName);

		/*
		 * Returns Feature Id from the Productions based on
		 * Product id
		 */
		//SBQQ__ProductOption__c getFeature(Id prodId,String parentProductName);

		/* Returns PriceBookEntry Id Based on Product Id and
		 *  PriceBook Id
		 */
		Id getPriceBookEntry(Id prodId, Id iHASCOPBId);

		/*
		 *  Returns the Product Options based on License Model and Product Name.
		 */
		Map<string, SBQQ__ProductOption__c> getProductOptionList(String productName);
	}
	/*For Custom Exception Handling created below class*/
	public virtual class CustomException extends Exception {
	}
	/*
	 *   Our selector that we were provided by what ever created us.
	 */
	private ISelector selector;

	public CPQQuoteService(ISelector selector) {
		this.selector = selector;
	}
	/*
	 *   see IDomainService
	 */
	public override void setDefaults(List<SObject> newRecords) {
	}

	/*
	 *   see IDomainService
	 */
	public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords) {
	}

	/*
	 *   see IDomainService
	 */
	public override void processRelatedRecordsOnNew(List<SObject> newRecords) {
	}

	/*
	 *   see IDomainService
	 */
	public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords) {
		List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>) newRecords;
		Map<Id, SBQQ__Quote__c> oldQuoteMap = (Map<Id, SBQQ__Quote__c>) (oldRecords);

		setAgreementIssuedQuoteOnOpportunity(quotes, oldQuoteMap);
	}

	/*
	 *   see IDomainService
	 */
	public override void processRelatedRecordsOnDelete(List<SObject> objs) {
	}
	public String createQuickQuote(String licenseModel, String productName, String term, String noOfUnits, String oppoId) {
		Id iHASCOPBId = selector.getPriceBook(DataConstants.Quote_iHASCO_PRICEBOOKNAME);
		Id quoteId;
		Id parenrentQLId;
		Integer termInYear = integer.ValueOf(term);
		Integer termInMonths = termInYear * 12;
		Map<string, SBQQ__ProductOption__c> pordNameVsProdOptMap = getProductList(licenseModel);
		Savepoint sp = Database.setSavePoint();
		try {
			quoteId = createiHASCOQuote(licenseModel, oppoId, iHASCOPBId);
			SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quoteId);
			qg.Name = 'Group 1';
			qg.SBQQ__SubscriptionTerm__c = termInMonths;
			IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
			uow.insertRecords(new List<SBQQ__QuoteLineGroup__c>{ qg });
			if (LicenseModel == DataConstants.QUOTE_OPEN_LICENSE) {
				parenrentQLId = createiHASCOQuoteLines(LicenseModel, quoteId, termInMonths, term, null, DataConstants.OPEN_LICENSE_PRODUCT, 0, qg.Id, iHASCOPBId, null);
				createiHASCOQuoteLines(LicenseModel, quoteId, termInMonths, term, parenrentQLId, productName, 0, qg.Id, iHASCOPBId, pordNameVsProdOptMap.get(productName));
				createiHASCOQuoteLines(LicenseModel, quoteId, termInMonths, term, parenrentQLId, DataConstants.OPENCREDITS_PRODUCT, integer.ValueOf(noOfUnits), qg.Id, iHASCOPBId, pordNameVsProdOptMap.get(DataConstants.OPENCREDITS_PRODUCT));
			} else if (licenseModel == DataConstants.QUOTE_USER_BASED) {
				parenrentQLId = createiHASCOQuoteLines(LicenseModel, quoteId, termInMonths, term, null, DataConstants.USERBASED_PRODUCT, 0, qg.Id, iHASCOPBId, null);
				createiHASCOQuoteLines(LicenseModel, quoteId, termInMonths, term, parenrentQLId, productName, integer.ValueOf(noOfUnits), qg.Id, iHASCOPBId, pordNameVsProdOptMap.get(productName));
			}
		} catch (Exception e) {
			Database.rollBack(sp);
			throw e;
		}
		return quoteId;
	}
	private Id createiHASCOQuote(String licenseModel, String oppoId, Id iHASCOPBId) {
		Id primaryContact = selector.getPrimaryContact(oppoId);
		Opportunity opp = selector.getOppDetails(oppoId);
		Id quoteIhascoRecordtypeId = selector.getRecordTypeId(SBQQ__Quote__c.SObjectType, DataConstants.Quote_iHASCO_RECORDTYPEDEVNAME);
		SBQQ__Quote__c quote = new SBQQ__Quote__c();
		quote.SBQQ__Opportunity2__c = oppoId;
		quote.RecordTypeId = quoteIhascoRecordtypeId;
		quote.SBQQ__Account__c = opp.accountId;
		quote.Quote_type__c = opp.Type;
		quote.SBQQ__StartDate__c = system.today();
		quote.SBQQ__PricebookId__c = iHASCOPBId;
		quote.SBQQ__PrimaryContact__c = primaryContact;
		quote.SBQQ__Primary__c = true;
		quote.SBQQ__PriceBook__c = iHASCOPBId;
		quote.License_Model__c = licenseModel;
		IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
		uow.insertRecords(new List<SBQQ__Quote__c>{ quote });
		return quote.Id;
	}
	private Id createiHASCOQuoteLines(String licenseModel, Id quoteId, Integer termInMonths, String termInYear, Id requiredById, String productName, Integer noOfUnits, Id groupId, Id iHASCOPBId, SBQQ__ProductOption__c productOption) {
		String parentProductName;
		Product2 prod = selector.getProductDetails(productName);
		SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
		ql.SBQQ__DefaultSubscriptionTerm__c = DataConstants.DEFAULT_SUB_TERM_12;
		if (licenseModel == DataConstants.QUOTE_USER_BASED) {
			ql.iHasco_Number_of_Users__c = noOfUnits;
			parentProductName = DataConstants.USERBASED_PRODUCT;
		} else if (licenseModel == DataConstants.QUOTE_OPEN_LICENSE) {
			ql.Ihasco_Number_of_Credits__c = noOfUnits;
			parentProductName = DataConstants.OPEN_LICENSE_PRODUCT;
		}
		if (requiredById != null) {
			ql.SBQQ__RequiredBy__c = requiredById;
			ql.SBQQ__OptionType__c = DataConstants.OPTION_TYPE_RELATED_PRODUCT;
			ql.SBQQ__ProductOption__c = productOption.Id;
			ql.SBQQ__DynamicOptionId__c = productOption.SBQQ__Feature__c + ':' + prod.Id;
		}
		ql.SBQQ__Quantity__c = 1;
		ql.SBQQ__PricebookEntryId__c = selector.getPriceBookEntry(prod.Id, iHASCOPBId);
		ql.SBQQ__BundledQuantity__c = 1;
		ql.SBQQ__PricingMethod__c = prod.SBQQ__PricingMethod__c;
		ql.SBQQ__Product__c = prod.Id;
		ql.SBQQ__BillingFrequency__c = prod.SBQQ__BillingFrequency__c;
		ql.SBQQ__BillingType__c = prod.SBQQ__BillingType__c;
		ql.SBQQ__SubscriptionPricing__c = prod.SBQQ__SubscriptionPricing__c;
		ql.SBQQ__SubscriptionBase__c = prod.SBQQ__SubscriptionBase__c;
		ql.Billing_Frequency__c = prod.SBQQ__BillingFrequency__c;
		ql.iHasco_Subscription_Term__c = termInMonths;
		ql.SBQQ__Group__c = groupId;
		ql.SBQQ__SubscriptionScope__c = DataConstants.QL_SUB_SCOPE_GROUP;
		ql.SBQQ__Quote__c = quoteId;
		ql.SBQQ__SubscriptionType__c = prod.SBQQ__SubscriptionType__c;
		ql.SBQQ__ProductSubscriptionType__c = prod.SBQQ__SubscriptionType__c;
		ql.Ihasco_Term__c = termInYear;
		IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
		uow.insertRecords(new List<SBQQ__QuoteLine__c>{ ql });
		return ql.Id;
	}
	public Map<string, SBQQ__ProductOption__c> getProductList(String licenseModel) {
		String productName;
		if (LicenseModel == DataConstants.QUOTE_OPEN_LICENSE) {
			productName = DataConstants.OPEN_LICENSE_PRODUCT;
		} else if (licenseModel == DataConstants.QUOTE_USER_BASED) {
			productName = DataConstants.USERBASED_PRODUCT;
		}
		return selector.getProductOptionList(productName);
	}

	private void setAgreementIssuedQuoteOnOpportunity(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> oldQuoteMap) {
		new AgreementIssuedQuoteOnOpportunity(quotes, oldQuoteMap, selector).process();
	}

	public class AgreementIssuedQuoteOnOpportunity {
		List<SBQQ__Quote__c> agreementQuoteList;
		ISelector selector;

		AgreementIssuedQuoteOnOpportunity(List<SBQQ__Quote__c> quoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap, ISelector selector) {
			this.agreementQuoteList = findQuoteToProcess(quoteList, oldQuoteMap);
			this.selector = selector;
		}

		void process() {
			if (agreementQuoteList.isEmpty())
				return;

			Id quoteCitationRecordtypeId = selector.getRecordTypeId(SBQQ__Quote__c.SObjectType, DataConstants.QUOTE_CITATION_RECORDTYPENAME);
			List<Opportunity> updatedOpportunityList = new List<Opportunity>();

			for (SBQQ__Quote__c quoteRecord : agreementQuoteList) {
				if (quoteRecord.RecordTypeId == quoteCitationRecordtypeId) {
					Opportunity opportunityRecord = new Opportunity();
					opportunityRecord.Id = quoteRecord.SBQQ__Opportunity2__c;
					opportunityRecord.StageName = DataConstants.OPPORTUNITY_STAGE_PROVISIONAL_AGREEMENT;
					updatedOpportunityList.add(opportunityRecord);
				}
			}

			if (!updatedOpportunityList.isEmpty()) {
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.updateRecords(updatedOpportunityList);
			}
		}

		List<SBQQ__Quote__c> findQuoteToProcess(List<SBQQ__Quote__c> quoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap) {
			List<SBQQ__Quote__c> agreementQuoteList = new List<SBQQ__Quote__c>();

			for (SBQQ__Quote__c quoteRecord : quoteList) {
				if (quoteRecord.SBQQ__Status__c == DataConstants.QUOTE_STATUS_AGREEMENT_ISSUED && oldQuoteMap.get(quoteRecord.Id).SBQQ__Status__c != DataConstants.QUOTE_STATUS_AGREEMENT_ISSUED) {
					agreementQuoteList.add(quoteRecord);
				}
			}
			return agreementQuoteList;
		}
	}

	public class CPQQuoteServiceSelector extends RecordTypeSelector implements CPQQuoteService.ISelector {
		public Id getPrimaryContact(String oppoId) {
			List<OpportunityContactRole> oppConRoleList = [
				SELECT Id, ContactId
				FROM OpportunityContactRole
				WHERE OpportunityId = :oppoId AND isPrimary = TRUE
			];
			if (oppConRoleList.size() > 0) {
				return oppConRoleList[0].ContactId;
			} else {
				return null;
			}
		}
		public Opportunity getOppDetails(String oppoId) {
			List<Opportunity> oppList = [SELECT Id, Type, AccountId FROM Opportunity WHERE Id = :oppoId];
			if (oppList.size() > 0) {
				return oppList[0];
			} else {
				throw new CustomException('No Opportunity found with id ' + oppoId);
			}
		}
		public Id getPriceBook(String priceBookName) {
			List<PriceBook2> pbList = [SELECT Id FROM PriceBook2 WHERE Name = :priceBookName];
			if (pbList.size() > 0) {
				return pbList[0].Id;
			} else {
				return null;
			}
		}
		public product2 getProductDetails(String productName) {
			List<product2> prodList = [
				SELECT Id, SBQQ__PricingMethod__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionType__c
				FROM Product2
				WHERE Name = :productName
			];
			if (prodList.size() > 0) {
				return prodList[0];
			} else {
				throw new CustomException('No Product found with Product Name ' + productName);
			}
		}
		public Id getPriceBookEntry(Id prodId, Id iHASCOPBId) {
			List<PricebookEntry> pbeList = [
				SELECT Id
				FROM PricebookEntry
				WHERE Product2Id = :prodId AND Pricebook2Id = :iHASCOPBId
			];
			if (pbeList.size() > 0) {
				return pbeList[0].Id;
			} else {
				return null;
			}
		}
		public Map<string, SBQQ__ProductOption__c> getProductOptionList(String productName) {
			Map<string, SBQQ__ProductOption__c> pordNameVsProdOptMap = new Map<string, SBQQ__ProductOption__c>();
			List<SBQQ__ProductOption__c> prodOptionList = [
				SELECT Id, SBQQ__ProductName__c, SBQQ__Feature__c
				FROM SBQQ__ProductOption__c
				WHERE SBQQ__ConfiguredSKU__c IN (SELECT Id FROM Product2 WHERE Name = :productName)
				ORDER BY SBQQ__ProductName__c
			];
			if (prodOptionList.size() > 0) {
				for (SBQQ__ProductOption__c prodOpt : prodOptionList) {
					pordNameVsProdOptMap.put(prodOpt.SBQQ__ProductName__c, prodOpt);
				}
				return pordNameVsProdOptMap;
			} else {
				throw new CustomException('No Product Options found with Product Name ' + productName);
			}
		}
	}
}