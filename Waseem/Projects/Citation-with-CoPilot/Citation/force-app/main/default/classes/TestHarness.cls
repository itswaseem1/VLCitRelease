/*
    * FinancialForce.com, inc. claims copyright in this software, its screen display designs and
    * supporting documentation. FinancialForce and FinancialForce.com are trademarks of FinancialForce.com, inc.
    * Any unauthorized use, copying or sale of the above may constitute an infringement of copyright and may
    * result in criminal or other legal proceedings.
    *
    * Copyright FinancialForce.com, inc. All rights reserved.
    * Created by @Uves Ravat
*/

public class TestHarness 
{
    /**
        *   Create Test User (Product Services)
        *   No @Parms required
        *   No Return
    **/
    public static User createTestUser()
    {
        return createTestUser(true);
    }
    /**
        *   Create Test User (Product Services)
        *   No @Parms required
    **/
    public static User createTestUser(Boolean doInsert)
    {
        Profile p = [select id from profile where name='System Administrator'];
        User testUser = new User();
        testUser.put('FirstName' , '$FinancialForce PS');
        testUser.put('LastName' , ' Developer$');
        testUser.put('Alias' , '$FFPSD$');
        testUser.put('Email' , 'productservices@financialforce.com');
        testUser.put('Username' , 'financialforceproductservicesdevloper@financialforce.com');
        testUser.put('CommunityNickname' , '$FFPSDMDT$');
        testUser.put('Phone' , '555.555.5555');
        testUser.put('IsActive' , true);
        testUser.put('ProfileId' , p.id);
        testUser.put('TimeZoneSidKey' , 'America/New_York');
        testUser.put('LocaleSidKey' , 'en_US');
        testUser.put('EmailEncodingKey' , 'ISO-8859-1');
        testUser.put('LanguageLocaleKey' , 'en_US');
        testUser.put('Title' , 'Product Service Developer and Tester');
        testUser.put('CompanyName' , 'FinancialForce Test Company PS');

        if (doInsert)
            insert testUser;

        return testUser;
    }
    /**
        *   Create Product
        *   No @Parms required
    **/
    public static Product2 createProduct(Boolean doInsert)
    {
        Product2 prod = new Product2();
        prod.put('Name' , 'Blue 101 Timecard with 10% OFF');
        prod.put('ProductCode' , 'CLUPFR101');
        prod.put('IsActive' , true);

        if(doInsert)
            insert prod;

        return prod;
    }
    /**
        *   Create PricebookEntry
        *   One Param required
        *       - Id prodId - Product2 Id
    **/
    public static PricebookEntry createPriceBookEntry(Boolean doInsert, Id prodId)
    {
        PricebookEntry priceBookEntry = new PricebookEntry();
        priceBookEntry.put('Pricebook2Id' , Test.getStandardPricebookId());
        priceBookEntry.put('Product2Id' , prodId);
        priceBookEntry.put('UnitPrice' , 5000);
        priceBookEntry.put('IsActive' , true);
        priceBookEntry.put('UseStandardPrice' , false);

        if(doInsert)
            insert priceBookEntry;

        return priceBookEntry;
    }
    /**
    *   Create or Insert Account
    *   No @Parms required
    **/
    public static Account createAccount(Boolean doInsert)
    {
        Account productServices = new Account();
        productServices.put('Name', '$$$$$$$Product Services$$$$$$$');
        productServices.put('CurrencyIsoCode', 'USD');
        productServices.put('AccountNumber', 'CD656092');
        productServices.put('Type', 'Customer - Direct');
        productServices.put('Industry', 'Apparel');
        productServices.put('AnnualRevenue', 350000000);
        productServices.put('Ownership', 'Public');
        productServices.put('Rating', 'Warm');
        productServices.put('Phone', '(336) 222-7000');
        productServices.put('Fax', '(336) 222-8000');
        productServices.put('Website', 'http://www.financialforce.com');
        productServices.put('TickerSymbol', 'BTXT');
        productServices.put('NumberOfEmployees', 9000);
        productServices.put('SIC', '546732');
        
        if(doInsert)
            insert productServices;

        return productServices;
    }

