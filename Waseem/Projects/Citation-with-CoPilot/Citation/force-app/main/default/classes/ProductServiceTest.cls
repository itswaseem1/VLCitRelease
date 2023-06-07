@isTest
public class ProductServiceTest {
	@isTest
    private static void whenProductCorenessNotChanged_noUpdateInRelatedOppLineCoreness()
    {
        List<Product2> prdsList = new List<Product2>{
            new Product2(Name = 'Core Product', Is_Core__c=true),
            new Product2(Name = 'Non Core Product', Is_Core__c=false)
        };
        TestUtility.setIDs(prdsList);
        
        Account acc = new Account(Name = 'Smith', BillingPostalCode = 'BN3 3DH');
        TestUtility.setID(acc);
        
        Opportunity opp = new Opportunity(Name = 'Smith', AccountId=acc.Id);
        TestUtility.setID(opp);
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>{
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[0].Id, Is_Core__c=true),
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[1].Id, Is_Core__c=false)
        };
        TestUtility.setIDs(prdsList);
        
        List<Product2> newPrdsList = new List<Product2>{
            new Product2(Name = 'Core Product 1', Is_Core__c=true, Id = prdsList[0].Id),
            new Product2(Name = 'Non Core Product 1',  Is_Core__c=false, Id = prdsList[1].Id)
        };
            
        Test.startTest();
        new ProductService(new MockSelector()).processRelatedRecordsOnChange(newPrdsList, new Map<Id,Product2>(prdsList));
        Test.stopTest();
        
        System.assertEquals(true, oppLineItems[0].Is_Core__c);
        System.assertEquals(false, oppLineItems[1].Is_Core__c);
    }
    
    @isTest
    private static void whenProductCorenessChanged_UpdateRelatedOppLineCoreness(){
        
        List<Product2> prdsList = new List<Product2>{
            new Product2(Name = 'Core Product', Is_Core__c=true),
            new Product2(Name = 'Non Core Product', Is_Core__c=false)
        };
        insert prdsList;
        
        Pricebook2 pb = new PriceBook2(Name = 'Test Pricebook');
        insert pb;
        
        List<pricebookentry> pricebookEntryList = new List<pricebookentry>{
            new pricebookentry(pricebook2id =Test.getStandardPricebookId(), unitprice = 100, product2id = prdsList[0].Id, isactive = true),
            new pricebookentry(pricebook2id =Test.getStandardPricebookId(), unitprice = 100, product2id = prdsList[1].Id, isactive = true)
        };
        insert pricebookEntryList;
        
        Opportunity opp= new Opportunity(Name='test', StageName='In Progress', CloseDate=System.today()+10, Pricebook2Id=pb.Id);
        insert opp;
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>{
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[0].Id, PricebookEntryId = pricebookEntryList[0].Id, Quantity=1, UnitPrice=100),
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[1].Id, PricebookEntryId = pricebookEntryList[1].Id, Quantity=1, UnitPrice=100)
        };
        insert oppLineItems;
        
        List<OpportunityLineItem> insertedOppLineItems = [SELECT Id,Is_Core__c FROM OpportunityLineItem];
        System.assertEquals(true, insertedOppLineItems[0].Is_Core__c);
        System.assertEquals(false, insertedOppLineItems[1].Is_Core__c);
        
        BatchApexController__c setting = new BatchApexController__c();
        setting.Name = 'UpdateOppLinesCorenessBatch';
        setting.Batch_size__c = 10;
        insert setting;
        
        Test.startTest();
        prdsList[0].Is_Core__c = false;
        prdsList[1].Is_Core__c = true;
        update prdsList;
        Test.stopTest();
        
        List<OpportunityLineItem> updatedOppLineItems = [SELECT Id,Is_Core__c FROM OpportunityLineItem];
        System.assertEquals(false, updatedOppLineItems[0].Is_Core__c);
        System.assertEquals(true, updatedOppLineItems[1].Is_Core__c);
    }
    
    class MockSelector implements ProductService.ISelector
    {
        Database.QueryLocator getOppLines;
        public Database.QueryLocator getRelatedOppLines(Set<Id> productIds)
        {
            return getOppLines;
        }
    }
}