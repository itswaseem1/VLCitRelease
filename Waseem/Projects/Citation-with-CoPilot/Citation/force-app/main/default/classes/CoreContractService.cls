public class CoreContractService{
   
public static map<id,date> cstartDate = new map<id,date>();    
    public CoreContractService(){   
    } 

    public static map<id,list<contract>> coreContractAccounts(list<contract> ctrListCPQ){
        
        set<contract> coreContracts = new set<contract>();
        List<String> listcoreProductCodes  = new List<String>();
        map<id,list<contract>> accountseg = new map<id,list<contract>>();
        set<id> accountset = new set<id>();     
        if(ctrListCPQ.size()>0){
            listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
            //ctrListCPQ = [select id,Renewal_Type__c,CALC_Segmentation_Monthly_Amount__c,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_AI_Only__c,Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Contract_Value__c,No_of_Payments__c,(select Id, name,Subscription_Term__c,SBQQ__BillingFrequency__c,Initial_Payment__c, SBQQ__QuoteLine__c,SBQQ__Contract__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c from SBQQ__Subscriptions__r),account.id from contract where status = 'Active' and Account.Id In: accidList];
            //map<id,integer> segtoNull = new map<id,integer>(); 
 
             for(contract c:ctrListCPQ){
                if(c.status == 'Active' && c.enddate >= system.today()){
                    if(!c.SBQQ__Subscriptions__r.isEmpty()){
                        for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                            if (sub.SBQQ__QuoteLine__c != Null && listcoreProductCodes.contains(sub.SBQQ__QuoteLine__r.SBQQ__ProductCode__c)) {
                                coreContracts.add(c);
                                if(accountseg.containsKey(c.accountid)){
                                    list<contract> tempListCon = new list<contract>();
                                    tempListCon = accountseg.get(c.accountid);
                                    tempListCon.add(c);
                                    accountseg.put(c.accountid,tempListCon);
                                }
                                else {
                                    list<contract> tempListCon = new list<contract>();
                                    tempListCon.add(c);
                                    accountseg.put(c.accountid,tempListCon);
                                }       
                           }
                        }
                       
                    }
                 if(c.Services_Taken_EL__c ==true || c.Services_Taken_HS__c == true || c.Services_Taken_AI_Only__c == True || c.Services_Taken_AI_Only_HS__c == True || c.Services_Taken_Advice_Only__c == True || c.Services_Taken_Advice_Only_HS__c == True){
                     decimal segmentcal = 0.00;
                         if(accountseg.containsKey(c.accountid)){
                                    list<contract> tempListCon = new list<contract>();
                                    tempListCon.addall(accountseg.get(c.accountid));
                                    tempListCon.add(c);
                                    accountseg.put(c.accountid,tempListCon);
                                }
                                else {
                                    list<contract> tempListCon = new list<contract>();
                                    tempListCon.add(c);
                                    accountseg.put(c.accountid,tempListCon);
                                } 
                 }
                 accountset.add(c.accountid);
                } 
                    
            }
        }
    system.debug('account seg from 56+++'+accountseg);
    return accountseg;    
    }

    public static map<id,integer> remaingCoreContractMonths(list<contract> ctrListCPQ){
        set<contract> remcoreContracts = new set<contract>();
        List<String> remlistcoreProductCodes  = new List<String>();
        map<id,list<contract>> remaccountseg = new map<id,list<contract>>();
        map<id,integer> acRemainingMonths = new map<id,integer>();      
        if(ctrListCPQ.size()>0){
            remlistcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
            //ctrListCPQ = [select id,Renewal_Type__c,CALC_Segmentation_Monthly_Amount__c,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_AI_Only__c,Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Contract_Value__c,No_of_Payments__c,(select Id, name,Subscription_Term__c,SBQQ__BillingFrequency__c,Initial_Payment__c, SBQQ__QuoteLine__c,SBQQ__Contract__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c from SBQQ__Subscriptions__r),account.id from contract where status = 'Active' and Account.Id In: accidList];
            //map<id,integer> segtoNull = new map<id,integer>(); 
 
             for(contract c:ctrListCPQ){
              
                    if(!c.SBQQ__Subscriptions__r.isEmpty() && c.enddate >= system.today()){
                        for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                            if (sub.SBQQ__QuoteLine__c != Null && remlistcoreProductCodes.contains(sub.SBQQ__QuoteLine__r.SBQQ__ProductCode__c)) {
                                remcoreContracts.add(c);
                                
                                //Logic to find the longest duration on subscriptions 
                                date dt = date.today();
                                
                                integer stday = dt.day();
                                integer lstdday = sub.Service_End_Date__c.day();
                                Integer monthsBetween;
                                if(stday > lstdday + 1){
                                    monthsBetween = ((dt.monthsBetween(sub.Service_End_Date__c) - 1)>0)?(dt.monthsBetween(sub.Service_End_Date__c) - 1):0;
                                }
                                else {
                                    monthsBetween = (dt.monthsBetween(sub.Service_End_Date__c))>0?dt.monthsBetween(sub.Service_End_Date__c):0;
                                }
                                if(acRemainingMonths.containskey(c.accountid)){
                                    integer current = acRemainingMonths.get(c.accountid);
                                    If(current>monthsBetween){
                                        acRemainingMonths.put(c.accountid,current);
                                        
                                    }
                                    else{
                                        acRemainingMonths.put(c.accountid,monthsBetween);
                                        cstartDate.put(c.accountid,sub.Service_Start_Date__c);
                                    }
                                    
                                }
                                else{
                                    acRemainingMonths.put(c.accountid,monthsBetween);
                                    cstartDate.put(c.accountid,sub.Service_Start_Date__c);
                                }

                                   
                           }
                        }
                       
                    }
                 if(c.Services_Taken_EL__c ==true || c.Services_Taken_HS__c == true || c.Services_Taken_AI_Only__c == True || c.Services_Taken_AI_Only_HS__c == True || c.Services_Taken_Advice_Only__c == True || c.Services_Taken_Advice_Only_HS__c == True){
                      date dt = date.today();
                                
                                integer stday = dt.day();
                                integer lstdday = c.EndDate.day();
                                Integer monthsBetween;
                     			
                                if(stday > lstdday + 1){
                                    monthsBetween = ((dt.monthsBetween(c.EndDate) - 1)>0)?(dt.monthsBetween(c.EndDate) - 1):0;
                                }
                                else {
                                    monthsBetween = (dt.monthsBetween(c.EndDate))>0?dt.monthsBetween(c.EndDate):0;
                                }   
                     //date dt = date.today();
                       // Integer monthsBetween = dt.monthsBetween(c.EndDate);
                        if(acRemainingMonths.containskey(c.accountid)){
                                    integer current = acRemainingMonths.get(c.accountid);
                                    
                                    If(current>monthsBetween){
                                        acRemainingMonths.put(c.accountid,current);
                                    }
                                    else{
                                        acRemainingMonths.put(c.accountid,monthsBetween);
                                        cstartDate.put(c.accountid,c.startdate);
                                       
                                    }
                        }
                        else{
                                acRemainingMonths.put(c.accountid,monthsBetween);
                                cstartDate.put(c.accountid,c.startdate);
                        }

                 }
               
                    
            }
        }
    
    return acRemainingMonths;  
    }

    //This contract returns the account ids of the contracts
    public static set<id> getccountid(list<contract> newobjects){
        set<id> accidList = new set<id>();
        for(contract ct:newobjects){
            accidList.add(ct.accountid);
        }

        return accidList;
    }

    //This method returns the contracts with not active status
    public static list<contract> getnotactContract(list<contract> newobjects){
        list<contract> gtnoActiveContr = new list<contract>();
        for(contract ct:newobjects){
             if(ct.status != 'Active'){
                gtnoActiveContr.add(ct);
            }
        }

        return gtnoActiveContr;
    }

    public static map<id,account> CPDRenType(list<contract> newobjects,list<contract> CPQContracts,set<id> acidset){
        
        map<id,list<contract>> accContractList = coreContractAccounts(CPQContracts);
        map<id,set<string>> idRenType = new  map<id,set<string>>();
        map<id,account> accountmpa = new map<id,account>();
        list<contract> noActiveContr = getnotactContract(newobjects);
        map<id,integer> acMonth = remaingCoreContractMonths(CPQContracts);

        if(accContractList.size()>0){
            for(list<contract> ctrval1: accContractList.values()){
                for(contract ctrval :ctrval1 ){
                    system.debug('ctrval --->'+ctrval);
                    if(accountmpa.containsKey(ctrval.accountid)){
                            account act = new account();
                            act = accountmpa.get(ctrval.accountid);
                            if(act.Core_Contract_Renewal_Type__c != 'Auto'){
                                act.Core_Contract_Renewal_Type__c = ctrval.Renewal_Type__c;
                            }
                            
                            accountmpa.put(act.id,act);
                        }
                    else{
                            account act = new account();
                            act.id = ctrval.accountid;
                            act.Core_Contract_Renewal_Type__c = ctrval.Renewal_Type__c;
                            accountmpa.put(act.id,act);
                        }
                }
            }
        }
        for(id acid :acidset){
            if(!accountmpa.containsKey(acid)){
                account act = new account();
                act.id = acid;
                act.Core_Contract_Renewal_Type__c = '';
                act.CoreCitationContractMonths__c = 0;
                act.Coterm_Core_Contract_start_date__c = null;
                accountmpa.put(act.id,act);
            }
        }

         if(acMonth.size()>0){
            for(id acid: acMonth.keySet()){
                if(accountmpa.containsKey(acid)){
                    account ac = accountmpa.get(acid);
                    ac.CoreCitationContractMonths__c = acMonth.get(acid);
                    ac.Coterm_Core_Contract_start_date__c = cstartDate.get(acid);
                    accountmpa.put(ac.id,ac);
                }
                else{
                    account ac = new account();
                    ac.id = acid;
                    ac.CoreCitationContractMonths__c =  acMonth.get(acid);
                    ac.Coterm_Core_Contract_start_date__c = cstartDate.get(acid);
                    accountmpa.put(ac.id,ac);
                }
            }
        }

        system.debug('Here you go at noActiveContract'+noActiveContr);
        if(noActiveContr.size()>0){
            for(contract ctrN: noActiveContr){
                if(!accountmpa.containsKey(ctrn.accountid)){
                    account ac = new account();
                    ac.id = ctrN.accountid;
                    ac.Core_Contract_Renewal_Type__c = '';
                    ac.CoreCitationContractMonths__c = 0;
                    ac.Coterm_Core_Contract_start_date__c = null;
                    accountmpa.put(ac.id,ac);
                }
                else {
                    account ac = accountmpa.get(ctrN.accountid);
                    //ac.Core_Contract_Renewal_Type__c = '';
                    //accountmpa.put(ac.id,ac);
                }
            }
        }

       

        if(accountmpa.size()>0){
            //update accountmpa.values();
            system.debug('account mpa'+accountmpa);
            return accountmpa;

        }
        
        /*if(idRenType.size()>0){
            for(id acid: idRenType.keyset()){
                string tampstrk = '';
                account tempac = new account();
                for(string s: idRenType.get(acid)){
                   tampstrk = tampstrk+s+ ';';
                }    
                tempac.id = acid;
                tempac.

            } 
        }    */
        return null;

    }

   
}