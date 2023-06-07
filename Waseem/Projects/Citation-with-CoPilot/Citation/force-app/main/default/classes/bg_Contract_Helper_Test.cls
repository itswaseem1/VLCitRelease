@isTest
public class bg_Contract_Helper_Test{
    
    public static Id citationPartnershipRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();

    public static Id lockedQuoterecordtype = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Quote Locked').getRecordTypeId();
    @testSetup static void setup()
    {
         Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
        Pricebook2 pb = new Pricebook2();
        pb.Name = DataConstants.Quote_iHASCO_PRICEBOOKNAME;
        pb.IsActive = True;
        insert pb;
      
      
    //      lockedQuoterecordtype = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' lIMIT 1] ; 
      
        
        Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
        contact con = TestDataFactory.getContacts(1, 'firstName', 'lastName', testAccount.id, false)[0];
        con.phone = '123456789';
        con.email = 'test@test.com';
        insert con;
        
         
        contract c = new contract(accountid=testAccount.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=2, startdate = date.today() , Agreement_Type__c = 'Auto') ;
        insert c ;
        
        Pricebook2 price = new Pricebook2();
        price.Name = 'QMS CPQ';
        price.IsActive = true;
        insert price;
        
        List<Opportunity> oppList = new List<Opportunity>();
        opportunity opp1 = new opportunity(name = 'test',stagename = 'Appointment',closedate = date.today(), accountid = testAccount.id) ;
        opp1.Amount = 1000;
        opp1.Core_Compliance_TCV__c  = 1234;
        opp1.Type='Add-On';
        oppList.add(opp1);
        opportunity opp2 = new opportunity(name = 'test2',stagename = 'Appointment',closedate = date.today(), accountid = testAccount.id) ;
        opp2.Amount = 1000;
        opp2.Core_Compliance_TCV__c  = 1234;
        opp2.Type='Add-On';
        oppList.add(opp2);
        insert oppList ;
        
        List<sbqq__quote__c> qtList = new List<sbqq__quote__c>();
        sbqq__quote__c q1 = new sbqq__quote__c(sbqq__account__c = testAccount.id,SBQQ__Opportunity2__c = opp1.id, recordtypeid = lockedQuoterecordtype,SBQQ__QuoteTemplateId__c=null, SBQQ__PrimaryContact__c = con.id) ;
        q1.Initial_Payment__c = 1000;
        q1.Initial_Payment_Date__c = date.today().addDays(2);
        q1.SBQQ__BillingFrequency__c = 'Monthly';
        q1.Preferred_Payment_Date__c = '7';
        q1.Second_Signatory_Required__c = 'No';
        qtList.add(q1);
        sbqq__quote__c q2 = new sbqq__quote__c(sbqq__account__c = testAccount.id,SBQQ__Opportunity2__c = opp2.id, recordtypeid = lockedQuoterecordtype,SBQQ__QuoteTemplateId__c=null, SBQQ__PrimaryContact__c = con.id) ;
        q2.Initial_Payment__c = 1000;
        q2.Initial_Payment_Date__c = date.today().addDays(2);
        q2.SBQQ__BillingFrequency__c = 'Monthly';
        q2.Preferred_Payment_Date__c = '7';
        q2.Second_Signatory_Required__c = 'No';
        q2.SBQQ__PrimaryContact__c = con.id;
        qtList.add(q2); 
        insert qtList ;
                
        List<contract> ctrList = new List<contract>();
        contract c1 = new contract(accountid=testaccount.id, startdate = date.today() , Agreement_Type__c = 'Auto', CustomerSignedId = con.id) ;
        c1.ContractTerm = 24;
        c1.FOC_Period_Mths__c =2;
        c1.FOC_Period_Mths_End__c = 12;
        c1.Name = 'test';
        c1.Service_Type__c = 'Citation';
        c1.Status = 'Draft';
        c1.Business_Type__c = 'New Business';
        c1.Payment_Period__c = 'Monthly';
        c1.Preferred_Payment_Date__c ='7';
        c1.Core_Compliance_TCV__c = 1000;
        c1.SBQQ__Opportunity__c = opp1.ID;
        c1.StartDate = system.today().addMonths(-12);
        c1.ContractTerm = 12;
        c1.FOC_Period_Mths__c = 1;
        c1.FOC_Period_Mths_End__c = 1;
        ctrList.add(c1);
      
        contract c2 = new contract(accountid=testaccount.id, startdate = date.today() ,SBQQ__Quote__c=q2.id, Agreement_Type__c = 'Auto', CustomerSignedId = con.id) ;
        c2.ContractTerm = 24;
        c2.FOC_Period_Mths__c =2;
        c2.FOC_Period_Mths_End__c = 12;
        c2.Name = 'test';
        c2.Service_Type__c = 'Citation';
        c2.Status = 'Draft';
        c2.Business_Type__c = 'New Business';
        c2.Payment_Period__c = 'Monthly';
        c2.Preferred_Payment_Date__c ='7';
        c2.Core_Compliance_TCV__c = 1000;
        c2.SBQQ__Opportunity__c = opp1.ID;
        c2.StartDate = system.today().addMonths(-12);
        c2.ContractTerm = 12;
        c2.FOC_Period_Mths__c = 1;
        c2.FOC_Period_Mths_End__c = 1;
        ctrList.add(c2);
        

        List<SBQQ__Subscription__c> listSub = new List<SBQQ__Subscription__c>();

      Test.startTest();   
        insert ctrList ;
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q1.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        Product2 employementLawProduct = bg_Product_TestUtils.createProduct(Bg_Constants.PRODUCT_EMPLOYMENT_LAW, 'Consultation', 'Premium');
        EmployementLawPRoduct.SBQQ__BillingFrequency__c = 'One-Off' ;
        EmployementLawPRoduct.ProductCode = 'CB1';
        insert EmployementLawPRoduct;
        
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(foc_months__c=2,sbqq__quote__c = q1.id, sbqq__group__c = qg.id, sbqq__product__C = EmployementLawPRoduct.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0,Initial_Payment__c = 120);
        insert ql ;
        
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(SBQQ__Contract__c=ctrList[0].id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='One-Off',Subscription_Term_m__c=12) ;
//      listSub.add(subs);
        
        SBQQ__Subscription__c subs1 = new SBQQ__Subscription__c(SBQQ__Contract__c=ctrList[1].id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='Monthly',Subscription_Term_m__c=12) ;
        listSub.add(subs1);
        
        SBQQ__Subscription__c subs2 = new SBQQ__Subscription__c(SBQQ__Contract__c=ctrList[1].id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='Monthly',Subscription_Term_m__c=12) ;
        listSub.add(subs2);
        
        SBQQ__Subscription__c subs3 = new SBQQ__Subscription__c(SBQQ__Contract__c=ctrList[1].id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='Annual',Subscription_Term_m__c=12,Initial_Payment_m__c = 120) ;
//        listSub.add(subs3);
        
        SBQQ__Subscription__c subs4 = new SBQQ__Subscription__c(SBQQ__Contract__c=ctrList[1].id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='Annual',Subscription_Term_m__c=12,Initial_Payment_m__c = 120) ;
//        listSub.add(subs4);
        
        SBQQ__Subscription__c subs5 = new SBQQ__Subscription__c(SBQQ__Contract__c=ctrList[0].id, sbqq__quoteline__c=ql.id, sbqq__quantity__c =1,SBQQ__BillingFrequency__c='One-Off',Subscription_Term_m__c=12) ;
        listSub.add(subs5);
        
        insert listSub;
          Test.stopTest();    
    }
    
    
    
    
    private static Account createAccount(String accName, String sector, Decimal fullTimeEmployees, Decimal partTimeEmployees)
    {
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
      //acc.Number_of_Active_Sites__c = 1;
        acc.Sites__c = 1;
        
        insert acc;
        return acc;     
    }
    
