public with sharing class iHASCOAccountProducts {
  
     @AuraEnabled(cacheable=true)
     public static list<subscriptionwrap> getSubscriptions(string recId){
       
         list<subscriptionwrap> subwrap = new list<subscriptionwrap>();
         list<subscriptionwrap> ordwrap = new list<subscriptionwrap>();
          list<string> lstAccid = new list<string>();
         if(recId.startsWith('001')){
            lstAccid.add(recId);
         }
         else if(recId.startsWith('00U')){
             list<string> lstEventid = new list<string>();
             lstEventid.add(recId);
             list<event> evt = [select id,accountid from event where id in: lstEventid limit 1];
             lstAccid.add(evt[0].accountid);
            
         }
         if(lstAccid.size()>0){
             list<Contract> ctList = [select id,License_Model__c,name,status,StartDate,EndDate,ContractTerm,
                                      (select id,SBQQ__Product__r.ProductCode,SBQQ__Product__r.Name,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Contract__r.Status,Subscription_Term__c,SBQQ__Quantity__C,SBQQ__RevisedSubscription__c,SBQQ__Contract__r.License_Model__c  from SBQQ__Subscriptions__r order by SBQQ__StartDate__c)
                                      
                                       from contract where accountid In: lstAccid order by StartDate];
        map<id,SBQQ__Subscription__c>      mapListSub = new map<id,SBQQ__Subscription__c>();
        set<id>   revisedSub = new set<id>();
        integer i=1;
         for(contract ct:ctList){
            if(!ct.SBQQ__Subscriptions__r.isEmpty()){
                for(SBQQ__Subscription__c sp: ct.SBQQ__Subscriptions__r){
                    if(!(sp.SBQQ__Product__r.ProductCode == 'IHCBP' || sp.SBQQ__Product__r.ProductCode == 'IHUBP' || 
                      sp.SBQQ__Product__r.ProductCode == 'IHRPM' ||  sp.SBQQ__Product__r.ProductCode == 'IHAS'))
                   {
                            mapListSub.put(sp.id,sp);
                            if (sp.SBQQ__RevisedSubscription__c != null){
                                revisedSub.add(sp.SBQQ__RevisedSubscription__c);
                            }
                    }                                    
                           
                   }
                }        
             }

             for(id rsbid: revisedSub){
                if(mapListSub.containsKey(rsbid)){
                    mapListSub.remove(rsbid);
                }
            }
            
            for(SBQQ__Subscription__c subL1: mapListSub.values()){
                if(subL1.SBQQ__Quantity__c == -1){
                    mapListSub.remove(subL1.id);
                }
            }
            for(SBQQ__Subscription__c  sbc: mapListSub.values()){
                if(sbc.SBQQ__Quantity__C != -1){
                    integer tm;
                    string std = sbc.SBQQ__StartDate__c.format();
                    string endd = sbc.SBQQ__EndDate__c.format();
                    subwrap.add(new subscriptionwrap(sbc.SBQQ__Contract__r.Status,sbc.SBQQ__Product__r.Name,std,endd,sbc.Subscription_Term__c,tm,i,sbc.SBQQ__Contract__r.License_Model__c,null,0.0));
                    i++;
                }
            }
            System.debug(subwrap);
             //subOrdwrap.add(subwrap);
          return subwrap;
         }
            
          
     
         return null;
         
     }
    
    public class subscriptionwrap{
         @AuraEnabled
         public boolean isActiveSub {get;set;}
         @AuraEnabled
         public string ProductName {get;set;}
         @AuraEnabled
         public string stdate {get;set;}
         @AuraEnabled
         public string endate {get;set;}
         @AuraEnabled
         public decimal sbterm {get;set;}
         @AuraEnabled
         public integer recun {get;set;}
         @AuraEnabled
         public String LicenseModel {get;set;}
        @AuraEnabled
         public String orderType {get;set;}
        @AuraEnabled
         public decimal Price {get;set;}
        @AuraEnabled
         public boolean isPilotOrder {get;set;}
         public subscriptionwrap(string subStat,string pdname,string sddate,string eddate,decimal stterm,integer stcterm,integer ud,string lM,String oT,Decimal price){
             string temps = subStat;
             this.isActiveSub = (temps == 'Active' || temps == 'In Amendment')?true:false;
             this.ProductName = pdname;  
             this.stdate = sddate;
             this.endate = eddate;
             this.sbterm = stterm == null? (Decimal)stcterm:stterm;
             this.recun = ud;
             this.LicenseModel = lM;
             this.orderType = oT;
             this.price = price;
             this.isPilotOrder = (oT =='Pilot Order') ? true : false;

         }
         
        }

        @AuraEnabled(cacheable=true)
        public static list<subscriptionwrap> getOrderDetails(string recId){
            list<subscriptionwrap> subwrap = new list<subscriptionwrap>();
         list<subscriptionwrap> ordwrap = new list<subscriptionwrap>();
          list<string> lstAccid = new list<string>();
         if(recId.startsWith('001')){
            lstAccid.add(recId);
         }
         else if(recId.startsWith('00U')){
             list<string> lstEventid = new list<string>();
             lstEventid.add(recId);
             list<event> evt = [select id,accountid from event where id in: lstEventid limit 1];
             lstAccid.add(evt[0].accountid);
            
         }
         if(lstAccid.size()>0){
             list<Order> orderList = [select id,License_Model__c,name,status,EffectiveDate,EndDate,
                                      (select id,Product2.Name,Order.License_Model__c,SBQQ__QuotedListPrice__c,ServiceDate,EndDate,Order.Status,Product2.ProductCode,order.SBQQ__Quote__r.Quote_type__c	  from OrderItems order by ServiceDate)
                                      
                                       from Order where accountid In: lstAccid order by EffectiveDate];
         integer i=1;
         for(Order od:orderList){
            if(!od.OrderItems.isEmpty()){
                for(OrderItem oi: od.OrderItems){
                    if(!(oi.Product2.ProductCode == 'IHCBP' || oi.Product2.ProductCode == 'IHUBP' || 
                      oi.Product2.ProductCode == 'IHRPM' ||  oi.Product2.ProductCode == 'IHAS') )
                   {
                    integer tm;
                    string std = oi.ServiceDate.format();
                    string endd = oi.EndDate.format();
                    subwrap.add(new subscriptionwrap(oi.Order.Status,oi.Product2.Name,std,endd,1,tm,i,oi.Order.License_Model__c,oi.Order.SBQQ__Quote__r.Quote_type__c,oi.SBQQ__QuotedListPrice__c));
                    i++;
                   }
                }        
             }

             i++;
             
         }
            
          System.debug(subwrap);
             //subOrdwrap.add(subwrap);
          return subwrap;
         }

         return null;
            

        }
}