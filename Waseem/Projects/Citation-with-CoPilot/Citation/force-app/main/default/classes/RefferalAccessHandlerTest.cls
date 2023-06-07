@isTest
private class RefferalAccessHandlerTest {
    static testMethod void testManualShareRead(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> users = new List<User>();
        User u1 = new User(Alias = 'standt1', Email='standarduser1RA@citation.co.uk',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1RA@citation.co.uk');
        users.add(u1);
        User u2 = new User(Alias = 'standt2', Email='standarduser2RA@citation.co.uk',EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2RA@citation.co.uk');
        users.add(u2);
        insert users;
        Id user1Id = users[0].Id;
        Id user2Id = users[1].Id;
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        Opportunity opp = new Opportunity(Name='Test opportunity',CloseDate=(System.today())+7,AccountId=testAccount.Id,
                                          ReferringEmployeeEmail__c='standarduser2RA@citation.co.uk',OwnerId=user1Id,StageName='Appointment');
        insert opp;    
        
        List<OpportunityShare> jShrs = [SELECT Id, UserOrGroupId, OpportunityAccessLevel, 
                                        RowCause FROM OpportunityShare WHERE OpportunityId = :opp.Id AND UserOrGroupId= :user2Id];
        
        System.assertEquals(jShrs[0].OpportunityAccessLevel, 'Edit','Record Access Level not set to Read');
        System.assertEquals(jShrs[0].RowCause, 'Manual','RowCause not set to Manual');
        System.assertEquals(jShrs[0].UserOrGroupId, user2Id,'UserOrGroupId not equal');
        
        Lead ld = new Lead(LastName='Test',Company='ABC',Referred_By_Email__c='standarduser2RA@citation.co.uk',OwnerId=user1Id);
        insert ld;
        List<LeadShare> lShrs = [SELECT Id, UserOrGroupId, LeadAccessLevel, 
                                 RowCause FROM LeadShare WHERE LeadId = :ld.Id AND UserOrGroupId= :user2Id];
        
        System.assertEquals(lShrs[0].LeadAccessLevel, 'Read','Record Access Level not set to Read');
        System.assertEquals(lShrs[0].RowCause, 'Manual','RowCause not set to Manual');
        System.assertEquals(lShrs[0].UserOrGroupId, user2Id,'UserOrGroupId not equal');
        
    }  
}