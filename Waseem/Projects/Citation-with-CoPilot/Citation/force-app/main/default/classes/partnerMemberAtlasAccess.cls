public class partnerMemberAtlasAccess {
    @AuraEnabled
    public static List<Partner_Member_Relationship__c> fetch(String partnerId){
        System.debug('fetch partnerId--'+partnerId);
        List<Partner_Member_Relationship__c> prmList = new List<Partner_Member_Relationship__c>([SELECT Id,Name,Member_Lead__c,Member_Lead__r.Name, Member__c,Member__r.Name, Partner__c,Partner__r.Name, HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c 
                FROM Partner_Member_Relationship__c 
                WHERE Partner__c=:partnerId 
                AND Partner__r.Is_Active_Partner__c = TRUE 
                AND Member_left_Partner_date__c = NULL
                AND (Member__c=NULL OR Member__r.CoreCitationContractMonths__c = 0)
                AND Member__c Not IN (Select AccountId from Opportunity Where StageName!='Closed Won' AND StageName!='Closed Lost' AND StageName!='Lost BDC' AND StageName!='Closed won (Consolidated)')
				AND (HR_Access_Unit_Assigned__c=NULL OR H_S_Access_Unit_Assigned__c=NULL)
                LIMIT 10000]);
        return prmList ;
    }
    
    @AuraEnabled
    public static List<Account> getAccount(String accId) {
        return [SELECT Id, Name, Assigned_H_S_Member_Atlas_Access_Units__c,Assigned_HR_Member_Atlas_Access_Units__c,
                Total_H_S_Member_Atlas_Access_Units__c  ,Total_HR_Member_Atlas_Access_Units__c,Available_H_S_Member_Atlas_Access_Units__c,Available_HR_Member_Atlas_Access_Units__c,Assign_Access_Units_In_Progress__c,UnAssign_Access_Units_In_Progress__c
                FROM Account Where Id=:accId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<Partner_Member_Relationship__c> fetchUnassign(String partnerId){
        return [SELECT Id,Name,Member_Lead__c,Member_Lead__r.Name, Member__c,Member__r.Name, Partner__c,Partner__r.Name, HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c,Member_left_Partner_date__c 
                FROM Partner_Member_Relationship__c 
                WHERE Partner__c=:partnerId 
                AND Partner__r.Is_Active_Partner__c = TRUE 
                AND Member_left_Partner_date__c = NULL
                AND (HR_Access_Unit_Assigned__c!=NULL OR H_S_Access_Unit_Assigned__c!=NULL)
                LIMIT 10000];
    }
    
    @AuraEnabled
    public static void unassignUnits(List<Partner_Member_Relationship__c> selectedPmrList,List<Partner_Member_Relationship__c> updatedPmrList, String partnerAccId) {
        system.debug('pmrList-----'+selectedPmrList.size());
        Map<Id, Partner_Member_Relationship__c> updatedPmrListMap = new Map<Id, Partner_Member_Relationship__c>(updatedPmrList);
        Account accId = new Account(Id=partnerAccId);
        accId.UnAssign_Access_Units_In_Progress__c = true;
        ByPassUtils.ByPass('AccountTrigger');
        Database.update(accId,false);
        Database.executeBatch(new unAssignAtlasAccessUnitsBatch(selectedPmrList,partnerAccId,updatedPmrListMap),Integer.valueOf(System.label.UnAssignAtlasAccessUnitsBatchSize));
    }
    
    @AuraEnabled
    public static void assignUnits(List<Partner_Member_Relationship__c> pmrList, String partnerAccId, Integer availableHR,Integer availableHS) {
        system.debug('pmrList-----'+pmrList.size());
        Account accId = new Account(Id=partnerAccId);
        accId.Assign_Access_Units_In_Progress__c = true;
        ByPassUtils.ByPass('AccountTrigger');
        Database.update(accId,false);
        Database.executeBatch(new AssignAtlasAccessUnitsBatch(pmrList,availableHR,availableHS,partnerAccId),Integer.valueOf(System.label.AssignAtlasAccessUnitsBatchSize));
        //createMember(pmrList,partnerAccId);
    }
    
    public static void createMember(List<Partner_Member_Relationship__c> partnerMemberList){
        List<Account> accList=new List<Account>();
        List<Contact> conList=new List<Contact>();
        List<Lead> leadUpdateList = new List<Lead>();
        Set<Id> memberAccIdSet=new Set<Id>();
        Set<Id> leadparentIdSet=new Set<Id>();
        Set<Id> partnerAccIdSet=new Set<Id>();
        Set<Id> leadUpdateIdSet=new Set<Id>();
        Map<Id, Id> accMap=new Map<Id,Id>();
        List<Partner_Member_Relationship__c> partnerMemberfilteredList = new List<Partner_Member_Relationship__c>();
        Account objAcc;
        Contact objCon;
        
        for(Partner_Member_Relationship__c part:partnerMemberList){
            if(part.Partner__c!=null){
                partnerAccIdSet.add(part.Partner__c);
            }
            if(part.Member_Lead__c !=null && !part.Member_Lead__r.How_To_Hub_Member__c){
                leadUpdateIdSet.add(part.Member_Lead__c);
            }
            if(part.Member_Lead__c !=null && part.Member__c==null){
                leadparentIdSet.add(part.Member_Lead__c);
                partnerMemberfilteredList.add(part);
            }/*else if(part.Member__c!=null){
                memberAccIdSet.add(part.Member__c);
            }*/
        }
        if(!partnerMemberfilteredList.isEmpty() && !leadparentIdSet.isEmpty()){
            for(Lead led:Database.query(AllFields('Lead',leadparentIdSet))){ 
				objAcc = new Account();
                objAcc.AffinityPartnerlookup__c = led.Affinity_Partner__c;
                objAcc.CitationSector__c = led.CitationSector__c;
                objAcc.Company_Registration_Number__c = led.Co_Reg__c;
                objAcc.Company_VAT_Number__c = led.Co_VAT__c;
                objAcc.Current_Third_Party_Product__c = led.Current_Third_Party_Product__c;
                objAcc.Directors__c = led.Directors__c;
                objAcc.FT_Employees__c = led.FT_Employees__c;
                objAcc.TotalNoInternationalOffices__c = led.Int_Offices__c;
                objAcc.PartnerType__c = led.PartnerType__c;
                objAcc.Payroll_Amt__c = led.Payroll_Amt__c;
                objAcc.PT_Employees__c = led.PT_Employees__c;
                objAcc.QMS_Sector__c = led.QMS_Sector__c;
                objAcc.Renewal_Date__c = led.Renewal_Date__c;
                objAcc.Convert_Lead_Id__c = led.Id;
                objAcc.Seminar_Attended__c = led.Seminar_Attended_Datestamp__c;
                objAcc.SIC2007_Description__c = led.SIC2007_Description__c;
                objAcc.SIC2007_Description2__c = led.SIC2007_Description2__c;
                objAcc.SIC2007_Description3__c = led.SIC2007_Description3__c;
                objAcc.SIC2007_Code__c = led.SIC2007_Code__c;
                objAcc.SIC2007_Code2__c = led.SIC2007_Code2__c;
                objAcc.SIC2007_Code3__c = led.SIC2007_Code3__c;
                objAcc.Original_Source__c = led.LeadSource;
                objAcc.Staff__c = led.Staff__c;
                objAcc.Subcontractors__c = led.Subcontractors__c;
                objAcc.TotalNoUKoffices__c = led.UK_Offices__c;
                objAcc.BillingStreet = led.Street;
                objAcc.BillingCity = led.City;
                objAcc.BillingState = led.State;
                objAcc.BillingCountry = led.Country;
                objAcc.BillingPostalCode = led.PostalCode;
                objAcc.Name = led.Company;
                objAcc.AnnualRevenue = led.AnnualRevenue;
                objAcc.Industry =led.Industry;
                objAcc.Website = led.Website;
                objAcc.Rating = led.Rating;
                objAcc.Phone = led.Phone;
                objAcc.NumberOfEmployees = led.NumberOfEmployees;
                objAcc.BillingLatitude = led.Latitude;
                objAcc.BillingLongitude = led.Longitude;
                objAcc.AccountSource = led.LeadSource;
                //objAcc.OwnerId = led.OwnerId;
                objAcc.Sites__c =1;
                
                objCon = new Contact();
                objCon.Other_Phone__c = led.Other_Phone__c;
                objCon.Position__c = led.Position__c;
                objCon.MailingStreet = led.Street;
                objCon.MailingCity = led.City;
                objCon.MailingState = led.State;
                objCon.MailingCountry = led.Country;
                objCon.MailingPostalCode = led.PostalCode;
                objCon.Description = led.Description;
                objCon.Email = led.Email;
                objCon.FirstName = led.FirstName;
                objCon.LastName = led.LastName;
                objCon.Title = led.Title;
                objCon.Phone = led.Phone;
                objCon.MobilePhone = led.MobilePhone;
                objCon.LeadSource = led.LeadSource;
                //objCon.OwnerId = led.OwnerId;
                objCon.Salutation = led.Salutation;
                objCon.Convert_Lead_Id__c = led.Id;
                
                accList.add(objAcc);
                conList.add(objCon);
            }
            
            if(!accList.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                Database.SaveResult[] srList = Database.insert(accList,dml);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.'+err.getStatusCode() + ': ' + err.getMessage()+': '+err.getFields());
                        }
                    }
                }
            }
            for(Account acc: accList){
                accMap.put(acc.Convert_Lead_Id__c, acc.Id);
            }
            for(Contact con: conList){
                if(accMap.containsKey(con.Convert_Lead_Id__c)){
                    con.AccountId = accMap.get(con.Convert_Lead_Id__c);
                }
            }
            if(!conList.isEmpty()){
                Database.insert(conList,false);
            }
        }
        system.debug('accMap---'+accMap);
        for(Partner_Member_Relationship__c part : partnerMemberList){
            if(accMap.containsKey(part.Member_Lead__c)){ 
                part.Member__c=accMap.get(part.Member_Lead__c);
            }
            if(part.Member__c!=null){
                memberAccIdSet.add(part.Member__c);
            }
        }
        system.debug('partnerMemberList--'+partnerMemberList);
        if(!partnerMemberList.isEmpty()){
            Database.update(partnerMemberList, false);
        }
        if(!memberAccIdSet.isEmpty()){
            createAccountSites(memberAccIdSet);
        	createContract(partnerAccIdSet,memberAccIdSet,partnerMemberList);    
        }
        if(!leadUpdateIdSet.isEmpty()){
            for(Id objId:leadUpdateIdSet){
                leadUpdateList.add(new Lead(Id=objId,How_To_Hub_Member__c=true));
            }
            system.debug('leadUpdateList--'+leadUpdateList);
            if(!leadUpdateList.isEmpty()){
                Database.update(leadUpdateList,false);
            }
        }
    }
    
    private static void createContract(Set<Id> partnerAccIdSet, Set<Id> memberAccIdSet, List<Partner_Member_Relationship__c> partnerMemberList){        
        system.debug('Inside createContract Method');
        List<Contract> contList=new List<Contract>();
        List<Contract> contUpdateList=new List<Contract>();
        Map<Id,Partner_Member_Relationship__c> partnerMap=new Map<Id,Partner_Member_Relationship__c>();
        Map <Id,Contract> memberAccMap=new Map<Id,Contract>();
        Map <Id,Id> memberContMap=new Map<Id,Id>();
        Map <Id,String> accNameMap=new Map<Id,String>();
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();   
        
        for(Contact con:[SELECT Id,AccountId FROM Contact WHERE AccountId =:memberAccIdSet
                         ORDER BY CreatedDate Desc]){
                             if(!memberContMap.containsKey(con.AccountId)){  
                                 memberContMap.put(con.AccountId, con.Id);
                             }
                         }
        
        for(Contract cont:[SELECT Id,AccountId,Account.name,Recordtype.Name,Payment_Period__c,Preferred_Payment_Date__c,Status,StartDate,ContractTerm,HR_Member_Atlas_Access_Units__c,H_S_Member_Atlas_Access_Units__c,PartnerAccountId__c
                           FROM Contract 
                           WHERE (AccountId =:memberAccIdSet OR AccountId =: partnerAccIdSet) 
                           AND (Recordtype.Name = 'Standard Contract' OR Recordtype.Name = 'Citation Partnership')
                           AND (Status = 'Active' OR Status = 'Pending Start')
                           ORDER BY CreatedDate DESC]){                                                                  
                               if(!memberAccMap.containsKey(cont.AccountId)){
                                   if((cont.Recordtype.Name== 'Citation Partnership' && partnerAccIdSet.contains(cont.AccountId)) || (!partnerAccIdSet.contains(cont.AccountId) && cont.PartnerAccountId__c!=null && cont.Recordtype.Name== 'Standard Contract' && cont.AccountId != cont.PartnerAccountId__c)){
                                       System.debug('Record type name :' +cont.Recordtype.Name + ':' + cont.AccountId + ':'+ cont.PartnerAccountId__c);
                                       memberAccMap.put(cont.AccountId,cont); 
                                   }                                                         
                               }
                           }
        system.debug('memberAccMap---'+memberAccMap);
        for(Account acc: [Select Id, Name From Account WHERE Id =: memberAccIdSet]){          
            accNameMap.put(acc.Id,acc.Name);
        }
        for(Partner_Member_Relationship__c part:partnerMemberList){
            partnerMap.put(part.Id,part);
            if(part.Member__c !=null && !memberAccMap.containsKey(part.Member__c) && memberAccMap.containsKey(part.Partner__c)){
                contList.add(contractInstance(part.Partner__c, part, contractRecordTypeId, memberAccMap, accNameMap, memberContMap,false,false));
            }else if(memberAccMap.containsKey(part.Member__c)){
                system.debug('Inside else if');
                if(memberAccMap.get(part.Member__c).HR_Member_Atlas_Access_Units__c==null || memberAccMap.get(part.Member__c).HR_Member_Atlas_Access_Units__c==0){
                    contList.add(contractInstance(part.Partner__c, part, contractRecordTypeId, memberAccMap, accNameMap, memberContMap,true,false));
                }else if(memberAccMap.get(part.Member__c).H_S_Member_Atlas_Access_Units__c==null || memberAccMap.get(part.Member__c).H_S_Member_Atlas_Access_Units__c==0){
                    contList.add(contractInstance(part.Partner__c, part, contractRecordTypeId, memberAccMap, accNameMap, memberContMap,false,true));
                }
            }
        }
        system.debug('contList---'+contList);
        if(!contList.isEmpty()){
            Database.insert(contList,false);            
            for(Contract contra:contList){  
                if(partnerMap.containskey(contra.Partner_Member_Id__c)){                  
                    if(contra.StartDate <= System.today()){
                        contra.Status='Active';
                    }else if(contra.StartDate > System.today()){
                        contra.Status='Pending Start';
                    }
                    contUpdateList.add(contra); 
                }
            }
            if(!contUpdateList.isEmpty()){
                //ByPassUtils.ByPass('ContractAfterUpdate');
                Database.update(contUpdateList,false);       
            }
            if(!contList.isEmpty()){
                createSubcription(contList,partnerMap);
            }
        }
    }
    
    private static Contract contractInstance(String partnerAccId,Partner_Member_Relationship__c part,Id contractRecordTypeId,Map <Id,Contract> memberAccMap,Map <Id,String> accNameMap,Map <Id,Id> memberContMap,Boolean hrCheck,Boolean hsCheck){
        system.debug('Inside contractInstance Method');
        Contract cont = new Contract();
        cont.Name= accNameMap.get(part.Member__c) +' & New Business'; 
        cont.AccountId=part.Member__c;
        cont.CurrencyIsoCode='GBP';
        if(memberAccMap.get(partnerAccId).StartDate >= System.today()){
            cont.StartDate = memberAccMap.get(partnerAccId).StartDate;
            cont.ContractTerm = memberAccMap.get(partnerAccId).ContractTerm;                
        }else if(memberAccMap.get(partnerAccId).StartDate < System.today()){
            Integer partnerDay = memberAccMap.get(partnerAccId).StartDate.day();
            Integer todayDay = System.today().day();
            Integer months=System.today().monthsBetween(memberAccMap.get(partnerAccId).StartDate);
            if(partnerDay>todayDay){
                cont.StartDate= memberAccMap.get(partnerAccId).StartDate.addMonths(-months-1);
                cont.ContractTerm =memberAccMap.get(partnerAccId).ContractTerm+months+1; 
            }else if(partnerDay<=todayDay){
                cont.StartDate= memberAccMap.get(partnerAccId).StartDate.addMonths(-months);
                cont.ContractTerm =memberAccMap.get(partnerAccId).ContractTerm+months;
            }
        }     
        cont.FOC_Period_Mths__c=0;
        cont.FOC_Period_Mths_End__c =0;  
        cont.Partner_Member_Id__c=part.Id;
        cont.Partner_Member_Record__c=part.Id;
        cont.Status='Draft';
        cont.Renewal_Type__c='Non-Auto';
        cont.Agreement_Type__c='Auto';
        cont.Business_Type__c='New Business';
        cont.Payment_Period__c=memberAccMap.get(partnerAccId).Payment_Period__c;
        cont.Preferred_Payment_Date__c=memberAccMap.get(partnerAccId).Preferred_Payment_Date__c;
        cont.Contract_Value__c=0; 
        cont.Total_Contract_Value__c=0;
        cont.RecordTypeId=contractRecordTypeId;
        cont.HR_Changed__c = hrCheck;
        cont.H_S_Changed__c = hsCheck;
        if(memberContMap.containsKey(part.Member__c)){
            cont.CustomerSignedId=memberContMap.get(part.Member__c);
        }
        return cont;
    }
    
    private static void createSubcription(List<Contract> contList , Map<Id,Partner_Member_Relationship__c> partnerMap){
        system.debug('Inside createSubcription Method');
        List<String> Prdcodes = System.Label.Partner_Access_Products.Split(',');
        Map<String, Id> productMap=new Map<String, Id>();
        List<SBQQ__Subscription__c> subsList= new List<SBQQ__Subscription__c>();
        
        for(Product2 productList :[Select Id, Name FROM Product2 where ProductCode IN : Prdcodes]){
            productMap.put(productList.Name, productList.Id);            
        }
        for(Contract cont:contList){
            if(cont.Partner_Member_Id__c !=null && partnerMap.containskey(cont.Partner_Member_Id__c)){
                if(cont.HR_Changed__c || cont.H_S_Changed__c){
                    if(cont.HR_Changed__c){
                        subsList.add(subsSyncInstance(cont,productMap.get(partnerMap.get(cont.Partner_Member_Id__c).HR_Access_Unit_Assigned__c)));
                    }else{
                        subsList.add(subsSyncInstance(cont,productMap.get(partnerMap.get(cont.Partner_Member_Id__c).H_S_Access_Unit_Assigned__c)));
                    }
                }else{
                    if(partnerMap.get(cont.Partner_Member_Id__c).HR_Access_Unit_Assigned__c!=null){
                        subsList.add(subsSyncInstance(cont,productMap.get(partnerMap.get(cont.Partner_Member_Id__c).HR_Access_Unit_Assigned__c)));
                    }  
                    if(partnerMap.get(cont.Partner_Member_Id__c).H_S_Access_Unit_Assigned__c!=null){       
                        subsList.add(subsSyncInstance(cont,productMap.get(partnerMap.get(cont.Partner_Member_Id__c).H_S_Access_Unit_Assigned__c)));
                    }
                }
            }
        }
        if(!subsList.isEmpty()){
            Database.insert(subsList,false);
        }        
    }
    
    private static SBQQ__Subscription__c subsSyncInstance(Contract cont,String productId){ 
        system.debug('Inside subsSyncInstance Method');
        SBQQ__Subscription__c subs =new SBQQ__Subscription__c();
        subs.SBQQ__Contract__c=cont.id;
        subs.SBQQ__Account__c=cont.AccountId;
        subs.SBQQ__BillingFrequency__c='Monthly';
        subs.SBQQ__CustomerPrice__c=0;
        subs.Initial_Payment_m__c=0;
        subs.SBQQ__NetPrice__c=0;
        subs.SBQQ__PricingMethod__c='Custom';                   
        subs.Service_Start_Date_m__c=cont.StartDate;
        subs.Service_End_Date_m__c=cont.EndDate;
        subs.SBQQ__SubscriptionStartDate__c=cont.StartDate;
        subs.SBQQ__SubscriptionEndDate__c=cont.EndDate;
        subs.Subscription_Term_m__c=cont.ContractTerm;
        subs.FOC_Months_m__c=0;
        subs.SBQQ__Quantity__c=1;
        subs.Regular_Payment_m__c=0;
        subs.SBQQ__RegularPrice__c=0;    
        subs.SBQQ__Product__c=productId;        
        return subs;
    }
    
    private static String AllFields(String ObjectName,Set<Id> leadparentIdSet) {
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
        String query = 'SELECT '+String.join(fields, ',')+' FROM '+ObjectName+ ' WHERE ' +' Id = :leadparentIdSet '; 
        return query; 
    }
	
	private static void createAccountSites(Set<Id> memberAccIdSet){
        system.debug('Inside createAccountSites Method');
        Set<Id> accIdWithSiteSet = new Set<Id>();
        List<Site__c> siteList = new List<Site__c>();
        Site__c siteObj;
        for(Site__c objSite : [SELECT Id,Account__c FROM Site__c Where Account__c=: memberAccIdSet]){
            if(!accIdWithSiteSet.contains(objSite.Account__c)){
                accIdWithSiteSet.add(objSite.Account__c);    
            }
        }
        System.debug('accIdWithSiteSet---'+accIdWithSiteSet);
        for(Account objAcc: [Select Id,Name,BillingPostalCode,BillingStreet,BillingCity from Account Where Id=:memberAccIdSet]){
            if(!accIdWithSiteSet.contains(objAcc.Id)){
                siteObj = new Site__c();
                siteObj.Account__c = objAcc.Id;
                siteObj.Name = objAcc.Name +'_'+objAcc.BillingStreet+'_'+objAcc.BillingPostalCode;
                siteObj.Active__c = true;
                siteObj.Site_Type__c ='Main Site';
                siteObj.Street__c = objAcc.BillingStreet;
                siteObj.City__c = objAcc.BillingCity;
                siteObj.Postcode__c = objAcc.BillingPostalCode;
                siteList.add(siteObj);
            }
        }
        if(!siteList.isEmpty()){
            Database.insert(siteList,false);
        }
    }
}