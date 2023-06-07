@isTest
public class CampaignMemberHelperTest {
	@TestSetup Static void setup(){
        Campaign Camp = new Campaign(Name = 'Test');
        Camp.Type = 'Seminar / Conference';
        insert Camp;
        
        List<Lead> ldalist = new List<Lead>();
        for(integer i=1 ;i<10; i++){ 
            Lead lda = new Lead();
            lda.lastname = 'test1' + i;
            lda.company = 'testcomp';
            lda.Seminar_immediate_radius__c = true;
            lda.status = 'open';
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
        
        camp.IsActive = true;
        camp.Status = 'Planned';
        camp.Run_Seminar_Campaign_Batch__c = true;
        update camp;
        
    }
    
    public static testmethod void LeadSeminarCampaignActiveBatch_Test(){
        List<campaignMember> cMemList = [select id from campaignMember];
        Test.startTest();
        	Delete cMemList;
        Test.stopTest();
    }
}