public with sharing class iHASCOQuoteTemplateController {
    
    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}   
    public Integer term{get;set;}
    public Decimal Aprice{get;set;}
    public Decimal price{get;set;}
    public string paymentterm{get;set;}
    public decimal annualPrice{get;set;}
    public decimal firstyearprice{get;set;}
    public SBQQ__Quote__c quote {get;set;}
    public User salesRep {get;set;}
    
    public Boolean CreditFlag {get;set;}   
    public Boolean AnnualFlag {get;set;}
    public Boolean UserFlag {get;set;}
    public Boolean RestrictedFlag {get;set;}
    public Boolean notPilotOrder {get;set;}
    public Boolean notTopUp {get;set;}
    
    
    public list<account> getBlank() {
        list<account> acc = new list<account>() ;
        acc.add(new account(name='test')) ;
        return acc ;
    }
    
    public iHASCOQuoteTemplateController() {
        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        
        //Quote Line 
        quoteLines = [SELECT Sub_Lines_Total_Monthly_Payment__c,SBQQ__BillingFrequency__c,Custom_Discount_Percentage__c, Total_Quote_Line__c, Id, Name, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, 
                      SBQQ__ProductName__c, SBQQ__Product__r.Business_Type__c, SBQQ__Quantity__c, SBQQ__Product__r.SBQQ__BillingFrequency__c,
                      SBQQ__CustomerPrice__c,Price__c,regular_payment__c, initial_payment__c,SBQQ__CustomerTotal__c,SBQQ__Quote__r.Quote_type__c,
                      SBQQ__Quote__r.Deal_Start_Date__c,SBQQ__Product__r.ProductCode,Cost_per_Credit__c,Ihasco_Number_of_Credits__c,
                      Users__c, Sites__c, Size__c, Billing_frequency__c, Ihasco_Term__c, SBQQ__ProductCode__c, SBQQ__RequiredBy__c,
                      SBQQ__Group__r.Id, SBQQ__Group__r.Name, SBQQ__Group__r.SBQQ__SubscriptionTerm__c, SBQQ__Group__r.SBQQ__ListTotal__c, 
                      SBQQ__Group__r.SBQQ__NetTotal__c, SBQQ__ListPrice__c,SBQQ__Group__r.Price_per_Billing_Frequency__c, SBQQ__Group__r.Bundle_Price__c,
                      
                      SBQQ__RequiredBy__r.SBQQ__Group__r.Id, SBQQ__RequiredBy__r.SBQQ__Group__r.Name, SBQQ__RequiredBy__r.SBQQ__Group__r.SBQQ__SubscriptionTerm__c, SBQQ__RequiredBy__r.SBQQ__Group__r.SBQQ__ListTotal__c, 
                      SBQQ__RequiredBy__r.SBQQ__Group__r.SBQQ__NetTotal__c, SBQQ__RequiredBy__r.SBQQ__Group__r.Price_per_Billing_Frequency__c, SBQQ__RequiredBy__r.SBQQ__Group__r.Bundle_Price__c,
                      
                      
                      SBQQ__RequiredBy__r.SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.Sites__c,SBQQ__RequiredBy__r.Total_Price_per_Billing_Frequency__c,SBQQ__RequiredBy__r.SBQQ__Quantity__c,
                      
                      SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__RequiredBy__r.Price__c,Number_of_Credits__c FROM SBQQ__QuoteLine__c
                      WHERE SBQQ__Quote__c = :quoteId and SBQQ__RequiredBy__c!= NULL 
                      
                      ORDER BY  SBQQ__Group__r.Name, sbqq__ListPrice__c desc, SBQQ__Number__c, SBQQ__ProductName__c, Term__c
                     ]; 
        
        
        
        system.debug('**QUOTE QUERY**: ' + JSON.serializePretty(quoteLines));          
       UserFlag = False;
  	CreditFlag= False;	
    RestrictedFlag =False; 
        AggregateResult[] agg=[SELECT MAX(Ihasco_Term__c) total FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quoteId ];
        if(agg.size()>0 && agg[0].get('total')!=null)
        {
            
            term=integer.valueof(agg[0].get('total'));   
        }
        Aprice=0;
        price=0;
       List<SBQQ__QuoteLine__c> quoteLines1=[select id,SBQQ__Product__r.ProductCode from SBQQ__QuoteLine__c where  SBQQ__Quote__c = :quoteId];
        for(SBQQ__QuoteLine__c ql : quoteLines1)
        {
            system.debug('A QUOTE LINE' + ql.SBQQ__Product__r.ProductCode) ;
            if(ql.SBQQ__Product__r.ProductCode == 'IHCBP')
            {CreditFlag = True;}
            if(ql.SBQQ__Product__r.ProductCode == 'IHUBP'){
                UserFlag = True;}
            if(ql.SBQQ__Product__r.ProductCode == 'IHRPM'){RestrictedFlag = True ;}
        }
        for(SBQQ__QuoteLine__c ql : quoteLines){
            if(ql.Billing_Frequency__c!='One-Off'){
                Aprice= Aprice+ql.SBQQ__CustomerPrice__c;
            }
            if(ql.Billing_Frequency__c=='One-Off'){
                price=price+ql.SBQQ__CustomerPrice__c;
                system.debug('price=='+price);
            }
            if(ql.Billing_Frequency__c=='Annual')
            {
                paymentterm=ql.Billing_Frequency__c;
            }
        }
        if(Aprice!=0 && term!=null){
            annualPrice=Aprice/term;
            annualPrice=annualPrice.setScale(2);
            firstyearprice=  price+annualPrice;
        }else {
            annualPrice=Aprice;
            annualPrice=annualPrice.setScale(2);
            firstyearprice=  price+annualPrice;
        }
        
        //quote
        quote = [SELECT SBQQ__SalesRep__c, SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, SBQQ__CustomerAmount__c, 
                 SBQQ__Account__r.Name, SBQQ__PrimaryContact__r.Name,SBQQ__Opportunity2__r.Deposit_Payment_Method__c,Quote_type__c
                 FROM SBQQ__Quote__c
                 WHERE Id = :quoteId
                ];
        
        notPilotOrder = True ;
        if(quote.Quote_type__c=='Pilot Order'){
            notPilotOrder = false ;  
        }
        notTopUp = True;
        if(quote.Quote_type__c=='Top-Up'){
            notTopUp = false;
        }
        
        //sales rep (user)
        salesRep = [SELECT name, email, phone
                    FROM User
                    WHERE id = :quote.SBQQ__SalesRep__c
                   ];
        
    }
    
}