@isTest
public with sharing class TestDataUtils {

	// Test Data Utility class containing various utility functions used for testing purposes
	public static final String RANDOM_CHARS 			= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	public static final String ALPHA_CHARS 				= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	public static final String RANDOM_ALL 				= '35';
	public static final String RANDOM_ALPHA 			= '25';

	public static Lead getLead(){
		Lead thelead = new Lead();
		thelead.LastName=getRandomString(10);
		thelead.Company=getRandomString(15);
		thelead.PostalCode='SK9 5AA';
		return thelead;
	}

    public static Lead insertLead(){
        Lead thelead = getLead();
        insert thelead;
        return thelead;
    }

	public static Campaign getCampaign(){
		Campaign thecampaign = new Campaign();
		thecampaign.Name=getRandomString(15);
		thecampaign.Description=getRandomString(30);
		thecampaign.IsActive=true;
		thecampaign.Postcode__c='SK9 5AA';
		return thecampaign;
	}

	public static Campaign insertCampaign(){
		Campaign thecampaign = getCampaign();
		insert thecampaign;
		return thecampaign;
	}

	public static CampaignMember getCampaignMember(Campaign campaign, Lead lead) {
        return new CampaignMember(CampaignId = campaign.Id, LeadId = lead.Id);
    }

    public static CampaignMember insertCampaignMember(Campaign campaign, Lead lead) {
        CampaignMember campaignMember = getCampaignMember(campaign, lead);
        insert campaignMember;
        return campaignMember;
    }	

	public static Double getRandomNumber() {
		return Math.round(Math.random() * 101) - 1;
	}
	
	public static String getRandomAlphaString(Integer len) { return getRandomString(len, RANDOM_ALPHA); } 
	public static String getRandomString(Integer len) { return getRandomString(len, RANDOM_ALL); } 
	public static String getRandomString(Integer len, String mode)
	{
		String retVal = '';
		if (len != null && len >= 1)
		{
			Integer chars = 0;
			Integer random;
			do
			{
				random = Math.round(Math.random() * Integer.valueOf(mode));
				retVal += RANDOM_CHARS.substring(random, random + 1);
				chars++;
			} while (chars < len);
		}
		return retVal;
	}

}