public class OpenOpportunityHandler
{
    public static void updateCoreComplianceOnOpp(List<opportunityLineItem> oppLineItemList)
    {
        if(oppLineItemList == null || oppLineItemList.isEmpty())
            return;

        Set<Id> oppIdSet = new Set<Id>();
        for(opportunityLineItem oppLineObj : oppLineItemList)
        {
            oppIdSet.add(oppLineObj.OpportunityId);
        }

        if(oppIdSet.isEmpty())
            return;

        List<String> coreProductList = new List<String>();
        for (String prodCodeStr : System.Label.CPQ_Core_Product_Codes.Split(','))
        {
            coreProductList.add(prodCodeStr.trim());
        }

        List<Opportunity> opps = [SELECT Id, Core_Compliance_TCV__c, 
                                        (SELECT Id,Product2.ProductCode,Subtotal From OpportunityLineItems) 
                                    FROM Opportunity 
                                    WHERE Id = :oppIdSet
                                    AND Opportunity.RecordType.Name!='QMS'
                                    AND Opportunity.RecordType.Name!='National Business Standards'];

        List<Opportunity> oppList = new List<Opportunity>();
        Decimal subTotal;
        for(Opportunity oppObj: opps)
        {
            subTotal = 0;
            for(OpportunityLineItem oppLineItemObj : oppObj.OpportunityLineItems)
            {
                if(coreProductList.contains(oppLineItemObj.Product2.ProductCode))
                {
                    subTotal += oppLineItemObj.Subtotal;
                }
            }

            if(oppObj.Core_Compliance_TCV__c != subTotal)
            {
                oppObj.Core_Compliance_TCV__c = subTotal;
                oppList.add(oppObj);
            }
        }

        if(!oppList.isEmpty()){
            Database.update(oppList,false);  
        }
    }
}