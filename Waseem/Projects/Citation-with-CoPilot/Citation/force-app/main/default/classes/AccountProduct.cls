public with sharing class AccountProduct {
  
     @AuraEnabled(cacheable=true)
     public static list<subscriptionwrap> getSubscriptions(string recId){
         list<subscriptionwrap> subwrap = new list<subscriptionwrap>();
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
             list<Contract> ctList = [select id,Notice_Reason__c,Notice_Reason_2__c,Notice_Reason_3__c,name,status,(select id,SBQQ__Product__r.Name,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Contract__r.Status,Subscription_Term__c  from SBQQ__Subscriptions__r order by SBQQ__StartDate__c),StartDate,EndDate,ContractTerm,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_Env__c,Services_Taken_eRAMS__c,Services_Taken_AI_Only__c,
                                      Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Services_Taken_Training__c,Services_Taken_Consultancy__c,Services_Taken_JIT__c,Services_Taken_SBP__c,Business_Defence__c,CQC__c,Online_Tools_Only__c,UBT_Meeting_Room__c,QMS_9001__c,QMS_14001__c,QMS_18001__c,
                                      QMS_27001__c,Services_Taken_FRA__c from contract where accountid In: lstAccid order by StartDate];
         integer i=1;
         for(contract ct:ctList){
            if(!ct.SBQQ__Subscriptions__r.isEmpty()){
                for(SBQQ__Subscription__c sp: ct.SBQQ__Subscriptions__r){
                    integer tm;
                    string std = sp.SBQQ__StartDate__c.format();
                    string endd = sp.SBQQ__EndDate__c.format();
                    subwrap.add(new subscriptionwrap(sp.SBQQ__Contract__r.Status,sp.SBQQ__Product__r.Name,std,endd,sp.Subscription_Term__c,tm,i,ct.Notice_Reason__c,ct.Notice_Reason_2__c,ct.Notice_Reason_3__c));
                    i++;
                }        
             }
             else{
                 SBQQ__Subscription__c nosub = new SBQQ__Subscription__c();
                 //nosub.id = ct.id;
                 list<string> pnameList = new list<string>();
                 if(ct.Services_Taken_HS__c && ct.Services_Taken_EL__c){
                     pnameList.add('Dual Service - Health & Safety and HR');
                 }
                 else if (ct.Services_Taken_HS__c) pnameList.add('H&S Compliance Service');
                 else if (ct.Services_Taken_EL__c) pnameList.add('EL and HR Compliance Service');
                 if(ct.Services_Taken_Env__c) pnameList.add('Environmental');
                 if(ct.Services_Taken_eRAMS__c) pnameList.add('eRAMS');
                 if(ct.Services_Taken_AI_Only__c) pnameList.add('A&I Only EL & HR');
                 if(ct.Services_Taken_AI_Only_HS__c) pnameList.add('A&I Only H&S');
                 if(ct.Services_Taken_Advice_Only__c) pnameList.add('Advice Only EL & HR');
                 if(ct.Services_Taken_Advice_Only_HS__c) pnameList.add('Advice Only H&S');
                 if(ct.Services_Taken_Training__c) pnameList.add('Training');
                 if(ct.Services_Taken_Consultancy__c) pnameList.add('Consultancy');
                 if(ct.Services_Taken_JIT__c) pnameList.add('JIT Tribunal');
                 if(ct.Services_Taken_SBP__c) pnameList.add('Environmental');
                 if(ct.Business_Defence__c) pnameList.add('Business Defence');
                 if(ct.CQC__c) pnameList.add('CQC');
                 if(ct.UBT_Meeting_Room__c) pnameList.add('UBT Meeting Room');
                 if(ct.QMS_9001__c) pnameList.add('QMS 9001');
                 if(ct.QMS_14001__c) pnameList.add('QMS 14001');
                 if(ct.QMS_18001__c) pnameList.add('QMS 18001');
                 if(ct.QMS_27001__c) pnameList.add('QMS 27001');
                 if(ct.Services_Taken_FRA__c) pnameList.add('Fire Risk Assessments');
                 if(ct.Online_Tools_Only__c) pnameList.add('Online Tools Only');              

                 Decimal tms;
                 if(pnameList.size()>0){
                     for(string st:pnameList){
                         string pname = st;
                         string std = ct.StartDate.format();
                         string endd = ct.EndDate.format();
                         subwrap.add(new subscriptionwrap(ct.status,pname,std,endd,tms,ct.ContractTerm,i,ct.Notice_Reason__c,ct.Notice_Reason_2__c,ct.Notice_Reason_3__c));
                     }
                         
                 }   
                 
             }
             i++;
             
         }
            
          System.debug(subwrap);
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
         public String ntrs1 {get;set;}
         @AuraEnabled
         public String ntrs2 {get;set;}
         @AuraEnabled
         public String ntrs3 {get;set;}
         public subscriptionwrap(string subStat,string pdname,string sddate,string eddate,decimal stterm,integer stcterm,integer ud,string nt1,string nt2,string nt3){
             string temps = subStat;
             this.isActiveSub = (temps == 'Active')?true:false;
             this.ProductName = pdname;  
             this.stdate = sddate;
             this.endate = eddate;
             this.sbterm = stterm == null? (Decimal)stcterm:stterm;
             this.recun = ud;
             this.ntrs1 = nt1;
             this.ntrs2 = nt2;
             this.ntrs3 = nt3;
         }
         
        }

        @AuraEnabled(cacheable=true)
        public static list<Account> getAccountDetails(string recId){
            list<id> rid = new list<id>();
            rid.add(recId);
            event et = [select id,accountid from event where id In: rid];
            list<string> actstr = new list<String>();
            actstr.add(et.accountid);
            list<account> ac = [select id,FT_Employees__c,PT_Employees__c,Sites__c,Industry from account where id In: actstr];
            return ac;

        }
}