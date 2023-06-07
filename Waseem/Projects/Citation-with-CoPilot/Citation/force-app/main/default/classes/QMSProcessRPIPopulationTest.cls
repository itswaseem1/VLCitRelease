@isTest
public class QMSProcessRPIPopulationTest {
    @testSetup
    public static void makeData(){
        User u = TestDataFactory.createUser_Generic('System Administrator','System Admin',true);
        Test.startTest();
        System.runAs(u){
    	List<fferpcore__Company__c> com = TestDataFactory.getCompanys('Citation');
        insert com;
        List<Contract> contractList = TestDataFactory.getStandardContracts();
        List<ffbc__Contract__c> billCon = TestDataFactory.getBillingContracts(com[0].Id);
        billCon[0].SF_Contract__c=contractList[0].Id;
        insert billCon[0];
        List<Product2> proList = TestDataFactory.getProducts('Atlas UpSkill','Monthly Flat Phased - Contract');
        proList[0].Family='Audit';
        update proList[0];
        List<Revenue_Recognition_Logic__c> getRevLogic = TestDataFactory.getRevRecLogic('Atlas Rev','New','Monthly Flat Phased - Contract','Citation Limited');
        insert getRevLogic[0];
        ffbc__SoftDate__c sf = new ffbc__SoftDate__c();
        sf.Name = 'Quarterly';
        sf.ffbc__Definition__c = '+1M';
        insert sf;
        List<ffbc__ContractLineItem__c> getContractLines = TestDataFactory.getContractLineItems(billCon[0].Id,proList[0].Id,getRevLogic[0].Id);
        getContractLines[0].ffbc__BillingTerm__c = sf.Id;
        insert getContractLines[0];
        }
    }
    
    public static testMethod void executeData(){
        List<ffbc__Contract__c> billCon = [SELECT Id,QMS_Process_RPI_Rollup__c FROM ffbc__Contract__c];
        for(ffbc__Contract__c ffbc : billCon){
            System.assert(ffbc.QMS_Process_RPI_Rollup__c!=null);
        }
    }
}