/********************************************************************************
* bg_OpportunityLineItem_Helper :
*
* Helper class for the Opportunity Line Item (Opportunity Product) object.
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*   JW - 09-02-2016 - Updated in line with CC001; changes to additional sites pricing and number of sites, and reductions
*
*********************************************************************************/
public with sharing class bg_OpportunityLineItem_Helper {
    
    /*
        Called on before insert trigger.
        For opp line items related to a QMS opportunity, update the sales price to include the price for the additional sites. This is done by:
            - Take the sales price and store this in the User Sales Price field. 
            - Then calculate the extra price of additional sites using the sites to visit field multiplied by the additional cost per site
            - Add this value to the sales price.
            - Also store this additional sites price in the Additional Sites Price field.
    */
    public static void calculatePrices(List<OpportunityLineItem> oppLineItems){

        // Create a list of the related Opportunity and Pricebook Entry Ids so that the records can be selected.
        List<Id> parentOppIds = new List<Id>();
        List<Id> parentPBEIds = new List<Id>();
        for (OpportunityLineItem oppLineItem : oppLineItems)
        {
            parentOppIds.add(oppLineItem.OpportunityId);
            parentPBEIds.add(oppLineItem.PricebookEntryId);
        }

        // Create a map of Opportunities and Pricebook Entries so that the related records can be retrieved when looping through the line items.
        Map<Id, Opportunity> parentOpportunityMap = new Map<Id,Opportunity>([select Id, RecordTypeId, Certification__c, Same_Standard_On_All_Sites__c, Sites_Visited__c, SyncedQuoteId, Contract_Length_Years__c, Type from Opportunity where id in :parentOppIds]);
        Map<Id, PricebookEntry> parentPBEMap = new Map<Id,PricebookEntry>([select Id, Additional_Sites_P_P__c, Additional_Sites_Mixed_P_P__c, Product2.Name, Days__c, Product2.Family from PricebookEntry where id in :parentPBEIds]);

        // Get the QMS Opportunity RecordTypeId for checks.
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSRecordTypeId = opportunityTypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);

        for (OpportunityLineItem oppLineItem : oppLineItems)
        {
            oppLineItem = populateOpportunityLineItemFields(oppLineItem, parentOpportunityMap.get(oppLineItem.OpportunityId), parentPBEMap.get(oppLineItem.PricebookEntryId), QMSRecordTypeID);
        }
    }

    public static OpportunityLineItem populateOpportunityLineItemFields(OpportunityLineItem opportunityLineItemRecord, Opportunity parentOpportunityRecord, PricebookEntry parentPriceBookEntryRecord, Id QMSRecordTypeId) {

        Boolean isQMSRecordTypeId = parentOpportunityRecord.RecordTypeId == QMSRecordTypeId;
        Boolean isProductReductionType = parentPriceBookEntryRecord.Product2.Name == bg_Constants.REDUCTION_PRODUCT_TYPE;
        Boolean alreadyCalculated = opportunityLineItemRecord.User_Sales_Price__c != 0;
        Boolean parentOppIsSyncing = parentOpportunityRecord.SyncedQuoteId != null;

        bg_LogsHelper.populateLog(opportunityLineItemRecord, 'isQMSRecordTypeId [' + isQMSRecordTypeId + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
        bg_LogsHelper.populateLog(opportunityLineItemRecord, 'isProductReductionType [' + isProductReductionType + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
        bg_LogsHelper.populateLog(opportunityLineItemRecord, 'alreadyCalculated [' + alreadyCalculated + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
        bg_LogsHelper.populateLog(opportunityLineItemRecord, 'parentOppIsSyncing [' + parentOppIsSyncing + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');

        if (isQMSRecordTypeId && !isProductReductionType && !alreadyCalculated && !parentOppIsSyncing)
        {
            // Store the sales price entered by the user in a separate field so that this information is not lost.
            opportunityLineItemRecord.User_Sales_Price__c = opportunityLineItemRecord.UnitPrice;
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'opportunityLineItemRecord.User_Sales_Price__c [' + opportunityLineItemRecord.User_Sales_Price__c + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'parentOpportunityRecord.Same_Standard_On_All_Sites__c [' + parentOpportunityRecord.Same_Standard_On_All_Sites__c + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            // Check if the same standard is applied across sites and use the appropriate additional sites price based on this.
            if (parentOpportunityRecord.Same_Standard_On_All_Sites__c)
            {
                bg_LogsHelper.populateLog(opportunityLineItemRecord, 'same on all sites', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
                opportunityLineItemRecord.Additional_Sites_Price__c = parentPriceBookEntryRecord.Additional_Sites_P_P__c;
                opportunityLineItemRecord.Additional_Sites_Days__c = 0.5;
            }
            else 
            {
                bg_LogsHelper.populateLog(opportunityLineItemRecord, 'not same on all sites', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
                opportunityLineItemRecord.Additional_Sites_Price__c = parentPriceBookEntryRecord.Additional_Sites_Mixed_P_P__c;
                opportunityLineItemRecord.Additional_Sites_Days__c = 1;
            }

            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'opportunityLineItemRecord.Additional_Sites_Price__c [' + opportunityLineItemRecord.Additional_Sites_Price__c + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'opportunityLineItemRecord.Additional_Sites_Days__c [' + opportunityLineItemRecord.Additional_Sites_Days__c + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');

            // Take 1 off the number of sites visited to account for the main site then calculate the new sales price.

            Decimal unitPrice = opportunityLineItemRecord.UnitPrice != null ? opportunityLineItemRecord.UnitPrice : 0;
            Decimal days = parentPriceBookEntryRecord.Days__c != null ? parentPriceBookEntryRecord.Days__c : 0;
            Decimal sitesVisited = parentOpportunityRecord.Sites_Visited__c != null ? parentOpportunityRecord.Sites_Visited__c : 1;
            Decimal additionalSitesPrice = opportunityLineItemRecord.Additional_Sites_Price__c != null ? opportunityLineItemRecord.Additional_Sites_Price__c : 0;
            Decimal additionalSitesDays = opportunityLineItemRecord.Additional_Sites_Days__c != null ? opportunityLineItemRecord.Additional_Sites_Days__c : 0;

            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'unitPrice [' + unitPrice + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'days [' + days + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'sitesVisited [' + sitesVisited + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'additionalSitesPrice [' + additionalSitesPrice + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'additionalSitesDays [' + additionalSitesDays + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');

            Decimal newUnitPrice = unitPrice + ((sitesVisited - 1) * additionalSitesPrice);
            Decimal newDays = days + ((sitesVisited - 1) * additionalSitesDays);

            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'newUnitPrice [' + newUnitPrice + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'newDays [' + newDays + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');

            opportunityLineItemRecord.UnitPrice = newUnitPrice;
            //opportunityLineItemRecord.Cert_Days__c = newDays;

            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'opportunityLineItemRecord.UnitPrice [' + opportunityLineItemRecord.UnitPrice + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'opportunityLineItemRecord.Cert_Days__c [' + opportunityLineItemRecord.Cert_Days__c + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');

            if (parentPriceBookEntryRecord.Product2.Family == 'Audit' && parentOpportunityRecord.Type != bg_Constants.RENEWAL_OPPORTUNITY_TYPE && parentOpportunityRecord.Contract_Length_Years__c > 1)
            {
                bg_LogsHelper.populateLog(opportunityLineItemRecord, 'not renewal', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
                if (parentOpportunityRecord.Certification__c != null && parentOpportunityRecord.Certification__c.equalsIgnoreCase(bg_Constants.OPPORTUNITY_CERTIFICATION_CONNECT)) {
                    opportunityLineItemRecord.Quantity = parentOpportunityRecord.Contract_Length_Years__c;
                } else {
                    opportunityLineItemRecord.Quantity = parentOpportunityRecord.Contract_Length_Years__c - 1; 
                }
            }
            else if(parentPriceBookEntryRecord.Product2.Family == 'Audit' && (parentOpportunityRecord.Type == bg_Constants.RENEWAL_OPPORTUNITY_TYPE || parentOpportunityRecord.Contract_Length_Years__c == 1))
            {
                bg_LogsHelper.populateLog(opportunityLineItemRecord, 'renewal', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
                opportunityLineItemRecord.Quantity = parentOpportunityRecord.Contract_Length_Years__c;
            }

            bg_LogsHelper.populateLog(opportunityLineItemRecord, 'opportunityLineItemRecord.Quantity [' + opportunityLineItemRecord.Quantity + ']', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');

        }

        System.debug('Brightgen opportunityLineItemRecord [' + opportunityLineItemRecord + ']');
        bg_LogsHelper.populateLog(opportunityLineItemRecord, 'End of method\n', 'bg_OpportunityLineItem_Helper', 'populateOpportunityLineItemFields');
        return opportunityLineItemRecord;
    }
}