/**
* @File Name          : MilestoneWorkTypeTrigger.apxt
* @Description        :
* @Author             : Maanas Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 3/15/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     3/12/2021      Initial Version						SS-337
**/
public with sharing class MilestoneWorkTypeTriggerHandler {
    
    public static Map<Id, Milestone_Work_Type__c> mwtMap = new Map<Id, Milestone_Work_Type__c>();
    public static Map<Id, WorkType> workTypeMap = new Map<Id, WorkType>();
    
    public static void mwtValidations( List<Milestone_Work_Type__c> mwtList, Map<Id,Milestone_Work_Type__c> mwtOldMap  ){
        
        if( mwtOldMap == NULL ){
            populateInsertMap(mwtList);
        }else{
            populateUpdateMap( mwtList, mwtOldMap);
        }
        
        if ( NULL != mwtMap && mwtMap.size() > 0 ){
            getWorkTypeData( mwtMap );
        }
        
        if ( NULL != workTypeMap && workTypeMap.size() > 0 ){
            checkValidations( mwtMap, workTypeMap );
        }
    }
    
    public static void getWorkTypeData( Map <Id, Milestone_Work_Type__c> milstoneWrkTypeMap ){
        
        for ( WorkType workTypeObj : [ SELECT Id, ShouldAutoCreateSvcAppt FROM WorkType WHERE ID IN : milstoneWrkTypeMap.keyset() ]){
            workTypeMap.put( workTypeObj.Id, workTypeObj);
        }
    }
    
    public static void checkValidations ( Map<Id, Milestone_Work_Type__c> mwtvalidationMap, Map<Id, WorkType> workTypeValidationMap ){
        
        final String ERROR_MESSAGE ='Service Territory/ Subject/Description is Mandatory when WorkType Selected has Auto Create Service Appointment Checked';
        final String ERROR_MESSAGE2 ='Customer Friendly Meeting Name and Meeting Type are Mandatory when WorkType Selected has Auto Create Service Appointment Checked';
        
        
        for ( Milestone_Work_Type__c mwtValidationObj : mwtvalidationMap.values() ){
           
            if(workTypeValidationMap.get(mwtValidationObj.Work_Type__c).ShouldAutoCreateSvcAppt){
                if (( mwtValidationObj.ServiceTerritory__c == null || mwtValidationObj.Subject__c == null || mwtValidationObj.Description__c == null)){
                    mwtValidationObj.AddError(ERROR_MESSAGE);
                    break;
                }
                //ss-815
                if((mwtValidationObj.Meeting_Type__c == null || mwtValidationObj.Meeting_Type__c == 'none')
                   ||(mwtValidationObj.Customer_Friendly_Meeting_Name__c == '' || mwtValidationObj.Customer_Friendly_Meeting_Name__c == null) ){
                       mwtValidationObj.AddError(ERROR_MESSAGE2);
                       break;
                   }
            }
        }
    }
    
    public static void populateInsertMap( List<Milestone_Work_Type__c> mwtList ){
        for ( Milestone_Work_Type__c mwtObj : mwtList ){
            if ( mwtObj.Work_Type__c != NULL ){
                mwtMap.put( mwtObj.Work_Type__c, mwtObj );
            }
        }
    }
    
    public static void populateUpdateMap( List<Milestone_Work_Type__c> mwtList, Map<Id,Milestone_Work_Type__c> mwtOldMap ){
        for ( Milestone_Work_Type__c mwtObj : mwtList ){
            if ( mwtObj.Work_Type__c != NULL && ( mwtObj.ServiceTerritory__c != mwtOldMap.get(mwtObj.Id).ServiceTerritory__c || mwtObj.Description__c != mwtOldMap.get(mwtObj.Id).Description__c ||  mwtObj.Subject__c != mwtOldMap.get(mwtObj.Id).Subject__c 
                                                			|| mwtObj.Meeting_Type__c != mwtOldMap.get(mwtObj.Id).Meeting_Type__c || mwtObj.Customer_Friendly_Meeting_Name__c != mwtOldMap.get(mwtObj.Id).Customer_Friendly_Meeting_Name__c)){
                mwtMap.put( mwtObj.Work_Type__c, mwtObj );
            }
        }
    }
    
    
    public static void checkDeletePermissions( List<Milestone_Work_Type__c> mwtList ){
        String curretUserRole=[select userrole.name from user where id=: UserInfo.getUserId()].userrole.name;
        FSL_Schedule_Policy_Access__mdt hj = FSL_Schedule_Policy_Access__mdt.getInstance('Hayley_Jones');
        FSL_Schedule_Policy_Access__mdt kg = FSL_Schedule_Policy_Access__mdt.getInstance('Kathy_Gwinnett');
        FSL_Schedule_Policy_Access__mdt access = FSL_Schedule_Policy_Access__mdt.getInstance('Access');
        for(Milestone_Work_Type__c mwt : mwtList){
            if(!(UserInfo.getUserEmail()==hj.Email_Id__c || UserInfo.getUserEmail()==kg.Email_Id__c || curretUserRole==access.role__c ))
                mwt.adderror('You are not authorized to delete the Milestone Work Type');
        }
    }
    
    
}