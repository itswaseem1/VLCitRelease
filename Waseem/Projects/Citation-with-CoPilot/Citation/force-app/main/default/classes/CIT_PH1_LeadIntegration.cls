public with sharing class CIT_PH1_LeadIntegration {
	
	private Map<Id,Account> accountToPush;
	private Set<Id> convertedLeadsAccountId = new Set<id>();
	
	public void addConvertedLeads(List<Lead> leadList){
		for(Lead eachLead : leadList){
			if(eachLead.IsConverted){
				this.convertedLeadsAccountId.add(eachLead.convertedAccountId);
			}
		}
		//Only needed if lead is converted
		if(this.convertedLeadsAccountId.size() > 0){
			String accountsQuery = constructAccountContactQuery();
			constructAccountsWithOpporutnityAndContact(accountsQuery);
		}
	}
	
	private String constructAccountContactQuery(){
		String accountsQuery = 'SELECT ';
		accountsQuery += CIT_PH1_Utility.addAccountsFieldToQuery(); 
		accountsQuery += '(SELECT ' + CIT_PH1_Utility.addContactsFieldToQuery() + ' FROM Contacts),';
		accountsQuery += '(SELECT ' + CIT_PH1_Utility.addOpportunityFieldToQuery() + ' FROM Opportunities)';
		accountsQuery += ' FROM Account';
		accountsQuery += ' WHERE Id IN ';
		accountsQuery += CIT_PH1_Utility.constructInFilterCriteria(this.convertedLeadsAccountId);
        return accountsQuery;
	}
	
	private void constructAccountsWithOpporutnityAndContact(String query){
		this.accountToPush = new Map<Id,Account>();
		for(Account eachAccount :Database.query(query)) {
            this.accountToPush.put(eachAccount.Id, eachAccount);
        }
        
	}
	
	public void sendAccountToServer(){
		List<String> jsonList = new List<String>();
		if (this.convertedLeadsAccountId.size() > 0){
			for(Account eachAccount : accountToPush.values()){
				jsonList.add(JSON.serialize(eachAccount));
			}
			System.DEBUG('Trigger Context : ' + Trigger.isUpdate);
		}
		if(jsonList.size() > 0){
			if(!System.isBatch() && !System.isFuture() && !System.isScheduled())
				CIT_PH1_HTTPManager.sendJSONListToServer('CONVERTED',jsonList);
		}
	}
	
}