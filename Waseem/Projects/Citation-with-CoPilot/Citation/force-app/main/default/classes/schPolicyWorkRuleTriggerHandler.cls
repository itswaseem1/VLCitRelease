public class schPolicyWorkRuleTriggerHandler {
	public static void checkDeletePermissions( List<FSL__Scheduling_Policy_Work_Rule__c> workRuleList ){
        String curretUserRole=[select userrole.name from user where id=: UserInfo.getUserId()].userrole.name;
        FSL_Schedule_Policy_Access__mdt hj = FSL_Schedule_Policy_Access__mdt.getInstance('Hayley_Jones');
        FSL_Schedule_Policy_Access__mdt kg = FSL_Schedule_Policy_Access__mdt.getInstance('Kathy_Gwinnett');
        FSL_Schedule_Policy_Access__mdt access = FSL_Schedule_Policy_Access__mdt.getInstance('Access');
        for(FSL__Scheduling_Policy_Work_Rule__c  wRule : workRuleList){
            if(!(UserInfo.getUserEmail()==hj.Email_Id__c || UserInfo.getUserEmail()==kg.Email_Id__c || curretUserRole==access.role__c ))
                wRule.adderror('You are not authorized to delete the scheduling policy work rule');
        }
    }
}