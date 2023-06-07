/*********************************************************************************
 * bg_Opportunity_QueueableHelper
 *
 * Helper class for queuing the Opportunity clone.
 *
 * Author: Jamie Wooley
 * Created: 21-01-2016
 * Changes: 
 *
 *********************************************************************************/

public without sharing class bg_Opportunity_QueueableHelper implements Queueable {
    private List<Opportunity> opps = new List<Opportunity>();
    public bg_Opportunity_QueueableHelper(List<Opportunity> oppsIn) {
        this.opps = oppsIn;
    }
    public void execute(QueueableContext context) {
    	List<Opportunity> Renewals = new List<Opportunity>();
    	User renewalOwner = [select Id from User where QMS_Renewals_Owner__c = true limit 1];
        for (Opportunity opp : opps)
        {
			Opportunity renewal = opp.clone(false, true, false, false);
			renewal.SyncedQuoteId = null;
			renewal.Ready_For_Renewal__c = False;
			renewal.StageName = bg_Constants.OPPORUNITY_STAGE_RENEWALDUE;
			renewal.Name = opp.Name + ' - ' + bg_Constants.RENEWAL_OPPORTUNITY_TYPE;
			renewal.Probability = 25;
			renewal.Type = bg_Constants.RENEWAL_OPPORTUNITY_TYPE;
			renewal.Parent_Opportunity__c = opp.Id;
			renewal.Contract_End_Date__c = opp.Contract_End_Date__c.addYears(integer.valueOf(opp.Contract_Length_Years__c));
			renewal.Accepted_Quote__c = false;
			renewal.New_Service_Form_Returned__c = false;
			renewal.Contract_Signed__c = false;
			renewal.OwnerId = renewalOwner.Id;
			renewal.FM_Opportunity_External_Id__c = null;
			renewal.Deposit_Received__c = false;
			renewal.New_Service_Form_Returned_Date__c = null;
			renewal.ECHO_Customer_Signed_Date__c = null;
			renewal.Sale_Approved__c = false;
			renewal.Sale_Approved_Date__c = null;
			renewal.Amount = null;
			renewal.Deposit__c = null;
			Renewals.add(renewal);
        }
        if (!Renewals.isEmpty())
		{
			insert Renewals; 
		
		}
    }
}