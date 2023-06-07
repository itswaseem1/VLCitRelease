@isTest
public class BillingDocumentTriggerTest
{

    @TestSetup
    static void makeData(){
        Account act = new Account(Name='Bob');
        insert act;
    }

    @isTest
    private static void testInsert()
    {
        //set up required extra data.
        Account act = [SELECT Id FROM Account WHERE Name = 'Bob'];

        MockTriggerHandler handler = new MockTriggerHandler();
        TriggerHandlerFactory.registerInstance(fferpcore__BillingDocument__c.SObjectType, handler);

        Test.startTest();

        fferpcore__BillingDocument__c doc = new fferpcore__BillingDocument__c(
                                                    fferpcore__Account__c = act.id,
                                                    fferpcore__DocumentType__c = 'Invoice');
        insert doc;

        Test.stopTest();

        System.assertEquals(true, handler.calledMethods.get('beforeInsert'));
        System.assertEquals(true, handler.calledMethods.get('afterInsert'));
    }

    @isTest
    private static void testUpdate()
    {
        //set up required extra data.
        Account act = [SELECT Id FROM Account WHERE Name = 'Bob'];
        
        MockTriggerHandler handler = new MockTriggerHandler();
        TriggerHandlerFactory.registerInstance(fferpcore__BillingDocument__c.SObjectType, handler);

        fferpcore__BillingDocument__c doc = new fferpcore__BillingDocument__c(
                                                    fferpcore__Account__c = act.id,
                                                    fferpcore__DocumentType__c = 'Invoice');
        insert doc;

        Test.startTest();
        
        fferpcore__BillingDocument__c doc1 = new fferpcore__BillingDocument__c(
                                                    Id = doc.id,
                                                    fferpcore__CustomerReference__c = 'blah');
        
        update doc1;

        Test.stopTest();

        System.assertEquals(true, handler.calledMethods.get('beforeUpdate'));
        System.assertEquals(true, handler.calledMethods.get('afterUpdate'));
    }

    @isTest
    private static void testDelete()
    {
        //set up required extra data.
        Account act = [SELECT Id FROM Account WHERE Name = 'Bob'];
        
        MockTriggerHandler handler = new MockTriggerHandler();
        TriggerHandlerFactory.registerInstance(fferpcore__BillingDocument__c.SObjectType, handler);

        fferpcore__BillingDocument__c doc = new fferpcore__BillingDocument__c(
                                                    fferpcore__Account__c = act.id,
                                                    fferpcore__DocumentType__c = 'Invoice');
        insert doc;

        Test.startTest();
        
        delete new fferpcore__BillingDocument__c(id = doc.id);

        Test.stopTest();

        System.assertEquals(true, handler.calledMethods.get('beforeDelete'));
        System.assertEquals(true, handler.calledMethods.get('afterDelete'));
    }

    @isTest
    private static void testUnDelete()
    {
        //set up required extra data.
        Account act = [SELECT Id FROM Account WHERE Name = 'Bob'];
        
        MockTriggerHandler handler = new MockTriggerHandler();
        TriggerHandlerFactory.registerInstance(fferpcore__BillingDocument__c.SObjectType, handler);

        fferpcore__BillingDocument__c doc = new fferpcore__BillingDocument__c(
                                                    fferpcore__Account__c = act.id,
                                                    fferpcore__DocumentType__c = 'Invoice');
        insert doc;
        delete new fferpcore__BillingDocument__c(id = doc.id);

        Test.startTest();
        
        undelete new fferpcore__BillingDocument__c(id = doc.id);

        Test.stopTest();

        System.assertEquals(true, handler.calledMethods.get('afterUnDelete'));
    }
}