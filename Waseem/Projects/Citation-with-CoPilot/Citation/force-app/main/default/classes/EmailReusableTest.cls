@isTest
Public class EmailReusableTest{

    public testmethod static void positive1(){
            Lead ld = new lead();
            ld.firstname = 'test';
            ld.lastname = 'test one';
            ld.email = 'srikanthragi@citation.co.uk';
            ld.company = 'Test';
            ld.BDC__c=UserInfo.getUserId();
            ld.recordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Citation Referral Record').getRecordTypeId();
            ld.ReferredByClientPartnerEmail__c = 'srikanthragi@citation.co.uk';
            insert ld;
            string st = ld.id+'-Client_Referral_Prospect_Email';
            list<string> stlist = new list<string>();
            stlist.add(st);
            EmailReusable.sendEmail(stlist);


    }

}