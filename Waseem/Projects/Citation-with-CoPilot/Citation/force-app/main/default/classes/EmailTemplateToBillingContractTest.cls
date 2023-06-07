@isTest
public class EmailTemplateToBillingContractTest {
    @testSetup
    public static void makeData(){
        User u = TestDataFactory.createUser_Generic('System Administrator','System Admin',true);
        Test.startTest();
        System.runAs(u){
        List<fferpcore__Company__c> com = TestDataFactory.getCompanys('Citation');
        insert com;
        List<Contract> contractList = TestDataFactory.getStandardContracts();
        System.debug('SF Contract:::::'+contractList);
        List<ffbc__Contract__c> billCon = TestDataFactory.getBillingContracts(com[0].Id);
        System.debug('Billing Contract:::::'+billCon);
        billCon[0].SF_Contract__c=contractList[0].Id;
        System.debug('Only SF Contract Value:::'+billCon[0].SF_Contract__c);
        insert billCon[0];
        List<Product2> proList = TestDataFactory.getProducts('Atlas UpSkill','Monthly Flat Phased - Contract');
        List<Revenue_Recognition_Logic__c> getRevLogic = TestDataFactory.getRevRecLogic('Atlas Rev','New','Monthly Flat Phased - Contract','Citation Limited');
        insert getRevLogic[0];
        List<ffbc__ContractLineItem__c> getContractLines = TestDataFactory.getContractLineItems(billCon[0].Id,proList[0].Id,getRevLogic[0].Id);
        insert getContractLines[0];
        Document doc = TestDataFactory.getDocument();
        EmailTemplate em = TestDataFactory.getEmailTemplate();
        List<SBQQ__Subscription__c> subList = TestDataFactory.getSubscriptions(1);
        subList[0].SBQQ__Contract__c = contractList[0].Id;
        insert subList[0];
        System.debug('Subscription Lists:::'+subList);
        }
        Test.stopTest();
    }
    
    public static testMethod void executeData(){
        List<ffbc__Contract__c> billConList = [SELECT Id,SF_Contract__c FROM ffbc__Contract__c];
        List<Contract> con = [SELECT Id,Customer_Signatory_Email_Address__c,CustomerSigned.Id FROM Contract];
        List<SBQQ__Subscription__c> subList = [SELECT Id FROM SBQQ__Subscription__c];
        System.debug('SF Contract values:::'+con);
        System.debug('SF Contract values:::'+subList);
        EmailTemplate et = [SELECT Id FROM EmailTemplate LIMIT 1];
        EmailTemplateToBillingContract etbc = new EmailTemplateToBillingContract();
        etbc.documentMapping(billConList);
        etbc.sendingEmail(billConList);
        Test.startTest();
        for(ffbc__Contract__c ffbc : [SELECT Id,SF_Contract__r.CustomerSignedId,SF_Contract__r.Customer_Signatory_Email_Address__c,SF_Contract__r.RecordType.Name FROM ffbc__Contract__c WHERE Id IN:billConList]){
            System.assertEquals('E-Commerce',ffbc.SF_Contract__r.RecordType.Name);
        }
        Test.stopTest();
    }
}