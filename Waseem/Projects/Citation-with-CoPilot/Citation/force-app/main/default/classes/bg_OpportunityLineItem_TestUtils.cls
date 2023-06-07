/********************************************************************************
* bg_OpportunityLineItem_TestUtils :
*
* Utility methods for Opportunity Line Item tests
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*********************************************************************************/
public with sharing class bg_OpportunityLineItem_TestUtils {

	public static OpportunityLineItem createOppLineItem(Id oppId, Id pbeId, Decimal salesPrice, Integer quantity, Decimal discount)
    {
    	return new OpportunityLineItem(
    		OpportunityId = oppId,
    		PricebookEntryId = pbeId,
    		UnitPrice = salesPrice,
    		Quantity = quantity,
    		Discount = discount
    	);
    }

}