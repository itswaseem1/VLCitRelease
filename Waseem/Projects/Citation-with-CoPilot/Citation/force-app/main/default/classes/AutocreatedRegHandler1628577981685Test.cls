@isTest
public class AutocreatedRegHandler1628577981685Test {

    static testMethod void testCreateAndUpdateUser() {
    User u = new User();
    Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
    u.username = 'testuserinvalid@citation.co.uk';
    u.email = 'testuserinvalid@citation.co.uk';
    u.lastName = 'data.lastName';
    u.firstName = 'data.firstName';
    u.alias = 'alias';
    u.languagelocalekey = 'en_US';
    u.localesidkey = 'en_US';
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'America/Los_Angeles';
    u.profileId = p.Id;
    insert u;
    AutocreatedRegHandler1628577981685 handler = new AutocreatedRegHandler1628577981685();
    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        'testFirst testLast', 'testuserinvalid@citation.co.uk', null, 'testuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});
    User u1 = handler.createUser(null, sampleData);
    System.assertEquals('testuserinvalid@citation.co.uk', u.userName,'Success');
    System.assertEquals('testuserinvalid@citation.co.uk', u.email,'Success');
    String uid = u.id;
    
    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
        'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{});
    handler.updateUser(uid, null, sampleData);
}

}