@isTest
public class Test_sf_QuoteHandler {
    public static testMethod void sampleData(){
        
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        List<SBQQ__Quote__c> newList = new List<SBQQ__Quote__c>();
        sf_QuoteHandler sfq = new sf_QuoteHandler();
        
        Account acc = new Account();
            acc.Name = 'ValueLabs LLP';
            acc.FT_Employees__c = 10;
            acc.PT_Employees__c = 5;
            acc.Directors__c = 4;
            acc.Subcontractors__c = 3;
            acc.Sites__c = 10;
            acc.CitationSector__c = 'CARE';
            acc.Sector__c = 'CARE';
            insert acc;
            Account accValues = [SELECT Id FROM Account WHERE Id=:acc.Id];
        
        Contact cont = new Contact();
            cont.FirstName = 'Sai';
            cont.LastName = 'Karthik';
            cont.AccountId = accValues.Id;
            insert cont;
            Contact contactValues = [SELECT Id FROM Contact WHERE Id=:cont.Id];
        
        Opportunity opp = new Opportunity();
            opp.Name = 'ValueLabs Oppo';
            opp.AccountId = accValues.Id;
            opp.CloseDate = Date.newInstance(2019, 05, 10);
            opp.StageName = 'Appointment';
            opp.Type = 'New Business';
            opp.Event_Outcome__c = 'Not attended yet';
            insert opp;
            Opportunity oppoVal = [SELECT Id FROM Opportunity WHERE Id=:opp.Id];
        
        Pricebook2 price = new Pricebook2();
            price.Name = '£0 - £75,000 (CPQ)';
            price.IsActive = true;
            insert price;
            Pricebook2 priceVal = [SELECT Id FROM Pricebook2 WHERE Id=:price.Id];
        
        SBQQ__Quote__c cpqQuote1 = new SBQQ__Quote__c();
            cpqQuote1.SBQQ__Primary__c = true;
            cpqQuote1.SBQQ__StartDate__c = Date.today().addMonths(5);
            cpqQuote1.SBQQ__Status__c = 'Draft';
            cpqQuote1.SBQQ__Account__c = accValues.Id;
            cpqQuote1.SBQQ__Opportunity2__c = oppoVal.Id;
            cpqQuote1.SBQQ__PrimaryContact__c = contactValues.Id;
            cpqQuote1.Preferred_Payment_Date__c = '7';
            cpqQuote1.SBQQ__PriceBook__c = priceVal.Id;
            cpqQuote1.Initial_Payment_Date__c = Date.newInstance(2018, 06, 07);
            test.startTest();
            insert cpqQuote1;
            
            system.assert(cpqQuote1.Id != null);
             oldMap.put(cpqQuote1.Id,cpqQuote1);
            SBQQ__Quote__c cpqQuoteVal = [SELECT Id FROM SBQQ__Quote__c WHERE Id=:cpqQuote1.Id];

           
        SBQQ__QuoteLineGroup__c groupName1 = new SBQQ__QuoteLineGroup__c();
            groupName1.Name = 'Option 1';
            groupName1.SBQQ__Quote__c = cpqQuoteVal.Id;
            insert groupName1;
            SBQQ__QuoteLineGroup__c groupVal1 = [SELECT Id,SBQQ__Quote__c,Name FROM SBQQ__QuoteLineGroup__c WHERE Id=:groupName1.Id];

        Product2 pro1 = new Product2();
            pro1.Name = 'Additional Law Posters';
            pro1.ProductCode = 'ADD';
            pro1.Family = 'Care';
            insert pro1;
            Product2 proVal1 = [SELECT Id,ProductCode,Name FROM Product2 WHERE Id=:pro1.Id];

        /*SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
            quoteLine1.SBQQ__Product__c = proVal1.Id;
            quoteLine1.SBQQ__Quote__c = cpqQuote1.Id;
            quoteLine1.SBQQ__Quantity__c = 2;
            quoteLine1.FOC_Period__c = 'Start';
            quoteLine1.SBQQ__StartDate__c = Date.newInstance(2020, 03, 10);
            quoteLine1.Service_Start_Date__c = Date.today();
            quoteLine1.SBQQ__Group__c = groupVal1.Id;
            quoteLine1.Billing_Frequency__c = 'Monthly';
            quoteLine1.SBQQ__BillingFrequency__c = 'Monthly';
            insert quoteLine1;
            system.assert(quoteLine1.Id != null);
            SBQQ__QuoteLine__c q1 = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id=:quoteLine1.Id];*/

            SBQQ__Quote__c cpqQuoteVal1 = [SELECT Id,SBQQ__StartDate__c,Preferred_Payment_Date__c FROM SBQQ__Quote__c WHERE Id=:cpqQuote1.Id];
        
            cpqQuote1.SBQQ__StartDate__c = Date.today().addMonths(3);
            cpqQuote1.Preferred_Payment_Date__c = '14';
            update cpqQuote1;
            newList.add(cpqQuote1);
        
            
            sfq.callQTLMethodForSTdate(newList,oldMap);
            test.stopTest();

    }
}