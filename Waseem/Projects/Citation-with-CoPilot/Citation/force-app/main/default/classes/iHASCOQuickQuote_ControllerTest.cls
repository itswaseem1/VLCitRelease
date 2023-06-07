@isTest
public class iHASCOQuickQuote_ControllerTest extends RecordTypeSelector{
    public  static Account acc;
    public  static Opportunity opp;
    public  static Pricebook2 pb;
    public  static SBQQ__Quote__c quote;
    RecordTypeSelector rs=new RecordTypeSelector(); 
    public   Id quoteRecordType = rs.getRecordTypeId(SBQQ__Quote__c.SObjectType, Dataconstants.Quote_iHASCO_RECORDTYPEDEVNAME);
    public  static Contact c;
    public  static Product2 p2;
    public  static Product2 p;
    @testsetup static void setUp(){
        RecordTypeSelector rs=new RecordTypeSelector(); 
        Id oppRecordType = rs.getRecordTypeId(Opportunity.SObjectType, Dataconstants.OPP_iHASCO_RECORDTYPEDEVNAME);
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileId=[SELECT Id FROM Profile WHERE name='System Administrator'].Id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'iHASCOQuickQuote_ControllerTest' ;
        insert iHASCOUser;
        system.runAs(iHASCOUser){
            List<Product2> prd = new List<Product2>();
            Product2 p = new Product2();
            p.Name = '10 Course Access Key';
            p.ProductCode = 'AccessKEY10';
            p.IsActive = true;
            p.SBQQ__SubscriptionType__c = 'Renewable';
            p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            P.SBQQ__BillingFrequency__c ='Annual';
            prd.add(p);
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'iHASCO';
            pb.IsActive = true;
            insert pb;
            Product2 p2 = new Product2();
            p2.Name = DataConstants.USERBASED_PRODUCT;
            p2.ProductCode = 'HUBP';
            p2.IsActive = true;
            p2.SBQQ__SubscriptionType__c = 'Renewable';
            p2.SBQQ__BillingFrequency__c ='Annual';
            prd.add(p2);
            Product2 p3 = new Product2();	
            p3.Name =  '5 Course Access';	
            p3.ProductCode = 'IR-HUBP';	
            p3.IsActive = true;	
            p3.SBQQ__SubscriptionType__c = 'Renewable';	
            p3.SBQQ__BillingFrequency__c ='Annual';	
            prd.add(p3);	
            Product2 p4 = new Product2();	
            p4.Name = DataConstants.OPEN_LICENSE_PRODUCT;	
            p4.ProductCode = 'IR-HUBP';	
            p4.IsActive = true;	
            p4.SBQQ__SubscriptionType__c = 'Renewable';	
            p4.SBQQ__BillingFrequency__c ='Annual';	
            prd.add(p4);	
            Product2 p5 = new Product2();	
            p5.Name = '20 Course Access';	
            p5.ProductCode = 'AccessKEY10';	
            p5.IsActive = true;	
            p5.SBQQ__SubscriptionType__c = 'Renewable';	
            p5.SBQQ__SubscriptionPricing__c = 'Fixed Price';	
            p5.SBQQ__BillingFrequency__c ='Annual';	
            prd.add(p5);
            insert prd;
            List<PricebookEntry> entries = new List<PricebookEntry>();
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p3.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p3.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p2.Id, 1000.0, 0.0, 0.0));
            insert entries; 
            //feature
            SBQQ__ProductFeature__c feature=new SBQQ__ProductFeature__c();
            feature.Name = 'Testing';
            feature.SBQQ__ConfiguredSKU__c = p2.Id;
            feature.SBQQ__Number__c =10;
            feature.SBQQ__MinOptionCount__c =1 ;
            insert feature;
            List<SBQQ__ProductOption__c> prodOptList=new  List<SBQQ__ProductOption__c>();
            SBQQ__ProductOption__c prodOpt=new SBQQ__ProductOption__c();
            prodOpt.SBQQ__OptionalSKU__c = p3.Id;
            prodOpt.SBQQ__ConfiguredSKU__c = p2.Id;
            prodOpt.SBQQ__Number__c = 10;
            prodOpt.SBQQ__Feature__c = feature.Id;
            prodOpt.SBQQ__Type__c ='Related Product';
            prodOptList.add(prodOpt) ;
            SBQQ__ProductOption__c prodOpt1=new SBQQ__ProductOption__c();
            prodOpt1.SBQQ__OptionalSKU__c = p5.Id;
            prodOpt1.SBQQ__ConfiguredSKU__c = p4.Id;
            prodOpt1.SBQQ__Number__c = 10;
            prodOptList.add(prodOpt1) ;
            insert prodOptList;
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
            Site__c acs = new Site__c();
            acs.Account__c = acc.Id;
            acs.City__c = 'test';
            acs.Name = 'test';
            insert acs;
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact';
            c.AccountId = acc.Id;
            c.Phone = '01912553955';
            c.MobilePhone = '70875327792';
            c.Email = 'testcontact@email.com';
            insert c;
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.Deposit_Payment_Method__c = 'Direct Debit';
            opp.RecordTypeId = oppRecordType;
            opp.CloseDate = Date.newInstance(2021, 09, 30);
            opp.StageName = 'In Progress';
            opp.Pricebook2Id = pb.Id;
            opp.Type = 'New Business';
            insert opp;
            OpportunityContactRole oppContRole = new OpportunityContactRole();
            oppContRole.ContactId =c.Id;
            oppContRole.IsPrimary = true;
            oppContRole.OpportunityId = opp.Id;
            insert oppContRole;
        }
    }
    @isTest 
    public static void getProductListOpenLicenseTest(){
        User iHASCOUser =[SELECT Id FROM USER WHERE Division='iHASCO' AND isactive = true AND LastName = 'iHASCOQuickQuote_ControllerTest'  LIMIT 1];
        system.runAs(iHASCOUser){
            List<SBQQ__ProductOption__c> prodOptList=iHASCOQuickQuote_Controller.getProductList(DataConstants.Quote_Open_License);
            system.assertEquals(1,prodOptList.size());
            system.assertEquals('20 Course Access', prodOptList[0].SBQQ__ProductName__c);
        }
    }
    @isTest 
    public static void getProductListUserBasedTest(){
        User iHASCOUser =[SELECT Id FROM USER WHERE Division='iHASCO' and isactive = true AND LastName = 'iHASCOQuickQuote_ControllerTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<SBQQ__ProductOption__c> prodOptList=iHASCOQuickQuote_Controller.getProductList(DataConstants.QUOTE_USER_BASED);
            system.assertEquals('5 Course Access', prodOptList[0].SBQQ__ProductName__c);
        }
    }
    @isTest 
    public static void createQuickQuoteTest(){        
        User iHASCOUser =[SELECT Id FROM USER WHERE Division='iHASCO' and isactive = true AND LastName = 'iHASCOQuickQuote_ControllerTest'  LIMIT 1];
        system.runAs(iHASCOUser){
            String prodName=[SELECT Id,Name FROM Product2 WHERE Name = '5 Course Access' LIMIT 1 ].Name;
            Id oppId=[SELECT Id FROM Opportunity LIMIT 1].Id;
            test.startTest();
            iHASCOQuickQuote_Controller.createQuickQuote(DataConstants.QUOTE_USER_BASED, prodName, '3', '100', oppId);
            test.stopTest();
            List<SBQQ__Quote__c> quote =[SELECT Id,License_Model__c FROM SBQQ__Quote__c ]    ;
            System.assertEquals(1, quote.size());
            System.assertEquals(DataConstants.QUOTE_USER_BASED, quote[0].License_Model__c);
            List<SBQQ__QuoteLine__c> quoteLines =[SELECT Id FROM SBQQ__QuoteLine__c];
            System.assertEquals(2, quoteLines.size());
        }  
    }
}