@isTest
public class TriggerLeadHandlerTest {
    @isTest static void checkiHascoLeadInsertTaskCreation()
    { 
        String iHascoLeadRTID=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Default_IHASCO').getRecordTypeId();
        TriggerLeadHandler.ihascoIntegrationusers = new Set<String>{UserInfo.getUserId()};

        Lead ld = new Lead();
        ld.RecordTypeId = iHascoLeadRTID;
        ld.LeadSource = 'Email Marketing';
        ld.utm_campaign__c = 'Test';
        ld.utm_keyword__c = 'Test';
        ld.utm_medium__c= 'Test';
        ld.Prospect_Channel__c = 'Marketing';
        ld.Notes__c = 'Test'; 
        ld.Email = 'Test@test.com';
        ld.LastName = 'Test';
        ld.Company = 'Testcomp';
        insert ld;

        System.assertEquals(1, [SELECT ID FROM Task].size());
    }
}