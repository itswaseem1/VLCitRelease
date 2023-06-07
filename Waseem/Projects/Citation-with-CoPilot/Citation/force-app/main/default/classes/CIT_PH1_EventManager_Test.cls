/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
Public class CIT_PH1_EventManager_Test {
    @isTest(seeallData=false)
    static void EventManager_OnInsert_CheckLeadUpdated() {
        Lead testLead = new Lead(LastName = 'TestLead', Company = 'TestCompany', Status = 'Data Quality',BDC__c = '005D00000037SsA', MADE_Criteria__C = 'Outbound - 1', LeadSource = 'Seminar', appointment_Type__C = 'H&S', email= 'test@citation.co.uk',salutation = 'Mr',Street='Test Street',PostalCode = 'SK9 5AU',position__c='Boss',Visit_Type__c='Face to Face');
        insert testLead; 
        Event testEvent = new Event(whoId = testLead.Id, ActivityDateTime = System.Now(), EndDateTime = System.Today().addDays(1), 
                                    Event_Status__c = 'Pending', Type = '1st Visit');
                                    
        Test.startTest();
            insert testEvent;
        Test.stopTest();
        testLead = [SELECT X1st_Visit_Date__c, X1st_Visit_Status__c FROM Lead WHERE Id =: testLead.Id];
        //Asserting if Inserted Events ActivityDateTime is same as X1st_Visit_Date__c of Its Lead
        System.assertEquals(System.Now().dateGMT(),testLead.X1st_Visit_Date__c.dateGMT(), 'X1st_Visit_Date__c is Not Updated');
        //Asserting if Inserted Events Event_Status__c is same as X1st_Visit_Status__c of Its Lead
        System.assertEquals('Pending',testLead.X1st_Visit_Status__c, 'X1st_Visit_Status__c is Not Updated');
        System.DEBUG('Nimil : ' + testLead);
        
    }
    
    @isTest(seeallData=false)
    static void EventManager_OnUpdate_CheckLeadUpdated() {
        Lead testLead = new Lead(LastName = 'TestLead', Company = 'TestCompany',Status = 'Data Quality',BDC__c = '005D00000037SsA', MADE_Criteria__C = 'Outbound - 1', LeadSource = 'Seminar', appointment_Type__C = 'H&S', email= 'test@citation.co.uk',salutation = 'Mr',Street='Test Street',PostalCode = 'SK9 5AU',position__c='Boss',Visit_Type__c='Face to Face');
        insert testLead; 
        Event testEvent = new Event(whoId = testLead.Id,ActivityDateTime = System.Now(), EndDateTime = System.Today().addDays(1), 
                                    Event_Status__c = 'Pending', Type = '1st Visit');
        insert testEvent;
        testEvent.Event_Status__c = 'Pending';
        Test.startTest();
            update testEvent;
        Test.stopTest();
        testLead = [SELECT X1st_Visit_Date__c, X1st_Visit_Status__c FROM Lead WHERE Id =: testLead.Id];
        //Asserting if Inserted Events ActivityDateTime is same as X1st_Visit_Date__c of Its Lead
        System.assertEquals(System.Now().dateGMT(),testLead.X1st_Visit_Date__c.dateGMT(), 'X1st_Visit_Date__c is Not Updated');
        //Asserting if Inserted Events Event_Status__c is same as X1st_Visit_Status__c of Its Lead
        System.assertEquals('Pending',testLead.X1st_Visit_Status__c, 'X1st_Visit_Status__c is Not Updated');
        System.DEBUG('Nimil : ' + testLead);
        
    }

    @isTest
    private static void clientRelationsEvent(){
        
        list<account> acct = TestDataFactory.getAccounts(1,'Subject Event test',true);
        list<id> acid = new list<id>();
        acid.add(acct[0].id);
        Id eventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Client Relations Record Type').getRecordTypeId();
        list<contact> lstct = TestDataFactory.getContacts(1,'Subject Event test','client Relations Event',acct[0].id,true);
        lstct[0].Email ='test@gmail.com';
        update lstct[0];
        list<opportunity> oppList = TestDataFactory.generateOppsForAccount(acct[0].id,1000,1,true);
        List<event> eventsToInsert=new List<event>();
        event et = new event();
        et.StartDateTime = system.now();
        et.EndDateTime = system.now()+1;
        et.WhatId = oppList[0].id;
        et.whoid = lstct[0].id;
        et.Contact_Type__c = 'Inbound';
        et.RecordTypeId = eventRecordTypeId;
        et.Event_Status__c = 'Booked';
        et.Location = 'Test Event';
        et.Type = 'Renewal';
        et.Subject = 'TEST 123';
        //Adding et to eventsToInsert
        eventsToInsert.add(et);
        //Creating Another Event with Account Id as WhatId
        event etwithWhatIdasAccountId = new event();
        etwithWhatIdasAccountId.StartDateTime = system.now();
        etwithWhatIdasAccountId.EndDateTime = system.now()+1;
        etwithWhatIdasAccountId.WhatId = acct[0].id;
        etwithWhatIdasAccountId.whoid = lstct[0].id;
        etwithWhatIdasAccountId.Contact_Type__c = 'Inbound';
        etwithWhatIdasAccountId.RecordTypeId = eventRecordTypeId;
        etwithWhatIdasAccountId.Event_Status__c = 'Booked';
        etwithWhatIdasAccountId.Location = 'Test Event';
        etwithWhatIdasAccountId.Type = 'Renewal';
        etwithWhatIdasAccountId.Subject = 'TEST 123';
        etwithWhatIdasAccountId.post_code__c = 'S72 7AB';
        //Adding etwithWhatIdasAccountId to eventsToInsert
        eventsToInsert.add(etwithWhatIdasAccountId);
        test.startTest();
        insert eventsToInsert;        
        test.StopTest();
    } 
    
    @isTest public static void restrictBDMtoDeleteEventsTestforBDMS(){
        User citationBDMUser=TestDataFactory.createUser_Generic('Citation BDM','',true);
        System.runAs(citationBDMUser){
            try{
                List<Account> accountforWhatId=TestDataFactory.getAccounts(1, 'restrictBDMtoDeleteEventsTestforBDMSAccount', true);
                List<Contact> contactforWhoId=TestDataFactory.getContacts(1, 'Test','restrictBDMtoDeleteEventsTestforBDMSContact',accountforWhatId[0].Id, true);
                List<Event> eventtoInsert=TestDataFactory.generateEvents(1, 'restrictBDMtoDeleteEventsTestforBDMS', System.now(), System.now().addHours(3), '1st Visit','Confirmed',contactforWhoId[0].Id ,accountforWhatId[0].Id);
                insert eventtoInsert;
                Test.startTest();
                delete eventtoInsert;
                Test.stopTest();
                List<Event> eventsafterDelete=[Select Id From Event];
                System.assertEquals(false,eventsafterDelete.isEmpty(),'Event is Deleted when it is Expected to be not Deleted');
            }
            catch(Exception e){
                System.assertEquals(true, e.getMessage().contains('Please Cancel the Event - Event Cannot be Deleted.'), 'Other Exception'+e.getMessage());
            }
        }
    }
    
    @isTest public static void restrictBDMtoDeleteEventsTestforOthers(){
        User citationDataAdminUser=TestDataFactory.createUser_Generic('Citation Data Admin','',true);
        System.runAs(citationDataAdminUser){
            Features__c f=new Features__c(Name='Default',Event_Subject_Fix__c=true);
            insert f;
            List<Account> accountforWhatId=TestDataFactory.getAccounts(1, 'restrictBDMtoDeleteEventsTestforBDMSAccount', true);
            List<Contact> contactforWhoId=TestDataFactory.getContacts(1, 'Test','restrictBDMtoDeleteEventsTestforBDMSContact',accountforWhatId[0].Id, true);
            List<Event> eventtoInsert=TestDataFactory.generateEvents(1, 'restrictBDMtoDeleteEventsTestforBDMS', System.now().addHours(24), System.now().addhours(25), '1st Visit','Confirmed',contactforWhoId[0].Id ,accountforWhatId[0].Id);
            insert eventtoInsert;
            Test.startTest();
            delete eventtoInsert;
            Test.stopTest();
            List<Event> eventsafterDelete=[Select Id From Event];
            System.assertEquals(true,eventsafterDelete.isEmpty(),'Event is not Deleted when it is Expected to be Deleted');
        }
    }
}