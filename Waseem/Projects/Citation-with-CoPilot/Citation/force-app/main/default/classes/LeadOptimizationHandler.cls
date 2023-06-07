public with sharing class LeadOptimizationHandler {
    public static void CloseBasedOnOutcome(list<Lead> LeadList) {
    	for(Lead L : LeadList) {
    		
    		if(
    			L.status != 'Closed' && 
    			(L.OutboundDMUnavailableCount__c > 11 || 
    			L.OutboundGKCount__c > 4 ||
    			L.OutboundNoAnswerCount__c > 4 ||
    			L.OutboundBusyCount__c > 4 ||
    			L.OutboundDisconnectCallCount__c > 1 ||
    			L.OutboundAnswerMachineCallCount__c > 5 )
    		
    		) {
    			L.NVMConnect__NextContactTime__c = datetime.valueof('4000-1-1 00:00:00' ) ;
    			L.Status = 'Closed' ;
    		}
    		
    			
    		
    	
    		
    		
    	}
    }
}