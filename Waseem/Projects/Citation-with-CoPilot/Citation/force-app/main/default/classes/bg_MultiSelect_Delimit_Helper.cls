/********************************************************************************
* bg_MultiSelect_Delimit_Helper :
*
* Created By: Hossein Mirzapour 
* Created Date: 07-09-2015
*
* Changes: KH 03-12-2015 - Updated insertRequiredMultiSelectPicklistDelimits to 
*						   use Field Label rather API Name.
*
*********************************************************************************/

public without sharing class bg_MultiSelect_Delimit_Helper {

	// Removes all MultiSelectPIcklist_delimit__c for the given ids of record
	public static void removeNonRequiredMultiSelectPicklistDelimits(String objectName, List<sObject> records)
	{
		List<MultiSelectPIcklist_delimit__c> delimitRecordsToRemove = removableMultiSelectPicklistDelimits(objectName, records);

		if (!delimitRecordsToRemove.isEmpty())
		{
			delete delimitRecordsToRemove;
		}
	}

	// Inserts all MultiSelectPIcklist_delimit__c for the given ids of records based on their multiselect picklist values
	public static void insertRequiredMultiSelectPicklistDelimits(List<sObject> records, List<String> multiSelectFields, String parentObject, Map<String, Schema.SObjectField> fieldMap)
	{
		List<MultiSelectPIcklist_delimit__c> newDelimitRecords = new List<MultiSelectPIcklist_delimit__c>();
		for(sObject record : records)
		{
			for(String fieldName : multiSelectFields)
			{
				List<String> picklistValues = seperateMultiSelectPicklistValues((String)record.get(fieldName));

                String label = fieldMap.get(fieldName).getDescribe().getLabel();
				for(String value : picklistValues)
				{
					newDelimitRecords.add(createMultiSelectPicklistDelimits(value, parentObject, record.Id, label));
				}
			}
		}

		if(!newDelimitRecords.isEmpty())
		{
			insert newDelimitRecords;
		}	
	}

	// Given a multi select picklist values, this method seperates the the value into a list of strings
	public static List<String> seperateMultiSelectPicklistValues(String picklistValue)
	{
		if(picklistValue != null)
		{
			List<String> multiSelectPicklistValues = picklistValue.split(';');
			return multiSelectPicklistValues;
		}
		else
		{
			return new List<String>();	
		}
		
	}

	// Gets all MultiSelectPIcklist_delimit__c records for the given object record
	public static List<MultiSelectPIcklist_delimit__c> removableMultiSelectPicklistDelimits(String parentObject, List<sObject> records)
	{
		String query = 'SELECT Id FROM MultiSelectPIcklist_delimit__c WHERE Related_' + parentObject + '__c IN :records';
		List<MultiSelectPIcklist_delimit__c> delimitRecords = Database.query(query);

		return delimitRecords;
	}

	// creates new MultiSelectPIcklist_delimit__c values for insertion given the object record details
	public static MultiSelectPIcklist_delimit__c createMultiSelectPicklistDelimits(String value, String parentObject, String parentObjectId, String relatedPicklistField)
	{
		MultiSelectPIcklist_delimit__c delimitedValue = new MultiSelectPIcklist_delimit__c();

		delimitedValue.put('Name', value);
		delimitedValue.put('Picklist__c', value);
		delimitedValue.put('Picklist_Field__c', relatedPicklistField);
		delimitedValue.put('Related_' + parentObject + '__c', parentObjectId);

		return delimitedValue;
	}
}