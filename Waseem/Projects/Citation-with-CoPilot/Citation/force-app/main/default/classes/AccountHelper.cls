public with sharing class AccountHelper {
  public  map<id,account> comAcc;
  public void commonUpdateMet(set<id> accidList,list<contract> ctrList) {
        comAcc = new map<id,account>([select id,MACV__c,Core_Contract_Renewal_Type__c,CoreCitationContractMonths__c,Coterm_Core_Contract_start_date__c from account where id In: accidList]);
        list<contract> ctrListCPQ = new list<contract>();
        list<SBQQ__QuoteLine__c> qtlLineCPQ = new list<SBQQ__QuoteLine__c>();
        list<account> acclistUpdate = new list<account>();
        List<String> listcoreProductCodes  = new List<String>();
        list<id> contractWithSub = new list<id>();
        Map<String, String> qlineIdContIdMap = new Map<String, String>();
        map<id,list<contract>> accidctrlist = new map<id,List<contract>>();
        map<id,Decimal> accountseg = new map<id,Decimal>();
        set<id> accountcommon = new set<id>();
        if(accidList.size()>0){
            //ctrList = [select id,Renewal_Type__c,CALC_Segmentation_Monthly_Amount__c,Contract_Value__c,No_of_Payments__c,account.id from contract where (Services_Taken_EL__c =true OR Services_Taken_HS__c = true OR Services_Taken_AI_Only__c = True OR Services_Taken_AI_Only_HS__c = True OR Services_Taken_Advice_Only__c = True OR Services_Taken_Advice_Only_HS__c = True) and status = 'Active' AND Account.Id In: accidList];
            listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
            ctrListCPQ = [select id,status,StartDate,Renewal_Type__c,EndDate,CALC_Segmentation_Monthly_Amount__c,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_AI_Only__c,Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Contract_Value__c,No_of_Payments__c,(select Id, name,Subscription_Term__c,SBQQ__BillingFrequency__c,Initial_Payment__c, SBQQ__QuoteLine__c,SBQQ__Contract__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c,Service_End_Date__c,Service_Start_Date__c from SBQQ__Subscriptions__r),account.id from contract where (status = 'Active' OR status = 'In Approval Process' OR status ='Pending Start') and Account.Id In: accidList];
            map<id,account> accMap = new map<id,account>();
            accMap = CoreContractService.CPDRenType(ctrList,ctrListCPQ,accidList);
            map<id,integer> segtoNull = new map<id,integer>(); 
 
             for(contract c:ctrListCPQ){
                if(c.status == 'Active'){
                    system.debug('Inside of an contract');
                    if(!c.SBQQ__Subscriptions__r.isEmpty()){
                     decimal segmentcal = 0.00;
                        accountcommon.add(c.account.id);
                     for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                             system.debug('sub.SBQQ__QuoteLine__r.SBQQ__ProductCode__c'+sub.SBQQ__QuoteLine__r.SBQQ__ProductCode__c);
                             system.debug('listcoreProductCodes'+listcoreProductCodes+sub.SBQQ__QuoteLine__c );
                       if (sub.SBQQ__QuoteLine__c != Null && listcoreProductCodes.contains(sub.SBQQ__QuoteLine__r.SBQQ__ProductCode__c)) {
                           system.debug('want to debug here 203');
                           integer tmp = 0;
                                                 
                            if(sub.SBQQ__BillingFrequency__c == 'One-Off'){
                               system.debug('want to debug here');
                               if(accountseg.containsKey(c.account.id)){
                                   segmentcal = accountseg.get(c.account.id) +  (sub.Initial_Payment__c/sub.Subscription_Term__c);
                                   accountseg.put(c.accountid,segmentcal);
                                   system.debug('segmentcal+++'+segmentcal+'acount map'+accountseg+'contract sub'+sub);
                               }
                               else {
                                   segmentcal = (sub.Initial_Payment__c/sub.Subscription_Term__c);
                                   accountseg.put(c.accountid,segmentcal);
								   system.debug('segmentcal+++'+segmentcal+'acount map'+accountseg+'contract sub'+sub);
                               }
                           }
                           if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                               system.debug('want to debug here');
                               if(accountseg.containsKey(c.account.id)){
                                   segmentcal = accountseg.get(c.account.id) + sub.Initial_Payment__c;
                                   accountseg.put(c.accountid,segmentcal);
                                      system.debug('segmentcal+++'+segmentcal+'acount map'+accountseg+'contract sub'+sub);
                               }
                               else {
                                   system.debug('want to debug here');
                                   segmentcal = sub.Initial_Payment__c;
                                   accountseg.put(c.accountid,segmentcal);
                                   system.debug('segmentcal+++'+segmentcal+'acount map'+accountseg+'contract sub'+sub);
                               }
                            }
                           if(sub.SBQQ__BillingFrequency__c == 'Annual'){
                               if(accountseg.containsKey(c.account.id)){
                                   segmentcal = accountseg.get(c.account.id) + ((sub.Subscription_Term__c/12) * sub.Initial_Payment__c)/sub.Subscription_Term__c;
                                   accountseg.put(c.accountid,segmentcal);
                                   system.debug('segmentcal+++'+segmentcal+'acount map'+accountseg+'contract sub'+sub);
                               }
                               else {
                                   segmentcal = ((sub.Subscription_Term__c/12) * sub.Initial_Payment__c)/sub.Subscription_Term__c;
                                   accountseg.put(c.accountid,segmentcal);
                                   system.debug('segmentcal+++'+segmentcal+'acount map'+accountseg+'contract sub'+sub);

                               }
                            }
                        }
                     }
                       
                 }

                 else if(c.Services_Taken_EL__c ==true || c.Services_Taken_HS__c == true || c.Services_Taken_AI_Only__c == True || c.Services_Taken_AI_Only_HS__c == True || c.Services_Taken_Advice_Only__c == True || c.Services_Taken_Advice_Only_HS__c == True){
                  	 decimal segmentcal = 0.00;
                     if(accountseg.containsKey(c.account.id)){
                                   segmentcal = accountseg.get(c.account.id) + c.CALC_Segmentation_Monthly_Amount__c;
                                   accountseg.put(c.accountid,segmentcal);
                               }
                               else {
                                   segmentcal = c.CALC_Segmentation_Monthly_Amount__c;
                                   accountseg.put(c.accountid,segmentcal);
                               }   
                  }
                }   
                 
            }
            
        if(accountseg.size()>0){
            for(id acid: accountseg.keyset()){
                if(accountseg.containsKey(acid)){
                      account acNew = new account();
                      acNew.id = acid;
                      acNew.MACV__c = accountseg.get(acid);
                      acclistUpdate.add(acNew);  
                }
            }   
        }
        if(accountcommon.size()>0){
                for(id ac:accountcommon){
                    if(!accountseg.containsKey(ac)){
                        account acNew = new account();
                        acNew.id = ac;
                        acNew.MACV__c = 0;
                        acclistUpdate.add(acNew);
                    }
                   
                }
        }
            
            
        list<account> actListFinal = new list<Account>();  
        system.debug('acclistUpdate+++'+acclistUpdate);
        system.debug('accMap+++'+accMap);
        if(acclistUpdate.size() >0 && accMap != null){
            
            for(account ac: acclistUpdate){
                if(accMap.containsKey(ac.id)){
                    ac.Core_Contract_Renewal_Type__c = accmap.get(ac.id).Core_Contract_Renewal_Type__c;
                    ac.CoreCitationContractMonths__c = accmap.get(ac.id).CoreCitationContractMonths__c;
                    ac.Coterm_Core_Contract_start_date__c = accmap.get(ac.id).Coterm_Core_Contract_start_date__c;
                    if(comAcc.get(ac.id).Core_Contract_Renewal_Type__c != accmap.get(ac.id).Core_Contract_Renewal_Type__c || comAcc.get(ac.id).CoreCitationContractMonths__c != accmap.get(ac.id).CoreCitationContractMonths__c || comAcc.get(ac.id).Coterm_Core_Contract_start_date__c != accmap.get(ac.id).Coterm_Core_Contract_start_date__c || comAcc.get(ac.id).MACV__c != accmap.get(ac.id).MACV__c){
                        actListFinal.add(ac);
                    }
                    
                }
                else{

                    actListFinal.add(ac);
                }
            }
            system.debug('actListFinal+++'+actListFinal);
            update actListFinal; 
        }   
        else if(acclistUpdate.size() >0 && !(accMap != null)){
           
            update acclistUpdate;

        }

        else if (!(acclistUpdate.size() >0) && accMap != null){
            update accMap.values();
        }                   

        }
                               
    }
}