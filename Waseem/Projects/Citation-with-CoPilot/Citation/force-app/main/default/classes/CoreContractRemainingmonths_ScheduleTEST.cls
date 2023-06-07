@isTest
public class CoreContractRemainingmonths_ScheduleTEST {
    public static Id lockedQuoterecordtype = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Quote Locked').getRecordTypeId();
    public static Account testAccount;
    @testSetup static void setup()
    {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
      
        List<String> Prdcodes = System.Label.CPQ_Core_Product_Codes.Split(',');
      
        List<Product2> products = new List<Product2>();
        Product2 combinedProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_COMBINED_SERVICE, 'Consultation', 'Premium');
        combinedproduct.SBQQ__BillingFrequency__c = 'Monthly' ;
        combinedproduct.ProductCode = Prdcodes[0];
        products.add(combinedProduct);
        insert products;
    //      lockedQuoterecordtype = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' lIMIT 1] ;
      
        
        testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        contact con = TestDataFactory.getContacts(1, 'firstName', 'lastName', testAccount.id, true)[0];
         
         
        contract c = new contract(accountid=testAccount.id, FOC_Period_Mths__c=2, FOC_Period_Mths_End__c=0, startdate = date.today() , Agreement_Type__c = 'Auto') ;
        insert c ;
        
        List<Opportunity> oppList = new List<Opportunity>();
        opportunity opp1 = new opportunity(name = 'test',stagename = 'Appointment',closedate = date.today(), accountid = testAccount.id) ;
        opp1.Amount = 1000;
        opp1.Core_Compliance_TCV__c  = 1234;
        oppList.add(opp1);
        opportunity opp2 = new opportunity(name = 'test2',stagename = 'Appointment',closedate = date.today(), accountid = testAccount.id) ;
        opp2.Amount = 1000;
        opp2.Core_Compliance_TCV__c  = 1234;
        oppList.add(opp2);
        insert oppList ;
        
        List<sbqq__quote__c> qtList = new List<sbqq__quote__c>();
        sbqq__quote__c q1 = new sbqq__quote__c(sbqq__account__c = testAccount.id,SBQQ__Opportunity2__c = opp1.id, recordtypeid = lockedQuoterecordtype,SBQQ__QuoteTemplateId__c=null, SBQQ__PrimaryContact__c = con.id) ;
        q1.Initial_Payment__c = 1000;
        q1.Initial_Payment_Date__c = date.today().addDays(2);
        q1.SBQQ__BillingFrequency__c = 'Monthly';
        q1.Preferred_Payment_Date__c = '7';
        q1.Second_Signatory_Required__c = 'No';
        q1.SBQQ__StartDate__c = date.today().adddays(2);
        qtList.add(q1);
        insert qtList ;
        
        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = q1.Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = combinedProduct.Id;
        quoteLine.SBQQ__Group__c = testGroup.Id;
        quoteLine.SBQQ__Quote__c = q1.Id;
        quoteline.sbqq__specialprice__c = 90 ;
        quoteline.sbqq__quantity__c = 1 ;
        quoteline.billing_Frequency__c = 'Monthly' ;
        quoteline.Initial_Payment__c = 10;
        insert quoteLine;
        
        
        List<contract> ctrList = new List<contract>();
        contract c1 = new contract(accountid=testaccount.id, startdate = date.today() , Agreement_Type__c = 'Auto', CustomerSignedId = con.id) ;
        c1.ContractTerm = 24;
        c1.FOC_Period_Mths__c =2;
        c1.FOC_Period_Mths_End__c = 12;
        c1.Name = 'test';
        c1.Service_Type__c = 'Citation';
        c1.Status = 'Draft';
        c1.Business_Type__c = 'New Business';
        c1.Payment_Period__c = 'Monthly';
        c1.Preferred_Payment_Date__c ='7';
        c1.Core_Compliance_TCV__c = 1000;
        c1.SBQQ__Opportunity__c = opp1.ID;
        c1.Renewal_Type__c = 'Auto';
        
    //    c1.SBQQ__Quote__c = q1.Id;
        ctrList.add(c1); 
        
		//To avoid Limit Exceptions
        Test.startTest();
        insert ctrList ;
        Test.stopTest();
        c1.Status = 'Active';
        
        
        //update ctrList;
    
    }
    
    
    
     static testmethod void testScheduleExecution_DefaultSize()
    {
        String CRON_EXP = '0 0 12 1/1 * ? *';
        String jobID = '';
		Test.startTest();
        Account acc = [SELECT id, Renewal_Type__c, CoreCitationContractMonths__c, MACV__c FROM Account LIMIT 1];
        acc.Renewal_Type__c = NULL;
        acc.CoreCitationContractMonths__c = 0;
        acc.MACV__c = 0;
        update acc;
        
        
            CoreContractRemainingmonths_Schedule schjob = new CoreContractRemainingmonths_Schedule();
            jobID = System.schedule('CoreRemainingDays Job', CRON_EXP, schjob);
        Test.StopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered); 
    //        System.assertNotEquals(NULL, [select Renewal_Type__c from Account where id = :acc.id].Renewal_Type__c);
    }
    
     static testmethod void testScheduleExecution_CustomSize()
    {
        String CRON_EXP = '0 0 12 1/1 * ? *';
        String jobID = '';
		Test.startTest();
        Account acc = [SELECT id, Renewal_Type__c, CoreCitationContractMonths__c, MACV__c FROM Account LIMIT 1];
        acc.Renewal_Type__c = NULL;
        acc.CoreCitationContractMonths__c = 0;
        acc.MACV__c = 0;
        update acc;
        
        
            CoreContractRemainingmonths_Schedule schjob = new CoreContractRemainingmonths_Schedule(400);
            jobID = System.schedule('CoreRemainingDays Job', CRON_EXP, schjob);
        Test.StopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    //        System.assertNotEquals(NULL, [select Renewal_Type__c from Account where id = :acc.id].Renewal_Type__c);
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
      //acc.Number_of_Active_Sites__c = 1;
        acc.Sites__c = 1;
        
        insert acc;
        return acc;     
    }
}