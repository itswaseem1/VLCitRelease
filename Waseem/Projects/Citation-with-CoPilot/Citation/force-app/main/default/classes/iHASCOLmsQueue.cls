public class iHASCOLmsQueue implements Queueable, Database.AllowsCallouts {
    
    public class CalloutData
    {
        Id recordId;
        String eventtype;
        
        public CalloutData(Id recordId, String eventtype)
        {
            this.recordId = recordId;
            this.eventtype = eventtype;
        }
    }
    
    public  List<CalloutData> paramList;
    
    public iHASCOLmsQueue(List<CalloutData> params){
        this.paramList = params;
    }
    
    public void execute(QueueableContext context) {
        if(!paramList.isEmpty())
        {
            CalloutData data = paramList.get(0);
            iHASCOLmsRestOutbound instance = new iHASCOLmsRestOutbound();
            instance.sendLMSData(data.recordId, data.eventtype);
            paramList.remove(0);
            
            if(!paramList.isEmpty()){
                System.enqueueJob(this);
            }
        }      
    }
}