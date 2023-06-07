public without sharing class BulkBillingDocumentCompleteBatch implements Database.Batchable<SObject>
{   
    public static void run(){
        Integer bulkProcessBillingDocumentsBatchSize = Integer.valueOf(BatchApexController__c.getValues('BulkBillingDocumentCompleteBatch').Batch_size__c);
        Database.executeBatch(new BulkBillingDocumentCompleteBatch(), bulkProcessBillingDocumentsBatchSize);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<String> cmps = c2g.CODAAPICompany_2_0.getCurrentCompanies(null);
        String query = 'SELECT Id FROM fferpcore__BillingDocument__c WHERE fferpcore__DocumentStatus__c=\'Draft\' AND fferpcore__Company__r.Name IN: cmps';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<fferpcore__BillingDocument__c> scope)
    {
        Set<Id> billingDocIds = (new Map<Id,fferpcore__BillingDocument__c>(scope)).keySet();
        ffbc.BillingDocumentsService.complete(billingDocIds);
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
}