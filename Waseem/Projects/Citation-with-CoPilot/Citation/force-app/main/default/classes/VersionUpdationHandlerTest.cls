@isTest
public class VersionUpdationHandlerTest {
    @testSetUp
    public static void makeData(){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        Id strdRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
        //Insert Product
        Product2 partProd = new Product2();
        partProd.Name = 'Partner Commission';
        partProd.ProductCode = 'Part-Comm';
        insert partProd;
        //Insert Account records
        List<Account> accountstoInsert=new List<Account>();
        Account partnerAcc = new Account();
        partnerAcc.Name = 'Citation Account';
        partnerAcc.PT_Employees__c=20;
        partnerAcc.FT_Employees__c=20;
        partnerAcc.Sites__c=5;
        partnerAcc.AccountSource='Partnership';
        partnerAcc.Is_Active_Partner__c=true;
        accountstoInsert.add(partnerAcc);
        Account childAcc=new Account();
        childAcc.Name='Child acc';
        childAcc.PT_Employees__c=2;
        childAcc.FT_Employees__c=2;
        childAcc.Sites__c=5;
        childAcc.AccountSource='Partnership';
        childAcc.Type='Client';
        accountstoInsert.add(childAcc);
        insert accountstoInsert;
        //Insert Contact records
        List<Contact> contactstoInsert=new List<Contact>();
        Contact contactRec = new Contact(LastName='Rama',Email='ramadevithota@citation.co.uk',AccountId=accountstoInsert[0].Id);
        contactstoInsert.add(contactRec); 
        Contact con1=new Contact();       
        con1.LastName='test1';
        con1.AccountId=accountstoInsert[1].id;
        contactstoInsert.add(con1);
        insert contactstoInsert;
        //Insert Opportunity records
        List<Opportunity> opportunitiestoInsert=new List<Opportunity>();
        opportunity opp=new opportunity();
        opp.name='test opp';
        opp.StageName='open';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountid=accountstoInsert[0].id;
        opp.DateMade__c=System.today().addMonths(2);
        opp.LeadSource='Partnership';
        opportunitiestoInsert.add(opp);
        opportunity opp1=new opportunity();
        opp1.name='test opp1';
        opp1.StageName='open';
        opp1.CloseDate=Date.today().addMonths(1);
        opp1.accountid=accountstoInsert[1].id;
        opp1.DateMade__c=System.today().addMonths(12);
        opp1.LeadSource='Partnership';
        opp1.Amount=1000;
        opportunitiestoInsert.add(opp1);
        insert opportunitiestoInsert;
        //Insert Sbqq_Quote__c records
        List<Sbqq__Quote__c> sbqqQuotetoInsert=new List<Sbqq__Quote__c>();
        Sbqq__Quote__c partnerQuote = new Sbqq__Quote__c();
        partnerQuote.SBQQ__PrimaryContact__c = contactstoInsert[0].Id;
        partnerQuote.SBQQ__StartDate__c = System.today();
        partnerQuote.SBQQ__Opportunity2__c=opportunitiestoInsert[0].id;
        partnerQuote.Initial_Payment__c=1000;
        sbqqQuotetoInsert.add(partnerQuote);
        Sbqq__Quote__c childQuote = new Sbqq__Quote__c();
        childQuote.SBQQ__PrimaryContact__c = contactstoInsert[1].Id;
        childQuote.SBQQ__StartDate__c = System.today();
        childQuote.SBQQ__Opportunity2__c=opportunitiestoInsert[1].id;
        childQuote.Initial_Payment__c=1000;
        sbqqQuotetoInsert.add(childQuote);
        insert sbqqQuotetoInsert;
        //Insert SBQQ__QuoteLineGroup__c record
        SBQQ__QuoteLineGroup__c testGroup = new SBQQ__QuoteLineGroup__c();
        testGroup.Name = 'Testy';
        testGroup.SBQQ__Quote__c = sbqqQuotetoInsert[0].Id;
        testGroup.SBQQ__SubscriptionTerm__c = 60;
        insert testGroup;
        //Insert Quote Line record
        TestDataFactory.getQuoteLines(sbqqQuotetoInsert[0].Id,partProd.Id,testGroup.Id);
        //Create a record for partner member relationship
        Partner_Member_Relationship__c part=new Partner_Member_Relationship__c();
        part.Partner__c=accountstoInsert[0].id;
        part.Member__c=accountstoInsert[1].Id;
        part.Name='testpartner'; 
        part.HR_Access_Unit_Assigned__c='HR How-To Hub';
        part.H_S_Access_Unit_Assigned__c='H&S How-To Hub';
        insert part;
        Test.startTest();    
        //Insert Contract which acts as partner
        Contract conRec = new Contract();
        conRec.Name = 'New Citation Contract';
        conRec.AccountId = accountstoInsert[0].Id;
        conRec.SBQQ__Quote__c=partnerQuote.Id;
        conRec.Source_Opportunity__c=opp.Id;
        conRec.Status = 'Draft';
        conRec.Renewal_Type__c = 'Auto';
        conRec.Business_Type__c = 'New Business';
        conRec.StartDate = System.today();
        conRec.ContractTerm = 24;
        conRec.FOC_Period_Mths__c = 20;
        conRec.FOC_Period_Mths_End__c = 10;
        conRec.Service_Type__c = 'Citation';
        conRec.Agreement_Type__c = 'Auto';
        conRec.CustomerSignedId=contactstoInsert[0].id;
        conRec.RecordTypeId=contractRecordTypeId;
        conRec.Ts_Cs_Version__c = null;
        conRec.Total_Contract_Value__c=1000;
        conRec.Core_Compliance_TCV__c=100;
        conRec.Initial_Payment2__c=1000;
        conRec.Commission_Partner__c=accountstoInsert[1].id;
        conRec.Commission_Eligibility__c=true;
        conRec.Commission_Approved__c=true;
        insert conRec;
        //Insert SBQQ__Subscription__c record
        SBQQ__Subscription__c ql1 = new SBQQ__Subscription__c(SBQQ__Contract__c= conRec.Id, sbqq__product__C = partProd.id,SBQQ__Quantity__c = 1.0) ;
        insert ql1 ; 
        //Insert Terms_and_Conditions__c record
        List<Terms_and_Conditions__c> tcList = TestDataFactory.getTermsAndConditions(4);
        for(Terms_and_Conditions__c t:tcList){
          t.Contract_Record_Type__c='Citation Partnership';  
        }
		insert tcList;
        //
        echosign_dev1__SIGN_Agreement__c e=new echosign_dev1__SIGN_Agreement__c();
        e.echosign_dev1__Status__c='Signed';
        e.echosign_dev1__Contract__c=conRec.Id;
        //Insert e;
        //Update Status of Partner contract to Active
        conRec.Status='Active';        
        update conRec; 
        Test.stopTest();
    }
    
