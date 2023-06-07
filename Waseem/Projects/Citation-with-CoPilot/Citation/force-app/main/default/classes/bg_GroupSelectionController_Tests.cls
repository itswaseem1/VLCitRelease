/********************************************************************
* bg_GroupSelectionController_Tests:
*
* Test class for the Group Selection page, allows the user to 
* select the Option/Group of Products the customer would like to purchase
*
* Created By: Kash Hussain (BrightGen)
* Created Date: 20-05-2017 
*
* Changes:
********************************************************************/

@isTest
private class bg_GroupSelectionController_Tests
{    
    //public Product2 combinedProduct {get;set;}

 @testSetup static void setup() {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;

        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        insert combinedProduct;

        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
		
     	Pricebook2 price = new Pricebook2();
        price.Name = 'QMS CPQ';
        price.IsActive = true;
        insert price;
        Opportunity testOpportunity = createOpportunity('TestOpp', null, testAccount);

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
		testQuote.SBQQ__Opportunity2__c = testOpportunity.Id;
		testQuote.SBQQ__Status__c = 'Draft';
		testQuote.SBQQ__Type__c = 'Quote';
		insert testQuote;

        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = testQuote.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = combinedProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = testQuote.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        insert quoteLine;
 }

 @isTest static void testAutoGroupSelection()
	{
        SBQQ__Quote__c testQuote = [select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Status__c from SBQQ__Quote__c limit 1] ;

        PageReference customContractPage = Page.bg_GroupSelection;
        Test.setCurrentPage(customContractPage);       
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);        

        test.startTest();

        bg_GroupSelectionController testController = new bg_GroupSelectionController(sc);
       
        test.stopTest();

        system.assertEquals(true,testController.groupOptions[0].Selected) ;      
      
	}

     @isTest static void testNoAutoSelectMultiGroup()
	{       
        SBQQ__Quote__c testQuote = [select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Status__c from SBQQ__Quote__c limit 1] ;

        SBQQ__QuoteLineGroup__c testGroup1 = new SBQQ__QuoteLineGroup__c();
        testGroup1.Name = 'Testy1';
        testGroup1.SBQQ__Quote__c = testQuote.Id;
        testGroup1.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup1;

        PageReference customContractPage = Page.bg_GroupSelection;
        Test.setCurrentPage(customContractPage);
       
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);        

        test.startTest();

        bg_GroupSelectionController testController = new bg_GroupSelectionController(sc);
       
        test.stopTest();

        system.assertEquals(false,testController.groupOptions[0].Selected) ;
        system.assertEquals(false,testController.groupOptions[1].Selected) ;   
	}



    @isTest static void testBasicControllerProperties()
	{
        SBQQ__Quote__c testQuote = [select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Status__c from SBQQ__Quote__c limit 1] ;

        PageReference customContractPage = Page.bg_GroupSelection;
        Test.setCurrentPage(customContractPage);
       
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        bg_GroupSelectionController testController = new bg_GroupSelectionController(sc);
		SBQQ__QuoteTemplate__c sbtop = new SBQQ__QuoteTemplate__c();
        sbtop.Business_Type__c = 'CitationBDM';
        sbtop.Template_Type__c = 'Contract';
        test.startTest();
        insert sbtop;
        testController.groupOptions[0].Selected = true;
        testController.quickSave();
        testController.calculateProposedInitialPayment();
        testController.save();
        test.stopTest();
        
        sbqq__quote__c q = [select id,Initial_Payment__c from sbqq__quote__c where id = :testQuote.id] ;        
      
        system.debug(testController.calculatedInitialPayment) ;      
	}
    
    @isTest static void insertingQuoteTemplate(){
        SBQQ__QuoteTemplate__c sbqq = new SBQQ__QuoteTemplate__c();
        sbqq.Name = 'Citation Template';
        sbqq.SBQQ__DeploymentStatus__c = 'Deployed';
        sbqq.Business_Type__c = 'CitationBDM';
        sbqq.Template_Type__c = 'Contract';
        insert sbqq; 
    }

    @isTest static void testBasicControllerOptional()
    {   
        SBQQ__Quote__c testQuote = [select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Status__c from SBQQ__Quote__c limit 1] ;

        PageReference customContractPage = Page.bg_GroupSelection;
        Test.setCurrentPage(customContractPage);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        bg_GroupSelectionController testController = new bg_GroupSelectionController(sc);
        SBQQ__QuoteTemplate__c sbt = new SBQQ__QuoteTemplate__c();
        sbt.Business_Type__c = 'CitationBDM';
        sbt.Template_Type__c = 'Contract';
        test.startTest();
        insert sbt;
        testController.save();
        testController.groupOptions[0].Selected = true;
        test.stopTest();
    }

    @isTest static void testNoGroupSelected()
    {   
        SBQQ__Quote__c testQuote = [select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Status__c from SBQQ__Quote__c limit 1] ;

        SBQQ__QuoteLineGroup__c testGroup1 = new SBQQ__QuoteLineGroup__c();
        testGroup1.Name = 'Testy1';
        testGroup1.SBQQ__Quote__c = testQuote.Id;
        testGroup1.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup1;

        PageReference customContractPage = Page.bg_GroupSelection;
        Test.setCurrentPage(customContractPage);
       
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        bg_GroupSelectionController testController = new bg_GroupSelectionController(sc);
        
        test.startTest();
        testController.save();  
           
        test.stopTest();
       
        system.assertequals(false,testController.AGroupIsSelected);

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean groupError = false;
        string GroupErrorMessage = System.label.CPQ_Group_Selection_Error;

        for(Apexpages.Message msg:msgs){
            if (msg.getDetail()==GroupErrorMessage) groupError = true;
        }
        system.assert(groupError);
    }


	private static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc)
    {
        bg_RecordTypeMap opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');         
        Opportunity o = new Opportunity();
        o.Name = opportunityName;
        if (recordtype == 'Default Citation Opportunity') {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Default Citation Opportunity'); 
        } else {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Small Business Package');
        } 
        o.AccountId = acc.id;
        o.Type = 'New Business';
        o.CloseDate = system.now().addMonths(1).date();
        o.Deal_Type__c = 'Combined';
        o.StageName = 'Provisional Approval';

        insert(o);
        return o;
    }

    private static Account createAccount(String accName, String sector, Decimal fullTimeEmployees, Decimal partTimeEmployees)
    {
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
        
        insert acc;
        return acc;     
    }
}