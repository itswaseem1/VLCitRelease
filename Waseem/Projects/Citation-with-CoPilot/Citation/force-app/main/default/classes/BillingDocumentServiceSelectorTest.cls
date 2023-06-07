@isTest
public class BillingDocumentServiceSelectorTest
{
    @TestSetup
    static void makeData(){
        account a = new account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
        insert a;
        ffbc__contract__c cont = new ffbc__contract__c(CustomerReference__c = 'TestRef', ffbc__account__c = a.id) ;
        insert cont ;
    }

    @isTest
    private static void testSelectsCustomerReference()
    {
        ffbc__contract__c cont = [SELECT Id FROM ffbc__contract__c WHERE CustomerReference__c = 'TestRef'];

        fferpcore__BillingDocument__c doc = new fferpcore__BillingDocument__c(ffbc__Contract__c = cont.Id);
        TestUtility.setID(doc);
        
        Test.startTest();
        Map<Id, ffbc__Contract__c> results = new BillingDocumentServiceSelector().loadRelatedContracts(new List<fferpcore__BillingDocument__c>{doc});
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('TestRef', results.get(doc.Id).CustomerReference__c);
    } 
}