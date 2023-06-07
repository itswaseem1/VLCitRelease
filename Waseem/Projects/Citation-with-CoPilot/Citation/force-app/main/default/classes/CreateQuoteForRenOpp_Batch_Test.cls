@isTest
public class CreateQuoteForRenOpp_Batch_Test {
	@isTest
    Public static void executeTest(){
        List<Account> accList = TestDataFactory.getAccounts(1,'Test',True);
        TestDataFactory.generateOppsForAccount(accList[0].id,1000,1,true);
        Test.startTest();
        	CreateQuoteForRenOpp_Batch b = new CreateQuoteForRenOpp_Batch('select id , createddate, AccountId, Original_Contract__c from opportunity');
			ID batchprocessid = Database.executeBatch(b, 1);
        Test.stopTest();
    }
}