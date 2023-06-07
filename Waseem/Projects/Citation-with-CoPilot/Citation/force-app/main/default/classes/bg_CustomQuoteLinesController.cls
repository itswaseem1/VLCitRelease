public with sharing class bg_CustomQuoteLinesController {
    
    public List<QuoteLineGroup> quoteGroups {get;set;}
    
    public List<SBQQ__QuoteLineGroup__c> quoteLineGroups {get;set;}
    
    
    public bg_CustomQuoteLinesController() {
        Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        quoteLineGroups = [SELECT Name, SBQQ__ListTotal__c, SBQQ__NetTotal__c, (SELECT SBQQ__ProductName__c,  SBQQ__Quantity__c, Price_per_Billing_Frequency__c, Term__c FROM SBQQ__LineItems__r ORDER BY SBQQ__Number__c) FROM SBQQ__QuoteLineGroup__c Where SBQQ__Quote__c = :quoteId];

    }
    
    public class QuoteLineGroup
    {
        public String groupName {get;set;}
        
        public QuoteLineGroup()
        {
            
        }
    }
}