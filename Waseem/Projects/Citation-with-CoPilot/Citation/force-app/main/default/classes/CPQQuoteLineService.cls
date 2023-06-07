public inherited sharing class CPQQuoteLineService extends DefaultService implements ICPQQuoteLineService
{
	/*
	*   This implementation of the service will require a selector to handle loading
	*   records that it will need to perform its job.
	*/
	public interface ISelector
	{
		//The method returns the map of parent quote line id as key and child quote lines as value.
		Map<Id, List<SBQQ__QuoteLine__c>> getRelatedQuoteLines(Set<Id> parentLineIds);		
		Map<Id, Product2> getProducts(List<SBQQ__QuoteLine__c> quoteLines);
		List<SBQQ__Quote__c> getQuotesToUpdate(Set<Id> quoteIds);
	}
	
	/*
	*   Our selector that we were provided by what ever created us.
	*/
	private ISelector selector;

	public CPQQuoteLineService(ISelector selector) 
	{
		this.selector = selector;
	}
	
  	/*
	*   see IDomainService
	*/
	public override void setDefaults(List<SObject> newRecords)
	{
		List<SBQQ__QuoteLine__c> newQuoteLines = (List<SBQQ__QuoteLine__c>)newRecords;
		createQuoteGroups(newQuoteLines);
		setPriceAndPayment(newQuoteLines, null, selector);
		setBillingRelatedFields(newQuoteLines, selector);
		setSubscriptionTerm(newQuoteLines, selector);
		setEndDate(newQuoteLines);
	}

	/*
	*   see IDomainService
	*/
	public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
	{
		List<SBQQ__QuoteLine__c> newQuoteLines = (List<SBQQ__QuoteLine__c>)newRecords;
		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>)(oldRecords);
		createQuoteGroups(newQuoteLines);
		setPriceAndPayment(newQuoteLines, oldQuoteLineMap, selector);
		setBillingRelatedFields(newQuoteLines, selector);
		setSubscriptionTerm(newQuoteLines, selector);
		setEndDate(newQuoteLines);
	}

	/*
	*   see IDomainService
	*/
	public override void processRelatedRecordsOnNew(List<SObject> newRecords)
	{
	  	List<SBQQ__QuoteLine__c> newQuoteLines = (List<SBQQ__QuoteLine__c>)newRecords;
	   	setInvalidCPQProduct(newQuoteLines, null);
	}

	/*
	*   see IDomainService
	*/
	public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
	{
		List<SBQQ__QuoteLine__c> newQuoteLines = (List<SBQQ__QuoteLine__c>)newRecords;
		Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>)(oldRecords);
		setInvalidCPQProduct(newQuoteLines, oldQuoteLineMap);
	}

	/*
	*   see IDomainService
	*/
	public override void processRelatedRecordsOnDelete(List<SObject> objs)
	{
		List<SBQQ__QuoteLine__c> quoteLinesToProcess = (List<SBQQ__QuoteLine__c>)objs;
		callRollUpCalculationFuture(quoteLinesToProcess);		
	   	setInvalidCPQProduct(quoteLinesToProcess, null);
	}
	
	/*
	* This method will eventually call the future method with the parent Quote Line Ids 
	*/
	private void callRollUpCalculationFuture(List<SBQQ__QuoteLine__c> oldRecords)
	{
		new ChecktoCallFuture(oldRecords).process();
	} 
	
	private void setPriceAndPayment(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap, Iselector selector)
	{
		new PriceAndPayment(newQuoteLines, oldQuoteLineMap, selector).process();
	}

	private void setBillingRelatedFields(List<SBQQ__QuoteLine__c> newQuoteLines, Iselector selector)
	{
		new BillingRelatedFields(newQuoteLines, selector).process();
	}
	
	private void setSubscriptionTerm(List<SBQQ__QuoteLine__c> newQuoteLines, Iselector selector)
	{
		new SubscriptionTerm(newQuoteLines, selector).process();
	}

	private void setEndDate(List<SBQQ__QuoteLine__c> newQuoteLines)
	{
		new EndDate(newQuoteLines).process();
	}

	/*
	 * The method will create groups and assing them in the before context on quote lines 
	*/
	private void createQuoteGroups(List<SBQQ__QuoteLine__c> newQuoteLines)
	{
		new InsertGroupsForUngroupedLines(newQuoteLines).process();
	}

	private void setInvalidCPQProduct(List<SBQQ__QuoteLine__c> quoteLinesToProcess, Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap)
	{
		new InvalidCPQProductOnQuote(quoteLinesToProcess, oldQuoteLineMap, selector).process();
	}
	/*
	* The future method will be called from the after delete to rollup the Child Quote Line Totals 
	* to the parent Quote Line Sub Line Total
	*/ 
	@future(callout=true)
	private static void rollupViaFuture(Set<Id> parentQuoteLineIds) 
	{ 
		//This is calling a future method so we have to start with the service first
		ICPQQuoteLineService srv = new CPQQuoteLineService(new CPQQuoteLineService.CPQQuoteLineServiceSelector()); 
		srv.rollUpAmountToParentLine(parentQuoteLineIds); 
	}
	
	/*
	 * calling the inner class to rollup the child quotelines total 
	 */
	public void rollUpAmountToParentLine(Set<Id> parentQuoteLineIds)
	{
		new CalculateandRollUp(parentQuoteLineIds, selector).process();
	}
	
	public class CPQQuoteLineServiceSelector extends RecordTypeSelector implements CPQQuoteLineService.ISelector
	{
		/*
		 * Quries the child lines of a parent to rollup the quote line amount
		*/ 
		public Map<Id, List<SBQQ__QuoteLine__c>> getRelatedQuoteLines(Set<Id> parentQuoteLineIds)
		{ 
			List<SBQQ__QuoteLine__c> parent_childLines = new List<SBQQ__QuoteLine__c>();
			
			Map<Id, List<SBQQ__QuoteLine__c>> mapParentChild = new Map<Id, List<SBQQ__QuoteLine__c>>();	
			
			if(!parentQuoteLineIds.IsEmpty())
			{
				parent_childLines = [SELECT id, (select id, Total_Quote_Line__c from SBQQ__Quote_Lines__r where IsDeleted = false) from SBQQ__QuoteLine__c where id IN :parentQuoteLineIds AND IsDeleted = false]; 
			}
			
			for(SBQQ__QuoteLine__c parentLine: parent_childLines)
			{
				for(SBQQ__QuoteLine__c childLine:parentLine.SBQQ__Quote_Lines__r)
				{
					if(mapParentChild.containsKey(parentLine.id))
					{
						mapParentChild.get(parentLine.id).add(childLine);
					}
					else
					{
						mapParentChild.put(parentLine.id, new List<SBQQ__QuoteLine__c>{childLine});
					}
							
				}
			}
			return mapParentChild;
	   	}
		
		/*
		 * Quries the product details of the quote lines
		*/      
		public Map<Id, Product2> getProducts(List<SBQQ__QuoteLine__c> newRecords)
		{
			Set<Id> productIdstoQuery = getProductIdSet(newRecords);
			List<Product2> lineProducts = new List<Product2>();

			if(!productIdstoQuery.isEmpty())
				lineProducts = [select id, sbqq__billingfrequency__c  from product2 where id in :productIdstoQuery];
			
			return new Map<Id, Product2> (lineProducts);
		}
		
		private Set<Id> getProductIdSet(List<SBQQ__QuoteLine__c> newRecords)
		{
			Set<Id> productIds = new Set<Id>();
			
			for(SBQQ__QuoteLine__c  ql: newRecords)
			{
				if(ql.sbqq__product__c != null && ql.Quote_Price_book__c != 'QMS CPQ' && ql.billing_Frequency__c == null)
				{
					productIds.add(ql.sbqq__product__c);
				}
			}
			return productIds;
		}

		public List<SBQQ__Quote__c> getQuotesToUpdate(Set<Id> qlines)
		{
			List<SBQQ__Quote__c> quoteList = [select Id, Invalid_CPQ_Product__c, (select Id, Invalid_CPQ_Product__c from SBQQ__LineItems__r ) from SBQQ__Quote__c where Id in: qlines];
			return quoteList;
		}
	}

	private class PriceAndPayment
	{
		private List<SBQQ__QuoteLine__c> newRecords;
		private ISelector selector;
		private Map<Id, SBQQ__QuoteLine__c> oldRecords;
		private string CPQQMSBusinessTypeName = System.label.CPQ_QMS_Business_Type_Name ;
		private string CPQFreeMonthProductName = System.label.CPQ_Free_Month_Product_Name ;
		private string CPQSetupFeeProductName = System.label.CPQ_Set_up_Fee_Product_Name ;
		
		PriceAndPayment(List<SBQQ__QuoteLine__c> newRecords, Map<Id, SBQQ__QuoteLine__c> oldRecords, ISelector selector)
		{
			this.newRecords = newRecords;
			this.oldRecords = oldRecords;
			this.selector = selector;
		}

		void process()
		{
			if(newRecords == null)
				return;
			
			for(SBQQ__QuoteLine__c qline: newRecords)
			{
				if(qline.Quote_Price_book__c != 'QMS CPQ')
				{
					setSpecialPriceAndType(qline);
				}
				
				if(oldRecords == Null)
				{
					if(qline.Sum_of_Children_Price_Per_Billing__c > 0 && qline.sbqq__specialprice__c == 0 || qline.sbqq__specialprice__c == null)
					{
						copyInitialPaymentFromSubLineTotal(qline);
					}
					  
				}
				else
				{
					if(oldRecords.get(qline.id).Sub_Lines_Total_Monthly_Payment__c != qline.Sub_Lines_Total_Monthly_Payment__c)
					{
						copyInitialPaymentFromSubLineTotal(qline);
					}
					
					if((qline.initial_payment__c == 0  || qline.initial_payment__c == null || (qline.custom_total_discount_amount__c != oldRecords.get(qline.id).custom_total_discount_amount__c)) )
					{
						setInitialPayment(qline);
					}
				}
			}
		}
		
		void copyInitialPaymentFromSubLineTotal(SBQQ__QuoteLine__c qline)
		{
		
			if(qline.Product_Business_Type__c == CPQQMSBusinessTypeName)
			{
				qline.initial_payment__c = qline.Sub_Lines_Total_Monthly_Payment__c ;
			}
		}
		
		void setSpecialPriceAndType(SBQQ__QuoteLine__c qline){

			
			/* this condition remvoed from inside the next one to try force the specialprice to stick for ISO sub lines*/
			if(qline.sbqq__product__c != null && qline.sbqq__requiredby__c != null && qline.Product_Business_Type__c == CPQQMSBusinessTypeName ) 
			{
				qline.sbqq__specialprice__c = qline.price_per_billing_frequency__c  ;							 
			} 
				
			/* copies listprice to special price if it's not populated yet - to help calculation to work on add prod page */
				
			else 
			{ /* ATTEMPT FORCED OVERRIDE */		    	
				qline.sbqq__specialprice__c = qline.SBQQ__ListPrice__c ; 
			}
			qline.SBQQ__SpecialPriceType__c = 'Custom' ;	
		}
		
		void setInitialPayment(SBQQ__QuoteLine__c qline)
		{
			if(qline.sbqq__product__c != null && qline.sbqq__requiredby__c != null && qline.Product_Business_Type__c == CPQQMSBusinessTypeName )
			{
				if(qline.Custom_Discount_Amount__c >0 ) 
				{
					qline.initial_payment__c = (qline.SBQQ__Listprice__c - (qline.Custom_Discount_Amount__c * qline.sbqq__quantity__c)) ;
				}
				else if (qline.Custom_Discount_Percentage__c >0) 
				{
					qline.initial_payment__c = (qline.SBQQ__Listprice__c)  * ((100 - qline.Custom_Discount_Percentage__c)/100);
				}
				else 
				{
					qline.initial_payment__c = (qline.SBQQ__Listprice__c) ;
				}    
			}
			else
			{
				if(qline.sbqq__SpecialPrice__c > 0) 
				{
					
					if(qline.Custom_Discount_Amount__c > 0 ) 
					{
						qline.initial_payment__c = ((qline.sbqq__specialprice__c * qline.sbqq__quantity__c) - (qline.Custom_Discount_Amount__c * qline.sbqq__quantity__c)) ;
					} 
					else if (qline.Custom_Discount_Percentage__c > 0) 
					{
						qline.initial_payment__c = (qline.sbqq__specialprice__c * qline.sbqq__quantity__c)  * ((100 - qline.Custom_Discount_Percentage__c)/100);
					}
					else 
					{
						qline.initial_payment__c = (qline.sbqq__specialprice__c * qline.sbqq__quantity__c) ;
					}					 					
				}
			}
		}
	}
	

	private class SubscriptionTerm
	{
		private List<SBQQ__QuoteLine__c> newQuoteLines;
		private ISelector selector;
		private string CPQQMSBusinessTypeName = System.label.CPQ_QMS_Business_Type_Name ;
		private string CPQFreeMonthProductName = System.label.CPQ_Free_Month_Product_Name ;
		private string CPQSetupFeeProductName = System.label.CPQ_Set_up_Fee_Product_Name ;
		
		SubscriptionTerm(List<SBQQ__QuoteLine__c> newQuoteLines, ISelector selector)
		{
			this.newQuoteLines = newQuoteLines;
			this.selector = selector;
		}

		void process()
		{
			for(SBQQ__QuoteLine__c qline:  newQuoteLines)
			{
				if(qline.Quote_Price_book__c != 'QMS CPQ')
				{
					if(isQMSBusinessType(qline) && isSubscriptionTermDifferentFromGroupTerm(qline))
					{
						qline.sbqq__SubscriptionTerm__c = qline.Group_Term__c ;		            
					}
				}
			}
		}

		Boolean isQMSBusinessType(SBQQ__QuoteLine__c qline)
		{
			if(qline.Product_Business_Type__c != null)
			{
				return (qline.sbqq__requiredby__c == null && qline.Product_Business_Type__c == CPQQMSBusinessTypeName)
				||	(qline.Product_Business_Type__c != CPQQMSBusinessTypeName &&  
					qline.SBQQ__ProductName__c != CPQFreeMonthProductName &&
					qline.SBQQ__ProductName__c != CPQSetupFeeProductName
					);
			}
			else
			{
				return false;
			}
		}   

		Boolean isSubscriptionTermDifferentFromGroupTerm(SBQQ__QuoteLine__c qline)
		{
			return qline.Group_Term__c != null && qline.sbqq__SubscriptionTerm__c != qline.Group_Term__c;
		}
	}

	private class EndDate
	{
		private List<SBQQ__QuoteLine__c> newQuoteLines;

		EndDate(List<SBQQ__QuoteLine__c> newQuoteLines)
		{
			this.newQuoteLines = newQuoteLines;
		}

		void process()
		{
			for(SBQQ__QuoteLine__c qline:  newQuoteLines)
			{
				if(qline.Quote_Price_book__c != 'QMS CPQ')
				{
					qline.sbqq__EndDate__C = qline.service_end_date__c ;
				}
			}
		}

	}

	private class BillingRelatedFields
	{
		private List<SBQQ__QuoteLine__c> newQuoteLines;		
		private ISelector selector;
		
		BillingRelatedFields(List<SBQQ__QuoteLine__c> newQuoteLines, ISelector selector)
		{
			this.newQuoteLines = newQuoteLines;
			this.selector = selector;
		}

		void process()
		{
			Map<Id, Product2> productMap;
			productMap = selector.getProducts(newQuoteLines);
			String productBillingFrequency;
			for(SBQQ__QuoteLine__c qline:  newQuoteLines)
			{
				if(qline.Quote_Price_book__c != 'QMS CPQ')
				{
					/* firstly, lets see if the line is linked to a product and that product has a billing frequency */
					/*  if so, set that onto the quoteline */		 		
								
					if(qline.billing_Frequency__c == null) 
					{
			
						if(qline.sbqq__product__c != null ) 
						{
							productBillingFrequency = productMap.get(qline.sbqq__product__c).SBQQ__BillingFrequency__c ;

							qline.billing_Frequency__c = productBillingFrequency ;
						}
					}
					
					/* next we try and set the billign type and term, which in turn enables the number of regular payments and regular payment amount to calculate */
							
					qline.sbqq__BillingFrequency__c = qline.billing_Frequency__c ;
					if(qline.billing_Frequency__c == 'Monthly' ) 
					{
						qline.billing_term__c = 'Monthly' ;
						
						if(qline.Initial_Payment__c != qline.Regular_Payment__c) 
						{
							qline.FF_Billing_Type__c = 'Recurring Variable' ;
						} 
						else
						{
							qline.FF_Billing_Type__c = 'Recurring Fixed' ;
						}    			
						
					}
									
					if(qline.billing_Frequency__c == 'Annual' ) {

						qline.billing_term__c = 'Annually' ;

						if(qline.Initial_Payment__c != qline.Regular_Payment__c) 
						{
							qline.FF_Billing_Type__c = 'Recurring Variable' ;
						} 
						else
						{
							qline.FF_Billing_Type__c = 'Recurring Fixed' ;
						}    			
						
					}
									
					if(qline.billing_Frequency__c == 'One-Off') 
					{
						qline.FF_Billing_Type__c = 'One Off' ;
						qline.billing_term__c = null ;
					}
				}
			}
			
		}
	}
	
	private class CalculateandRollUp
	{
		private Set<Id> parentQuoteLineIds;
		private ISelector selector;
		
		CalculateandRollUp(Set<Id> parentQuoteLineIds, ISelector selector)
		{
			this.parentQuoteLineIds = parentQuoteLineIds;
			this.selector = selector;
		}

		void process()
		{
			if(parentQuoteLineIds == null)
				return;
			
			List<SBQQ__QuoteLine__c> parentQuoteLines = new List<SBQQ__QuoteLine__c>();
			Map<Id, List<SBQQ__QuoteLine__c>> parentChildMap = selector.getRelatedQuoteLines(parentQuoteLineIds);
			for(Id parentLineId : parentChildMap.keySet())
			{
				SBQQ__QuoteLine__c	parentLine = new SBQQ__QuoteLine__c();
				parentLine.id = parentLineId;
				parentLine.Sub_Line_Total__c = 0; 
				
				for(SBQQ__QuoteLine__C childQuoteLine: parentChildMap.get(parentLineId))
				{
					parentLine.Sub_Line_Total__c = parentLine.Sub_Line_Total__c + childQuoteLine.Total_Quote_Line__c;    
				}
				
				parentQuoteLines.add(parentLine);                 
			}
		
			if(!parentQuoteLines.isEmpty())
			{   
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.updateRecords(parentQuoteLines);
			}  
		}
	}
	
	private class ChecktoCallFuture
	{
		private List<SBQQ__QuoteLine__C> quoteLines;
		private Set<Id> parentQuoteLineIds = new Set<Id>();
		private List<SBQQ__QuoteLine__c> parent_childLines = new List<SBQQ__QuoteLine__c>();
		
		ChecktoCallFuture(List<SBQQ__QuoteLine__c> quotelines)
		{
			this.quoteLines = quotelines;	            
		}
		
		void process()
		{
			
			for(SBQQ__QuoteLine__c quoteLine: quotelines)
			{
				if(quoteLine.SBQQ__RequiredBy__c != null)
				{
					parentQuoteLineIds.add(quoteLine.SBQQ__RequiredBy__c);    
				}
			}
			
			if(!parentQuoteLineIds.IsEmpty())
			{
				// CPQ issue due to call outs and trigger interaction - this needs calling from a futur
				rollupViaFuture(parentQuoteLineIds); 
			}    
		}
	}
	
	private class InsertGroupsForUngroupedLines
	{
		private List<SBQQ__QuoteLine__c> quoteLines;

		InsertGroupsForUngroupedLines(List<SBQQ__QuoteLine__c> newQuoteLines)
		{
			this.quoteLines = newQuoteLines;
		}
		
		void process()
		{
			Map<Id, SBQQ__QuoteLineGroup__c> newGroups = new Map<Id, SBQQ__QuoteLineGroup__c>() ;
			
			for(SBQQ__QuoteLine__c ql : quoteLines) 
			{
				if(ql.SBQQ__Group__c == null && ql.SBQQ__Quote__c != null) 
				{
					newGroups.put(ql.SBQQ__Quote__c, new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = ql.SBQQ__Quote__c, name=System.label.Referral_Product_Warning, SBQQ__Number__c=0 )) ;
	
				}
			}

			if(!newGroups.isEmpty()) 
			{
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.insertRecords(newGroups.values());
				
				for(SBQQ__QuoteLine__c ql : quoteLines) 
				{
					if(ql.SBQQ__Group__c == null) 
					{
						ql.SBQQ__Group__c = newgroups.get(ql.SBQQ__Quote__c).id ;
					}
				}
			}    
		}
	}

	private class InvalidCPQProductOnQuote
	{
		private List<SBQQ__QuoteLine__c> quoteLinesToProcess;
		private Iselector selector;
		private Map<Id, SBQQ__QuoteLine__c> oldRecords;
		
		InvalidCPQProductOnQuote(List<SBQQ__QuoteLine__c> quoteLinesToProcess, Map<Id, SBQQ__QuoteLine__c> oldRecords, Iselector selector)
		{
			this.quoteLinesToProcess = quoteLinesToProcess;
			this.oldRecords = oldRecords;
			this.selector = selector;
		}
		void process()
		{
			Set<Id> quoteIdSet = new Set<Id>();

			if(quoteLinesToProcess == Null || quoteLinesToProcess.isEmpty())
				return;
			
			for(SBQQ__QuoteLine__c qLine : quoteLinesToProcess)
			{
				// on update
				if(oldRecords != null && !oldRecords.isEmpty() && (qLine.SBQQ__Product__c != oldRecords.get(qLine.Id).SBQQ__Product__c))
				{
					quoteIdSet.add(qLine.SBQQ__Quote__c);
				} 
				// on insert or delete
				else if (oldRecords == null || oldRecords.isEmpty() )
				{
					quoteIdSet.add(qLine.SBQQ__Quote__c);
				}
			}
			if(!quoteIdSet.isEmpty())
				updateCPQQuote(quoteIdSet);
		}
		void updateCPQQuote(Set<Id> quoteIds)
		{
			Map<Id, SBQQ__Quote__c> quotesToUpdateMap = new Map<Id, SBQQ__Quote__c>();
			List<SBQQ__Quote__c> quoteList = selector.getQuotesToUpdate(quoteIds);
			for(SBQQ__Quote__c quoteRecord : quoteList)
			{
				Boolean invalid = false;

				List<SBQQ__QuoteLine__c> lines = quoteRecord.SBQQ__LineItems__r;
				if(lines != null || !lines.isEmpty())
				{
					for(SBQQ__QuoteLine__c line: lines)
					{
						invalid = invalid || line.Invalid_CPQ_Product__c;
					}
				}

				if(quoteRecord.Invalid_CPQ_Product__c != invalid)
				{
					quoteRecord.Invalid_CPQ_Product__c = invalid;
					quotesToUpdateMap.put(quoteRecord.Id, quoteRecord);
				}
			}
			List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>(quotesToUpdateMap.values());
			if(!quotesToUpdate.isEmpty())
			{
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.updateRecords(quotesToUpdate);
			}			
		}
	}
}