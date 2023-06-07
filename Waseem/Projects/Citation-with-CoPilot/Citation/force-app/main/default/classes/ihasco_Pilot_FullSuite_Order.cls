public class ihasco_Pilot_FullSuite_Order {
    public List<SBQQ__QuoteLine__c> quoteLine {get;set;} 
    public SBQQ__Quote__c quote {get;set;}
    public Order order {get;set;}
    public Decimal orderTotal {get;set;}
    public Date renewalDate {get;set;}
   // public string Licencemodel {get;set;}
    public Decimal AgreementTerm {get;set;}

    public ihasco_Pilot_FullSuite_Order() {
        
        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        
        //Order
         order =[SELECT Id,EndDate,EffectiveDate,OrderNumber,CreatedDate,Order.TotalAmount FROM Order WHERE SBQQ__Quote__c = :quoteId];
        

        //Quote 
        quote = [SELECT SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, Account_Annual_Revenue__c, 
                        SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email, SBQQ__PrimaryContact__r.Phone,
                        SBQQ__Account__c,  SBQQ__Account__r.Company_Registration_Number__c,SBQQ__SubscriptionTerm__c,
                        SBQQ__Account__r.iHasco_Client_ID__c,Payment_Method__c,Quote_type__c,License_Model__c,
                        SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c,
                        SBQQ__BillingFrequency__c, Contract__c,Contract__r.ContractTerm,SBQQ__TotalCustomerDiscountAmount__c,
                 SBQQ__Opportunity2__r.Contract.StartDate,SBQQ__Opportunity2__r.Contract.ContractNumber,SBQQ__Opportunity2__r.Payment_Method__c, SBQQ__Opportunity2__r.Owner.Name, SBQQ__Opportunity2__r.Owner.Email,SBQQ__Opportunity2__r.Owner.MobilePhone,
                 SBQQ__StartDate__c
                 FROM SBQQ__Quote__c
                 WHERE Id = :quoteId
                ];
        if(quote.Quote_type__c=='Pilot Order')
            AgreementTerm = 12;
       
          else AgreementTerm = quote.SBQQ__SubscriptionTerm__c;
              Integer months=(integer)AgreementTerm;
       renewalDate = order.EffectiveDate.addMonths(months);
quoteLine = new List<SBQQ__QuoteLine__c>();         
        //Quote Line
        quoteLine = [SELECT Id, SBQQ__ProductName__c, Ihasco_Number_of_Credits__c, Number_of_Credits__c,Parent_product_name__c,
                                SBQQ__Quantity__c, Ihasco_Term__c, SBQQ__SubscriptionTerm__c,Custom_Discount_Percentage__c,
                                SBQQ__CustomerTotal__c,SBQQ__ListTotal__c, SBQQ__BillingFrequency__c, SBQQ__CustomerPrice__c
                            
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND SBQQ__Group__r.SBQQ__Optional__c = false
                    ORDER BY SBQQ__Number__c
                    ];
        orderTotal = 0; 
        for(sbQQ__quoteline__c ql:quoteline){
            if(ql.SBQQ__ListTotal__c > 0){
                orderTotal = orderTotal + ql.SBQQ__ListTotal__c;
            }
        }
        
    }
    public list<account> getBlank() {
        list<account> acc = new list<account>() ;
        acc.add(new account(name='test')) ;
        return acc ;
    }
}