public class qms_CertificationProductsController {
	
	public List<SBQQ__QuoteLine__c> quoteLine {get;set;} 
    public SBQQ__Quote__c quote {get;set;} 
    public Decimal Totalamount {get;set;}
    public Decimal TotalSites {get;set;}
    public Decimal Additionsites {get;set;}
    public Decimal primarySiteGAdays {get;set;}
    public String Certificationnames {get;set;}
    
      
    public qms_CertificationProductsController() {
        
        Totalamount = 0;
        TotalSites = 0;
        Additionsites = 0;
        primarySiteGAdays = 0;
		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        
 		//Quote Line
 		quoteLine = [SELECT Id, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__Product__r.Description, SBQQ__Quote__r.Account_No_Of_Sites__c,
 					Total_Quote_Line__c , SBQQ__ProductName__c, SBQQ__Quantity__c , Term__c ,Price_per_Billing_Frequency__c,
                    SBQQ__Quote__r.SBQQ__Opportunity2__r.Sites__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c,
                    SBQQ__Quote__r.Primary_Site_Gap_Analysis_Days__c , SBQQ__Quote__r.Service_Type__c,SBQQ__NetTotal__c
 					FROM SBQQ__QuoteLine__c
 					WHERE SBQQ__Quote__c = :quoteId
 					AND	 SBQQ__RequiredBy__c != null 
                    AND SBQQ__Product__r.Family = 'Certification'
	 				];
        
        quote =  [SELECT id, SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c,
                 Primary_Site_Gap_Analysis_Days__c, SBQQ__Opportunity2__r.Sites__c
                 FROM SBQQ__Quote__c WHERE id = :quoteId];
        
        TotalSites = quote.SBQQ__Opportunity2__r.Sites__c ;
        Additionsites = quote.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c;
        primarySiteGAdays = quote.Primary_Site_Gap_Analysis_Days__c; 
        
        for(SBQQ__QuoteLine__c qli : quoteLine){
            Totalamount = Totalamount + qli.SBQQ__NetTotal__c;
            if(!((Certificationnames == '') || (Certificationnames == NULL) )){
                Certificationnames = Certificationnames + ', ' + qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            } else {
                Certificationnames = qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
            }
        }
 					
	
    }

}