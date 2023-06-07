/*
 * Copyright (c) 2011-2016 FinancialForce.com, inc. All rights reserved.
 */
global with sharing class SCMCLLoadCatalog implements Database.Batchable<SObject>{
    
	global Database.QueryLocator start(Database.BatchableContext ctx) {
        // Select all catalogs that haven't been loaded yet
        return Database.getQueryLocator([Select id, name
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
        		, SCMC__Currency__c
                , SCMC__Catalog_Name__c
                , SCMC__Replace__c
                , SCMC__Item_Type__c
                , SCMC__Product_Group_Name__c
                , SCMC__Error__c
                , SCMC__Error_Message__c
            From SCMC__Catalog_Load__c 
            where SCMC__Loaded__c = false 
				and SCMC__Error__c = false]);
    }
    
    global void execute(Database.BatchableContext ctx, List<SObject> records) {
        List<SCMC__Catalog_Load__c> loads = new List<SCMC__Catalog_Load__c>();
        Map<string, SCMC__Supplier_Catalogue__c> catalogues = new Map<string, SCMC__Supplier_Catalogue__c>();
        Map<Id, List<SCMC__Supplier_Catalogue_Item__c>> catalogueItems = new Map<Id, List<SCMC__Supplier_Catalogue_Item__c>>();
        Map<string, SCMC__Supplier_Site__c> suppliers = new Map<string, SCMC__Supplier_Site__c>();
        Map<string, SCMC__Item__c> items = new Map<string, SCMC__Item__c>();
        Map<string, SCMC__Manufacturer__c> manufacturers = new Map<string, SCMC__Manufacturer__c>();
        Map<string, SCMC__Condition_Code__c> conds = new Map<string, SCMC__Condition_Code__c>();
    	Map<string, SCMC__Currency_Master__c> cmcodes = new Map<string, SCMC__Currency_Master__c>();
    	Map<String, SCMC__Product_Group__c>pgroups = new Map<String, SCMC__Product_Group__c>();
        
        // collect references
        for (SObject record : records) {
            SCMC__Catalog_Load__c load = (SCMC__Catalog_Load__c)record;
            loads.add(load);
            
            catalogues.put(load.SCMC__Catalog_Name__c, null);
            
            suppliers.put(load.SCMC__Supplier_Name__c, null);
            
            items.put(load.SCMC__Item_Number__c, null);
            
            if (load.SCMC__Product_Group_Name__c != null){
            	pgroups.put(load.SCMC__Product_Group_Name__c, null);
            }
            
            if (load.SCMC__Manufacturer__c != null) {
                manufacturers.put(load.SCMC__Manufacturer__c, null);
            }
            
            if (load.SCMC__Condition__c != null) {
                conds.put(load.SCMC__Condition__c, null);
            }
        }
        
        // query all the references
        Set<Id> catalogueIds = new Set<Id>();
        List<SCMC__Supplier_Catalogue__c> supplierCatalogs = [select Id, name
                    , SCMC__Catalogue_Name__c 
                    , SCMC__Supplier_Site__c
                from SCMC__Supplier_Catalogue__c
                where SCMC__Catalogue_Name__c in :catalogues.keySet()];
        for (SCMC__Supplier_Catalogue__c c : supplierCatalogs) {
            catalogues.put(c.SCMC__Catalogue_Name__c.toLowerCase(), c);
            catalogueIds.add(c.Id);
        }
        
        List<SCMC__Supplier_Catalogue_Item__c> supplierCatalogueItems = [select Id, name 
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
                from SCMC__Supplier_Catalogue_Item__c
                where SCMC__Supplier_Catalogue__c in :catalogueIds and 
                	(SCMC__new_item_number__c in :items.Keyset() or
                		SCMC__Item_Master__r.name in :items.Keyset())
                    AND SCMC__Active__c = true];
        for (SCMC__Supplier_Catalogue_Item__c i : supplierCatalogueItems) {
            List<SCMC__Supplier_Catalogue_Item__c> currItems = catalogueItems.get(i.SCMC__Supplier_Catalogue__c);
            if (currItems == null) {
                currItems = new List<SCMC__Supplier_Catalogue_Item__c>();
            }

            currItems.add(i);
            catalogueItems.put(i.SCMC__Supplier_Catalogue__c, currItems);
        }
        
        List<SCMC__Supplier_Site__c> supplierSites = [select Id, Name
                from SCMC__Supplier_Site__c
                where name in :suppliers.keySet()];
        for (SCMC__Supplier_Site__c site : supplierSites) {
            suppliers.put(site.name.toLowerCase(), site);
        }
        
        List<SCMC__Item__c> itemMasters = [select id, name
					,SCMC__Serial_Number_Control__c
					,SCMC__Lot_Number_Control__c
                 from SCMC__Item__c
                where name in :items.Keyset()];
        for (SCMC__Item__c master : itemMasters){
            items.put(master.name.toLowerCase(), master);
        }
        
        List<SCMC__Manufacturer__c> manus = [select Id, name
                from SCMC__Manufacturer__c
                where name in :manufacturers.keySet()];
        for (SCMC__Manufacturer__c m : manus) {
            manufacturers.put(m.name.toLowerCase(), m);
        }
        
        List<SCMC__Product_Group__c>pgrp = [select id, name
        		from SCMC__Product_Group__c
        		where name in :pgroups.keyset()];
        for (SCMC__Product_Group__c p : pgrp){
        	pgroups.put(p.name.toLowerCase(), p);
        }
        
        List<SCMC__Condition_Code__c> ccodes = [select id, name from SCMC__Condition_Code__c
                where name in :conds.Keyset()];
        for (SCMC__Condition_Code__c ccode : ccodes){
            conds.put(ccode.name.toLowerCase(), ccode);
        }
   		List<SCMC__Currency_Master__c> currs = [select id, name from SCMC__Currency_Master__c];
     	for (SCMC__Currency_Master__c curr : currs){
    		cmcodes.put(curr.name, curr);
    	}
        
        boolean addNewCatalogue = true;
        
        Map<string, CatalogueExtended> catalogueExtToUpdate = new Map<string, CatalogueExtended>();
        List<CatalogueExtended> catalogueExtendeds = new List<CatalogueExtended>();
        
        //loop through the records, validate and load
        for (SCMC__Catalog_Load__c load : loads) {
            // reset error
            load.SCMC__Error__c = false;
            load.SCMC__Error_Message__c = '';
            
            try {
                // get current references
                SCMC__Supplier_Site__c currSupplierSite = suppliers.get(load.SCMC__Supplier_Name__c.toLowerCase());
                SCMC__Item__c currItem = items.get(load.SCMC__Item_Number__c.toLowerCase());
                SCMC__Manufacturer__c currManufacturer = null;
                if (load.SCMC__Manufacturer__c != null) {
                    currManufacturer = manufacturers.get(load.SCMC__Manufacturer__c.toLowerCase());
                }
                SCMC__Product_Group__c currProdGroup = null;
                if (load.SCMC__Product_Group_Name__c != null) {
                	currProdGroup = pgroups.get(load.SCMC__Product_Group_Name__c.toLowerCase());
                }
                SCMC__Condition_Code__c currConditionCode = null;
                if (load.SCMC__Condition__c != null) {
                    currConditionCode = conds.get(load.SCMC__Condition__c.toLowerCase());
                }
                
                // lookup catalog name; add if doesn't exist?
                CatalogueExtended currCatExt = null;
                SCMC__Supplier_Catalogue__c currCatalogue = null;
                
                // check cat extendeds first
                for (CatalogueExtended ce : catalogueExtendeds) {
                    system.debug('looking in new catalogues; ' + ce.catalogue.SCMC__Catalogue_Name__c + ' - ' + load.SCMC__Catalog_Name__c);
                    if (ce.catalogue.SCMC__Catalogue_Name__c == load.SCMC__Catalog_Name__c) {
                        currCatalogue = ce.catalogue;
                        currCatExt = ce;
                    }
                }
                
                if (currCatalogue == null) {
                    system.debug('not found in cat ext: ' + catalogueExtendeds);
                    
                    currCatalogue = catalogues.get(load.SCMC__Catalog_Name__c.toLowerCase());
                    
                    if (currCatalogue == null) {
                        system.debug('not found in existing cats');
                        if (addNewCatalogue) {
                            system.debug('adding new cat');
                            currCatalogue = new SCMC__Supplier_Catalogue__c();
                            currCatalogue.SCMC__Catalogue_Name__c = load.SCMC__Catalog_Name__c;
                            if (currSupplierSite != null) {
                                currCatalogue.SCMC__Supplier_Site__c = currSupplierSite.Id;
                            } else {
                                load.SCMC__Error__c = true;
                                load.SCMC__Error_Message__c += '\nSupplier not found.';
                            }
                        } else {
                            load.SCMC__Error__c = true;
                            load.SCMC__Error_Message__c += '\nCatalogue not found.';
                            continue;
                        }
                    }
                } else {
                    system.debug('+++found in existing cat ext');
                    if (currCatalogue.SCMC__Supplier_Site__c != currSupplierSite.Id && currSupplierSite != null) {
                        load.SCMC__Error__c = true;
                        load.SCMC__Error_Message__c += '\nSupplier site not associated with Catalogue';
                    }
                }
                
                if (currCatExt == null) {
                    system.debug('curr cat ext is null. creating new');
                    currCatExt = new CatalogueExtended(currCatalogue);
                }
                
                // +++++++++++++++++++++++++
                // look up catalog item; add if doesn't exist (update, if not?)
                SCMC__Supplier_Catalogue_Item__c currCatalogueItem = null;
                CatalogueItemExtended currCatItemExt = null;
                
                // check extendeds first
                // need to look in new catalogue items created in this batch
                system.debug('look up cat item: ' + load.SCMC__Item_Number__c);
                currCatItemExt = currCatExt.FindItem(currItem, load.SCMC__Item_Number__c);
                system.debug('what we found in new items: ' + currCatItemExt);
                if (currCatItemExt != null) { 
                    currCatalogueItem = currCatItemExt.catalogueItem;
                }
                
                if (currCatalogueItem == null) {
                    system.debug('not found in ext item');
                    List<SCMC__Supplier_Catalogue_Item__c> currCatalogueItems = catalogueItems.get(currCatalogue.Id);
                    
                    if (currCatalogueItems != null) {
                        // loop through list and find curr item - based on item number
                        // TODO: do we need to base this on other criteria?
                        system.debug('+++existing items found. curritem:' + currItem);
                        for (SCMC__Supplier_Catalogue_Item__c i : currCatalogueItems) {
                            if (currItem != null) {
                                if (i.SCMC__Item_Master__c == currItem.Id) {
                                    system.debug('found based on item master: ' + load.SCMC__Item_Number__c);
                                    currCatalogueItem = i;
                                    break;
                                }
                            } else {
                                if (i.SCMC__New_Item_Number__c == load.SCMC__Item_Number__c) {
                                    system.debug('found based on item new:' + load.SCMC__Item_Number__c);
                                    currCatalogueItem = i;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                if (currCatalogueItem == null) {
                    // create new if not found
                    system.debug('+++item not found. create new: ' + load.SCMC__Item_Number__c);
                    currCatalogueItem = new SCMC__Supplier_Catalogue_Item__c();
                }
                
                if (currCatItemExt == null) {
                    system.debug('+++create new cat item ext');
                    currCatItemExt = new CatalogueItemExtended(currCatalogueItem);
                    currCatExt.AddItem(currCatItemExt);
                }
                
                // populate/update fields
                if (currItem != null) {
                    currCatalogueItem.SCMC__Item_Master__c = currItem.Id;
                } else {
                    currCatalogueItem.SCMC__New_Item_Number__c = load.SCMC__Item_Number__c;
                    if (load.SCMC__Item_Description__c.length() > 50) {
                        currCatalogueItem.SCMC__New_Item_Description__c = load.SCMC__Item_Description__c.substring(0, 46) + '...';
                    } else {
                        currCatalogueItem.SCMC__New_Item_Description__c = load.SCMC__Item_Description__c;
                    }
                }
                currCatalogueItem.SCMC__List_Price__c = load.SCMC__List_Price__c;
                currCatalogueItem.SCMC__Delivery_ARO__c = load.SCMC__Delivery_ARO__c;
                if (currManufacturer != null && load.SCMC__Manufacturer__c != null) {
                    currCatalogueItem.SCMC__Manufacturer__c = currManufacturer.Id;
                }
                System.debug('product group ' + currProdGroup +' ' + load.SCMC__Product_Group_Name__c);
                if (currProdGroup != null && load.SCMC__Product_Group_Name__c != null ) {
                	currCatalogueItem.SCMC__Product_Group__c = currProdGroup.id;
                }
                currCatalogueItem.SCMC__Active__c = true;
                
                // +++++++++++++++++++++++++
                // look up price break. if exists, invalidate it. always add new break.
                SCMC__Supplier_Catalogue_Price_Break__c currPriceBreak = null;
                List<SCMC__Supplier_Catalogue_Price_Break__c> currPriceBreaks = currCatalogueItem.SCMC__Supplier_Catalogue_Price_Breaks__r;
                
                // search for existing
                Id condId = null;
                if (currConditionCode != null) {
                    condId = currConditionCode.Id;
                }
                
                if (currPriceBreaks != null) {
                    // loop through list and find curr price break - based on condition and valid until x fields
                    for (SCMC__Supplier_Catalogue_Price_Break__c p : currPriceBreaks) {
                        if (p.SCMC__Condition_Code__c == condId
                            && p.SCMC__Valid_Until_Date__c == load.SCMC__Valid_Until_Date__c
                            && p.SCMC__Valid_Until_Quantity__c == load.SCMC__Valid_Until_Quantity__c) {
							currPriceBreak = p;
							break;
						}
                    }
                }
                
                if (currPriceBreak == null) {
                    // need to look in new price breaks created in this batch
                    // if found, error. shouldn't have duplicates here.
                    system.debug('look in new price breaks');
                    currPriceBreak = currCatItemExt.FindBreak(load.SCMC__Valid_Until_Quantity__c, load.SCMC__Valid_Until_Date__c, condId);
                    system.debug('looked in new price breaks: ' + currPriceBreak);
                    if (currPriceBreak != null) {
                        system.debug('duplicate pbs found w/in batch');
                        load.SCMC__Error__c = true;
                        load.SCMC__Error_Message__c += '\nDuplicate price breaks found.';
                    }
                }
                
                if (load.SCMC__Replace__c) {
                    // if found, invalidate
                    if (currPriceBreak != null && !load.SCMC__Error__c) {
                        // invalidate curr break
                        currPriceBreak.SCMC__Valid_Until_Date__c = system.today() - 1;
                        currCatItemExt.AddPriceBreak(currPriceBreak);
                    }
                } else {
                    if (currPriceBreak != null && !load.SCMC__Error_Message__c.contains('Duplicate price breaks found')) {
                        // if found and not marked for replacement, error.
                        system.debug('found and not marked for replacement');
                        load.SCMC__Error__c = true;
                        load.SCMC__Error_Message__c += '\nDuplicate price breaks found.';
                    }
                }
                
                // add new
                SCMC__Supplier_Catalogue_Price_Break__c newPriceBreak = new SCMC__Supplier_Catalogue_Price_Break__c();
                if (currConditionCode != null) {
                    newPriceBreak.SCMC__Condition_Code__c = currConditionCode.Id;
                } else if (load.SCMC__Condition__c != null) {
                    load.SCMC__Error__c = true;
                    load.SCMC__Error_Message__c += '\nCondition code not found.';
                }
                newPriceBreak.SCMC__Price__c = load.SCMC__Price__c;
                newPriceBreak.SCMC__Valid_Until_Date__c = load.SCMC__Valid_Until_Date__c;
                newPriceBreak.SCMC__Valid_Until_Quantity__c = load.SCMC__Valid_Until_Quantity__c;
				//SCMC__Currency_Master__c pbcurr = cmcodes.get(load.SCMC__Currency__c);
				//System.assertNotEquals(null, pbcurr, load.SCMC__Currency__c);
				//newPriceBreak.CurrencyIsoCode = pbcurr.name;
				//newPriceBreak.SCMC__Currency__c = pbcurr.id;
                
                if (!load.SCMC__Error__c) {
                    load.SCMC__Loaded__c = true;
                    
                    system.debug('add new price break to cie');
                    currCatItemExt.AddPriceBreak(newPriceBreak);
                    
                    system.debug('add to cat ext');
                    // add to update list
                    catalogueExtendeds.add(currCatExt);
                    
                    string catName = currCatExt.catalogue.SCMC__Catalogue_Name__c;
                    if (!catalogueExtToUpdate.containsKey(catName)) {
                        catalogueExtToUpdate.put(catName, currCatExt);
                    }
                }
            }
            catch (Exception ex) {
                load.SCMC__Error__c = true;
                load.SCMC__Error_Message__c = 'Exception: ' + ex.getMessage() + '[ln: ' + ex.getLineNumber() + ']';
            }
        }

        // ==========================
        // update
        update loads;
        
        List<SCMC__Supplier_Catalogue__c> updCatalogues = new List<SCMC__Supplier_Catalogue__c>();
        for (CatalogueExtended ce : catalogueExtToUpdate.values()) {
            updCatalogues.add(ce.catalogue);
        }
        if (updCatalogues.size() > 0) {
            upsert updCatalogues;
        }
        
        List<CatalogueItemExtended> updItemExts = new List<CatalogueItemExtended>();
        for (CatalogueExtended ce : catalogueExtToUpdate.values()) {
            updItemExts.addAll(ce.updateCatalogueId());
            system.debug('new total of cies:' + updItemExts.size());
        }
        
        List<SCMC__Supplier_Catalogue_Item__c> updCatalogueItems = new List<SCMC__Supplier_Catalogue_Item__c>();
        system.debug('total of cies:' + updItemExts.size());
        for (CatalogueItemExtended cie : updItemExts) {
            updCatalogueItems.add(cie.catalogueItem);
        }
        system.debug('new total of cis to upd:' + updCatalogueItems.size());
        if (updCatalogueItems.size() > 0) {
            upsert updCatalogueItems;
        }

        List<SCMC__Supplier_Catalogue_Price_Break__c> updPriceBreaks = new List<SCMC__Supplier_Catalogue_Price_Break__c>();
        for (CatalogueItemExtended cie : updItemExts) {
            updPriceBreaks.addAll(cie.updateCatalogueItemIds());
        }
        if (updPriceBreaks.size() > 0) {
            upsert updPriceBreaks;
        }
    }
    
    global void finish(Database.BatchableContext ctx){
        AsyncApexJob a = [Select Id
                        , Status
                        , NumberOfErrors
                        , JobItemsProcessed
                        , TotalJobItems
                        , CreatedBy.Email
                     from AsyncApexJob 
                     where Id = :ctx.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);

        string subj = 'Catalog Load Batch Process Complete';
        string mailBody = 'The batch job Catalog Load is complete.';
        mail.setSubject(subj);
        mail.setPlainTextBody(mailBody);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception ex) {
            SCMC.ErrorLog.log('LoadCatalog.finish','Error sending email.', ex, mailBody);
        }
    }
    
    
    public class CatalogueExtended {
        
        public SCMC__Supplier_Catalogue__c catalogue {get; set;}
        public List<CatalogueItemExtended> catalogueItemExtendeds { get; set;}
        
        public CatalogueExtended(SCMC__Supplier_Catalogue__c cat) {
            catalogue = cat;
            catalogueItemExtendeds = new List<CatalogueItemExtended>();
            system.debug('in ce const. cie: ' + catalogueItemExtendeds.size());
        }
        
        public void AddItem(CatalogueItemExtended catalogueItemExt) {
            system.debug('in addItem(cie)');
            catalogueItemExtendeds.add(catalogueItemExt);
            system.debug('total items: ' + catalogueItemExtendeds.size());
        }
        
        public CatalogueItemExtended FindItem(SCMC__Item__c item, string itemNumber) {
            CatalogueItemExtended currItemExt = null;
            system.debug('in cat: ' + catalogueItemExtendeds);
            system.debug('cie: ' + catalogueItemExtendeds.size());
            if (catalogueItemExtendeds.size() > 0) {
                system.debug('size > 0');
                for (CatalogueItemExtended cie : catalogueItemExtendeds) {
                    if (item != null) {
                        if (cie.catalogueItem.SCMC__Item_Master__c == item.Id) {
                            currItemExt = cie;
                            break;
                        }
                    } else {
                        if (cie.catalogueItem.SCMC__New_Item_Number__c == itemNumber) {
                            currItemExt = cie;
                            break;
                        }
                    }
                }
            }
            system.debug('leaving finditem(): ' + currItemExt);
            return currItemExt;
        }
        
        public List<CatalogueItemExtended> updateCatalogueId() {
            Id catalogueId = catalogue.Id;
            for (CatalogueItemExtended cie : catalogueItemExtendeds) {
                if (cie.catalogueItem.SCMC__Supplier_Catalogue__c == null) { 
                    cie.catalogueItem.SCMC__Supplier_Catalogue__c = catalogueId;
                }
            }
            
            return catalogueItemExtendeds;
        }
    }
    
    public class CatalogueItemExtended {
        
        public SCMC__Supplier_Catalogue_Item__c catalogueItem {get; set;}
        List<SCMC__Supplier_Catalogue_Price_Break__c> priceBreaks {get; set;}
        
        public CatalogueItemExtended(SCMC__Supplier_Catalogue_Item__c catItem) {
            catalogueItem = catItem;
            priceBreaks = new List<SCMC__Supplier_Catalogue_Price_Break__c>();
        }
        
        public List<SCMC__Supplier_Catalogue_Price_Break__c> updateCatalogueItemIds() {
            Id catalogueItemId = catalogueItem.Id;
            for (SCMC__Supplier_Catalogue_Price_Break__c pb : priceBreaks) {
                if (pb.SCMC__Supplier_Catalogue_Item__c == null) {
                    pb.SCMC__Supplier_Catalogue_Item__c = catalogueItemId;
                }
            }
            
            return priceBreaks;
        }
        
        public void AddPriceBreak(SCMC__Supplier_Catalogue_Price_Break__c priceBreak) {
            system.debug('add pb: ' + priceBreak);
            priceBreaks.add(priceBreak);
            system.debug('new pb size: ' + priceBreaks.size());
        }
        
        public SCMC__Supplier_Catalogue_Price_Break__c FindBreak(decimal validUntilQty, Date validUntilDate, Id conditionCodeId) {
            SCMC__Supplier_Catalogue_Price_Break__c currBreak = null;
            
            system.debug('new pb size: ' + priceBreaks.size());
            if (priceBreaks.size() > 0) {
                for (SCMC__Supplier_Catalogue_Price_Break__c pb : priceBreaks) {
                    if (pb.SCMC__Condition_Code__c == conditionCodeId
                        && pb.SCMC__Valid_Until_Date__c == validUntilDate 
                        && pb.SCMC__Valid_Until_Quantity__c == validUntilQty)
                    currBreak = pb;
                    break;
                }
            }
            return currBreak;
        }
    }
    
}