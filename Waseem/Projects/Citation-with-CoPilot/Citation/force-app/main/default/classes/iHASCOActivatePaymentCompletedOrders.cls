public class iHASCOActivatePaymentCompletedOrders  implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable  {
    
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> statuses = SYSTEM.Label.iHASCOOrderStatusforActivation.split(',');
        String PaymentStatus = SYSTEM.Label.iHASCOPaymentStatusCompleted;
        String orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
        String query = 'SELECT id, Status from Order WHERE recordTypeid = :orderRecordType and Status = :statuses AND Payment_Status__c = :PaymentStatus' ;
        return Database.getQueryLocator(query);
    }

     public void execute(Database.BatchableContext BC, List<Order> Orders) {
         List<order> updatedOrders = new List<Order>();
         for(Order ord: Orders){
             ord.Status = 'Activated';
             updatedOrders.add(ord);
         }	
         if(!updatedOrders.isEmpty()){
             update updatedOrders;
         }
    }    
    public void execute(SchedulableContext sc){
        iHASCOActivatePaymentCompletedOrders iHASCOActivatePayments = new iHASCOActivatePaymentCompletedOrders();
        Database.executeBatch(iHASCOActivatePayments, 1);
    }
    public void finish(Database.BatchableContext BC){    
    }
}