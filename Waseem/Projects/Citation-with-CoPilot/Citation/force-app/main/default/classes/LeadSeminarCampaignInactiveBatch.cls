global without sharing class  LeadSeminarCampaignInactiveBatch implements Database.Batchable<sObject>, schedulable {
	
    public Integer BatchSize;
	 
    global LeadSeminarCampaignInactiveBatch(Integer Bsz) {
    	BatchSize = Bsz;
    }
    
    global LeadSeminarCampaignInactiveBatch() {
    	BatchSize = 100;
    }
    
    global void execute(SchedulableContext sc) {
   	 database.executebatch(this,BatchSize) ;
   }
   	
    
     global Database.QueryLocator start(Database.BatchableContext BC){
   	    string query = 'select id, CampaignId, campaign.Type , Campaign.Status, campaign.isActive, LeadId   from CampaignMember where  campaign.Run_Seminar_Campaign_Batch__c = true AND (Campaign.Type = \'Seminar / Conference\') AND (Campaign.Status = \'Completed\' OR Campaign.Status = \'Aborted\') AND (Campaign.IsActive = false) AND (LeadID != NULL) '  ;
        return database.getQueryLocator(query);
   	   
    }
    
     global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
         set<id> idSetToReference = new Set<id>();
         set<id> idSetToDeReference = new Set<id>();
         Set<Lead> updatedProspects = new Set<Lead>();
         For(CampaignMember cMember : scope){
                     Lead ld = new Lead();
                     ld.id = cMember.LeadID;
                     ld.Seminar_Campaign__c = Null;
                     ld.Seminar_immediate_radius__c = false;
                     updatedProspects.add(ld);  
         }
         if(updatedProspects != NULL && updatedProspects.SIZE() != 0){
            List<Lead> updLeads = new List<Lead>(updatedProspects);
            Database.update(updLeads,false);
        }
     }
    
    global void finish(database.batchableContext BC) {
    	Database.executeBatch(new LeadSeminarCampaignActiveBatch(),BatchSize);
        
         AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
         If(job.NumberOfErrors>0)
         {
            GenericBatchStatusEmails.sendEmail('The job processed ' + job.TotalJobItems +' batches with '+ job.NumberOfErrors + ' failures.' , 'Batch Failure LeadSeminarCampaignInactiveBatch' ,Label.PaymentAgreement_BatchEmails.split(','));
         }
    }
    
    
}