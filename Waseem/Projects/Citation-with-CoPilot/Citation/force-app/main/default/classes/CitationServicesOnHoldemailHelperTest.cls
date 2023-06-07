@isTest
private class CitationServicesOnHoldemailHelperTest {
    static testMethod void test () {
        
        test.startTest();
       List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.put('Name', '$$$$$$$Product Services$$$$$$$');
        acc.put('CurrencyIsoCode', 'USD');
        acc.put('AccountNumber', 'CD656092');
        acc.put('Type', 'Customer - Direct');
        acc.put('Industry', 'Apparel');
        acc.put('AnnualRevenue', 350000000);
        acc.put('Ownership', 'Public');
        acc.put('Rating', 'Warm');
        acc.put('Phone', '(336) 222-7000');
        acc.put('Fax', '(336) 222-8000');
        acc.put('Website', 'http://www.financialforce.com');
        acc.put('TickerSymbol', 'BTXT');
        acc.put('NumberOfEmployees', 9000);
        acc.put('SIC', '546732');
       // accList.add(acc);
        insert acc;
        
       
        
            Contact con = new Contact();
            con.FirstName = 'Xyz';
            con.LastName  = 'abc';
            con.AccountId = acc.Id;
            con.Email = 'abc@citation.co.uk.abc';       
            insert con;
        Id onhold =[Select id from Group where Name = 'On-Hold'].Id;

       List<Case> caselist  = new list<Case>();
        Id rTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('S360_Atlas_Support').getRecordTypeId();
        Id rTID1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
        Id rTID2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HS_Advice_Generic').getRecordTypeId();
       // Id rTID3 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Citation_Client_Operations').getRecordTypeId();
        Id rTID4 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HR_CYJ').getRecordTypeId();
       // Id rTID5 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Citation_Contract_Admin').getRecordTypeId();
        //Id rTID6 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Citation_Common_Request').getRecordTypeId();
      Id rTID7 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Reception_General').getRecordTypeId();
        Case cemail = new Case();
        cemail.RecordTypeId=rTID;
        cemail.Status='New';
        cemail.AccountId = acc.Id;
       // cemail.PreviousOwnerId__c=cemail.OwnerId;
        cemail.ContactId =con.Id;
        //cemail.OwnerId = cemail.PreviousOwnerId__c;
        caselist.add(cemail);
        System.assertEquals(acc.Id, cemail.AccountId , 'success');
         System.assertEquals(con.Id, cemail.ContactId , 'success');
        Case ceemail = new Case();
        ceemail.RecordTypeId=rTID1;
        ceemail.Status='In Progress';
        ceemail.AccountId = acc.Id;
        ceemail.PreviousOwnerId__c=onhold;
        ceemail.OwnerId = ceemail.PreviousOwnerId__c;
        //ceemail.Contact.Email = 'abc@citation.com';

        caselist.add(ceemail);
        
        Case ceemail2 = new Case();
        ceemail2.RecordTypeId=rTID2;
        ceemail2.Status='In Progress';
        ceemail2.AccountId = acc.Id;
        ceemail2.PreviousOwnerId__c=onhold;
        ceemail2.OwnerId = ceemail2.PreviousOwnerId__c;
        caselist.add(ceemail2);
        
       Case ceemail3 = new Case();
        ceemail3.RecordTypeId=rTID;
        ceemail3.Status='In Progress';
        ceemail3.AccountId = acc.Id;
        ceemail3.PreviousOwnerId__c=onhold;
        ceemail3.OwnerId = ceemail3.PreviousOwnerId__c;
        //ceemail.Contact.Email = 'abc@citation.com';

        caselist.add(ceemail3);
        
       /*  Case ceemail4 = new Case();
        ceemail4.RecordTypeId=rTID4;
        ceemail4.Status='In Progress';
        ceemail4.AccountId = acc.Id;
        ceemail4.PreviousOwnerId__c=onhold;
        ceemail4.OwnerId = ceemail4.PreviousOwnerId__c;
        //ceemail.Contact.Email = 'abc@citation.com';

        caselist.add(ceemail4);
        
        Case ceemail5 = new Case();
        ceemail5.RecordTypeId=rTID7;
        ceemail5.Status='In Progress';
        ceemail5.AccountId = acc.Id;
        ceemail5.PreviousOwnerId__c=onhold;
        ceemail5.OwnerId = ceemail5.PreviousOwnerId__c;
        //ceemail.Contact.Email = 'abc@citation.com';

        caselist.add(ceemail5);
        
        Case ceemail6 = new Case();
        ceemail6.RecordTypeId=rTID6;
        ceemail6.Status='In Progress';
        ceemail6.AccountId = acc.Id;
        ceemail6.PreviousOwnerId__c=[Select id from Group where Name = 'On-Hold'].Id;
        ceemail6.OwnerId = ceemail6.PreviousOwnerId__c;
        //ceemail.Contact.Email = 'abc@citation.com';

        caselist.add(ceemail6);
        
         Case ceemail7 = new Case();
        ceemail7.RecordTypeId=rTID7;
        ceemail7.Status='In Progress';
        ceemail7.AccountId = acc.Id;
        ceemail7.PreviousOwnerId__c=[Select id from Group where Name = 'On-Hold'].Id;
        ceemail7.OwnerId = ceemail7.PreviousOwnerId__c;
        //ceemail.Contact.Email = 'abc@citation.com';

        caselist.add(ceemail7); */
        
        insert(caselist);
        
        
        CitationServicesOnHoldemailHelper.onHoldsendEmail(new Id[] { acc.Id });
        CitationServicesOffHoldbackToCaseQueue.offHoldbacktoCaseQueue(new Id[] { acc.Id });
        System.assertEquals(4,caselist.size() , 'success');
         test.stopTest();
        
    }

}