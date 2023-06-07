public without sharing class LegacyOpportunityLineItemTriggerHandler implements ITriggerHandler
{
    private boolean isIHasco()
    {
        return iHASCOUtility.userDivison == 'iHASCO';
    }

    public void beforeInsert(List<SObject> newRecords)
    {
        if(!isIHasco())
            bg_OpportunityLineItem_Helper.calculatePrices(trigger.new);
    }

    public void afterInsert(List<SObject> newRecords)
    {
        if(!isIHasco())
            updateCoreOpportunity(newRecords);
    }

    public void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {       
    }

    public void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        if(!isIHasco())
        {
            List<OpportunityLineItem> oppLines = (List<OpportunityLineItem>)newRecords.values();

            OpenOpportunityHandler.updateCoreComplianceOnOpp(oppLines); //Added for SDT-4891
        }
    }

    public void beforeDelete(List<SObject> oldRecords)
    {
    }

    public void afterDelete(List<SObject> oldRecords)
    {
        if(!isIHasco())
            updateCoreOpportunity(oldRecords);
    }

    public void afterUnDelete(List<SObject> newRecords)
    {
    }

    private void updateCoreOpportunity(List<SObject> oldRecords)
    {
        List<OpportunityLineItem> oppLines = (List<OpportunityLineItem>)oldRecords; 

        OpenOpportunityHandler.updateCoreComplianceOnOpp(oppLines); //Added for SDT-4891
    }
}