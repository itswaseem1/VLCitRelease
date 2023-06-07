public inherited sharing class ProductService extends DefaultService {
    
    public interface ISelector
    {
        Database.QueryLocator getRelatedOppLines(Set<Id> productIds);
    }
    
    private ISelector selector;

    public ProductService(ISelector selector) 
    {
        this.selector = selector;
    }
    
    /*
    *   see IDomainService
    */
    public override void setDefaults(List<SObject> newRecords)
    {
        
    }
    
    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        super.processRelatedRecordsOnChange(newRecords, oldRecords);

        List<Product2> newProducts = (List<Product2>)newRecords;
        Map<Id, Product2> oldProducts = (Map<Id, Product2>)oldRecords;
        updateOppLinesOnProductCoreness(newProducts, oldProducts);
    }
    
    private void updateOppLinesOnProductCoreness(List<Product2> newProducts, Map<Id, Product2> oldProducts)
    {
        new UpdateRelatedOppLinesOnProductCoreness(newProducts, oldProducts, selector).process();
    }
    
    public class UpdateRelatedOppLinesOnProductCoreness
    {
        private Map<Id,Boolean> productsToProcess;
        private ISelector selector;
        
        updateRelatedOppLinesOnProductCoreness(List<Product2> newProducts, Map<Id, Product2> oldProducts, ISelector selector)
        {
            this.productsToProcess = findProductsToProcess(newProducts, oldProducts);
            this.selector = selector;
        }
        
        private Map<Id,Boolean> findProductsToProcess(List<Product2> newProducts, Map<Id, Product2> oldProducts)
        {
            Map<Id,Boolean> productCorenessChangedMap = new Map<Id,Boolean>();
            
            for(Product2 objProduct: newProducts)
            {
                if(objProduct.Is_Core__c != oldProducts.get(objProduct.Id).Is_Core__c)
                {
                    productCorenessChangedMap.put(objProduct.Id, objProduct.Is_Core__c);
                }
            }
            return productCorenessChangedMap;
        }
        
        public Database.QueryLocator getRelatedOppLines(){
            return selector.getRelatedOppLines(productsToProcess.keySet());
        }
            
        public void execute(List<OpportunityLineItem> relatedOppLinesList){
            
            List<OpportunityLineItem> oppLineItemUpdateList = new List<OpportunityLineItem>();
            
            for(OpportunityLineItem objOppLineItem : relatedOppLinesList)
            {
                Boolean productCore = productsToProcess.get(objOppLineItem.Product2Id);
                if(objOppLineItem.Is_Core__c != productCore){
                    objOppLineItem.Is_Core__c = productCore;
                    oppLineItemUpdateList.add(objOppLineItem);
                }
            }
            if(!oppLineItemUpdateList.isEmpty())
            {
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(oppLineItemUpdateList);
            }
        }
        
        void process()
        {
            if(productsToProcess.isEmpty())
                return;
            
            Integer UpdateOppLinesCorenessBatchSize = Integer.valueOf(BatchApexController__c.getValues('UpdateOppLinesCorenessBatch').Batch_size__c);
            Database.executeBatch(new UpdateOppLinesCorenessBatch(this), UpdateOppLinesCorenessBatchSize);
        }
    }
    
    public class DefaultSelector implements ISelector {
        
        public Database.QueryLocator getRelatedOppLines(Set<Id> productIds)
        {
            return Database.getQueryLocator([SELECT Id,Product2Id,Is_Core__c FROM OpportunityLineItem WHERE Product2Id IN : productIds AND Opportunity.StageName!='Closed Lost' AND Opportunity.StageName!='Closed Won']);
        }
    }
}