public class schPolicyObjTriggerHandler {
	public static void checkDeletePermissions( List<FSL__Scheduling_Policy_Goal__c> schPolicyObjList ){
        String curretUserRole=[select userrole.name from user where id=: UserInfo.getUserId()].userrole.name;
        FSL_Schedule_Policy_Access__mdt hj = FSL_Schedule_Policy_Access__mdt.getInstance('Hayley_Jones');
        FSL_Schedule_Policy_Access__mdt kg = FSL_Schedule_Policy_Access__mdt.getInstance('Kathy_Gwinnett');
        FSL_Schedule_Policy_Access__mdt access = FSL_Schedule_Policy_Access__mdt.getInstance('Access');
        for(FSL__Scheduling_Policy_Goal__c objective : schPolicyObjList){
            if(!(UserInfo.getUserEmail()==hj.Email_Id__c || UserInfo.getUserEmail()==kg.Email_Id__c || curretUserRole==access.role__c ))
                objective.adderror('You are not authorized to delete the scheduling policy objective');
        }
    }
}