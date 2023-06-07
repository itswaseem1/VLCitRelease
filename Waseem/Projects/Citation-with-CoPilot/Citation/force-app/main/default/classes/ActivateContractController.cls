global without sharing class ActivateContractController {
	     
    @AuraEnabled
    webservice static String Activate(Id conId) {
        Contract conDetails = [select id, Status from Contract where Id =: conId];
        String userid = userinfo.getUserId();
        Boolean validAccess = false;
        validAccess = [SELECT id, name, PermissionsActivateContract from PRofile where id = :userinfo.getProfileId()].PermissionsActivateContract;
        Set<id> AssigneeIds = new Set<id>();
        if(!validAccess){
            For(permissionset ps : [SELECT id, name, (SELECT AssigneeId FROM Assignments where AssigneeId = :userid)  from permissionset where PermissionsActivateContract = true]){
                if(ps.Assignments != NULL && ps.Assignments.size() != 0){
                    validAccess = true;   
                }	
            }
        }
        if (!validAccess){
            return 'Permission Denied';
        }
        if(conDetails != NULL && conDetails.Status != 'Active' && validAccess){
           conDetails.Status = 'Active'; 
           update conDetails;
        } else if(conDetails != NULL && conDetails.Status == 'Active'){
            return 'Contract already Active';
        }
    	return 'success';
    }
}