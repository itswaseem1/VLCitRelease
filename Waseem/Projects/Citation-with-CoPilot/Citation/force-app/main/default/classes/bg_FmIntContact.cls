/**********************************************************************
* bg_FmIntContact:
*
* Class to serialise Contact object into a json message and 
* send via bg_FmIntHttpCallout
* Created By: SA
* Created Date: 01-02-2016
*
* Changes: 
***********************************************************************/
public with sharing class bg_FmIntContact {

	public static Map<ID, Account> getAccMap(List<Id> accIdList) {
	    Map<ID, Account> accMap = new Map<ID, Account>([SELECT Id, Name, Phone, 
	    	BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
	    	Website, AnnualRevenue, Company_Registration_Number__c, Company_VAT_Number__c, 
	    	NumberOfEmployees, QMS_Sector__c, FM_Fixed_Notes__c, Staff__c, Billing_Address__c,
	    	TotalNoUKoffices__c, TotalNoInternationalOffices__c, AccountsEmailAddress__c
	    	FROM Account where id in :accIdList]);
	    return accMap;
	}

	public static Map<ID, Contact> getCntMap(List<Id> cntIdList) {
	    Map<ID, Contact> cntMap = new Map<ID, Contact>([SELECT Id, FM_Contact_External_Id__c, AccountId, Title, 
	    	FirstName, LastName, Phone, Fax, Email, LeadSource, Salutation, Position__c 
	    	FROM Contact where id in :cntIdList]);
	    return cntMap;
	}

	public static Map<ID, Account> getAccMap(List<Contact> cntList) {
	    List<Id> accIdList = new List<Id>();
	    for (Contact c : CntList) {
	        accIdList.add(c.AccountId);
	    }
	    return getAccMap(accIdList);
	}


	public static List<String> serialize(List<Contact> cntList) {
		Map<ID, Account> accMap = getAccMap(cntList);
		List<String> jsonList = new List<String>();
		for(Contact cnt : cntList){
			jsonList.add( '[' + JSON.serialize(cnt)  + ',' +  
				JSON.serialize(accMap.get(cnt.AccountId)) + ']');
		}
		return jsonList;
	}


	public static String getAction() {
		String action;

		if(Trigger.isUpdate) {
			action = 'Update';
		}
		else if(Trigger.isInsert) {
			action = 'Insert';
		}
		else if(Trigger.isDELETE) {
			action = 'Delete';
		}
		else if(Trigger.isUNDELETE) {
			action = 'Undelete';
		}

		return action;
	}

	public static void send(List<Contact> cntList) {
		send(bg_FmIntContact.getAction(), cntList);
	}

	public static void send(String action, List<Contact> cntList) {
		// if not SF API user
		String apiUsers = String.valueOf(FM_Integration__c.getValues('Host').get('SF_API_Username__c'));
		if(!apiUsers.contains(UserInfo.getUserName())) {
			ID jobIdOpp = bg_FmIntHttpQueueableCallout.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Contact',action,cntList));
			System.debug('send cnts: ' + action + ' # ' + cntList);
		}
	}
}