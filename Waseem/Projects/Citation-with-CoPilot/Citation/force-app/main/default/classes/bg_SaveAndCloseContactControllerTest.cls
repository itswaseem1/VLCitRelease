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
private class bg_SaveAndCloseContactControllerTest {

    static testMethod void saveAndCloseSuccess() {
        bg_Unit_Test_Helper.createEchosignCustomSettings();

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;

		Contact theContact = new Contact(); 
		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
		bg_RecordTypeMap  contractRecordTypeMap = new bg_RecordTypeMap('Contract');
		
		Test.StartTest();
	 	
	 	PageReference pageRef = Page.CreateContact;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(theContact);
        ApexPages.currentPage().getParameters().put('accid',Opp1.AccountId);        
	    
	    bg_SaveAndCloseContactController controller = new bg_SaveAndCloseContactController(sc);						
		
		list<Account> theAccount = [Select id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where id = : Opp1.AccountId];
			
		controller.contact.Salutation = 'Mr';
		controller.contact.FirstName = 'Tom';
		controller.contact.LastName = 'Brown';
		controller.contact.Title = 'MD';
		controller.contact.MailingStreet = '22 The Street';
		controller.contact.MailingCity = 'The City';
		controller.contact.MailingState = 'The County';
		controller.contact.MailingCountry = 'The Country';
		controller.contact.MailingPostalCode = 'LS1 8YU';
		controller.contact.Phone = '01132787766';
		controller.contact.MobilePhone = '07656545432';
		
		controller.saveAndClose();
				
		Test.stopTest();
    }
    
    static testMethod void saveAndCloseFailure() {
        bg_Unit_Test_Helper.createEchosignCustomSettings();

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;

		Contact theContact = new Contact(); 
		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
		bg_RecordTypeMap  contractRecordTypeMap = new bg_RecordTypeMap('Contract');
		
		Test.StartTest();
	 	
	 	PageReference pageRef = Page.CreateContact;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(theContact);
        ApexPages.currentPage().getParameters().put('accid',Opp1.AccountId);        
	    
	    bg_SaveAndCloseContactController controller = new bg_SaveAndCloseContactController(sc);						
		
		list<Account> theAccount = [Select id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where id = : Opp1.AccountId];
			
		controller.contact.Salutation = 'Mr';
		controller.contact.FirstName = 'Tom';
		controller.contact.Title = 'MD';
		controller.contact.MailingStreet = '22 The Street';
		controller.contact.MailingCity = 'The City';
		controller.contact.MailingState = 'The County';
		controller.contact.MailingCountry = 'The Country';
		controller.contact.MailingPostalCode = 'LS1 8YU';
		controller.contact.Phone = '01132787766';
		controller.contact.MobilePhone = '07656545432';
		
		controller.saveAndClose();
				
		Test.stopTest();
    }
    
    static testMethod void cancel() {
        bg_Unit_Test_Helper.createEchosignCustomSettings();

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;
		
		Contact theContact = new Contact(); 
		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
		bg_RecordTypeMap  contractRecordTypeMap = new bg_RecordTypeMap('Contract');
		
		Test.StartTest();
	 	
	 	PageReference pageRef = Page.CreateContact;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(theContact);
        ApexPages.currentPage().getParameters().put('accid',Opp1.AccountId);        
	    
	    bg_SaveAndCloseContactController controller = new bg_SaveAndCloseContactController(sc);						
		
		list<Account> theAccount = [Select id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where id = : Opp1.AccountId];
			
		controller.contact.Salutation = 'Mr';
		controller.contact.FirstName = 'Tom';
		controller.contact.LastName = 'Brown';
		controller.contact.Title = 'MD';
		controller.contact.MailingStreet = '22 The Street';
		controller.contact.MailingCity = 'The City';
		controller.contact.MailingState = 'The County';
		controller.contact.MailingCountry = 'The Country';
		controller.contact.MailingPostalCode = 'LS1 8YU';
		controller.contact.Phone = '01132787766';
		controller.contact.MobilePhone = '07656545432';
		
		controller.cancel();
		
		Test.stopTest();
    }
}