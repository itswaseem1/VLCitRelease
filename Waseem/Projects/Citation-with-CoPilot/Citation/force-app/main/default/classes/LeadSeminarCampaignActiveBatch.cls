global without sharing class LeadSeminarCampaignActiveBatch implements Database.Batchable<sobject> {
	
    private List<String> mailids;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
   	    string query = 'select id, CampaignId, campaign.Type , Campaign.Status, campaign.isActive, LeadId   from CampaignMember where  campaign.Run_Seminar_Campaign_Batch__c = true AND (Campaign.Type = \'Seminar / Conference\') AND (Campaign.Status = \'In Progress\' OR Campaign.Status = \'Planned\') AND (Campaign.IsActive = true) AND (LeadID != NULL) '  ;
        return database.getQueryLocator(query);
   	   
    }

    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
         set<id> idSetToReference = new Set<id>();
         set<id> idSetToDeReference = new Set<id>();
        Set<Lead> updatedProspects = new Set<Lead>();
         For(CampaignMember cMember : scope){
                     Lead ld = new Lead();
                     ld.id = cMember.LeadID;
                     ld.Seminar_Campaign__c = cMember.CampaignId;
                     updatedProspects.add(ld);    
         }
        if(updatedProspects != NULL && updatedProspects.SIZE() != 0){
            List<Lead> updLeads = new List<Lead>(updatedProspects);
            Database.update(updLeads, false);
        }
     }
    
    global void finish(database.BatchableContext BC){
		 
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
         If(job.NumberOfErrors>0)
         {
            GenericBatchStatusEmails.sendEmail('The job processed ' + job.TotalJobItems +' batches with '+ job.NumberOfErrors + ' failures.' , 'Batch Failure - LeadSeminarCampaignActiveBatch' ,Label.PaymentAgreement_BatchEmails.split(','));
         }
        List<Campaign> updateCamp = new List<Campaign>();
        For(Campaign camp : [select id ,Run_Seminar_Campaign_Batch__c from Campaign where Run_Seminar_Campaign_Batch__c = true]){
            camp.Run_Seminar_Campaign_Batch__c = false;
            updateCamp.add(camp);
        }
        if(updateCamp != NULL && updateCamp.size() != 0){
            Update updateCamp;
        }
    }
    
}