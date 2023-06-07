@isTest
private class TriggerAgreementHandlerTest{
    
    @TestSetup
    static void makeData(){

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
      
        recordtype rt = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' ] ;
        Id contractRecordType = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Standard_Contract').getRecordTypeId();
    
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = 'PROFESSIONAL ACTIVITIES';
        acc.FT_Employees__c = 6;
        acc.PT_Employees__c = 1;
        acc.Subcontractors__c = 0;
        acc.Directors__c = 4;
        acc.Sites__c = 2;
        acc.Payroll_Amt__c = 1000;
        insert acc;

        bg_Unit_Test_Helper.createEchosignCustomSettings();
         
        opportunity opp = new opportunity(name = 'test',stagename = 'Appointment',closedate = date.today(), accountid = acc.id) ;
        insert opp ;

        contract c = new contract(
            accountid=acc.id, 
            startdate = date.today() , 
            Agreement_Type__c = 'EchoSign', 
            RecordTypeId = contractRecordType, 
            FOC_Period_Mths__c = 2,
            FOC_Period_Mths_End__c=0,
            Agreement_Template_Type__c = 'Combined', 
            CustomerSignedId = bg_Unit_Test_Helper.createContact('CAT1','User1', opp.AccountId).Id,
            Initial_Payment2__c = 1000,
            Source_Opportunity__c = opp.Id
            
        ) ;
        insert c ;

        sbqq__quote__c q = new sbqq__quote__c(sbqq__account__c = acc.id,SBQQ__Opportunity2__c = opp.id, contract__c = c.id, recordtypeid = rt.id,SBQQ__QuoteTemplateId__c=null ) ;
        insert q ;
        
    }
    
    @isTest static void updateContractHasAgreementFieldTest() {
        // create agreement

        Contract contract = [select Id, Account.Id, Status, HasAgreement__c from Contract limit 1];
        Opportunity Opp1 = [select Id, AccountId, OwnerId, RecordTypeId, Name, Type, Core_Compliance_TCV__c, Payment_Period__c, Contract_Length_Mths__c, Deal_Start_Date__c from Opportunity limit 1];

        Test.startTest();
        System.assertEquals(false, contract.HasAgreement__c);
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.Name = 'TEst';
        agreement.echosign_dev1__Account__c = Opp1.AccountId;
        agreement.echosign_dev1__Contract__c = contract.Id;

        insert agreement;

        Test.stopTest();

        System.assertEquals(true, [select Id, Account.Id, Status, HasAgreement__c from Contract limit 1].HasAgreement__c);
    }

    @isTest static void updateContractHasAgreementFieldDeleteTest() {
        // create agreement
        
        Contract contract = [select Id, Account.Id, Status, HasAgreement__c from Contract limit 1];
        Opportunity Opp1 = [select Id, AccountId, OwnerId, RecordTypeId, Name, Type, Core_Compliance_TCV__c, Payment_Period__c, Contract_Length_Mths__c, Deal_Start_Date__c from Opportunity limit 1];

        System.assertEquals(false, contract.HasAgreement__c);
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.Name = 'TEst';
        agreement.echosign_dev1__Account__c = Opp1.AccountId;
        agreement.echosign_dev1__Contract__c = contract.Id;

        insert agreement;

        //System.assertEquals(true, [select Id, Account.Id, Status, HasAgreement__c from Contract limit 1].HasAgreement__c);
        Test.startTest();
        
        delete agreement;
        
        System.assertEquals(true, [select Id, IsDeleted from echosign_dev1__SIGN_Agreement__c where Id =: agreement.Id ALL ROWS].IsDeleted);
        System.assertEquals(false, [select Id, Account.Id, Status, HasAgreement__c from Contract ALL ROWS].HasAgreement__c);
        Test.stopTest();

    }
    
}