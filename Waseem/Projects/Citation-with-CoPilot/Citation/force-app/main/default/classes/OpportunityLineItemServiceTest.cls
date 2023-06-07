@isTest
public class OpportunityLineItemServiceTest {
	@isTest
    private static void whenOppLineInserted_SetCore()
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
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[0].Id),
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[1].Id)
        };
            
		MockSelector selector = new MockSelector();
        selector.coreProductIdSet = new Set<Id>{prdsList[0].Id};
            
        Test.startTest();
        new OpportunityLineItemService(selector).setDefaults(oppLineItems);
        Test.stopTest();

        System.assertEquals(True, oppLineItems[0].Is_Core__c);
        System.assertEquals(False, oppLineItems[1].Is_Core__c);
    }
    
    @isTest
    private static void selector_returnsCoreProducts()
    {        
        Account act  = new Account(name='test', Open_Core_Opportunities__c = true) ;
        insert act;
        
        List<Product2> prdsList = new List<Product2>{
            new Product2(Name = 'Core Product', Is_Core__c=true),
            new Product2(Name = 'Non Core Product', Is_Core__c=false)
        };
        insert prdsList;
        
        Opportunity opp= new Opportunity(Name='test', StageName='In Progress', CloseDate=System.today()+10);
        insert opp;
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>{
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[0].Id),
            new OpportunityLineItem(OpportunityId = opp.Id, Product2Id=prdsList[1].Id)
        };
        
        Set<Id> response = new OpportunityLineItemService.DefaultSelector().getCoreProducts(oppLineItems);

        System.assertEquals(1, response.size());
        System.assert(response.contains(prdsList[0].Id));
        System.assert(!response.contains(prdsList[1].Id));
    }
    
    class MockSelector implements OpportunityLineItemService.ISelector
    {
        Set<Id> coreProductIdSet = new Set<Id>();
        public Set<Id> getCoreProducts(List<OpportunityLineItem> sourceOppLines)
        {
            return coreProductIdSet;
        }
    }
}