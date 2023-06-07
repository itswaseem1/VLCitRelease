/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public with sharing class CIT_PH1_LeadIntegration_Test {

    @isTest
    static void LeadIntegration_ConvertLead_isLeadConverted(){
        //http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_dml_convertLead.htm
        CWS_Integration__c integrationSetting = CWS_Integration__c.getValues('Host');
  
            if(integrationSetting == null) {
                integrationSetting = new CWS_Integration__c(Name= 'Host');
                integrationSetting.RemoteServer__c = 'Test';
                insert integrationSetting;
            }
        CIT_PH1_HTTPManager.isApexTest = true;
        Lead myLead = new Lead(LastName = 'Fry', Company='Fry And Sons', MADE_Criteria__c = 'Outbound - 1', AnnualRevenue = 100000, Appointment_Type__c = 'Combined', Approved_By_User__c = UserInfo.getUserId(), Approved_Date__c = Date.today(), Date_Made__c = Date.today(), Sector__c = 'ACCOMODATION', CitationSector__c = 'ACCOMMODATION', email='chriscoates@citation.co.uk');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Citation Partner Referral').getRecordTypeId();
        myLead.RecordTypeId = devRecordTypeId;
        insert myLead;

        myLead = [select id, RecordTypeId from lead];

        System.assertEquals(devRecordTypeId, myLead.RecordTypeId);

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
        insert pricebook;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(myLead.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }
}