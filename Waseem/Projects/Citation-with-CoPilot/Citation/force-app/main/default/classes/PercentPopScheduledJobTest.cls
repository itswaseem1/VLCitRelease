@isTest
public class PercentPopScheduledJobTest{

    public static String CRON_EXP = '00 59 12 12 12 ? 2025';

    @testSetup
    static void setUp(){
        List<Product2> prod = TestDataFactory.getProducts('BS 10012 - Additional Company - Certification','Consultancy - Contract');
        List<fferpcore__Company__c> company = TestDataFactory.getCompanys('Training Company');
        insert company;
        List<Revenue_Recognition_Logic__c> revrec = TestDataFactory.getRevRecLogic('Test Rev Logic','New','Consultancy - Contract','Training Company');
        insert revrec;
        List<ffbc__Contract__c> ffbcContract = TestDataFactory.getBillingContracts(company[0].Id);
        insert ffbcContract;
        List<ffbc__ContractLineItem__c> ffbcCLI = TestDataFactory.getContractLineItems(ffbcContract[0].Id,prod[0].Id,revrec[0].Id);
        insert ffbcCLI;
    }

    static testMethod User newUser(){
        Profile pro = [SELECT Id FROM Profile WHERE Name='Citation FF FULL' LIMIT 1];
        User u = new User(
            ProfileId       = pro.Id,
            FirstName       = 'Ben',
            LastName        = 'Stokes',
            Email           = 'benstokes@citation.co.uk',
            Username        = 'benstokesl200519ar@citation.co.uk',
            CompanyName     = 'Citation Limited',
            Title           = 'President',
            Alias           = 'arus',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US'
        );
        return u;
    }

    @isTest static void mySampleTest(){
        User u = [SELECT Id FROM User LIMIT 1];
        List<ffbc__ContractLineItem__c> contractLines = [SELECT Id,Revenue_Recognition_Logic_Percent__c,Revenue_Recognition_Logic__c FROM ffbc__ContractLineItem__c];
            Test.startTest();
            PercentPopScheduledJob schedule = new PercentPopScheduledJob();
            String sch = System.schedule('Percent Calculation 3', CRON_EXP, schedule);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :sch];
            System.assertEquals(0, ct.TimesTriggered);
            for(ffbc__ContractLineItem__c cli : contractLines){
                System.assert(cli.Revenue_Recognition_Logic_Percent__c==null);
            }
            Test.stopTest();
    }   

}