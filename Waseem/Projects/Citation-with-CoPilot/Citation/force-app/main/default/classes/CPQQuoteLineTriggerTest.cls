@isTest
public class CPQQuoteLineTriggerTest
{
	class Factory implements TriggerFrameworkTest.IFactory
	{
		private SBQQ__QuoteLine__c record;
		Factory()
		{
			Account act = new Account(Name = 'CPQ Hogwarts');
			insert act;
			
			Contact cont = new Contact(Lastname = 'CPQHarry',accountid =act.id );
			insert cont;
			
			Product2 prd = new Product2(name = 'cpq Product');
			insert prd;
			
			Pricebook2 prb = new Pricebook2(name = 'Product Pricebook');
			insert prb;
			
			PricebookEntry spbe = new 	PricebookEntry(Product2id=prd.id,pricebook2id = Test.getStandardPricebookId(),UnitPrice = 100);
			insert spbe;
			
			PricebookEntry cpbe = new 	PricebookEntry(Product2id=prd.id,pricebook2id = prb.id,UseStandardPrice=false,UnitPrice = 200);
			insert cpbe;
			
			SBQQ__Quote__c CPQQuote = new SBQQ__Quote__c(SBQQ__PrimaryContact__c = cont.id, 
														 SBQQ__Account__c = act.Id, 
														 SBQQ__StartDate__c = Date.today()+1,SBQQ__PricebookId__c = prb.id);
			insert CPQQuote;
			
			SBQQ__QuoteLineGroup__c CPQQuoteGroup = new SBQQ__QuoteLineGroup__c(name = 'Group 1',SBQQ__Quote__c = CPQQuote.id);
			insert CPQQuoteGroup;
			
			record = new SBQQ__QuoteLine__c(SBQQ__Quantity__c = 1,SBQQ__Quote__c = CPQQuote.id,SBQQ__ListPrice__c = 1000,SBQQ__SpecialPrice__c = 1000,SBQQ__Product__c = prd.id,SBQQ__PricebookEntryId__c = cpbe.id);
				
		}
		
		
		public ITriggerHandler getTriggerHandler(IDomainService service)
		{
			return new DefaultTriggerHandler(service, null);
		}
		
		public SObject getRecordToInsert()
		{
			return record;
		}
		
		public SObject getRecordToUpdate()
		{
			record.SBQQ__DefaultSubscriptionTerm__c = 12;
			return record;
		}
		
		public SObject getRecordToDelete()
		{
			return record;
		}
		
		public SObject getRecordToUndelete()
		{
			return record;
		}
	
	}
   
	@isTest
	private static void testFramework()
	{
		TriggerFrameworkTest.testDMLToService(new Factory());
	}
}