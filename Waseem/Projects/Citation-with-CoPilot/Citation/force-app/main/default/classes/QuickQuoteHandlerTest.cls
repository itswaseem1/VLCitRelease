@isTest
public class QuickQuoteHandlerTest {
    
    @isTest public static void iHascoQuoteTest(){
        //Opportunity op=[SELECT ID,RecordTypeId FROM Opportunity LIMIT 1];
         Account a = new Account();
        a.Name = 'iHASCO Limited';
        insert a;
        Opportunity oppo = new Opportunity();
        oppo.Name = 'iHASCO Opportunity';
        oppo.AccountId = a.Id;
        oppo.StageName = 'Proposal/Price Quote';
        oppo.CloseDate = Date.today().addMonths(30);
        
        oppo.RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
       insert oppo;
         QuickQuoteHandler.send(oppo.Id);
    }
    
    @isTest public static void qmsQuoteTest(){
        //Opportunity op=[SELECT ID,RecordTypeId FROM Opportunity LIMIT 1];
        Account a = new Account();
        a.Name = 'QMS Limited';
        insert a;
        
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        pricebook.Name = 'QMS CPQ';
        pricebook.IsActive = true;
        insert pricebook;
        
        Opportunity oppo = new Opportunity();
        oppo.Name = 'QMS Opportunity';
        oppo.AccountId = a.Id;
        oppo.StageName = 'Proposal/Price Quote';
        oppo.CloseDate = Date.today().addMonths(30);
        oppo.RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS').getRecordTypeId();
        oppo.Term__c = '3';
        insert oppo;
        
        QuickQuoteHandler.send(oppo.Id);
    }
}