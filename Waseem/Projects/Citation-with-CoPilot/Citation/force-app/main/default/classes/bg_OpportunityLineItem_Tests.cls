/********************************************************************************
* bg_OpportunityLineItem_Tests :
*
* Test methods for the Opportunity Line Item Helper class.
* Tests:
*       same standard on all sites, client with 9 sites, single OLI
*       same standard on all sites, client with 1 site, single OLI
*       same standard on all sites, client with 3 sites, multi OLIs
*       same standard on all sites, client with 1 site, multi OLIs
*       different standard on sites, client with 3 sites, single OLI
*       different standard on sites, client with 1 site, single OLI
*       different standard on sites, client with 3 sites, multi OLIs
*       different standard on sites, client with 1 site, multi OLIs
*       different standard on sites, client with 3 sites, multi OLIs, but for a reduction product.
*
* Created By: Jamie Wooley
* Created Date: 18-01-2015 
*
* Changes:
*********************************************************************************/
@isTest
private class bg_OpportunityLineItem_Tests {

    public static final Integer BULK_VALUE = 5;

    @testSetup static void setupData() {

        Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ');
        insert qmsNewPB;

        List<Product2> productRecords = new List<Product2>();
        productRecords.add(bg_Product_TestUtils.createProduct('A', 'Consultation', 'Premium'));
        productRecords.add(bg_Product_TestUtils.createProduct(bg_Constants.REDUCTION_PRODUCT_TYPE, 'Consultation', 'Premium'));
        insert productRecords;

        // just needed for creating standard prices which SF insist on.
        List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[0].Id, 1000.0, 500.0, 600.0));
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[1].Id, 1000.0, 500.0, 600.0));
        insert stdPricebookEntries;

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[0].Id, 1000.0, 500.0, 600.0));
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(qmsNewPB.Id, productRecords[1].Id, 1000.0, 500.0, 600.0));
        insert pricebookEntries;

        Account account = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
        insert account;
    }

    /*
        same standard on a sites, client with 9 sites, single OLI
    */
    static testMethod void testMultiSiteSingleOLI(){
        /*
            Setup
        */
        
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];
        System.assert(priceBookEntry != null, 'null price book entry');

        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 9);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;

            System.assertEquals(priceBookEntry.Pricebook2Id, [select Pricebook2Id from opportunity where id = : opportunity.Id].Pricebook2Id, 'changed price book');

            OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
            insert oppLineItem;
        }
        Test.stopTest();

        /*
            Assertions
        */
        OpportunityLineItem updatedOppLineItem = [select Id, UnitPrice,TotalPrice from OpportunityLineItem limit 1];
        system.assertEquals(2000.0, updatedOppLineItem.UnitPrice);
        system.assertEquals(2000.0, updatedOppLineItem.TotalPrice);
    }

    /*
        same standard on all sites, client with 1 site, single OLI
    */
    static testMethod void testSingleSiteSingleOLI(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];

        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 1);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
            insert oppLineItem;
        }
        Test.stopTest();

        /*
            Assertions
        */
        OpportunityLineItem updatedOppLineItem = [select Id, UnitPrice,TotalPrice from OpportunityLineItem limit 1];
        system.assertEquals(1000.0, updatedOppLineItem.UnitPrice);
        system.assertEquals(1000.0, updatedOppLineItem.TotalPrice);
    }

    /*
        same standard on all sites, client with 3 sites, multi OLIs
    */
    static testMethod void testMultiSiteMultiOLI(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];

        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 3);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for (integer i=0; i < BULK_VALUE; i++)
            {
                OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
                oppLineItems.add(oppLineItem);
            }
            insert oppLineItems;
        }
        Test.stopTest();

        /*
            Assertions
        */
        List<OpportunityLineItem> updatedOppLineItems = [select Id, UnitPrice,TotalPrice from OpportunityLineItem];
        for (OpportunityLineItem updatedOppLineItem : updatedOppLineItems)
        {
            system.assertEquals(1000.0, updatedOppLineItem.UnitPrice);
            system.assertEquals(1000.0, updatedOppLineItem.TotalPrice);
        }
        
    }

    /*
        same standard on all sites, client with 1 site, multi OLIs
    */
    static testMethod void testSingleSiteMultiOLI(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];


        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 1);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for (integer i=0; i < BULK_VALUE; i++)
            {
                OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
                oppLineItems.add(oppLineItem);
            }
            insert oppLineItems;
        }
        Test.stopTest();

        /*
            Assertions
        */
        List<OpportunityLineItem> updatedOppLineItems = [select Id, UnitPrice,TotalPrice from OpportunityLineItem];
        for (OpportunityLineItem updatedOppLineItem : updatedOppLineItems)
        {
            system.assertEquals(1000.0, updatedOppLineItem.UnitPrice);
            system.assertEquals(1000.0, updatedOppLineItem.TotalPrice);
        }
        
    }

    /*
        different standard on sites, client with 3 sites, single OLI
    */
    static testMethod void testDifferentStandardsMultiSiteSingleOLI(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];

        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, false, 3);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
            insert oppLineItem;
        }
        Test.stopTest();

        /*
            Assertions
        */
        OpportunityLineItem updatedOppLineItem = [select Id, UnitPrice,TotalPrice from OpportunityLineItem limit 1];
        system.assertEquals(2200.0, updatedOppLineItem.UnitPrice);
        system.assertEquals(2200.0, updatedOppLineItem.TotalPrice);
    }

    /*
        different standard on sites, client with 1 site, single OLI
    */
    static testMethod void testDifferentStandardsSingleSiteSingleOLI(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];


        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, false, 1);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
            insert oppLineItem;
        }
        Test.stopTest();

        /*
            Assertions
        */
        OpportunityLineItem updatedOppLineItem = [select Id, UnitPrice,TotalPrice from OpportunityLineItem limit 1];
        system.assertEquals(1000.0, updatedOppLineItem.UnitPrice);
        system.assertEquals(1000.0, updatedOppLineItem.TotalPrice);
    }

    /*
        different standard on sites, client with 3 sites, multi OLIs
    */
    static testMethod void testDifferentStandardsMultiSiteMultiOLI(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];


        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, false, 3);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for (integer i=0; i < BULK_VALUE; i++)
            {
                OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
                oppLineItems.add(oppLineItem);
            }
            insert oppLineItems;
        }
        Test.stopTest();

        /*
            Assertions
        */
        List<OpportunityLineItem> updatedOppLineItems = [select Id, UnitPrice,TotalPrice from OpportunityLineItem];
        for (OpportunityLineItem updatedOppLineItem : updatedOppLineItems)
        {
            system.assertEquals(2200.0, updatedOppLineItem.UnitPrice);
            system.assertEquals(2200.0, updatedOppLineItem.TotalPrice);
        }
        
    }

    /*
        different standard on sites, client with 1 site, multi OLIs
    */
    static testMethod void testDifferentStandardSingleSiteMultiOLI(){
        /*
            Setup
        */
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;


        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 1);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for (integer i=0; i < BULK_VALUE; i++)
            {
                OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
                oppLineItems.add(oppLineItem);
            }
            insert oppLineItems;
        }
        Test.stopTest();

        /*
            Assertions
        */
        List<OpportunityLineItem> updatedOppLineItems = [select Id, UnitPrice,TotalPrice from OpportunityLineItem];
        for (OpportunityLineItem updatedOppLineItem : updatedOppLineItems)
        {
            system.assertEquals(1000.0, updatedOppLineItem.UnitPrice);
            system.assertEquals(1000.0, updatedOppLineItem.TotalPrice);
        }
        
    }

    /*
        different standard on sites, client with 3 sites, multi OLIs, but for a reduction product.
    */
    static testMethod void testDifferentStandardsMultiSiteMultiOLIReductions(){
        /*
            Setup
        */
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id, Pricebook2Id From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name = :bg_Constants.REDUCTION_PRODUCT_TYPE];


        /*
            Business Logic
        */
        Test.startTest();
        system.runAs(QMSUser)
        {
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, false, 3);
            opportunity.Pricebook2Id = priceBookEntry.Pricebook2Id;
            insert opportunity;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for (integer i=0; i < BULK_VALUE; i++)
            {
                OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 0.0, 1, 0.0);
                oppLineItems.add(oppLineItem);
            }
            insert oppLineItems;
        }
        Test.stopTest();

        /*
            Assertions
        */
        List<OpportunityLineItem> updatedOppLineItems = [select Id, UnitPrice,TotalPrice from OpportunityLineItem];
        for (OpportunityLineItem updatedOppLineItem : updatedOppLineItems)
        {
            system.assertEquals(0.0, updatedOppLineItem.UnitPrice);
            system.assertEquals(0.0, updatedOppLineItem.TotalPrice);
        }
        
    }

    /*
     * Calculate prices tests
     */
    @isTest static void Given_AnyInput_When_PricesAreCalculatedOnTheLineItem_TheCorrectPricesAreCalculatedWithoutError() {
        User userToRunAs = bg_User_TestUtils.createQMSSalesUser('1');
        System.runAs(userToRunAs)
        {
            PricebookEntry priceBookEntry = [Select Id, Product2Id, Product2.Name, Additional_Sites_Mixed_P_P__c From PriceBookEntry Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE];

            PricebookEntry priceBookEntryReduction = [Select Id, Product2Id, Product2.Name, Additional_Sites_Mixed_P_P__c From PriceBookEntry 
                                                        Where Pricebook2.Name = 'QMS CPQ' AND Product2.Name = :bg_Constants.REDUCTION_PRODUCT_TYPE];


            Account account = [Select Id From Account];

            List<Opportunity> opportunityRecords = new List<Opportunity>();
            opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, false, 3));
            opportunityRecords.add(bg_Opportunity_TestUtils.createDefaultCitationOpportunity('2', account.Id, false, 3));
            opportunityRecords.add(bg_Opportunity_TestUtils.createQMSOpportunity('3', account.Id, true, 3));
            opportunityRecords.add(bg_Opportunity_TestUtils.createDefaultCitationOpportunity('4', account.Id, true, 3));
            insert opportunityRecords;

            opportunityRecords = [Select Id, Sites_Visited__c, RecordTypeId, Same_Standard_On_All_Sites__c From Opportunity Order By Name ASC];
            
            List<OpportunityLineItem> opportunityLineItemRecords = new List<OpportunityLineItem>();
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[0].Id, pricebookEntry.Id, 5.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[1].Id, pricebookEntry.Id, 6.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[2].Id, pricebookEntry.Id, 7.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[3].Id, pricebookEntry.Id, 8.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[0].Id, priceBookEntryReduction.Id, 9.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[1].Id, priceBookEntryReduction.Id, 10.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[2].Id, priceBookEntryReduction.Id, 11.0, 1, 0.0));
            opportunityLineItemRecords.add(bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunityRecords[3].Id, priceBookEntryReduction.Id, 12.0, 1, 0.0));
            insert opportunityLineItemRecords;


            opportunityLineItemRecords = [Select Id, Additional_Sites_Price__c, UnitPrice, User_Sales_Price__c From OpportunityLineItem Where
                                          PriceBookEntry.Product2.Name != :bg_Constants.REDUCTION_PRODUCT_TYPE Order By Opportunity.Name];

            /*
             * Check the calculations
             */
            /*
             * QMS & not the same standaed on all sites
             */ 
            System.assertEquals(600, opportunityLineItemRecords[0].Additional_Sites_Price__c);
            System.assertEquals(1205, opportunityLineItemRecords[0].UnitPrice);
            System.assertEquals(5, opportunityLineItemRecords[0].User_Sales_Price__c);

            /*
             * Non-QMS & not the same standaed on all sites
             */ 
            System.assertEquals(0, opportunityLineItemRecords[1].Additional_Sites_Price__c);
            System.assertEquals(6, opportunityLineItemRecords[1].UnitPrice);
            System.assertEquals(0, opportunityLineItemRecords[1].User_Sales_Price__c);

            /*
             * QMS & the same standaed on all sites
             */ 
            System.assertEquals(500, opportunityLineItemRecords[2].Additional_Sites_Price__c);
            System.assertEquals(7, opportunityLineItemRecords[2].UnitPrice);
            System.assertEquals(7, opportunityLineItemRecords[2].User_Sales_Price__c);

            /*
             * Non-QMS & the same standaed on all sites
             */ 
            System.assertEquals(0, opportunityLineItemRecords[3].Additional_Sites_Price__c);
            System.assertEquals(8, opportunityLineItemRecords[3].UnitPrice);
            System.assertEquals(0, opportunityLineItemRecords[3].User_Sales_Price__c);

            opportunityLineItemRecords = [Select Id, Additional_Sites_Price__c, UnitPrice, User_Sales_Price__c From OpportunityLineItem Where
                                          PriceBookEntry.Product2.Name = :bg_Constants.REDUCTION_PRODUCT_TYPE Order By Opportunity.Name];
            /*
             * Reduction & QMS & not the same standaed on all sites
             */ 
            System.assertEquals(0, opportunityLineItemRecords[0].Additional_Sites_Price__c);
            System.assertEquals(9, opportunityLineItemRecords[0].UnitPrice);
            System.assertEquals(0, opportunityLineItemRecords[0].User_Sales_Price__c);

            /*
             * Reduction & Non-QMS & not the same standaed on all sites
             */ 
            System.assertEquals(0, opportunityLineItemRecords[1].Additional_Sites_Price__c);
            System.assertEquals(10, opportunityLineItemRecords[1].UnitPrice);
            System.assertEquals(0, opportunityLineItemRecords[1].User_Sales_Price__c);

            /*
             * Reduction & QMS & the same standaed on all sites
             */ 
            System.assertEquals(0, opportunityLineItemRecords[2].Additional_Sites_Price__c);
            System.assertEquals(11, opportunityLineItemRecords[2].UnitPrice);
            System.assertEquals(0, opportunityLineItemRecords[2].User_Sales_Price__c);

            /*
             * Reduction & Non-QMS & the same standaed on all sites
             */ 
            System.assertEquals(0, opportunityLineItemRecords[3].Additional_Sites_Price__c);
            System.assertEquals(12, opportunityLineItemRecords[3].UnitPrice);
            System.assertEquals(0, opportunityLineItemRecords[3].User_Sales_Price__c);
            
        }
    }

    /*static testMethod void testConnectQMS(){
        
        User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        insert pricebook;

        List<Product2> productRecords = new List<Product2>();
        productRecords.add(bg_Product_TestUtils.createProduct('QMS', 'Audit', 'Premium'));
        productRecords[0].Business_Type__c = 'QMS';
        insert productRecords;

        List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();
        stdPricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), productRecords[0].Id, 1000.0, 0.0, 0.0));
        insert stdPricebookEntries;

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        pricebookEntries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pricebook.Id, productRecords[0].Id, 1000.0, 0.0, 0.0));
        insert pricebookEntries;

        Account account = [Select Id From Account];
        PricebookEntry priceBookEntry = [Select Id From PriceBookEntry Where Pricebook2Id != :Test.getStandardPricebookId() AND Product2.Business_Type__c = 'QMS' limit 1];

        Id oplid = null;
        Test.startTest();
        system.runAs(QMSUser){
            Opportunity opportunity = bg_Opportunity_TestUtils.createQMSOpportunity('1', account.Id, true, 9);
            opportunity.Certification__c = bg_Constants.OPPORTUNITY_CERTIFICATION_CONNECT;
            opportunity.Connect_Certifications__c = 'ISO 9001';
            insert opportunity;

            OpportunityLineItem oppLineItem = bg_OpportunityLineItem_TestUtils.createOppLineItem(opportunity.Id, pricebookEntry.Id, 1000.0, 1, 0.0);
            insert oppLineItem;
            oplid = oppLineItem.Id;
        }
        Test.stopTest();

        OpportunityLineItem updatedOppLineItem = [select Id, UnitPrice,TotalPrice, Quantity from OpportunityLineItem where Id =: oplid limit 1];
        system.assertEquals(1000.00, updatedOppLineItem.UnitPrice);
        system.assertEquals(10000.00, updatedOppLineItem.TotalPrice);
        System.assertEquals(10, updatedOppLineItem.Quantity);
    }*/

}