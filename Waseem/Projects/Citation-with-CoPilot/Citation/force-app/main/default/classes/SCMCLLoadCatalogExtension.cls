/*
 * Copyright (c) 2011-2016 FinancialForce.com, inc. All rights reserved.
 *
 * Class to start batch process to load catalogs
*/
public with sharing class SCMCLLoadCatalogExtension {

	private ApexPages.StandardSetController setController;

    // this constructor is invoked from the multi select on the catalog load object view
    public SCMCLLoadCatalogExtension(ApexPages.StandardSetController controller) {
    	this.setcontroller = controller;
	}
    
	public PageReference process() {
		Database.executeBatch(new SCMCLLoadCatalog(), 100);
		// Get the sObject describe result for the Catalog Load object
		Schema.DescribeSObjectResult r = SCMC__Catalog_Load__c.sObjectType.getDescribe(); 
		String keyPrefix = r.getKeyPrefix();
		PageReference retPage = new PageReference('/' + keyPrefix + '/o');
		
		return retPage;
	}
	
	public PageReference goback() {
		PageReference retPage = setController.cancel();
		return retPage;
	}

}