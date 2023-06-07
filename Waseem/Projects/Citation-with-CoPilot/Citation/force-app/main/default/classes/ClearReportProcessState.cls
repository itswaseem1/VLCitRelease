global class ClearReportProcessState implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    
    public ClearReportProcessState(String queryString){
        query = queryString;
    }
    
    public ClearReportProcessState(){
        
        query = 'SELECT Id,Processed__c,recordtypeid FROM Automation_Configuration__c  WHERE Processed__c In: psState';
}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<string> psState = new list<string>();
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
                Database.update(aCList,false);
            }
        }catch(Exception e){
            System.debug('ClearReportProcessState Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new SelfServeReportResultsFetch(), 2000);
       
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ClearReportProcessState(), 250);
    }

}