    static testMethod void TestsetContractOnQuote() {
        List<Contract> cList = [select id, sbqq__quote__c,accountid,Number_of_Standard_Sites__c,Number_of_Complex_Sites__c from Contract where SBQQ__Quote__c = NULL LIMIT 1] ;
        recordtype rt = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' ] ;
        List<sbqq__quote__c> q = [Select id from sbqq__quote__c where  recordtypeid = :lockedQuoterecordtype LIMIT 1];
       
        For(Contract c: cList){
           c.SBQQ__Quote__c = q[0].id; 
        }
         Test.Starttest();
        update cList;
         Test.stoptest();
        System.assertEquals(cList[0].Number_of_Standard_Sites__c+cList[0].Number_of_Complex_Sites__c, 0);             
    }
    
     static testMethod void TestsetContractOnQuote2() {
         List<Contract> cList = [select id, sbqq__quote__c,accountid,Number_of_Standard_Sites__c,Number_of_Complex_Sites__c  from Contract WHERE SBQQ__Quote__c != NULL] ;
         recordtype rt = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' ] ;
         Test.Starttest();
         update cList;
         Test.stoptest();
         System.assertEquals(cList[0].Number_of_Standard_Sites__c+cList[0].Number_of_Complex_Sites__c , [SELECT Sites__c from Account where id = :cList[0].accountid].Sites__c);  
    }
    
