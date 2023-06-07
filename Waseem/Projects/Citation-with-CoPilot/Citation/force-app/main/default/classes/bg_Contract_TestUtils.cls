/********************************************************************************
* bg_Contract_TestUtils :
*
* Utility methods for contract tests
*
* Created By: Jamie Wooley
* Created Date: 24-05-2016
*
* Changes:
*********************************************************************************/
public with sharing class bg_Contract_TestUtils {

    public static Contract createContract(String i, Id accountId)
    {
        Map<String,Id> contractTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Contract.SObjectType);
        Id RecordTypeId = contractTypes.get(bg_Constants.STANDARD_CONTRACT_RECORDTYPE);
    	return new Contract(
    		AccountId = accountId,
    		Name = 'test ' + i,
    		RecordTypeId = RecordTypeId,
    		StartDate = Date.Today(),
    		ContractTerm = 12,
    		FOC_Period_Mths__c = 1,
    		FOC_Period_Mths_End__c = 12,
    		Service_Type__c = 'Citation',
    		Status = 'Draft',
    		Renewal_Type__c = 'Non-Auto',
    		Business_Type__c = 'New Business',
    		Contract_Value__c = 10000,
    		Payment_Period__c = 'monthly',
    		Preferred_Payment_Date__c = '7'
    	);
    }

}