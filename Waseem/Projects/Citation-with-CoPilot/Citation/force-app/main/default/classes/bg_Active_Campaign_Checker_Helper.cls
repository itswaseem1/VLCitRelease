/******************************************************************************************************************************
*
* bg_Active_Campaign_Checker_Helper :
*
* Helper methods for active campaign checker 
*
* Created By: Hossein Mirzapour 
* Created Date: 02-10-2015 
*
* Changes: KH 11-11-15 - Updated getInRangeActiveSeminarNamesDescriptionByLeadId to cater for no description on the Campaign. 
*
*******************************************************************************************************************************/

public class bg_Active_Campaign_Checker_Helper {

    /*
        Method to populate a Campaign Name to Campaign Description map. Also catering for a blank description. 
    */
    public static Map<String, String> getInRangeActiveSeminarNamesDescriptionByLeadId(List<Campaign> campaigns)
    {
        Map<String, String> campaignNameDescriptionMap = new Map<String, String>();
        String NO_DESCRIPTION = 'No Description';

        for(Campaign campaign : campaigns)
        {
            if (campaign.Description == null) {
                campaignNameDescriptionMap.put(campaign.Name, NO_DESCRIPTION);              
            }
            else {
                campaignNameDescriptionMap.put(campaign.Name, campaign.Description);            
            }
        }

        return campaignNameDescriptionMap;
    }

    /*
        Returns active campaigns based on the type parameter
    */
    public static List<Campaign> getActiveCampaigns(String type, Lead lead, Decimal distance)
    {

        return null;
    }

     /*
        Method to get all the active Campaigns for the given GeoCode records
    */
    public static List<Campaign> getActiveCampaignRelatedtoGeoCode(Set<Id> relatedGeocodes)
    {
        return null;
    }

}