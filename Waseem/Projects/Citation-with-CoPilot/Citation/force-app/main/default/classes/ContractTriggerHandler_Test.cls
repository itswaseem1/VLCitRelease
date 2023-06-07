@isTest
public class ContractTriggerHandler_Test {
    @testSetup
    static void setUp(){
        
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
        
        
        Date maxTerm= [Select SBQQ__EndDate__c from SBQQ__QuoteLine__c where Id = :ql.Id].SBQQ__EndDate__c;
        System.debug(maxTerm);                
    }
    
    @isTest    public static void updateiHascoRecordTypeTest(){
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractTriggerHandler_Test';
        insert iHASCOUser;
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        system.runAs(iHASCOUser){
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
            
            Test.stopTest();
            
            ContractTriggerHandler contHand = new ContractTriggerHandler();
            contHand.updateiHascoRecordType([Select id,recordTypeID,SBQQ__Opportunity__c from Contract]);
            Contract updatedContr =[Select id,SBQQ__RenewalOpportunityStage__c,SBQQ__RenewalPricebookId__c,RecordtypeId from Contract WHERE id =: con.id];
            
            system.assertEquals('Genuine interest', updatedContr.SBQQ__RenewalOpportunityStage__c);
            system.assertEquals([Select id From  PriceBook2 where Name=:DataConstants.Quote_iHASCO_PRICEBOOKNAME].id, updatedContr.SBQQ__RenewalPricebookId__c);
            system.assertEquals(contractRecordType, updatedContr.RecordtypeId);
        }
    }
    @isTest    public static void validateContractActivation_Lessthan10KTest(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractTriggerHandler_Test';
        insert iHASCOUser;
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Contract con = new Contract();
        system.runAs(iHASCOUser){
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
            con.Annual_Contract_Value__c = 2000;
            con.Agreement_Type__c = 'Auto';
            Test.startTest();
            insert con;
        }
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.Name = 'Test';
        agreement.echosign_dev1__Account__c = con.AccountId;
        agreement.echosign_dev1__Contract__c = con.id;
        
        insert agreement;
        
        con.Status ='Active';
        Database.SaveResult result = Database.UPDATE(con,false);
        System.assertEquals(0, result.getErrors().size());
        Test.stopTest();
    }  
    @isTest    public static void validateContractActivation_Greaterthan10KTest(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractTriggerHandler_Test';
        insert iHASCOUser;
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Contract con = new Contract();
        system.runAs(iHASCOUser){
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
            con.Annual_Contract_Value__c = 20000;
            con.Agreement_Type__c = 'Auto';
            Test.startTest();
            insert con;
            
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            agreement.Name = 'Test';
            agreement.echosign_dev1__Account__c = con.AccountId;
            agreement.echosign_dev1__Contract__c = con.id;
            insert agreement;
            
            con.Status ='Active';
            Database.SaveResult result = Database.UPDATE(con,false);
            System.assertEquals(Label.iHASCO_ACV_10K_Error, result.getErrors()[0].getMessage());
        }
        Test.stopTest();
    }  
    @isTest    public static void validateContractActivation_Greaterthan10KSignedTest(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractTriggerHandler_Test';
        insert iHASCOUser;
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Contract con = new Contract();
        system.runAs(iHASCOUser){
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
            con.Annual_Contract_Value__c = 20000;
            con.Agreement_Type__c = 'Auto';
            Test.startTest();
            insert con;
            
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            agreement.Name = 'Test';
            agreement.echosign_dev1__Account__c = con.AccountId;
            agreement.echosign_dev1__Contract__c = con.id;
            agreement.echosign_dev1__DateSigned__c = System.today();
            insert agreement;
            
            //Test.startTest();
            con.Status ='Active';
            Database.SaveResult result = Database.UPDATE(con,false);
            System.assertEquals(0, result.getErrors().size());
        }
        Test.stopTest();
    }  
    @isTest    public static void validateContractActivation_Greaterthan10KSplAcessTest(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractTriggerHandler_Test';
        insert iHASCOUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'iHASCO_Contract_Activate_Special_Access'];
        insert new PermissionSetAssignment(AssigneeId = iHASCOUser.id, PermissionSetId = ps.Id);
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Contract con = new Contract();
        system.runAs(iHASCOUser){
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
            con.Annual_Contract_Value__c = 20000;
            con.Agreement_Type__c = 'Auto';
            Test.startTest();
            insert con;
            
            con.Status ='Active';
            Database.SaveResult result = Database.UPDATE(con,false);
            System.assertEquals(0, result.getErrors().size());
        }
        
        Test.stopTest();
    } 
    @isTest    public static void validateContractActivation_Greaterthan10KWithOutAdobeTest(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'ContractTriggerHandler_Test';
        insert iHASCOUser;
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        Contract con = new Contract();
        system.runAs(iHASCOUser){
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
            con.Annual_Contract_Value__c = 10000;
            con.Agreement_Type__c = 'Auto';
            Test.startTest();
            insert con;
            
            con.Status ='Active';
            Database.SaveResult result = Database.UPDATE(con,false);
            System.assertEquals(Label.iHASCO_ACV_10K_Error, result.getErrors()[0].getMessage());
        }
        Test.stopTest();
    }  
}