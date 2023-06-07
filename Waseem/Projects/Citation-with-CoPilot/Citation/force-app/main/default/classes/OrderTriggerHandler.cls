public class OrderTriggerHandler {
    public static Id iHascoRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    
    public static void handleUpdate(List<Order> newOrder, Map<id,Order> oldOrderMap){
        Set<id> ordList= new set<id>();
        List<IHASCOLmsQueue.CalloutData> ordersToLms = new List<IHASCOLmsQueue.CalloutData>();
        for(Order ord: newOrder){
            if(ord.recordTypeId == iHascoRecTypeId && ((ord.Status == 'Activated') && (oldOrderMap.get(ord.id).Status != 'Activated')) ){
                ordersToLms.add(new IHASCOLmsQueue.CalloutData(ord.Id, Label.iHASCOEventOrderActivated));
                ordList.add(ord.id);
            }
        }
        if(ordList.size()>0 && Ordlist != NULL){
            iHASCOTopUpOrderSendMail.SendEmailToAccountsTeam(ordList);
        }
        if(!ordersToLms.isEmpty()){
            iHASCOLmsQueue queue = new iHASCOLmsQueue(ordersToLms);
            System.enqueueJob(queue);
        }
    }
    
    @future(callout=true)
    public static void sendLMSiHascoPayload(id OrderId, String EventType){
        iHASCOLmsRestOutbound instance = new iHASCOLmsRestOutbound();
        instance.sendLMSData(OrderId, EventType);       
    }
}