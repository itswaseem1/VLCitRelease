global class ClearReportProcessStateOppAutomation implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    
    public ClearReportProcessStateOppAutomation(String queryString){
        query = queryString;
    }
    
    public ClearReportProcessStateOppAutomation(){
        
        query = 'SELECT Id,Processed__c,recordtypeid FROM Automation_Configuration__c  WHERE Processed__c In: psState and recordtypeid In: recTId';
}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<string> psState = new list<string>();
        psState.add('Yes');
        psState.add('No');
        psState.add('NA');
        list<id> recTId =new list<id>();
        recTId.add(Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Opportunity Automation').getRecordTypeId());
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
                Database.update(aCList,false);
            }
        }catch(Exception e){
            System.debug('ClearReportProcessStateOppAutomation Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new SelfServeReportResultsFetchOppAutomation(), 2000);
       
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ClearReportProcessStateOppAutomation(), 250);
    }

}