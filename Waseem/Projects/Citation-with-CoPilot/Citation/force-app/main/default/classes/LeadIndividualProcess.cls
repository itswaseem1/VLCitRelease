global class LeadIndividualProcess implements Database.Batchable<sObject>{
 global Database.queryLocator start (Database.BatchableContext bc){
      string st = 'Data Quality';
   String query= 'SELECT Id,FirstName,Name,status,RecordTypeId,Recordtype.Name,LastName,Email,IndividualId,HasOptedOutOfEmail FROM Lead where email != null and individualid = null and RecordtypeId != null and IsConverted = false limit '+system.Label.Batch_Limit_Label;
        return Database.getQueryLocator(query); 
 }
 global void execute (Database.BatchableContext bc ,List<Lead> scope){
      LeadTriggerHandler lTU = new LeadTriggerHandler();
     list<lead> updateLeadList = lTU.populateIndividual(scope);
     if(!updateLeadList.isEmpty()){
          upsert updateLeadList;
     }
     
 }
 global void finish (Database.BatchableContext bc){
 }
}