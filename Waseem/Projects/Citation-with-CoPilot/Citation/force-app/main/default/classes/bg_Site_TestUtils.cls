/********************************************************************************
* bg_Site_TestUtils :
*
* Utility methods for Account Site tests
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*********************************************************************************/
public with sharing class bg_Site_TestUtils {

    public static Site__c createSite(String name, Id accountId)
    {
    	return new Site__c(
    		Name = name,
    		Account__c = accountId
    	);
    }

}