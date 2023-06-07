public with sharing class bg_RecordType_Utils {

    private static Map<Schema.SObjectType,Map<String,Id>> rtypesCache;

    static {
        rtypesCache = new Map<Schema.SObjectType,Map<String,Id>>();
    }

    // Returns a map of active, user-available RecordType IDs for a given SObjectType,
    // keyed by each RecordType's unique, unchanging DeveloperName 
    public static Map<String, Id> GetRecordTypeIdsByDeveloperName(Schema.SObjectType token)
    {
        Map<String, Id> mapRecordTypes = rtypesCache.get(token);
        
        if (mapRecordTypes == null) 
        {
            mapRecordTypes = new RecordTypeSelector().getRecordTypesByDevName(token);
        } 
        
        return mapRecordTypes;
    }

}