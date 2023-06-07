/***********************************************
 *                                              
 *               Unit Tests      
 *               
 * Author: James Garford(BrightGen.com)
 * Created: 05-01-2015
 * Changes: KH 01-10-2017 (CPQ Unit Test Fixes)                                           
 ************************************************/
@isTest
private class bg_AttachFileControllerTest {

	private static testMethod void testControllerSuccess() 
	{       
	    String QUALIFICATION_STAGE_NAME = 'Qualify';

	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;
	    
	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = 'Audit Report';
	    opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	    
	    attachFileController.documentBody = Blob.valueOf('9999oooo');
	    attachFileController.documentName = 'TestDoc'; 
	    attachFileController.upload();
  	} 

	private static testMethod void testControllerFailed1() {       
	    String QUALIFICATION_STAGE_NAME = 'Qualify';
	    
	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;

	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = 'Audit Report';
		opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	    
	    attachFileController.documentBody = Blob.valueOf('9999oooo');
	    attachFileController.upload();
  	}
  
	private static testMethod void testControllerFailed2() {
	    String QUALIFICATION_STAGE_NAME = 'Qualify';
	    
	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;

	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = 'Audit Report';
		opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	
	    attachFileController.documentBody = Blob.valueOf('9999oooo');
	    attachFileController.documentName = 'TestDoc';
	    attachFileController.upload();
  	}
  	
  	private static testMethod void testControllerCancel() {
	    String QUALIFICATION_STAGE_NAME = 'Qualify';

	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;
	    
	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = 'Audit Report';
		opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	
	    attachFileController.documentBody = Blob.valueOf('9999oooo');
	    attachFileController.documentName = 'TestDoc';
	    attachFileController.cancel();
  	}
  	
  	private static testMethod void testControllerFailed3() {
	    String QUALIFICATION_STAGE_NAME = 'Qualify';

	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;

	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = 'Audit Report';
		opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	
	    attachFileController.documentBody = null;
	    attachFileController.documentName = null;
	    
	    attachFileController.upload();
  	}
  	
  	private static testMethod void testControllerFailed4() {
	    String QUALIFICATION_STAGE_NAME = 'Qualify';

	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;
	    
	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = null;
		opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	
	    attachFileController.documentBody = Blob.valueOf('9999oooo');
	    attachFileController.documentName = 'TestDoc';
	    attachFileController.upload();
  	}
    
    private static testMethod void testControllerException() 
	{       
	    String QUALIFICATION_STAGE_NAME = 'Qualify';
        String expMsg = '';

	    Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
		insert pricebook;

	    Account acc = new Account(name='Test1');
	    acc.AnnualRevenue = 75000;
	    insert acc;
	    
	    Opportunity opportunity = new Opportunity();
	    opportunity.CloseDate = date.newinstance(2013, 1, 1); 
	    opportunity.Name = 'TestOpp';
	    opportunity.CloseDate = Date.today();
	    opportunity.StageName = QUALIFICATION_STAGE_NAME;
	    opportunity.Key_Document_Type__c = 'Audit *Report';
	    opportunity.AccountId = acc.Id;
	    insert opportunity;
	     
	    Opportunity opportunitydb = [Select id, Key_Document_Type__c, Audit_Report_Uploaded__c From Opportunity where id = : opportunity.id];     
	    
	    PageReference pageRef = Page.AttachFile;
	    Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id', opportunitydb.id);
	    bg_AttachFileController attachFileController = new bg_AttachFileController(new ApexPages.StandardController(opportunitydb));
	    bg_AttachFileController attachFileController2 = new bg_AttachFileController();
	    
	    attachFileController.documentBody = Blob.valueOf('9999oooo');
	    attachFileController.documentName = 'TestDoc/*-+_'; 
        try{
	    attachFileController.upload();
        } Catch(Exception e){
            expMsg = e.getMessage();
        }
        System.assert(!String.isBlank(expMsg));
  	} 
}