    /**
        *   Create Opportunity
        *   One Param required
        *       - Id accId - Account Id
    **/
    public static Opportunity createOpportunity(Boolean doInsert, id accountId)
    {
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.AccountId = accountId;
        testOpportunity.Name = 'Uves Ravat';
        testOpportunity.CloseDate = system.today();
        testOpportunity.StageName = 'Prospecting';

        if(doInsert)
            insert testOpportunity;

        return testOpportunity;
    }
    /**
        *   Create Opportunity Line Item
        *   Two Param required
        *       - Id oppId - Opportunity Id
        *       - Id priceBookEntryId - PricebookEntry Id
    **/
    public static OpportunityLineItem createOpportunityProduct(Boolean doInsert, Id oppId, Id priceBookEntryId)
    {
        OpportunityLineItem testOpportunityLine = new OpportunityLineItem();
        testOpportunityLine.Quantity = 1;
        testOpportunityLine.UnitPrice = 5000;
        testOpportunityLine.Description = 'Test by Uves Ravat';
        testOpportunityLine.OpportunityId = oppId;
        testOpportunityLine.PricebookEntryId = priceBookEntryId;

        if(doInsert)
            insert testOpportunityLine;

        return testOpportunityLine;
    }

    public static fferpcore__Company__c createBillingCompany(Boolean doInsert)
    {
        fferpcore__Company__c widgetsInc = new fferpcore__Company__c(
            Name = 'FinancialForce Test Company',
            fferpcore__Street__c = '1000 Elm St Suite 801',
            fferpcore__City__c = 'Manchester',
            fferpcore__State__c = 'NH',
            fferpcore__Zip__c = '03101-1700',
            fferpcore__Country__c = 'US'
        );

        if(doInsert)
            insert widgetsInc;

        return widgetsInc;
    }   

    public static ffbc__SoftDate__c createSoftDate(Boolean doInsert)
    {
        ffbc__SoftDate__c dailySoftDate = new ffbc__SoftDate__c(
            Name = 'Monthly',
            ffbc__Definition__c = '+1M'
            );

        if(doInsert)
            insert dailySoftDate;

        return dailySoftDate;
    }

    public static ffbc__Contract__c createBillingContract(Boolean doInsert, Account contractAccount, fferpcore__Company__c company, Opportunity testOpportunity)
    {
        ffbc__Contract__c billingContract = new ffbc__Contract__c();
        billingContract.ffbc__Account__c = contractAccount.Id;
        billingContract.ffbc__Company__c = company.Id;
        billingContract.ffbc__FirstBillDate__c = System.today();
        billingContract.ffbc__StartDate__c = System.today();
        billingContract.ffbc__EndDate__c = System.today().addYears(1);
        //billingContract.ffps_bcext__Opportunity__c = testOpportunity.id;

        if(doInsert)
            insert billingContract;

        return billingContract;
    }

    public static ffbc__ContractLineItem__c createBillingContractLine(Boolean doInsert, Product2 testProduct, ffbc__SoftDate__c billingTerm, ffbc__Contract__c testContract)
    {
        ffbc__ContractLineItem__c billingContractLine = new ffbc__ContractLineItem__c();
        billingContractLine.ffbc__FirstBillDate__c = System.today();
        billingContractLine.ffbc__StartDate__c = System.today();
        billingContractLine.ffbc__EndDate__c = System.today().addYears(1);
        billingContractLine.ffbc__ProductService__c = testProduct.Id;
        billingContractLine.ffbc__BillingTerm__c = billingTerm.Id;
        billingContractLine.ffbc__BillingType__c = 'Recurring Fixed';
        billingContractLine.ffbc__Quantity__c = 1;
        billingContractLine.ffbc__UnitPrice__c = 500;
        billingContractLine.ffbc__Contract__c = testContract.Id;
        billingContractLine.put('Service_Start_Date__c', system.today());
        billingContractLine.put('Service_End_Date__c', System.today().addYears(1));

        if(doInsert)
            insert billingContractLine;

        return billingContractLine;
    }
}