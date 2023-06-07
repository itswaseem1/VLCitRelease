@isTest
public class LeadSeminarCampaignInactiveBatchTest {
	 @TestSetup Static void setup(){
        Campaign Camp = new Campaign(Name = 'Test');
        Camp.Type = 'Seminar / Conference';
        insert Camp;
        
        List<Lead> ldalist = new List<Lead>();
        for(integer i=1 ;i<10; i++){ 
            Lead lda = new Lead();
            lda.lastname = 'test1' + i;
            lda.company = 'testcomp';
            lda.status = 'open';
            lda.Seminar_Campaign__c = camp.id;
            ldalist.add(lda);
        }
        insert ldalist;
        List<CampaignMember> camMemberList = new List<CampaignMember>();
        for(Lead l : ldalist){
            CampaignMember camMember= new CampaignMember();
            camMember.CampaignId = Camp.id;
            camMember.LeadId = l.id;
            camMemberList.add(camMember);
        }
        insert camMemberList;
        
        camp.IsActive = false;
        camp.Status = 'Completed';
        camp.Run_Seminar_Campaign_Batch__c = true;
        update camp;
        
    }
    
    public static testmethod void createTestData(){
        String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobID = '';
        List<campaign> campList = [select id from campaign];
        Test.startTest();
        	LeadSeminarCampaignInactiveBatch schjob = new LeadSeminarCampaignInactiveBatch();
            jobID = System.schedule('LeadSeminarCampaignInactiveBatch Job', CRON_EXP, schjob);
        Test.stopTest();
    }
    public static testmethod void createTestDataBatch(){
        String CRON_EXP = '0 0 0 3 9 ? 2032';
        String jobID = '';
        List<campaign> campList = [select id from campaign];
        Test.startTest();
        	LeadSeminarCampaignInactiveBatch schjob = new LeadSeminarCampaignInactiveBatch(100);
            jobID = System.schedule('LeadSeminarCampaignInactiveBatch Job', CRON_EXP, schjob);
        Test.stopTest();
    }
    
}