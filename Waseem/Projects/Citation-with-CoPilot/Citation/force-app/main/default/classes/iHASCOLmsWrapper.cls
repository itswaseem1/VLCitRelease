public class iHASCOLmsWrapper 
{
    public String EventType;
    public String PriceModel;
    public String EventId;	
    public String EventNumber;	
    public Date StartDate ;		
    public Date EndDate;					
    public String OrderActivatedDate ;	
    public String SourceOpportunityId ;	
    public String AccountId ;	
    public String AccountName ;
    public String LmsId ; 	
    public PrimaryContact PrimaryContact ;	
    public parent parent;
    public SalesRepresentative SalesRepresentative ;	
    public List<LineItem> LineItems ;
    public List<CreditPurchases> CreditPurchases ;	
    public List<AccountSites> AccountSites ;
    public class AccountSites {	
        public String AccountId ;	
        public String SiteName ;	
        public Boolean Active ;	
        public String City ;	
        public String Street ;	
        
        public AccountSites(Site__c site){
            this.AccountId  = site.id;
            this.SiteName = site.Name;
            this.Active = site.Active__c;
            this.City = site.City__c;
            this.Street = site.Street__c;
        }
    }	
    public class LineItem {	
        public String Id ;	
        public Integer Quantity ;	
        public String Name ;	
        public String EventId ;	
        public String EventNumber ;
        public Date StartDate ;	
        public Date EndDate ;	
        public String ProductName ;	
        public String ProductCode ;	
        public String ParentProductCode ;	
        public Date ServiceStartDate ;	
        public Date ServiceEndDate ;
        public String UserLimit;
        public String BespokeContent;
        
        public LineItem(SBQQ__Subscription__c sc){
            this.Id = sc.Id;
            if(sc.SBQQ__Quantity__c != null){
                this.Quantity = (Integer)sc.SBQQ__Quantity__c;
            }
            this.UserLimit = '';
            this.Name = sc.Name;
            this.EventId = sc.SBQQ__Contract__c;
            this.EventNumber = sc.SBQQ__ContractNumber__c;
            this.StartDate = sc.SBQQ__StartDate__c;
            this.EndDate = sc.SBQQ__EndDate__c;
            this.ProductName = sc.SBQQ__ProductName__c;
            this.ProductCode = sc.ProductCode__c;
            this.ParentProductCode = sc.ParentProductCode__c; 
            this.ServiceStartDate = sc.Service_Start_Date__c;
            this.ServiceEndDate = sc.Service_End_Date__c;
            if(sc.iHasco_Number_of_Users__c > 0 && (sc.ProductCode__c == 'IHUBP' || sc.ProductCode__c == 'ASDS') ){
                this.UserLimit = String.valueof(sc.iHasco_Number_of_Users__c);
            }
            if(sc.ProductCode__c == 'ASDS'){
                this.BespokeContent = sc.Bespoke_products__c;
            }
            
        }
        
        public LineItem(orderItem oItem){
            this.Id = oItem.Id;
            this.Name = oItem.OrderItemNumber;
            if(oItem.Quantity != null){
                this.Quantity = (Integer)oItem.Quantity;
            }
            this.UserLimit = '';
            this.EventId = oItem.OrderId;
            this.EventNumber = oItem.Order.OrderNumber;
            this.StartDate = oItem.ServiceDate;
            this.EndDate = oItem.EndDate;
            this.ProductName = oItem.Product2.Name;
            this.ProductCode = oItem.Product2.ProductCode;
            this.ParentProductCode = oItem.ParentProductCode__c; 
            this.ServiceStartDate = oItem.ServiceDate;
            this.ServiceEndDate = oItem.EndDate;
            if(oItem.iHasco_Number_of_Users__c > 0 && (oItem.Product2.ProductCode == 'IHUBP' || oItem.Product2.ProductCode == 'ASDS') ){
                this.UserLimit = String.valueof(oItem.iHasco_Number_of_Users__c);
            }
            if(oItem.Product2.ProductCode == 'ASDS'){
                this.BespokeContent = oItem.Bespoke_products__c;
            }
            
        }
    }	
    public class SalesRepresentative {	
        public String FirstName ;	
        public String LastName ;	
        public String Email ;	
        public String Phone ;	
        
        public SalesRepresentative(String fn, String ln, String email, String Phone){
            this.FirstName = fn;
            this.LastName = ln;
            this.Email = email;
            this.Phone = phone;
        }
    }	
    public class CreditPurchases {	
        public String LineItemId ;	
        public Date PurchaseDate ;	
        public Integer Quantity ;	
        
        public CreditPurchases(SBQQ__Subscription__c sc, String evt){
            if(sc.ProductCode__c == System.Label.iHASCOCreditProductCode){
                this.LineItemId = sc.SBQQ__RequiredById__c;
            } else {
                this.LineItemId = sc.id;
            }
            if(evt == System.Label.iHASCOEventContractAmended){
                this.PurchaseDate = System.Today();
            } else {
                this.PurchaseDate = Date.valueof(sc.SBQQ__Contract__r.ActivatedDate);
            }
            if(sc.Ihasco_Number_of_Credits__c != null){
                this.Quantity = (Integer)sc.Ihasco_Number_of_Credits__c;
            }
            else{
                this.Quantity=(Integer)sc.SBQQ__Quantity__c;
            }
        }
        
        public CreditPurchases(OrderItem oItem){
            if(oItem.Product2.productCode == System.Label.iHASCOCreditProductCode){
                this.LineItemId = oItem.SBQQ__RequiredBy__c;
            } else {
                this.LineItemId = oItem.id;
            }
            this.PurchaseDate = Date.valueof(oItem.Order.ActivatedDate);
            if(oItem.Ihasco_Number_of_Credits__c != null){
                this.Quantity = (Integer)oItem.Ihasco_Number_of_Credits__c;
            } else{
                this.Quantity=(Integer)oItem.Quantity;
            }
        }
    }	
    public class PrimaryContact {	
        public String Id ;	
        public String FirstName	 ;
        public String LastName ;	
        public String Email ;	
        public String Phone ;	
        
        public PrimaryContact(Id conId, String fn, String ln, String Email, String Phone){
            this.id = conId;
            this.FirstName = fn;
            this.LastName = ln;
            this.Email = Email;
            this.Phone = Phone;
        }
    }
    public class parent {	
        public String AccountId ;	
        public String LmsId	 ;	
        
        public parent(Contract cont){
            this.AccountId = Cont.Account?.ParentId;
            this.LmsId = Cont.Account?.Parent?.LMS_Id__c;
        }
        
        public parent(Order Ord){
            this.AccountId = Ord.Account?.ParentId;
            this.LmsId = Ord.Account?.Parent?.LMS_Id__c;
        }
    }
    
    
    public iHASCOLmsWrapper(Order ord, List<Site__c> sites, String eventType) {
        this.EventType = eventType;
        this.PriceModel = ord.License_Model__c.replaceAll( '\\s+', '');
        this.EventId = ord.Id;
        this.EventNumber = ord.OrderNumber;
        this.StartDate = ord.EffectiveDate;
        this.EndDate = ord.EndDate;
        this.SourceOpportunityId = ord.SBQQ__Quote__r.SBQQ__Opportunity2__c;
        this.AccountId = ord.AccountId;
        this.AccountName = ord.Account.Name;
        this.LmsId = ord.Account.LMS_ID__c;
        this.PrimaryContact = new PrimaryContact(ord.SBQQ__Quote__r.SBQQ__PrimaryContact__c,ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName,
                                                 ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone);
        this.SalesRepresentative = new SalesRepresentative(ord.Owner.FirstName,ord.Owner.LastName,ord.Owner.Email,ord.Owner.Phone);
        
        List<String> prodcodes = System.Label.iHASCOUserbasedProductCodes.split(',');
        Decimal numberofUsers;
        for(OrderItem oItem : ord.OrderItems){
            if(prodcodes.contains(oItem.Product2.productCode)){
                numberofUsers = oItem.iHasco_Number_of_Users__c;
            }
        }
        
        this.CreditPurchases = new List<CreditPurchases>();
        this.LineItems = new List<LineItem>();
        for(OrderItem oItem : ord.OrderItems){
            if(oItem.SBQQ__RequiredBy__c == NULL && oItem.Product2.productCode == System.Label.iHASCOUserBasedProduct){
                oItem.iHasco_Number_of_Users__c = numberofUsers;
            }
            
            if( (oItem.Product2.productCode == System.Label.iHASCOCreditProductCode) || (oItem.Product2.productCode.Startswith('IH-RPM-'))){
                this.CreditPurchases.add(new CreditPurchases(oItem));
            } 
            if(oItem.Product2.productCode != System.Label.iHASCOCreditProductCode){
                this.LineItems.add(new LineItem(oItem));
            }     
        }
        this.AccountSites = new List<AccountSites>();
        for(Site__c s : sites){
            this.AccountSites.add(new AccountSites(s));
        }
        this.parent = new parent(ord); 
    }
    
    public iHASCOLmsWrapper(Contract Contr, List<Site__c> sites, String eventType){
        this.EventType = eventType;
        this.PriceModel = Contr.License_Model__c.replaceAll( '\\s+', '');
        this.EventId = Contr.Id;
        this.EventNumber = contr.ContractNumber;
        this.StartDate = contr.StartDate;
        this.EndDate = contr.EndDate;
        this.SourceOpportunityId = contr.SBQQ__Opportunity__c;
        this.AccountId = Contr.AccountId;
        this.AccountName = Contr.Account.Name;
        this.LmsId = Contr.Account.LMS_ID__c;
        this.PrimaryContact = new PrimaryContact(contr.SBQQ__Quote__r.SBQQ__PrimaryContact__c,contr.SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,contr.SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName,
                                                 contr.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,contr.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone);
        this.SalesRepresentative = new SalesRepresentative(contr.Owner.FirstName,contr.Owner.LastName,contr.Owner.Email,contr.Owner.Phone);
        this.CreditPurchases = new List<CreditPurchases>();
        Set<Id> RevisedLineItems = new Set<Id>();
        Map<String,Decimal> Numberofusers = new Map<String,Decimal>();
        for(SBQQ__Subscription__c sub : Contr.SBQQ__Subscriptions__r){
            if(sub.SBQQ__RevisedSubscription__c !=NULL){
                system.debug('revised'+sub.SBQQ__RevisedSubscription__c);
                RevisedLineItems.add(sub.SBQQ__RevisedSubscription__c);
            }
        }
        //This Map is to store old credit to send delta credits to LMS
        Map<id,Decimal> oldCredits = new Map<id,Decimal>();
        //This code for prodcodes was added as additional users are added with another product during amendment process 
        List<String> prodcodes = System.Label.iHASCOUserbasedProductCodes.split(',');
        
        for(SBQQ__Subscription__c sub2 : Contr.SBQQ__Subscriptions__r){
            if((this.EventType == System.Label.iHASCOEventContractAmended) 
                && RevisedLineItems.contains(SUB2.id)
                && sub2.ProductCode__c == System.Label.iHASCOCreditProductCode){
                oldCredits.put(SUB2.id,sub2.Ihasco_Number_of_Credits__c);
            }
             
            
            if((sub2.SBQQ__RequiredById__c!= NULL && !RevisedLineItems.contains(sub2.Id) )
               && (sub2.SBQQ__Quantity__c >0 )){
                   if(prodcodes.contains(sub2.ProductCode__c)){
                       if(Numberofusers.containsKey(sub2.SBQQ__RequiredById__c)){
                           Decimal count = Numberofusers.get(sub2.SBQQ__RequiredById__c);
                           count = count + sub2.iHasco_Number_of_Users__c;
                           Numberofusers.put(sub2.SBQQ__RequiredById__c, count);
                       } else {
                           Numberofusers.put(sub2.SBQQ__RequiredById__c, sub2.iHasco_Number_of_Users__c);
                       }
                   }
                   
               }
        }
        
        this.LineItems = new List<LineItem>();
        List<String> AmendUBPKeyProductcodes = System.Label.iHASCOAmendUserKeyProducts.split(',');
        for(SBQQ__Subscription__c sc : Contr.SBQQ__Subscriptions__r){
            if((sc.SBQQ__RequiredById__c== NULL) && !Numberofusers.IsEmpty()){
                String stringid =String.valueOf(sc.id);
                sc.iHasco_Number_of_Users__c = Numberofusers.get(stringid);
            }
            
            if(sc.Purchase_Data_Time__c == NULL && sc.ProductCode__c == System.Label.iHASCOCreditProductCode
               && !oldCredits.isEmpty() && oldCredits.containskey(sc.SBQQ__RevisedSubscription__c)
               && oldCredits.get(sc.SBQQ__RevisedSubscription__c) > 0){
                   sc.Ihasco_Number_of_Credits__c = sc.Ihasco_Number_of_Credits__c - oldCredits.get(sc.SBQQ__RevisedSubscription__c);
               }
            
            if(!RevisedLineItems.contains(sc.Id)){
                if( (sc.ProductCode__c == System.Label.iHASCOCreditProductCode && sc.Purchase_Data_Time__c == NULL ) || (sc.ProductCode__c.Startswith('IH-RPM-'))){
                    this.CreditPurchases.add(new CreditPurchases(sc,this.EventType));
                } 	if(!RevisedLineItems.contains(sc.Id) && (sc.SBQQ__Quantity__c >0) && !AmendUBPKeyProductcodes.contains(sc.ProductCode__c)
                      && sc.ProductCode__c != System.Label.iHASCOCreditProductCode){
                    this.LineItems.add(new LineItem(sc));
                }
            }
        }
        this.AccountSites = new List<AccountSites>();
        for(Site__c s : sites){
            this.AccountSites.add(new AccountSites(s));
        }
        this.parent = new parent(contr);
        
    }
    
}