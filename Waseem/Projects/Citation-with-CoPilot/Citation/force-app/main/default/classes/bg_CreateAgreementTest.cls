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
private class bg_CreateAgreementTest {

    static testMethod void CreateAgreementSuccessfulCallout() {
	
		bg_Unit_Test_Helper.createEchosignCustomSettings();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;
		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
		bg_RecordTypeMap  contractRecordTypeMap = new bg_RecordTypeMap('Contract');
		
		Test.StartTest();
	 	
	 	PageReference pageRef = Page.CreateAgreement;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Opp1);
        ApexPages.currentPage().getParameters().put('Id',Opp1.id);        

		bg_CreateAgreement controller = new bg_CreateAgreement(sc);		
		//Test that all values have been padded through correctly
		System.assertEquals(controller.contract.Name, controller.opportunity.Name);
		System.assertEquals(controller.contract.StartDate, controller.opportunity.Deal_Start_Date__c);
		System.assertEquals(controller.contract.ContractTerm, Integer.valueOf(controller.opportunity.Contract_Length_Mths__c));
		System.assertEquals(controller.contract.AccountId, controller.account.id);
		System.assertEquals(controller.contract.Source_Opportunity__c, controller.opportunity.id);
		System.assertEquals(controller.contract.Business_Type__c, controller.opportunity.Type);
		System.assertEquals(controller.contract.total_Contract_Value__c, controller.opportunity.Amount);
		System.assertEquals(controller.contract.Contract_Value__c, controller.opportunity.Core_Compliance_TCV__c);

        System.assertEquals(controller.contract.Payment_Period__c, controller.opportunity.Payment_Period__c);
		System.assertEquals(controller.contract.CompanySigned, controller.opportunity.Owner);
		System.assertEquals(controller.contract.Initial_Payment2__c, controller.opportunity.Deposit__c);
		System.assertEquals(controller.contract.Affinity__c, controller.opportunity.Affinity_Industry_Type__c);
		System.assertEquals(controller.contract.Renewal_Type__c, 'Auto');		
		System.assertEquals(controller.contract.Agreement_Type__c, 'EchoSign');
				
		controller.account.FT_Employees__c = 20;
		controller.account.Payroll_Amt__c = 1000;
		controller.account.Subcontractors__c = 0;
		controller.account.PT_Employees__c = 2000;
		controller.account.Directors__c = 4;
		controller.account.Sites__c = 1;		
		controller.contract.FOC_Period_Mths__c = 1;
		controller.contract.FOC_Period_Mths_End__c = 2;
		controller.contract.Initial_Payment2__c = 200;
		controller.contract.Initial_Payment_Date__c = System.now().addDays(2).date();
		controller.contract.CompanySignedId = Opp1.OwnerId;   
		controller.contract.CustomerSignedId = bg_Unit_Test_Helper.createContact('CAT1','User1', Opp1.AccountId).Id;
		controller.contract.CustomerSignedTitle = 'Test';		
		controller.contract.Service_Type__c = 'Citation';
		controller.contract.Agreement_Template_Type__c = 'Combined';
		controller.contract.Second_Signatory_Required__c = 'No';
		controller.contract.Finance_Notes__c = 'Testing Financial Notes';
		controller.createAgreement();
		
		// Make sure that a standard contract type was created.
		System.assertEquals(controller.contract.RecordTypeId , contractRecordTypeMap.getIdFromName('Standard Contract'));
		
