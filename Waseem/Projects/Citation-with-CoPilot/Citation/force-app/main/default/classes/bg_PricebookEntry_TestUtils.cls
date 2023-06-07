/********************************************************************************
* bg_PricebookEntry_TestUtils :
*
* Utility methods for Pricebook Entry tests
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*********************************************************************************/
public with sharing class bg_PricebookEntry_TestUtils {
    
	public static PricebookEntry createPricebookEntry(Id pricebook, Id product, Decimal listPrice, Decimal additionalSitesPrice, Decimal additionalSitesPriceMixed)
    {
    	return new PricebookEntry(
    		Pricebook2Id = pricebook,
    		Product2Id = product,
    		UnitPrice = listPrice,
    		Additional_Sites_P_P__c = additionalSitesPrice,
    		Additional_Sites_Mixed_P_P__c = additionalSitesPriceMixed,
    		IsActive = true
    	);
    }

}