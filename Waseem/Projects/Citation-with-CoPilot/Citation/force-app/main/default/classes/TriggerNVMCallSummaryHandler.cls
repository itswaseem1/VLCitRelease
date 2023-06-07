public with sharing class TriggerNVMCallSummaryHandler {
	public TriggerNVMCallSummaryHandler() {}

	public static void onBeforeInsert(final List<NVMStatsSF__NVM_Call_Summary__c> newObjects){
		updateDialListName(newObjects, null);
	}

	public static void onBeforeUpdate(final List<NVMStatsSF__NVM_Call_Summary__c> newObjects, Map<Id, NVMStatsSF__NVM_Call_Summary__c> oldObjects){
		updateDialListName(newObjects, oldObjects);
	}

	// helper methods

	private static void updateDialListName(List<NVMStatsSF__NVM_Call_Summary__c> newObjects, Map<Id, NVMStatsSF__NVM_Call_Summary__c> oldObjects){
		if(newObjects == null) return;

		Map<Id, NVMStatsSF__NVM_Call_Summary__c> taskIDCallSummaryMap = new Map<Id, NVMStatsSF__NVM_Call_Summary__c>();

		for(NVMStatsSF__NVM_Call_Summary__c record: newObjects){
			// on insert
			if(oldObjects == null || oldObjects.size() == 0){
				if(record.NVMStatsSF__TaskExists__c == true && record.NVMStatsSF__TaskID__c != null && record.Dial_List_Name__c == null){
					taskIDCallSummaryMap.put(Id.ValueOf(record.NVMStatsSF__TaskID__c), record);
				}
			}
			// on update 
			else if( oldObjects != null && !oldObjects.isEmpty() && oldObjects.get(record.Id) != null){
				
				if(record.NVMStatsSF__TaskID__c == null &&  record.Dial_List_Name__c != null){
					record.Dial_List_Name__c = null;
				} else if(record.NVMStatsSF__TaskExists__c == true && record.NVMStatsSF__TaskID__c != null && record.NVMStatsSF__TaskID__c <> oldObjects.get(record.Id).NVMStatsSF__TaskID__c){
					taskIDCallSummaryMap.put(Id.ValueOf(record.NVMStatsSF__TaskID__c), record);
				}

			}
		}

		if(taskIDCallSummaryMap.size() > 0){
			for(Task record: [select Id, NVMConnect__DialList__c, NVMConnect__DialList__r.Name from Task where Id in:taskIDCallSummaryMap.keyset() ]){
				NVMStatsSF__NVM_Call_Summary__c callSummary = taskIDCallSummaryMap.get(record.Id);
				if(callSummary != null){
					callSummary.Dial_List_Name__c = record.NVMConnect__DialList__c != null ? record.NVMConnect__DialList__r.Name : null;
				}
			}
		}

	}

}