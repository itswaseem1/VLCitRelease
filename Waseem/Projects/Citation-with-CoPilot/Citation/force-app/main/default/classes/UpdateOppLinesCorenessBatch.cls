public without sharing class UpdateOppLinesCorenessBatch implements Database.Batchable<SObject>
{
    private ProductService.updateRelatedOppLinesOnProductCoreness handler;
    
    public UpdateOppLinesCorenessBatch(ProductService.updateRelatedOppLinesOnProductCoreness handler)
    {
        this.handler = handler;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
    	return handler.getRelatedOppLines();
    }
  
    public void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope)
    {
        handler.execute(scope);
    }
  
    public void finish(Database.BatchableContext BC)
    {
        
    }
}