     static testMethod void TestcheckAccountToUpdateCall() {
         List<Contract> cList = [select id, sbqq__quote__c,accountid, RecordtypeId from Contract WHERE SBQQ__Quote__c != NULL] ;
         Map<id,Contract> cMap = new Map<id, Contract>();
         recordtype rt = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' ] ;
         List<sbqq__quote__c> q = [Select id from sbqq__quote__c where  recordtypeid = :lockedQuoterecordtype and SBQQ__Opportunity2__r.name = 'test'];
         For(Contract c: cList){
             cMap.put(c.id,c);
             c.sbqq__quote__c = q[0].id; 
             c.RecordTypeId = citationPartnershipRecordTypeId;
             c.Status = 'Active';
         }
         
         Test.Starttest();
         update cList;
         
            bg_Contract_Helper.checkAccountToUpdateCall(new Map<id,Contract>(), cMap);
          bg_Contract_Helper.createBillingContracts(cList);
         Test.stoptest();
        
    }
   
   @isTest
    public static void updateCALCCitationContractsTest() {
      Contract cont=[Select id,status,AccountId from Contract  limit 1];
        cont.Status='Active';
        Test.startTest();
        update cont;
        
        
        //System.assertEquals(a.CALC_Citation_Contract__c, 2, 'Count of Citation contracts not updated');
        delete cont;
      Account a=[SELECT CALC_Citation_Contract__c from Account where Id=:cont.AccountId];
        System.assertEquals(a.CALC_Citation_Contract__c, 0, 'Count of Citation contracts not updated');
        undelete cont;
        Test.stopTest();
    }    

