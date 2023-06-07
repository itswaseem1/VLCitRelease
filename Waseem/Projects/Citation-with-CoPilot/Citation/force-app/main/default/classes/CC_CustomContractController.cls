public with sharing class CC_CustomContractController {
    

    public SBQQ__QuoteTemplate__c template {get;set;}
    public List<SBQQ__QuoteLineGroup__c> quoteLineGroups {get;set;}     
    public List<SBQQ__QuoteLine__c> quoteLine {get;set;}
    public Map<Id,List<SBQQ__QuoteLine__c>> childquoteLine {get;set;} 
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
    
    public double OneOffTotal {get;set;}
    public double MonthlyTotal {get;set;}
    public double AnnualTotal {get;set;}
    
    public integer TotalEmployees {get;set;}
    
    //SDT-5854
    public Boolean freeMonthFlag {get;set;}
    public Boolean noFreeMonthFlag {get;set;}
    public String noFreeMonthProduct {get;set;}
    public Integer FreeMonthCount {get;set;}
    //SDT-5653
    public String partnerProductCode {get;set;}
    public Decimal commissionNewRate {get;set;}
    public String commissionCycle {get;set;}
    public String commissionFrequency {get;set;}
    public Decimal commissionRenewalRate {get;set;}
    public boolean additionalInclude {get;set;}   
    public String contractPaid {get;set;}
    public Decimal discountPreferrentialRate {get;set;}
    public cc_CustomContractController() {

        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        Id templateId = (Id)ApexPages.currentPage().getParameters().get('tid');
        
        //Template
        template = [SELECT Name,SBQQ__CompanyStreet__c, SBQQ__CompanyCity__c, SBQQ__CompanyState__c, SBQQ__CompanyPostalCode__c, SBQQ__CompanySlogan__c
                FROM SBQQ__QuoteTemplate__c
                WHERE Id = :templateId  ];
        
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
                
        TotalEmployees = 0 ;
        
        if(quote.Number_of_Part_Time_Employees__c != null && quote.Number_of_Part_Time_Employees__c >0 ){
            TotalEmployees += integer.valueof(quote.Number_of_Part_Time_Employees__c) ;
        }
        
        if(quote.Number_of_full_Time_Employees__c != null && quote.Number_of_full_Time_Employees__c >0 ){
            TotalEmployees += integer.valueof(quote.Number_of_full_Time_Employees__c) ;
        }
            
       
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
 
        Set<Id> childQuoteLineIds = new Set<Id>();

        //Quote Line
        quoteLine = [SELECT Id,SBQQ__Product__r.Has_Wrapper__c, SBQQ__ProductName__c,SmasRollUp__c, SBQQ__Product__r.Detail_of_Service__c,SBQQ__Product__r.Business_Type__c, SBQQ__Product__r.SBQQ__Hidden__c, SBQQ__RequiredBy__c,
                                SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, SBQQ__StartDate__c,Service_Start_Date__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c,  SBQQ__SubscriptionTerm__c,
                                SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Core_Product__c, Term_Including_FOC__c, SBQQ__Product__r.ProductCode,
                                SBQQ__Product__r.Product_Type__c,SBQQ__Product__r.Core_Product__c, SBQQ__Product__r.Service_Type__c, SBQQ__SpecialPrice__c,Billing_frequency__c, sbqq__product__r.sbqq__billingfrequency__c,
                                Users__c, Sites__c, Tribunal_case_number__c, Visit_Fulfilment_Years__c, price__c, regular_payment__c,Initial_Payment__c,Sum_of_Children_Price_Per_Billing__c,
                            	SBQQ__Quote__r.Deal_Start_Date__c, SBQQ__CustomerTotal__c, Additional_Discount_Message__c,
                        		Sub_Lines_Total_Monthly_Payment__c,SBQQ__Quote__r.FOC_Months__c,SBQQ__Product__r.FOC_Months_Eligible__c,SBQQ__Product__r.Name,
                     			Commission_Rate_New_Business__c,Additional_Contracts_Included__c,Commission_Payment_Cycle__c,Commission_Payment_Frequency__c,Commission_Rate_Renewal__c,Contract_Value_paid_on__c,Discount_Prefferential_Rate_for_Members__c,Number_of_Units_Circuits_Outlets__c,
                            (SELECT Id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Has_Wrapper__c,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__StartDate__c,Term_Including_FOC__c,Sub_Lines_Total_Monthly_Payment__c, SBQQ__Product__r.Detail_of_Service__c,SBQQ__Product__r.Core_Product__c, price__c,Initial_Payment__c, regular_payment__c, Users__c, Sites__c, Tribunal_case_number__c, Visit_Fulfilment_Years__c, SBQQ__SpecialPrice__c, SBQQ__SubscriptionTerm__c, Billing_frequency__c,SBQQ__Product__r.ProductCode, sbqq__product__r.sbqq__billingfrequency__c, Total_Price_per_Billing_Frequency__c,SBQQ__Quantity__c
                            FROM SBQQ__Quote_Lines__r
                            where SBQQ__Product__r.SBQQ__Hidden__c = false and SBQQ__Product__r.Business_Type__c != 'QMS'
                            order by SBQQ__ProductName__c 
                            )
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND SBQQ__Group__r.SBQQ__Optional__c = false
                    
                    AND
                    (
                        (
                            SBQQ__Product__r.Business_Type__c = 'QMS'  AND (SBQQ__RequiredBy__c = null OR sbqq__requiredby__r.SBQQ__Product__r.Has_Wrapper__c = true)
                            //AND 
                        //  SBQQ__Product__r.SBQQ__Hidden__c != true
                        )
                        OR
                        (
                            SBQQ__Product__r.Business_Type__c != 'QMS'
                            AND
                            SBQQ__Product__r.SBQQ__Hidden__c = false                            
                            //AND 
                            //Price_per_Billing_Frequency__c <> 0
                            //  AND SBQQ__RequiredBy__c != ''
                        )
                    )   
                    
                    
                    and (sbqq__requiredby__c = null     or (sbqq__requiredby__c <> null and sbqq__requiredby__r.Price_per_Billing_Frequency__c = 0 and sbqq__requiredby__r.SBQQ__Product__r.SBQQ__Hidden__c = true ) Or (sbqq__requiredby__r.SBQQ__Product__r.Has_Wrapper__c = true))       
                                
                    ORDER BY  SBQQ__Group__r.Name,SBQQ__Product__r.Has_Wrapper__c desc,SBQQ__Product__r.Core_Product__c desc, SBQQ__ProductName__c, sbqq__Listprice__c desc, SBQQ__ProductName__c, Term__c, SBQQ__Number__c
                    ];
                    
        system.debug('quoteline----'+quoteline);
        OneOffTotal = 0.00 ;
        MonthlyTotal = 0.00 ;
        AnnualTotal = 0.00 ; 
        FreeMonthCount=0;
        noFreeMonthProduct=''; 
        //SDT-5653
        commissionNewRate=0;  
        commissionRenewalRate=0;
        discountPreferrentialRate = 0;
        commissionCycle='';
        commissionFrequency=''; 
        contractPaid='';
        additionalInclude=false; 
        for(SBQQ__QuoteLine__c ql : quoteline) {
            if(ql.SBQQ__Quote__r.FOC_Months__c !=null){
                if(ql.SBQQ__Product__r.FOC_Months_Eligible__c){
                    freeMonthFlag=true;               
                    FreeMonthCount=Integer.valueOf(ql.SBQQ__Quote__r.FOC_Months__c); 
                }else{ 
                    noFreeMonthFlag=true;
                    noFreeMonthProduct+=(ql.SBQQ__Product__r.Name).replace('&','&amp;')+',';                    
                } 
            }
            
            //SDT-5653
            if(ql.SBQQ__Product__r.ProductCode !=null && ql.SBQQ__Product__r.ProductCode=='Part-Comm'){                
                partnerProductCode = ql.SBQQ__Product__r.ProductCode;
                commissionNewRate = ql.Commission_Rate_New_Business__c;
                commissionRenewalRate = ql.Commission_Rate_Renewal__c;
                commissionCycle = ql.Commission_Payment_Cycle__c;
                commissionFrequency= ql.Commission_Payment_Frequency__c;
                contractPaid = ql.Contract_Value_paid_on__c;
                additionalInclude = ql.Additional_Contracts_Included__c;
                discountPreferrentialRate = ql.Discount_Prefferential_Rate_for_Members__c;
            }
            
            if(ql.price__c != null && ql.price__c >0) {
                if(ql.Billing_frequency__c ==  'Monthly' || (ql.sbqq__product__r != null && ql.sbqq__product__r.sbqq__billingfrequency__c == 'Monthly')) {
                    MonthlyTotal += ql.price__c ;
                }
            }
            else if(ql.Billing_frequency__c ==  'Monthly' && ql.SBQQ__Product__r.ProductCode=='SMAS-ACC'){
                MonthlyTotal += ql.SmasRollUp__c !=null ? ql.SmasRollUp__c : 0 ;
            }
            if(ql.Billing_frequency__c ==  'Annual' || (ql.sbqq__product__r != null && ql.sbqq__product__r.sbqq__billingfrequency__c == 'Annual')) {
                if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC'){
                    AnnualTotal += ql.SmasRollUp__c !=null ? ql.SmasRollUp__c : 0 ;
                }
                else{
                	AnnualTotal += ql.price__c > 0 ? ql.price__c : ql.Initial_payment__c ;
                }
            }
            if(ql.Initial_payment__c > 0 && (ql.Billing_frequency__c ==  'One-Off' || (ql.sbqq__product__r != null && ql.sbqq__product__r.sbqq__billingfrequency__c == 'One-Off'))) {
                OneOffTotal += ql.Initial_payment__c ;
            }
            else if(ql.sbqq__product__r != null && ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.Billing_frequency__c ==  'One-Off' && ql.SmasRollUp__c!=null){
                OneOffTotal += ql.SmasRollUp__c;
            }
            system.debug('MonthlyTotal----'+MonthlyTotal);
            for(SBQQ__QuoteLine__c sub_ql : ql.SBQQ__Quote_Lines__r) {
                if(sub_ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Has_Wrapper__c == false){
                    childQuoteLineIds.add(sub_ql.Id);
                    if(sub_ql.price__c != null && sub_ql.price__c >0) {
                        if(sub_ql.Billing_frequency__c ==  'Monthly' || (sub_ql.sbqq__product__r != null && sub_ql.sbqq__product__r.sbqq__billingfrequency__c == 'Monthly')) {
                            MonthlyTotal += sub_ql.price__c ;
                        }
                    }
                    if(sub_ql.Billing_frequency__c ==  'Annual' || (sub_ql.sbqq__product__r != null && sub_ql.sbqq__product__r.sbqq__billingfrequency__c == 'Annual')) {
                        AnnualTotal += sub_ql.price__c > 0 ? sub_ql.price__c : sub_ql.Initial_payment__c ;
                    }
                    if(sub_ql.Initial_payment__c > 0 && (sub_ql.Billing_frequency__c ==  'One-Off' || (sub_ql.sbqq__product__r != null && sub_ql.sbqq__product__r.sbqq__billingfrequency__c == 'One-Off'))) {
                        OneOffTotal += sub_ql.Initial_payment__c ;
                    }
                }
            }
            
        }
        System.debug('childQuoteLineIds--'+childQuoteLineIds);
        noFreeMonthProduct=noFreeMonthProduct.removeEnd(','); 
        childquoteLine = new Map<Id,List<SBQQ__QuoteLine__c>>() ;
        for(SBQQ__QuoteLine__c ql:[SELECT Id, SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__Product__r.Detail_of_Service__c, SBQQ__RequiredBy__c,Visit_Fulfilment_Years__c,Billing_frequency__c,Initial_payment__c,
                                   SBQQ__Quantity__c, SBQQ__StartDate__c,Service_Start_Date__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c,  SBQQ__SubscriptionTerm__c,SBQQ__Product__r.sbqq__billingfrequency__c,price__c,
                                   SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Core_Product__c, Term_Including_FOC__c, SBQQ__Product__r.ProductCode,Sub_Lines_Total_Monthly_Payment__c
                                   FROM SBQQ__QuoteLine__c
                                   WHERE SBQQ__RequiredBy__c=:childQuoteLineIds        
                                   ORDER BY SBQQ__ProductName__c
                                  ]){
                                      if(ql.price__c != null && ql.price__c >0) {
                                          if(ql.Billing_frequency__c ==  'Monthly' || (ql.sbqq__product__r != null && ql.sbqq__product__r.sbqq__billingfrequency__c == 'Monthly')) {
                                              MonthlyTotal += ql.price__c ;
                                          }
                                      }
                                      if(ql.Billing_frequency__c ==  'Annual' || (ql.sbqq__product__r != null && ql.sbqq__product__r.sbqq__billingfrequency__c == 'Annual')) {
                                          AnnualTotal += ql.price__c > 0 ? ql.price__c : ql.Initial_payment__c ;
                                      }
                                      if(ql.Initial_payment__c > 0 && (ql.Billing_frequency__c ==  'One-Off' || (ql.sbqq__product__r != null && ql.sbqq__product__r.sbqq__billingfrequency__c == 'One-Off'))) {
                                          OneOffTotal += ql.Initial_payment__c ;
                                      }
                                      if(!childquoteLine.containsKey(ql.SBQQ__RequiredBy__c)){
                                          childquoteLine.put(ql.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>{ql});
                                      }
                                      else{
                                           childquoteLine.get(ql.SBQQ__RequiredBy__c).add(ql);
                                      }
                                  }
          system.debug('childquoteLine---'+childquoteLine);   
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
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Premium') { PremiumFlag = true;  }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Synergy') { SynergyFlag = true;  }
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