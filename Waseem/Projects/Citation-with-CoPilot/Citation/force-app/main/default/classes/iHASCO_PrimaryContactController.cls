public class iHASCO_PrimaryContactController {
    @AuraEnabled(cacheable=true)
    Public Static List<Contact> getPrimaryContact(String accountId){
        set<id> contIds= new set<id>();
        set<id> OppIds = new set<id>();
        for(contract contr:[SELECT Id,Source_Opportunity__c FROM Contract 
                            WHERE AccountId =: accountId AND Status =:Dataconstants.CONTRACT_STATUS_ACTIVE]){
            OppIds.add(contr.Source_Opportunity__c);
        }
        for(OpportunityContactRole opr:[SELECT Id,contact.Name,ContactId FROM OpportunityContactRole 
			   						    WHERE OpportunityId IN : OppIds AND  isPrimary = TRUE])
        {
            contIds.add(opr.ContactId);
        }
        return [SELECT Id,Name,Phone,Email FROM Contact WHERE id IN:contIds ];
    }


}