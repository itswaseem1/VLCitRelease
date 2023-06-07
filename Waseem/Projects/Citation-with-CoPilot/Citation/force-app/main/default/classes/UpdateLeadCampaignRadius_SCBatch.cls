global without sharing class  UpdateLeadCampaignRadius_SCBatch implements Database.Batchable<sObject>, schedulable {
	
    public Integer BatchSize;
	private List<String> mailids;
    
    global UpdateLeadCampaignRadius_SCBatch(Integer Bsz) {
    	BatchSize = Bsz;
    }
    
    global UpdateLeadCampaignRadius_SCBatch() {
    	BatchSize = 100;
    }
    
    global void execute(SchedulableContext sc) {
   	 database.executebatch(this,BatchSize) ;
   }
   	
    
     global Database.QueryLocator start(Database.BatchableContext BC){
   	    string query = 'select id, 	Seminar_immediate_radius__c , Seminar_Campaign__c FROM Lead Where  Seminar_immediate_radius__c = true AND  Seminar_Campaign__c = NULL' ;
        return database.getQueryLocator(query);
   	   
    }
    
     global void execute(Database.BatchableContext BC, List<Lead> scope) {
         List<Lead> updatedProspects = new List<Lead>();
         For(Lead ld : scope){
             ld.Seminar_immediate_radius__c = false;
             updatedProspects.add(ld);  
         }
         if(updatedProspects != NULL && updatedProspects.SIZE() != 0){
            Database.update(updatedProspects , false) ;
        }
     }
    
    global void finish(database.batchableContext BC) {
         AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
         If(job.NumberOfErrors>0)
         {
            GenericBatchStatusEmails.sendEmail('The job processed ' + job.TotalJobItems +' batches with '+ job.NumberOfErrors + ' failures.' , 'Batch Failure - UpdateLeadCampaignRadius_SCBatch' ,Label.PaymentAgreement_BatchEmails.split(','));
         }
    }
    
}