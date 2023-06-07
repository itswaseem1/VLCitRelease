/********************************************************************************
* bg_QuoteLineItem_Helper :
*
* Helper class for the Quote Line Item object.
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*   JW - 09-02-2016 - Updated in line with CC001; changes to additional sites pricing and number of sites, and reductions
*
*********************************************************************************/
public with sharing class bg_QuoteLineItem_Helper {
    
    /*
        Called on before insert trigger.
        For quote line items related to a QMS Quote, update the sales price to include the price for the additional sites. This is done by:
            - Take the sales price and store this in the User Sales Price field. 
            - Then calculate the extra price of additional sites using the sites to visit field multiplied by the additional cost per site
            - Add this value to the sales price.
            - Also store this additional sites price in the Additional Sites Price field.
    */
    public static void calculatePrices(List<QuoteLineItem> quoteLineItems){
        // Create a list of the related Quote and Pricebook Entry Ids so that the records can be selected.
        List<Id> parentquoteIds = new List<Id>();
        List<Id> parentPBEIds = new List<Id>();
        Map<Id, List<QuoteLineItem>> quoteLineItemPerQuote = new Map<Id, List<QuoteLineItem>>();
        for (QuoteLineItem quoteLineItem : quoteLineItems)
        {
            bg_LogsHelper.populateLog(quoteLineItem, 'quoteLineItem.QuoteId [' + quoteLineItem.QuoteId + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
            parentquoteIds.add(quoteLineItem.QuoteId);
            parentPBEIds.add(quoteLineItem.PricebookEntryId);
            if(quoteLineItemPerQuote.containsKey(quoteLineItem.QuoteId)) 
            {
                bg_LogsHelper.populateLog(quoteLineItem, 'quote contains key', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                List<QuoteLineItem> quotesQuoteLineItems = quoteLineItemPerQuote.get(quoteLineItem.QuoteId);
                quotesQuoteLineItems.add(quoteLineItem);
                quoteLineItemPerQuote.put(quoteLineItem.QuoteId, quotesQuoteLineItems);
            } 
            else 
            {
                bg_LogsHelper.populateLog(quoteLineItem, 'new quote added', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                quoteLineItemPerQuote.put(quoteLineItem.QuoteId, new List<QuoteLineItem> { quoteLineItem });
            }
        }

        // Create a map of Quotes and Pricebook Entries so that the related records can be retrieved when looping through the line items.
        Map<Id, Quote> parentQuoteMap = new Map<Id,Quote>([select Id, OpportunityId, RecordTypeId, Same_Standard_On_All_Sites__c, Sites_Visited__c, IsSyncing, Opportunity.Contract_Length_Years__c, Opportunity.Type from Quote where id in :parentquoteIds]);
        Map<Id, PricebookEntry> parentPBEMap = new Map<Id,PricebookEntry>([select Id, Additional_Sites_P_P__c, Additional_Sites_Mixed_P_P__c, Product2.Name, Days__c, Product2.Family from PricebookEntry where id in :parentPBEIds]);
        
        List<Id> relatedOppIds = new List<Id>();
        for (Quote quote : parentQuoteMap.values())
        {
            relatedOppIds.add(quote.OpportunityId);
        }

        Map<String, OpportunityLineItem> oppLineMap = new Map<String, OpportunityLineItem>();
        List<OpportunityLineItem> relatedLineItems = [select Id, UnitPrice, Quantity, Product2Id, PricebookEntryId, Product_Family__c, Description, Presentation_Days__c, Discount, Additional_Sites_Days__c, Cert_Days__c, OpportunityId, User_Sales_Price__c, Additional_Sites_Price__c from OpportunityLineItem where OpportunityId in :relatedOppIds order by Id DESC];
        
        Map<Id, List<OpportunityLineItem>> oppLineItemPerOpp = new Map<Id, List<OpportunityLineItem>>();
        for (OpportunityLineItem oppLineItem : relatedLineItems)
        {
            if(oppLineItemPerOpp.containsKey(oppLineItem.OpportunityId)) 
            {
                List<OpportunityLineItem> oppsOppLineItems = oppLineItemPerOpp.get(oppLineItem.OpportunityId);
                oppsOppLineItems.add(oppLineItem);
                oppLineItemPerOpp.put(oppLineItem.OpportunityId, oppsOppLineItems);
            } 
            else 
            {
                oppLineItemPerOpp.put(oppLineItem.OpportunityId, new List<OpportunityLineItem> { oppLineItem });
            }
        }

        for (List<OpportunityLineItem> oppRelatedOppLineItems : oppLineItemPerOpp.values())
        {
            Integer i=0;
            for (OpportunityLineItem oppLineItem : oppRelatedOppLineItems)
            {
                oppLineMap.put(string.valueOf(oppLineItem.OpportunityId)+string.valueOf(oppLineItem.PricebookEntryId), oppLineItem);
                i++;
            }
        }
        system.debug('oppLineMap: ' + oppLineMap);

        // Get the QMS Quote RecordTypeId for checks.
        Map<String,Id> quoteTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Quote.SObjectType);
        Id QMSRecordTypeId = quoteTypes.get(bg_Constants.QMS_QUOTE_RECORDTYPE);

        for (List<QuoteLineItem> quotesQuoteLineItems : quoteLineItemPerQuote.values())
        {
            integer j = 0;
            for (QuoteLineItem quoteLineItem : quotesQuoteLineItems)
            {
                system.debug('quoteLineItem: ' + quoteLineItem);
                system.debug('j: ' + j);
                Boolean isCreatedFromQuoteInsert = bg_Quote_Helper.getNewQuoteIds().contains(quoteLineItem.QuoteId);
                // Get the parent Quote and Pricebook Entry, ready to refer to their fields.
                if(!isCreatedFromQuoteInsert || Test.isRunningTest())
                {
                    quoteLineItem = populateQuoteLineItemFields(quoteLineItem, parentQuoteMap.get(quoteLineItem.QuoteId), parentPBEMap.get(quoteLineItem.PricebookEntryId), QMSRecordTypeId);
                }
                else
                {
                    bg_LogsHelper.populateLog(quoteLineItem, 'set quoteLineItem.User_Sales_Price__c [' + quoteLineItem.User_Sales_Price__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set quoteLineItem.Additional_Sites_Price__c [' + quoteLineItem.Additional_Sites_Price__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set quoteLineItem.Additional_Sites_Days__c [' + quoteLineItem.Additional_Sites_Days__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set quoteLineItem.Cert_Days__c [' + quoteLineItem.Cert_Days__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set quoteLineItem.Presentation_Days__c [' + quoteLineItem.Presentation_Days__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set quoteLineItem.Product_Family__c [' + quoteLineItem.Product_Family__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');

                    OpportunityLineItem relatedLineItem = oppLineMap.get(string.valueOf(parentQuoteMap.get(quoteLineItem.QuoteId).OpportunityId)+string.valueOf(quoteLineItem.PricebookEntryId));
                    system.debug('parentQuoteMap.get(quoteLineItem.QuoteId).OpportunityId+string.valueOf(quoteLineItem.PricebookEntryId): ' + string.valueOf(parentQuoteMap.get(quoteLineItem.QuoteId).OpportunityId)+string.valueOf(quoteLineItem.PricebookEntryId));
                    system.debug('relatedLineItem: ' + relatedLineItem);
                    quoteLineItem.User_Sales_Price__c = relatedLineItem.User_Sales_Price__c;
                    quoteLineItem.Additional_Sites_Price__c = relatedLineItem.Additional_Sites_Price__c;
                    quoteLineItem.Additional_Sites_Days__c = relatedLineItem.Additional_Sites_Days__c;
                    quoteLineItem.Cert_Days__c = relatedLineItem.Cert_Days__c;
                    quoteLineItem.Presentation_Days__c = relatedLineItem.Presentation_Days__c;
                    quoteLineItem.Product_Family__c = relatedLineItem.Product_Family__c;

                    bg_LogsHelper.populateLog(quoteLineItem, 'parentQuoteMap.get(quoteLineItem.QuoteId).OpportunityId+string.valueOf(quoteLineItem.PricebookEntryId): ' + string.valueOf(parentQuoteMap.get(quoteLineItem.QuoteId).OpportunityId)+string.valueOf(quoteLineItem.PricebookEntryId), 'bg_QuoteLineItem_Helper', 'calculatePrices');

                    bg_LogsHelper.populateLog(quoteLineItem, 'set relatedLineItem.User_Sales_Price__c [' + relatedLineItem.User_Sales_Price__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set relatedLineItem.Additional_Sites_Price__c [' + relatedLineItem.Additional_Sites_Price__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set relatedLineItem.Additional_Sites_Days__c [' + relatedLineItem.Additional_Sites_Days__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set relatedLineItem.Cert_Days__c [' + relatedLineItem.Cert_Days__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set relatedLineItem.Presentation_Days__c [' + relatedLineItem.Presentation_Days__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                    bg_LogsHelper.populateLog(quoteLineItem, 'set relatedLineItem.Product_Family__c [' + relatedLineItem.Product_Family__c + ']', 'bg_QuoteLineItem_Helper', 'calculatePrices');

                    bg_LogsHelper.populateLog(quoteLineItem, 'End of method\n', 'bg_QuoteLineItem_Helper', 'calculatePrices');
                }
                j++;
            }
        }

    }

    public static QuoteLineItem populateQuoteLineItemFields(QuoteLineItem quoteLineItemRecord, Quote parentQuoteRecord, PricebookEntry parentPriceBookEntry, ID QMSRecordTypeId) {

        Boolean isQMSRecordTypeId = parentQuoteRecord.RecordTypeId == QMSRecordTypeId;
        Boolean isRequctionProductType = parentPriceBookEntry.Product2.Name == bg_Constants.REDUCTION_PRODUCT_TYPE;
        Boolean alreadyCalculated = quoteLineItemRecord.User_Sales_Price__c != 0;

        bg_LogsHelper.populateLog(quoteLineItemRecord, 'isQMSRecordTypeId [' + isQMSRecordTypeId + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
        bg_LogsHelper.populateLog(quoteLineItemRecord, 'isRequctionProductType [' + isRequctionProductType + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
        bg_LogsHelper.populateLog(quoteLineItemRecord, 'alreadyCalculated [' + alreadyCalculated + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');

        if (isQMSRecordTypeId && !isRequctionProductType && !alreadyCalculated)
        {
            // Store the sales price entered by the user in a separate field so that this information is not lost.
            quoteLineItemRecord.User_Sales_Price__c = quoteLineItemRecord.UnitPrice;
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'quoteLineItemRecord.User_Sales_Price__c [' + quoteLineItemRecord.User_Sales_Price__c + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'parentQuoteRecord.Same_Standard_On_All_Sites__c [' + parentQuoteRecord.Same_Standard_On_All_Sites__c + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            // Check if the same standard is applied across sites and use the appropriate additional sites price based on this.
            if (parentQuoteRecord.Same_Standard_On_All_Sites__c)
            {
                bg_LogsHelper.populateLog(quoteLineItemRecord, 'same on all sites', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
                quoteLineItemRecord.Additional_Sites_Price__c = parentPriceBookEntry.Additional_Sites_P_P__c;
                quoteLineItemRecord.Additional_Sites_Days__c = 0.5;
            }
            else {
                bg_LogsHelper.populateLog(quoteLineItemRecord, 'not same on all sites', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
                quoteLineItemRecord.Additional_Sites_Price__c = parentPriceBookEntry.Additional_Sites_Mixed_P_P__c;
                quoteLineItemRecord.Additional_Sites_Days__c = 1;
            }
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'quoteLineItemRecord.Additional_Sites_Price__c [' + quoteLineItemRecord.Additional_Sites_Price__c + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'quoteLineItemRecord.Additional_Sites_Days__c [' + quoteLineItemRecord.Additional_Sites_Days__c + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            // Take 1 off the number of sites visited to account for the main site then calculate the new sales price.

            Decimal unitPrice = quoteLineItemRecord.UnitPrice != null ? quoteLineItemRecord.UnitPrice : 0;
            Decimal days = parentPriceBookEntry.Days__c != null ? parentPriceBookEntry.Days__c : 0;
            Decimal sitesVisited = parentQuoteRecord.Sites_Visited__c != null ? parentQuoteRecord.Sites_Visited__c : 1;
            Decimal additionalSitesPrice = quoteLineItemRecord.Additional_Sites_Price__c != null ? quoteLineItemRecord.Additional_Sites_Price__c : 0;
            Decimal additionalSitesDays = quoteLineItemRecord.Additional_Sites_Days__c != null ? quoteLineItemRecord.Additional_Sites_Days__c : 0;

            bg_LogsHelper.populateLog(quoteLineItemRecord, 'unitPrice [' + unitPrice + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'days [' + days + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'sitesVisited [' + sitesVisited + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'additionalSitesPrice [' + additionalSitesPrice + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'additionalSitesDays [' + additionalSitesDays + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');

            Decimal newUnitPrice = unitPrice + ((sitesVisited - 1) * additionalSitesPrice);
            Decimal newDays = days + ((sitesVisited - 1) * additionalSitesDays);

            bg_LogsHelper.populateLog(quoteLineItemRecord, 'newUnitPrice [' + newUnitPrice + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
            bg_LogsHelper.populateLog(quoteLineItemRecord, 'newDays [' + newDays + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');

            quoteLineItemRecord.UnitPrice = newUnitPrice;
            //quoteLineItemRecord.Cert_Days__c = newDays;
            if (parentPriceBookEntry.Product2.Family == 'Audit' && parentQuoteRecord.Opportunity.Type != bg_Constants.RENEWAL_OPPORTUNITY_TYPE && parentQuoteRecord.Opportunity.Contract_Length_Years__c > 1){
                quoteLineItemRecord.Quantity = parentQuoteRecord.Opportunity.Contract_Length_Years__c - 1;
            }

            else if (parentPriceBookEntry.Product2.Family == 'Audit' && (parentQuoteRecord.Opportunity.Type == bg_Constants.RENEWAL_OPPORTUNITY_TYPE || parentQuoteRecord.Opportunity.Contract_Length_Years__c == 1)){
                quoteLineItemRecord.Quantity = parentQuoteRecord.Opportunity.Contract_Length_Years__c;
            }

            bg_LogsHelper.populateLog(quoteLineItemRecord, 'quoteLineItemRecord.Quantity [' + quoteLineItemRecord.Quantity + ']', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
        }

        System.debug('Brightgen quoteLineItemRecord [' + quoteLineItemRecord + ']');
        bg_LogsHelper.populateLog(quoteLineItemRecord, 'End of method\n', 'bg_QuoteLineItem_Helper', 'populateQuoteLineItemFields');
        return quoteLineItemRecord;
    }

}