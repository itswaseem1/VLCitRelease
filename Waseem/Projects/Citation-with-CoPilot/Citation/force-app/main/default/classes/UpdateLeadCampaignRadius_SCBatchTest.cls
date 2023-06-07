@isTest
public class UpdateLeadCampaignRadius_SCBatchTest {
	@TestSetup Static void setup(){
        
        List<Lead> ldalist = new List<Lead>();
        for(integer i=1 ;i<10; i++){ 
            Lead lda = new Lead();
            lda.lastname = 'test1' + i;
            lda.company = 'testcomp';
            lda.status = 'open';
            lda.Seminar_immediate_radius__c = true;
            ldalist.add(lda);           
        }
        insert ldalist;
        
    }
    
     public static testmethod void UpdateLeadCampaignRadius_SCBatch_Test(){
         String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobID = '';
        List<campaign> campList = [select id from campaign];
        Test.startTest();
        	UpdateLeadCampaignRadius_SCBatch schjob = new UpdateLeadCampaignRadius_SCBatch();
            jobID = System.schedule('UpdateLeadCampaignRadius_SCBatch Job', CRON_EXP, schjob);
        Test.stopTest();
    }
    
    public static testmethod void UpdateLeadCampaignRadius_SCBatchSize_Test(){
         String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobID = '';
        List<campaign> campList = [select id from campaign];
        Test.startTest();
        	UpdateLeadCampaignRadius_SCBatch schjob = new UpdateLeadCampaignRadius_SCBatch(100);
            jobID = System.schedule('UpdateLeadCampaignRadius_SCBatch Job', CRON_EXP, schjob);
        Test.stopTest();
    }
}