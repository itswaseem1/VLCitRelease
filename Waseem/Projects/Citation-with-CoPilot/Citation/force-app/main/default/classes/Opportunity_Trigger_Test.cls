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
 *
 * Last Modified By: KH 01-10-17 (SimplySell CPQ Unit Test Fixes)
 */
@isTest(isParallel=false)
private class Opportunity_Trigger_Test {


    @TestSetup
    private static void testSetup()
    {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;

        Account acc = new Account(name='Test1');
        acc.AnnualRevenue = 75000;
        insert acc;
    }
    @isTest
    static void OpportunityTrigger_InsertOpportunity_isOpportunityInserted() {
        Integer expectedValue = 20;
        
        Account acc = [SELECT Id FROM Account];

        List<Opportunity> Opportunities = CIT_PH1_Trigger_Utils.createOpportunities(expectedValue);

        for(Opportunity opp : Opportunities)
        {
            opp.AccountId = acc.Id;
        }
        
        Test.StartTest();
            insert Opportunities;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Opportunity WHERE Id in :Opportunities];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void OpportunityTrigger_UpdateOpportunity_isOpportunityUpdated() {
        Integer expectedValue = 20;

        Account acc = [SELECT Id FROM Account];

        List<Opportunity> Opportunities = CIT_PH1_Trigger_Utils.createOpportunities(expectedValue);

        for(Opportunity opp : Opportunities)
        {
            opp.AccountId = acc.Id;
        }

        insert Opportunities;
        
        Test.StartTest();
            update Opportunities;   
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Opportunity WHERE Id in :Opportunities];
        System.AssertEquals(expectedValue,actualValue);
    }
    
    @isTest
    static void OpportunityTrigger_DeleteOpportunity_isOpportunityDeleted() {
        Integer expectedValue = 20;

        Account acc = [SELECT Id FROM Account];

        List<Opportunity> Opportunities = CIT_PH1_Trigger_Utils.createOpportunities(expectedValue);

        for(Opportunity opp : Opportunities)
        {
            opp.AccountId = acc.Id;
        }

        insert Opportunities;
        
        Test.StartTest();
            delete Opportunities;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Opportunity WHERE Id in :Opportunities];
        
        System.AssertEquals(0,actualValue);
    }
    
    @isTest
    static void OpportunityTrigger_UnDeleteOpportunity_isOpportunityUndeleted() {
        Integer expectedValue = 20;

        Account acc = [SELECT Id FROM Account];

        List<Opportunity> Opportunities = CIT_PH1_Trigger_Utils.createOpportunities(expectedValue);

        for(Opportunity opp : Opportunities)
        {
            opp.AccountId = acc.Id;
        }

        insert Opportunities;
        delete Opportunities;
        
        Test.StartTest();
            undelete Opportunities;
        Test.stopTest();
         
        Integer actualValue = [SELECT count() FROM Opportunity WHERE Id in :Opportunities];
        System.AssertEquals(expectedValue,actualValue);
    }

    @isTest
    static void TestUpdateSalesMarketingChannel(){
        Account acc = [SELECT Id FROM Account];

        Test.startTest();
        List<Opportunity> oppList=TestDataFactory.generateOppsForAccount(acc.Id,3000,1,false);
        oppList[0].LeadSource='Cross Sell - Citation';
        oppList[0].RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Default Citation Opportunity').getRecordTypeId();
        insert oppList;
        Opportunity opp=[SELECT LeadSource,Marketing_Channel__c,Sales_Channel__c from Opportunity where Id=:oppList[0].Id];
        System.assertEquals(opp.Marketing_Channel__c, 'Citation', 'Marketing Channel Not updated');
        System.assertEquals(opp.Sales_Channel__c, 'Cross Sell', 'Sales Channel Not updated');
        opp.LeadSource='Cross Sell - QMS';
        update opp;
        opp=[SELECT Marketing_Channel__c,Sales_Channel__c from Opportunity where Id=:opp.Id];
        System.assertEquals(opp.Marketing_Channel__c, 'QMS', 'Marketing Channel Not updated');
        System.assertEquals(opp.Sales_Channel__c, 'Cross Sell', 'Sales Channel Not updated');
        opp.Sales_Channel__c=opp.Marketing_Channel__c=null;
        update opp;
        database.executeBatch(new BatchUpdateSalesMarketingChannelOpp(),200);
        Test.stopTest();
    }
    @isTest
    static void testCreateQuotes(){
        Account acc = [SELECT Id FROM Account];
        
        Contact con=new Contact();
        con.LastName='Test Con';
        con.AccountId=acc.Id;
        con.CurrencyIsoCode='GBP';
        insert con;
        List<fferpcore__Company__c> company = TestDataFactory.getCompanys('Training Company');
        insert company;
        List<Product2> prodPAT = TestDataFactory.getProducts('Fixed Wire Testing Service - 3 Year Tailored Package','Consultancy - Contract');
        List<Product2> prodOther=TestDataFactory.getProducts('BS 10012 - Additional Company - Certification','Consultancy - Contract');
        
        Contract contract=new Contract();
        contract.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
        contract.Name='Test Contract';
        contract.AccountId=acc.Id;
        contract.status='Draft';
        contract.Renewal_Type__c='Non-Auto';
        contract.Business_Type__c='New Business';
        contract.Contract_Value__c=12000;
        contract.Payment_Period__c='monthly';
        contract.Preferred_Payment_Date__c='7';
        contract.CustomerSignedId=con.Id;
        contract.StartDate=System.Today();
        contract.ContractTerm=12;
        contract.FOC_Period_Mths__c=0;
        contract.FOC_Period_Mths_End__c=0;
        insert contract;
        ffbc__Contract__c bc = new ffbc__Contract__c();
        bc.ffbc__Account__c = acc.Id;
        bc.ffbc__Company__c  = company[0].Id;
        bc.Contract_Type__c = 'New';
        bc.SF_Contract__c=contract.Id;
        bc.ffbc__StartDate__c=Date.newInstance(System.today().year(),System.today().month(),System.today().day());
        bc.ffbc__EndDate__c=Date.newInstance(System.today().addYears(1).year(),System.today().addYears(1).month(),System.today().addYears(1).day());
        bc.ffbc__Status__c='Draft';
        bc.ffbc__Type__c='Contract';
        bc.ffbc__FirstBillDate__c=System.Today();
        insert bc;
        ffbc__SoftDate__c softdate=new ffbc__SoftDate__c();
        softdate.Name='Monthly';
        softdate.ffbc__Definition__c='+1M';
        insert softdate;
        List<ffbc__ContractLineItem__c> billingContractLineItems=new List<ffbc__ContractLineItem__c>();
        ffbc__ContractLineItem__c ffbc1 = new ffbc__ContractLineItem__c();
        ffbc1.ffbc__Contract__c = bc.Id;
        ffbc1.ffbc__ProductService__c = prodOther[0].Id;
        ffbc1.ffbc__StartDate__c=ffbc1.Service_Start_Date__c = Date.newInstance(System.today().year(),System.today().month(),System.today().day());
        ffbc1.ffbc__EndDate__c=ffbc1.Service_End_Date__c = Date.newInstance(System.today().addYears(1).year(),System.today().addYears(1).month(),System.today().addYears(1).day());
        ffbc1.ffbc__BillingType__c = 'Recurring Fixed';
        ffbc1.ffbc__Quantity__c = 10;
        ffbc1.ffbc__UnitPrice__c=75;
        ffbc1.ffbc__BillingTerm__c=softdate.Id;
        billingContractLineItems.add(ffbc1);
        ffbc__ContractLineItem__c ffbc2 = new ffbc__ContractLineItem__c();
        ffbc2.ffbc__Contract__c = bc.Id;
        ffbc2.ffbc__ProductService__c = prodPAT[0].Id;
        ffbc2.ffbc__StartDate__c=ffbc2.Service_Start_Date__c = Date.newInstance(System.today().year(),System.today().month(),System.today().day());
        ffbc2.ffbc__EndDate__c=ffbc2.Service_End_Date__c = Date.newInstance(System.today().addYears(1).year(),System.today().addYears(1).month(),System.today().addYears(1).day());
        ffbc2.ffbc__BillingType__c = 'Recurring Fixed';
        ffbc2.ffbc__Quantity__c = 10;
        ffbc2.ffbc__UnitPrice__c=75;
        ffbc2.ffbc__BillingTerm__c=softdate.Id;
        billingContractLineItems.add(ffbc2);
        insert billingContractLineItems;
        Test.startTest();
        Opportunity opp=new Opportunity();
        opp.AccountId=acc.Id;
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal / Retention Opportunity - Non-Auto').getRecordTypeId();
        opp.CloseDate=System.today().addYears(1);
        opp.StageName='Appointment';
        opp.Name='Test Renewal Opp';
        opp.Original_Contract__c=contract.Id;
        insert opp;
        Test.stopTest();
        List<SBQQ__Quote__c> quotes=[SELECT Id from SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:opp.Id];        
    }
}