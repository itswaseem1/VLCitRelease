public class VersionUpdationHandler {

    public void updateCommissionContract(List<Contract> newContractList) {
        Id standardRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
        Id oneOffRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('One Off Sale').getRecordTypeId();
        Id clientRelationRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Contract Record Type').getRecordTypeId();
        Id clientRenewalRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Renewal Contract').getRecordTypeId();
        
        Set<Id> partnerAccSetId = new Set<Id>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, Id> quoteMap = new Map<Id, Id>();
        Map<Id, Contract> partnerContractMap = new Map<Id, Contract>();
        Map<Id, Contract> memberContractMap = new Map<Id, Contract>();
        for(Contract objContract : newContractList) {
            if(objContract.AccountId !=null && objContract.Total_Contract_Value_for_Commission__c > 0 && (objContract.Recordtypeid ==standardRecordTypeId 
                                                                                                          || objContract.Recordtypeid ==oneOffRecordTypeId 
                                                                                                          || objContract.Recordtypeid ==clientRelationRecordTypeId 
                                                                                                          || objContract.Recordtypeid ==clientRenewalRecordTypeId)){
                                                                                                              partnerAccSetId.add(objContract.AccountId);
                                                                                                          }
        }
        
        if(!partnerAccSetId.isEmpty()){  
            Map<Id, Partner_Member_Relationship__c> memberPmrIdMap = new Map<Id, Partner_Member_Relationship__c>();
            Set<Id> partnerIdSet = new Set<Id>();
            for(Partner_Member_Relationship__c objPMR : [SELECT Id, Name, HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c, Member__c, Member_left_Partner_date__c, Partner__c FROM Partner_Member_Relationship__c WHERE Member__c IN :partnerAccSetId AND Member_left_Partner_date__c = null AND Partner__r.Is_Active_Partner__c = True]){
                if(!memberPmrIdMap.containsKey(objPMR.Member__c)){
                    memberPmrIdMap.put(objPMR.Member__c, objPMR);
                }
                partnerIdSet.add(objPMR.Partner__c);                
            }
            
            if(!partnerIdSet.isEmpty()){
                for(Contract cont: [SELECT Id, StartDate, SBQQ__Quote__c, AccountId, Source_Opportunity__c, Source_Opportunity__r.Original_Contract__c, Source_Opportunity__r.Original_Contract__r.SBQQ__Quote__C 
                                   FROM Contract WHERE Id IN (SELECT SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Name = 'Partner Commission') 
                                   AND Status='Active' AND Recordtype.Name ='Citation Partnership' 
                                   AND AccountId=:partnerIdSet ORDER BY StartDate ASC]){
                                       if(!partnerContractMap.containsKey(cont.AccountId)){
                                           partnerContractMap.put(cont.AccountId, cont);
                                           quoteMap.put(cont.AccountId, cont.SBQQ__Quote__c);                                      
                                       }
                                   }
                
                for(SBQQ__QuoteLine__c quoteline: [SELECT Id, SBQQ__Quote__c, Commission_Rate_New_Business__c, Commission_Payment_Cycle__c, Commission_Payment_Frequency__c, Commission_Rate_Renewal__c, Contract_Value_paid_on__c, Additional_Contracts_Included__c
                                                  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c in :quoteMap.values() AND SBQQ__ProductName__c = 'Partner Commission']){
                                                      quoteLineMap.put(quoteline.SBQQ__Quote__c, quoteline);
                                                  }
                
                for(Contract memberCon: [SELECT Id, AccountId, Status, Commission_Eligibility__c, Commission_Partner__c, Commission_Approved__c 
                                        FROM Contract WHERE AccountId =: partnerAccSetId AND Status = 'Active'
                                        AND Commission_Eligibility__c = true AND Commission_Approved__c = true 
                                        AND Commission_Partner__c =: partnerIdSet
                                        AND (Recordtype.Name = 'Standard Contract' OR Recordtype.Name = 'Client Relations Contract Record Type' 
                                             OR Recordtype.Name = 'Client Relations Renewal Contract')]){
                                                 memberContractMap.put(memberCon.AccountId, memberCon);                
                                             }
                
                Decimal commisionRate;
                SBQQ__QuoteLine__c ql;
                for(Contract contObj : newContractList){                  
                    if(memberPmrIdMap.containskey(contObj.AccountId) && partnerContractMap.containsKey(memberPmrIdMap.get(contObj.AccountId).Partner__c) && partnerContractMap.get(memberPmrIdMap.get(contObj.AccountId).Partner__c).StartDate < contObj.Opp_DateMade__c && ((contObj.RecordTypeId == standardRecordTypeId && (memberPmrIdMap.get(contObj.AccountId).HR_Access_Unit_Assigned__c == 'HR How-To Hub' || memberPmrIdMap.get(contObj.AccountId).H_S_Access_Unit_Assigned__c == 'H&S How-To Hub' || contObj.Partner_source__c))|| (((contObj.Recordtypeid ==oneOffRecordTypeId && quoteLineMap.get(quoteMap.get(memberPmrIdMap.get(contObj.AccountId).Partner__c)).Additional_Contracts_Included__c==true) || ((contObj.Recordtypeid ==clientRelationRecordTypeId || contObj.Recordtypeid ==clientRenewalRecordTypeId) && quoteLineMap.get(quoteMap.get(memberPmrIdMap.get(contObj.AccountId).Partner__c)).Commission_Rate_Renewal__c > 0)) && memberContractMap.containsKey(contObj.AccountId))))
                    {   
                        contObj.Commission_Eligibility__c = true;
                        contObj.Commission_Partner__c = memberPmrIdMap.get(contObj.AccountId).Partner__c != null ? memberPmrIdMap.get(contObj.AccountId).Partner__c : null;               
                        if(memberPmrIdMap.get(contObj.AccountId).Partner__c!=null && quoteMap.containsKey(memberPmrIdMap.get(contObj.AccountId).Partner__c) && quoteLineMap.containskey(quoteMap.get(memberPmrIdMap.get(contObj.AccountId).Partner__c))){
                            ql = quoteLineMap.get(quoteMap.get(memberPmrIdMap.get(contObj.AccountId).Partner__c)); 
                            if(ql.Commission_Rate_New_Business__c != null || ql.Commission_Rate_Renewal__c != null){
                                if(contObj.RecordTypeId == standardRecordTypeId || contObj.RecordTypeId == oneOffRecordTypeId){
                                    contObj.Commission_Rate__c = ql.Commission_Rate_New_Business__c ;
                                }
                                else if(contObj.RecordTypeId == clientRelationRecordTypeId || contObj.RecordTypeId == clientRenewalRecordTypeId) {
                                    contObj.Commission_Rate__c = ql.Commission_Rate_Renewal__c;
                                }
                                else{
                                    contObj.Commission_Rate__c = 0;
                                }
                            }
                            // Assign First Payment date
                            if(ql.Commission_Payment_Cycle__c == 'Contract Anniversary' && contObj.Initial_First_Payment_Date_For_Comission__c != null)
                                contObj.First_Payment_Date__c = contObj.Initial_First_Payment_Date_For_Comission__c.AddMonths(12);
                            else if(ql.Commission_Payment_Cycle__c == 'Contract End')
                                contObj.First_Payment_Date__c = contObj.StartDate.AddMonths(contObj.ContractTerm).addDays(-1);                        
                            //Assign Commission payment frequency
                            if(ql.Commission_Payment_Frequency__c != null)
                                contObj.Commission_Payment_Frequency__c = ql.Commission_Payment_Frequency__c;
                            //Assign Total Commission Amount
                            if(contObj.Commission_Rate__c != Null){
                                if(ql.Contract_Value_paid_on__c == 'Core Only' && contObj.Core_Compliance_TCV_for_Commission__c != null)
                                    contObj.Total_Commission_Amount__c = 0.01*contObj.Commission_Rate__c*contObj.Core_Compliance_TCV_for_Commission__c;
                                else if(ql.Contract_Value_paid_on__c == 'Total TCV' && contObj.Total_Contract_Value_for_Commission__c != null)
                                    contObj.Total_Commission_Amount__c = 0.01*contObj.Commission_Rate__c*contObj.Total_Contract_Value_for_Commission__c;
                                else if(ql.Contract_Value_paid_on__c == 'First year ACV' && contObj.Total_Contract_Value_for_Commission__c != null)
                                    contObj.Total_Commission_Amount__c = 0.01*contObj.Commission_Rate__c*(contObj.Total_Contract_Value_for_Commission__c/contObj.ContractTerm*12);
                            }
                            
                            //Assign number commission payments
                            if(contObj.ContractTerm != 1 && ql.Commission_Payment_Frequency__c == 'Annually')
                                contObj.Number_Commission_Payments__c = contObj.ContractTerm/12;     
                            //Assign Commission payment amount
                            if(ql.Commission_Payment_Frequency__c == 'Annually' && contObj.ContractTerm != 1 && contObj.Total_Commission_Amount__c != null)
                                contObj.Commission_Payment_Amounts__c = contObj.Total_Commission_Amount__c/contObj.Number_Commission_Payments__c;
                            if((ql.Commission_Payment_Frequency__c == 'Full Payment' && contObj.ContractTerm != 1) || contObj.ContractTerm == 1){
                                contObj.Number_Commission_Payments__c = 1;
                                contObj.Commission_Payment_Amounts__c = contObj.Total_Commission_Amount__c;
                            }
                        }
                    }
                }
            }
        }
    } 
    
      public void updateAccountToClient(List<Contract> newContractList) {   
        Id partnerRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        Set<Id> accSetId = new Set<Id>();
        List<Account> updateAccList = new List<Account>();
        List<Contract> updateContList = new List<Contract>();
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        
        for(Contract contr : newContractList) {
            if(contr.AccountId !=null && contr.Status == 'Active'){
                accSetId.add(contr.AccountId);
                updateContList.add(contr);
            }
        }
        if(!accSetId.isEmpty()){
            for(Account acct: [SELECT Id, S__c, PB_Last_Care_Call_Date__c, PB_Last_Rel_Visit_Dt__c, Type FROM Account WHERE Id =: accSetId]){
                mapAcc.put(acct.id,acct);
            }            
            for(Contract conVal : updateContList){ 
                if(mapAcc.containsKey(conVal.AccountId) && mapAcc.get(conVal.AccountId).Type != 'Partner' && conVal.RecordtypeId != partnerRecordTypeId){                   
                    Account acc = mapAcc.get(conVal.AccountId);
                    acc.Type = 'Client'; 
                    if(acc.S__c == 'Bronze' ){                                                          
                        acc.PB_Last_Care_Call_Date__c = system.today();                                                        
                    }else if(acc.S__c == 'Silver' || acc.S__c == 'Gold' || acc.S__c == 'Gold+' || acc.S__c == 'Platinum'){                            
                        acc.PB_Last_Care_Call_Date__c = System.today();
                        acc.PB_Last_Rel_Visit_Dt__c = System.today();                                
                    } 
                    updateAccList.add(acc);
                }               
            }
            if(!updateAccList.isEmpty()){
                Database.update(updateAccList, false) ; 
            }            
        }
    }
    
    public void displayPartnerDataOnContract(List<Contract> newContractList) {   
        Id partnerRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();       
        Set<Id> quoteSetId = new Set<Id>();
        List<Contract> updateContList = new List<Contract>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        
        for(Contract contr : newContractList) {
            if(contr.SBQQ__Quote__c != null && contr.Recordtypeid == partnerRecordTypeId){
                quoteSetId.add(contr.SBQQ__Quote__c);
                updateContList.add(contr);
            }
        }
        if(!quoteSetId.isEmpty()){            
            for(SBQQ__QuoteLine__c quoteline: [SELECT Id,SBQQ__Quote__c,Annual_Internal_Budget__c,Commission_Rate_New_Business__c,Commission_Payment_Cycle__c, Commission_Payment_Frequency__c, Commission_Rate_Renewal__c, Contract_Value_paid_on__c,Additional_Contracts_Included__c,Discount_Prefferential_Rate_for_Members__c,Fixed_Fee_Membership__c
                                              FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quoteSetId AND SBQQ__ProductName__c = 'Partner Commission']){
                                                  quoteLineMap.put(quoteline.SBQQ__Quote__c, quoteline);
                                              }
            if(!quoteLineMap.isEmpty()){
                for(Contract conVal : updateContList){ 
                    if(quoteLineMap.containskey(conVal.SBQQ__Quote__c)){
                        conVal.Partner_Additional_Contracts_Included__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Additional_Contracts_Included__c;
                        conVal.Partner_Annual_Internal_Budget__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Annual_Internal_Budget__c; 
                        conVal.Partner_Commission_Payment_Cycle__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Commission_Payment_Cycle__c;  
                        conVal.Partner_Commission_Payment_Frequency__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Commission_Payment_Frequency__c;     
                        conVal.Partner_Commission_Rate_New_Business__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Commission_Rate_New_Business__c;
                        conVal.Partner_Commission_Rate_Renewal__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Commission_Rate_Renewal__c;
                        conVal.Partner_Contract_Value_paid_on__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Contract_Value_paid_on__c; 
                        conVal.Partner_Discount_Preferential_Rate_for__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Discount_Prefferential_Rate_for_Members__c;     
                        conVal.Partner_Fixed_Fee_Membership__c = quoteLineMap.get(conVal.SBQQ__Quote__c).Fixed_Fee_Membership__c;                     
                    }
                }
            }               
        }                       
    }
    
    public static void UpdatingTsandCsVersion(List<Contract> contractList, Map<Id, Contract> contractOldMap) {
        List<Terms_and_Conditions__c> termsandConditions = [SELECT Id, Name, Agreement_Type__c, Contract_Record_Type__c, End_Date__c, Start_Date__c FROM Terms_and_Conditions__c WHERE Contract_Record_Type__c != NULL AND Agreement_Type__c != NULL];
        List<Contract> contractUpdateList = new List<Contract>();
		for (Contract objCon : [SELECT Id, Status, StartDate, CreatedDate, Agreement_Type__c, Source_Opportunity__r.Original_Contract__r.Ts_Cs_Version__c, Source_Opportunity__r.RecordType.Name, Recordtype.Name, Legacy_Migration_Company__c, (SELECT echosign_dev1__Status__c, CreatedDate FROM R00N70000001hM2JEAU__r WHERE echosign_dev1__Status__c = 'Signed' ORDER BY CreatedDate DESC) FROM Contract WHERE Id = :contractList]) {
			if (objCon.Status != contractOldMap.get(objCon.Id).Status && (objCon.Status == 'Active' || objCon.Status == 'Pending Start')) {
				if (objCon.Source_Opportunity__r.RecordType.Name == 'Renewal / Retention Opportunity - Auto' && (objCon.Recordtype.Name == 'Client Relations Contract Record Type' || (objCon.Recordtype.Name == 'Client Relations Renewal Contract' && objCon.Legacy_Migration_Company__c == 'Southalls' && objCon.R00N70000001hM2JEAU__r.isEmpty()))) {
					if (objCon.Source_Opportunity__r.Original_Contract__r.Ts_Cs_Version__c != null) {
						objCon.Ts_Cs_Version__c = objCon.Source_Opportunity__r.Original_Contract__r.Ts_Cs_Version__c;
					}
					objCon.Current_Ts_and_Cs_Effective_Date__c = objCon.StartDate;
					contractUpdateList.add(objCon);
				} else if (objCon.Recordtype.Name != 'Client Relations Contract Record Type' && !objCon.R00N70000001hM2JEAU__r.isEmpty()) {
					for (Terms_and_Conditions__c tcs : termsandConditions) {
						if (tcs.Contract_Record_Type__c.containsIgnoreCase(objCon.Recordtype.Name) && tcs.Agreement_Type__c.containsIgnoreCase(objCon.Agreement_Type__c)) {
							if (tcs.Start_Date__c <= objCon.R00N70000001hM2JEAU__r[0].CreatedDate.date() && (tcs.End_Date__c == null || tcs.End_Date__c >= objCon.R00N70000001hM2JEAU__r[0].CreatedDate.date())) {
								objCon.Ts_Cs_Version__c = tcs.Id;
								objCon.Current_Ts_and_Cs_Effective_Date__c = objCon.StartDate;
								contractUpdateList.add(objCon);
								break;
							}
						}
					}
				} else if (objCon.Recordtype.Name != 'Client Relations Contract Record Type') {
					for (Terms_and_Conditions__c tcs : termsandConditions) {
						if (tcs.Contract_Record_Type__c.containsIgnoreCase(objCon.Recordtype.Name) && tcs.Agreement_Type__c.containsIgnoreCase(objCon.Agreement_Type__c)) {
							if (tcs.Start_Date__c <= objCon.CreatedDate.date() && (tcs.End_Date__c == null || tcs.End_Date__c >= objCon.CreatedDate.date())) {
								objCon.Ts_Cs_Version__c = tcs.Id;
								objCon.Current_Ts_and_Cs_Effective_Date__c = objCon.StartDate;
								contractUpdateList.add(objCon);
								break;
							}
						}
					}
				}
			}
		}
		if (!contractUpdateList.isEmpty()) {
			Database.update(contractUpdateList, false);
		}
	}
}