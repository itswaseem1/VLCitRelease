public class ContractLineItemHandler{
    public static boolean flag = false;
    
    public void attachRevRecTemplate(List<ffbc__ContractLineItem__c> LineItems) {
        string RevRecTemplateName = System.label.ContractLineItem_RevRecTemplateName;
        list<ffrr__Template__c> templateList = [select id from ffrr__Template__c where name = :RevRecTemplateName] ;
        if(templateList.size() == 1) {
            for(ffbc__ContractLineItem__c cli : LineItems) {
                cli.ffrrtemplate__c = templateList[0].id ;
            }
        }
    }

    public void appendFields(List<ffbc__ContractLineItem__c> contractNew){
        Set<Id> contractId = new Set<Id>();
        Set<String> productVal = new Set<String>();
        Set<Decimal> conMon = new Set<Decimal>();
        Set<String> conType = new Set<String>();
        Set<String> billType = new Set<String>();
        Set<String> conComp = new Set<String>();
        Set<String> rrlVal = new Set<String>();
        
        Map<String,Id> revFields = new Map<String,Id>();   
        Map<Id,String> companyNameRev = new Map<Id,String>();
        Map<String,Id> contractFields = new Map<String,Id>();
        List<String> companyNames = new List<String>();
        List<ffbc__ContractLineItem__c> con = new List<ffbc__ContractLineItem__c>();
        List<ffbc__ContractLineItem__c> contractLine = new List<ffbc__ContractLineItem__c>();

    	for(ffbc__ContractLineItem__c c : contractNew){
            if(c.Migrated_from_Sage__c == false){
                contractId.add(c.Id);
          		System.debug('contractId+++' + contractId);
            }
        }

        for(ffbc__ContractLineItem__c cli : [SELECT ffbc__ProductService__r.Product_Grouping__c, Service_Months_in_Contract__c, ffbc__Contract__r.Contract_Type__c, ffbc__Contract__r.ffbc__Company__c,ffbc__BillingType__c FROM ffbc__ContractLineItem__c WHERE Id=:contractId ]){
            System.debug('cli+++' + cli);
            if( cli.ffbc__Contract__r.Contract_Type__c != null && cli.ffbc__ProductService__r.Product_Grouping__c != null &&
                cli.ffbc__Contract__r.ffbc__Company__c != null && cli.Service_Months_in_Contract__c != null ){
                  con.add(cli);
                  productVal.add(cli.ffbc__BillingType__c == 'One-off'?'One-Off':cli.ffbc__ProductService__r.Product_Grouping__c);
                  conMon.add(cli.Service_Months_in_Contract__c);
                  conType.add(cli.ffbc__Contract__r.Contract_Type__c);
                  conComp.add(cli.ffbc__Contract__r.ffbc__Company__c); 
                  billType.add(cli.ffbc__BillingType__c);
                }
            System.debug('productVal+++' + productVal + ' ' + conMon +' '+ conType +' '+ conComp);
        }

        for(fferpcore__Company__c compN: [SELECT Id, Name from fferpcore__Company__c WHERE Id IN:conComp]){
          companyNameRev.put(compN.Id, compN.Name);
        }
        System.debug('companyNameRev+++' + companyNameRev);
        
        if(!productVal.isEmpty() && !conMon.isEmpty() && !conType.isEmpty() && !conComp.isEmpty() ){
                for(Revenue_Recognition_Logic__c rrl : [SELECT Product_Grouping__c, New_or_Renewal__c, Term_months__c, Selling_Company__c, Id FROM Revenue_Recognition_Logic__c WHERE Product_Grouping__c IN:productVal AND New_or_Renewal__c IN:conType AND Term_months__c IN:conMon AND Selling_Company__c IN:companyNameRev.values()]){            
                    System.debug('rrl+++' + rrl);
                    String rev = rrl.Product_Grouping__c + ' - ' + rrl.Term_months__c + ' - ' + rrl.New_or_Renewal__c  + ' - ' + rrl.Selling_Company__c;
                    revFields.put(rev,rrl.Id);
                    System.debug('revFields.put(rev,rrl.Id)+++' + revFields.put(rev,rrl.Id));
                    System.debug('revFields+++' + revFields);
                }
        }

        if(!revFields.isEmpty()){
                System.debug('revFields are not empty');
                for(ffbc__ContractLineItem__c con1 : con){
                         System.debug('con1 Loop');
                         String conVal = (con1.ffbc__BillingType__c == 'One-off'?'One-Off':con1.ffbc__ProductService__r.Product_Grouping__c) + ' - ' + con1.Service_Months_in_Contract__c + ' - ' + con1.ffbc__Contract__r.Contract_Type__c + ' - ' + companyNameRev.get(con1.ffbc__Contract__r.ffbc__Company__c);
                         System.debug('conVal+++' + conVal);
                         System.debug('revFields.get(conVal)+++' + revFields.get(conVal));
                         con1.Revenue_Recognition_Logic__c = revFields.get(conVal);
                         contractLine.add(con1);
                }
        }        
        if(!contractLine.isempty()){
			update contractLine;
        }
    }
    
    
    public void appendFieldsUpdate(Map<Id, ffbc__ContractLineItem__c> contractNewMap, Map<Id, ffbc__ContractLineItem__c> contractOldMap){
        if(AvoidRecursion.CLIH_isFirstRun()){
            System.debug('contractUpdate+++' + contractNewMap);
            System.debug('contractOldMap+++' + contractOldMap);
    
            Set<String> productVal = new Set<String>();
            Set<Decimal> conMon = new Set<Decimal>();
            Set<String> conType = new Set<String>();
            Set<String> billType = new Set<String>();
            Set<String> conComp = new Set<String>();
            List<ffbc__ContractLineItem__c> trueCase = new List<ffbc__ContractLineItem__c>();
            Set<Id> updateIds = new Set<Id>();
            Map<String,Id> revFields = new Map<String,Id>(); 
            //Map<Id,String> companyNameRev = new Map<Id,String>();
            List<ffbc__ContractLineItem__c> contractLine =  new List<ffbc__ContractLineItem__c>();
            List<ffbc__ContractLineItem__c> updatedCli = new List<ffbc__ContractLineItem__c>();
            
            for(Id c : contractNewMap.keyset()){
                if(contractNewMap.get(c).Migrated_from_Sage__c == false){
                    updateIds.add(c);
                    System.debug('updateIds+++' + updateIds);
                } else{
                    if(contractNewMap.get(c).Migrated_from_Sage__c != contractOldMap.get(c).Migrated_from_Sage__c){
                        if(contractNewMap.get(c).Migrated_from_Sage__c == true){
                            trueCase.add(contractNewMap.get(c));
                        }
                    }
                }
           }
           for(ffbc__ContractLineItem__c con : [SELECT Revenue_Recognition_Logic__c FROM ffbc__ContractLineItem__c WHERE Id=:trueCase]){
           		 con.Revenue_Recognition_Logic__c = null;    
               	 contractLine.add(con);
           }

           if(!updateIds.isEmpty()){
     
               for(ffbc__ContractLineItem__c conId : [SELECT ffbc__ProductService__r.Product_Grouping__c, Service_Months_in_Contract__c, ffbc__Contract__r.Contract_Type__c, ffbc__Contract__r.ffbc__Company__r.Name,ffbc__Contract__r.ffbc__Company__c,ffbc__BillingType__c FROM ffbc__ContractLineItem__c WHERE Id=:updateIds]){
                    System.debug('conId+++' + conId);
                    if( contractOldMap.get(conId.id).ffbc__ProductService__r.Product_Grouping__c != conId.ffbc__ProductService__r.Product_Grouping__c || 
                        contractOldMap.get(conId.id).Service_Months_in_Contract__c 				 != conId.Service_Months_in_Contract__c ||
                        contractOldMap.get(conId.id).ffbc__Contract__r.Contract_Type__c          != conId.ffbc__Contract__r.Contract_Type__c || 
                        contractOldMap.get(conId.id).ffbc__Contract__r.ffbc__Company__c     	 != conId.ffbc__Contract__r.ffbc__Company__c){
                           System.debug('Inside Conditions' + conId.ffbc__BillingType__c);
                           updatedCli.add(conId);
                           System.debug('Turnary Value'+conId.ffbc__BillingType__c == 'One-off'?'One-Off':conId.ffbc__ProductService__r.Product_Grouping__c);
                           productVal.add(conId.ffbc__BillingType__c == 'One-off'?'One-Off':conId.ffbc__ProductService__r.Product_Grouping__c);
                           conMon.add(conId.Service_Months_in_Contract__c);
                           conType.add(conId.ffbc__Contract__r.Contract_Type__c);
                           conComp.add(conId.ffbc__Contract__r.ffbc__Company__c);
                           billType.add(conId.ffbc__BillingType__c);
                       }
                    System.debug('4 Values+++' + productVal +' '+ conMon +' '+ conType +' '+conComp+' '+billType);
                }
                Set<String> cN = new Set<String>();
                for(fferpcore__Company__c compN: [SELECT Id,Name from fferpcore__Company__c WHERE Id IN:conComp]){
                  //companyNameRev.put(compN.Id, compN.Name);
                  cN.add(compN.Name);
                }
                //System.debug('companyNameRev+++' + companyNameRev);
                System.debug('companyNameRev+++' + cN);

                List<String> companyNames = new List<String>();
                Boolean companyFlag = false;
               
                Map<Id,String> newCom = new Map<Id,String>();
                Set<String> rN = new Set<String>();
                for(Revenue_Recognition_Logic__c r : [SELECT Selling_Company__c FROM Revenue_Recognition_Logic__c WHERE Selling_Company__c IN:cN]){
                    //newCom.put(r.Id, r.Selling_Company__c);
                    System.debug('company Total values:::'+r.Selling_Company__c);
                    //System.debug('newCom one Value:::'+newCom.values());
                    if(cN.contains(r.Selling_Company__c)){
                    //if(companyNameRev.values() == newCom.values()){
                        System.debug('Companies are equal');
                        companyFlag = true;
                    }
                }

                if(!productVal.isEmpty() && !conMon.isEmpty() && !conType.isEmpty() && !conComp.isEmpty() && companyFlag){
                    System.debug('Updated values are not empty');
                    System.debug('Updated values are not equal to old values');
                        for(Revenue_Recognition_Logic__c rrl : [SELECT Product_Grouping__c, New_or_Renewal__c, Term_months__c, Selling_Company__c, Id FROM Revenue_Recognition_Logic__c WHERE Product_Grouping__c IN:productVal AND New_or_Renewal__c IN:conType AND Term_months__c IN:conMon AND Selling_Company__c IN:cN]){            
                            System.debug('rrl+++' + rrl);
                            String rev = rrl.Product_Grouping__c + ' - ' + rrl.Term_months__c + ' - ' + rrl.New_or_Renewal__c  + ' - ' + rrl.Selling_Company__c;
                            revFields.put(rev,rrl.Id);
                            System.debug('revFields.put(rev,rrl.Id)+++' + revFields.put(rev,rrl.Id));
                            System.debug('revFields+++' + revFields);
                        }
                }
                else{
                   for(ffbc__ContractLineItem__c con1 : updatedCli ){
                        String conVal = con1.ffbc__ProductService__r.Product_Grouping__c + ' - ' + con1.Service_Months_in_Contract__c + ' - ' + con1.ffbc__Contract__r.Contract_Type__c + ' - ' + con1.ffbc__Contract__r.ffbc__Company__r.Name;
                        System.debug('updaterevFields.get(conVal)+++' + revFields.get(conVal));
                        if(revFields.get(conVal) == null){
                            con1.Revenue_Recognition_Logic__c = null;
                            contractLine.add(con1);
                       }
                   }
              }
                
                if(!revFields.isEmpty()){
                    System.debug('Updated revFields are not empty');
                    for(ffbc__ContractLineItem__c con1 : updatedCli ){
                        System.debug('update con1 Loop');
                        String conVal = (con1.ffbc__BillingType__c == 'One-off'?'One-Off':con1.ffbc__ProductService__r.Product_Grouping__c) + ' - ' + con1.Service_Months_in_Contract__c + ' - ' + con1.ffbc__Contract__r.Contract_Type__c + ' - ' + con1.ffbc__Contract__r.ffbc__Company__r.Name;
                        System.debug('updateconVal+++' + conVal);
                        System.debug('updaterevFields.get(conVal)+++' + revFields.get(conVal));
                        con1.Revenue_Recognition_Logic__c = revFields.get(conVal);
                        contractLine.add(con1);
                    }
                }
         }
            
             if(!contractLine.isEmpty()){
                update contractLine;
             }   

        }
    }
    
    public void combinedPackage(List<ffbc__ContractLineItem__c> contractLineItems){
        Set<Id> contractIdSet = new Set<Id>();
        Date startDate, endDate;
        List<Id> contractLineItemIdList = new List<Id>();
        list<ffbc__ContractLineItem__c> updateContractLineItemsList = new List<ffbc__ContractLineItem__c>();
        for(ffbc__ContractLineItem__c cli : contractLineItems){
            contractIdSet.add(cli.ffbc__Contract__c);
        }
        for(ffbc__Contract__c con : [SELECT id, (SELECT id, ffbc__ProductService__r.Core_Product__c, ffbc__StartDate__c, ffbc__EndDate__c, Combined_Product_Package__c
                                                 FROM  ffbc__ContractLineItems__r 
                                                 WHERE ffbc__ProductService__r.Core_Product__c =True
                                                 AND ffbc__StartDate__c!=NULL
                                                 AND ffbc__EndDate__c!=NULL) 
                                     FROM ffbc__Contract__c WHERE Id =: contractIdSet]){
            startDate = Null; endDate = Null;
            for(ffbc__ContractLineItem__c conLineItem : con.ffbc__ContractLineItems__r){
                if(startDate != Null && endDate != Null){
                    if(startDate == conLineItem.ffbc__StartDate__c && endDate == conLineItem.ffbc__EndDate__c){
                        conLineItem.Combined_Product_Package__c = True;
                        updateContractLineItemsList.add(conLineItem);
                    }
                }
                if(startDate==null && endDate==null){
                    startDate = conLineItem.ffbc__StartDate__c;
                    endDate = conLineItem.ffbc__EndDate__c;
                    conLineItem.Combined_Product_Package__c = True;
                    updateContractLineItemsList.add(conLineItem);
                }
            }
        }
        if(updateContractLineItemsList.size()>1){
           Database.update(updateContractLineItemsList,false);
        }
       // flag = True;
    }
    
   public void combinedPackageUpdate(List<ffbc__ContractLineItem__c> contractLineItems){
        //boolean flag = false;
        //boolean oldflag = false;
        Set<Id> contractIdSet = new Set<Id>();
        Date startDate, endDate;
        Boolean checkDates;
        List<Id> contractLineItemIdList = new List<Id>();
        List<ffbc__ContractLineItem__c> updateList = new List<ffbc__ContractLineItem__c>();
        list<ffbc__ContractLineItem__c> updateContractLineItemsList = new List<ffbc__ContractLineItem__c>();
       
        for(ffbc__ContractLineItem__c cli : contractLineItems){
            contractIdSet.add(cli.ffbc__Contract__c);
        }
        for(ffbc__Contract__c con : [SELECT id, (SELECT id, ffbc__ProductService__r.Core_Product__c, ffbc__StartDate__c, ffbc__EndDate__c, Combined_Product_Package__c
                                                 FROM  ffbc__ContractLineItems__r 
                                                 WHERE ffbc__ProductService__r.Core_Product__c =True
                                                 AND ffbc__StartDate__c!=NULL
                                                 AND ffbc__EndDate__c!=NULL) 
                                     FROM ffbc__Contract__c WHERE Id =: contractIdSet]){
            startDate = Null; endDate = Null;
            for(ffbc__ContractLineItem__c conLineItem : con.ffbc__ContractLineItems__r){
                checkDates = false;
                if(startDate != Null && endDate != Null){
                    if(startDate == conLineItem.ffbc__StartDate__c && endDate == conLineItem.ffbc__EndDate__c){
                        checkDates = True;
                    }
					if(startDate != conLineItem.ffbc__StartDate__c || endDate != conLineItem.ffbc__EndDate__c){
						if(conLineItem.Combined_Product_Package__c) {
							updateList.add(conLineItem);
						}
                    }
                }
                if(startDate==null && endDate==null){
                    startDate = conLineItem.ffbc__StartDate__c;
                    endDate = conLineItem.ffbc__EndDate__c;
                    contractLineItemIdList.add(conLineItem.Id);
					updateList.add(conLineItem);
                }
                if(checkDates){
                    contractLineItemIdList.add(conLineItem.Id);
                }
            }
        }
        if(contractLineItemIdList.size()> 1){
            for(Id objId : contractLineItemIdList){
                ffbc__ContractLineItem__c objContLine = new ffbc__ContractLineItem__c();
				objContLine.Id =  objId;
                objContLine.Combined_Product_Package__c = true;
                updateContractLineItemsList.add(objContLine);
            }
        }
        if(!updateContractLineItemsList.isEmpty()){
            if(flag == false){
                flag = True;
                Database.update(updateContractLineItemsList,false);
            }
           
           
        }
       if(updateList.size()>1){
           for(ffbc__ContractLineItem__c updateCli : updateList)
               updateCli.Combined_Product_Package__c = False;
           if(flag == false){
               flag = True;
               Database.update(updateList,false);
           }
           
           
       }
       
                                         
    } 	
	
 }