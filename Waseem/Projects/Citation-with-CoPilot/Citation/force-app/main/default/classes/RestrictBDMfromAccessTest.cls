@isTest
public class RestrictBDMfromAccessTest {
    /*
    * @date 12-09-2022
    * @description This Method inserts necessary data for all other TestMethods in this class
    * @param None
    * @return Void
    */
    @testsetup public static void essentialRecords(){
        UserRole userRole = new UserRole(DeveloperName = 'CitationDeveloper', Name = 'Citation Limited');
        insert userRole;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Citation BDM' LIMIT 1].Id,
            FirstName       = 'Test',
            LastName        = 'testasBDM',
            Email           = 'testasBDMOwner@citation.co.uk',
            Username        = 'testasBDMOwner@citation.co.uk',
            CompanyName     = 'Citation Company',
            Title           = 'Captian',
            Alias           = 'tBDM',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US',
            UserRoleId      = userRole.Id
        );
        insert u;
        System.runAs(u){
            Id currentUserId=UserInfo.getUserId();
            Account acc=new Account(Name='TestAccount');
            insert acc;
            Event testevent=new Event(WhatId=acc.Id,OwnerId=currentUserId,Subject='Test 1st Meeting',Type='1st Visit',EndDateTime=System.now().addDays(1),StartDateTime=System.now());
            insert testevent;
        }
    }
    /*
    * @date 12-09-2022
    * @description This Method Verifies a Scenario where BDM views other BDMS Records
    * @param None
    * @return Void
    */
    @isTest public static void testasBDM(){
        Event testevent=[Select Id from Event where Subject='Test 1st Meeting'];
        UserRole userRole = [Select Id From UserRole where DeveloperName = 'CitationDeveloper'];
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Citation BDM' LIMIT 1].Id,
            FirstName       = 'Test',
            LastName        = 'testasBDM',
            Email           = 'testasBDM@citation.co.uk',
            Username        = 'testasBDM@citation.co.uk',
            CompanyName     = 'Citation Company',
            Title           = 'Captian',
            Alias           = 'tBDM',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US',
            UserRoleId      = userRole.Id
        );
        insert u;
        System.runAs(u){
            CalendarView bdmcalendarview=new CalendarView(OwnerId=u.Id,Name='Test',SobjectType='Event',StartField='StartDateTime',DisplayField='Subject',PublisherId=u.Id);
            insert bdmcalendarview;
            Test.startTest();
            Boolean returnedvalue=RestrictBDMfromAccessingothersCalendars.verifyandRemoveCalendarView(testevent.Id);
            Test.stopTest();
            List<CalendarView> postcallingbdmcalendarview=[SELECT Id FROM CalendarView where OwnerId=:u.Id];
            System.assertEquals(true,postcallingbdmcalendarview.isempty(),'User not needed to Navigating Back to Calendar Home');
            System.assertEquals(true,returnedvalue,'User is not Navigating Back to Calendar Home');
        }
    }
    /*
    * @date 12-09-2022
    * @description This Method Verifies a Scenario where Non BDM views Records
    * @param None
    * @return Void
    */
    @isTest public static void testascurrentUser(){
        Event testevent=[Select Id from Event where Subject='Test 1st Meeting'];
        Test.startTest();
        Boolean returnedvalue=RestrictBDMfromAccessingothersCalendars.verifyandRemoveCalendarView(testevent.Id);
        Test.stopTest();
        System.assertEquals(false,returnedvalue,'User is Navigating Back to Calendar Home');
    }
    /*
    * @date 12-09-2022
    * @description This Method Verifies a Scenario where BDM views his Own Records
    * @param None
    * @return Void
    */
    @isTest public static void testasOwnerascurrentUser(){
        Event testevent=[Select Id from Event where Subject='Test 1st Meeting'];
        User ownerUser=[Select Id From User where Username = 'testasBDMOwner@citation.co.uk'];
        System.runAs(ownerUser){
            Test.startTest();
            Boolean returnedvalue=RestrictBDMfromAccessingothersCalendars.verifyandRemoveCalendarView(testevent.Id);
            Test.stopTest();
            System.assertEquals(false,returnedvalue,'User is Navigating Back to Calendar Home');
        }
    }
}