public class SalesInvoicePostController {
    
    private Set<Id> invoiceIdSet = new Set<Id>();
    public Integer invoiceListSize {get;set;}
    
    // Constructor
    public SalesInvoicePostController(ApexPages.StandardSetController cntlr){
        for(c2g__codaInvoice__c invoice : (List<c2g__codaInvoice__c >)cntlr.getSelected()){
            invoiceIdSet.add(invoice.Id);
        }
        invoiceListSize = invoiceIdSet.size();
    }
    
    public void onSave()
    {
        if(invoiceListSize > 0){
            c2g.PostingPxService.postAsync(invoiceIdSet);
        }else{
            BulkSalesInvoicePostBatch.run();
        }
    }
}