public with sharing class CIT_PH1_ContactIntegration {
	private Map<Id,Contact> contactToPush = new Map<Id,Contact>();
	
	public void addContactMap(Map<Id,Contact> newContactMap){
		this.contactToPush = newContactMap;
	}
    
	public void sendContactToServer(){
		List<String> jsonList = new List<String>();
		String Action = '';
		if(Trigger.isUpdate){
			Action += 'UPDATE_CONTACT';
			for(Contact eachContact : contactToPush.values()){
				jsonList.add(JSON.serialize(eachContact));
			}
		}else if(Trigger.isInsert){
			Action += 'INSERT_CONTACT';
			for(Contact eachContact : contactToPush.values()){
				//Only Add contacts that are not converted from a lead
				if(!eachContact.isConverted__c){
					jsonList.add(JSON.serialize(eachContact));
				}
			}
		}else if(Trigger.isDELETE){
			Action += 'DELETE_CONTACT';
			for(Contact eachContact : contactToPush.values()){
				jsonList.add(JSON.serialize(eachContact));
			}
		}else if(Trigger.isUNDELETE){
			Action += 'UNDELETE_CONTACT';
			for(Contact eachContact : contactToPush.values()){
				jsonList.add(JSON.serialize(eachContact));
			}
		}
		if(jsonList.size() > 0){
			if(!System.isBatch() && !System.isFuture() && !System.isScheduled())
				CIT_PH1_HTTPManager.sendJSONListToServer(Action,jsonList);
		}
	}
}