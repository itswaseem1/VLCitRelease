@isTest
public with sharing class TestAccountProduct {

@isTest
private static void testAccountdetails(){
        list<contact> cont= TestDataFactory.generateAccountWithContacts('Test Account Product',1,'Test contact','last name',false);
        contact ct = cont[0];
        ct.email = 'srikanthragi@citation.co.uk';
        insert ct;

        contact oc = [select id,name,email,accountid from contact limit 1];
        list<opportunity> opls = TestDataFactory.generateOppsForAccount(oc.accountid,1000,1,true);
        datetime temp = system.now();
        integer yesrd = system.now().year();
        integer monsrd = system.now().month();
        integer daysrd = system.now().day();
        Datetime stDateTime = Datetime.newInstance(yesrd, monsrd, daysrd+1, 11, 00, 0);
        Datetime enDateTime = Datetime.newInstance(yesrd, monsrd, daysrd+1, 13, 00, 0);
        
        list<event> evl = TestDataFactory.generateEvents(1, '1st Meeting', stDateTime,enDateTime, 'Outboubd', 'Booked', oc.id,opls[0].id);
        Datetime newDateTime = system.now().addDays(2);
        event et = evl[0];
        et.recordtypeid = System.Label.CRE_Record_Type;
        //et.WhoId = ct.id;
        Date myDate = system.today();
        et.Cancellation_Date__c = system.today();
        et.Cancellation_Reason__c = 'Cancel In Advance';
        et.Cancellation_By__c = 'Client';
        et.Cancellation_Status__c = 'E-mailed in';
        et.Rebooking_Date__c = newDateTime;
        insert et;
        /*EventRelation ert = new EventRelation();
        ert.RelationId = oc.id;
        ert.eventid = et.id;
        insert ert;*/
              
        test.startTest();
            et.event_status__c ='Cancel and Re-book';
            RecursiveTriggerHandler.isFirstTime = true;
            //update et;

        
        list<contract> ctlist = TestDataFactory.getContracts(2);
        for(contract ct1: ctlist){
            contract cot = ct1;
            cot.Services_Taken_Env__c = true;
            cot.Services_Taken_HS__c = true;
            cot.Services_Taken_EL__c = true;
            cot.status = 'Draft';
            cot.CustomerSignedId = oc.id;
            cot.accountid = opls[0].accountid;
        }
        insert ctlist;
        // SBQQ__Quote__c cpqquotetest = TestDataFactory.createCPQ_Quote_With_Group_and_QLIs('cpq quotes');
        // cpqquotetest

        list<SBQQ__Subscription__c> subcpq = TestDataFactory.getSubscriptions(1);
        SBQQ__Subscription__c sbp = subcpq[0];
        sbp.SBQQ__Account__c  = oc.accountid;
        sbp.SBQQ__Contract__c = ctlist[1].id;
        insert sbp;
        AccountProduct.getAccountDetails(et.id);
    	test.stopTest();
        EventCapSheet.getContacts(et.id);
        // AccountProduct.getSubscriptions(et.accountid);
        AccountProduct.getSubscriptions(et.id);
    	
    }

}