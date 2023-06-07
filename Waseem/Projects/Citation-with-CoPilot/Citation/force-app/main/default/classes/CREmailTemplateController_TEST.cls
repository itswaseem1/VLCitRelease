@isTest
public class CREmailTemplateController_TEST {
    
    @testSetup static void setup()
    {
        List<Contact> Contacts = CIT_PH1_Trigger_Utils.createContacts(1);
        insert Contacts;
        Event e = new Event(whoid = Contacts[0].id,
                            durationinminutes=10, 
                            activitydatetime = system.now().adddays(1), 
                            subject = 'Test', 
                            event_status__c  = 'Confirmed',
                            type = 'Call') ;
        insert e ;
    }
    
    static testMethod void TestGetEvent() {
       List<event> eTest = [select id,subject from event] ;
        CREmailTemplateController eTC = new CREmailTemplateController();
        eTC.recid = eTest[0].id;
        Event e = eTC.evnt;
        System.assertNotEquals(Null, e);
    }
}