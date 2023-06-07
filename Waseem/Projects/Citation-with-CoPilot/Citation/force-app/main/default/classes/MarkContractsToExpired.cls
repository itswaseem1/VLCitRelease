public class MarkContractsToExpired implements Database.Batchable<sObject>, Schedulable{
   public final String Query;
   public MarkContractsToExpired(String q){
            Query=q;
               
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<Contract> scope){
    list<Contract>     contractListToUpdate  = new list<contract>();
    for(Contract c : scope){
         c.status = 'Expired';
         contractListToUpdate.add(c);
    }      
    if(contractListToUpdate.size()>0){
      Database.update(contractListToUpdate,false);
    }
    
   }

   public void finish(Database.BatchableContext BC){

   }
    /*****
    *** Scheduler Interface method 
    *****/
   Public void execute(SchedulableContext SC) {
      string q = 'Select id,status from contract where recordtype.name IN (\''+ String.escapeSingleQuotes('iHASCO Standard Contract') + '\') and enddate = YESTERDAY and status =\''+ String.escapeSingleQuotes('Active') + '\'' ;
       database.executeBatch(new MarkContractsToExpired(q), 10);
  }

}