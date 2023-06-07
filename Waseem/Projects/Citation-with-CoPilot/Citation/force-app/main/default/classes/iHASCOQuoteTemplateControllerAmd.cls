public with sharing class iHASCOQuoteTemplateControllerAmd {
      
    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}   
    public List<SBQQ__QuoteLine__c> quoteLinesAmend {get;set;}
    public List<SBQQ__QuoteLine__c> finQuoteLinesAmend {get;set;}
    public List<SBQQ__QuoteLine__c> amendedFinalQuoteLine {get;set;}
    public SBQQ__Quote__c quoteRecord {get;set;}
    public decimal amendAnnual{get;set;}
   
    public decimal premiumAnnual{get;set;}
    public decimal OpenCreditPrice {get;set;} 
    public list<SBQQ__Quote__c>  quote {get;set;}
    public User salesRep {get;set;}
    private list<id> sourceQuoteId {get;set;}
    public map<id,SBQQ__Subscription__c> sourceQuotelnSubMap {get;set;} 
    private map<id,SBQQ__QuoteLine__c>       mapAmdPrdQuoeLine {get;set;}
    private map<id,SBQQ__QuoteLine__c>       mapPrdQuoeLine {get;set;}
    
    public iHASCOQuoteTemplateControllerAmd() {
       mapAmdPrdQuoeLine = new map<id,SBQQ__QuoteLine__c>();
       mapPrdQuoeLine = new map<id,SBQQ__QuoteLine__c>();
       Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
       
       //Quote Record
       quoteRecord = [SELECT SBQQ__EndDate__c, SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, Account_Annual_Revenue__c, 
       SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email, SBQQ__PrimaryContact__r.Phone,
        SBQQ__Account__c,  SBQQ__Account__r.Company_Registration_Number__c,
        SBQQ__Account__r.iHasco_Client_ID__c,SBQQ__Account__r.name,
        SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c,
       SBQQ__StartDate__c,PO_Reference__c,SBQQ__CustomerAmount__c,Annual_Price__c
         FROM SBQQ__Quote__c
         WHERE Id = :quoteId];

        //Quote Line 
        quoteLines = [SELECT SBQQ__BillingFrequency__c,Custom_Discount_Percentage__c, Total_Quote_Line__c, Id, Name, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, 
                            SBQQ__ProductName__c, SBQQ__Product__r.Business_Type__c, SBQQ__Quantity__c, SBQQ__Product__r.SBQQ__BillingFrequency__c,
                            SBQQ__CustomerPrice__c,Price__c,regular_payment__c, Annual_Price__c,SBQQ__CustomerTotal__c,
                            SBQQ__Product__r.ProductCode,Cost_per_Credit__c,Ihasco_Number_of_Credits__c,
                            Users__c, Billing_frequency__c, Ihasco_Term__c, SBQQ__ProductCode__c, SBQQ__RequiredBy__c,
                            SBQQ__ListPrice__c,SBQQ__RequiredBy__r.SBQQ__Product__r.ProductCode,SBQQ__RequiredBy__r.Total_Price_per_Billing_Frequency__c,SBQQ__RequiredBy__r.SBQQ__Quantity__c,Total_Credits_Users__c,SBQQ__UpgradedSubscription__r.Regular_Payment__c,Source_Subscription__r.SBQQ__CustomerPrice__c,Source_Subscription__r.SBQQ__ProrateMultiplier__c,Source_Price__c,iHasco_Number_of_Users__c,Source_Subscription__r.Regular_Payment__c,Whole_Credits__c, Source_Subscription__c,                            
                            SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__RequiredBy__r.Price__c,Number_of_Credits__c,
                                (SELECT Id,Total_Quote_Line__c, Name,Price__c, regular_payment__c, Annual_Price__c,SBQQ__ProductName__c , SBQQ__SubscriptionTerm__c, SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c,Whole_Credits__c, 
                                SBQQ__CustomerPrice__c , Billing_frequency__c, SBQQ__RequiredBy__c,SBQQ__ProductCode__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__Product__r.Business_Type__c
                                FROM SBQQ__Quote_Lines__r WHERE SBQQ__RequiredBy__c != NULL 
                                )
                            FROM SBQQ__QuoteLine__c
                            WHERE SBQQ__Quote__c = :quoteId
                            ORDER BY  SBQQ__ProductName__c ASC, sbqq__ListPrice__c, SBQQ__Number__c, Term__c];
        sourceQuoteId = new list<id>();
        sourceQuotelnSubMap = new map<id,SBQQ__Subscription__c>();
        list<SBQQ__Subscription__c> subList = getOriginalSub(quoteId);
        
        // sourceQuoteId = SourceQuote.SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.Source_Opportunity__r.SBQQ__PrimaryQuote__c;
        for(SBQQ__Subscription__c sbl : subList){
            sourceQuotelnSubMap.put(sbl.SBQQ__QuoteLine__c,sbl);
        }
        
        currentActivetSubscriptions();  
       
      //Loop quote lines
        amendedFinalQuoteLine = new list<SBQQ__QuoteLine__c>();
        premiumAnnual = 0; 
        OpenCreditPrice = 0;
        
        for(SBQQ__QuoteLine__c ql : quoteLines)
        {
            if((ql.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'Annual' || ql.Billing_Frequency__c == 'Annual') && ((ql.SBQQ__Quantity__c > 0 && ql.SBQQ__Quantity__c != null && ql.SBQQ__CustomerTotal__c > 0 && ql.SBQQ__CustomerTotal__C >0) || ql.SBQQ__ProductName__c =='Open License Credits' || ql.SBQQ__ProductName__c =='Additional Course Access Key'))
                   {
                        
                        //Product is ANNUAL 
                       if(ql.SBQQ__ProductName__C == 'Open License Credits'){
                           SBQQ__QuoteLine__c   tempQl = new SBQQ__QuoteLine__c();
                           tempQl  = ql;
                           decimal openCred = ql.Whole_Credits__c;
                           tempQl.Ihasco_Number_of_Credits__c = openCred;
                           OpenCreditPrice = tempQl.Source_Subscription__c != null ?tempQl.Annual_Price__c+tempQl.Source_Subscription__r.Regular_Payment__c :tempQl.Annual_Price__c;
                           amendedFinalQuoteLine.add(tempQl);
                           premiumAnnual = premiumAnnual+ OpenCreditPrice;
                           mapPrdQuoeLine.put(tempQl.SBQQ__Product__c,tempQl);
                       
                       }

                       else if(ql.SBQQ__ProductName__C.contains('Course') && ql.iHasco_Number_of_Users__c != null){
                           SBQQ__QuoteLine__c   tempQl = new SBQQ__QuoteLine__c();
                           tempQl  = ql;
                           decimal userCourse = ql.Total_Credits_Users__c != null ?ql.Total_Credits_Users__c+ql.iHasco_Number_of_Users__c:ql.iHasco_Number_of_Users__c;
                           tempQl.iHasco_Number_of_Users__c = userCourse;
                           OpenCreditPrice = tempQl.Source_Subscription__c != null ?(tempQl.Annual_Price__c+(tempQl.Source_Subscription__r.SBQQ__CustomerPrice__c/tempQl.Source_Subscription__r.SBQQ__ProrateMultiplier__c)) :tempQl.Annual_Price__c;
                           amendedFinalQuoteLine.add(tempQl);
                           premiumAnnual = premiumAnnual+ OpenCreditPrice;
                           mapPrdQuoeLine.put(tempQl.SBQQ__Product__c,tempQl);
                       }
                       
                       else{
                           premiumAnnual = premiumAnnual+ ql.Annual_Price__c;
                           mapPrdQuoeLine.put(ql.SBQQ__Product__c,ql);
                           amendedFinalQuoteLine.add(ql);
                       } 
                   }
               }        
        
    list<id>  quoteidList = new list<id>();
    quoteidList.add(quoteId);
    
    getQuoteDetails(quoteidList);
    
    }

    private void getQuoteDetails(list<id> qIDList){
       quote = [SELECT SBQQ__SalesRep__c, SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, SBQQ__CustomerAmount__c, 
                    SBQQ__Account__r.Name, SBQQ__PrimaryContact__r.Name,SBQQ__Opportunity2__r.Deposit_Payment_Method__c,Quote_type__c,SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.ContractNumber,SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.Total_Contract_Value__c
                FROM SBQQ__Quote__c
                WHERE Id In: qIDList order by SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.ContractNumber DESC
            ]; 
        //sales rep (user)
        salesRep = [SELECT name, email, phone
                    FROM User
                    WHERE id = :quote[0].SBQQ__SalesRep__c
                    ];
    }
    
    private void currentActivetSubscriptions() {
      
    //Quote Line 
    quoteLinesAmend = [SELECT SBQQ__StartDate__c, SBQQ__EndDate__c, Sub_Lines_Total_Monthly_Payment__c,SBQQ__BillingFrequency__c,Custom_Discount_Percentage__c, Total_Quote_Line__c, Id, Name, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, 
                            SBQQ__ProductName__c, SBQQ__Product__r.Business_Type__c, SBQQ__Quantity__c, SBQQ__Product__r.SBQQ__BillingFrequency__c,
                            SBQQ__CustomerPrice__c,Price__c,regular_payment__c, Annual_Price__c,SBQQ__CustomerTotal__c,
                            SBQQ__Quote__r.Deal_Start_Date__c,SBQQ__Product__r.ProductCode,Cost_per_Credit__c,Ihasco_Number_of_Credits__c,
                            Users__c, Sites__c, Size__c, Billing_frequency__c, Ihasco_Term__c, SBQQ__ProductCode__c, SBQQ__RequiredBy__c,
                            SBQQ__RequiredBy__r.SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.Sites__c,SBQQ__RequiredBy__r.Total_Price_per_Billing_Frequency__c,SBQQ__RequiredBy__r.SBQQ__Quantity__c,Whole_Credits__c,Source_Price__c,
                            SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__RequiredBy__r.Price__c,Number_of_Credits__c,iHasco_Number_of_Users__c,Total_Credits_Users__c,
                            (SELECT Id,Total_Quote_Line__c, Name,Price__c, regular_payment__c, Annual_Price__c,SBQQ__ProductName__c , SBQQ__SubscriptionTerm__c, SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c,
                                SBQQ__CustomerPrice__c , Size__c, Billing_frequency__c, Visit_Fulfilment_Years__c, SBQQ__RequiredBy__c,SBQQ__ProductCode__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__Product__r.Business_Type__c
                                FROM SBQQ__Quote_Lines__r WHERE SBQQ__RequiredBy__c != NULL
                            )
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quantity__c != -1 and SBQQ__Quantity__c != null and SBQQ__Quantity__c > 0  and id in: sourceQuotelnSubMap.keySet()
                    ORDER BY  SBQQ__ProductName__c ASC, sbqq__ListPrice__c, SBQQ__Number__c, Term__c
                    ]; 
        
        amendAnnual = 0;
        
        map<id,SBQQ__QuoteLine__c>      mapProdQuoteLine = new map<id,SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c ql : quoteLinesAmend)
        {   
            if((ql.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'Annual' || ql.Billing_Frequency__c == 'Annual') && ql.SBQQ__Quantity__c > 0 && ql.SBQQ__Quantity__c != null && ql.SBQQ__Quantity__c != -1 && ql.SBQQ__CustomerPrice__c != 0 && ql.SBQQ__CustomerPrice__c != null)
                    {
                    //Product is ANNUAL  
                        
                        amendAnnual = amendAnnual+((ql.source_price__c != null && ql.source_price__c>0)? (getSourcePriceAftDiscount(ql.source_price__c,sourceQuotelnSubMap.get(ql.id).Custom_Discount_Percentage__c).setScale(2) + ql.Annual_Price__c) : ql.Annual_Price__c);
                        if(mapProdQuoteLine.containsKey(ql.SBQQ__Product__c)){
                           SBQQ__QuoteLine__c tempQuoteLine = new SBQQ__QuoteLine__c();
                           tempQuoteLine = ql;
                           tempQuoteLine.SBQQ__CustomerPrice__c =   mapProdQuoteLine.get(ql.SBQQ__Product__c).SBQQ__CustomerPrice__c+ ql.SBQQ__CustomerPrice__c;
                           //Applying the source discount on the source price
                           tempQuoteLine.source_price__c = getSourcePriceAftDiscount(tempQuoteLine.source_price__c,sourceQuotelnSubMap.get(ql.id).Custom_Discount_Percentage__c).setScale(2);                           Decimal sourcePrice = tempQuoteLine.source_price__c;
                           mapProdQuoteLine.put(ql.SBQQ__Product__c,tempQuoteLine);    
                        }
                        else{
                            SBQQ__QuoteLine__c tempQuoteLine = new SBQQ__QuoteLine__c();
                            tempQuoteLine = ql;
                            //Applying the source discount on the source price
                            Decimal discountPerc = sourceQuotelnSubMap.get(ql.id).Custom_Discount_Percentage__c;
                            Decimal sourcePrice = tempQuoteLine.source_price__c;
                            tempQuoteLine.source_price__c = (discountPerc != null && discountPerc > 0 && sourcePrice >0) ? (sourcePrice - (sourcePrice * (discountPerc/100))):0;
                            mapProdQuoteLine.put(ql.SBQQ__Product__c,tempQuoteLine);  
                        }
                    }
        }
        finQuoteLinesAmend = new list<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c sql: mapProdQuoteLine.values()){
           mapAmdPrdQuoeLine.put(sql.id,sql);
           finQuoteLinesAmend.add(sql);    
        }
    }


    Private list<SBQQ__Subscription__c> getOriginalSub(id recordId){
        
        map<id,SBQQ__Subscription__c>      mapListSub = new map<id,SBQQ__Subscription__c>();
        SBQQ__Quote__c  amendedQuote = getAmendedQuote(recordId);
        id amendedContractId  = amendedQuote.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c;
        
        if(amendedContractId != null){
            mapListSub = getRemovedRevisedOriginalSub(amendedContractId);
        }
        
        if(mapListSub.size()>0){
            return mapListSub.values();
        }
        
        else return null;
    }
    
    private SBQQ__Quote__c getAmendedQuote(ID recordId){
        
        SBQQ__Quote__c   amdQuote = [select id,SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, Contract__c, SBQQ__MasterContract__c  from SBQQ__Quote__c where id =: recordId];
        return amdQuote;

    }

    private map<id,SBQQ__Subscription__c> getRemovedRevisedOriginalSub(Id amdContractID){
        set<id>   revisedSub = new set<id>();
        map<id,SBQQ__Subscription__c>    originalSubMap = new map<id,SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c sb: [select id,SBQQ__ProductName__c,SBQQ__RevisedSubscription__c,iHasco_Number_of_Users__c,Ihasco_Number_of_Credits__c,SBQQ__BillingFrequency__c, Regular_Payment__c, SBQQ__Quantity__c,SBQQ__BundledQuantity__c,Custom_Discount_Percentage__c,SBQQ__QuoteLine__r.SBQQ__Quote__c from SBQQ__Subscription__c  where SBQQ__Contract__c  =: amdContractID order by SBQQ__RevisedSubscription__c DESC]){
            originalSubMap.put(sb.id,sb);
            if (sb.SBQQ__RevisedSubscription__c != null){
                revisedSub.add(sb.SBQQ__RevisedSubscription__c);
            }                                 
        }
        
        for(id rsbid: revisedSub){
            if(originalSubMap.containsKey(rsbid)){
                originalSubMap.remove(rsbid);
            }
        }
        
        for(SBQQ__Subscription__c subL1: originalSubMap.values()){
            if(subL1.SBQQ__Quantity__c == -1){
                originalSubMap.remove(subL1.id);
            }
        }

        return originalSubMap;
    }

    private Decimal getSourcePriceAftDiscount(Decimal sourcePrice, Decimal discountPerc){
        return (discountPerc != null && discountPerc > 0 && sourcePrice >0) ? (sourcePrice - (sourcePrice * (discountPerc/100))):0;
    }
    
}