public virtual inherited sharing class RecordTypeSelector
{
    public Map<String, Id> getRecordTypesByDevName(SObjectType objType)
    {
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = objType.getDescribe().getRecordTypeInfosByID();

        Map<String, Id> types = new Map<String, Id> ();
        for(ID recordTypeId: recordTypeInfos.keySet())
        {
            RecordTypeInfo info = recordTypeInfos.get(recordTypeId);

            if(info.isActive())
                types.put(info.getDeveloperName(), recordTypeId);
        }

        return types;
    }

    public Id getRecordTypeId(SObjectType objType, String devName)
    {
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = objType.getDescribe().getRecordTypeInfosByID();

        for(ID recordTypeId: recordTypeInfos.keySet())
        {
            RecordTypeInfo info = recordTypeInfos.get(recordTypeId);

            if(devName == info.getDeveloperName())
                return recordTypeId;
        }

        return null;
    }

}