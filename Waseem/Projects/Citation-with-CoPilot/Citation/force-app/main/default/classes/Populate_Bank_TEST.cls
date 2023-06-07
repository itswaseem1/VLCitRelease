@isTest
public with sharing class Populate_Bank_TEST {
    static testMethod void executeTest() 
    {
       
        Group companyGroup = null;
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            Test.startTest();
            // Create Company
            c2g__codaCompany__c company = new c2g__codaCompany__c();
            company.Name = 'ApexTestCompany';
            company.RecordTypeId = Schema.SObjectType.c2g__codaCompany__c.RecordTypeInfosByName.get('VAT').RecordTypeId;
            insert company;
            // Create Company Queue
            c2g.CODACompanyWebService.createQueue(company.Id, 'EUR', company.Name);
            // Activate the Company
            c2g.CODAYearWebService.calculatePeriods(null); // Workaround to bug in company API's, safe to remain once fixed
            c2g.CODACompanyWebService.activateCompany(company.Id, 'EUR', company.Name);
            // Assign the User to the Company
            c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
            userCompany.c2g__Company__c = company.Id;
            userCompany.c2g__User__c = UserInfo.getUserId();
            insert userCompany;
            // Assign the User to the Company Queue
            String queueName = 'FF ' + company.Name;
            companyGroup = [select Id from Group where Name = :queueName And Type = 'Queue'];
            insert new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = UserInfo.getUserId());
            
/*            c2g__codaGeneralLedgerAccount__c GLA = NEW c2g__codaGeneralLedgerAccount__c(Name = 'Test');
            GLA.c2g__ReportingCode__c = 'TEST';
            gla.c2g__Type__c = 'Balance Sheet';
            insert gla;
            
            c2g__codaAccountingCurrency__c cur = new c2g__codaAccountingCurrency__c();
            cur.CurrencyIsoCode = 'EUR';
            cur.c2g__DecimalPlaces__c = 2;
            insert cur;
            
           c2g__codaJournal__c journal = new c2g__codaJournal__c();
        	journal.c2g__JournalDate__c = Date.today().addMonths(-1);
            journal.c2g__JournalCurrency__c = cur.Id;
        	insert journal;
 
        	c2g__codaJournalLineItem__c journalLine1 = new c2g__codaJournalLineItem__c();
        	journalLine1.c2g__LineType__c = 'General Ledger Account';
        	journalLine1.c2g__Journal__c = journal.Id;
        	journalLine1.c2g__GeneralLedgerAccount__c = gla.Id;
        	journalLine1.c2g__Value__c = 42;
        	c2g__codaJournalLineItem__c journalLine2 = new c2g__codaJournalLineItem__c();
        	journalLine2.c2g__LineType__c = 'General Ledger Account';
        	journalLine2.c2g__Journal__c = journal.Id;
        	journalLine2.c2g__GeneralLedgerAccount__c = gla.Id;
        	journalLine2.c2g__Value__c = -42;
        	insert new List<c2g__codaJournalLineItem__c> {journalLine1, journalLine2};
 
	        c2g.CODAAPIJournal_12_0.PostJournal(null, c2g.CODAAPICommon.getRef(journal.Id, null));
            
            c2g__codaBankAccount__c acd = NEW c2g__codaBankAccount__c(Name = 'Test');
            acd.c2g__AccountName__c = 'TestAc';
            acd.c2g__AccountNumber__c = '1234';
            acd.c2g__BankName__c = 'Test Bank';
            acd.c2g__ReportingCode__c =  'TEST';
            acd.c2g__GeneralLedgerAccount__c = gla.id;
            acd.c2g__BankAccountCurrency__c = cur.Id;
            insert acd;
            
            c2g__codaBankReconciliation__c BnkRecon = new c2g__codaBankReconciliation__c(Name = 'Test');
            BnkRecon.c2g__StatementDate__c = System.today().AddDays(-1);
            BnkRecon.c2g__ClosingBalance__c = 0;
            BnkRecon.c2g__BankAccount__c = acd.id;
            insert BnkRecon;
            
            CSV_Bank_Recon__c csvRecon = new CSV_Bank_Recon__c();
            csvRecon.Processed__c = false;
            csvRecon.Bank_Reconciliation__c = BnkRecon.Id;
            csvRecon.Cash_Entry__c = 'abc123';
            insert csvRecon;
            
            c2g__codaTransaction__c tran =	[select id, c2g__DocumentTotal__c from c2g__codaTransaction__c LIMIT 1];
            
       //     c2g__codaTransaction__c tran = new c2g__codaTransaction__c();
       //     tran.c2g__DocumentNumber__c = 'abc123';
       //     insert tran; 
            
            c2g__codaTransactionLineItem__c tranLine = new c2g__codaTransactionLineItem__c();
            tranLine.c2g__LineType__c = 'Analysis';
            tranLine.c2g__Transaction__c = tran.Id;
            insert tranLine; 
            */
            
            Populate_Bank obj = new Populate_Bank();
            DataBase.executeBatch(obj); 
            
            
            
            Test.stopTest();
            SYSTEM.assertEquals(0, [SELECT count() from c2g__codaBankReconciliationLineItem__c ]);
        } 
        
    } 
}