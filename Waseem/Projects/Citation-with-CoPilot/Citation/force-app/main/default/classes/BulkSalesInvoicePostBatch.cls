public without sharing class BulkSalesInvoicePostBatch implements Database.Batchable<SObject>
{   
    public static void run(){
        Integer bulkSalesInvoicePostBatchSize = Integer.valueOf(BatchApexController__c.getValues('BulkSalesInvoicePostBatch').Batch_size__c);
        Database.executeBatch(new BulkSalesInvoicePostBatch(), bulkSalesInvoicePostBatchSize);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<String> cmps = c2g.CODAAPICompany_2_0.getCurrentCompanies(null);
        String query = 'SELECT Id FROM c2g__codaInvoice__c WHERE c2g__InvoiceStatus__c=\'In Progress\' AND c2g__OwnerCompany__r.Name IN: cmps';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> scope)
    {
        Set<Id> invoiceIds = (new Map<Id,c2g__codaInvoice__c>(scope)).keySet();
        c2g.PostingPxService.postSync(invoiceIds);
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
}