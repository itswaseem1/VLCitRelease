/********************************************************************************
* bg_Opportunity_TestUtils :
*
* Utility methods for Opportunity tests
*
* Created By: Jamie Wooley
* Created Date: 11-01-2015 
*
* Changes: MF 19-04-2017 -  Term added to the QMS opportunity creation method 
*                           as a default and an override for testing with different terms.
*********************************************************************************/
public with sharing class bg_Opportunity_TestUtils {

    public static Opportunity createQMSOpportunity(String i, Id accountId, Boolean sameStandard, Integer numberOfSites)
    {
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSRecordTypeId = opportunityTypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);
        return new Opportunity(
            Name = 'test ' + i,
            RecordTypeId = QMSRecordTypeId,
            AccountId = accountId,
            StageName = bg_Constants.OPPORTUNITY_STAGE_QUOTEDQMS,
            CloseDate = Date.Today() + 5,
            Same_Standard_On_All_Sites__c = sameStandard,
            Sites__c = numberOfSites,
            Contract_Length_Years__c = 10,
            Deposit_Payment_Method__c = 'Credit Card',
            Term__c = '5'
        );
    }

    public static Opportunity createQMSOpportunity(String i, Id accountId, Boolean sameStandard, Integer numberOfSites, String termValue)
    {
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSRecordTypeId = opportunityTypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);
        return new Opportunity(
            Name = 'test ' + i,
            RecordTypeId = QMSRecordTypeId,
            AccountId = accountId,
            StageName = bg_Constants.OPPORTUNITY_STAGE_QUOTEDQMS,
            CloseDate = Date.Today() + 5,
            Same_Standard_On_All_Sites__c = sameStandard,
            Sites__c = numberOfSites,
            Contract_Length_Years__c = 10,
            Deposit_Payment_Method__c = 'Credit Card',
            Term__c = termValue
        );
    }

    public static Opportunity createDefaultCitationOpportunity(String i, Id accountId, Boolean sameStandard, Integer numberOfSites)
    {
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id citationRecordTypeId = opportunityTypes.get(bg_Constants.CITATION_OPPORTUNITY_RECORDTYPE);
        return new Opportunity(
            Name = 'test ' + i,
            RecordTypeId = citationRecordTypeId,
            AccountId = accountId,
            StageName = bg_Constants.OPPORTUNITY_STAGE_QUOTEDQMS,
            CloseDate = Date.Today() + 5,
            Same_Standard_On_All_Sites__c = sameStandard,
            Sites__c = numberOfSites,
            Contract_Length_Years__c = 10,
            Deposit_Payment_Method__c = 'Credit Card'
        );
    }

}