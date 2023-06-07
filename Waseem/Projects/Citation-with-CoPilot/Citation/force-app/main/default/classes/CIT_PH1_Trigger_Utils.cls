@isTest
public with sharing class CIT_PH1_Trigger_Utils {
    
    public static List<Account> createAccounts(Integer expectedAccounts){
        List<Account> accountsList = new List<Account>();
        for(Integer index = 0; index < expectedAccounts; index++){
            Account a = new Account(Name = 'Test ' + index, isConverted__c = false, AnnualRevenue = 100000);
            accountsList.add(a);
        }
        return accountsList;
    }
    
    
    public static List<Contact> createContacts(Integer expectedContacts){
        List<Contact> contactsList = new List<Contact>();
        for(Integer index = 0; index < expectedContacts; index++){
            Contact a = new Contact(LastName = 'Test ' + index, isConverted__c = false);
            contactsList.add(a);
        }
        return contactsList;
    }
    
    
    public static List<Opportunity> createOpportunities(Integer expectedOpportunities){
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        for(Integer index = 0; index < expectedOpportunities; index++){
            Opportunity a = new Opportunity(Name = 'Test ' + index, isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today());
            opportunitiesList.add(a);
        }
        return opportunitiesList;
    }

    public static List<Opportunity> createOpportunities(Integer expectedOpportunities, Account account){
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        for(Integer index = 0; index < expectedOpportunities; index++){
            Opportunity a = new Opportunity(Name = 'Test ' + index, isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), AccountId = account.Id);
            opportunitiesList.add(a);
        }
        return opportunitiesList;
    }
    
    public static List<Lead> createLeads(Integer expectedLeads){
        List<Lead> leadsList = new List<Lead>();
        for(Integer index = 0; index < expectedLeads; index++){
            Lead a = new Lead(LastName = 'Test ' + index, isAccountConverted__c = true, isContactConverted__c = true, isOpportunityConverted__c = true, Company = 'Test',
                             Status = 'Data Quality',BDC__c = '005D00000037SsA', MADE_Criteria__C = 'Outbound - 1', LeadSource = 'Seminar',appointment_type__c = 'H&S',
                             email= 'test@citation.co.uk',salutation = 'Mr',Street='Test Street',PostalCode = 'SK9 5AU',position__c='Boss',Visit_Type__c = 'Virtual'
                             );
            leadsList.add(a);
        }
        return leadsList;
    }
    
    public static List<Event> createEventObjectTestData(Integer expectedEvents, Lead testLead){
        List<Event> EventList = New List<Event>(); 
        for(Integer index=0; index<expectedEvents; index++){
            Event Event = New Event(whoId = testLead.Id, ActivityDateTime = System.Now(), EndDateTime = System.Today().addDays(1), Type = 'Other');
            EventList.add(Event);
        }
        return EventList;
    }
    
    public static List<Task> createNobleTaskTestData(Integer expectedTasks, Integer totalTasks, Lead testLead, User testUser) {
        List<Task> TaskList = new List<Task>();
        Integer j = 0;
        for (Integer i = 0; i < totalTasks; i++) {
            Task newTask = new Task();
            if (j < expectedTasks) {
                newTask.Subject = 'Outbound Call';
                newTask.CallDisposition = null;
            }
            if (testLead != null && testUser != null) {
                newTask.whoId = testLead.Id;
                newTask.OwnerId = testUser.Id;
            }
            TaskList.Add(newTask);
            j++;
        }
        return TaskList;
    }
    
    // Some of the fields necessary to create a User account
    // should be populated based on whichever User is running tests.        
    // public static User DummyUser = [select id, TimeZoneSidKey, LocaleSidKey, 
    //                 EmailEncodingKey, ProfileId, LanguageLocaleKey
    //                 from User limit 1];

    // Creates a Test User with a given Profile
    // public static User createTestUser(String firstName,String lastName,String email,String userName,Id profileId, Id UserRoleId) {
    //     return new User(
    //         FirstName = firstName,
    //         LastName = lastName,
    //         Email = email,
    //         Username = userName,
    //         ProfileId = profileId,
    //         UserRoleId = UserRoleId,
    //         Alias = lastName.substring(0,4),
    //         CommunityNickname = lastName.substring(0,4),
    //         TimeZoneSidKey=DummyUser.TimeZoneSidKey,
    //         LocaleSidKey=DummyUser.LocaleSidKey,
    //         EmailEncodingKey=DummyUser.EmailEncodingKey,
    //         LanguageLocaleKey=DummyUser.LanguageLocaleKey
    //     );
    // }

    // Create a Test User with the Profile 
    // of whoever is running the tests
    // public static User createTestUser(String firstName, String lastName, String email, String userName) {
    //     return createTestUser(firstName,lastName,email,userName,DummyUser.ProfileId,DummyUser.UserRoleId);
    // }
}