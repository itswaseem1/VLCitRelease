public without sharing class CampaignMemberHelper 
{    	
    public static void dereferenceProspectSeminarCampaign(List<CampaignMember> oldCampMemList, Map<id,CampaignMember> oldCampMemMap){
        Set<id> campIds = new Set<id>();
        Map<id,String> CampType = new Map<id,String>();
        List<Lead> updatedLeads = new List<Lead>();
        For(CampaignMember c : oldCampMemList){
            campIds.add(c.CampaignId);
        }
        IF(campIds != NULL && campIds.size() != 0){
            for(Campaign camp: [SELECT Id,Type FROM Campaign where id IN :campIds AND TYPE = 'Seminar / Conference']){
				CampType.put(camp.id,camp.Type);
            }
        }
        For(CampaignMember c : oldCampMemList){
            if( c.LeadId != NULL && CampType.containskey(c.CampaignId)){
                lead ld = new lead();
                ld.id = c.LeadId;
                ld.Seminar_immediate_radius__c = false;
                ld.Seminar_Campaign__c = NULL;
                updatedLeads.add(ld);      		
            }
        }
        if(updatedLeads.size() != 0){
            update updatedLeads;
        }        
    }
}