@IsTest
Public class iHASCO_PurgatorySchedule_Test {
    public  static Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    public  static Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
    public static  Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    @TestSetup
    public  static void createTestData(){
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName ='iHASCO_PurgatorySchedule_Test';
        iHASCOUser.IsActive = True;
        insert iHASCOUser;
        system.runAs(iHASCOUser){
            
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'iHASCO';
            pb.IsActive = True;
            insert pb;
            Account a = new Account(RecordTypeId= '012D0000000KKTtIAO',
                                    Name = 'PurgatoryStatus',
                                    BillingStreet = 'Harvey street',
                                    BillingCity = 'Manchester',
                                    BillingCountry = 'England',
                                    BillingPostalCode = 'NXJ001',
                                    iHASCO_Client__c=True,
                                    iHASCO_Finance_Status__c='Active',
                                    iHASCO_Status_Reason__c =Null,
                                    iHASCO_Account_Manager__c=iHASCOUser.id);
            insert a;
            Site__c acs = new Site__c();
            acs.Account__c = a.id;
            acs.City__c = 'test';
            acs.Name = 'test';
            insert acs;
            Contact c = new Contact(LastName = 'Testihasco',
                                    AccountId=a.id);
            
            insert c;
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = a.id;
            opp.Deposit_Payment_Method__c = 'Direct Debit';
            opp.RecordTypeId = oppRecordType;
            opp.CloseDate = Date.newInstance(2021, 09, 30);
            opp.StageName = 'In Progress';
            opp.Pricebook2Id = pb.id;
            opp.Type = 'New Business';
            insert opp;
            
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = quoteRecordType;
            quote.SBQQ__Primary__c = true;
            quote.Payment_Method__c = 'Invoice';
            quote.iHASCO_Payment_Terms__c = '30 Days';
            quote.SBQQ__StartDate__c = Date.today();
            quote.SBQQ__PrimaryContact__c = c.id;
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Account__c = a.Id;
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__PrimaryContact__c = c.Id;
            quote.Preferred_Payment_Date__c = '7';
            quote.Initial_Payment__c = 200;
            quote.SBQQ__PriceBook__c = pb.Id;
            quote.Initial_Payment_Date__c = Date.today();
            quote.SBQQ__SubscriptionTerm__c = 24;
            quote.License_Model__c = 'User Based';
            quote.PO_reference__c = '1234';
            insert quote;
            
            Contract Con =new Contract(RecordTypeId = contractRecordType,
                                       CurrencyIsoCode ='GBP',
                                       Status='Draft',
                                       Name='TestConExpired',
                                       AccountId=a.id,
                                       SBQQ__Quote__c=quote.id,
                                       ContractTerm=12,
                                       CustomerSignedId =c.id,
                                       StartDate =system.today().addMonths(-12)
                                      );            
            insert con;
        }
    }
    
    
    public testmethod static void testScheduleClass(){
        Test.startTest();
        
        iHASCO_PurgatorySchedule sh = new iHASCO_PurgatorySchedule();
        String sch = '0 0 12 * * ?'; 
        
        system.schedule('Test Purgatory Check', sch, sh); 
        Test.stopTest();
        system.assert([SELECT Id FROM AsyncApexJob ].size()> 0);
        
    } 
    public testmethod static void testBulkifyScheduleClass(){
        Test.startTest();
        
        TestDataFactory.getAccounts(5,'PurgatoryStatusAccount',true);//Inserting multiple accounts
        iHASCO_PurgatorySchedule sh = new iHASCO_PurgatorySchedule();
        String sch = '0 0 12 * * ?'; 
        system.schedule('Test Purgatory Check', sch, sh); 
        
        Test.stopTest();
        system.assert([SELECT Id FROM AsyncApexJob ].size()> 0);
        
    }     
    public testmethod static void testNoniHASCOAccount(){
        Test.startTest();
        
        Account acc = [SELECT ID,Name,Contract_End_Date__c,iHASCO_Client__c,iHASCO_Finance_Status__c,iHASCO_Status_Reason__c,Purgatory_Status__c from Account  LIMIT 1];
        acc.iHASCO_Client__c=False;
        update acc;
        
        iHASCO_PurgatorySchedule sh = new iHASCO_PurgatorySchedule();
        String sch = '0 0 12 * * ?'; 
        system.schedule('Test Purgatory Check', sch, sh);
        Test.stopTest();
        
        Account updatedAcc =[SELECT ID,Purgatory_Status__c FROM Account LIMIT 1];
        System.AssertNotEquals(updatedAcc.Purgatory_Status__c,'Purgatory');   
    }
}