    @isTest
    public static void executeDataforChildContract(){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        Id strdRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
        //Get Inserted PartnerAccount and MemberAccount
        Account partnerAcc=[Select Id,Name From Account Where Name='Citation Account'];
        Account childAcc=[Select Id,Name From Account Where Name='Child acc'];
        //Get Inserted Member Contact
        Contact con1=[Select Id,Name From Contact where LastName='test1'];
        //Get Inserted Member Quote
        SBQQ__Quote__c childQuote=[Select Id From SBQQ__Quote__c where SBQQ__PrimaryContact__c=:con1.Id];
        //Get Inserted Member Opportunity
         Opportunity opp1=[Select Id From Opportunity Where accountid=:childAcc.Id];
        //Get Inserted Product
        Product2 partProd=[Select Id,Name From Product2 where Name='Partner Commission'];
        //Get Partner_Member_Relationship__c record of this Member
        Partner_Member_Relationship__c part=[Select Id From Partner_Member_Relationship__c where Partner__c=:partnerAcc.Id AND Member__c=:childAcc.Id];
        
        Test.startTest(); 
        //Insert Member Contract
        List<Contract> conList1=new List<Contract>();
        Contract cont1= new Contract();
        cont1.Name='test contract';
        cont1.AccountId=childAcc.id; 
        cont1.Source_Opportunity__c=opp1.id;
        cont1.SBQQ__Opportunity__c=opp1.id;
        cont1.SBQQ__Quote__c=childQuote.id;
        cont1.StartDate=System.today();
        cont1.ContractTerm=12;
        cont1.Partner_Member_Record__c=part.Id;
        cont1.RecordTypeId=strdRecordTypeId;
        cont1.FOC_Period_Mths__c=0;
        cont1.FOC_Period_Mths_End__c =0;  
        cont1.CustomerSignedId=con1.id;	
        cont1.Total_Contract_Value__c=100;
        cont1.Core_Compliance_TCV__c=100;
        cont1.Initial_Payment2__c=100;
        conList1.add(cont1);	
        insert conList1;
        Test.stopTest();
    }  
    
