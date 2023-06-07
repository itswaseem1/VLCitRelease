@isTest
public class Triggercg2InvoiceHandlerTest {

    public @TestSetup static void createTestData(){
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue ;

        System.runAs(new User(Id=UserInfo.getUserId()))
            {
                List<queuesobject >  listQueue = new List<queuesobject >();
                queuesobject q1 = new queuesobject (queueid=testGroup.id, sobjecttype='Case'); 
                listQueue.add(q1);
                queuesobject q2 = new queuesobject (queueid=testGroup.id,                                                                 sobjecttype='c2g__codaAccountingCurrency__c'); 
                listQueue.add(q2);
                queuesobject q3 = new queuesobject (queueid=testGroup.id,                                                                 sobjecttype='c2g__codaPurchaseInvoice__c'); 
                listQueue.add(q3);
                queuesobject q4 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCompany__c'); 
                listQueue.add(q4);
                queuesobject q5 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaYear__c'); 
                listQueue.add(q5);
                queuesobject q6 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaInvoice__c'); 
                listQueue.add(q6);
                insert  listQueue;

                GroupMember GroupMemberObj = new GroupMember();
                GroupMemberObj.GroupId = testGroup.id;
                GroupMemberObj.UserOrGroupId = UserInfo.getUserId();
                insert GroupMemberObj;
            } 

        c2g__codaCompany__c company = new c2g__codaCompany__c();
        company.Name = 'Test Record';       
        company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
        company.c2g__YearEndMode__c = 'Test Code';
        company.c2g__ExternalId__c = 'ABCDE1234567876';
        company.c2g__LogoURL__c ='ww.XYZ.com';
        company.c2g__ECCountryCode__c = 'GBP' ;
        company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
        company.c2g__Website__c = 'ww.xyz.com';
        company.c2g__Country__c ='UK';
        company.ownerid = testGroup.Id;
        insert company;

        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
        userCompany.c2g__Company__c =company.id;
        userCompany.c2g__User__c = userInfo.getUserId();
        userCompany.c2g__ExternalId__c = 'ABCDE1234567876';
        userCompany.c2g__UnitOfWork__c = 111 ;
        insert  userCompany;

        c2g__codaYear__c yr= new c2g__codaYear__c();
        yr.Name ='2019';
        yr.c2g__AutomaticPeriodList__c =  true;
        yr.c2g__OwnerCompany__c = company.id;
        yr.c2g__ExternalId__c = 'yzsd1234';
        yr.c2g__NumberOfPeriods__c =11;
        yr.c2g__StartDate__c =  system.today() - 10;
        yr.c2g__Status__c = 'Open';
        yr.c2g__PeriodCalculationBasis__c = '445';
        yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
        yr.c2g__UnitOfWork__c = 12;
        yr.ownerid = testGroup.Id;
        insert yr;

        c2g__codaPeriod__c prd = new c2g__codaPeriod__c();
        prd.Name ='Test2019';
        prd.c2g__ExternalId__c ='abdc12345';
        prd.c2g__StartDate__c = System.today()-10;
        prd.c2g__EndDate__c= System.today()+10;
        prd.c2g__OwnerCompany__c = company.id;
        prd.c2g__PeriodNumber__c ='123';
        prd.c2g__Description__c ='test Desc';
        prd.c2g__PeriodGroup__c = 'Q1';
        prd.c2g__PeriodNumber__c = '1';
        prd.c2g__YearName__c = yr.id;
        insert prd;

        c2g__codaAccountingCurrency__c accCurrency = new c2g__codaAccountingCurrency__c();
        accCurrency.c2g__OwnerCompany__c = company.id;
        accCurrency.c2g__DecimalPlaces__c = 2;
        accCurrency.Name = 'GBP';
        accCurrency.c2g__Dual__c = true ;
        accCurrency.ownerid = testGroup.Id;
        insert accCurrency;

        c2g__codaExchangeRate__c exchRate = new c2g__codaExchangeRate__c();
        exchRate.c2g__ExchangeRateCurrency__c = accCurrency.id;
        exchRate.c2g__OwnerCompany__c = company.id;
        exchRate.c2g__ExternalId__c ='12323232';
        exchRate.c2g__Rate__c =44.55;
        exchRate.c2g__StartDate__c = system.today()-10;
        exchRate.c2g__UnitOfWork__c =10;
        insert exchRate;       

        c2g__codaGeneralLedgerAccount__c GLAcc = new c2g__codaGeneralLedgerAccount__c();
        GLAcc.Name = 'Retained Earnings';
        GLAcc.c2g__BalanceSheet1__c ='Balance Sheet'; 
       
        GLAcc.c2g__ExternalId__c ='testID';
        GLAcc.c2g__ReportingCode__c = '1234567543333';
        GLAcc.c2g__UnitOfWork__c =123;
        GLAcc.c2g__TrialBalance1__c = 'Balance Sheet' ;
        GLAcc.c2g__Type__c = 'Balance Sheet' ;
        insert GLAcc;

        Account acc= new Account();
        acc.Name='Test Account';
        acc.c2g__CODAAccountTradingCurrency__c = 'GBP' ;
        acc.CurrencyIsoCode='GBP';
        acc.c2g__CODAAccountsPayableControl__c = GLAcc.Id;
        insert acc;
    }

