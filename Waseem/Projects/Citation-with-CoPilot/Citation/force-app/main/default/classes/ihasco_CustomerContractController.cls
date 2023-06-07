public without sharing class ihasco_CustomerContractController {
	
	public List<SBQQ__QuoteLine__c> quoteLine {get;set;} 
    public SBQQ__Quote__c quote {get;set;}
    public Decimal orderTotal {get;set;}
    //public Date renewalDate {get;set;}
    //public string Licencemodel {get;set;}
    public Contract contract {get;set;}

    public ihasco_CustomerContractController() {

		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        
        

        //Quote 
        quote = [SELECT SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, Account_Annual_Revenue__c, 
        				SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email, SBQQ__PrimaryContact__r.Phone,
 						SBQQ__Account__c,  SBQQ__Account__r.Company_Registration_Number__c,
 						SBQQ__Account__r.iHasco_Client_ID__c,SBQQ__Account__r.name,
 						SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c,
                        SBQQ__StartDate__c,PO_Reference__c,SBQQ__CustomerAmount__c,Annual_Price__c,	Year_One_Total__c
 				 FROM SBQQ__Quote__c
 				 WHERE Id = :quoteId
 				];
        //Contract
        contract = [SELECT Contract_Term_Years__c, Id, StartDate,EndDate FROM Contract WHERE SBQQ__Quote__c=:quoteId];

 
quoteLine = new List<SBQQ__QuoteLine__c>(); 		
 		//Quote Line
        quoteLine = [SELECT Id, SBQQ__ProductName__c, Ihasco_Number_of_Credits__c, Number_of_Credits__c,Parent_product_name__c,
                                SBQQ__Quantity__c, Ihasco_Term__c, SBQQ__SubscriptionTerm__c,Custom_Discount_Percentage__c,
                                SBQQ__CustomerTotal__c,SBQQ__ListTotal__c, SBQQ__BillingFrequency__c, SBQQ__CustomerPrice__c,Annual_Price__c,Year_One_Price__c,SBQQ__ProductCode__c
                            
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND SBQQ__Group__r.SBQQ__Optional__c = false AND SBQQ__ProductCode__c!='IHUBP' AND SBQQ__ProductCode__c!='IHCBP'AND SBQQ__ProductCode__c!='IHRPM'AND SBQQ__ProductCode__c!='IHRCBP'
                    ORDER BY SBQQ__Number__c
 					];
        orderTotal = 0; 
        /*for(sbQQ__quoteline__c ql:quoteline){
            if(ql.SBQQ__ListTotal__c > 0){
                orderTotal = orderTotal + ql.SBQQ__ListTotal__c;
            }
        }*/
		
    }
}