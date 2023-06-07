/*
 * Copyright (c) 2011-2016 FinancialForce.com, inc. All rights reserved.
 */
@isTest
private class SCMCLLoadCatalogTests {

    static TestMethod void testLoadWithExisting() {
        
        string existingCatName = 'Cat1';
        string existingItemName = 'Item1';
        string existingCondition = 'NE';
        string existingSupplierName = 'Supplier1';
        string existingManufacturer = 'Manu1';
        
        SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c();
        curr.name = 'USD';
        curr.SCMC__Active__c = true;
        curr.SCMC__Corporate_Currency__c = true;
        insert curr;
        
        SCMC__Condition_Code__c cCode = new SCMC__Condition_Code__c();
        cCode.name = existingCondition;
        cCode.SCMC__Description__c = 'Description for New';
        cCode.SCMC__Disposal_Code__c = '1 - Excellent';    
        cCode.SCMC__Supply_Code__c = 'A - Serviceable';
        insert cCode;
        
        SCMC__Unit_of_Measure__c uom = new SCMC__Unit_of_Measure__c();
        uom.name = 'EA';
        insert uom;
        
        SCMC__Supplier_Site__c supp = new SCMC__Supplier_Site__c();
        supp.Name = existingSupplierName;
        supp.SCMC__E_Mail__c = 'a@b.com';
        supp.SCMC__Currency__c = curr.id;
        insert supp;
        
        SCMC__Manufacturer__c manu = new SCMC__Manufacturer__c();
        manu.name = existingManufacturer;
        insert manu;
        
        // add item master
        SCMC__Item__c item = new SCMC__Item__c();
        item.name = existingItemName;
        item.SCMC__Item_Description__c = 'Test part for unit tests';
        item.SCMC__Inspection_Required__c  = false;
        item.SCMC__Serial_Number_Control__c = false;
        item.SCMC__Lot_Number_Control__c = false;
        item.SCMC__Stocking_UOM__c = uom.id;
        insert item;
        
        // add product group
        SCMC__Product_Group__c pgroup = new SCMC__Product_Group__c();
        pgroup.name = 'Cisco';
        insert pgroup;
        
        // add catalogue
        SCMC__Supplier_Catalogue__c cat = new SCMC__Supplier_Catalogue__c();
        cat.SCMC__Supplier_Site__c = supp.Id;
        cat.SCMC__Catalogue_Name__c = existingCatName;
        cat.SCMC__Available_for_Use__c = true;
        insert cat;
        
        // add cat item
        SCMC__Supplier_Catalogue_Item__c catItem = new SCMC__Supplier_Catalogue_Item__c();
        catItem.SCMC__Supplier_Catalogue__c = cat.Id;
        catItem.SCMC__Item_Master__c = item.Id;
        //catItem.SCMC__New_Item_Number__c = item.name;
        catItem.SCMC__Active__c = true;
        catItem.SCMC__Manufacturer__c = manu.Id;
        insert catItem;
        
        // add price break
        SCMC__Supplier_Catalogue_Price_Break__c priceBreak = new SCMC__Supplier_Catalogue_Price_Break__c();
        priceBreak.SCMC__Supplier_Catalogue_Item__c = catItem.Id;
        priceBreak.SCMC__Price__c = 10.99;
        priceBreak.SCMC__Valid_Until_Quantity__c = 50;
        priceBreak.SCMC__Condition_Code__c = cCode.Id;
        insert priceBreak;
        
        // create catalog load
        List<SCMC__Catalog_Load__c> testLoad = new List<SCMC__Catalog_Load__c>();
        
        // load for existing cat, existing item, existing price break
        SCMC__Catalog_Load__c cat1 = new SCMC__Catalog_Load__c();
        cat1.SCMC__Catalog_Name__c = existingCatName;
        cat1.SCMC__Delivery_ARO__c = 10;
        cat1.SCMC__Item_Description__c = 'item 1';
        cat1.SCMC__Item_Number__c = existingItemName;
        cat1.SCMC__Item_Type__c = null;
        cat1.SCMC__Product_Group_Name__c = 'Cisco';
        cat1.SCMC__List_Price__c = 20.00;
        cat1.SCMC__Manufacturer__c = null;
        cat1.SCMC__Price__c = 17.50;
        cat1.SCMC__Supplier_Name__c = existingSupplierName;
        cat1.SCMC__Valid_Until_Date__c = priceBreak.SCMC__Valid_Until_Date__c;
        cat1.SCMC__Valid_Until_Quantity__c = priceBreak.SCMC__Valid_Until_Quantity__c;
        cat1.SCMC__Condition__c = existingCondition;
        cat1.SCMC__Replace__c = true;
   		cat1.SCMC__Currency__c = 'USD';
        testLoad.add(cat1);
        
        // existing cat, new item, new price break
        SCMC__Catalog_Load__c cat2 = new SCMC__Catalog_Load__c();
        cat2.SCMC__Catalog_Name__c = existingCatName;
        cat2.SCMC__Delivery_ARO__c = 10;
        cat2.SCMC__Item_Description__c = 'Newitem 1';
        cat2.SCMC__Item_Number__c = 'New Item1';
        cat1.SCMC__Item_Type__c = null;
        cat1.SCMC__Product_Group_Name__c = 'Cisco';
        
        cat2.SCMC__List_Price__c = 20.00;
        cat2.SCMC__Manufacturer__c = existingManufacturer;
        cat2.SCMC__Price__c = 17.50;
        cat2.SCMC__Supplier_Name__c = existingSupplierName;
        cat2.SCMC__Valid_Until_Date__c = null;
        cat2.SCMC__Valid_Until_Quantity__c = 100;
        cat2.SCMC__Condition__c = null;
        cat2.SCMC__Replace__c = false;
 	   	cat2.SCMC__Currency__c = 'USD';
        testLoad.add(cat2);
        
        insert testLoad;
        
        Test.startTest();
        
        ApexPages.Standardsetcontroller setController = new ApexPages.StandardSetController(testLoad);
        SCMCLLoadCatalogExtension ext = new SCMCLLoadCatalogExtension(setController);
        ext.process();
        
        Test.stopTest();
        
        // validate
        List<SCMC__Catalog_Load__c> refreshedLoad = [Select id, name
                , SCMC__Valid_Until_Quantity__c
                , SCMC__Valid_Until_Date__c
                , SCMC__Supplier_Unit_of_Measure__c
                , SCMC__Supplier_Name__c
                , SCMC__Price__c
                , SCMC__Manufacturer__c
                , SCMC__List_Price__c
                , SCMC__Item_Number__c
                , SCMC__Item_Description__c
                , SCMC__Delivery_ARO__c
                , SCMC__Condition__c
                , SCMC__Catalog_Name__c
                , SCMC__Replace__c
                , SCMC__Error__c
                , SCMC__Error_Message__c
            From SCMC__Catalog_Load__c];
        
        for (SCMC__Catalog_Load__c c : refreshedLoad) {
            system.assert(!c.SCMC__Error__c, 'expected no error. msg: ' + c.SCMC__Error_Message__c);
        }
        
        List<SCMC__Supplier_Catalogue__c> refreshedCatalogues = [select Id, name
                    , SCMC__Catalogue_Name__c 
                    , SCMC__Supplier_Site__c
                from SCMC__Supplier_Catalogue__c];
        system.debug('cats: ' + refreshedCatalogues);
        
        system.assertEquals(1, refreshedCatalogues.size(), 'unexpected number of catalogues');
        system.assertEquals(existingCatName, refreshedCatalogues[0].SCMC__Catalogue_Name__c, 'unexpected catalogue name');
        
        List<SCMC__Supplier_Catalogue_Item__c> refreshedItems = [select Id, name
                    , SCMC__Supplier_Unit_of_Measure__c
                    , SCMC__Supplier_Catalogue__c
                    , SCMC__New_Item_Number__c
                    , SCMC__New_Item_Description__c
                    , SCMC__Model_Applicability__c
                    , SCMC__Manufacturer__c
                    , SCMC__List_Price__c
                    , SCMC__Item_Master__c
                    , SCMC__Item_Description__c
                    , SCMC__Is_Preferred_Catalogue_Item__c
                    , SCMC__Delivery_ARO__c
                    , SCMC__Active__c
                    , SCMC__Item_Type__c
                    , SCMC__Product_Group__c
                    , (select Id, Name
                        , SCMC__Condition_Code_Description__c
                        , SCMC__Condition_Code__c
                        , SCMC__Price__c
                        , SCMC__Supplier_Catalogue_Item__c
                        , SCMC__Valid_Until_Date__c
                        , SCMC__Valid_Until_Quantity__c 
                        from SCMC__Supplier_Catalogue_Price_Breaks__r
                        order by SCMC__Valid_Until_Date__c) 
                from SCMC__Supplier_Catalogue_Item__c];
        System.debug('CatItems ' + refreshedItems);
        system.assertEquals(2, refreshedItems.size(), 'unexpected number of items');
        System.assertNotEquals(null, refreshedItems[0].SCMC__Product_Group__c);
        for (SCMC__Supplier_Catalogue_Item__c ci : refreshedItems) {
            system.debug('++breaks:' + ci.SCMC__Supplier_Catalogue_Price_Breaks__r);
            
            if (ci.SCMC__Item_Master__c != null) {
                system.assertEquals(2, ci.SCMC__Supplier_Catalogue_Price_Breaks__r.size(), 'unexpected number of breaks');
                system.assertEquals(system.today() - 1, ci.SCMC__Supplier_Catalogue_Price_Breaks__r[1].SCMC__Valid_Until_Date__c, 'should be invalidated');
                system.assertEquals(null, ci.SCMC__Supplier_Catalogue_Price_Breaks__r[0].SCMC__Valid_Until_Date__c, 'should be valid');
            } else {
                system.assertEquals(1, ci.SCMC__Supplier_Catalogue_Price_Breaks__r.size(), 'unexpected number of breaks');
            }
        }
    }
    static TestMethod void testLoadWithExisting3() {
        
        string existingCatName = 'Cat1';
        string existingItemName = 'Item1';
        string existingCondition = 'NE';
        string existingSupplierName = 'Supplier1';
        string existingManufacturer = 'Manu1';
        
        SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c();
        curr.name = 'USD';
        curr.SCMC__Active__c = true;
        curr.SCMC__Corporate_Currency__c = true;
        insert curr;
        
        SCMC__Condition_Code__c cCode = new SCMC__Condition_Code__c();
        cCode.name = existingCondition;
        cCode.SCMC__Description__c = 'Description for New';
        cCode.SCMC__Disposal_Code__c = '1 - Excellent';    
        cCode.SCMC__Supply_Code__c = 'A - Serviceable';
        insert cCode;
        
        SCMC__Unit_of_Measure__c uom = new SCMC__Unit_of_Measure__c();
        uom.name = 'EA';
        insert uom;
        
        SCMC__Supplier_Site__c supp = new SCMC__Supplier_Site__c();
        supp.Name = existingSupplierName;
        supp.SCMC__E_Mail__c = 'a@b.com';
        supp.SCMC__Currency__c = curr.id;
        insert supp;
        
        // add manufacturer
        SCMC__Manufacturer__c manu = new SCMC__Manufacturer__c();
        manu.name = existingManufacturer;
        insert manu;
        
        // add item master
        SCMC__Item__c item = new SCMC__Item__c();
        item.name = existingItemName;
        item.SCMC__Item_Description__c = 'Test part for unit tests';
        item.SCMC__Inspection_Required__c  = false;
        item.SCMC__Serial_Number_Control__c = false;
        item.SCMC__Lot_Number_Control__c = false;
        item.SCMC__Stocking_UOM__c = uom.id;
        insert item;
        
        // add catalogue
        SCMC__Supplier_Catalogue__c cat = new SCMC__Supplier_Catalogue__c();
        cat.SCMC__Supplier_Site__c = supp.Id;
        cat.SCMC__Catalogue_Name__c = existingCatName;
        cat.SCMC__Available_for_Use__c = true;
        insert cat;
        
        // add cat item
        SCMC__Supplier_Catalogue_Item__c catItem = new SCMC__Supplier_Catalogue_Item__c();
        catItem.SCMC__Supplier_Catalogue__c = cat.Id;
        catItem.SCMC__Item_Master__c = item.Id;
        catItem.SCMC__Active__c = true;
        catItem.SCMC__Manufacturer__c = manu.Id;
        insert catItem;
        
        // add price break
        SCMC__Supplier_Catalogue_Price_Break__c priceBreak = new SCMC__Supplier_Catalogue_Price_Break__c();
        priceBreak.SCMC__Supplier_Catalogue_Item__c = catItem.Id;
        priceBreak.SCMC__Price__c = 10.99;
        priceBreak.SCMC__Valid_Until_Quantity__c = 50;
        priceBreak.SCMC__Condition_Code__c = cCode.Id;
        insert priceBreak;
        
        // create catalog load
        List<SCMC__Catalog_Load__c> testLoad = new List<SCMC__Catalog_Load__c>();
        
        // load for existing cat, new item, new price break
        SCMC__Catalog_Load__c cat1 = new SCMC__Catalog_Load__c();
        cat1.SCMC__Catalog_Name__c = existingCatName;
        cat1.SCMC__Delivery_ARO__c = 10;
        cat1.SCMC__Item_Description__c = 'item 1';
        cat1.SCMC__Item_Number__c = existingItemName;
        cat1.SCMC__List_Price__c = 24.00;
        cat1.SCMC__Manufacturer__c = existingManufacturer;
        cat1.SCMC__Price__c = 17.50;
        cat1.SCMC__Supplier_Name__c = existingSupplierName;
        cat1.SCMC__Valid_Until_Date__c = null;
        cat1.SCMC__Valid_Until_Quantity__c = 500;
        cat1.SCMC__Condition__c = existingCondition;
        cat1.SCMC__Replace__c = true;
    	cat1.SCMC__Currency__c = 'USD';
        testLoad.add(cat1);
        
        // existing cat, existing item (new), existing price break (new)
        SCMC__Catalog_Load__c cat2 = new SCMC__Catalog_Load__c();
        cat2.SCMC__Catalog_Name__c = existingCatName;
        cat2.SCMC__Delivery_ARO__c = 10;
        cat2.SCMC__Item_Description__c = 'item 1';
        cat2.SCMC__Item_Number__c = existingItemName;
        cat2.SCMC__List_Price__c = 20.00;
        cat2.SCMC__Manufacturer__c = existingManufacturer;
        cat2.SCMC__Price__c = 17.50;
        cat2.SCMC__Supplier_Name__c = existingSupplierName;
        cat2.SCMC__Valid_Until_Date__c = null;
        cat2.SCMC__Valid_Until_Quantity__c = 500;
        cat2.SCMC__Condition__c = existingCondition;
        cat2.SCMC__Replace__c = true;
   		cat2.SCMC__Currency__c = 'USD';
        testLoad.add(cat2);
        
        insert testLoad;
        
        Test.startTest();
        
        ApexPages.Standardsetcontroller setController = new ApexPages.StandardSetController(testLoad);
        SCMCLLoadCatalogExtension ext = new SCMCLLoadCatalogExtension(setController);
        ext.process();
        
        Test.stopTest();
        
        // validate
        List<SCMC__Catalog_Load__c> refreshedLoad = [Select id, name
                , SCMC__Valid_Until_Quantity__c
                , SCMC__Valid_Until_Date__c
                , SCMC__Supplier_Unit_of_Measure__c
                , SCMC__Supplier_Name__c
                , SCMC__Price__c
                , SCMC__Manufacturer__c
                , SCMC__List_Price__c
                , SCMC__Item_Number__c
                , SCMC__Item_Description__c
                , SCMC__Delivery_ARO__c
                , SCMC__Condition__c
                , SCMC__Catalog_Name__c
                , SCMC__Replace__c
                , SCMC__Error__c
                , SCMC__Error_Message__c
            From SCMC__Catalog_Load__c];
        
        if (refreshedLoad[0].SCMC__Error__c) {
            system.assertEquals(true, refreshedLoad[0].SCMC__Error__c, 'expecting error');
            system.debug('erro msg:' + refreshedLoad[0].SCMC__Error__c);
        } else {
            system.assertEquals(true, refreshedLoad[1].SCMC__Error__c, 'expecting error');
            system.debug('erro msg:' + refreshedLoad[1].SCMC__Error__c);
        }
        
        List<SCMC__Supplier_Catalogue__c> refreshedCatalogues = [select Id, name
                    , SCMC__Catalogue_Name__c 
                    , SCMC__Supplier_Site__c
                from SCMC__Supplier_Catalogue__c];
        system.debug('cats: ' + refreshedCatalogues);
        
        system.assertEquals(1, refreshedCatalogues.size(), 'unexpected number of catalogues');
        system.assertEquals(existingCatName, refreshedCatalogues[0].SCMC__Catalogue_Name__c, 'unexpected catalogue name');
        
        List<SCMC__Supplier_Catalogue_Item__c> refreshedItems = [select Id, name
                    , SCMC__Supplier_Unit_of_Measure__c
                    , SCMC__Supplier_Catalogue__c
                    , SCMC__New_Item_Number__c
                    , SCMC__New_Item_Description__c
                    , SCMC__Model_Applicability__c
                    , SCMC__Manufacturer__c
                    , SCMC__List_Price__c
                    , SCMC__Item_Master__c
                    , SCMC__Item_Description__c
                    , SCMC__Is_Preferred_Catalogue_Item__c
                    , SCMC__Delivery_ARO__c
                    , SCMC__Active__c
                    , (select Id, Name
                        , SCMC__Condition_Code_Description__c
                        , SCMC__Condition_Code__c
                        , SCMC__Price__c
                        , SCMC__Supplier_Catalogue_Item__c
                        , SCMC__Valid_Until_Date__c
                        , SCMC__Valid_Until_Quantity__c 
                        from SCMC__Supplier_Catalogue_Price_Breaks__r
                        order by SCMC__Valid_Until_Date__c) 
                from SCMC__Supplier_Catalogue_Item__c];
        system.assertEquals(1, refreshedItems.size(), 'unexpected number of items');
        for (SCMC__Supplier_Catalogue_Item__c ci : refreshedItems) {
            system.debug('++breaks:' + ci.SCMC__Supplier_Catalogue_Price_Breaks__r);
            
            system.assertEquals(2, ci.SCMC__Supplier_Catalogue_Price_Breaks__r.size(), 'unexpected number of breaks');
            system.assertEquals(null, ci.SCMC__Supplier_Catalogue_Price_Breaks__r[0].SCMC__Valid_Until_Date__c, 'should be valid');
            system.assertEquals(null, ci.SCMC__Supplier_Catalogue_Price_Breaks__r[1].SCMC__Valid_Until_Date__c, 'should be valid');
        }
    }
    
