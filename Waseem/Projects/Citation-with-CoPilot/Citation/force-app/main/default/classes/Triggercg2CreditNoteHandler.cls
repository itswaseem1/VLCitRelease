public with sharing class Triggercg2CreditNoteHandler {
	public Triggercg2CreditNoteHandler() {}

	public static void onBeforeInsert(final List<c2g__codaCreditNote__c> newObjects){
		updateDimension1(newObjects);
	}

	//Helper methods

	private static void updateDimension1(List<c2g__codaCreditNote__c> newObjects){
		try{
			c2g__codaDimension1__c dim1 = [select id from c2g__codaDimension1__c where name =: System.Label.FF_Dimension_1_Name limit 1];
			if(dim1 == null) return;

			for(c2g__codaCreditNote__c record: newObjects){
				record.c2g__Dimension1__c = dim1.Id;
			}
		} catch(Exception ex){
			System.debug('Error : ' + ex.getMessage());
		}
	}
}