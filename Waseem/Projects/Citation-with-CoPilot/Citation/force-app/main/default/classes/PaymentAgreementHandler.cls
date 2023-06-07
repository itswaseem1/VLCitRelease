public class PaymentAgreementHandler{

public PaymentAgreementHandler(){
}

public static void updateAccount(map<id,PAYREC2__Payment_Agreement__c> newMapPTC,map<id,PAYREC2__Payment_Agreement__c> oldMapPTC ){
    map<id,account> mpacct = new map<id,account>();
    set<id> acsetid = new set<id>();

    for(PAYREC2__Payment_Agreement__c ppla: newMapPTC.values() ){
        if(newMapPTC.get(ppla.id).PAYREC2__Status__c != oldMapPTC.get(ppla.id).PAYREC2__Status__c
          || newMapPTC.get(ppla.Id).FFCompany__c!= oldMapPTC.get(ppla.id).FFCompany__c){
            acsetid.add(ppla.PAYREC2__Account__c);
        }
    }
    
    list<PAYREC2__Payment_Agreement__c> PPA = [select id,PAYREC2__Account__c,PAYREC2__Status__c,FFCompany__r.Name from PAYREC2__Payment_Agreement__c where PAYREC2__Account__c in: acsetid ];
    set<id> acid = new set<id>();

    for(PAYREC2__Payment_Agreement__c pct: PPA){
        if((pct.PAYREC2__Status__c == 'On Going' || pct.PAYREC2__Status__c == 'New instruction' || pct.PAYREC2__Status__c == 'First collection') && pct.FFCompany__r.Name == System.Label.Payonomy_Company){
            account ac = new account();
            ac.id = pct.PAYREC2__Account__c;
            mpacct.put(pct.PAYREC2__Account__c,ac);
            acid.add(ac.id);
        }
        else{
            if(!mpacct.containskey(pct.id)){
                account ac = new account();
                ac.id = pct.PAYREC2__Account__c;
                ac.Valid_Direct_Debit__c = 'No current DD';
                mpacct.put(ac.id,ac);
                
            }
        }
    }
    
    map<id,account> aclist = corecontacts(acid);
    
    for(id ac: aclist.keySet()){
        account temp = mpacct.get(ac);
        temp.Valid_Direct_Debit__c = aclist.get(ac).Valid_Direct_Debit__c;
        mpacct.put(ac,temp);
    }
    
    if(mpacct != null){
        update mpacct.values();
    }

}

public static map<id,account> CoreContacts(set<id> accidSet){
map<id,list<contract>> accContractList = new map<id,list<contract>>();
set<id> ctrSetId = new set<id>();
//ctIdnAc - not active contract id's
set<id> ctIdnAc = new set<id>();
set<id> oppId = new set<id>();
//map to store the contract and billing contract id's
map<id,id> ConBil = new map<id,id>();
List<String> listcoreProductCodes  = new List<String>();
list<contract> cpqCTList = [select id,status,Source_Opportunity__c,Source_Opportunity__r.Original_Contract__r.Id,Renewal_Type__c,EndDate,CALC_Segmentation_Monthly_Amount__c,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_AI_Only__c,Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Contract_Value__c,No_of_Payments__c,(select Id, name,Subscription_Term__c,SBQQ__BillingFrequency__c,Initial_Payment__c, SBQQ__QuoteLine__c,SBQQ__Contract__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c,Service_End_Date__c from SBQQ__Subscriptions__r),account.id from contract where (status = 'Active' OR status = 'In Approval Process' OR status ='Pending Start') and Account.Id In: accidSet];
if(cpqCTList.size()>0){
            listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
            //ctrListCPQ = [select id,Renewal_Type__c,CALC_Segmentation_Monthly_Amount__c,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_AI_Only__c,Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Contract_Value__c,No_of_Payments__c,(select Id, name,Subscription_Term__c,SBQQ__BillingFrequency__c,Initial_Payment__c, SBQQ__QuoteLine__c,SBQQ__Contract__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c from SBQQ__Subscriptions__r),account.id from contract where status = 'Active' and Account.Id In: accidList];
            //map<id,integer> segtoNull = new map<id,integer>(); 
 
             for(contract c:cpqCTList){
                    
                    if(!c.SBQQ__Subscriptions__r.isEmpty()){
                        if(c.status != 'Active'){
                            ctrSetId.add(c.Source_Opportunity__r.Original_Contract__r.Id);
                            ConBil.put(c.id,c.Source_Opportunity__r.Original_Contract__r.Id);
                        }
                        for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                            if (sub.SBQQ__QuoteLine__c != Null && listcoreProductCodes.contains(sub.SBQQ__QuoteLine__r.SBQQ__ProductCode__c)) {
                                   
                                ctrSetId.add(c.id);
                                if(accContractList.containskey(c.accountid)){
                                    list<contract> tempList = accContractList.get(c.accountid);
                                    templist.add(c);
                                    accContractList.put(c.accountid,templist);
                                } 
                                else{
                                    list<contract> temp = new list<contract>();
                                    temp.add(c);
                                    accContractList.put(c.accountid,temp);
                                }
                           }
                        }
                       
                    }
                 if(c.Services_Taken_EL__c ==true || c.Services_Taken_HS__c == true || c.Services_Taken_AI_Only__c == True || c.Services_Taken_AI_Only_HS__c == True || c.Services_Taken_Advice_Only__c == True || c.Services_Taken_Advice_Only_HS__c == True){
                            ctrSetId.add(c.id);
                            if(c.status != 'Active'){
                                ctrSetId.add(c.Source_Opportunity__r.Original_Contract__r.Id);
                                ConBil.put(c.id,c.Source_Opportunity__r.Original_Contract__r.Id);
                            }
                            if(accContractList.containskey(c.accountid)){
                                    list<contract> tempList = accContractList.get(c.accountid); 
                                    templist.add(c);
                                    accContractList.put(c.accountid,templist);
                                } 
                                else{
                                    list<contract> temp = new list<contract>();
                                    temp.add(c);
                                    accContractList.put(c.accountid,temp);
                                }
                 }
            }
        }   
    //Account & Billing Contract mapping
    map<id,ffbc__Contract__c>   mapBillingContract = new map<id,ffbc__Contract__c>();  
    map<id,list<ffbc__Contract__c>> mapIdBillingContractList = new map<id,list<ffbc__Contract__c>>();
    map<id,ffbc__Contract__c> mpBilling = new map<id,ffbc__Contract__c>();
    list<ffbc__Contract__c> listBillingContract = [select id,SF_Contract__c,Preferred_Payment_Date__c,ffbc__StartDate__c, (select id,ffbc__ProductService__r.ProductCode from ffbc__ContractLineItems__r),ffbc__EndDate__c,ffbc__Account__c from ffbc__Contract__c where (ffbc__Status__c = 'Active' OR ffbc__Status__c = 'Draft') and ffbc__Account__c in : accidSet];
    for(ffbc__Contract__c bct: listBillingContract){
        for(ffbc__ContractLineItem__c clt: bct.ffbc__ContractLineItems__r){
            if (listcoreProductCodes.contains(clt.ffbc__ProductService__r.ProductCode)) {
                if(bct.SF_Contract__c != null){
                    mpBilling.put(bct.SF_Contract__c,bct);
                }
                if(mapIdBillingContractList.containsKey(bct.ffbc__Account__c)){
                    list<ffbc__Contract__c> tempbcList = new list<ffbc__Contract__c>();
                    tempbcList = mapIdBillingContractList.get(bct.ffbc__Account__c);
                    tempbcList.add(bct);
                    mapIdBillingContractList.put(bct.ffbc__Account__c,tempbcList);
                }
                else{
                    list<ffbc__Contract__c> tempbcList = new list<ffbc__Contract__c>();
                    tempbcList.add(bct);
                    mapIdBillingContractList.put(bct.ffbc__Account__c,tempbcList);
                }
            }
            
        }
        
    }
    system.debug('map of account and billing contracts list '+mapIdBillingContractList);

    map<id,date> bliveenddate = new map<id,date>(); 
    map<id,ffbc__Contract__c> bmpcontract = new map<id,ffbc__Contract__c>();
    for(id acid: mapIdBillingContractList.keySet()){
        for(ffbc__Contract__c ct:mapIdBillingContractList.get(acid) ){
                if(bliveenddate.containsKey(ct.id)){
                    date tempdt = bliveenddate.get(ct.id);
                    if(tempdt < ct.ffbc__EndDate__c){
                        bliveenddate.put(ct.id,ct.ffbc__EndDate__c);
                        bmpcontract.put(ct.ffbc__Account__c,ct);
                    }
               
                }
                else{
                    date tempdt = ct.ffbc__EndDate__c;
                    bliveenddate.put(ct.id,ct.ffbc__EndDate__c);
                    bmpcontract.put(ct.ffbc__Account__c,ct);
                }
            }
    }


    //Contract and date mapping
    map<id,date> liveenddate = new map<id,date>(); 
    map<id,contract> mpcontract = new map<id,contract>();
    for(id acid: accContractList.keySet()){
        for(contract ct:accContractList.get(acid) ){
            if(liveenddate.containsKey(ct.id)){
                date tempdt = liveenddate.get(ct.id);
                if(tempdt < ct.enddate){
                    liveenddate.put(ct.id,ct.enddate);
                    mpcontract.put(ct.accountid,ct);
                }
               
            }
            else{
                date tempdt = ct.enddate;
                liveenddate.put(ct.id,ct.enddate);
                mpcontract.put(ct.accountid,ct);
            }


        }
    }
    
    //update accounts with preferred payment date
    map<id,account> acclist = new map<id,account>();
    for(id aci: mpcontract.keyset()){
        
        contract ct = mpcontract.get(aci);
        account tempac = new account();
        tempac.id = aci;
        if(ct.status != 'Active'){
             tempac.Valid_Direct_Debit__c = mpBilling.ContainsKey(ConBil.get(ct.id)) ? mpBilling.get(ConBil.get(ct.id)).Preferred_Payment_Date__c : bmpcontract.ContainsKey(ct.accountid) ? bmpcontract.get(ct.accountid).Preferred_Payment_Date__c : 'No current DD' ;
        }
        else{
            tempac.Valid_Direct_Debit__c = mpBilling.ContainsKey(ct.id) ? mpBilling.get(ct.id).Preferred_Payment_Date__c : bmpcontract.ContainsKey(ct.accountid) ? bmpcontract.get(ct.accountid).Preferred_Payment_Date__c : 'No current DD';
        }
        
        acclist.put(aci,tempac);
        
    }

   



return acclist;

}

