/********************************************************************************
* bg_FmInt_Account_Helper :
*
* Helper class for the Account object.
*
* Created By: SA
* Created Date: 02-03-2016 
*
* Changes:
*********************************************************************************/
public with sharing class bg_FmInt_Account_Helper {

	/*
		Called from after insert trigger.
		Send to FM if any of the Account's Contacts has a FM id
	*/
	public static void synchronise(List<Account> accounts, Map<Id, Account> oldMap) {

		Features__c f = new Features__c() ;
    	try {
    		f = Features__c.getValues('Default');
    	}
    	catch (Exception ex) {
    		
    	}
    	
    	
    	if(f != null && f.Contact_Sync__c == true) {

			List<Id> accIdList = new List<Id>();
			for (Account a : accounts) {
				if(oldMap.get(a.id).ffps_accBalance__CalculatedBalance__c != a.ffps_accBalance__CalculatedBalance__c 
					||oldMap.get(a.id).ffps_accBalance__CalculatedCredits__c != a.ffps_accBalance__CalculatedCredits__c 
					|| oldMap.get(a.id).ffps_accBalance__CalculatedDebits__c != a.ffps_accBalance__CalculatedDebits__c 
					|| oldMap.get(a.id).ffps_accBalance__LastBalanceUpdate__c != a.ffps_accBalance__LastBalanceUpdate__c	    		
				)	    	
				{
					system.debug('bg_skipthismutha') ;
					// do nothing - payonomy updte.
				}
                else if( oldMap.get(a.id).Name != a.Name || oldMap.get(a.id).Phone != a.Phone ||
                        oldMap.get(a.id).BillingStreet != a.BillingStreet || oldMap.get(a.id).BillingCity != a.BillingCity ||
                        oldMap.get(a.id).BillingState != a.BillingState || oldMap.get(a.id).BillingPostalCode != a.BillingPostalCode ||
                        oldMap.get(a.id).BillingCountry != a.BillingCountry || oldMap.get(a.id).Website != a.Website ||
                        oldMap.get(a.id).AnnualRevenue != a.AnnualRevenue || oldMap.get(a.id).Billing_Address__c != a.Billing_Address__c ||
                        oldMap.get(a.id).Company_VAT_Number__c != a.Company_VAT_Number__c || oldMap.get(a.id).Company_Registration_Number__c != a.Company_Registration_Number__c ||
                        oldMap.get(a.id).NumberOfEmployees != a.NumberOfEmployees || oldMap.get(a.id).QMS_Sector__c != a.QMS_Sector__c ||
                        oldMap.get(a.id).FM_Fixed_Notes__c != a.FM_Fixed_Notes__c || oldMap.get(a.id).Staff__c != a.Staff__c ||
                        oldMap.get(a.id).TotalNoInternationalOffices__c != a.TotalNoInternationalOffices__c || oldMap.get(a.id).TotalNoUKoffices__c != a.TotalNoUKoffices__c ||
                        oldMap.get(a.id).AccountsEmailAddress__c != a.AccountsEmailAddress__c
                ){
					accIdList.add(a.Id);
				}
			}

			List<Contact> cntList = [SELECT Id FROM Contact where FM_Contact_External_Id__c != null and AccountId in :accIdList];
			if(cntList.size()>0) {

				List<Id> cntIdList = new List<Id>();
				for (Contact c : cntList) {
					cntIdList.add(c.Id);
				}

				//if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())  {				
					bg_FmIntContact.send(bg_FmIntContact.getAction(), bg_FmIntContact.getCntMap(cntIdList).values());
				//}
			}
		}

	}
    
}