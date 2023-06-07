@isTest
public class TestMarkContractsToExpired {
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default IHASCO';
    public static final Id CONTRACTRECORDTYPE = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    public  static Account acc;
    public  static Opportunity opp;
    public  static Pricebook2 pb;
    public  static SBQQ__Quote__c quote;
    public  static Id OPPRECORDTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    public  static Id QUOTERECORDTYPE = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    public  static Contact c;
    public  static Product2 p2;
    public  static Product2 p;
    
    @testsetup 
    static void setUp(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'TestMarkContractsToExpired';
        insert iHASCOUser;
        //User iHASCOUser =[select id from USER where Division='iHASCO' and isactive = true LIMIT 1];
        system.runAs(iHASCOUser){
            List<Product2> prd = new List<Product2>();
            Product2 p = new Product2();
            p.Name = '10 Course Access Key';
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
            p2.Name = 'User based Pricing';
            p2.ProductCode = 'HUBP';
            p2.IsActive = True;
            p2.SBQQ__SubscriptionType__c = 'Renewable';
            p2.SBQQ__BillingFrequency__c ='Annual';
            prd.add(p2);
            insert prd;
            List<PricebookEntry> entries = new List<PricebookEntry>();
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p2.Id, 1000.0, 0.0, 0.0));
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
            //quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__Primary__c = true;
            quote.Payment_Method__c = 'Invoice';
            quote.iHASCO_Payment_Terms__c = '30 Days';
            quote.SBQQ__StartDate__c = Date.today().addYears(-5);
            quote.SBQQ__PrimaryContact__c = c.id;
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__PrimaryContact__c = c.Id;
            quote.Preferred_Payment_Date__c = '7';
            quote.Initial_Payment__c = 200;
            quote.SBQQ__PriceBook__c = pb.Id;
            quote.Initial_Payment_Date__c = Date.today().addyears(-5);
            quote.SBQQ__SubscriptionTerm__c = 60;
            quote.License_Model__c = 'User Based';
            quote.PO_reference__c = '1234';
            insert quote;
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = p2.Id;
            ql.SBQQ__Quantity__c = 1;
            ql.Custom_Discount_Percentage__c = 10;
            ql.SBQQ__Quote__c = quote.Id;
            ql.SBQQ__StartDate__c = Date.today();
            ql.SBQQ__EndDate__c = Date.today().addYears(5);
            ql.Service_Start_Date__c = Date.today();
            ql.Billing_Frequency__c = 'Annual';
            ql.SBQQ__BillingFrequency__c = 'Annual';
            ql.SBQQ__NetPrice__c = 600;
            ql.SBQQ__SubscriptionTerm__c = 60;
            ql.FOC_Period__c = 'Start';
            insert ql;
            
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Product__c = p.Id;
            ql1.SBQQ__Quantity__c = 1;
            ql1.Custom_Discount_Percentage__c = 10;
            ql1.SBQQ__Quote__c = quote.Id;
            ql1.SBQQ__StartDate__c = Date.today().addYears(-5);
            ql1.SBQQ__EndDate__c = Date.today().AddDays(-1);
            ql1.Service_Start_Date__c = Date.today();
            ql1.SBQQ__RequiredBy__c = ql.id;
            ql1.iHasco_Number_of_Users__c = 50;
            ql1.Billing_Frequency__c = 'Annual';
            ql1.SBQQ__BillingFrequency__c = 'Annual';
            ql1.SBQQ__NetPrice__c = 600;
            ql1.SBQQ__SubscriptionTerm__c = 60;
            ql1.SBQQ__PricebookEntryId__c = pb.id;
            ql1.FOC_Period__c = 'Start';
            ql1.Custom_Discount_Amount__c = 150;
            
            Test.startTest();
            quoteLines.add(ql1);
            
            insert quoteLines;
            
            test.stopTest();
            
            Date maxTerm= [Select SBQQ__EndDate__c from SBQQ__QuoteLine__c where Id = :ql.Id].SBQQ__EndDate__c;
            System.debug(maxTerm);
            
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.OpportunityId = opp.id;
            ocr.ContactId = c.id;
            ocr.IsPrimary = true;
            ocr.Role = 'Decision Maker';
            insert ocr;
            
            
        }
    }
    
    @isTest 
    static void testMarkContractsToExpiredScheduler() {
        Test.startTest();
        SBQQ__Quote__c   quotei = [select id,SBQQ__Account__c, SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c from SBQQ__Quote__C limit 1];
        User iHASCOUser =[select id from USER where Division='iHASCO' and LastName = 'TestMarkContractsToExpired' LIMIT 1];
        system.runAs(iHASCOUser)
        {
            Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today().addMonths(-60);
            con.ContractTerm = 60;
            con.SBQQ__Quote__c = quotei.Id;
            con.AccountId = quotei.SBQQ__Account__c;
            con.Source_Opportunity__c = quotei.SBQQ__Opportunity2__c;
            con.SBQQ__Opportunity__c =quotei.SBQQ__Opportunity2__c;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.CustomerSignedId = quotei.SBQQ__PrimaryContact__c;
            con.Total_Contract_Value__c = 1000;
            insert con;
            
            id  prd = [select id from product2 where name ='User based Pricing' limit 1].id;
            id  prd2 = [select id from product2 where name ='10 Course Access Key' limit 1].id;
            list<SBQQ__Subscription__c>    subList = new list<SBQQ__Subscription__c>();
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
            sb.SBQQ__Contract__c = con.id;
            sb.SBQQ__Product__c = prd;
            sb.SBQQ__Quantity__c = 1;
            sb.SBQQ__ListPrice__c = 2000; 
            subList.add(sb);
            SBQQ__Subscription__c sb1 = new SBQQ__Subscription__c();
            sb1.SBQQ__Contract__c = con.id;
            sb1.SBQQ__Product__c = prd2;
            sb1.SBQQ__Quantity__c = 1;
            sb1.SBQQ__ListPrice__c = 2000;
            subList.add(sb1);
            insert subList; 
        }
        
        List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType limit 1];
        
        if(!conList.isEmpty()){
            for(Contract c : conList){
                c.status = 'Active';
            }
            update conList;
        }
        string q = 'Select id,status from contract where recordtype.name IN (\''+ String.escapeSingleQuotes('iHASCO_Contract') + '\') and enddate = YESTERDAY and status =\''+ String.escapeSingleQuotes('Active') + '\'' ;
        // Schedule the test job
        sTRING Cron_Exp = '0 0 1 * * ?';
        String jobId = System.schedule('MarkContractsToExpiredScheduled',Cron_Exp,new MarkContractsToExpired(q));
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals('0 0 1 * * ?',ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
}