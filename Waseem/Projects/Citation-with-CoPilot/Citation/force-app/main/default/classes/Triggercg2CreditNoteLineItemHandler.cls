public with sharing class Triggercg2CreditNoteLineItemHandler {
	public Triggercg2CreditNoteLineItemHandler() {}

	public static void onBeforeInsert(final List<c2g__codaCreditNoteLineItem__c> newObjects){
		updateDimension1(newObjects);
		updateProductGLA(newObjects);
	}

	//Helper methods

	private static void updateDimension1(List<c2g__codaCreditNoteLineItem__c> newObjects){
		try{
			c2g__codaDimension1__c dim1 = [select id from c2g__codaDimension1__c where name =: System.Label.FF_Dimension_1_Name limit 1];
			if(dim1 == null) return;

			for(c2g__codaCreditNoteLineItem__c record: newObjects){
				record.c2g__Dimension1__c = dim1.Id;
			}
		} catch(Exception ex){
			System.debug('Error : ' + ex.getMessage());
		}
	}

	private static void updateProductGLA(List<c2g__codaCreditNoteLineItem__c> newObjects){
		if(newObjects == null || newObjects.isEmpty()) return;

		try{
			c2g__codaGeneralLedgerAccount__c glAccount = [select Id, Name from c2g__codaGeneralLedgerAccount__c where Name =: System.Label.FF_Sales_Revenue limit 1];
			if(glAccount == null) return;
			for(c2g__codaCreditNoteLineItem__c record: newObjects){
				if(record.c2g__GeneralLedgerAccount__c == null) record.c2g__GeneralLedgerAccount__c = glAccount.Id;
			}
		} catch (Exception ex){
			System.debug('Error: ' + ex.getMessage());
		}

	}

}