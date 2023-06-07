/**
* @File Name          : ClientQueryGetHighlightedPanel.cls
* @Description        : To get fieldset details and case subject for client query case record
* @Author             : Priyanka
**/
public without sharing class ClientQueryGetHighlightedPanel {
	@AuraEnabled
	public static HighlightedPanelDetails getFieldSetDetails(String recordId, String sObjectName) {
		HighlightedPanelDetails panelDetails = new HighlightedPanelDetails();
		try {
			List<Case> caseList = [SELECT Id, Subject FROM Case WHERE Id =: recordId];
			if(caseList == null || caseList.isEmpty()) {
				throw new CustomException('Unable to retrieve Case Id='+recordId+', Please contact admin');
			}
			panelDetails.subjectField = String.valueof(caseList[0].get('Subject'));
			//Get Fieldset values
			String fieldSetName = 'ClientQuery_Custom_Highlighted_Panel';
			DescribeSObjectResult[] objName = Schema.describeSObjects(new String[] {sObjectName});
			Schema.FieldSet fieldSet = objName[0].fieldSets.getMap().get(fieldSetName);
			panelDetails.fieldSet = new List<String>();
			for(Schema.FieldSetMember fieldSetMem : fieldSet.getFields()){
				panelDetails.fieldSet.add(fieldSetMem.getFieldPath());
			}
			return panelDetails;
		}
		catch(Exception ex) {
			System.debug('Exception occured-->'+ex.getMessage() +', '+ex.getLineNumber());
			throw new AuraHandledException(ex.getMessage());
		}
	}
	
	public class HighlightedPanelDetails {
		@AuraEnabled public List<String> fieldSet;
		@AuraEnabled public String subjectField;
	}
	//For Custom Exception Handling
	public virtual class CustomException extends Exception {
	}
}