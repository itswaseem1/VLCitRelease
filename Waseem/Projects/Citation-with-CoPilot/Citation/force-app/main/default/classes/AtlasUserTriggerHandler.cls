/**
 * @File Name          : AtlasUserTriggerHandler.cls
 * @Description        : Enables/Disables the Community Access of a User based on Can Access Communities field
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka              Initial Version
 **/
public without sharing class AtlasUserTriggerHandler {
    public static void createCommUsers(List<Atlas_User__c> users){
        try{
            Map<Id,Boolean> userCreationMap = new Map<Id,Boolean>();
            for(Atlas_User__c uss : users){
                if(uss.Contact__c != null && uss.Can_Access_Communities__c){
                    userCreationMap.put(uss.Contact__c,uss.Can_Access_Communities__c);
                } 
            }
            if(!userCreationMap.isEmpty()){
                createCommunityUsers(userCreationMap);
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+ex.getMessage());
        }
    }
    
    //Creates new Community Users
    @future
    public static void createCommunityUsers(Map<Id,Boolean> userCreationMap){
        Map<Id,Contact> conts = new Map<Id,Contact>([SELECT Id, FirstName, LastName, Email, AccountId,Active__c FROM Contact where Id IN: userCreationMap.keySet() WITH SECURITY_ENFORCED]);
        List<User> commUsers = fetchCommunityUserDetails(userCreationMap.keySet());
        if(commUsers != null && commUsers.size()>0){
            updateUserDetails(commUsers,conts,userCreationMap);
        }else{
            AtlasUserTriggerHelper.createNewUsers(conts.values(),null,userCreationMap);
        }        
    }
    
    //Gets the list of Users whose details are updated in SF
    public static void updateCommunityUsers(Map<Id,Atlas_User__c> newMap,Map<Id,Atlas_User__c> oldMap){
        Map<Id,Boolean> contIds = new Map<Id,Boolean>();
        for(Atlas_User__c user : newMap.values()){
            if(user.Can_Access_Communities__c != oldMap.get(user.Id).Can_Access_Communities__c || user.FirstName__c != oldMap.get(user.Id).FirstName__c ||
               user.SecondName__c != oldMap.get(user.Id).SecondName__c || user.Email__c != oldMap.get(user.Id).Email__c){
                   if(newMap.get(user.Id).Contact__c != null){
                       contIds.put(newMap.get(user.Id).Contact__c,user.Can_Access_Communities__c);
                   }
               }
        }
        if(!contIds.isEmpty()){
            createCommunityUsers(contIds);
        }
    }

    //Updates the Community user's details
    public static void updateUserDetails(List<User> commUsers,Map<Id,Contact> conts,Map<Id,Boolean> userCreationMap){
        Set<Id> contactIds = new Set<Id>();
        for(User usr : commUsers){
            contactIds.add(usr.ContactId);
            usr.FirstName = conts.get(usr.ContactId).FirstName;
            usr.LastName = conts.get(usr.ContactId).LastName;
            usr.IsActive = userCreationMap.get(usr.ContactId);
            usr.Username = conts.get(usr.ContactId).Email;
            usr.Email = conts.get(usr.ContactId).Email+'.invalid';
        }
        List<Contact> commUserCreation = new List<Contact>();
        for(Id atlasId : conts.keySet()){
            if(!contactIds.contains(atlasId)){
                commUserCreation.add(conts.get(atlasId));
            }
        }
        AtlasUserTriggerHelper.createNewUsers(commUserCreation,commUsers,userCreationMap);
    }

    //Fetches Community User Details
    public static List<User> fetchCommunityUserDetails(Set<Id> contIds){
        List<User> uss = [Select FirstName,LastName,Username,Email,ContactId,IsActive from User where ContactId IN: contIds and Profile.Name='Citation Customer Community Login User' WITH SECURITY_ENFORCED];
        return uss;
    }
}