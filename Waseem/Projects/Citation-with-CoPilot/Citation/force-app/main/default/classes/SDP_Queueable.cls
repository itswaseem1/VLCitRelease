public class SDP_Queueable implements Queueable {
    String queryString;
    
    public SDP_Queueable(String queryString){
       this.queryString = queryString; 
    }
    public void execute(QueueableContext qc){
        
        SDP_BatchToGenerateSalesInvoiceCases batchInstance = new SDP_BatchToGenerateSalesInvoiceCases(queryString, false);
        database.executebatch(batchInstance,1);
    }
}