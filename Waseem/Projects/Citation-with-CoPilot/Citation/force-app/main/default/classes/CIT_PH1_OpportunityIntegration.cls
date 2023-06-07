public with sharing class CIT_PH1_OpportunityIntegration {

/*	private Map<Id,Opportunity> opportunityToPush = new Map<Id,Opportunity>();
	
	public void addOpportunityMap(Map<Id,Opportunity> newOpportunityMap){
		this.opportunityToPush = newOpportunityMap;
	}
      */
	public void sendOpportunityToServer(){
/*		List<String> jsonList = new List<String>();
		String Action = '';
		if(Trigger.isUpdate){
			Action += 'UPDATE_OPPORTUNITY';
			for(Opportunity eachOpportunity : opportunityToPush.values()){
				jsonList.add(JSON.serialize(eachOpportunity));
			}
		}else if(Trigger.isInsert){
			Action += 'INSERT_OPPORTUNITY';
			for(Opportunity eachOpportunity : opportunityToPush.values()){
				//Only Add opportunities that are not converted from a lead
				if(!eachOpportunity.isConverted__c){
					jsonList.add(JSON.serialize(eachOpportunity));
				}
			}
		}else if(Trigger.isDelete){
			Action += 'DELETE_OPPORTUNITY';
			for(Opportunity eachOpportunity : opportunityToPush.values()){
				jsonList.add(JSON.serialize(eachOpportunity));
			}
		}
		else if(Trigger.isUnDelete){
			Action += 'UNDELETE_OPPORTUNITY';
			for(Opportunity eachOpportunity : opportunityToPush.values()){
				jsonList.add(JSON.serialize(eachOpportunity));
			}
		}
		if(jsonList.size() > 0){
			if(!System.isBatch() && !System.isFuture() && !System.isScheduled())
				CIT_PH1_HTTPManager.sendJSONListToServer(Action,jsonList);
		} */
	} 
}