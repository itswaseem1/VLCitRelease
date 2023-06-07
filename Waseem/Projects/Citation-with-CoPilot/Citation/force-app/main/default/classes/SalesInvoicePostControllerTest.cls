@isTest
public class SalesInvoicePostControllerTest {
    
    @TestSetup
    static void makeData(){
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue ;
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<queuesobject>  listQueue = new List<queuesobject >();
            queuesobject q1 = new queuesobject (queueid=testGroup.id, sobjecttype='Case'); 
            listQueue.add(q1);
            queuesobject q2 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaAccountingCurrency__c'); 
            listQueue.add(q2);
            queuesobject q3 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaPurchaseInvoice__c'); 
            listQueue.add(q3);
            queuesobject q4 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCompany__c'); 
            listQueue.add(q4);
            queuesobject q5 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaYear__c'); 
            listQueue.add(q5);
            queuesobject q6 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaInvoice__c'); 
            listQueue.add(q6);
            queuesobject q7 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaTransaction__c'); 
            listQueue.add(q7);
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
        accCurrency.c2g__Home__c = true ;
        accCurrency.ownerid = testGroup.Id;
        insert accCurrency;      
        
        c2g__codaGeneralLedgerAccount__c GLAcc = new c2g__codaGeneralLedgerAccount__c();
        GLAcc.Name = '10100 - Sales Revenue';
        GLAcc.c2g__BalanceSheet1__c ='Balance Sheet';
        GLAcc.c2g__ExternalId__c ='10100 - Sales Revenue';
        GLAcc.c2g__ReportingCode__c = '10100';
        GLAcc.c2g__UnitOfWork__c =123;
        GLAcc.c2g__TrialBalance1__c = 'Profit and Loss' ;
        GLAcc.c2g__Type__c = 'Profit and Loss' ;
        insert GLAcc;
        
        
        Account acc= new Account();
        acc.Name='Test Account';
        acc.c2g__CODAAccountTradingCurrency__c = 'GBP' ;
        acc.CurrencyIsoCode='GBP';
        acc.c2g__CODAAccountsPayableControl__c = GLAcc.Id;
        acc.c2g__CODAAccountsReceivableControl__c = GLAcc.Id;
        insert acc;
        
        c2g__codaInvoice__c invoice = new c2g__codaInvoice__c();
        invoice.c2g__OwnerCompany__c = company.Id;
        invoice.c2g__Account__c = acc.Id;
        invoice.c2g__InvoiceDate__c = System.today().addDays(8);
        invoice.c2g__DueDate__c = System.today().addDays(8);
        invoice.c2g__FirstDueDate__c = System.today().addDays(8);
        invoice.c2g__DeriveDueDate__c = false;
        invoice.c2g__Interval__c = 'Monthly';
        invoice.CurrencyIsoCode = 'GBP';
        invoice.ownerid = [select id from group where Name='test group'].Id;
        insert invoice;
        
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;
        
        Product2 product = new Product2(Name = 'tst', isactive=true);
        product.c2g__CODASalesRevenueAccount__c = GLAcc.Id;
        insert product;
        
        c2g__codaAccountingSettings__c accountSettings = new c2g__codaAccountingSettings__c();
        accountSettings.SetupOwnerId = UserInfo.getUserId();
        accountSettings.c2g__EnableOverrideProductGLA__c = true;
        insert accountSettings;
        
        c2g__codaInvoiceLineItem__c invoiceLine = new c2g__codaInvoiceLineItem__c();
        invoiceLine.c2g__Invoice__c = invoice.Id;
        invoiceLine.c2g__LineDescription__c = 'test';
        invoiceLine.c2g__OwnerCompany__c = company.Id;
        invoiceLine.c2g__Product__c = product.Id;
        invoiceLine.c2g__UnitPrice__c = 23;
        insert invoiceLine;
        
        BatchApexController__c setting = new BatchApexController__c(Name = 'BulkSalesInvoicePostBatch', Batch_size__c = 10);
        insert setting;
    }
    
    @isTest
    static void whenSalesInvoiceSelected_PostRecordsSyncronously() 
    {
        List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id,c2g__InvoiceStatus__c FROM c2g__codaInvoice__c];
        
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(salesInvoiceList);
        stdSetController.setSelected(salesInvoiceList);
        SalesInvoicePostController ext = new SalesInvoicePostController(stdSetController);
        ext.onSave();
        Test.stopTest();
        
        List<c2g__codaInvoice__c> salesInvoiceList1 = [SELECT Id,c2g__InvoiceStatus__c FROM c2g__codaInvoice__c];
        System.assertEquals('Complete', salesInvoiceList1[0].c2g__InvoiceStatus__c);
    }
    
    @isTest
    static void whenNoSalesInvoiceSelected_PostRecordsAsyncronously() 
    {
        List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();
        
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(salesInvoiceList);
        stdSetController.setSelected(salesInvoiceList);
        SalesInvoicePostController ext = new SalesInvoicePostController(stdSetController);
        ext.onSave();
        Test.stopTest();
        
        List<c2g__codaInvoice__c> salesInvoiceList1 = [SELECT Id,c2g__InvoiceStatus__c FROM c2g__codaInvoice__c];
        System.assertEquals('Complete', salesInvoiceList1[0].c2g__InvoiceStatus__c);
    }
}