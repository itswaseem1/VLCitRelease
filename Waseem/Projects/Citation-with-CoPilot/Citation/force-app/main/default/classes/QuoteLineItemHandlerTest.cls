@isTest
public class QuoteLineItemHandlerTest {

    @TestSetup
    static void makeData(){
        
        List<Account> accList = TestDataFactory.getAccounts(1,'Citation Limited',true);
        List<Contact> conList = TestDataFactory.getContacts(1,'Karthik','Sai',accList[0].Id,true);
        List<Opportunity> oppList = TestDataFactory.generateOppsForAccount(accList[0].Id,10,1,true);
        List<Pricebook2> priceList = TestDataFactory.getPricebooks();
        SBQQ__Quote__c quoteList = TestDataFactory.getQuotes(oppList[0].Id,accList[0].Id,conList[0].Id,priceList[0].Id);
        List<SBQQ__QuoteLineGroup__c> quoteGroupList = TestDataFactory.getQuoteLine(quoteList.Id);
        List<Product2> prodList = TestDataFactory.getProducts('BS 10012 - Additional Company - Certification','Consultancy - Contract');
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineList = TestDataFactory.getQuoteLines(quoteList.Id,prodList[0].Id,quoteGroupList[0].Id);
        Test.stopTest();
    }

    public static testMethod void executeData(){
        Test.startTest();
        for(SBQQ__QuoteLine__c sbqq:[SELECT Id,Sum_of_Children_Price_Per_Billing__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Sum_of_Children_Price_Per_Billing__c FROM SBQQ__QuoteLine__c]){
            if(sbqq.SBQQ__RequiredBy__c==null){
            	System.assertEquals(300,sbqq.Sum_of_Children_Price_Per_Billing__c);
            }
        }
        Test.stopTest();
    }
	
}