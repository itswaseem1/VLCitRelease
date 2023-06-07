/**************************************************************
* bg_Quote_TestUtils - A utility class used for tests creating quotes
*
* Created By: Cameron Stewart
* Created Date: 2016-02-15
*
* Changes:
*
***************************************************************/
public with sharing class bg_Quote_TestUtils {
    public static Quote generateBasicQuoteRecord(Id opportunityId, String name, Id priceBookId) {
    	Map<String,Id> quoteTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Quote.SObjectType);
		Id QMSRecordTypeId = quoteTypes.get(bg_Constants.QMS_QUOTE_RECORDTYPE);
    	return new Quote(OpportunityId = opportunityId, Name = name, Pricebook2Id = priceBookId, RecordTypeId = QMSRecordTypeId);
    }

    public static Quote generateDefaultQuoteRecord(Id opportunityId, String name, Id priceBookId) {
    	Map<String,Id> quoteTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Quote.SObjectType);
		Id QMSRecordTypeId = quoteTypes.get(bg_Constants.DEFAULT_QUOTE_RECORDTYPE);
    	return new Quote(OpportunityId = opportunityId, Name = name, Pricebook2Id = priceBookId, RecordTypeId = QMSRecordTypeId);
    }
}