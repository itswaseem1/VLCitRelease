global class NVMStandardDailListsNullJob implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    
    public NVMStandardDailListsNullJob(String queryString){
        query = queryString;
    }
    
    public NVMStandardDailListsNullJob(){
        query = 'SELECT Id,List_ID__c FROM Lead WHERE List_ID__c!=null AND IsConverted=false';
}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope){        
        try{
            List<Lead> nullList = new List<Lead>();
            for(Lead l : scope){
                if(l.List_ID__c!=null){
                    l.List_ID__c = null;
                    nullList.add(l);
                }
            }
            if(nullList!=null && nullList.size()>0){
                Database.update(nullList,false);
            }
        }catch(Exception e){
            System.debug('NVMStandardDailListsNullJob Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        list<Automation_Configuration__c> lad = [select id,Selected__c,Diallable__c from Automation_Configuration__c where Selected__c!= null OR Diallable__c != null];
        for(Automation_Configuration__c la:lad){
            la.Selected__c = null;
            la.Diallable__c  = null;
        }
        database.update(lad,false);
        Database.executeBatch(new NVMStandardDailListsScheduleJob(), 2000);
       
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NVMStandardDailListsNullJob(), 250);
    }

}