    @isTest
    public static void AccountCalContractUpdateTest() {
    Contract cont=[Select id,status,AccountId from Contract  limit 1];
        cont.Status='Expired';
        update cont;
        
        Account a=[SELECT CALC_Citation_Contract__c from Account where Id=:cont.AccountId];
        a.CALC_Citation_Contract__c = 2;
        update a;
      
        Test.startTest();

            AccountCalContractUpdate pretest = new AccountCalContractUpdate();
            Database.executeBatch(pretest,50);
        Test.stopTest();
    }    
    
    
    @isTest
    public static void AccountCalContractUpdateStandardContractTest() {
      Contract cont=[Select id,status,AccountId from Contract  limit 1];
        cont.Status='Active';
        Test.startTest();
        update cont;
        
        Account a=[SELECT CALC_Citation_Contract__c from Account where Id=:cont.AccountId];
        a.CALC_Citation_Contract__c = 2;
        update a;
        String queryStr = 'select id,(select id,status from contracts where status =:acst AND RecordtypeId IN :recordtypeIds),CALC_Citation_Contract__c from account';
        AccountCalContractUpdate pretest = new AccountCalContractUpdate(queryStr);
        Database.executeBatch(pretest,50);
        Test.stopTest();
    }        
   @isTest
    public static void clusterDatesCalculationtest(){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        Account partnerAcc = new Account();
        partnerAcc.Name = 'Citation Account';
        partnerAcc.PT_Employees__c=20;
        partnerAcc.FT_Employees__c=20;
        partnerAcc.Sites__c=5;
        partnerAcc.AccountSource='Partnership';
        partnerAcc.Is_Active_Partner__c=true;
        insert partnerAcc;
        Contact contactRec = new Contact(LastName='Rama',Email='ramadevithota@citation.co.uk',AccountId=partnerAcc.Id);
        insert contactRec;
        Test.startTest();
        //Insert Contract which acts as partner
        Contract conRec = new Contract();
        conRec.Name = 'New Citation Contract';
        conRec.AccountId = partnerAcc.Id;
        conRec.Status = 'Draft';
        conRec.Renewal_Type__c = 'Auto';
        conRec.Business_Type__c = 'New Business';
        conRec.StartDate = System.today();
        conRec.ContractTerm = 24;
        conRec.FOC_Period_Mths__c = 20;
        conRec.FOC_Period_Mths_End__c = 10;
        conRec.Agreement_Template_Type__c='Combined';
        conRec.Service_Type__c = 'Citation';
        conRec.Agreement_Type__c = 'Paper';
        conRec.CustomerSignedId=contactRec.id;
        conRec.RecordTypeId=contractRecordTypeId;
        conRec.Total_Contract_Value__c=1000;
        conRec.Payment_Period__c='monthly';
        conRec.Preferred_Payment_Date__c='14';
        insert conRec;
        //Update Status of contract to Active
        conRec.Status='Active';        
        update conRec; 
        Test.stopTest();
        Contract contractrecord=[Select Id,StartDate,EndDate From Contract where Id=:conRec.Id];
        Account accountUpdated=[Select Id,Cluster_Start_Date__c,Cluster_End_Date__c From Account Where Id=:partnerAcc.Id];
        System.assertEquals(contractrecord.StartDate, accountUpdated.Cluster_Start_Date__c);
        System.assertEquals(contractrecord.EndDate, accountUpdated.Cluster_End_Date__c);        
    }
     @isTest
    public static void contractHistory(){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        List<Contract> conList=new List<Contract>();
        Map<Id,Contract> conMap=new Map<Id,Contract>();
        Account partnerAcc = new Account();
        partnerAcc.Name = 'Citation Account';
        partnerAcc.PT_Employees__c=20;
        partnerAcc.FT_Employees__c=20;
        partnerAcc.Sites__c=5;
        partnerAcc.AccountSource='Partnership';
        partnerAcc.Is_Active_Partner__c=true;
        insert partnerAcc;
        Contact contactRec = new Contact(LastName='Rama',Email='ramadevithota@citation.co.uk',AccountId=partnerAcc.Id);
        insert contactRec;
        Test.startTest();
        Terms_and_Conditions__c terms=new Terms_and_Conditions__c();
        terms.name='termscontions';
        insert terms;
        //Insert Contract which acts as partner
        Contract conRec = new Contract();
        conRec.Name = 'New Citation Contract';
        conRec.AccountId = partnerAcc.Id;
        conRec.Status = 'Draft';
        conRec.Renewal_Type__c = 'Auto';
        conRec.Business_Type__c = 'New Business';
        conRec.StartDate = System.today();
        conRec.ContractTerm = 24;
        conRec.FOC_Period_Mths__c = 20;
        conRec.FOC_Period_Mths_End__c = 10;
        conRec.Agreement_Template_Type__c='Combined';
        conRec.Service_Type__c = 'Citation';
        conRec.Agreement_Type__c = 'Paper';
        conRec.CustomerSignedId=contactRec.id;
        conRec.RecordTypeId=contractRecordTypeId;
        conRec.Total_Contract_Value__c=1000;
        conRec.Payment_Period__c='monthly';
        conRec.Preferred_Payment_Date__c='14';
        conRec.Current_Ts_and_Cs_Effective_Date__c=system.today();
        conRec.Ts_Cs_Version__c=terms.Id;
        insert conRec;
        //Update Status of contract to Active
        conRec.Status='Active';        
        update conRec; 
        conList.add(conRec);
        conMap.put(conRec.Id,conRec);
        Test.stopTest();
        bg_Contract_Helper.createContractHistory(conMap,conList);
    }
    
