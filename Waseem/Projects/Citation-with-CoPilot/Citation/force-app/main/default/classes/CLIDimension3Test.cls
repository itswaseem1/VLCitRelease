@isTest
public class CLIDimension3Test {
	@TestSetup
    static void makeData(){
        List<fferpcore__Company__c> com = TestDataFactory.getCompanys('Citation');
        insert com;    
        List<ffbc__Contract__c> billCon = TestDataFactory.getBillingContracts(com[0].Id);
        insert billCon;
        List<Revenue_Recognition_Logic__c> rev = TestDataFactory.getRevRecLogic('Rev Rec','New','One-Off','Citation Limited');
        insert rev;
        List<Product2> prods = TestDataFactory.getProducts('Additional Tribunal Day', 'One-Off');
        List<ffbc__ContractLineItem__c> conLine = TestDataFactory.getContractLineItems(billCon[0].Id,prods[0].Id,rev[0].Id);
        insert conLine;
    }
    
    public static testMethod void executeData(){
        List<c2g__codaDimension3__c> dim = [SELECT Id FROM c2g__codaDimension3__c];
        List<ffbc__Contract__c> billCon = [SELECT Id FROM ffbc__Contract__c];
    	Test.startTest();
        System.assertNotEquals(0,dim.size());
        System.assertNotEquals(0, billCon.size());
        Test.stopTest();
    }
}