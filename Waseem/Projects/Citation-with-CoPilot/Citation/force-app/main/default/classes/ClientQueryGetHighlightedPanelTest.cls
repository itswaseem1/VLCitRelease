@isTest
public class ClientQueryGetHighlightedPanelTest {
	@testSetup
	static void setup() 
	{
		Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Client_Query').getRecordTypeId();
		Case clientQuery=new Case();
		clientQuery.RecordTypeId=rTId;
		clientQuery.Origin='Call';
		clientQuery.Status='New';
		clientQuery.Priority='Medium';
		clientQuery.subject='Test';
		clientQuery.Description='Test client query field set values';
		insert clientQuery;
	}
	 
	@isTest
	public static void givenValidRecordIdTest() {	
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		ClientQueryGetHighlightedPanel.HighlightedPanelDetails response = ClientQueryGetHighlightedPanel.getFieldSetDetails(caseRecord.Id, 'Case');
		string primaryField = response.subjectField;
		string fieldSetValues = string.join(response.fieldSet,',');
		system.assertEquals('Test', primaryField);
		system.assertEquals('Priority,Status,CaseNumber', fieldSetValues);
		Test.stopTest();
	}

	@isTest
	public static void givenBadRecordIdTest(){
		Test.startTest();
		try{
		ClientQueryGetHighlightedPanel.HighlightedPanelDetails firstResponse = ClientQueryGetHighlightedPanel.getFieldSetDetails('', 'Case');
		Assert.fail('Expected the exception for bad recordId');
		}
		catch(Exception ex){
		 system.assertEquals('Script-thrown exception',ex.getMessage() );
		}
		Test.stopTest();
	}

	@isTest
	public static void exceptionHandlingTest(){
		try{
			Case caseRecord=[SELECT Id FROM Case WHERE Id='5003G000008xxxxxXx'];
			ClientQueryGetHighlightedPanel.HighlightedPanelDetails response = ClientQueryGetHighlightedPanel.getFieldSetDetails(caseRecord.Id, 'Case');
			Assert.fail('Expected the exception for invalid recordId');
		}
		catch(exception ex){system.assertEquals('List has no rows for assignment to SObject', +ex.getMessage());}
	}
}