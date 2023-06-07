public with sharing class Triggercg2InvoiceLineHandler {
	public Triggercg2InvoiceLineHandler() {}

	public static void onBeforeInsert(final List<c2g__codaInvoiceLineItem__c> newObjects){
		UpdateProductGLA(newObjects);
		updateDimension1(newObjects);
	}

	// Helper methods
	private static void UpdateProductGLA(List<c2g__codaInvoiceLineItem__c> newObjects){
		if(newObjects == null || newObjects.isEmpty()) return;

		List<c2g__codaInvoiceLineItem__c> invoiceLineItemsToUpdate = new List<c2g__codaInvoiceLineItem__c>();
		for(c2g__codaInvoiceLineItem__c record: newObjects){
			if(record.ffps_cita__BillingDocumentLine__c == null){
				invoiceLineItemsToUpdate.add(record);
			}
		}

		if(invoiceLineItemsToUpdate.isEmpty()) return;

		try{
			c2g__codaGeneralLedgerAccount__c glAccount = [select Id, Name from c2g__codaGeneralLedgerAccount__c where Name =: System.Label.FF_Sales_Revenue limit 1];
			if(glAccount == null) return;
			for(c2g__codaInvoiceLineItem__c record: invoiceLineItemsToUpdate){
				record.c2g__GeneralLedgerAccount__c = glAccount.Id;
			}
		} catch (Exception ex){
			System.debug('Error: ' + ex.getMessage());
		}

	}

	private static void updateDimension1(List<c2g__codaInvoiceLineItem__c> newObjects){

		try{
			c2g__codaDimension1__c dim1 = [select id from c2g__codaDimension1__c where name =: System.Label.FF_Dimension_1_Name limit 1];
			if(dim1 == null) return;

			for(c2g__codaInvoiceLineItem__c record: newObjects){
				record.c2g__Dimension1__c = dim1.Id;
			}
		} catch(Exception ex){
			System.debug('Error : ' + ex.getMessage());
		}
	}
}