/********************************************************************************
* bg_Account_TestUtils :
*
* Utility methods for Account tests
*
* Created By: Jamie Wooley
* Created Date: 11-01-2015 
*
* Changes:
*********************************************************************************/
public with sharing class bg_Account_TestUtils {

    public static Account createQMSAccount(String i, Decimal annualRevenue)
    {
        Map<String,Id> accountTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
        Id QMSRecordTypeId = accountTypes.get(bg_Constants.CITATION_ACCOUNT_RECORDTYPE);
    	return new Account(
    		Name = 'test ' + i,
    		AnnualRevenue = annualRevenue,
    		RecordTypeId = QMSRecordTypeId
    	);
    }

    public static Account createCitationAccount(String i, Decimal annualRevenue)
    {
        Map<String,Id> accountTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
        Id CitationRecordTypeId = accountTypes.get(bg_Constants.CITATION_ACCOUNT_RECORDTYPE);
    	return new Account(
    		Name = 'test ' + i,
    		AnnualRevenue = annualRevenue,
    		RecordTypeId = CitationRecordTypeId
    	);
    }

}