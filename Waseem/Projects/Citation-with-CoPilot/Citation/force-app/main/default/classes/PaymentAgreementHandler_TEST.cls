@isTest
public class PaymentAgreementHandler_TEST {
    
    Public static id parecid =  Schema.SObjectType.PAYREC2__Payment_Agreement__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId();
    @isTest(SeeAllData=true)
    static void TestafterInsertQ() {
	String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='rebeccaking@citation.co.uk', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
	System.runAs(u) {

		Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        contact con = TestDataFactory.getContacts(1, 'firstName', 'lastName', testAccount.id, true)[0];
        
        
        PAYREC2__Payment_Schedule__c ps = new PAYREC2__Payment_Schedule__c();
        ps.Name = 'testPS';
        ps.PAYREC2__Frequency__c = 'month';
        ps.PAYREC2__Day__c = '5';
        ps.PAYREC2__Interval__c = 3;
        ps.PAYREC2__Type__c = 'Ongoing';
        insert ps;
        
        PAYACCVAL1__Bank_Account__c pba = new PAYACCVAL1__Bank_Account__c();
        pba.PAYACCVAL1__Account_Number__c = '12345678';
        pba.PAYACCVAL1__Sort_Code__c = '124578';
        pba.PAYFISH3__Account_Name__c = testAccount.name;
        insert pba;
        
        PAYREC2__Payment_Agreement__c pa = new PAYREC2__Payment_Agreement__c();
        pa.PAYREC2__Account__c = testAccount.id;
        pa.PAYREC2__Status__c = 'On going';
        pa.PAYREC2__Payment_Schedule__c = ps.Id;
        pa.PAYREC2__Ongoing_Collection_Amount__c = 200;
        pa.PAYFISH3__FTA_Sub_Type__c = '768335';
        pa.RecordTypeId = String.valueof(parecid).substring(0,15);
        pa.PAYFISH3__Current_Bank_Account__c = pba.id;
        pa.PAYFISH3__Fund_Transfer_Agent__c = 'New fund transfer';
        Test.Starttest();
        	insert pa;
        System.assertEqualS('No current DD', [Select id,Valid_Direct_Debit__c from Account where id = :testAccount.id].Valid_Direct_Debit__c);
        pa.PAYREC2__Status__c = 'New instruction';
        	update pa;
         pa.PAYREC2__Status__c = 'Expired';
        	update pa;
        
        PAYREC2__Payment_Agreement__c pa1 = new PAYREC2__Payment_Agreement__c();
        pa1.PAYREC2__Account__c = testAccount.id;
        pa1.PAYREC2__Status__c = 'Expired';
        pa1.PAYREC2__Payment_Schedule__c = ps.Id;
        pa1.PAYREC2__Ongoing_Collection_Amount__c = 200;
        pa1.PAYFISH3__FTA_Sub_Type__c = '768335';
        pa1.RecordTypeId = String.valueof(parecid).substring(0,15);
        pa1.PAYFISH3__Current_Bank_Account__c = pba.id;
        pa1.PAYFISH3__Fund_Transfer_Agent__c = 'New fund transfer';
        
        	insert pa1;
        
        Test.stopTest();
        
        
        }
    }
    
    private static Account createAccount(String accName, String sector, Decimal fullTimeEmployees, Decimal partTimeEmployees)
    {
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
        //acc.Number_of_Active_Sites__c = 1;
        acc.Sites__c = 1;
        
        insert acc;
        return acc;     
    }
}