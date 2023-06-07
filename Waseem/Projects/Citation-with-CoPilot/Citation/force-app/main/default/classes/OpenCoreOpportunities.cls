global class OpenCoreOpportunities implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    
    public OpenCoreOpportunities(String queryString){
        query = queryString;
    }
    
    public OpenCoreOpportunities(){
        query = 'SELECT Id,account.CoreCitationContractMonths__c,(Select Product2.ProductCode From OpportunityLineItems),accountid FROM opportunity WHERE recordtypeid Not In:opRecId and stagename In: LstStageName';
}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        set<string>         LstStageName = new set<string>();
        LstStageName.add('Closed Lost');
        list<id> opRecId = new list<id>();
        id qmsid  = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('QMS').getRecordTypeId();
        id nbssid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('National Business Standards').getRecordTypeId(); 
        opRecId.add(qmsid);
        opRecId.add(nbssid); 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<opportunity> scope){        
        try{
            /*map<id,account>    mapAcc = new map<id,account>();
            set<string>     PrCodes = new set<string>();
            set<string>     listcoreProductCodes = new set<string>();
            listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
            if(!listcoreProductCodes.isEmpty()){
                for (String prouctcode : listcoreProductCodes) {
                    PrCodes.add(prouctcode.trim());
                }
            }
            for(opportunity op: scope){
                for(OpportunityLineItem opl: op.OpportunityLineItems){
                    if(PrCodes.contains(opl.Product2.ProductCode)){
                        account ac = new account();
                        ac.id = op.accountid;
                        ac.Open_Core_Opportunities__c = true ;
                        mapAcc.put(op.accountid,ac);
                    }
                }
            }
            if(mapAcc.size()>0){
                update mapAcc.values();
            }*/
            list<id>                  oid = new list<id>();
            
            for(opportunity op:scope){
                if(op.account.CoreCitationContractMonths__c == 0){
                    oid.add(op.id);
                }
            }
            
            OpenOpportunityHandler.coreOpportunityCheck(oid);
            
        }catch(Exception e){
            System.debug('OpenCoreOpportunities Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new OpenCoreOpportunities(), 250);
    }
}