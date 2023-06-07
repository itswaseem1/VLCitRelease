public with sharing class CIT_PH1_AccountIntegration {
	
	private Map<Id,Account> accountToPush = new Map<Id,Account>();
	
	public void addAccountMap(Map<Id,Account> newAccountMap){
		this.accountToPush = newAccountMap;
		String accountsQuery = constructAccountContactQuery();
		constructAccountsWithOpporutnityAndContact(accountsQuery);
	}
	
	private String constructAccountContactQuery(){
		String accountsQuery = 'SELECT ';
		accountsQuery += CIT_PH1_Utility.addAccountsFieldToQuery(); 
		accountsQuery += '(SELECT ' + CIT_PH1_Utility.addContactsFieldToQuery() + ' FROM Contacts),';
		accountsQuery += '(SELECT ' + CIT_PH1_Utility.addOpportunityFieldToQuery() + ' FROM Opportunities)';
		accountsQuery += ' FROM Account';
		accountsQuery += ' WHERE Id IN ';
		accountsQuery += CIT_PH1_Utility.constructInFilterCriteria(this.accountToPush.keyset());
        return accountsQuery;
	}
	
	private void constructAccountsWithOpporutnityAndContact(String query){
		this.accountToPush = new Map<Id,Account>();
		for(Account eachAccount :Database.query(query)) {
            this.accountToPush.put(eachAccount.Id, eachAccount);
        }
	}
	
	public void sendAccountToServer(){
		List<String> accountJsonList = new List<String>();
		List<String> financeApprovedJsonList = new List<String>();
		String Action = '';
		if(Trigger.isUpdate){
			Action += 'UPDATE_ACCOUNT';
			for(Account eachAccount : accountToPush.values()){
				if(eachAccount.Finance_Approved__c){
					financeApprovedJsonList.add(JSON.serialize(eachAccount));
				}else{
					accountJsonList.add(JSON.serialize(eachAccount));
				}
			}
		}else if(Trigger.isInsert){
			Action += 'INSERT_ACCOUNT';
			for(Account eachAccount : accountToPush.values()){
				//Only Add accounts that are not converted from a lead
				if(!eachAccount.isConverted__c){
					accountJsonList.add(JSON.serialize(eachAccount));
				}
			}
		}else if(Trigger.isDelete){
			Action += 'DELETE_ACCOUNT';
			for(Account eachAccount : accountToPush.values()){
				accountJsonList.add(JSON.serialize(eachAccount));
			}
		}else if(Trigger.isUnDelete){
			Action += 'UNDELETE_ACCOUNT';
			for(Account eachAccount : accountToPush.values()){
				accountJsonList.add(JSON.serialize(eachAccount));
			}
		}
		if(accountJsonList.size() > 0){
			if(!System.isBatch() && !System.isFuture() && !System.isScheduled())
				CIT_PH1_HTTPManager.sendJSONListToServer(Action,accountJsonList);
		}
		if(financeApprovedJsonList.size() > 0){
			if(!System.isBatch() && !System.isFuture() && !System.isScheduled())
				CIT_PH1_HTTPManager.sendJSONListToServer('FINANCE_SIGNED_OFF',financeApprovedJsonList);
		}
	}
	
}