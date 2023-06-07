@isTest
public class ContactBatchProcess_TEST {
	 static testMethod void executeTest() 
    {
        List<Account> accList = TestDataFactory.getAccounts(1,'TestAc',true);
        List<Contact> conList = TestDataFactory.getContacts(50,'TestFN','TestLN',accList[0].Id,false);
        integer i = 0;
        for(Contact c : conList){
            c.email = 'test' + i + '@test.com';
            i++;
        }
        insert conList;
        for(Contact con : conList){
            con.individualId = null;
        }
        update conList;
     /*   i = 0;
        List<Individual> indvlList = [SELECT Id from Individual WHERE Email__c LIKE 'test%'];
        for(individual ind : indvlList){
            ind.email__c = 'chgtest' + i + '@test.com';
        }
        update indvlList; */
        
        Test.startTest();
			ContactBatchProcess obj = new ContactBatchProcess();
            DataBase.executeBatch(obj); 
        Test.stopTest();
        
        SYSTEM.assertEquals(50, [SELECT count() from Individual WHERE Email__c LIKE 'test%']);
        	
       
    }
}