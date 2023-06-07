@isTest
public class OpportunityLineItemTriggerTest 
{
    class Factory implements TriggerFrameworkTest.IFactory
    {
        private OpportunityLineItem record;

        Factory()
        {
            Product2 pro = new Product2(Name = 'Test X', Family = 'Test');
            Insert pro;
 
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            Update standardPricebook;
 
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = pro.Id,
                UnitPrice = 1020,
                IsActive = true
            );
            Insert pbe;

            Account act = new Account(Name = 'Bub');
            insert act;

            Opportunity opp = new Opportunity(Name = 'Stuff', 
                                                AccountId = act.Id, 
                                                StageName = 'Renewal Contact Due', 
                                                CloseDate = Date.today()+740);

            insert opp;

            record = new OpportunityLineItem(
                PricebookEntryId = pbe.ID,
                quantity = 1,
                TotalPrice = 100,
                opportunityid = opp.Id
            );
        }

        public ITriggerHandler getTriggerHandler(IDomainService service)
        {
            return new DefaultTriggerHandler(service, null);
        }

        public SObject getRecordToInsert()
        {
            return record;
        }

        public SObject getRecordToUpdate()
        {
            record.Logs__c = 'More Stuff';
            return record;
        }

        public SObject getRecordToDelete()
        {
            return record;
        }

        public SObject getRecordToUndelete()
        {
            return record;
        }
    }

    @isTest
    private static void testFramework()
    {
        TriggerFrameworkTest.testDMLToService(new Factory());
    }
}