    @isTest
    public static void testContractRetHistory(){
        List<Contract> conList = [select id from Contract Limit 1];
        bg_Contract_Helper.contractRetHistory(conList[0].id, 'Test', String.valueof(System.today()), String.valueof(System.today()), null, null);        
    }
    
    @isTest
    public static void AtestContractAmendment(){
        List<Contract> conList = [select id, status from Contract where SBQQ__Quote__c!=null AND SBQQ__Quote__r.SBQQ__PrimaryContact__c!=null Limit 1];
        Id iHASCOContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        conList[0].Status = 'In Amendment';
        conList[0].RecordTypeId = iHASCOContractRecordTypeId;
        update conList[0];
        
        User iHASCOUser = new User(Username= 'test.user123@citation.co.uk',LastName =  'test', Alias = 'resetest',TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', email = 'test.user123test@citation.co.uk', Division='iHASCO');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        
        
            Test.startTest();
        System.runAs(iHASCOUser){
            conList[0].Status = 'Active';
            update conList[0];
        }
            Test.stopTest();
        
    }
    
   @isTest
    public static void insertSouthallsOppRecordTest(){
        //Update Status of contract to Active
        List<Contract> contractsforTest=[Select Id,Name,Legacy_Migration_Company__c,Status From Contract where Account.name='TestAccount'];
        Test.startTest();
        contractsforTest[0].Status='Active';  
        contractsforTest[0].Legacy_Migration_Company__c='Southalls';
        contractsforTest[0].StartDate=System.today();
        contractsforTest[0].ContractTerm =12;
        update contractsforTest[0]; 
        Test.stopTest();
        List<Opportunity> oppInserted=[Select Id,Name,Account.Name,ELAS_Opportunity_Pot__c,StageName,Type From Opportunity Where Name = 'TestAccount Southalls Atlas Internal Only Renewal'];
        System.assertEquals(false, oppInserted.isEmpty()); 
        System.assertEquals('TestAccount Southalls Atlas Internal Only Renewal', oppInserted[0].Name);
        System.assertEquals('Atlas Internal Only', oppInserted[0].ELAS_Opportunity_Pot__c);
        System.assertEquals('Renewal Contact Due', oppInserted[0].StageName);
        System.assertEquals('Existing Business', oppInserted[0].Type);
    } 
    @isTest
    public static void noSouthallsOppRecordsContractsScenario(){
        //Update Status of contract to Active
        List<Contract> contractsforTest=[Select Id,Name,Legacy_Migration_Company__c,Status From Contract where Account.name='TestAccount'];
        Test.startTest();
        contractsforTest[0].Status='Active';
        contractsforTest[0].StartDate=System.today();
        contractsforTest[0].ContractTerm =12;
        update contractsforTest[0]; 
        Test.stopTest();
        List<Opportunity> oppInserted=[Select Id,Name,Account.Name,ELAS_Opportunity_Pot__c,StageName,Type From Opportunity Where Name = 'TestAccount Southalls Atlas Internal Only Renewal'];
        System.assertEquals(true, oppInserted.isEmpty());
    } 
}