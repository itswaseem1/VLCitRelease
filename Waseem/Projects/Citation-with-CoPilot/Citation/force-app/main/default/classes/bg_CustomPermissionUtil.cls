public with sharing class bg_CustomPermissionUtil {

	private static Map<String,Set<String>> currentUserPermissionsByNamespace;

    public static Boolean userHasPermission(String permissionName, String namespace)
    {
        if(currentUserPermissionsByNamespace == null || !currentUserPermissionsByNamespace.containsKey(namespace))
        {
        	if(currentUserPermissionsByNamespace == null)
        	{
        		currentUserPermissionsByNamespace = new Map<String, Set<String>>();
        	}

            Map<Id, String> customPermissionNamesById = new Map<Id, String>();
            List<CustomPermission> customPermissions = [select 
            												Id, 
            												DeveloperName 
            											from 
            												CustomPermission 
            											where 
            												NamespacePrefix = :namespace];

            for(CustomPermission customPermission : customPermissions) 
            {
	            customPermissionNamesById.put(customPermission.Id, customPermission.DeveloperName);
            }

            // Query to determine which of these custom permissions are assigned to this user
            List<SetupEntityAccess> setupEntities = [SELECT 
            											SetupEntityId
													FROM 
														SetupEntityAccess
													WHERE 
														SetupEntityId in :customPermissionNamesById.keySet() 
													AND
														ParentId IN (SELECT 
																		PermissionSetId 
																	FROM 
																		PermissionSetAssignment
																	WHERE 
																		AssigneeId = :UserInfo.getUserId())]; 
			if(setupEntities.size() > 0)
			{
				currentUserPermissionsByNamespace.put(namespace, new Set<String>());

	            for(SetupEntityAccess setupEntity : setupEntities)
	            {
	            	currentUserPermissionsByNamespace.get(namespace).add(customPermissionNamesById.get(setupEntity.SetupEntityId));
	            }
	        }
        }

        if(currentUserPermissionsByNamespace.containsKey(namespace))
        {
        	return currentUserPermissionsByNamespace.get(namespace).contains(permissionName);
        }
        else
        {
        	return false;
        }
    }
}