    static testmethod void salesInvoiceTestPopulatesDimension1() {      

        c2g__codaDimension1__c dim = new c2g__codaDimension1__c() ;
        dim.c2g__ExternalId__c = 'CP102' ;
        dim.Description__c = 'test' ;
        dim.name = 'CP102 - Corporate' ;
        dim.c2g__ReportingCode__c = 'CP102' ;
        insert dim ;  

        test.starttest() ;
            c2g__codaInvoice__c testInvoice = new c2g__codaInvoice__c();
            testInvoice.CurrencyIsoCode = 'GBP' ;
            testInvoice.c2g__InvoiceDate__c = date.today().addDays(-7) ;
            testInvoice.c2g__DueDate__c = date.today().addDays(-7) ;
            testInvoice.c2g__Account__c = [select id from account].id ;
            testInvoice.c2g__OwnerCompany__c = [select id from c2g__codaCompany__c].id ;
            testInvoice.ownerid = [select id from group where Name='test group'].Id ;
            insert testInvoice; 
        test.stoptest() ;

        c2g__codaInvoice__c checkInvoice = [select id, c2g__Dimension1__c from c2g__codaInvoice__c where id = :testInvoice.id] ;
       
        system.assertEquals(dim.id,checkInvoice.c2g__Dimension1__c) ;
    }  

    
    static testmethod void salesInvoiceTest_NoOverwrite() {

        c2g__codaDimension1__c dim = new c2g__codaDimension1__c() ;
        dim.c2g__ExternalId__c = 'CP101' ;
        dim.Description__c = 'test' ;
        dim.name = 'CP101 - Corporate' ;
        dim.c2g__ReportingCode__c = 'CP101' ;
        insert dim ;

        c2g__codaDimension1__c dim2 = new c2g__codaDimension1__c() ;
        dim2.c2g__ExternalId__c = 'CP102' ;
        dim2.Description__c = 'test' ;
        dim2.name = 'CP102 - Corporate' ;
        dim2.c2g__ReportingCode__c = 'CP102' ;
        insert dim2 ;
       
        test.starttest() ;
            c2g__codaInvoice__c testInvoice = new c2g__codaInvoice__c();
            testInvoice.CurrencyIsoCode = 'GBP' ;
            testInvoice.c2g__InvoiceDate__c = date.today().addDays(-7) ;
            testInvoice.c2g__DueDate__c = date.today().addDays(-7) ;
            testInvoice.c2g__Account__c = [select id from account].id ;
            testInvoice.c2g__OwnerCompany__c = [select id from c2g__codaCompany__c].id ;
            testInvoice.ownerid = [select id from group where Name='test group'].Id ;
            testInvoice.c2g__Dimension1__c = dim.id ;           
            insert testInvoice; 
        test.stoptest() ;

        c2g__codaInvoice__c checkInvoice = [select id, c2g__Dimension1__c from c2g__codaInvoice__c where id = :testInvoice.id] ;
      
        system.assertEquals(dim.id,checkInvoice.c2g__Dimension1__c) ;
    }      

    static testmethod void salesInvoiceNoDimensionRecords() { 

        test.starttest() ;
            c2g__codaInvoice__c testInvoice = new c2g__codaInvoice__c();
            testInvoice.CurrencyIsoCode = 'GBP' ;
            testInvoice.c2g__InvoiceDate__c = date.today().addDays(-7) ;
            testInvoice.c2g__DueDate__c = date.today().addDays(-7) ;
            testInvoice.c2g__Account__c = [select id from account].id ;
            testInvoice.c2g__OwnerCompany__c = [select id from c2g__codaCompany__c].id ;
            testInvoice.ownerid = [select id from group where Name='test group'].Id ;
            insert testInvoice;  
        test.stoptest() ;

        c2g__codaInvoice__c checkInvoice = [select id, c2g__Dimension1__c from c2g__codaInvoice__c where id = :testInvoice.id] ;
        system.assertEquals(null,checkInvoice.c2g__Dimension1__c) ;
    }  
}