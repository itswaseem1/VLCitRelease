public  class TriggerffbcContractHandler {
	
	public static boolean avoidContractResursion=false;
    public static void BeforeUpdate(list<ffbc__contract__c> NewRecords,map<id,ffbc__contract__c> OldRecordsMap) {
    	string fileName = '' ;
    	list<id> idList = new list<id>() ;
    	system.debug('List size.............' + newrecords.size()) ;
    	set<id> cIdSet = new set<id>() ;
    	list<id> idList1 = new list<id>() ;
    	for(ffbc__contract__c c : NewRecords) {
    		idList1.add(c.id) ;
    	}
    	
    	
    	list<ffbc__billingSchedule__c> schedList = [select id, ffbc__ContractLineItem__r.ffbc__Contract__r.id from ffbc__billingSchedule__c where ffbc__ContractLineItem__r.ffbc__Contract__r.id in :idList1] ;
    	for(ffbc__billingSchedule__c s : schedList) {
    	 cIdSet.add(s.ffbc__ContractLineItem__r.ffbc__Contract__r.id) ;
    	}
    	system.debug(cidSet) ;
    	
    	for(ffbc__contract__c c : NewRecords) {
	    	system.debug('Old Value -----> ' + OldRecordsMap.get(c.id).VAT_schedule_filetrigger__c) ;
    		system.debug('New Value ------> ' + c.VAT_schedule_filetrigger__C) ;
        		if(c.VAT_schedule_filetrigger__c == true && c.VAT_schedule_filetrigger__c != OldRecordsMap.get(c.id).VAT_schedule_filetrigger__c ) {
    			system.debug('Check for Process') ;
    			if(cidSet.contains(c.id)) {
    				system.debug('Added to process...!') ;
    				idList.add(c.id) ;
    			}
                /*if(c.SF_Contract__r.RecordType.Name=='E-Commerce'){
                    c.VAT_Schedule_Start__c=c.Service_Start_Roll_up__c!=null?c.Service_Start_Roll_up__c:c.ffbc__StartDate__c;
                }*/
    			
    			c.VAT_schedule_filetrigger__c = false ;
    			system.debug('Found One!!');
    			
    		}
    	}
    	
    	if(idList.size() >0) {
    		system.debug('Generate Files!!');
    		    		BillingScheduleController.GenerateScheduleFiles(idList) ;
    	}
    }
	
    public static void afterUpdate(List<ffbc__Contract__c> newContractList, Map<Id, ffbc__Contract__c> oldContractMap){
        populateFinancialForceFieldsOnAccount(newContractList, oldContractMap);
		populateInvoiceEmail(newContractList, oldContractMap);
    }
	
	// helper methods

    // copy Signatory email value from contract to Invoice email field on account if empty and when the Financial force contract is activated
    private static void populateInvoiceEmail(List<ffbc__Contract__c> newContracts, Map<Id, ffbc__Contract__c> oldContractMap){

        Set<Id> salesContract = new Set<Id>();
        for(ffbc__Contract__c record: newContracts){
            if(record.ffbc__Status__c != null && record.ffbc__Status__c.equalsIgnoreCase('Active')
                && oldContractMap != null && record.ffbc__Status__c <> oldContractMap.get(record.Id).ffbc__Status__c
                && record.SF_Contract__c != null){
                salesContract.add(record.SF_Contract__c);
            }
        }

        if(!salesContract.isEmpty()) {
            Map<Id, String> accountToEmailMap = new Map<Id, String>();
            for(Contract record: [select Id, Customer_Signatory_Email_Address__c, AccountId
                            from Contract where Id in: salesContract and Account.c2g__CODAInvoiceEmail__c = null and Customer_Signatory_Email_Address__c != null]){
                accountToEmailMap.put(record.AccountId, record.Customer_Signatory_Email_Address__c);
            }

            if(!accountToEmailMap.isEmpty()){
                List<Account> accountsToUpdate = new List<Account>();
                for(Account record: [select id, c2g__CODAInvoiceEmail__c from Account where Id in: accountToEmailMap.keyset()]){
                    record.c2g__CODAInvoiceEmail__c = accountToEmailMap.get(record.Id);
                    accountsToUpdate.add(record);
                }

                update accountsToUpdate;
            }
        }

    } 

    // when a contract is activated, set some financial force fields to default values if these fields are empty
    private static void populateFinancialForceFieldsOnAccount(List<ffbc__Contract__c> newContracts, Map<Id, ffbc__Contract__c> oldContractMap){
        
        Set<Id> accountIdsToPopulate = new Set<Id>();
        for(ffbc__Contract__c record: newContracts){
            if(record.ffbc__Status__c != null && record.ffbc__Status__c.equalsIgnoreCase('Active')
                && oldContractMap != null && record.ffbc__Status__c <> oldContractMap.get(record.Id).ffbc__Status__c){
                accountIdsToPopulate.add(record.ffbc__Account__c);
            }
        }

        if(!accountIdsToPopulate.isEmpty()){

            List<Account> accountsToUpdate = new List<Account>();
            Id recordTypeId;
            Schema.RecordTypeInfo rti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer');
            if(rti != null){
                recordTypeId = rti.getRecordTypeId();
            }

            Map<String, Id> ids = new Map<String, Id>();
            for(c2g__codaTaxCode__c record: [select Id, Name from c2g__codaTaxCode__c where Name in ('GB-I-STD', 'GB-O-STD')]){
                ids.put(record.Name, record.Id);
            }

            c2g__codaGeneralLedgerAccount__c gl = [select Id, Name from c2g__codaGeneralLedgerAccount__c where Name = '45100 - Trade Debtors Control' limit 1];
            ids.put('45100', gl.Id);

            for(Account record :[select Id, c2g__CODAAccountTradingCurrency__c, c2g__CODABillingMethod__c, c2g__CODAAccountsReceivableControl__c, c2g__CODAInputVATCode__c, c2g__CODAOutputVATCode__c, c2g__CODATaxCalculationMethod__c, c2g__CODAVATStatus__c, c2g__CODAECCountryCode__c
                                from Account where Id in: accountIdsToPopulate and RecordTypeId =: recordTypeId]){

                if( record.c2g__CODAVATStatus__c == null ) record.c2g__CODAVATStatus__c = 'Home';
                if( record.c2g__CODAECCountryCode__c == null ) record.c2g__CODAECCountryCode__c = 'GB';
                if( record.c2g__CODAInputVATCode__c == null ) record.c2g__CODAInputVATCode__c = ids.get('GB-I-STD');
                if( record.c2g__CODAOutputVATCode__c == null ) record.c2g__CODAOutputVATCode__c = ids.get('GB-O-STD');
                if( record.c2g__CODABillingMethod__c == null ) record.c2g__CODABillingMethod__c = 'Electronic';
                if( record.c2g__CODATaxCalculationMethod__c == null ) record.c2g__CODATaxCalculationMethod__c = 'Gross';
                if( record.c2g__CODAAccountTradingCurrency__c == null ) record.c2g__CODAAccountTradingCurrency__c = 'GBP';
                if( record.c2g__CODAAccountsReceivableControl__c == null ) record.c2g__CODAAccountsReceivableControl__c = ids.get('45100');

                accountsToUpdate.add(record);
            }

            update accountsToUpdate;
        }
        
    }
    /**
    * @author Raghunath Utpala
    * @date Sep 5th 2019
    * @description this method creates Billing Schedules for E-Commerce contract.
    * @return void
    **/
    public static void createBillingSchedules(List<ffbc__Contract__c> contracts){
        for(ffbc__ContractLineItem__c cline:[SELECT Id,ffbc__StartDate__c,ffbc__EndDate__c,Service_Months_in_Contract__c,ffbc__Contract__c FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN :contracts]){
            ffbc.ContractsService.ActivationRequest req=new ffbc.ContractsService.ActivationRequest();
            Set<Id> contractIds=new Set<Id>();
            contractIds.add(cline.ffbc__Contract__c);
            req.ContractIds=contractIds;
            req.MonthsToGenerate=(Integer)cline.Service_Months_in_Contract__c;
            ffbc.ContractsService.ActivationResponse resp = ffbc.ContractsService.activation(req);
        }
    }

    /**
    * @author Raghunath Utpala
    * @date Sep 5th 2019
    * @description this method creates VAT Schedules for E-Commerce contract.
    * @return void
    **/
    public static void createVATSchedules(List<ffbc__Contract__c> contracts){
        System.debug('Inside Create VAT Schedules');
        List<ffbc__Contract__c> contractsToUpdate=new List<ffbc__Contract__c>();
        List<Id> idList=new List<Id>();
        for(ffbc__Contract__c c:contracts){
            c.VAT_Schedule_Start__c=c.Service_Start_Roll_up__c!=null?c.Service_Start_Roll_up__c:c.ffbc__StartDate__c;
            //c.VAT_Schedule_FileTrigger__c=true;
            contractsToUpdate.add(c);
            System.debug('Contracts to update ---'+c);
            idList.add(c.Id);
        }
        if(!contractsToUpdate.isEmpty() && !avoidContractResursion){
            avoidContractResursion=true;
            update contractsToUpdate;
            System.debug('updated contracts are ---'+contractsToUpdate);
            if(System.isBatch()){
                BillingScheduleController.GenerateScheduleFilesSynchronous(idList);
            }
        }
    }
}