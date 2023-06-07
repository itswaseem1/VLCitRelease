public with sharing class AutocreatedRegHandler1628577981685 implements Auth.RegistrationHandler {


public User createUser(Id portalId, Auth.UserData data){

User u = [select id,username from User where username=:data.email WITH SECURITY_ENFORCED];
   return u;
}

public void updateUser(Id userId, Id portalId, Auth.UserData data){

    User u = new User(id=userId);
}
}