public with sharing class bg_RecordTypeMap {

	private Map<String,ID> recordTypeMapByName;
	private Map<ID,String> recordTypeMapByID; 

	private void createRecordTypeMap(String objectTypeName){
		List<RecordType> rtypes = [Select Name, Id From RecordType  where sObjectType=:objectTypeName  and isActive=true];
		
		recordTypeMapByName = new Map<String,ID>();
		recordTypeMapByID = new Map<ID,String>();
		
		for( RecordType r: rtypes ){
			recordTypeMapByName.put(r.name,r.id);
			recordTypeMapByID.put(r.id, r.name);
		}
	}
	
	public bg_RecordTypeMap(String objectTypeName){
			createRecordTypeMap(objectTypeName);
	}
	
	public ID getIdFromName( String name){
		ID recTypeId = recordTypeMapByName.get(name);
		if (recTypeId == null ){
			throw new bg_invalidRecordTypeException('Invalid Record Type - '+ name);
		}
		return recTypeId;
	}
	
	public String getNameFromID( ID id ){
		String recTypeName = recordTypeMapByID.get(id);
		if ( recTypeName == null) {
			throw new bg_invalidRecordTypeException('Invalid  Record Type - '+ id);
		}
		return recTypeName;
	}

}