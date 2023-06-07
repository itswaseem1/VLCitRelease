@isTest
public class TestQmsContractHandler {
    
    @isTest static void testsynchronise(){      
        List<Opportunity> oppList = NEW List<Opportunity>();
        list<id> idList=new list<id>(); 
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 productDetails = new Product2();
        productDetails.Name = 'On-Site H&S Site Inspections - Bi-Annually';
        productDetails.ProductCode = 'HS-INSP-Bi-annual';
        productDetails.Online_System_Feature_Enabling__c=true;
        productDetails.Online_System__c='Atlas';        
        insert productDetails;
        
        PricebookEntry priceBookEntryDetails = new PricebookEntry();
        priceBookEntryDetails.Pricebook2Id = pricebookId;
        priceBookEntryDetails.Product2Id = productDetails.Id;
        priceBookEntryDetails.UnitPrice = 15;
        priceBookEntryDetails.IsActive = true;        
        insert priceBookEntryDetails;
        
        Account acc=new Account();
        acc.Name='test';
        acc.Sites__c=1;
        acc.FT_Employees__c=1;
        acc.PT_Employees__c=1;
        insert acc;
        
        Contact cc=new Contact();
        cc.LastName='tes contact';
        cc.AccountId=acc.Id;
        insert cc;        
        
        Opportunity opp=new Opportunity();
        opp.AccountId= acc.Id;
        opp.Name='opp name';
        opp.Amount=100;
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Contact__c=cc.Id;
        insert opp;
        
        OpportunityLineItem item1=new OpportunityLineItem();
        item1.OpportunityId=opp.Id;
        item1.Product2Id=productDetails.id;
        item1.PricebookEntryId=priceBookEntryDetails.Id;
        item1.Quantity=1;         
        item1.TotalPrice=priceBookEntryDetails.UnitPrice;      
        insert item1;
        
        Contract cont=new contract();
        cont.AccountId=acc.id;
        cont.Source_Opportunity__c=opp.id;
        cont.ContractTerm=12;
        cont.CustomerSignedId=cc.id;
        cont.Pricebook2Id='01sD0000000tHqv';
        cont.FOC_Period_Mths__c=0;
        cont.FOC_Period_Mths_End__c=0;
        cont.CurrencyIsoCode='GBP';  
        Cont.Status='Draft';
        Cont.StartDate=System.today();
        cont.Initial_Payment2__c=10;
        cont.Agreement_Type__c='EchoSign';
        cont.Agreement_Template_Type__c='Add-On';       
        insert cont;
        
        idList.add(opp.Id);
        
        test.startTest();
        QmsContractHandler.QmsContractCheck(idList);
        test.stopTest();        
    }
}