    static TestMethod void testLoadWithExisting2() {
        
        string existingCatName = 'Cat1';
        string existingItemName = 'Item1';
        string existingCondition = 'NE';
        string existingSupplierName = 'Supplier1';
        string existingManufacturer = 'Manu1';
        
        SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c();
        curr.name = 'USD';
        curr.SCMC__Active__c = true;
        curr.SCMC__Corporate_Currency__c = true;
        insert curr;
        
        SCMC__Condition_Code__c cCode = new SCMC__Condition_Code__c();
        cCode.name = existingCondition;
        cCode.SCMC__Description__c = 'Description for New';
        cCode.SCMC__Disposal_Code__c = '1 - Excellent';    
        cCode.SCMC__Supply_Code__c = 'A - Serviceable';
        insert cCode;
        
        SCMC__Unit_of_Measure__c uom = new SCMC__Unit_of_Measure__c();
        uom.name = 'EA';
        insert uom;
        
        SCMC__Supplier_Site__c supp = new SCMC__Supplier_Site__c();
        supp.Name = existingSupplierName;
        supp.SCMC__E_Mail__c = 'a@b.com';
        supp.SCMC__Currency__c = curr.id;
        insert supp;
        
        // add manufacturer
        SCMC__Manufacturer__c manu = new SCMC__Manufacturer__c();
        manu.name = existingManufacturer;
        insert manu;
        
        // add item master
        SCMC__Item__c item = new SCMC__Item__c();
        item.name = existingItemName;
        item.SCMC__Item_Description__c = 'Test part for unit tests';
        item.SCMC__Inspection_Required__c  = false;
        item.SCMC__Serial_Number_Control__c = false;
        item.SCMC__Lot_Number_Control__c = false;
        item.SCMC__Stocking_UOM__c = uom.id;
        insert item;
        
        // add catalogue
        SCMC__Supplier_Catalogue__c cat = new SCMC__Supplier_Catalogue__c();
        cat.SCMC__Supplier_Site__c = supp.Id;
        cat.SCMC__Catalogue_Name__c = existingCatName;
        cat.SCMC__Available_for_Use__c = true;
        insert cat;
        
        // add cat item
        SCMC__Supplier_Catalogue_Item__c catItem = new SCMC__Supplier_Catalogue_Item__c();
        catItem.SCMC__Supplier_Catalogue__c = cat.Id;
        catItem.SCMC__Item_Master__c = item.Id;
        catItem.SCMC__Active__c = true;
        catItem.SCMC__Manufacturer__c = manu.Id;
        insert catItem;
        
        // add price break
        SCMC__Supplier_Catalogue_Price_Break__c priceBreak = new SCMC__Supplier_Catalogue_Price_Break__c();
        priceBreak.SCMC__Supplier_Catalogue_Item__c = catItem.Id;
        priceBreak.SCMC__Price__c = 10.99;
        priceBreak.SCMC__Valid_Until_Quantity__c = 50;
        priceBreak.SCMC__Condition_Code__c = cCode.Id;
        insert priceBreak;
        
        // create catalog load
        List<SCMC__Catalog_Load__c> testLoad = new List<SCMC__Catalog_Load__c>();
        
        // load for existing cat, new item, new price break
        SCMC__Catalog_Load__c cat1 = new SCMC__Catalog_Load__c();
        cat1.SCMC__Catalog_Name__c = existingCatName;
        cat1.SCMC__Delivery_ARO__c = 10;
        cat1.SCMC__Item_Description__c = 'item 1';
        cat1.SCMC__Item_Number__c = 'Newitem1';
        cat1.SCMC__List_Price__c = 24.00;
        cat1.SCMC__Manufacturer__c = existingManufacturer;
        cat1.SCMC__Price__c = 17.50;
        cat1.SCMC__Supplier_Name__c = existingSupplierName;
        cat1.SCMC__Valid_Until_Date__c = null;
        cat1.SCMC__Valid_Until_Quantity__c = 500;
        cat1.SCMC__Condition__c = existingCondition;
        cat1.SCMC__Replace__c = true;
    	cat1.SCMC__Currency__c = 'USD';
        testLoad.add(cat1);
        
        // existing cat, existing item (new), existing price break (new)
        SCMC__Catalog_Load__c cat2 = new SCMC__Catalog_Load__c();
        cat2.SCMC__Catalog_Name__c = existingCatName;
        cat2.SCMC__Delivery_ARO__c = 10;
        cat2.SCMC__Item_Description__c = 'item 1';
        cat2.SCMC__Item_Number__c = 'Newitem1';
        cat2.SCMC__List_Price__c = 20.00;
        cat2.SCMC__Manufacturer__c = existingManufacturer;
        cat2.SCMC__Price__c = 17.50;
        cat2.SCMC__Supplier_Name__c = existingSupplierName;
        cat2.SCMC__Valid_Until_Date__c = null;
        cat2.SCMC__Valid_Until_Quantity__c = 500;
        cat2.SCMC__Condition__c = existingCondition;
        cat2.SCMC__Replace__c = true;
   		cat2.SCMC__Currency__c = 'USD';
        testLoad.add(cat2);
        
        insert testLoad;
        
        Test.startTest();
        
        ApexPages.Standardsetcontroller setController = new ApexPages.StandardSetController(testLoad);
        SCMCLLoadCatalogExtension ext = new SCMCLLoadCatalogExtension(setController);
        ext.process();
        
        Test.stopTest();
        
        // validate
        List<SCMC__Catalog_Load__c> refreshedLoad = [Select id, name
                , SCMC__Valid_Until_Quantity__c
                , SCMC__Valid_Until_Date__c
                , SCMC__Supplier_Unit_of_Measure__c
                , SCMC__Supplier_Name__c
                , SCMC__Price__c
                , SCMC__Manufacturer__c
                , SCMC__List_Price__c
                , SCMC__Item_Number__c
                , SCMC__Item_Description__c
                , SCMC__Delivery_ARO__c
                , SCMC__Condition__c
                , SCMC__Catalog_Name__c
                , SCMC__Replace__c
                , SCMC__Error__c
                , SCMC__Error_Message__c
            From SCMC__Catalog_Load__c];
        
        if (refreshedLoad[0].SCMC__Error__c) {
            system.assertEquals(true, refreshedLoad[0].SCMC__Error__c, 'expecting error');
            system.debug('erro msg:' + refreshedLoad[0].SCMC__Error__c);
        } else {
            system.assertEquals(true, refreshedLoad[1].SCMC__Error__c, 'expecting error');
            system.debug('erro msg:' + refreshedLoad[1].SCMC__Error__c);
        }
        
        List<SCMC__Supplier_Catalogue__c> refreshedCatalogues = [select Id, name
                    , SCMC__Catalogue_Name__c 
                    , SCMC__Supplier_Site__c
                from SCMC__Supplier_Catalogue__c];
        system.debug('cats: ' + refreshedCatalogues);
        
        system.assertEquals(1, refreshedCatalogues.size(), 'unexpected number of catalogues');
        system.assertEquals(existingCatName, refreshedCatalogues[0].SCMC__Catalogue_Name__c, 'unexpected catalogue name');
        
        List<SCMC__Supplier_Catalogue_Item__c> refreshedItems = [select Id, name
                    , SCMC__Supplier_Unit_of_Measure__c
                    , SCMC__Supplier_Catalogue__c
                    , SCMC__New_Item_Number__c
                    , SCMC__New_Item_Description__c
                    , SCMC__Model_Applicability__c
                    , SCMC__Manufacturer__c
                    , SCMC__List_Price__c
                    , SCMC__Item_Master__c
                    , SCMC__Item_Description__c
                    , SCMC__Is_Preferred_Catalogue_Item__c
                    , SCMC__Delivery_ARO__c
                    , SCMC__Active__c
                    , (select Id, Name
                        , SCMC__Condition_Code_Description__c
                        , SCMC__Condition_Code__c
                        , SCMC__Price__c
                        , SCMC__Supplier_Catalogue_Item__c
                        , SCMC__Valid_Until_Date__c
                        , SCMC__Valid_Until_Quantity__c 
                        from SCMC__Supplier_Catalogue_Price_Breaks__r
                        order by SCMC__Valid_Until_Date__c) 
                from SCMC__Supplier_Catalogue_Item__c];
        System.debug('CatItems ' + refreshedItems);
        system.assertEquals(2, refreshedItems.size(), 'unexpected number of items');
        for (SCMC__Supplier_Catalogue_Item__c ci : refreshedItems) {
            system.debug('++breaks:' + ci.SCMC__Supplier_Catalogue_Price_Breaks__r);
            
            if (ci.SCMC__Item_Master__c != null) {
                system.assertEquals(1, ci.SCMC__Supplier_Catalogue_Price_Breaks__r.size(), 'unexpected number of breaks');
                system.assertEquals(null, ci.SCMC__Supplier_Catalogue_Price_Breaks__r[0].SCMC__Valid_Until_Date__c, 'should be valid');
            } else {
                system.assertEquals(1, ci.SCMC__Supplier_Catalogue_Price_Breaks__r.size(), 'unexpected number of breaks');
            }
        }
    }
    
