public inherited sharing class OpportunityLineItemService extends DefaultService {
    public interface ISelector{
        Set<Id> getCoreProducts(List<OpportunityLineItem> sourceOppLines);
    }
    private ISelector selector;

    public OpportunityLineItemService(ISelector selector) 
    {
        this.selector = selector;
    }
    
    public override void setDefaults(List<SObject> newRecords)
    {
        List<OpportunityLineItem> newOppLineItems = (List<OpportunityLineItem>)newRecords;
        setIsCore(newOppLineItems);
    }
    
    private void setIsCore(List<OpportunityLineItem> newOppLineItems)
    {
        new SetCoreOppLines(newOppLineItems, selector).process();
    }
    
    class SetCoreOppLines
    {
        private List<OpportunityLineItem> newOppLines;
        private ISelector selector;
        
        setCoreOppLines(List<OpportunityLineItem> newOppLines, ISelector selector)
        {
            this.newOppLines = newOppLines;
            this.selector = selector;
        }

        void process()
        {
            Set<Id> coreProductIds = selector.getCoreProducts(newOppLines);
            for(OpportunityLineItem objOppLineItem : newOppLines)
            {
                if(coreProductIds.contains(objOppLineItem.Product2Id)){
                	objOppLineItem.Is_Core__c = true;    
                }
            }
        }
    }
    
    public class DefaultSelector implements ISelector 
    {
        public Set<Id> getCoreProducts(List<OpportunityLineItem> sourceOppLines)
        {
            Set<Id> productIdSet = new Set<Id>();
            for(OpportunityLineItem objOppLine: sourceOppLines)
            {
                productIdSet.add(objOppLine.Product2Id);
            }
            Map<Id,Product2> coreProductMap = new Map<Id,Product2>([Select Id,Is_Core__c FROM Product2 WHERE ID=: productIDSet AND Is_Core__c=TRUE]);
            return coreProductMap.keySet();
        }
    }
}