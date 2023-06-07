/**********************************
**** creating Oppotunities based on Contract renewal type
***********************************/

global class ContractRenewalOppBatchHandler implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    private String query;
    private String resultString = '';
    private List<String> contractIds;
    private List<String> rtid;
    //private Date priorDate = Date.today().addMonths(9);
    Integer contractExpiryTermAuto=Integer.valueOf(System.Label.Contract_Expiry_Term_Auto);
    Integer ContractExpiryTermNonAuto=Integer.valueOf(System.Label.Contract_Expiry_Term_Non_Auto);
    private Date priorDate =contractExpiryTermAuto>=ContractExpiryTermNonAuto? Date.today().addMonths(contractExpiryTermAuto):Date.today().addMonths(ContractExpiryTermNonAuto);
    private Date currentDate=Date.today();
    string nbsContract = DataConstants.NBS_CONTRACT_RECORDTYPE_NAME;
    ID contNBSRecordTypeID  = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(nbsContract).getRecordTypeId();
    
    /*****
    *** @Param: queryString - query to run the batch class
    ****/
    public ContractRenewalOppBatchHandler(String queryString){
        query = queryString;
    }   
    
    /*****
    *** Query all Contracts with criteria 
    *****/

    public ContractRenewalOppBatchHandler(){
             rtid= Label.Renewal_Type_ID.split(',');
             query = 'Select AccountID, Account.Name, Account.Postcode_District__c, Account.S__c, ContractNumber, id, name,CALC_Renewal_Auto_Close_Date__c, ContractTerm, EndDate, RecordTypeID, StartDate, Status,'
                    +'Services_Taken_EL__c, Services_Taken_HS__c, Services_Taken_AI_Only__c, Services_Taken_AI_Only_HS__c, Services_Taken_Advice_Only__c, Services_Taken_Advice_Only_HS__c,'
                    +'SBQQ__Quote__c,Payment_Period__c,Preferred_Payment_Date__c, Post_Indexation_Value__c, Renewal_Type__c, Renewal_Start_Date__c, Initial_Payment2__c,'
                    +'(select Id, name, SBQQ__QuoteLine__c,SBQQ__Contract__c from SBQQ__Subscriptions__r),'
                    +'(select id,contractid from opportunities__r where recordtypeid IN: rtid)'
                    +'From Contract Where No_Auto_Create_Opportunity__c != true AND Status =\'Active\' AND EndDate>=:currentDate AND EndDate<=: priorDate';

    }
   
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope){
        String tempResult;
        String oppRecTyeRenewRetenAuto = DataConstants.RENEWAL_AUTO_OPPORTUNITY_RECORDTYPE_NAME;
        String oppRecTyeRenewRetenNonAuto = DataConstants.RENEWAL_NON_AUTO_OPPORTUNITY_RECORDTYPE_NAME;
        String renewalAuto = DataConstants.AUTO_RENEWAL_TYPE_CONTRACT;
        String renewalNonAuto = DataConstants.NON_AUTO_RENEWAL_TYPE_CONTRACT;
        string oppStageRenewContactDue = DataConstants.OPPORUNITY_STAGE_RENEWALDUE;
        string oppStageProAgreement = DataConstants.OPPORUNITY_STAGE_PROVISIONAL_AGREEMENT;
        string oppForecastCategoryName = DataConstants.OPPORUNITY_FORCAST_CATEGORY_NAME;
        string OppAccessLevelReadWrite = DataConstants.OPPORTUNITY_ACCESS_LEVEL_READ_WRITE;
        ID oppAutoRecordTypeID  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecTyeRenewRetenAuto).getRecordTypeId();
        ID oppNonAutoRecordTypeID  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oppRecTyeRenewRetenNonAuto).getRecordTypeId();

        Set<Id> accIds = new Set<Id> ();//Set of AccountIDs of Contract
        set<string> cpqProductCodes = new set<string>(); //set of trimed CPQ Core Product Codes added from System.Label.CPQ_Core_Product_Codes
        List<String> listcoreProductCodes  = new List<String>();//list of all Productcodes added from System.Label.CPQ_Core_Product_Codes

        List<Account> accList = new List<Account>();//Accounts List to pass to ClusterManager.getclusterName()
        List<Opportunity> insertOpportunityList = new List<Opportunity>();//list to Insert Renewal Opportunities 
        Map<Id,Cluster__c> mapAccountCluster = new Map<Id,Cluster__c> (); // Returned Map with AccountID as Key and Value is Cluster Object
        Map<Id, Contract> mapContract = new Map<Id, Contract>(); // Map with contractId as Key and Value is Contract Object
        Map<Id, SBQQ__QuoteLine__c> mapQuotelines  = new Map<Id, SBQQ__QuoteLine__c>(); // Map with ContractID and SBQQ__QuoteLine__c Object
        Map<String, String> qlineIdContIdMap  = new Map<String, String>(); // Map to store SBQQ__QuoteLine__c Id as Key and Contract Id from contract related Subscriptions 
         
        // SDT-4206
        Set<Id> accidList=new Set<Id>();
        List<Account> accTerriList =new List<Account>();
        
        try{

            if (!scope.isEmpty()) {
                listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
                if(!listcoreProductCodes.isEmpty()){
                    for (String prouctcode : listcoreProductCodes) {
                        cpqProductCodes.add(prouctcode.trim());
                    }
                }

                for(Contract c : scope){
                    If(c.AccountId != Null){
                        mapContract.put(c.Id, C);
                        accIds.add(c.AccountId);
                    }
                    
                    if(!c.SBQQ__Subscriptions__r.isEmpty()){
                        for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                            if (sub.SBQQ__QuoteLine__c != Null) {
                                qlineIdContIdMap.put(sub.SBQQ__QuoteLine__c, sub.SBQQ__Contract__c);
                            }
                        } 
                    }
                    
                }
                
                for(SBQQ__QuoteLine__c qLine : [Select Id, Name, SBQQ__ProductCode__c  from SBQQ__QuoteLine__c where Id In : qlineIdContIdMap.keySet()]){
                    if(qLine.SBQQ__ProductCode__c != Null && cpqProductCodes.contains(qLine.SBQQ__ProductCode__c)){
                        mapQuotelines.put(qlineIdContIdMap.get(qLine.Id), qLine);
                    }
                }

                accList = [Select Id, Name,Type, Cluster__c, Postcode_District__c, s__c  From Account Where Id IN : accIds ];
				
                if(!accList.isEmpty()){
                    mapAccountCluster =  ClusterManager.getclusterNameByRole(accList, DataConstants.ClUSTER_ROLE_RENEWAL);
                }
                
                for (Contract cont : scope) {
                    
                    if(cont.Renewal_Type__c != Null ){
                        if(mapQuotelines.containsKey(cont.Id) || (cont.Services_Taken_EL__c == True || cont.Services_Taken_HS__c == True || cont.Services_Taken_AI_Only__c == True 
                            || cont.Services_Taken_AI_Only_HS__c == True || cont.Services_Taken_Advice_Only__c == True  || cont.Services_Taken_Advice_Only_HS__c  == True) ){
                            
                            /*:::: New Opportunity to create based on Contract.Renewal_Type__c  ::::*/
                            Opportunity opp = new Opportunity();

                            if (cont.Renewal_Type__c == renewalAuto && cont.EndDate<=Date.today().addMonths(contractExpiryTermAuto) && cont.Opportunities__r.isEmpty()) {
                                
                                if(cont.Renewal_Start_Date__c != Null ){
                                    opp.CloseDate  =  cont.Renewal_Start_Date__c;
                                    opp.Deal_Start_Date__c = cont.Renewal_Start_Date__c;
                                }
                                opp.Name = cont.Account.Name;
                                opp.StageName = oppStageProAgreement;
                                opp.AccountId = cont.AccountId;
                                if(cont.Post_Indexation_Value__c != Null )opp.Amount = cont.Post_Indexation_Value__c;
                                opp.ForecastCategoryName = oppForecastCategoryName;
                                opp.Notify__c = True;
                                opp.Original_Contract__c = cont.Id;
                                if(cont.AccountId != Null && mapAccountCluster.containsKey(cont.AccountId) && mapAccountCluster.get(cont.AccountId).Owner__c != null){
                                    opp.OwnerID = mapAccountCluster.get(cont.AccountId).Owner__c;
                                    accidList.add(cont.AccountId);
                                }else {
                                    opp.OwnerID = system.label.Salesforce_Admin; 
                                }    
                                if(cont.Payment_Period__c != Null )opp.Payment_Period__c = cont.Payment_Period__c;
                                if(cont.Preferred_Payment_Date__c != Null )opp.Preferred_Payment_Date__c = cont.Preferred_Payment_Date__c;
                                opp.RecordtypeId = oppAutoRecordTypeID;
                                insertOpportunityList.add(opp);
                                
                            }
                            else if (cont.Renewal_Type__c == renewalNonAuto && cont.EndDate<=Date.today().addMonths(ContractExpiryTermNonAuto) && cont.Opportunities__r.isEmpty() ) {
                                
                                    if(cont.CALC_Renewal_Auto_Close_Date__c != Null )opp.CloseDate  =  cont.CALC_Renewal_Auto_Close_Date__c;
                                    opp.Name = cont.Account.Name;
                                    opp.StageName = oppStageRenewContactDue;
                                    opp.AccountId = cont.AccountId;
                                    if(cont.Post_Indexation_Value__c != Null )opp.Amount = cont.Post_Indexation_Value__c;
                                    if(cont.Renewal_Start_Date__c != Null )opp.Deal_Start_Date__c = cont.Renewal_Start_Date__c;
                                    opp.ForecastCategoryName = oppForecastCategoryName;
                                    opp.Notify__c = True;
                                    opp.Original_Contract__c = cont.Id;
                                    if(cont.AccountId != Null && mapAccountCluster.containsKey(cont.AccountId) && mapAccountCluster.get(cont.AccountId).Owner__c != null){
                                        opp.OwnerID = mapAccountCluster.get(cont.AccountId).Owner__c;
                                        accidList.add(cont.AccountId);
                                    }else {
                                        opp.OwnerID = system.label.Salesforce_Admin; 
                                    }
                                    if(cont.Payment_Period__c != Null )opp.Payment_Period__c = cont.Payment_Period__c;
                                    if(cont.Preferred_Payment_Date__c != Null )opp.Preferred_Payment_Date__c = cont.Preferred_Payment_Date__c;
                                    opp.RecordtypeId = oppNonAutoRecordTypeID;
                                    insertOpportunityList.add(opp);
                                   
                            }
                        }
                    }
                }
            }
    
            if (!insertOpportunityList.isEmpty()) {
                insert insertOpportunityList;
            }
           
            //SDT-4206 Changes    
            Set<String> acidSet =  new Set<String>(); 
            if(!accidList.isEmpty()){
            for(Id accid1:accidList){
                Account acc=new Account();
                acc.id=accid1;
                acc.Renewal_Territory__c=mapAccountCluster.get(accid1).Name;
                accTerriList.add(acc);                
            }
            }
            
            if(!accTerriList.isEmpty()){
                update accTerriList;
                if(AvoidRecursion.RunTer_isFirstRun()){
                    RunTerritoryRules job = new RunTerritoryRules() ;
                    job.accntIds = acidSet; 
                    IF(!Test.isRunningTest()){
                        System.enqueueJob(job);
                    }
                    
                 }
            }           
                  
        }catch(Exception e){
              
              System.debug('ErrorNessage::=='+e.getMessage());
              System.debug('Error Line Number::=='+e.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC){
    
        System.debug(' Result '+resultString);
    }

    /*****
    *** Scheduler Interface method 
    *****/
    global void execute(SchedulableContext SC) {
       database.executeBatch(new ContractRenewalOppBatchHandler(), 1);
   }
}