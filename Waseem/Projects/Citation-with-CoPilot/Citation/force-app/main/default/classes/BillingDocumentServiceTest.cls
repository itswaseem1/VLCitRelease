@isTest
public with sharing class BillingDocumentServiceTest 
{
    private static IDomainService createService(BillingDocumentService.ISelector selector)
    {
        return new BillingDocumentService(selector);
    }

    @isTest
    private static void whenContractsHaveReference_SetsOnBillingDoc()
    {
        // contracts with refs
        List<ffbc__Contract__c> contracts = new List<ffbc__Contract__c>{
            new ffbc__Contract__c(CustomerReference__c = 'reference1'),
            new ffbc__Contract__c(CustomerReference__c = 'reference2')
        };
        TestUtility.setIDs(contracts);

        Map<ID, ffbc__Contract__c> relatedContracts = new Map<ID, ffbc__Contract__c>(contracts);

        // when data
        List<fferpcore__BillingDocument__c> documents = new List<fferpcore__BillingDocument__c>{
            new fferpcore__BillingDocument__c(ffbc__Contract__c = contracts[0].Id),
            new fferpcore__BillingDocument__c(ffbc__Contract__c = contracts[1].Id)
        };

        Test.startTest();
        BillingDocumentService.ISelector selector = new MockSelector();
        ((MockSelector)selector).relatedContracts = relatedContracts;

        IDomainService service = createService(selector);
        service.setDefaults(documents);
        Test.stopTest();

        System.assertEquals('reference1', documents[0].fferpcore__CustomerReference__c);
        System.assertEquals('reference2', documents[1].fferpcore__CustomerReference__c);
    }

    @isTest
    private static void whenSomeContractHaveReference_SetsOnlyBillingDocThatMatch()
    {
        // contracts with refs
        List<ffbc__Contract__c> contracts = new List<ffbc__Contract__c>{
            new ffbc__Contract__c(CustomerReference__c = 'reference1'),
            new ffbc__Contract__c()
        };
        TestUtility.setIDs(contracts);

        Map<ID, ffbc__Contract__c> relatedContracts = new Map<ID, ffbc__Contract__c>(contracts);

        // when data
        List<fferpcore__BillingDocument__c> documents = new List<fferpcore__BillingDocument__c>{
            new fferpcore__BillingDocument__c(ffbc__Contract__c = contracts[0].Id),
            new fferpcore__BillingDocument__c(ffbc__Contract__c = contracts[1].Id)
        };

        Test.startTest();
        BillingDocumentService.ISelector selector = new MockSelector();
        ((MockSelector)selector).relatedContracts = relatedContracts;
        
        IDomainService service = createService(selector);
        service.setDefaults(documents);
        Test.stopTest();

        System.assertEquals('reference1', documents[0].fferpcore__CustomerReference__c);
        System.assertEquals(null, documents[1].fferpcore__CustomerReference__c);
    }

    @isTest
    private static void whenNoRelatedContract_NoBillingDocReferencesSet()
    {
        // when data
        List<fferpcore__BillingDocument__c> documents = new List<fferpcore__BillingDocument__c>{
            new fferpcore__BillingDocument__c(),
            new fferpcore__BillingDocument__c()
        };

        Test.startTest();
        BillingDocumentService.ISelector selector = new MockSelector();
        
        IDomainService service = createService(selector);
        service.setDefaults(documents);
        Test.stopTest();

        System.assertEquals(null, documents[0].fferpcore__CustomerReference__c);
        System.assertEquals(null, documents[1].fferpcore__CustomerReference__c);
    }

    @isTest
    private static void whenABillingDocHasReferenceAlready_NoDefaultBillingDocReferencesSet()
    {
        // contracts with refs
        List<ffbc__Contract__c> contracts = new List<ffbc__Contract__c>{
            new ffbc__Contract__c(CustomerReference__c = 'reference1'),
            new ffbc__Contract__c(CustomerReference__c = 'reference2')
        };
        TestUtility.setIDs(contracts);

        Map<ID, ffbc__Contract__c> relatedContracts = new Map<ID, ffbc__Contract__c>(contracts);

        // when data
        List<fferpcore__BillingDocument__c> documents = new List<fferpcore__BillingDocument__c>{
            new fferpcore__BillingDocument__c(ffbc__Contract__c = contracts[0].Id, fferpcore__CustomerReference__c = 'Existing1'),
            new fferpcore__BillingDocument__c(ffbc__Contract__c = contracts[1].Id)
        };

        Test.startTest();
        BillingDocumentService.ISelector selector = new MockSelector();
        ((MockSelector)selector).relatedContracts = relatedContracts;
        
        IDomainService service = createService(selector);
        service.setDefaults(documents);
        Test.stopTest();

        System.assertEquals('Existing1', documents[0].fferpcore__CustomerReference__c);
        System.assertEquals('reference2', documents[1].fferpcore__CustomerReference__c);
    }

    @isTest
    private static void testSelector_findsCustomerReference()
    {
        // setup data.
        account a = new account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
        insert a;

        ffbc__contract__c cont = new ffbc__contract__c(CustomerReference__c = 'TestRef', ffbc__account__c = a.id) ;
        insert cont ;

        fferpcore__BillingDocument__c doc = new fferpcore__BillingDocument__c(ffbc__Contract__c = cont.Id);
        
        Test.startTest();
        Map<Id, ffbc__Contract__c> results = new BillingDocumentService.BillingDocumentServiceSelector().loadRelatedContracts(new List<fferpcore__BillingDocument__c>{doc});
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('TestRef', results.get(cont.Id).CustomerReference__c);
    } 

    class MockSelector implements BillingDocumentService.ISelector
    {
        Map<ID, ffbc__Contract__c> relatedContracts = new Map<ID, ffbc__Contract__c>();

        public Map<Id, ffbc__Contract__c> loadRelatedContracts(List<fferpcore__BillingDocument__c> documents)
        {
            return relatedContracts;
        }
    }
}