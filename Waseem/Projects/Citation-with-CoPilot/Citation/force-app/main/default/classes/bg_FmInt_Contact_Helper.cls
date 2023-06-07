/********************************************************************************
* bg_FmInt_Contact_Helper :
*
* Helper class for the Contact object.
*
* Created By: SA
* Created Date: 02-03-2016 
*
* Changes:
*********************************************************************************/
public with sharing class bg_FmInt_Contact_Helper {

	/*
		Called from after insert trigger.
		Send to FM if Cnt has a FM id
	*/
	public static void synchronise(List<Contact> contacts, Map<Id, Contact> oldMap) {
	    List<Contact> cntSendList = new List<Contact>();
	    for (Contact c : contacts) {
            if((c.FM_Contact_External_Id__c != null && oldMap.get(c.Id).FM_Contact_External_Id__c == c.FM_Contact_External_Id__c) &&
               (oldMap.get(c.Id).AccountId != c.AccountId || oldMap.get(c.Id).Title != c.Title ||
                oldMap.get(c.Id).FirstName != c.FirstName || oldMap.get(c.Id).LastName != c.LastName ||
                oldMap.get(c.Id).Phone != c.Phone         || oldMap.get(c.Id).Fax != c.Fax ||
                oldMap.get(c.Id).Email != c.Email         || oldMap.get(c.Id).Salutation != c.Salutation ||
                oldMap.get(c.Id).LeadSource != c.LeadSource || oldMap.get(c.Id).Position__c != c.Position__c)
             ) {
	    		// only update if Contact_External_Id__c is set AND no update to ext_ids
                cntSendList.add(c);
			}
	    }

	    if(cntSendList.size()>0) {
	        bg_FmIntContact.send(bg_FmIntContact.getAction(), cntSendList);
	    }

	}
    
}