    public static testMethod void whenContractActive_update_CallDateAndLastVisitDate(){
        Id strdRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
        
        Test.startTest();
        //Insert Partner Account
        Account partnerAcc = new Account();
        partnerAcc.Name = 'Citation Account';
        partnerAcc.PT_Employees__c = 20;
        partnerAcc.FT_Employees__c = 20;
        partnerAcc.Sites__c = 5;
        partnerAcc.AccountSource = 'Partnership';
        partnerAcc.Type = 'Client';
        partnerAcc.MACV__c = 100;
        partnerAcc.PACV__c = 100;
        insert partnerAcc;
        
        //Insert Partner Contact
        Contact contactRec = new Contact(LastName = 'Rama', Email = 'ramadevithota@citation.co.uk', AccountId = partnerAcc.Id);
        insert contactRec;
        
        //Insert Partner Contract       
        Contract conRec = new Contract();
        conRec.Name = 'New Citation Contract';
        conRec.AccountId = partnerAcc.Id;
        conRec.Status = 'Draft';
        conRec.Renewal_Type__c = 'Auto';
        conRec.Business_Type__c = 'New Business';
        conRec.StartDate = Date.today();
        conRec.ContractTerm = 24;
        conRec.FOC_Period_Mths__c = 20;
        conRec.FOC_Period_Mths_End__c = 10;
        conRec.Service_Type__c = 'Citation';
        conRec.Agreement_Type__c = 'Paper';
        conRec.CustomerSignedId = contactRec.Id;
        conRec.RecordTypeId = strdRecordTypeId;
        conRec.Ts_Cs_Version__c = null;
        conRec.Total_Contract_Value__c = 1000;
        conRec.Core_Compliance_TCV__c = 100;
        conRec.Initial_Payment2__c = 1000;
        conRec.Commission_Rate__c = 28;
        insert conRec;
        
        //Update Contract Status to Active
        conRec.Status = 'Active';        
        update conRec; 
        Test.stopTest();
        
        Account acc = [SELECT Id, PB_Last_Care_Call_Date__c, PB_Last_Rel_Visit_Dt__c FROM Account WHERE Id=: partnerAcc.Id];
        System.assertEquals(System.today(), acc.PB_Last_Care_Call_Date__c);
        System.assertEquals(System.today(), acc.PB_Last_Rel_Visit_Dt__c);
    }
    
    public static testMethod void whenContractActiveForSouthalls_update_TermsVersionAndEffectiveDate(){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Contract Record Type').getRecordTypeId();
        Id clientRelRenewalRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Renewal Contract').getRecordTypeId();
        Id oppoRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal / Retention Opportunity - Auto').getRecordTypeId();
        
        //Account
        Account acc = [SELECT Id, Name FROM Account WHERE Name='Citation Account' LIMIT 1];
        
        //Contact
        Contact con = [SELECT Id, Name FROM Contact WHERE LastName='Rama' LIMIT 1];
        
        //Terms_and_Conditions__c
        Terms_and_Conditions__c terms = [SELECT Id FROM Terms_and_Conditions__c LIMIT 1];
        
        Contract cont = new Contract();
        cont.Name = 'New Citation Contract';
        cont.Status = 'Draft';
        cont.Renewal_Type__c = 'Auto';
        cont.Business_Type__c = 'New Business';
        cont.StartDate = Date.today();
        cont.ContractTerm = 15;
        cont.FOC_Period_Mths__c = 20;
        cont.FOC_Period_Mths_End__c = 10;
        cont.Service_Type__c = 'Citation';
        cont.Agreement_Type__c = 'Paper';
        cont.RecordTypeId = contractRecordTypeId;
        cont.CustomerSignedId = con.Id;
        cont.AccountId = acc.Id;
        cont.Preferred_Payment_Date__c ='14';
        cont.Ts_Cs_Version__c = terms.Id;
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppoRecordTypeName;
        opp.Original_Contract__c = cont.Id;
        opp.Name = 'Auto Renewal Opportunity';
        opp.CloseDate = Date.today()+740;
        opp.AccountId = acc.Id;
        opp.StageName = 'Renewal Contact Due';
        insert opp;
        
        Test.startTest();
        
        //Insert Partner Contract       
        Contract conRec = new Contract();
        conRec.Name = 'New Citation Contract1';
        conRec.AccountId = acc.Id;
        conRec.Status = 'Draft';
        conRec.Renewal_Type__c = 'Auto';
        conRec.Business_Type__c = 'New Business';
        conRec.StartDate = Date.today();
        conRec.ContractTerm = 24;
        conRec.FOC_Period_Mths__c = 20;
        conRec.FOC_Period_Mths_End__c = 10;
        conRec.Service_Type__c = 'Citation';
        conRec.Agreement_Type__c = 'Paper';
        conRec.CustomerSignedId = con.Id;
        conRec.RecordTypeId = clientRelRenewalRecTypeId;
        conRec.Legacy_Migration_Company__c = 'Southalls';
        conRec.Source_Opportunity__c = opp.Id;
        insert conRec;
        
        //Update Contract Status to Active
        conRec.Status = 'Active';        
        update conRec; 
        Test.stopTest();
        
        Contract updatedContract = [SELECT Id, Ts_Cs_Version__c, Current_Ts_and_Cs_Effective_Date__c, StartDate, Source_Opportunity__r.Original_Contract__r.Ts_Cs_Version__c FROM Contract WHERE Id=: conRec.Id];
        System.assertEquals(updatedContract.Ts_Cs_Version__c, updatedContract.Source_Opportunity__r.Original_Contract__r.Ts_Cs_Version__c);
        System.assertEquals(updatedContract.Current_Ts_and_Cs_Effective_Date__c, updatedContract.StartDate);
    }
}