public with sharing class cc_CustomQuoteLinesController {
      
    public List<SBQQ__QuoteLineGroup__c> quoteLineGroups {get;set;} 
    public List<SBQQ__QuoteLineGroup__c> QMSquoteLineGroups {get;set;} 
    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}   
    public SBQQ__QuoteTemplate__c template {get;set;}
    
    public List<SBQQ__QuoteLineGroup__c> quoteGroupListMonthly {get;set;} 
    public List<SBQQ__QuoteLineGroup__c> quoteGroupListOneOff {get;set;} 
    public List<SBQQ__QuoteLineGroup__c> quoteGroupListAnnual {get;set;} 
     
   
   
    public map<id,SBQQ__QuoteLineGroup__c> quoteGroupMapMonthly {get;set;} 
    public map<id,SBQQ__QuoteLineGroup__c> quoteGroupMapOneOff {get;set;} 
    public map<id,SBQQ__QuoteLineGroup__c> quoteGroupMapAnnual {get;set;} 
    
    
    public Map<ID,LIST<SBQQ__QuoteLine__c>> quoteItemsMonthly {get;set;}
    public Map<ID,LIST<SBQQ__QuoteLine__c>> quoteItemsOneOff {get;set;}
    public Map<ID,LIST<SBQQ__QuoteLine__c>> quoteItemsAnnual {get;set;}
    public map<id,list<SBQQ__Quoteline__C>> quoteItemsMixed {get;set;}
    
    
    
    public Map<Id,LIST<SBQQ__QuoteLine__c>> quoteLinkedItemsMonthly {get;set;}
    public Map<Id,LIST<SBQQ__QuoteLine__c>> quoteLinkedItemsOneOff {get;set;}
    public Map<Id,LIST<SBQQ__QuoteLine__c>> quoteLinkedItemsAnnual {get;set;}
    public map<id,List<SBQQ__QuoteLine__C>> quoteLinkedItemsMixed {get;set;}
    
    public map<id,list<sbqq__quoteline__c>> MixedMapItems {get;set;}
    public set<id> MixedItemIds {get;set;}
    
    public Map<Id, Double> groupTotalsMonthly {get;set;}
    public Map<Id, Double> groupTotalsOneOff {get;set;}
    public Map<Id, Double> groupTotalsAnnual {get;set;}
    
    public map<id,double>  QMSLineTotals {get;set;}
    public map<id,string>  QMSLineExists {get;set;}
    
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
    public Decimal oneofftermvalue {get;set;}
    
    public integer ctr {get;set;}
    //SDT-5853
    public Boolean freeMonthFlag {get;set;}
    public Boolean noFreeMonthFlag {get;set;}
    public String noFreeMonthProduct {get;set;}
    public Integer FreeMonthCount {get;set;}
    
     // SDT-5540
    public String partnerProductCode {get;set;}
    public Decimal commissionNewRate {get;set;}
    public String commissionCycle {get;set;}
    public String commissionFrequency {get;set;}
    public Decimal commissionRenewalRate {get;set;}
    public boolean additionalInclude {get;set;}   
    public String contractPaid {get;set;}
    public Decimal discountPreferrentialRate {get;set;}  
    
    public class groupWrapper {
        public string groupname {get;set;}
        public integer ord {get;set;}
        public integer subscriptionTerm {get;set;}
        public string freq {get;set;}
        public SBQQ__QuoteLineGroup__c QLG_Mixed {get;set;}     
        public SBQQ__QuoteLineGroup__c QLG_Monthly {get;set;}
        public SBQQ__QuoteLineGroup__c QLG_Annual {get;set;}
        public SBQQ__QuoteLineGroup__c QLG_OneOff {get;set;}
        public boolean HasMixed {get;set;}
        public id groupId {get;set;} 
        public decimal mixedmonthlyTotal {get;set;}
        public decimal mixedoneoffTotal {get;set;}
        public decimal mixedAnnualTotal {get;set;}
        public string productCode {get;set;}
        
    }
    
    public list<account> getBlank() {
        list<account> acc = new list<account>() ;
        acc.add(new account(name='test')) ;
        return acc ;
    }
    
    public map<id,groupWrapper> groupWrapperMap = new map<id,groupWrapper>() ;
    
    public list<groupWrapper> getQuoteGroups() {
        return groupWrapperMap.values() ;
    }
    public integer getQuoteGroupsSize() {
        return groupWrapperMap.values().size() ;
    }
    
    
    
            
        
   
    public cc_CustomQuoteLinesController() {
        
        oneofftermvalue = decimal.valueOf(System.label.ONEOFF_QUOTE_TERM_VALUE);

        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        Id templateId = (Id)ApexPages.currentPage().getParameters().get('tid');
        
        //Template
        template = [SELECT Name FROM SBQQ__QuoteTemplate__c WHERE Id = :templateId  ];
        
        //Quote Line 
        quoteLines = [SELECT Number_of_Units_Circuits_Outlets__c,SmasRollUp__c,SBQQ__Product__r.Has_Wrapper__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Has_Wrapper__c,Sub_Line_Total__c,SBQQ__SubscriptionTerm__c, Sub_Lines_Total_Monthly_Payment__c, Total_Quote_Line__c, Id, Name, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, Term__c, 
                            SBQQ__ProductName__c, SBQQ__Product__r.Detail_of_Service__c,  SBQQ__Product__r.Business_Type__c, SBQQ__Quantity__c, SBQQ__Product__r.SBQQ__BillingFrequency__c,
                            SBQQ__CustomerPrice__c,Price__c,regular_payment__c, initial_payment__c,
                            SBQQ__Quote__r.Deal_Start_Date__c,SBQQ__Product__r.ProductCode,Sum_of_Children_Price_Per_Billing__c,
                            Users__c, Sites__c, Size__c, Billing_frequency__c, Visit_Fulfilment_Years__c, SBQQ__ProductCode__c, SBQQ__RequiredBy__c,
                            SBQQ__Group__r.Id, SBQQ__Group__r.Name, SBQQ__Group__r.SBQQ__SubscriptionTerm__c, SBQQ__Group__r.SBQQ__ListTotal__c, 
                            SBQQ__Group__r.SBQQ__NetTotal__c, SBQQ__Group__r.Price_per_Billing_Frequency__c, SBQQ__Group__r.Bundle_Price__c,
                            
                            SBQQ__RequiredBy__r.SBQQ__Group__r.Id, SBQQ__RequiredBy__r.SBQQ__Group__r.Name, SBQQ__RequiredBy__r.SBQQ__Group__r.SBQQ__SubscriptionTerm__c, SBQQ__RequiredBy__r.SBQQ__Group__r.SBQQ__ListTotal__c, 
                            SBQQ__RequiredBy__r.SBQQ__Group__r.SBQQ__NetTotal__c, SBQQ__RequiredBy__r.SBQQ__Group__r.Price_per_Billing_Frequency__c, SBQQ__RequiredBy__r.SBQQ__Group__r.Bundle_Price__c,
                            
                            
                            SBQQ__RequiredBy__r.Users__c, SBQQ__RequiredBy__r.Sites__c,SBQQ__RequiredBy__r.Total_Price_per_Billing_Frequency__c,SBQQ__RequiredBy__r.SBQQ__Quantity__c,
                            
                            SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__RequiredBy__r.Price__c,SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__Quote__r.FOC_Months__c,SBQQ__Product__r.FOC_Months_Eligible__c,SBQQ__Product__r.Name,
                            Commission_Rate_New_Business__c,Additional_Contracts_Included__c,Commission_Payment_Cycle__c,Commission_Payment_Frequency__c,Commission_Rate_Renewal__c,Contract_Value_paid_on__c,Discount_Prefferential_Rate_for_Members__c,
                            (SELECT Id,Total_Quote_Line__c, Name,Price__c, regular_payment__c, initial_payment__c,SBQQ__ProductName__c , SBQQ__SubscriptionTerm__c, SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Total_Price_per_Billing_Frequency__c, 
                            SBQQ__CustomerPrice__c , Size__c, Billing_frequency__c, Visit_Fulfilment_Years__c, SBQQ__RequiredBy__c,SBQQ__ProductCode__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c,SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__Product__r.Business_Type__c
                                FROM SBQQ__Quote_Lines__r 
                                where 
                                (
                                    (
                                        SBQQ__Product__r.Business_Type__c = 'QMS'
                                    
                                    )
                                    OR 
                                    (
                                        SBQQ__Product__r.Business_Type__c != 'QMS'
                                        AND
                                        SBQQ__Product__r.SBQQ__Hidden__c = false
                                  
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
                                    (Price_per_Billing_Frequency__c <> 0 OR (Price_per_Billing_Frequency__c=0 AND SBQQ__ProductCode__c = 'Part-Comm') OR (Price_per_Billing_Frequency__c = 0 AND (SBQQ__ProductCode__c = 'Free-Month' OR SBQQ__ProductCode__c = 'CB-HRHS')) OR SBQQ__ProductCode__c = 'SMAS-ACC' OR SBQQ__Product__r.Has_Wrapper__c =true)
                                )                           
                            )  
                    ORDER BY  SBQQ__Group__r.Name, SBQQ__ProductName__c, sbqq__ListPrice__c desc, SBQQ__Number__c, Term__c
                    ]; 
        
    
 
 system.debug('**QUOTE QUERY**: ' + JSON.serializePretty(quoteLines));                           
 
     Set<SBQQ__QuoteLineGroup__c> quoteGroupMonthlySet = new Set<SBQQ__QuoteLineGroup__c>();
     Set<SBQQ__QuoteLineGroup__c> quoteGroupOneOffSet = new Set<SBQQ__QuoteLineGroup__c>();
      Set<SBQQ__QuoteLineGroup__c> quoteGroupAnnualSet = new Set<SBQQ__QuoteLineGroup__c>();
    
     
     
     
     
     quoteGroupListMonthly = new List<SBQQ__QuoteLineGroup__c>(); 
     quoteGroupListOneOff = new List<SBQQ__QuoteLineGroup__c>(); 
     quoteGroupListAnnual = new List<SBQQ__QuoteLineGroup__c>(); 
     
     
     quoteItemsMonthly = new  Map<ID,LIST<SBQQ__QuoteLine__c>>();
     quoteItemsOneOff = new  Map<ID,LIST<SBQQ__QuoteLine__c>>();
     quoteItemsAnnual = new  Map<ID,LIST<SBQQ__QuoteLine__c>>();
     quoteItemsMixed = new  Map<ID,LIST<SBQQ__QuoteLine__c>>();
     
     quoteLinkedItemsMonthly = new Map<Id,LIST<SBQQ__QuoteLine__c>>();  
     quoteLinkedItemsOneOff = new Map<Id,LIST<SBQQ__QuoteLine__c>>();      
     quoteLinkedItemsAnnual = new Map<Id,LIST<SBQQ__QuoteLine__c>>();  
     
     groupTotalsMonthly = new Map<Id, Double>();
     groupTotalsOneOff = new Map<Id, Double>();
     groupTotalsAnnual = new Map<Id, Double>();
        
     QMSLineTotals = new map<id,double>() ;
     
  
  //Loop quote lines
  GroupWrapper gw = new GroupWrapper() ;
  
  QMSLineExists = new map<id,string>() ;
  
   for(SBQQ__QuoteLine__c ql : quoteLines)
      {
        QMSLineExists.put(ql.id,'NO') ;
        
        if(ql.SBQQ__Group__c != null ) {
                if(groupWrappermap.get(ql.SBQQ__Group__c) == null) {
                    gw = null ;
                    gw = new groupwrapper() ;               
                    gw.groupId = ql.SBQQ__Group__c ;
                    gw.groupname = ql.SBQQ__Group__r.name ;  
                //  gw.QLG_Mixed = ql.SBQQ__Group__r ;  
              //        gw.MixedLines = new list<SBQQ__QuoteLine__c>() ;                
                //  gw.QLG_Monthly = ql.SBQQ__Group__r ;
                //  gw.QLG_Annual = ql.SBQQ__Group__r ;
                //  gw.QLG_OneOff = ql.SBQQ__Group__r ;
                    //gw.hasmixed = false ;
                      gw.mixedmonthlyTotal = 0.00 ;
                    gw.mixedoneoffTotal = 0.00 ;
                 gw.mixedAnnualTotal = 0.00 ;   
                 gw.subscriptionTerm = integer.valueof(ql.sbqq__group__r.SBQQ__SubscriptionTerm__c) ;
                 gw.productCode= ql.SBQQ__Product__r.ProductCode;
                    groupWrapperMap.put(ql.SBQQ__Group__c, gw) ;
                }
            
            
        }
      }
    
    //for(groupWrapper gwrap : groupwrappermap.values()) {
    //  gwrap.hasmixed = true ;
    //  gwrap.QLG_Mixed.sbqq__lineitems__r.add(new SBQQ__QuoteLine__c()) ;
    //}
     
    
      
      /* get mixed billing items */
                     map<id,sbqq__quoteline__c> parentmap = new map<id,sbqq__quoteline__C>() ;
                    MixedMapItems = new map<id,list<sbqq__quoteline__c>>() ;
                    
                    sbqq__quoteline__c qline = new sbqq__quoteline__c() ;
                    
                    list<sbqq__quoteline__c> qlist = new list<sbqq__quoteline__c>() ;
                    
                    //list<sbqq__quoteline__c> tempMQL = new list<sbqq__quoteline__c>() ;
                    
                    
                    for(sbqq__quoteline__c ql : quoteLines) {
                        if(ql.sbqq__requiredby__c != null && ql.sbqq__requiredby__r.SBQQ__Product__r.Has_Wrapper__c == false) {
                            parentmap.put(ql.sbqq__requiredby__c,ql.sbqq__requiredby__r) ;
                            
                        }
                    }
                    
                    
                    string bf = '' ;
                    boolean flag = false ;
                    for(sbqq__quoteline__c parentrec : parentmap.values() ) {
                            qlist = new list<sbqq__quoteline__c>() ;
                            qlist.clear() ;
                            for(sbqq__quoteline__c ql : quoteLines) {
                                if(ql.sbqq__requiredby__c == parentrec.id) {
                                    qlist.add(ql) ;
                                }   
                            }
                            if(qlist.size() >0 ) {
                            flag = false ;
                            bf = qlist[0].SBQQ__Product__r.SBQQ__BillingFrequency__c ;
                                for(sbqq__quoteline__c templine : qlist) {
                                    system.debug('checking') ;
                                //  system.debug(templine.SBQQ__Product__r.SBQQ__BillingFrequency__c) ;
                                    if(templine.SBQQ__Product__r.SBQQ__BillingFrequency__c != bf) {
                                        flag = true ;
                                    }
                                }
                                if(flag == true ) {
                                        system.debug(parentrec.SBQQ__ProductName__c) ;
                                        system.debug(qlist) ;
                    
                                    mixedmapitems.put(parentrec.id,qlist) ;
                                }
                    
                            }
                            
                    }
                    
                    //system.debug(parentmap.values().size()) ;
                    
                    
                    for(sbqq__quoteline__c parentline : parentmap.values()) {
                                if(mixedmapitems.get(parentline.id) != null) {
                                    /* mark which groups have mixed */
                                     gw = null ;
                                    gw = groupwrappermap.get(parentline.SBQQ__Group__c) ;
                                    gw.qlg_mixed = parentline.sbqq__group__r ;
                                    if(quoteItemsMixed.containskey(parentline.sbqq__group__r.id)) {
                                        list<sbqq__quoteline__c> tempMQL = new list<sbqq__quoteline__c>() ;
                                        tempMQL = quoteItemsMixed.get(parentline.sbqq__group__r.id) ;
                                        tempMQL.add(parentline) ;
                                        quoteItemsMixed.put(parentline.sbqq__group__r.id, tempMQL) ;
                                        
                                        
                                    }
                                    else
                                    {
                                        quoteItemsMixed.put(parentline.sbqq__group__r.id, new list<sbqq__quoteline__c> {parentline}) ;
                                    }
                                    
                                    for(sbqq__quoteline__c mapitem : mixedmapitems.get(parentline.id)) {
                                            if(mapitem.sbqq__product__r.sbqq__billingfrequency__c == 'Monthly' || mapitem.Billing_Frequency__c == 'Monthly') {
                                                
                                                if(mapitem.sbqq__Product__r.productcode == 'PEL' ||mapitem.sbqq__Product__r.productcode == 'CB1' ||mapitem.sbqq__Product__r.productcode == 'HS-Compliance' ) {
                                                        gw.mixedmonthlytotal += mapitem.regular_payment__c + mapitem.Sum_of_Children_Price_Per_Billing__c ; // Total_Price_per_Billing_Frequency__c ;
                                                }
                                                 else
                                                 {
                                                        gw.mixedmonthlytotal += mapitem.regular_payment__c ; // Total_Price_per_Billing_Frequency__c ;
                                                 }
                                            
                                            }
                                            
                                            if(mapitem.sbqq__product__r.sbqq__billingfrequency__c == 'Annual' || mapitem.Billing_Frequency__c == 'Annual') {
                                                gw.mixedAnnualtotal += mapitem.regular_payment__c ; // Total_Price_per_Billing_Frequency__c ;
                                            }
                                            
                                            if(mapitem.sbqq__product__r.sbqq__billingfrequency__c == 'One-Off' || mapitem.Billing_Frequency__c == 'One-off') {
                                                gw.mixedoneOfftotal += mapitem.regular_payment__c ; //Total_Price_per_Billing_Frequency__c ;
                                            }
                                            
                                        }
                                                                        
                                     groupwrappermap.put(parentline.SBQQ__Group__c,gw) ;
                                    
                                    /* */
                                    system.debug('has mixed') ;
                                } else
                                    {
                                            parentmap.remove(parentline.id) ;
                                    }
                    
                        }
                        
                        
                        
                    
                    
                    
                    system.debug(parentmap.values().size()) ;
                    
                    ctr = 0 ;
                    
                    MixedItemIds = new set<id>() ;
                    for(list<sbqq__quoteline__c> l : mixedmapitems.values()) {
                        ctr++ ;
                        for(sbqq__quoteline__c ql : l) {
                            MixedItemIds.add(ql.id) ;
                            
                        }
                    }
                    
                    
      /* end get mixed billing items */
      
      
    system.debug('MIXED ITEMS' + MixedItemIds) ;    
    
        FreeMonthCount=0;
        noFreeMonthProduct=''; 
        //SDT-5540
        commissionNewRate=0;  
        commissionRenewalRate=0;
        commissionCycle='';
        commissionFrequency=''; 
        contractPaid='';
        additionalInclude=false;
        discountPreferrentialRate=0;  
        
  for(SBQQ__QuoteLine__c ql : quoteLines)
  {
        system.debug('A QUOTE LINE' + ql) ;
        if(!MixedItemIds.contains(ql.id)) {
            if(ql.SBQQ__Quote__r.FOC_Months__c !=null){
                if(ql.SBQQ__Product__r.FOC_Months_Eligible__c){
                    freeMonthFlag=true;               
                    FreeMonthCount=Integer.valueOf(ql.SBQQ__Quote__r.FOC_Months__c); 
                }else{ 
                    if(ql.SBQQ__Product__r.ProductCode !=null && ql.SBQQ__Product__r.ProductCode !='Part-Comm'){ 
                        noFreeMonthFlag=true;                        
                        noFreeMonthProduct+=(ql.SBQQ__Product__r.Name).replace('&','&amp;')+',';   
                    }
                } 
            }    
            
            //SDT-5540
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
                //Product is MONTHLY
                if(ql.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'Monthly' || ql.Billing_Frequency__c == 'Monthly')
                {
                    // add group to Monthly List
                    quoteGroupMonthlySet.add(ql.SBQQ__Group__r);
                    
                    gw = null ;
                    gw = groupwrappermap.get(ql.SBQQ__Group__c) ;
                    gw.qlg_monthly = ql.sbqq__group__r ;
                    groupwrappermap.put(ql.SBQQ__Group__c,gw) ;
                    
                    system.debug('Total price per billing freq : ' + ql.Total_Price_per_Billing_Frequency__c) ;
                    
                    //its there
                    If(groupTotalsMonthly.containsKey(ql.SBQQ__Group__r.Id))
                    {
                        Double tempTotal = groupTotalsMonthly.get( ql.SBQQ__Group__r.Id );
                      
                        if(temptotal ==null) {temptotal = 0 ;}
                        if(ql.sbqq__product__r.business_type__c == 'QMS') {
                            //groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.Sub_Lines_Total_Monthly_Payment__c) ;
                            groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.regular_payment__c) ;
                            
                        }
                        else {
                        
                            if(ql.price__c == null) {
                                 groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  0) ;
                                 
                            }
                            else {
                                if(ql.sbqq__Product__r.productcode == 'PEL' ||ql.sbqq__Product__r.productcode == 'CB1' ||ql.sbqq__Product__r.productcode == 'HS-Compliance' ) {
                               
                                 groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.regular_payment__c + ql.Sum_of_Children_Price_Per_Billing__c ) ;
                               
                                }
                                else {
                                     if(((ql.sbqq__Product__r.productcode != 'HR-REVIEW') || (ql.sbqq__Product__r.productcode == 'HR-REVIEW' && ( ql.SBQQ__RequiredBy__r == null))) || ((ql.sbqq__Product__r.productcode != 'CORE-HSFD') || (ql.sbqq__Product__r.productcode == 'CORE-HSFD' && ( ql.SBQQ__RequiredBy__r == null))) ||((ql.sbqq__Product__r.productcode != 'CORE-HSHD') || (ql.sbqq__Product__r.productcode == 'CORE-HSHD' && ( ql.SBQQ__RequiredBy__r == null))) )
                                     {
                                         if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                                             groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  (ql.SmasRollUp__c)) ;
                                         }
                                         else{
                                             groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.regular_payment__c) ;
                                         }
                                    }
                                 }
                            }
                       
                        } // Total_Price_per_Billing_Frequency__c);
                            // groupTotals.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.Price_per_Billing_Frequency__c);   
                    }
                    else
                    {
                    //its not there 
                        if(ql.sbqq__product__r.business_type__c == 'QMS') {
                            // groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, ql.Sub_Lines_Total_Monthly_Payment__c) ; 
                             groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, ql.regular_payment__c) ; 
                             
                        }
                        else {
                            if(ql.Total_Price_per_Billing_Frequency__c != 0 && ql.SBQQ__Product__r.Has_Wrapper__c == false)
                            {
                                
                                if(ql.sbqq__Product__r.productcode == 'PEL' ||ql.sbqq__Product__r.productcode == 'CB1' ||ql.sbqq__Product__r.productcode == 'HS-Compliance' ) {
                                 groupTotalsMonthly.put(ql.SBQQ__Group__r.Id,   ql.regular_payment__c + ql.Sum_of_Children_Price_Per_Billing__c ) ;
                                }
                                else {
                                    if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                                        groupTotalsMonthly.put(ql.SBQQ__Group__r.Id,   ql.SmasRollUp__c) ;
                                    }
                                    else{
                                        groupTotalsMonthly.put(ql.SBQQ__Group__r.Id,   ql.regular_payment__c) ;
                                     }
                                }
                                
                                
                                
                                
                               // groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, ql.Price__c) ; // Total_Price_per_Billing_Frequency__c);
                                // groupTotals.put(ql.SBQQ__Group__r.Id, ql.Price_per_Billing_Frequency__c);
                            }else if(ql.sbqq__Product__r.productcode == 'Part-Comm'){
                                groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, ql.regular_payment__c) ;
                            } 
                            else if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                                        groupTotalsMonthly.put(ql.SBQQ__Group__r.Id,   ql.SmasRollUp__c) ;
                                    }
                        }
                    }
                    
                    // add quote lines
                    if(ql.SBQQ__Product__r.Has_Wrapper__c == false){
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
                    }
                        
                   // add sub lines
                    if(ql.SBQQ__Quote_Lines__r.size() > 0 && ql.SBQQ__Product__r.Has_Wrapper__c == false)
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
                        
                        /*
                        code here to add to monthly total for QMS lines?
                        */
                            for (SBQQ__QuoteLine__c subline : ql.SBQQ__Quote_Lines__r) {
                                
                                
                                
                                if(subline.SBQQ__Product__r.business_type__c == 'QMS') {
                                        if(QMSLineTotals.containsKey(ql.id)) {
                                            double tempQMSTotal = QMSLineTotals.get(ql.id) ;
                                             if(subline.Total_Quote_Line__c != 0)
                                                {
                                                    QMSLineTotals.put(ql.id,tempQMSTotal + subline.Total_Quote_Line__c) ;
                                                    QMSLineExists.put(ql.id,'YES') ;
                                                }
                                        }
                                        else
                                        {
                                            QMSLineTotals.put(ql.id,subline.Total_Quote_Line__c) ;
                                            QMSLineExists.put(ql.id,'YES') ;
                                            
                                        }
                                    
                                    
                                    //its there
                                            If(groupTotalsMonthly.containsKey(ql.SBQQ__Group__r.Id))
                                            {
                                                Double tempTotal = groupTotalsMonthly.get( ql.SBQQ__Group__r.Id );
                                                if(subline.sbqq__Product__r.business_type__c == 'QMS') {
                                                    //groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal + subline.Total_Quote_Line__c) ;
                                                }
                                                else {
                                                groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, tempTotal + subline.regular_payment__c) ; // Total_Price_per_Billing_Frequency__c);
                                                }    // groupTotals.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.Price_per_Billing_Frequency__c);   
                                            }
                                            else
                                            {
                                            //its not there 
                                                if(subline.Total_Price_per_Billing_Frequency__c != 0)
                                                {
                                                     if(subline.sbqq__Product__r.business_type__c == 'QMS') {
                                                        //  groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, subline.Total_Quote_Line__c) ;
                                                     }
                                                     else
                                                     {
                                                        groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, subline.regular_payment__c) ; // Total_Price_per_Billing_Frequency__c);
                                                    // groupTotals.put(ql.SBQQ__Group__r.Id, ql.Price_per_Billing_Frequency__c);
                                                     }
                                                }else if(subline.sbqq__Product__r.productcode == 'Part-Comm'){
                                                    groupTotalsMonthly.put(ql.SBQQ__Group__r.Id, subline.regular_payment__c) ;
                                                }
                                            }
                                }
                            }
                        /*
                        */
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
                    
                     gw = null ;
                    gw = groupwrappermap.get(ql.SBQQ__Group__c) ;
                    gw.qlg_oneoff = ql.sbqq__group__r ;
                    groupwrappermap.put(ql.SBQQ__Group__c,gw) ;
                    
                    if(groupTotalsOneOff.containsKey(ql.SBQQ__Group__r.Id))
                    {
                        Double tempTotal = groupTotalsOneOff.get( ql.SBQQ__Group__r.Id );
                        double initpayment =ql.initial_payment__c ;
                        if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                            initpayment=ql.SmasRollUp__c;
                        }
                        if(initpayment == null ) {initpayment =0;} 
                        if(temptotal ==null) {temptotal = 0;}
                        if(ql.price__c == null) {
                             groupTotalsOneOff.put(ql.SBQQ__Group__r.Id, tempTotal +  0) ; // SBQQ__CustomerPrice__c);
                        }  else
                        {
                             groupTotalsOneOff.put(ql.SBQQ__Group__r.Id, tempTotal +  initpayment) ; // SBQQ__CustomerPrice__c);
                        }        
                       
                    }
                    else
                    {
                        if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                            System.debug('Hi Entered if');
                            groupTotalsOneOff.put(ql.SBQQ__Group__r.Id, ql.SmasRollUp__c ) ;
                        }
                        else{
                        groupTotalsOneOff.put(ql.SBQQ__Group__r.Id, ql.initial_payment__c ) ; // SBQQ__CustomerPrice__c);
                    }
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
                                
                } // end oneoff
                
                
                 else if(ql.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'Annual' || ql.Billing_Frequency__c == 'Annual')
                {
                //Product is ANNUAL 
                
                    // add group
                    quoteGroupAnnualSet.add(ql.SBQQ__Group__r);
                    
                     gw = null ;
                    gw = groupwrappermap.get(ql.SBQQ__Group__c) ;
                    gw.qlg_annual = ql.sbqq__group__r ;
                    groupwrappermap.put(ql.SBQQ__Group__c,gw) ;
                    
                    if(groupTotalsAnnual.containsKey(ql.SBQQ__Group__r.Id))
                    {
                        Double tempTotal = groupTotalsAnnual.get( ql.SBQQ__Group__r.Id );
                         if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                         groupTotalsAnnual.put(ql.SBQQ__Group__r.Id, tempTotal + ql.SmasRollUp__c) ;   
                        }
                        else{
                        groupTotalsAnnual.put(ql.SBQQ__Group__r.Id, tempTotal +  ql.regular_payment__c ) ; // Total_Price_per_Billing_Frequency__c);
                    }
                    }
                    else
                    {
                        if(ql.SBQQ__Product__r.ProductCode=='SMAS-ACC' && ql.SmasRollUp__c!=null){
                         groupTotalsAnnual.put(ql.SBQQ__Group__r.Id, ql.SmasRollUp__c) ;   
                        }
                        else{
                        groupTotalsAnnual.put(ql.SBQQ__Group__r.Id, ql.regular_payment__c ) ; // Total_Price_per_Billing_Frequency__c);
                    }
                    }
                    
                    // add quote lines
                        if(quoteItemsAnnual.containsKey(ql.SBQQ__Group__r.Id))
                        {
                            List<SBQQ__QuoteLine__c> tempQL = quoteItemsAnnual.get( ql.SBQQ__Group__r.Id );
                            tempQL.add(ql);
                            quoteItemsAnnual.put(ql.SBQQ__Group__r.Id, tempQL);
                        }
                        else
                        {
                            quoteItemsAnnual.put(ql.SBQQ__Group__r.Id, new List<SBQQ__QuoteLine__c> {ql});
                        }
                            
                      // add sub lines
                        if(ql.SBQQ__Quote_Lines__r.size() > 0)
                        {
                           if(quoteLinkedItemsAnnual.containsKey(ql.id))
                            {   
                                List<SBQQ__QuoteLine__c> tempQLSub = quoteLinkedItemsAnnual.get(ql.id);
                                tempQLSub.add(ql.SBQQ__Quote_Lines__r);
                                
                                quoteLinkedItemsAnnual.put(ql.id, tempQLSub);               
                            }
                            else
                            {
                               quoteLinkedItemsAnnual.put(ql.id,  ql.SBQQ__Quote_Lines__r );
                                
                            }
                        }
                        else
                        {
                            if(!quoteLinkedItemsAnnual.containsKey(ql.id))
                            {   
                                quoteLinkedItemsAnnual.put(ql.id, new List<SBQQ__QuoteLine__c>());              
                            }
                            
                        }
                                
                } // end oneoff
        } // end if mixeditemcontains .                            
    } // end quotelines

    noFreeMonthProduct=noFreeMonthProduct.removeEnd(','); 
    quoteGroupListOneOff.addAll(quoteGroupOneOffSet); 
    quoteGroupListMonthly.addAll(quoteGroupMonthlySet);
    quoteGroupListAnnual.addAll(quoteGroupAnnualSet);
     
  

    
 
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
                                            SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
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
            System.debug('Hi');
                        
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