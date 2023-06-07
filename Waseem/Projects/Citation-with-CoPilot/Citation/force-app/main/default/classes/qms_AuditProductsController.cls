public class qms_AuditProductsController {
	
	public List<SBQQ__QuoteLine__c> quoteLine {get;set;} 
    public SBQQ__Quote__c quote {get;set;} 
    public Decimal Totalamount {get;set;}
    public Decimal TotalSites {get;set;}
    public Decimal AdditionAuditDays {get;set;}
    public Decimal AuditDays {get;set;}
    public String Certificationnames {get;set;}
    public Decimal TotalDeposit {get;set;}
    
      
    public qms_AuditProductsController() {
        
        Totalamount = 0;
        TotalSites=0;
        AdditionAuditDays= 0;
        TotalDeposit = 0;
		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        
 		//Quote Line
 		quoteLine = [SELECT Id, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__Product__r.Description, SBQQ__Quote__r.Account_No_Of_Sites__c,
 					Total_Quote_Line__c , SBQQ__ProductName__c, SBQQ__Quantity__c , Term__c ,Price_per_Billing_Frequency__c,
                    SBQQ__Quote__r.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c,SBQQ__NetTotal__c,
                    SBQQ__Quote__r.SBQQ__Opportunity2__r.Audit_Days__c,Deposit__c
 					FROM SBQQ__QuoteLine__c
 					WHERE SBQQ__Quote__c = :quoteId
 					AND	 SBQQ__RequiredBy__c != null 
                    AND SBQQ__Product__r.Family = 'Audit'
	 				];
        quote = [SELECT id,name,Account_Annual_Revenue__c,SBQQ__BillingStreet__c,SBQQ__BillingCity__c,Account_Total_Employees__c,
                 SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, Account_Name__c,SBQQ__Account__r.TotalNoUKoffices__c,
                 SBQQ__Account__r.TotalNoInternationalOffices__c,SBQQ__Opportunity2__r.Primary_Site_Audit_Days__c,
                 SBQQ__Opportunity2__r.Audit_Days__c, SBQQ__Opportunity2__r.Sites__c
                 FROM SBQQ__Quote__c WHERE id = :quoteId];
        
        TotalSites = quote.SBQQ__Opportunity2__r.Sites__c;
        AuditDays = quote.SBQQ__Opportunity2__r.Audit_Days__c;
        if(quote.SBQQ__Opportunity2__r.Primary_Site_Audit_Days__c != null){
        AdditionAuditDays = quote.SBQQ__Opportunity2__r.Audit_Days__c - quote.SBQQ__Opportunity2__r.Primary_Site_Audit_Days__c;
        } else{
            AdditionAuditDays = quote.SBQQ__Opportunity2__r.Audit_Days__c;
        }
        
        for(SBQQ__QuoteLine__c qli : quoteLine){
            Totalamount = Totalamount + qli.SBQQ__NetTotal__c;  
            if(qli.Deposit__c != null){
                TotalDeposit = TotalDeposit + qli.Deposit__c;
            }
            if(!((Certificationnames == '') || (Certificationnames == NULL) )){
                Certificationnames = Certificationnames + ', ' + qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            } else {
                Certificationnames = qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            }
        }
 					
	
    }

}