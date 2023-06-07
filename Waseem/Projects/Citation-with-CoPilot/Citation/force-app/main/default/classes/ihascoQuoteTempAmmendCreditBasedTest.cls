@isTest
public class ihascoQuoteTempAmmendCreditBasedTest {
private static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default IHASCO';
    private static final Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    private static final Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    private  static Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    private  static Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
  
    
    @testsetup static void setUp(){
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ihascoQuoteTempAmmendCreditBasedTest'; 
        insert iHASCOUser;
        
        system.runAs(iHASCOUser){
        
        PermissionSetLicense psl = [select id,DeveloperName from PermissionSetLicense where DeveloperName ='SalesforceCPQ_CPQStandardPerm'];
        PermissionSetLicenseAssign psla = new PermissionSetLicenseAssign();
        psla.AssigneeId     = iHASCOUser.id;
        psla.PermissionSetLicenseId  = psl.id;
        insert psla;
           
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Label = 'Salesforce CPQ User' LIMIT 1];
        PermissionSetAssignment  psa1 = new PermissionSetAssignment();
        psa1.PermissionSetId         = ps1.id; 
        psa1.AssigneeId              = iHASCOUser.id;
        insert psa1;

        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Label = 'Add Product for iHASCO' LIMIT 1];
        PermissionSetAssignment  psa2 = new PermissionSetAssignment();
        psa2.PermissionSetId         = ps2.id; 
        psa2.AssigneeId              = iHASCOUser.id;
        insert psa2;

        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Label = 'ihasco Permission Set' LIMIT 1];
        PermissionSetAssignment  psa3 = new PermissionSetAssignment();
        psa3.PermissionSetId         = ps3.id; 
        psa3.AssigneeId              = iHASCOUser.id;
        insert psa3;
        
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Label = 'Citation Salesforce CPQ User' LIMIT 1];
        PermissionSetAssignment  psa4 = new PermissionSetAssignment();
        psa4.PermissionSetId         = ps4.id; 
        psa4.AssigneeId              = iHASCOUser.id;
        insert psa4;

        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Label = 'Salesforce 360 General' LIMIT 1];
        PermissionSetAssignment  psa5 = new PermissionSetAssignment();
        psa5.PermissionSetId         = ps5.id; 
        psa5.AssigneeId              = iHASCOUser.id;
        insert psa5;

        List<Product2> prd = new List<Product2>();
        Product2 p = new Product2();
        p.Name = '10 Course Access';
        p.ProductCode = 'AccessKEY10';
        p.IsActive = True;
        p.SBQQ__SubscriptionType__c = 'Renewable';
        p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        P.SBQQ__BillingFrequency__c ='Annual';
        prd.add(p);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'iHASCO';
        pb.IsActive = True;
        insert pb;

        Product2 p2 = new Product2();
        p2.Name = 'Open License Pricing';
        p2.ProductCode = 'HUBP';
        p2.IsActive = True;
        p2.SBQQ__SubscriptionType__c = 'Renewable';
        p2.SBQQ__BillingFrequency__c ='Annual';
        prd.add(p2);
            
        Product2 p3 = new Product2();
        p3.Name = 'Open License Credits';
        p3.ProductCode = 'IHCR';
        p3.IsActive = True;
        p3.SBQQ__SubscriptionType__c = 'Renewable';
        p3.SBQQ__BillingFrequency__c ='Annual';
        prd.add(p3);
        
        Product2 p4 = new Product2();
        p4.Name = 'Ihasco Plus';
        p4.ProductCode = 'IPlus';
        p4.IsActive = True;
        p4.SBQQ__SubscriptionType__c = 'Renewable';
        p4.SBQQ__BillingFrequency__c ='Annual';
        prd.add(p4);
        
        Product2 p5 = new Product2();
        p5.Name = '20 Course Access';
        p5.ProductCode = 'AccessKEY20';
        p5.IsActive = True;
        p5.SBQQ__SubscriptionType__c = 'Renewable';
        p5.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        P5.SBQQ__BillingFrequency__c ='Annual';
        prd.add(p5);    

        insert prd;
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p2.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p3.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p3.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p4.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p4.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p5.Id, 1000.0, 0.0, 0.0));
        entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p5.Id, 1000.0, 0.0, 0.0));
        insert entries;
        
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
        insert acc;
        
        Site__c acs = new Site__c();
        acs.Account__c = acc.id;
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
        opp.AccountId = acc.id;
        opp.Deposit_Payment_Method__c = 'Direct Debit';
        opp.RecordTypeId = oppRecordType;
        opp.CloseDate = Date.newInstance(2021, 09, 30);
        opp.StageName = 'In Progress';
        opp.Pricebook2Id = pb.id;
        opp.Type = 'New Business';
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = quoteRecordType;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__Primary__c = true;
        quote.Payment_Method__c = 'Invoice';
        quote.iHASCO_Payment_Terms__c = '30 Days';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__PrimaryContact__c = c.id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.Preferred_Payment_Date__c = '7';
        quote.SBQQ__PriceBook__c = pb.Id;
        quote.Initial_Payment_Date__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 36;
        quote.License_Model__c = 'User Based';
        quote.PO_reference__c = '1234';
        quote.Quote_type__c = 'New Business';
        insert quote;
        
        //quote group with subscrption
        SBQQ__QuoteLineGroup__c quoteTGrp1 = new SBQQ__QuoteLineGroup__c();
        quoteTGrp1.name = 'Group 1';
        quoteTGrp1.SBQQ__Quote__c = quote.id;
        quoteTGrp1.SBQQ__SubscriptionTerm__c = 36;
        insert quoteTGrp1;
            
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Product__c = p2.Id;
        ql.SBQQ__Quantity__c = 1;
        ql.SBQQ__Quote__c = quote.Id;
        ql.SBQQ__StartDate__c = Date.today();
        ql.SBQQ__EndDate__c = Date.today().addYears(3);
        ql.Service_Start_Date__c = Date.today();
        ql.Billing_Frequency__c = 'Annual';
        ql.SBQQ__BillingFrequency__c = 'Annual';
        ql.SBQQ__ListPrice__c = 0;
        ql.SBQQ__SubscriptionTerm__c = 36 ;
        ql.FOC_Period__c = 'Start';
        ql.SBQQ__Group__c = quoteTGrp1.id;
        ql.initial_payment__c = 0;
        ql.Ihasco_Term__c = '3';    
        ql.iHasco_Subscription_Term__c = 36;
        ql.SBQQ__DefaultSubscriptionTerm__c = 36;
        ql.SBQQ__RegularPrice__c  = 0;
        quoteLines.add(ql);
        
        test.startTest();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Product__c = p.Id;
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Discount__c = 10;
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.SBQQ__StartDate__c = Date.today();
        ql1.SBQQ__EndDate__c = Date.today().addYears(3);
        ql1.Service_Start_Date__c = Date.today();
        ql1.SBQQ__RequiredBy__c = ql.id;
        ql1.Billing_Frequency__c = 'Annual';
        ql1.SBQQ__BillingFrequency__c = 'Annual';
        ql1.SBQQ__NetPrice__c = 1200;
        ql.SBQQ__ListPrice__c = 400;
        ql1.SBQQ__SubscriptionTerm__c = 36;
        ql1.SBQQ__PricebookEntryId__c = pb.id;
        ql1.FOC_Period__c = 'Start';
        ql1.initial_payment__c = 400;
        ql1.SBQQ__Group__c = quoteTGrp1.id;
        ql1.Ihasco_Term__c = '3';
        ql1.iHasco_Subscription_Term__c = 36;
        ql1.SBQQ__CustomerPrice__c = 1200;   
        ql1.SBQQ__RegularPrice__c  = 1200;
        ql1.SBQQ__DefaultSubscriptionTerm__c = 36;
        ql1.SBQQ__BundledQuantity__c  = 1;
        ql1.SBQQ__ProrateMultiplier__c = 3;
        ql1.Source_Price__c = 200;
        quoteLines.add(ql1);

        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Product__c = p3.Id;
        ql2.SBQQ__Quantity__c = 1;
        ql2.SBQQ__Discount__c = 10;
        ql2.SBQQ__Quote__c = quote.Id;
        ql2.SBQQ__StartDate__c = Date.today();
        ql2.SBQQ__EndDate__c = Date.today().addYears(3);
        ql2.Service_Start_Date__c = Date.today();
        ql2.SBQQ__RequiredBy__c = ql.id;
        ql2.Ihasco_Number_of_Credits__c = 50;
        ql2.Billing_Frequency__c = 'Annual';
        ql2.SBQQ__BillingFrequency__c = 'Annual';
        ql2.SBQQ__NetPrice__c = 3000;
        ql2.SBQQ__ListPrice__c = 1000;
        ql2.SBQQ__SubscriptionTerm__c = 36;
        ql2.SBQQ__PricebookEntryId__c = pb.id;
        ql2.FOC_Period__c = 'Start';
        ql2.initial_payment__c = 1000;
        ql2.SBQQ__Group__c = quoteTGrp1.id;
        ql2.Ihasco_Term__c = '3';
        ql2.iHasco_Subscription_Term__c = 36;
        ql2.SBQQ__CustomerPrice__c = 3000; 
        ql2.SBQQ__RegularPrice__c  = 1000;
        ql2.SBQQ__DefaultSubscriptionTerm__c = 36;
        ql2.SBQQ__BundledQuantity__c  = 1;
        ql2.SBQQ__ProrateMultiplier__c = 3;
        ql2.Source_Price__c = 500;
        quoteLines.add(ql2);
        insert quoteLines;

        Date maxTerm= [Select SBQQ__EndDate__c from SBQQ__QuoteLine__c where Id = :ql.Id].SBQQ__EndDate__c;
        System.debug(maxTerm);
       
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.id;
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        insert ocr;
        SBQQ__Quote__c   quotei = [select id,SBQQ__Account__c, SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c from SBQQ__Quote__C limit 1];
    
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
       
        Contract con = new Contract();
        con.Name = 'Test contract';
        con.RecordTypeId = contractRecordType;
        con.StartDate =  Date.today();
        con.ContractTerm = 36;
        con.SBQQ__Quote__c = quote.Id;
        con.AccountId = quotei.SBQQ__Account__c;
        con.Source_Opportunity__c = quotei.SBQQ__Opportunity2__c;
        con.SBQQ__Opportunity__c =quotei.SBQQ__Opportunity2__c;
        con.Status = 'Draft';
        con.Renewal_Type__c = 'Non-Auto';
        con.Initial_Payment2__c = 500;
        con.CustomerSignedId = quotei.SBQQ__PrimaryContact__c;
        con.Total_Contract_Value__c = 1500;
        insert con;
        
        id  prd9 = [select id from product2 where name ='Open License Pricing' limit 1].id;
        id  prd10 = [select id from product2 where name ='Open License Credits' limit 1].id;
        id  prd11 = [select id from product2 where name ='10 Course Access' limit 1].id;
        
        list<SBQQ__Subscription__c>    subList = new list<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
        sb.SBQQ__Contract__c = con.id;
        sb.SBQQ__Account__c =  quotei.SBQQ__Account__c;       
        sb.SBQQ__Bundle__c = true;   
        sb.SBQQ__Product__c = prd9;
        sb.SBQQ__Quantity__c = 1;
        sb.SBQQ__QuoteLine__c = ql.id;
        subList.add(sb);
        
        SBQQ__Subscription__c sb1 = new SBQQ__Subscription__c();
        sb.SBQQ__RootId__c  = sb.id;
        sb.SBQQ__Account__c = quotei.SBQQ__Account__c;
        sb1.SBQQ__Contract__c = con.id;
        sb1.SBQQ__Product__c = prd10;
        sb1.SBQQ__Quantity__c = 1;
        sb1.SBQQ__ListPrice__c = 400;
        sb1.SBQQ__CustomerPrice__c = 1200;
        sb1.SBQQ__QuoteLine__c = ql1.id;
        subList.add(sb1);

        SBQQ__Subscription__c sb2 = new SBQQ__Subscription__c();
        sb2.SBQQ__RootId__c  = sb.id;
        sb2.SBQQ__Account__c = quotei.SBQQ__Account__c;
        sb2.SBQQ__Contract__c = con.id;
        sb2.SBQQ__Product__c = prd11;
        sb2.SBQQ__Quantity__c = 1;
        sb2.SBQQ__ListPrice__c = 1000;
        sb2.SBQQ__CustomerPrice__c = 3000;
        sb2.SBQQ__QuoteLine__c = ql2.id;
        subList.add(sb2);    
        insert subList; 
       
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Amendment for contract';
        opp1.AccountId = con.accountid;
        opp1.Deposit_Payment_Method__c = 'Direct Debit';
        opp1.RecordTypeId = oppRecordType;
        opp1.CloseDate = Date.newInstance(2021, 09, 30);
        opp1.StageName = 'In Progress';
        opp1.Pricebook2Id = pb.id;
        opp1.Type = 'New Business';
        opp1.SBQQ__AmendedContract__c = con.id;
        insert opp1;
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1.RecordTypeId = quoteRecordType;
        quote1.SBQQ__Primary__c = true;
        quote1.Payment_Method__c = 'Invoice';
        quote1.iHASCO_Payment_Terms__c = '30 Days';
        quote1.SBQQ__StartDate__c = Date.today();
        quote1.SBQQ__PrimaryContact__c = c.id;
        quote1.SBQQ__Status__c = 'Draft';
        quote1.SBQQ__Account__c = con.accountid;
        quote1.SBQQ__Opportunity2__c = opp1.Id;
        quote1.SBQQ__PrimaryContact__c = c.Id;
        quote1.Preferred_Payment_Date__c = '7';
        quote1.SBQQ__PriceBook__c = pb.Id;
        quote1.Initial_Payment_Date__c = Date.today();
        quote1.SBQQ__SubscriptionTerm__c = 36;
        quote1.License_Model__c = 'User Based';
        quote1.PO_reference__c = '1234';
        quote1.SBQQ__Type__c = 'Amendment';
        quote1.SBQQ__MasterContract__c = con.id;
        quote1.Quote_type__c = 'Mid-contract Amendment';
         
        insert quote1;
        }
        test.stopTest();
              
    }
    
    @isTest static void testAmendCreditBasedAnnualPriceCal() {
        id profileid1=[select id from Profile where name='System Administrator'].id;          
        User iHASCOUser1 =[select id from USER where Division='iHASCO' and isactive = true and LastName = 'ihascoQuoteTempAmmendCreditBasedTest' LIMIT 1];
        
        system.runAs(iHASCOUser1){
            List<Contract> conList = [SELECT id,SBQQ__Quote__c,accountid from Contract where recordTypeId = :contractRecordType limit 1];
            pricebook2 pb = [select id from pricebook2 where name ='iHASCO' limit 1]; 
            contact c = [select id from contact where phone ='01912553955'];
        
            opportunity opp = [select id,name from opportunity where name ='Amendment for contract' limit 1];
            SBQQ__Quote__c quote1 = [select id,SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =: opp.id];
            SBQQ__Subscription__c SBP1= [SELECT ID FROM SBQQ__Subscription__c WHERE SBQQ__ListPrice__c = 400 limit 1]; 
            SBQQ__Subscription__c SBP2= [SELECT ID FROM SBQQ__Subscription__c WHERE SBQQ__ListPrice__c = 1000 limit 1]; 

            SBQQ__QuoteLineGroup__c quoteTGrp2 = new SBQQ__QuoteLineGroup__c();
            quoteTGrp2.name = 'Group 1';
            quoteTGrp2.SBQQ__Quote__c = quote1.id;
            quoteTGrp2.SBQQ__SubscriptionTerm__c = 36;
            insert quoteTGrp2;
                
            list<product2> prdList = [select id,name from product2];
            map<string,id> mapNamStr = new map<string,id>();
            for(product2 pd: prdList){
                mapNamStr.put(pd.name,pd.id);
            } 
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = mapNamStr.get('Open License Pricing');
            ql.SBQQ__Quantity__c = 1;
            ql.SBQQ__Discount__c = 10;
            ql.SBQQ__Quote__c = quote1.Id;
            ql.SBQQ__StartDate__c = Date.today();
            ql.SBQQ__EndDate__c = Date.today().addYears(3);
            ql.Service_Start_Date__c = Date.today();
            ql.SBQQ__RequiredBy__c = ql.id;
            ql.Billing_Frequency__c = 'Annual';
            ql.SBQQ__BillingFrequency__c = 'Annual';
            ql.SBQQ__Existing__c = true;
            ql.SBQQ__ListPrice__c = 0;
            ql.SBQQ__NetPrice__c = 0;
            ql.SBQQ__SubscriptionTerm__c = 36;
            ql.FOC_Period__c = 'Start';
            ql.SBQQ__UpgradedSubscription__c = SBP1.id;
            ql.SBQQ__Group__c = quoteTGrp2.id;
            ql.initial_payment__c = 0;
            ql.Ihasco_Term__c = '3';
            ql.iHasco_Subscription_Term__c = 36;
            ql.SBQQ__PriorQuantity__c = 1;
            ql.SBQQ__BundledQuantity__c = 1;
            ql.SBQQ__CustomerPrice__c = 0;
            ql.SBQQ__RegularPrice__c  = 0;
            ql.SBQQ__DefaultSubscriptionTerm__c = 36;
            ql.SBQQ__BundledQuantity__c  = 1;
            ql.SBQQ__ProrateMultiplier__c = 3;
            ql.Source_Price__c = 500;
            insert ql;
            
            test.startTest();  
                
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Product__c = mapNamStr.get('10 Course Access');
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Discount__c = 10;
            ql1.SBQQ__Quote__c = quote1.Id;
            ql1.SBQQ__StartDate__c = Date.today();
            ql1.SBQQ__EndDate__c = Date.today().addYears(3);
            ql1.Service_Start_Date__c = Date.today();
            ql1.SBQQ__RequiredBy__c = ql.id;
            ql1.Billing_Frequency__c = 'Annual';
            ql1.SBQQ__BillingFrequency__c = 'Annual';
            ql1.SBQQ__Existing__c = true;
            ql1.SBQQ__ListPrice__c = 2500;
            ql1.SBQQ__NetPrice__c = 7500;
            ql1.SBQQ__SubscriptionTerm__c = 36;
            ql1.FOC_Period__c = 'Start';
            ql1.SBQQ__UpgradedSubscription__c = SBP1.id;
            ql1.SBQQ__Group__c = quoteTGrp2.id;
            ql1.initial_payment__c = 500;
            ql1.Ihasco_Term__c = '3';
            ql1.iHasco_Subscription_Term__c = 36;
            ql1.SBQQ__PriorQuantity__c = 1;
            ql1.SBQQ__BundledQuantity__c = 1;
            ql1.SBQQ__CustomerPrice__c = 1500;
            ql1.SBQQ__RegularPrice__c  = 1500;
            ql1.SBQQ__DefaultSubscriptionTerm__c = 36;
            ql1.SBQQ__BundledQuantity__c  = 1;
            ql1.SBQQ__ProrateMultiplier__c = 3;
            ql1.Source_Price__c = 500;
            quoteLines.add(ql1); 
    
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            ql2.SBQQ__Product__c = mapNamStr.get('Open License Credits');
            ql2.SBQQ__Quantity__c = 1;
            QL2.Ihasco_Number_of_Credits__c = 100;
            ql2.SBQQ__Discount__c = 10;
            ql2.SBQQ__Quote__c = quote1.Id;
            ql2.SBQQ__StartDate__c = Date.today();
            ql2.SBQQ__EndDate__c = Date.today().addYears(3);
            ql2.Service_Start_Date__c = Date.today();
            ql2.SBQQ__RequiredBy__c = ql.id;
            ql2.initial_payment__c = 1500;
            ql2.SBQQ__ListPrice__c = 1500;
            ql2.Billing_Frequency__c = 'Annual';
            ql2.SBQQ__BillingFrequency__c = 'Annual';
            ql2.SBQQ__Existing__c = true;
            ql2.SBQQ__NetPrice__c = 4500;
            ql2.SBQQ__SubscriptionTerm__c = 36;
            ql2.FOC_Period__c = 'Start'; 
            ql1.SBQQ__UpgradedSubscription__c = SBP2.id;
            ql2.SBQQ__Group__c = quoteTGrp2.id;
            ql2.Ihasco_Term__c = '3';  
            ql2.iHasco_Subscription_Term__c = 36;
            ql2.SBQQ__CustomerPrice__c = 4500;
            ql2.SBQQ__RegularPrice__c  = 1500;
            ql2.SBQQ__DefaultSubscriptionTerm__c = 36;
            ql2.SBQQ__BundledQuantity__c  = 1;
            ql2.SBQQ__ProrateMultiplier__c = 3;
            ql2.Source_Price__c = 500;
            quoteLines.add(ql2);

            SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
            ql3.SBQQ__Product__c = mapNamStr.get('Ihasco Plus');
            ql3.SBQQ__Quantity__c = 1;
            ql3.SBQQ__Quote__c = quote1.Id;
            ql3.SBQQ__StartDate__c = Date.today();
            ql3.SBQQ__EndDate__c = Date.today().addYears(3);
            ql3.Service_Start_Date__c = Date.today();
            ql3.SBQQ__RequiredBy__c = ql.id;
            ql3.initial_payment__c = 0;
            ql3.Billing_Frequency__c = 'Annual';
            ql3.SBQQ__BillingFrequency__c = 'Annual';
            ql3.SBQQ__Existing__c = true;
            ql3.SBQQ__NetPrice__c = 0;
            ql3.SBQQ__SubscriptionTerm__c = 36;
            ql3.FOC_Period__c = 'Start'; 
            ql3.SBQQ__ListPrice__c = 0;
            ql3.SBQQ__Group__c = quoteTGrp2.id;
            ql3.Ihasco_Term__c = '3';
            ql3.iHasco_Subscription_Term__c = 36;
            ql3.SBQQ__CustomerPrice__c = 0;
            ql3.SBQQ__RegularPrice__c  = 1500;
            ql3.SBQQ__DefaultSubscriptionTerm__c = 36;
            ql3.SBQQ__BundledQuantity__c  = 1;
            ql3.SBQQ__ProrateMultiplier__c = 3;
            ql3.Source_Price__c = 500;
            quoteLines.add(ql3);
            insert quoteLines;
            system.debug('quote lines+++'+quoteLines);
            test.stopTest();
    
            SBQQ__QuoteTemplate__c testTemplate = createTemplate();
            PageReference CPQGeneratePage = Page.SBQQ__GenerateDocument;
            Test.setCurrentPage(CPQGeneratePage);
            ApexPages.currentPage().getParameters().put('qid', quote1.Id);
            ApexPages.currentPage().getParameters().put('tid', testTemplate.Id);
            iHASCOQuoteTemplateControllerAmd quoteDocument = new iHASCOQuoteTemplateControllerAmd();
            double customerprice = 900;
            for(SBQQ__QuoteLine__c qLine: quoteDocument.amendedFinalQuoteLine){
                if(qLine.SBQQ__ProductName__c == 'Open License Credits'){
                    system.assertEquals(450, qLine.Annual_Price__c, 'Open Credits Annual Price Check');	
                    system.assertEquals(450,quoteDocument.OpenCreditPrice,'Open Credits Price check');
                }
                if(qLine.SBQQ__ProductName__c== '10 Course Access'){
                    system.assertEquals(750, qLine.Annual_Price__c, '10 Course Annual Course Price check');	
                }
            }
            system.assertEquals(450, quoteDocument.premiumAnnual, 'Validates the anual price of quotelines');
            }
    }
    private static SBQQ__QuoteTemplate__c createTemplate()
    {
        SBQQ__QuoteTemplate__c t = new SBQQ__QuoteTemplate__c();
        insert t;
        return t;    
    }
}