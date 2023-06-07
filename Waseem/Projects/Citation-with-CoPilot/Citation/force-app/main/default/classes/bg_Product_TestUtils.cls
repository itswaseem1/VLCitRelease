/********************************************************************************
* bg_Product_TestUtils :
*
* Utility methods for Product tests
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*********************************************************************************/
public with sharing class bg_Product_TestUtils {
    
	public static Product2 createProduct(String category, String type, String service)
    {
    	return new Product2(
    		Name = category,
    		Family = type,
    		Service_Type__c = service
    	);
    }
}