global class DeleteNVMEven_Note implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    
    public DeleteNVMEven_Note(String queryString){
        query = queryString;
    }
    
    public DeleteNVMEven_Note(){
        query = 'select id,CreatedDate from NVMContactWorld__InteractionEvent__c where CreatedDate < today and CreatedDate < LAST_N_DAYS:7';
}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<NVMContactWorld__InteractionEvent__c> scope){        
        try{
            List<NVMContactWorld__InteractionEvent__c> nvm_EvenandNote = new List<NVMContactWorld__InteractionEvent__c>();
            for(NVMContactWorld__InteractionEvent__c nmen : scope){
                nvm_EvenandNote.add(nmen);
            }
            if(nvm_EvenandNote.size()>0){
                Database.delete(nvm_EvenandNote,false);
            }
            Database.emptyRecycleBin(nvm_EvenandNote);
        }catch(Exception e){
            System.debug('DeleteNVMEven_Note Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
       
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteNVMEven_Note(), 250);
    }

}