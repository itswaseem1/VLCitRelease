public with sharing class sm_CustomQuoteLinesController {
  
    public List<SBQQ__QuoteLineGroup__c> quoteLineGroups {get;set;} 
    public List<SBQQ__QuoteLineGroup__c> QMSquoteLineGroups {get;set;} 
    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}   
    
    public List<SBQQ__QuoteLineGroup__c> quoteGroupListMonthly {get;set;} 
    public List<SBQQ__QuoteLineGroup__c> quoteGroupListOneOff {get;set;} 
    public Map<ID,LIST<SBQQ__QuoteLine__c>> quoteItemsMonthly {get;set;}
    public Map<ID,LIST<SBQQ__QuoteLine__c>> quoteItemsOneOff {get;set;}
    public Map<Id,LIST<SBQQ__QuoteLine__c>> quoteLinkedItemsMonthly {get;set;}
    public Map<Id,LIST<SBQQ__QuoteLine__c>> quoteLinkedItemsOneOff {get;set;}
    public Map<Id, Double> groupTotalsMonthly {get;set;}
    public Map<Id, Double> groupTotalsOneOff {get;set;}
    
    public Set<String> QMSquoteUniqueISOs{get;set;}
    public Double QMSDeposit{get;set;}
    public Double QMSAuditFee{get;set;}
     
    public SBQQ__Quote__c quote {get;set;}
    public User salesRep {get;set;}
    
    public Boolean PremiumFlag {get;set;}   
    public Boolean SynergyFlag {get;set;} 
    public Boolean ComplianceFlag {get;set;}    
    public Boolean TransferFlag {get;set;}      
    public Boolean AdditionalCompanyFlag {get;set;}     
    public Boolean UKASFlag {get;set;}      
    public Boolean CoreFlag {get;set;}      
    public Boolean TPSMFlag {get;set;}      
    public Boolean ConsultancyFlag {get;set;}  
    public Boolean SupportFlag {get;set;}
    
   
   
    public sm_CustomQuoteLinesController() {

        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        
        //Quote Line 
        quoteLines = [SELECT Id, Name, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, 
                            SBQQ__StartDate__c, SBQQ__SubscriptionTerm__c,
                            SBQQ__ProductName__c, SBQQ__Product__r.Detail_of_Service__c,  SBQQ__Product__r.Business_Type__c, SBQQ__Quantity__c, SBQQ__Product__r.SBQQ__BillingFrequency__c,
                            SBQQ__CustomerPrice__c,
                            SBQQ__Quote__r.Deal_Start_Date__c,
                            Users__c, Sites__c, Size__c, Billing_frequency__c,
                            SBQQ__Group__r.Id, SBQQ__Group__r.Name, SBQQ__Group__r.SBQQ__SubscriptionTerm__c, SBQQ__Group__r.SBQQ__ListTotal__c, 
                            SBQQ__Group__r.SBQQ__NetTotal__c, SBQQ__Group__r.Price_per_Billing_Frequency__c, SBQQ__Group__r.Bundle_Price__c,
                            SBQQ__RequiredBy__r.SBQQ__ProductName__c,
                            (SELECT Id, Name, SBQQ__ProductName__c , SBQQ__SubscriptionTerm__c, SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, 
                            SBQQ__CustomerPrice__c , Size__c, Billing_frequency__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c
                                FROM SBQQ__Quote_Lines__r 
                                where 
                                (
                                    (
                                        SBQQ__Product__r.Business_Type__c = 'QMS'
                                        AND 
                                        SBQQ__Product__r.SBQQ__Hidden__c = true
                                    )
                                    OR 
                                    (
                                        SBQQ__Product__r.Business_Type__c != 'QMS'
                                        AND
                                        SBQQ__Product__r.SBQQ__Hidden__c = false
                                    //    AND 
                                   //     Price_per_Billing_Frequency__c = 0
                                    )                           
                                ) 
                                ORDER BY  SBQQ__Group__r.Name)
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND
                            (
                                (
                                    SBQQ__Product__r.Business_Type__c = 'QMS'
                                    AND 
                                    SBQQ__Product__r.SBQQ__Hidden__c = true
                                )
                                OR 
                                (
                                    SBQQ__Product__r.Business_Type__c != 'QMS'
                                    AND
                                    SBQQ__Product__r.SBQQ__Hidden__c = false
                                    AND 
                                    Price_per_Billing_Frequency__c <> 0
                                )                           
                            )  
                    ORDER BY  SBQQ__Group__r.Name, Price_per_Billing_Frequency__c desc, SBQQ__Number__c, SBQQ__ProductName__c, Term__c
                    ]; 
        
    
 
 system.debug('**QUOTE QUERY**: ' + JSON.serializePretty(quoteLines));                           
 
     Set<SBQQ__QuoteLineGroup__c> quoteGroupMonthlySet = new Set<SBQQ__QuoteLineGroup__c>();
     Set<SBQQ__QuoteLineGroup__c> quoteGroupOneOffSet = new Set<SBQQ__QuoteLineGroup__c>();
     
     quoteGroupListMonthly = new List<SBQQ__QuoteLineGroup__c>(); 
     quoteGroupListOneOff = new List<SBQQ__QuoteLineGroup__c>(); 
     
     quoteItemsMonthly = new  Map<ID,LIST<SBQQ__QuoteLine__c>>();
     quoteItemsOneOff = new  Map<ID,LIST<SBQQ__QuoteLine__c>>();
     
     quoteLinkedItemsMonthly = new Map<Id,LIST<SBQQ__QuoteLine__c>>();  
     quoteLinkedItemsOneOff = new Map<Id,LIST<SBQQ__QuoteLine__c>>();  
     
     groupTotalsMonthly = new Map<Id, Double>();
     groupTotalsOneOff = new Map<Id, Double>();     
  
  //Loop quote lines
  for(SBQQ__QuoteLine__c ql : quoteLines)
  {
    
        //Product is MONTHLY
        if(ql.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'Monthly' || ql.Billing_Frequency__c == 'Monthly')
        {
            // add group to Monthly List
            quoteGroupMonthlySet.add(ql.SBQQ__Group__r);
            
            //its there
            If(groupTotalsMonthly.containsKey(ql.SBQQ__Group__r.Id))
            {
                Double tempTotal = groupTotalsMonthly.get( ql.SBQQ__Group__r.Id );
                groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.Total_Price_per_Billing_Frequency__c);
                    // groupTotals.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.Price_per_Billing_Frequency__c);   
            }
            else
            {
            //its not there 
                if(ql.Total_Price_per_Billing_Frequency__c != 0)
                {
                    groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, ql.Total_Price_per_Billing_Frequency__c);
                    // groupTotals.put(ql.SBQQ__Group__r.Id, ql.Price_per_Billing_Frequency__c);
                }
            }
            
            // add quote lines
            if(quoteItemsMonthly.containsKey(ql.SBQQ__Group__r.Id))
            {
                List<SBQQ__QuoteLine__c> tempQL = quoteItemsMonthly.get( ql.SBQQ__Group__r.Id );
                tempQL.add(ql);
                quoteItemsMonthly.put(ql.SBQQ__Group__r.Id, tempQL);
            }
            else
            {
                quoteItemsMonthly.put(ql.SBQQ__Group__r.Id, new List<SBQQ__QuoteLine__c> {ql});
            }
                
           // add sub lines
            if(ql.SBQQ__Quote_Lines__r.size() > 0)
            {
               if(quoteLinkedItemsMonthly.containsKey(ql.id))
                {   
                    List<SBQQ__QuoteLine__c> tempQLSub = quoteLinkedItemsMonthly.get(ql.id);
                    tempQLSub.add(ql.SBQQ__Quote_Lines__r);
                    
                    quoteLinkedItemsMonthly.put(ql.id, tempQLSub);              
                }
                else
                {
                   quoteLinkedItemsMonthly.put(ql.id,  ql.SBQQ__Quote_Lines__r );
                    
                }
            }
            else
            {
                if(!quoteLinkedItemsMonthly.containsKey(ql.id))
                {   
                    quoteLinkedItemsMonthly.put(ql.id, new List<SBQQ__QuoteLine__c>());             
                }
                
            }
                    
                
            
            
        }
        else if(ql.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'One-Off' || ql.Billing_Frequency__c == 'One-Off')
        {
        //Product is One-Off 
        
            // add group
            quoteGroupOneOffSet.add(ql.SBQQ__Group__r);
            
            if(groupTotalsOneOff.containsKey(ql.SBQQ__Group__r.Id))
            {
                Double tempTotal = groupTotalsOneOff.get( ql.SBQQ__Group__r.Id );
                                
                groupTotalsOneOff.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.SBQQ__CustomerPrice__c);
            }
            else
            {
                groupTotalsOneOff.put(ql.SBQQ__Group__r.Id, ql.SBQQ__CustomerPrice__c);
            }
            
            // add quote lines
                if(quoteItemsOneOff.containsKey(ql.SBQQ__Group__r.Id))
                {
                    List<SBQQ__QuoteLine__c> tempQL = quoteItemsOneOff.get( ql.SBQQ__Group__r.Id );
                    tempQL.add(ql);
                    quoteItemsOneOff.put(ql.SBQQ__Group__r.Id, tempQL);
                }
                else
                {
                    quoteItemsOneOff.put(ql.SBQQ__Group__r.Id, new List<SBQQ__QuoteLine__c> {ql});
                }
                    
              // add sub lines
                if(ql.SBQQ__Quote_Lines__r.size() > 0)
                {
                   if(quoteLinkedItemsOneOff.containsKey(ql.id))
                    {   
                        List<SBQQ__QuoteLine__c> tempQLSub = quoteLinkedItemsOneOff.get(ql.id);
                        tempQLSub.add(ql.SBQQ__Quote_Lines__r);
                        
                        quoteLinkedItemsOneOff.put(ql.id, tempQLSub);               
                    }
                    else
                    {
                       quoteLinkedItemsOneOff.put(ql.id,  ql.SBQQ__Quote_Lines__r );
                        
                    }
                }
                else
                {
                    if(!quoteLinkedItemsOneOff.containsKey(ql.id))
                    {   
                        quoteLinkedItemsOneOff.put(ql.id, new List<SBQQ__QuoteLine__c>());              
                    }
                    
                }
                        
        }
                                    
    }

    quoteGroupListOneOff.addAll(quoteGroupOneOffSet); 
    quoteGroupListMonthly.addAll(quoteGroupMonthlySet); 


 
        //quote
        quote = [SELECT SBQQ__SalesRep__c, SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, Account_Annual_Revenue__c,  
                        SBQQ__Account__c, SBQQ__Account__r.Staff__c,  SBQQ__Account__r.TotalNoUKoffices__c, SBQQ__Account__r.TotalNoInternationalOffices__c,
                        Number_Of_Full_Time_Employees__c, Number_of_Part_Time_Employees__c, FTE__c,  Number_of_Complex_Sites__c, Number_of_Standard_Sites__c, Total_Sites__c,
                        SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c
                 FROM SBQQ__Quote__c
                 WHERE Id = :quoteId
                ];
 

        
        //sales rep (user)
        salesRep = [SELECT name, email, phone
                    FROM User
                    WHERE id = :quote.SBQQ__SalesRep__c
                    ];
        
        
        //Quote Line Groups (QMS)
         QMSquoteLineGroups = [SELECT Id, 
                                Name, 
                                SBQQ__SubscriptionTerm__c, 
                                SBQQ__ListTotal__c, 
                                SBQQ__NetTotal__c, 
                                Price_per_Billing_Frequency__c, 
                                Bundle_Price__c,
                                    (SELECT Id, 
                                            SBQQ__SubscriptionTerm__c, 
                                            SBQQ__ProductName__c,  
                                            SBQQ__Product__r.Service_Type__c,
                                            SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,
                                            SBQQ__RequiredBy__r.SBQQ__ProductName__c,  
                                            SBQQ__ListPrice__c,  
                                            SBQQ__CustomerTotal__c,
                                            SBQQ__Product__r.SBQQ__BillingFrequency__c,
                                            SBQQ__Product__r.Product_Type__c, 
                                            SBQQ__Product__r.SBQQ__Hidden__c, 
                                            SBQQ__Quantity__c, 
                                            Price_per_Billing_Frequency__c, 
                                            Total_Price_per_Billing_Frequency__c,
                                            Term__c , 
                                            Additional_Discount_Message__c,
                                            SBQQ__Quote__c
                                    FROM SBQQ__LineItems__r 
                                    Where SBQQ__Product__r.SBQQ__Hidden__c = false
                                    ORDER BY SBQQ__ProductName__c, Price_per_Billing_Frequency__c desc, 
                                                Term__c, 
                                                SBQQ__Number__c) 
                            FROM SBQQ__QuoteLineGroup__c 
                            Where SBQQ__Quote__c = :quoteId
                            ORDER BY SBQQ__Number__c];
                            
            
                            
            QMSquoteUniqueISOs = new Set<String>();
            PremiumFlag = false;
            SynergyFlag = false;    
            ComplianceFlag = false;
            TransferFlag = false;
            AdditionalCompanyFlag = false;
            UKASFlag = false;   
            CoreFlag = false;   
            TPSMFlag = false;   
            ConsultancyFlag = false;
            SupportFlag = false;
            
                        
            for(SBQQ__QuoteLineGroup__c qg : QMSquoteLineGroups)
            {
                for(SBQQ__QuoteLine__c ql: qg.SBQQ__LineItems__r)
                {
                    QMSquoteUniqueISOs.add(ql.SBQQ__RequiredBy__r.SBQQ__ProductName__c);  
                    
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Premium') { PremiumFlag = true;  }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Synergy') { SynergyFlag = true;  }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Compliance') { ComplianceFlag = true;  }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Transfer') { TransferFlag = true; }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Additional Company') { AdditionalCompanyFlag = true; }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'UKAS') { UKASFlag = true; }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Core') { CoreFlag = true; }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'TPSM') { TPSMFlag = true; }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Consultancy') { ConsultancyFlag = true; }
                    if(ql.SBQQ__Product__r.Service_Type__c == 'Support') { SupportFlag = true; }
                    
                    
                }
            }   
            
            
            system.debug('## PremiumFlag: ' + PremiumFlag);
            system.debug('## SynergyFlag: ' + SynergyFlag);
            system.debug('## ComplianceFlag: ' + ComplianceFlag);
            system.debug('## TransferFlag: ' + TransferFlag);
            system.debug('## AdditionalCompanyFlag: ' + AdditionalCompanyFlag);
            system.debug('## UKASFlag: ' + UKASFlag);
            system.debug('## CoreFlag: ' + CoreFlag);
            system.debug('## TPSMFlag: ' + TPSMFlag);
            system.debug('## ConsultancyFlag: ' + ConsultancyFlag);
            
            
            //Quote Line (Aggregate) - Cert
            AggregateResult[] QMS_sumCert = [SELECT sum(SBQQ__CustomerTotal__c) CERT_TOTAL
                                           FROM SBQQ__QuoteLine__c
                                           WHERE SBQQ__Quote__c = :quoteId
                                           AND SBQQ__Product__r.Family = 'Certification'
                                           GROUP BY SBQQ__Quote__c];
                                                    
            
            if(QMS_sumCert.size() > 0)
            {    
                QMSDeposit = (double.valueOf(QMS_sumCert[0].get('CERT_TOTAL'))  / 2 );
            }
            
            //Quote Line (Aggregate) - Audit
            AggregateResult[] QMS_sumAudit = [SELECT sum(SBQQ__CustomerTotal__c) AUD_TOTAL, max(SBQQ__SubscriptionTerm__c) MAX_TERM
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c = :quoteId
                                              AND SBQQ__Product__r.Family = 'Audit'
                                              GROUP BY SBQQ__Quote__c];
            
            if(QMS_sumAudit.size() > 0)
            {    
                QMSAuditFee = (((double.valueOf(QMS_sumAudit[0].get('AUD_TOTAL'))/double.valueOf(QMS_sumAudit[0].get('MAX_TERM'))) *12) / 4 );
 //     system.debug('***Aud Total**: ' + ((double.valueOf(QMS_sumAudit[0].get('AUD_TOTAL')))));
 //     system.debug('***Aud Max Term**: ' + double.valueOf(QMS_sumAudit[0].get('MAX_TERM')));
            //  QMSAuditFee = ((double.valueOf(QMS_sumAudit[0].get('AUD_TOTAL'))  / double.valueOf(QMS_sumAudit[0].get('MAX_TERM'))) );
            }
             
    }
 
 
    
   
    
}