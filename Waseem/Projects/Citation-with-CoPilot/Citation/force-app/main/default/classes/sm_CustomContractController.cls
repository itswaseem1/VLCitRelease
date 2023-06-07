public with sharing class sm_CustomContractController {

	public SBQQ__QuoteTemplate__c template {get;set;}
	public List<SBQQ__QuoteLineGroup__c> quoteLineGroups {get;set;} 	
	public List<SBQQ__QuoteLine__c> quoteLine {get;set;} 
	public Double SUM_Price_per_Billing_Frequency {get;set;}
	public Double SUM_GroupedPrice_per_Billing_Frequency {get;set;}
    public boolean RenderNSF {get;set;}
    public Integer COUNT_BT  {get;set;}
    public boolean Render2Sig {get;set;}
    public SBQQ__Quote__c quote {get;set;}
 //   public Contact PrimaryContact {get;set;}  
    public List<SBQQ__QuoteLineGroup__c> QMSquoteLineGroups {get;set;}
    
    public Boolean PremiumFlag {get;set;} 	
    public Boolean SynergyFlag {get;set;} 
    public Boolean ComplianceFlag {get;set;}  	
    public Boolean TransferFlag {get;set;}  	
    public Boolean AdditionalCompanyFlag {get;set;}  	
    public Boolean UKASFlag {get;set;}  	
    public Boolean CoreFlag {get;set;}  	
    public Boolean TPSMFlag {get;set;}  	
    public Boolean ConsultancyFlag {get;set;} 
    public Boolean BS8522Flag {get;set;}
    public Boolean ISO45001Flag {get;set;}
    public Boolean BS15713Flag {get;set;}
    
      
    public sm_CustomContractController() {

		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        Id templateId = (Id)ApexPages.currentPage().getParameters().get('tid');
        
        //Template
        template = [SELECT SBQQ__CompanyStreet__c, SBQQ__CompanyCity__c, SBQQ__CompanyState__c, SBQQ__CompanyPostalCode__c, SBQQ__CompanySlogan__c
        		FROM SBQQ__QuoteTemplate__c
        		WHERE Id = :templateId	];
        
        //Quote 
        quote = [SELECT SBQQ__SalesRep__c, SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, Account_Annual_Revenue__c, 
        				SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email, SBQQ__PrimaryContact__r.Phone,
 						SBQQ__Account__c, SBQQ__Account__r.Staff__c,  SBQQ__Account__r.TotalNoUKoffices__c, SBQQ__Account__r.TotalNoInternationalOffices__c,
 						SBQQ__Account__r.Company_VAT_Number__c, SBQQ__Account__r.Company_Registration_Number__c, SBQQ__Account__r.Website,
 						Number_Of_Full_Time_Employees__c, Number_of_Part_Time_Employees__c, Number_of_Complex_Sites__c, Number_of_Standard_Sites__c,
 						SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c,
 						SBQQ__BillingFrequency__c, Contract__c,  Contract__r.ContractNumber,
 						Deal_Start_Date__c, Subsidiary_and_associated_companies__c, FTE__c, Payroll__c, Total_Sites__c, SBQQ__StartDate__c
 				 FROM SBQQ__Quote__c
 				 WHERE Id = :quoteId
 				];
       
       //Customer Signatory 
  /*     if(quote.Customer_Signatory__c != null)
       { 
       		Customer_Signatory = [SELECT name, Email, phone 
 								FROM contact
 								WHERE Id = :quote.Customer_Signatory__c ];
       }					
 	*/						
       //Quote Line Groups
       quoteLineGroups = [SELECT Id, Name, SBQQ__ListTotal__c, SBQQ__NetTotal__c, Price_per_Billing_Frequency__c, SBQQ__Optional__c, Term_Years__c,
        						(SELECT Id, SBQQ__ProductName__c, SBQQ__Product__r.Detail_of_Service__c,  SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, SBQQ__StartDate__c, Users__c, Sites__c 
        						FROM SBQQ__LineItems__r 
        						WHERE SBQQ__Product__r.SBQQ__Hidden__c = false
        						ORDER BY  Price_per_Billing_Frequency__c desc, SBQQ__ProductName__c, Term__c, SBQQ__Number__c) 
        					FROM SBQQ__QuoteLineGroup__c 
        					Where SBQQ__Quote__c = :quoteId
        					And SBQQ__Optional__c = false
        					ORDER BY Name];
 
 		
 		//Quote Line
 		quoteLine = [SELECT Id, SBQQ__ProductName__c, SBQQ__Product__r.Detail_of_Service__c,  SBQQ__Product__r.Business_Type__c, SBQQ__Product__r.SBQQ__Hidden__c, SBQQ__RequiredBy__c,
 								SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, SBQQ__StartDate__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c,  SBQQ__SubscriptionTerm__c,
 								SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c, 
 								SBQQ__Product__r.Product_Type__c, SBQQ__Product__r.Service_Type__c,
 								Users__c, Sites__c, Tribunal_case_number__c,
 							SBQQ__Quote__r.Deal_Start_Date__c, SBQQ__CustomerTotal__c, Additional_Discount_Message__c,
 							(SELECT Id, SBQQ__ProductName__c , Users__c, Sites__c, Tribunal_case_number__c, SBQQ__SubscriptionTerm__c
 							FROM SBQQ__Quote_Lines__r 
 							where SBQQ__Product__r.SBQQ__Hidden__c = false
 							and Price_per_Billing_Frequency__c = 0)
 					FROM SBQQ__QuoteLine__c
 					WHERE SBQQ__Quote__c = :quoteId
 					AND SBQQ__Group__r.SBQQ__Optional__c = false
 					AND
 					(
	 					(
	 						SBQQ__Product__r.Business_Type__c = 'QMS'
	 						AND 
	 						SBQQ__Product__r.SBQQ__Hidden__c != true
	 					)
	 					OR
	 					(
	 						SBQQ__Product__r.Business_Type__c != 'QMS'
	 						AND
	 						SBQQ__Product__r.SBQQ__Hidden__c = false 							
	 						AND 
	 						Price_per_Billing_Frequency__c <> 0
	 						//	AND SBQQ__RequiredBy__c != ''
	 					)
 					) 					
 								
 					ORDER BY  SBQQ__Group__r.Name, SBQQ__ProductName__c, Price_per_Billing_Frequency__c desc, SBQQ__ProductName__c, Term__c, SBQQ__Number__c
 					];
 					
 				
 		//Quote Line group (Aggregated)
 		AggregateResult[] groupedResults_sumBill = [SELECT SUM(Price_per_Billing_Frequency__c) SUM_per_bill
		        									FROM SBQQ__QuoteLineGroup__c 
						        					Where SBQQ__Quote__c = :quoteId
						        					And SBQQ__Optional__c = false
						        					];
						        					
		//Quote Line group (Aggregated)
 		AggregateResult[] groupedResults_sumFroupItemsBill = [SELECT SUM(Price_per_Billing_Frequency__c) SUM_per_bill
					        									FROM SBQQ__QuoteLine__c 
									        					Where SBQQ__Quote__c = :quoteId
									        					And SBQQ__Group__r.SBQQ__Optional__c = false
									        					];				        					
						
        						
		SUM_GroupedPrice_per_Billing_Frequency = (Double)groupedResults_sumFroupItemsBill[0].get('SUM_per_bill');
		
		SUM_Price_per_Billing_Frequency = (Double)groupedResults_sumBill[0].get('SUM_per_bill');
		
		
		//Quote Line (Aggregated)
		AggregateResult[] groupedResults_QL = [SELECT count(SBQQ__Product__r.Business_Type__c) COUNT_busType
							 					FROM SBQQ__QuoteLine__c
							 					WHERE SBQQ__Quote__c = :quoteId
							 					AND SBQQ__Group__r.SBQQ__Optional__c = false
							 					AND SBQQ__Product__r.Business_Type__c = 'QMS'
							 					];
		
		COUNT_BT = (Integer)groupedResults_QL[0].get('COUNT_busType');
		
			
		
		//if the contract as an QMS product then add NSF
		if(COUNT_BT > 0)
		{
			RenderNSF = true;
		}
		else
		{
			RenderNSF = false;
		}
		
	
		// Second Signiture Required
		SBQQ__Quote__c quote = [SELECT Second_Signatory_Required__c				
				 				 FROM SBQQ__Quote__c
				 				 WHERE Id = :quoteId
				 				 ];
	
		if(quote.Second_Signatory_Required__c == 'yes')
		{
			Render2Sig = true;
		}
		else
		{
			Render2Sig = false;
		}
		
		
		//Quote lines - for QMS
		 QMSquoteLineGroups = [SELECT Id, 
        						Name, 
        						SBQQ__SubscriptionTerm__c, 
        						SBQQ__ListTotal__c, 
        						SBQQ__NetTotal__c, 
        						Price_per_Billing_Frequency__c, 
        						Bundle_Price__c,
	        						(SELECT Id, 
	        								SBQQ__ProductName__c,
	        								SBQQ__Product__r.ProductCode,  
	        								SBQQ__Product__r.Service_Type__c,
	        								SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,
	        								SBQQ__RequiredBy__r.SBQQ__ProductName__c,  
	        								SBQQ__ListPrice__c,  
	        								SBQQ__CustomerTotal__c,
	        								SBQQ__Product__r.Product_Type__c, 
	        								SBQQ__Product__r.SBQQ__Hidden__c, 
	        								SBQQ__Quantity__c, 
	        								Price_per_Billing_Frequency__c, 
	        								Term__c , 
	        								Additional_Discount_Message__c,
	        								SBQQ__Quote__c, 
	        								SBQQ__SubscriptionTerm__c
	        						FROM SBQQ__LineItems__r 
	        						Where SBQQ__Product__r.SBQQ__Hidden__c = false
	        						ORDER BY SBQQ__ProductName__c, Price_per_Billing_Frequency__c desc, 
	        									Term__c, 
	        									SBQQ__Number__c) 
        					FROM SBQQ__QuoteLineGroup__c 
        					Where SBQQ__Quote__c = :quoteId
        					AND SBQQ__Optional__c = false
        					ORDER BY SBQQ__Number__c, Name];
	
			PremiumFlag = false;
 			SynergyFlag = false; 	
 			ComplianceFlag = false;
 			TransferFlag = false;
 			AdditionalCompanyFlag = false;
 			UKASFlag = false; 	
 			CoreFlag = false; 	
 			TPSMFlag = false; 	
 			ConsultancyFlag = false;
 			BS8522Flag  = false;
 			ISO45001Flag  = false;
 			BS15713Flag = false;
 			
 			
 			for(SBQQ__QuoteLineGroup__c qg : QMSquoteLineGroups)
  			{
  				for(SBQQ__QuoteLine__c ql: qg.SBQQ__LineItems__r)
  				{
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Premium') { PremiumFlag = true; 	}
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Synergy') { SynergyFlag = true; 	}
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Compliance') { ComplianceFlag = true;  }
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Transfer') { TransferFlag = true; }
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Additional Company') { AdditionalCompanyFlag = true; }
  					if(ql.SBQQ__Product__r.Service_Type__c == 'UKAS') { UKASFlag = true; }
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Core') { CoreFlag = true; }
  					if(ql.SBQQ__Product__r.Service_Type__c == 'TPSM') { TPSMFlag = true; }
  					if(ql.SBQQ__Product__r.Service_Type__c == 'Consultancy') { ConsultancyFlag = true; }
  					
  					if(ql.SBQQ__Product__r.ProductCode == 'BS 8522-OTH') { BS8522Flag  = true; }
  					if(ql.SBQQ__Product__r.ProductCode == 'ISO 45001-A') { ISO45001Flag  = true; }
  					if(ql.SBQQ__Product__r.ProductCode == 'BS 15713-A') { BS15713Flag = true; }
  					
  				}
  			}
		
    }
    	
}