		Test.stopTest();
    }
    
    static testMethod void CreateAgreementFailedToFindTemplate() {
	
		bg_Unit_Test_Helper.createEchosignCustomSettings();
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;

		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
	 	PageReference pageRef = Page.CreateAgreement;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Opp1);
        ApexPages.currentPage().getParameters().put('Id',Opp1.id);
		
		Test.StartTest();

		//set the field name to an invalid format
		bg_Unit_Test_Helper.updateEchosignCustomSettingsFieldName('Create Agreement SBP - 1c', 'RecordTypeId');
		bg_Unit_Test_Helper.updateEchosignCustomSettingsFieldValue('Create Agreement SBP - 1c', 'BobOn');
		
		bg_CreateAgreement controller = new bg_CreateAgreement(sc);
		
		controller.account.FT_Employees__c = 20;
		controller.account.Payroll_Amt__c = 1000;
		controller.account.Subcontractors__c = 0;
		controller.account.PT_Employees__c = 2000;
		controller.account.Directors__c = 4;
		controller.account.Sites__c = 1;
		
		controller.contract.FOC_Period_Mths__c = 1;
		controller.contract.FOC_Period_Mths_End__c = 2;
		controller.contract.Initial_Payment2__c = 200;
		controller.contract.Initial_Payment_Date__c = System.now().addDays(2).date();
		controller.contract.CompanySignedId = Opp1.OwnerId;   
		controller.contract.CustomerSignedId = bg_Unit_Test_Helper.createContact('CAT1','User1', Opp1.AccountId).Id;
		controller.contract.CustomerSignedTitle = 'Test';		
		controller.contract.Service_Type__c = 'Citation';
		controller.contract.Agreement_Template_Type__c = 'Combined';
		controller.contract.Second_Signatory_Required__c = 'No';
		controller.contract.Finance_Notes__c = 'Testing Financial Notes';		
		controller.createAgreement();
		
		// get the list of ApexPages.Message
		List<ApexPages.Message> msgList = ApexPages.getMessages();
		system.debug('Create Agreement Failed To Find Template Page Message ['+msgList+']');
		// or loop over the messages
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
		    System.assertEquals('No EchoSign templates have been identified for the Contract criteria provided', msg.getSummary());
		    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
		}
		
		Test.stopTest();
    }
    
    static testMethod void CreateAgreementFoundTwoTemplates() {
	
		bg_Unit_Test_Helper.createEchosignCustomSettings();
		
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;
		
		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
	 	PageReference pageRef = Page.CreateAgreement;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Opp1);
        ApexPages.currentPage().getParameters().put('Id',Opp1.id);
		bg_CreateAgreement controller = new bg_CreateAgreement(sc);
		
		controller.account.FT_Employees__c = 20;
		controller.account.Payroll_Amt__c = 1000;
		controller.account.Subcontractors__c = 0;
		controller.account.PT_Employees__c = 2000;
		controller.account.Directors__c = 4;
		controller.account.Sites__c = 1;
		
		controller.contract.FOC_Period_Mths__c = 1;
		controller.contract.FOC_Period_Mths_End__c = 2;
		controller.contract.Initial_Payment2__c = 200;
		controller.contract.Initial_Payment_Date__c = System.now().addDays(2).date();
		controller.contract.CompanySignedId = Opp1.OwnerId;   
		controller.contract.CustomerSignedId = bg_Unit_Test_Helper.createContact('CAT1','User1', Opp1.AccountId).Id;
		controller.contract.CustomerSignedTitle = 'Test';		
		controller.contract.Service_Type__c = 'Citation';
		controller.contract.Agreement_Template_Type__c = 'Combined';
		controller.contract.Second_Signatory_Required__c = 'No';
		controller.contract.Finance_Notes__c = 'Testing Financial Notes';		
		controller.createAgreement();
		
		Test.StartTest();
		
	    //set the field name to an invalid format
		bg_Unit_Test_Helper.updateEchosignCustomSettingsFieldValue('Create Agreement SBP - 2a', 'No');
		
		// get the list of ApexPages.Message
		List<ApexPages.Message> msgList = ApexPages.getMessages();
		
		system.debug('Create Agreement Found Two Templates Page Message ['+msgList+']');
		
		// or loop over the messages
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
		    System.assertEquals('More that one EchoSign template has been identified for the Contract criteria provided'+ ' [' + controller.templateIdsToUse + ']', msg.getSummary());
		    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
		}
		
		Test.stopTest();
    }
    
    static testMethod void CreateAgreementFailureOnMandatoryFields() {
	
		bg_Unit_Test_Helper.createEchosignCustomSettings();

		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
		insert pricebook;
		
		//set the field name to an invalid format		
		Opportunity Opp1 = bg_Unit_Test_Helper.createDefaultCitationOpportunity('Provisional Agreement');
		
	 	PageReference pageRef = Page.CreateAgreement;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Opp1);
        ApexPages.currentPage().getParameters().put('Id',Opp1.id);
		bg_CreateAgreement controller = new bg_CreateAgreement(sc);
		
		controller.account.FT_Employees__c = null;
		controller.account.Payroll_Amt__c = 1000;
		controller.account.Subcontractors__c = 0;
		controller.account.PT_Employees__c = 2000;
		controller.account.Directors__c = 4;
		controller.account.Sites__c = 1;
		
		controller.contract.FOC_Period_Mths__c = 1;
		controller.contract.FOC_Period_Mths_End__c = 2;
		controller.contract.Initial_Payment2__c = 200;
		controller.contract.Initial_Payment_Date__c = System.now().addDays(2).date();
		controller.contract.CompanySignedId = Opp1.OwnerId;   
		controller.contract.CustomerSignedId = bg_Unit_Test_Helper.createContact('CAT1','User1', Opp1.AccountId).Id;
		controller.contract.CustomerSignedTitle = 'Test';		
		controller.contract.Service_Type__c = 'Citation';
		controller.contract.Agreement_Template_Type__c = 'Combined';
		controller.contract.Second_Signatory_Required__c = 'No';
		controller.contract.Finance_Notes__c = 'Testing Financial Notes';		
		controller.createAgreement();
		
		Test.StartTest();
		
		// get the list of ApexPages.Message
		List<ApexPages.Message> msgList = ApexPages.getMessages();
		
		system.debug('Create Agreement Failure On Mandatory Fields Page Message ['+msgList+']');
		
		// or loop over the messages
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
		    System.assertEquals('No. of sites, no. of full/part time employees ALL need to be populated on the Account to allow the save of this record', msg.getSummary());
		    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
		}
		
		Test.stopTest();
    }
    
}