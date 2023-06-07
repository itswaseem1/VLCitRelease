@isTest
public class iHASCO_PrimaryContactController_Test 
{
    @testSetup
    static void setUp()
    {
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'iHASCO_PrimaryContactController_Test' ;
        
        insert iHASCOUser;
        
        system.runAs(iHASCOUser)
        {
            
            Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
            Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
            Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
            
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
            
            Product2 p = new Product2();
            p.Name = 'Test Product';
            p.IsActive = True;
            p.SBQQ__SubscriptionType__c = 'Renewable';
            P.SBQQ__BillingFrequency__c ='Annual';
            insert p;
            
            Pricebook2 pb = new Pricebook2();
            pb.Name = DataConstants.Quote_iHASCO_PRICEBOOKNAME;
            pb.IsActive = True;
            insert pb;
            
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
            quote.License_Model__c = 'Open License';
            insert quote;
            
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = p.Id;
            ql.SBQQ__Quantity__c = 1;
            ql.Custom_Discount_Percentage__c = 10;
            ql.SBQQ__Quote__c = quote.Id;
            ql.SBQQ__StartDate__c = Date.today();
            ql.SBQQ__EndDate__c = Date.today().addYears(5);
            ql.Service_Start_Date__c = Date.today();
            
            ql.Billing_Frequency__c = 'Annual';
            ql.SBQQ__BillingFrequency__c = 'Annual';
            ql.SBQQ__NetPrice__c = 600;
            ql.SBQQ__SubscriptionTerm__c = 60;
            ql.FOC_Period__c = 'Start';
            insert ql;
        }        
    }
    
    @isTest
    public static void updateiHascoRecordTypeTest()
    {
        User iHASCOUser1 =[select id from USER where Division='iHASCO' and isactive = true and LastName = 'iHASCO_PrimaryContactController_Test' LIMIT 1];
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        
        system.runAs(iHASCOUser1)
        {
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today();
            con.ContractTerm = 24;
            con.AccountId =[Select id from account limit 1].Id;
            con.Source_Opportunity__c = [Select id from Opportunity limit 1].id;
            con.SBQQ__Opportunity__c =[Select id from Opportunity limit 1].id;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.Agreement_Type__c = 'Auto';
            Test.startTest();
            insert con;
            
            con.status = 'Active';
            update Con;
            Test.stopTest();
            OpportunityContactRole oCR= new OpportunityContactRole();
            contact cont= [SELECT Id,Name   FROM Contact Limit 1];
            oCR.ContactId =cont.id;
            oCR.OpportunityId = Con.Source_Opportunity__c;
            oCR.IsPrimary = TRUE;
            INSERT oCR;
            
            List<contact> contacts=iHASCO_PrimaryContactController.getPrimaryContact(con.AccountId);
            System.assertEquals(cont.name,contacts[0].Name);                        
        }
    }
}