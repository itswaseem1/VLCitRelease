@isTest
public class DuplicateiHASCOProspectBatchTest {
	
	@testsetup 
	static void setUp(){
		Id iHASCOLeadRecordType=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(DataConstants.LEAD_iHASCO_RECORDTYPENAME).getRecordTypeId();
	   
		Lead ld = new Lead();
		ld.RecordTypeId = iHASCOLeadRecordType;
		ld.LeadSource = 'Email Marketing';
		ld.utm_campaign__c = 'Test';
		ld.utm_keyword__c = 'Test';
		ld.utm_medium__c= 'Test';
		ld.Prospect_Channel__c = 'Marketing';
		ld.Notes__c = 'Test'; 
		ld.Email = 'Test@test.com';
		ld.LastName = 'Test';
		ld.Company = 'Testcomp';
        ld.leadSource='Website';
		insert ld;
		
		Account acc = new Account();
		acc.Name = 'Test Acc';
		acc.BillingStreet = 'Harvey street';
		acc.BillingCity = 'Manchester';
		acc.BillingCountry = 'England';
		acc.BillingPostalCode = 'NXJ001';
		acc.Sites__c = 5.0;
		acc.FT_Employees__c = 20.0;
		acc.PT_Employees__c = 10.0;
		acc.iHASCO_Finance_Status__c = 'Active';
		acc.SBQQ__RenewalModel__c = 'Contract Based';
		acc.iHASCO_Client__c = True ;
		insert acc;         
		
		Contact contact = new Contact();
		contact.FirstName = 'Test';
		contact.LastName = 'Contact';
		contact.Phone = '01912553955';
		contact.MobilePhone = '70875327792';
		contact.Email = 'Test@test.com';
		insert contact;
		
	}
	
	@isTest
	public static void givenLeadDetails_WheniHASCOLead_ThenJobScheduled()
	{
		
		Test.startTest();
		Id jobId=System.Schedule('HSDRenewalOpportunityEmail Batch : at 00 mins', '0 0 * * * ?', new DuplicateiHASCOProspectBatch());         
		Test.stopTest();  
		
		CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
		System.assertEquals('0 0 * * * ?',ct.CronExpression);
	}
		
	@isTest
	public static void givenLeadDetails_WheniHASCOLead_Bulkification_ThenJobScheduled()
	{
	   TestDataFactory.getLeads(5,'DuplicateLead','TestCompany',True);
		Test.startTest();
		Id jobId=System.Schedule('HSDRenewalOpportunityEmail Batch : at 00 mins', '0 0 * * * ?', new DuplicateiHASCOProspectBatch());         
		Test.stopTest();  
		
		CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
		System.assertEquals('0 0 * * * ?',ct.CronExpression);
	}
}