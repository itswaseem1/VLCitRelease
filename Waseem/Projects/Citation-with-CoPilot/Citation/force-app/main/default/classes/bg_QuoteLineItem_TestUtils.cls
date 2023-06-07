/**************************************************************
* bg_QuoteLineItem_TestUtils - A utility class used for creating quote line item records
*
* Created By: Cameron Stewart
* Created Date: 2016-02-15
*
* Changes:
*
***************************************************************/
public with sharing class bg_QuoteLineItem_TestUtils {
    public static QuoteLineItem createQuoteLineItem(Id quoteId, Id pbeId, Decimal salesPrice, Integer quantity, Decimal discount)
    {
    	return new QuoteLineItem(
    		QuoteId = quoteId,
    		PricebookEntryId = pbeId,
    		UnitPrice = salesPrice,
    		Quantity = quantity,
    		Discount = discount
    	);
    }
}