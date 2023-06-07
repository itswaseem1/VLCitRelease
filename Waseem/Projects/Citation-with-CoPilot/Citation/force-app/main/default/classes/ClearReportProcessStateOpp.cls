global class ClearReportProcessStateOpp implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    public boolean chaining = false;
    
    public ClearReportProcessStateOpp(String queryString){
        query = queryString;
    }
    
    public ClearReportProcessStateOpp(){
        
        query = 'SELECT Id,Processed__c,recordtypeid FROM Automation_Configuration__c  WHERE Processed__c In: psState and recordtypeid In: rTid';
}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<string> psState = new list<string>();
        list<id>     rTid = new list<id>();
        id rid = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        rTid.add(rid);
        psState.add('Yes');
        psState.add('No');
        psState.add('NA');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Automation_Configuration__c> scope){        
        try{
            list<Automation_Configuration__c> aCList = new list<Automation_Configuration__c>();
            for(Automation_Configuration__c acs: scope){
                if(acs.Processed__c != 'NA'){
                    acs.Processed__c = 'No';
                    aCList.add(acs);
                }
            }
            if(aCList!=null && aCList.size()>0){
                chaining = true;
                Database.update(aCList,false);
                id UserId =(Id)UserInfo.getUserId();
                User                        toUp = new User();
                toUp.id = UserId;
                toUp.Run_Duplicate_Rules__c = true;
                update toUp;
            }
            else{
                chaining = false;
            }
        
        }catch(Exception e){
            System.debug('ClearReportProcessStateOpp Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        if(chaining){
            Database.executeBatch(new SelfServeReportResultsFetchOpp(), 2000);
        }
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ClearReportProcessStateOpp(), 250);
    }

}