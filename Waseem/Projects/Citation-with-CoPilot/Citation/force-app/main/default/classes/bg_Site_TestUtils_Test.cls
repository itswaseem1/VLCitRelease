@isTest
public class bg_Site_TestUtils_Test {
	@isTest static void createSiteTest()
     {
        List<Account> accList = TestDataFactory.getAccounts(1,'TestAc',true);
         Site__c site = bg_Site_TestUtils.createSite('testSite', accList[0].id);
    }
}