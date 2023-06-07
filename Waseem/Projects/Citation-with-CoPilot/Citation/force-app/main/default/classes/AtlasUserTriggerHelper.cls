/**
 * @File Name          : AtlasUserTriggerHelper.cls
 * @Description        : Helper Class for AtlasUserTriggerHandler.cls
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class AtlasUserTriggerHelper {
    //Checks wheteher the Account Owner has a role for selected Contacts
    public static void checkForAccountOwnerRole(Set<Id> accIds,List<User> existingCommUsers){
        Set<Id> userIds = new Set<Id>();
        List<Account> accs = [Select Id, Name, OwnerId, Owner.UserRoleId from Account where Id IN: accIds WITH SECURITY_ENFORCED];
        for(Account acc : accs){
            if(acc.Owner.UserRoleId == null ){
                userIds.add(acc.OwnerId);
            }
        }
        updateRoles(userIds,existingCommUsers);
    }

    //Updates the Account Owner role with 'Training'
    public static void updateRoles(Set<Id> userIds,List<User> existingCommUsers){
        UserRole role = [Select Id,Name from UserRole where Name='Training' WITH SECURITY_ENFORCED Limit 1];
        List<User> users = [Select Id, UserRoleId from User where Id IN: userIds WITH SECURITY_ENFORCED];
        for(User uss : users){
            uss.UserRoleId = role.Id;
        }
        if(existingCommUsers!= null && existingCommUsers.size()>0){
            users.addAll(existingCommUsers);
        }
        if(users.size()>0 && User.sObjectType.getDescribe().isUpdateable()){
            update users;
        }
    }

    public static void createNewUsers(List<Contact> conts,List<User> existingCommUsers,Map<Id,Boolean> userCreationMap){
        if(conts.size() == 0 && existingCommUsers!= null && existingCommUsers.size()>0){
            update existingCommUsers;
        }else{
            Set<Id> accIds= new Set<Id>();
            for(Contact cont : conts){
                accIds.add(cont.AccountId);
            }
            checkForAccountOwnerRole(accIds,existingCommUsers);
            List<User> commUsers = createUserData(conts,userCreationMap);
            
            if(commUsers.size()>0 && User.sObjectType.getDescribe().isCreateable()){
                insert commUsers;
                assignPermissionSet(commUsers);
            }
        }
    }
    
    //Creates new Community users
    public static List<User> createUserData(List<Contact> conts,Map<Id,Boolean> userCreationMap){
        List<User> commUsers = new List<User>();
        Profile prof = [Select Id from Profile where Name='Citation Customer Community Login User' WITH SECURITY_ENFORCED Limit 1];
        for(Contact cont : conts){
            if(userCreationMap.get(cont.Id)){
                String aliasVal = ((cont.FirstName != null) ? cont.FirstName: '') + ' ' + cont.LastName;
                User u = new User(FirstName = ((cont.FirstName != null) ? cont.FirstName: ''),
                                  LastName = cont.LastName,ContactId = cont.Id,
                                  Username = cont.Email,Email = (cont.Email+'.invalid'),
                                  Alias = ((aliasVal.length() > 8) ? aliasVal.substring(0, 7): aliasVal),
                                  TimeZoneSidKey = 'Europe/London',LocaleSidKey = 'en_GB',
                                  EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US',
                                  ProfileId = prof.Id,IsActive=userCreationMap.get(cont.Id));
                commUsers.add(u);
            }
        }
        return commUsers;
    }
    
    //Assigns permission sets to the newly created Community users
    public static void assignPermissionSet(List<User> commUsers){
        List<PermissionSet> perSets = [SELECT Id, Name FROM PermissionSet where Name='Community_Login_User_PS_Citation_and_QMS' or Name='FSL_Community_Self_Service_Permissions' or Name='General_S360_Permission_Set_Community' WITH SECURITY_ENFORCED];
        if(perSets != null && perSets.size()>0){
            List<PermissionSetAssignment> perAssignment = new List<PermissionSetAssignment>();
            for(User uss : commUsers){
                for(PermissionSet per : perSets){
                    perAssignment.add(new PermissionSetAssignment(AssigneeId = uss.Id, PermissionSetId = per.Id));
                }
            }
            if(perAssignment.size()>0 && PermissionSetAssignment.sObjectType.getDescribe().isCreateable()){
                insert perAssignment;
            }
        }
    }
    
}