	static TestMethod void testLoad() {
        
        SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c();
        curr.name = 'USD';
        curr.SCMC__Active__c = true;
        curr.SCMC__Corporate_Currency__c = true;
        insert curr;
        List<SCMC__Currency_Master__c>cmaster = [select id, name
        		from SCMC__Currency_Master__c
        		where SCMC__Corporate_Currency__c = true];
        System.assertEquals(1, cmaster.Size());
        
        SCMC__Supplier_Site__c supp = new SCMC__Supplier_Site__c();
        supp.Name = 'Supplier1';
        supp.SCMC__E_Mail__c = 'a@b.com';
        supp.SCMC__Currency__c = curr.id;
        insert supp;
        
        SCMC__Product_Group__c pgrp = new SCMC__Product_Group__c(name='Cisco');
        insert pgrp;
        
        // new cat, net item, new pb
        List<SCMC__Catalog_Load__c> testLoad = new List<SCMC__Catalog_Load__c>();
        SCMC__Catalog_Load__c cat1 = new SCMC__Catalog_Load__c();
        cat1.SCMC__Catalog_Name__c = 'New Cat 1';
        cat1.SCMC__Delivery_ARO__c = 10;
        cat1.SCMC__Item_Description__c = 'item 1';
        cat1.SCMC__Item_Number__c = 'Item1';
        cat1.SCMC__List_Price__c = 20.00;
        cat1.SCMC__Manufacturer__c = null;
        cat1.SCMC__Price__c = 17.50;
        cat1.SCMC__Supplier_Name__c = 'Supplier1';
        cat1.SCMC__Valid_Until_Date__c = null;
        cat1.SCMC__Valid_Until_Quantity__c = 100;
        cat1.SCMC__Condition__c = null;
   		cat1.SCMC__Currency__c = 'USD';
   		cat1.SCMC__Item_Type__c = null;
   		cat1.SCMC__Product_Group_Name__c = 'Cisco';
        testLoad.add(cat1);
        
        // existing (curr batch), existing item (curr batch), new pb
        SCMC__Catalog_Load__c cat2 = new SCMC__Catalog_Load__c();
        cat2.SCMC__Catalog_Name__c = 'New Cat 1';
        cat2.SCMC__Delivery_ARO__c = 10;
        cat2.SCMC__Item_Description__c = 'item 1';
        cat2.SCMC__Item_Number__c = 'Item1';
        cat2.SCMC__List_Price__c = 20.00;
        cat2.SCMC__Manufacturer__c = null;
        cat2.SCMC__Price__c = 17.50;
        cat2.SCMC__Supplier_Name__c = 'Supplier1';
        cat2.SCMC__Valid_Until_Date__c = null;
        cat2.SCMC__Valid_Until_Quantity__c = 200;
        cat2.SCMC__Condition__c = null;
   		cat2.SCMC__Currency__c = 'USD';
    	cat2.SCMC__Item_Type__c = null;
   		cat2.SCMC__Product_Group_Name__c = 'Cisco';
        testLoad.add(cat2);
        
        insert testLoad;
        
        Test.startTest();
        
        ApexPages.Standardsetcontroller setController = new ApexPages.StandardSetController(testLoad);
        SCMCLLoadCatalogExtension ext = new SCMCLLoadCatalogExtension(setController);
        ext.process();
        
        Test.stopTest();
        
        List<SCMC__Catalog_Load__c> refreshedLoad = [Select id, name
                , SCMC__Valid_Until_Quantity__c
                , SCMC__Valid_Until_Date__c
                , SCMC__Supplier_Unit_of_Measure__c
                , SCMC__Supplier_Name__c
                , SCMC__Price__c
                , SCMC__Manufacturer__c
                , SCMC__List_Price__c
                , SCMC__Item_Number__c
                , SCMC__Item_Description__c
                , SCMC__Delivery_ARO__c
                , SCMC__Condition__c
                , SCMC__Catalog_Name__c
                , SCMC__Replace__c
                , SCMC__Error__c
                , SCMC__Error_Message__c
            From SCMC__Catalog_Load__c];
        
        for (SCMC__Catalog_Load__c c : refreshedLoad) {
            system.assert(!c.SCMC__Error__c, 'expected no error. msg: ' + c.SCMC__Error_Message__c);
        }
        
        List<SCMC__Supplier_Catalogue__c> refreshedCatalogues = [select Id, name
                    , SCMC__Catalogue_Name__c 
                    , SCMC__Supplier_Site__c
                from SCMC__Supplier_Catalogue__c];
        system.debug('cats: ' + refreshedCatalogues);
        
        system.assertEquals(1, refreshedCatalogues.size(), 'unexpected number of catalogues');
        system.assertEquals('New Cat 1', refreshedCatalogues[0].SCMC__Catalogue_Name__c, 'unexpected catalogue name');
        
        List<SCMC__Supplier_Catalogue_Item__c> refreshedItems = [select Id, name
                    , SCMC__Supplier_Unit_of_Measure__c
                    , SCMC__Supplier_Catalogue__c
                    , SCMC__New_Item_Number__c
                    , SCMC__New_Item_Description__c
                    , SCMC__Model_Applicability__c
                    , SCMC__Manufacturer__c
                    , SCMC__List_Price__c
                    , SCMC__Item_Master__c
                    , SCMC__Item_Description__c
                    , SCMC__Is_Preferred_Catalogue_Item__c
                    , SCMC__Delivery_ARO__c
                    , SCMC__Active__c
                    , SCMC__Item_Type__c
                    , SCMC__Product_Group__c
                    , (select Id, Name
                        , SCMC__Condition_Code_Description__c
                        , SCMC__Condition_Code__c
                        , SCMC__Price__c
                        , SCMC__Supplier_Catalogue_Item__c
                        , SCMC__Valid_Until_Date__c
                        , SCMC__Valid_Until_Quantity__c 
                        from SCMC__Supplier_Catalogue_Price_Breaks__r) 
                from SCMC__Supplier_Catalogue_Item__c];
        system.assertEquals(1, refreshedItems.size(), 'unexpected number of items');
        System.assertNotEquals(null, refreshedItems[0].SCMC__Product_Group__c);
        system.assertEquals(2, refreshedItems[0].SCMC__Supplier_Catalogue_Price_Breaks__r.size(), 'unexpected number of breaks');
    }
	
