public with sharing class CIT_PH1_Utility {
	public static String addAccountsFieldToQuery(){
		String queryAddon = '';
        for(Schema.FieldSetMember fieldSetMember : SObjectType.Account.FieldSets.Account_Integration.getFields()) {
            queryAddon += fieldSetMember.getFieldPath() + ', ';
        }
        return queryAddon;
	}
	
	public static String addContactsFieldToQuery(){
		String queryAddon = '';
        for(Schema.FieldSetMember fieldSetMember : SObjectType.Contact.FieldSets.Contact_Integration.getFields()) {
            queryAddon += fieldSetMember.getFieldPath() + ',';
        }
        queryAddon = queryAddon.subString(0, queryAddon.length() - 1);
        return queryAddon;
	
	}
	
	public static String addOpportunityFieldToQuery(){
		String queryAddon = '';
        for(Schema.FieldSetMember fieldSetMember : SObjectType.Opportunity.FieldSets.Opportunity_Integration.getFields()) {
            queryAddon += fieldSetMember.getFieldPath() + ',';
        }
        queryAddon = queryAddon.subString(0, queryAddon.length() - 1);
        return queryAddon;
	
	}
	
	public static String constructInFilterCriteria(Set<Id> Ids){
        String inStatement= '(';
        if(Ids.size() > 0 && Ids.size()==1){
            for(Id id : Ids){
                inStatement += '\'' + id + '\'';
            }
        }else{
            for(Id id : Ids){
                inStatement += '\'' + id + '\'' +',';
            }
            inStatement = inStatement.subString(0, inStatement.length() - 1);
        }
        inStatement += ')';

        return inStatement;
    }
}