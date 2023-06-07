public class BillingDocumentCompleteController {
    
    private Set<Id> billDocIdSet = new Set<Id>();
    public Integer billDocListSize {get;set;}
    
    // Constructor
    public BillingDocumentCompleteController(ApexPages.StandardSetController cntlr){
        for(fferpcore__BillingDocument__c billDoc : (List<fferpcore__BillingDocument__c>)cntlr.getSelected()){
            billDocIdSet.add(billDoc.Id);
        }
        billDocListSize = billDocIdSet.size();
    }
    
    public void onSave()
    {
        if(billDocListSize > 0){
            ffbc.BillingDocumentsService.completeAsync(billDocIdSet);
        }else{
            BulkBillingDocumentCompleteBatch.run();
        }
    }
}