    static TestMethod void testLoadError() {
        
        SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c();
        curr.name = 'USD';
        curr.SCMC__Active__c = true;
        curr.SCMC__Corporate_Currency__c = true;
        insert curr;
        List<SCMC__Currency_Master__c>cmaster = [select id, name
        		from SCMC__Currency_Master__c
        		where SCMC__Corporate_Currency__c = true];
        System.assertEquals(1, cmaster.Size());
     /*   
        SCMC__Supplier_Site__c supp = new SCMC__Supplier_Site__c();
        supp.Name = 'Supplier1';
        supp.SCMC__E_Mail__c = 'a@b.com';
        supp.SCMC__Currency__c = curr.id;
        insert supp; */
        
        SCMC__Product_Group__c pgrp = new SCMC__Product_Group__c(name='Cisco');
        insert pgrp;
        
        // new cat, net item, new pb
        List<SCMC__Catalog_Load__c> testLoad = new List<SCMC__Catalog_Load__c>();
        SCMC__Catalog_Load__c cat1 = new SCMC__Catalog_Load__c();
        cat1.SCMC__Catalog_Name__c = 'New Cat 1';
        cat1.SCMC__Delivery_ARO__c = 10;
        cat1.SCMC__Item_Description__c = 'item 1';
        cat1.SCMC__Item_Number__c = 'Item1';
        cat1.SCMC__List_Price__c = 20.00;
        cat1.SCMC__Manufacturer__c = null;
        cat1.SCMC__Price__c = 17.50;
        cat1.SCMC__Supplier_Name__c = 'Supplier1';
        cat1.SCMC__Valid_Until_Date__c = null;
        cat1.SCMC__Valid_Until_Quantity__c = 100;
        cat1.SCMC__Condition__c = null;
   		cat1.SCMC__Currency__c = 'USD';
   		cat1.SCMC__Item_Type__c = null;
   		cat1.SCMC__Product_Group_Name__c = 'Cisco';
        testLoad.add(cat1);
        
        // existing (curr batch), existing item (curr batch), new pb
        SCMC__Catalog_Load__c cat2 = new SCMC__Catalog_Load__c();
        cat2.SCMC__Catalog_Name__c = 'New Cat 1';
        cat2.SCMC__Delivery_ARO__c = 10;
        cat2.SCMC__Item_Description__c = 'item 1';
        cat2.SCMC__Item_Number__c = 'Item1';
        cat2.SCMC__List_Price__c = 20.00;
        cat2.SCMC__Manufacturer__c = null;
        cat2.SCMC__Price__c = 17.50;
        cat2.SCMC__Supplier_Name__c = 'Supplier1';
        cat2.SCMC__Valid_Until_Date__c = null;
        cat2.SCMC__Valid_Until_Quantity__c = 200;
        cat2.SCMC__Condition__c = null;
   		cat2.SCMC__Currency__c = 'USD';
    	cat2.SCMC__Item_Type__c = null;
   		cat2.SCMC__Product_Group_Name__c = 'Cisco';
        testLoad.add(cat2);
        
        insert testLoad;
        
        Test.startTest();
        
        ApexPages.Standardsetcontroller setController = new ApexPages.StandardSetController(testLoad);
        SCMCLLoadCatalogExtension ext = new SCMCLLoadCatalogExtension(setController);
        ext.process();
        
        Test.stopTest();
        
        List<SCMC__Catalog_Load__c> refreshedLoad = [Select id, name
                , SCMC__Valid_Until_Quantity__c
                , SCMC__Valid_Until_Date__c
                , SCMC__Supplier_Unit_of_Measure__c
                , SCMC__Supplier_Name__c
                , SCMC__Price__c
                , SCMC__Manufacturer__c
                , SCMC__List_Price__c
                , SCMC__Item_Number__c
                , SCMC__Item_Description__c
                , SCMC__Delivery_ARO__c
                , SCMC__Condition__c
                , SCMC__Catalog_Name__c
                , SCMC__Replace__c
                , SCMC__Error__c
                , SCMC__Error_Message__c
            From SCMC__Catalog_Load__c];
        
        for (SCMC__Catalog_Load__c c : refreshedLoad) {
            system.assertEquals('Supplier not found.', c.SCMC__Error_Message__c);
        }
    }
}