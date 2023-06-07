public class DataJobForExpBillingContracts implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
	Set<Id> contractIds = new Set<Id>();
    List<String> errors = new List<String>();
    List<ffbc__ContractLineItem__c> excludedContracts = new List<ffbc__ContractLineItem__c>();
    
     public Database.QueryLocator start(Database.BatchableContext BC){
        excludedContracts = [Select Id, ffbc__UnitPrice__c, ffbc__Contract__c, Total_Billing_Terms__c from ffbc__ContractLineItem__c where ffbc__Contract__r.CreatedDate >= 2020-09-01T00:00:00.000Z And (Total_Billing_Terms__c = 0 OR Total_Billing_Terms__c = 1) And ffbc__UnitPrice__c = 0];
    
		for(ffbc__ContractLineItem__c cli : excludedContracts){
        contractIds.add(cli.ffbc__Contract__c);
    	}
    	string query = 'Select Id, Status from Case where (Billing_Contract__r.ffbc__Status__c = \'Superseded\' OR Billing_Contract__r.ffbc__Status__c = \'Expired\') AND Billing_Contract__c Not In :contractIds AND expBillingContProcessed__c = False';
      	return Database.getQueryLocator(query);
   }
    
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        List<WorkOrder> updateWorkOrders = new List<WorkOrder>();
        Map<Id, WorkOrder> workOrderIdMap = new Map<Id, WorkOrder>();
        System.debug('Number of cases: '+scope.size());
        System.debug('cases : '+scope);
        Savepoint sp = Database.setSavepoint();
        try{
            for(Case eachCase : scope){
                if(eachCase.Status == 'Pending Start'){
                    eachCase.Status = 'Contract Amendment';                    
                }
                else{
                    caseIds.add(eachCase.Id);
                }            		
                eachCase.expBillingContProcessed__c = True;
                casesToUpdate.add(eachCase);
        	}
            if(!caseIds.isEmpty()) {
            	for(WorkOrder wo : [Select Id, ServiceAppointmentCount, Status From WorkOrder where CaseId In :caseIds]){
                	if(wo.ServiceAppointmentCount > 0){
                    	workOrderIdMap.put(wo.Id, wo);
                	}
                	else{
                    	wo.Status = 'Canceled';
                		updateWorkOrders.add(wo);
                	}
            	}
            	if(!workOrderIdMap.keySet().isEmpty()){
            		for(ServiceAppointment sa : [Select Id, Status, Reason__c, ParentRecordId From ServiceAppointment where ParentRecordId In :workOrderIdMap.keySet()]){
                		if(sa.Status == 'None' || sa.Status == 'Scheduled'){
                    		sa.Status = 'Cannot Complete';
                    		sa.Reason__c = 'Contract issue with Client Relations';
                			appointmentsToUpdate.add(sa);
                		}
                		else if(workOrderIdMap.containsKey(sa.ParentRecordId)){
                    		workOrderIdMap.remove(sa.ParentRecordId);
                		}

            		} 
            		for (WorkOrder w : workOrderIdMap.values()){
                		w.Status = 'Canceled';
                		updateWorkOrders.add(w);
            		}
             	}
            }
            if(!casesToUpdate.IsEmpty())
            	update casesToUpdate;
            if(!updateWorkOrders.IsEmpty())
            	update updateWorkOrders;
            if(!appointmentsToUpdate.IsEmpty())
            	update appointmentsToUpdate;
        }
        catch(Exception error){
            Database.rollback(sp);
            errors.add(error.getMessage());
        }
        
    }
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   		String[] toAddresses = new String[] {a.CreatedBy.Email};
   		mail.setToAddresses(toAddresses);
   		mail.setSubject(' ' + a.Status);
   		mail.setPlainTextBody
   		('The batch Apex job processed ' + a.TotalJobItems +
   			' batches with '+ a.NumberOfErrors + ' failures. The errors are '+errors);
   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
    public void execute(SchedulableContext sc) {
        database.executebatch(new DataJobForExpBillingContracts(), 1);        
    }
}