@isTest
public class ContractRenewalForecastSchedulableTest {
    
    
    @testSetup static void dataSetup() {
        
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractRenewalForecastSchedulableTest';
        insert iHASCOUser;
        
        system.runAs(iHASCOUser){
            Account acc = new Account();
            acc.Name = 'Test Acc';
            acc.BillingStreet = 'Harvey street';
            acc.BillingCity = 'Manchester';
            acc.BillingCountry = 'England';
            acc.BillingPostalCode = 'NXJ001';
            acc.Sites__c = 5.0;
            acc.FT_Employees__c = 20.0;
            acc.PT_Employees__c = 10.0;
            insert acc;
            
            Pricebook2 pb = new Pricebook2();
            pb.Name = DataConstants.Quote_iHASCO_PRICEBOOKNAME;
            pb.IsActive = True;
            insert pb;
            
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact';
            c.AccountId = acc.Id;
            c.Phone = '01912553955';
            c.MobilePhone = '70875327792';
            c.Email = 'testcontact@email.com';
            insert c;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.id;
            opp.Deposit_Payment_Method__c = 'Direct Debit';
            opp.RecordTypeId = oppRecordType;
            opp.CloseDate = Date.newInstance(2021, 09, 30);
            opp.StageName = 'In Progress';
            insert opp;
            
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = quoteRecordType;
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__StartDate__c = Date.today();
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__PrimaryContact__c = c.Id;
            quote.Preferred_Payment_Date__c = '7';
            quote.Initial_Payment__c = 200;
            quote.Initial_Payment_Date__c = Date.today();
            quote.SBQQ__SubscriptionTerm__c = 24;
            insert quote;
            
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate = Date.newInstance(2021, 10, 1);
            con.SBQQ__Quote__c = quote.Id;
            con.AccountId = acc.Id;
            con.Source_Opportunity__c = opp.Id;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            Con.CustomerSignedId = c.id;
            con.FOC_Period_Mths__c =1 ;
            con.FOC_Period_Mths_End__c = 3;
            con.StartDate = system.today().addDays(2);
            con.SBQQ__RenewalForecast__c = false;
            con.ContractTerm = 3;
            
            insert con;
            
            contract con2 = new contract();
            con2.Name = 'Test con2tract';
            con2.RecordTypeId = contractRecordType;
            con2.StartDate = Date.newInstance(2021, 10, 1);
            con2.SBQQ__Quote__c = quote.Id;
            con2.AccountId = acc.Id;
            con2.Source_Opportunity__c = opp.Id;
            con2.Status = 'Draft';
            con2.Renewal_Type__c = 'Non-Auto';
            con2.Initial_Payment2__c = 200;
            con2.CustomerSignedId = c.id;
            con2.FOC_Period_Mths__c =1 ;
            con2.FOC_Period_Mths_End__c = 3;
            con2.StartDate = system.today().addDays(-90);
            con2.SBQQ__RenewalForecast__c = false;
            con2.contractTerm = 3;
            
            insert con2;
        }
        
    } 
    
    
    @isTest static void testExecute() {
        User iHASCOUser1 =[SELECT id from USER WHERE Division='iHASCO' AND LastName = 'ContractRenewalForecastSchedulableTest' LIMIT 1];
        
        system.runAs(iHASCOUser1){
            Test.startTest();
            
            ContractRenewalForecastSchedulable sh1 = new ContractRenewalForecastSchedulable();
            
            String sch = '0 0 12 * * ?'; 
            system.schedule('Test Renewal Check', sch, sh1); 
            Test.stopTest(); 
        }
        system.assert([SELECT Id FROM AsyncApexJob ].size()> 0);
        System.assertNotEquals(0, Database.countQuery('SELECT Count() FROM SBQQ__Quote__c')); 
        System.assertNotEquals(0, Database.countQuery('SELECT Count() FROM Opportunity')); 
    }
    
}