public static void afterInsertQ(map<id,PAYREC2__Payment_Agreement__c> newMapPTC){
    set<id> acsetid = new set<id>();
    for(PAYREC2__Payment_Agreement__c ppla: newMapPTC.values() ){
        acsetid.add(ppla.PAYREC2__Account__c);
    }
    set<id> acid = new set<id>();
    list<PAYREC2__Payment_Agreement__c> PPA = [select id,PAYREC2__Account__c,PAYREC2__Status__c,FFCompany__r.Name from PAYREC2__Payment_Agreement__c where PAYREC2__Account__c in: acsetid];
    map<id,account> mpacct = new map<id,account>();

    for(PAYREC2__Payment_Agreement__c pct: PPA){
        if((pct.PAYREC2__Status__c == 'On Going' || pct.PAYREC2__Status__c == 'New instruction' || pct.PAYREC2__Status__c == 'First collection') && pct.FFCompany__r.Name == System.Label.Payonomy_Company){
            account ac = new account();
            ac.id = pct.PAYREC2__Account__c;
            mpacct.put(ac.id,ac);
            acid.add(ac.id);
        }
        else{
            if(!mpacct.containskey(pct.id)){
                account ac = new account();
                ac.id = pct.PAYREC2__Account__c;
                ac.Valid_Direct_Debit__c = 'No current DD';
                mpacct.put(ac.id,ac);
                
            }
        }
    }

     map<id,account> aclist = corecontacts(acid);
    
    for(id ac: aclist.keySet()){
        account temp = mpacct.get(ac);
        temp.Valid_Direct_Debit__c = aclist.get(ac).Valid_Direct_Debit__c;
        mpacct.put(ac,temp);
    }
    
    if(mpacct != null){
        update mpacct.values();
    }

}

}