public class AuditUtils
{
    public static void checkLeadchanges(List<Lead> oldRecordList, list<Lead> newRecordList)
    {    	
    	checkChanges(oldRecordList, newRecordList);
    }

    public static void CheckOpportunitychanges(List<Opportunity> oldRecordList, list<Opportunity> newRecordList)
    {    	
    	checkChanges(oldRecordList, newRecordList);
    }

    public static void LogOpportunityInsert( list<Opportunity> newRecordList)
    {
    	checkChanges(null, newRecordList);
    }

    private static void checkChanges(List<SObject> oldRecordList, list<SObject> newRecordList)
    {    	
        if(newRecordList == null || newRecordList.isEmpty())
            return;

        SObjectType objType = newRecordList[0].getSObjectType();
        String objName = objType.getDescribe().getName();
    	Map<String, SObjectField> fields = objType.getDescribe().fields.getMap();

		Map<Id, SObject> oldObjMap = new Map<Id, SObject>();
        if(oldRecordList != null) // may be an insert, in which case null.
            oldObjMap.putAll(oldRecordList);

		String recordid = '' ;
		String oldValue = '' ;
		String newvalue = '' ;		

		list<Audit_log__c> logList = new list<Audit_log__c>() ;	
        String operationName =  objName + oldRecordList == null ? ' Insert' : ' Update';

		for(SObject auditObj : newRecordList)
        {	
			try
            {
                recordid = auditObj.Id;

                for (String fieldName : fields.keyset())
                {
                    if(fieldname != 'systemmodtimestamp' && 
                        fieldname != 'lastmodifieddate' && 
                        fieldname != 'systemmodstamp')
                    {
                        oldValue = getValue(oldObjMap.get(recordid), fieldName);
                        NewValue = getValue(auditObj, fieldName);
                        
                        if(OldValue != newValue)
                        {
                            logList.add(new Audit_log__c(object_name__c = operationName,
                                                            record_id__c = recordid, 
                                                            Old_Value__c = OldValue, 
                                                            New_Value__C = newvalue, 
                                                            field_name__c = fieldname)) ;
                        }
                    }
                }
			}
			catch (Exception ex)
            {
				system.debug('Error here' + ex.getmessage()) ;
			}
		}		
		
		if (logList.size() > 0) 
        {
			insert logList ;
		}
    }

    private static String getValue(SObject obj, String fldName)
    {
        if(obj == null)
            return '';

        String val = String.valueof(obj.get(fldName));

        if(val != null && val.length() >255)
            val = val.subString(0, 255);

        return val;
    }
    
    
}