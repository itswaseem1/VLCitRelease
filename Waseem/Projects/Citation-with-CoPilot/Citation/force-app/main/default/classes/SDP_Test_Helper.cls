@SuppressWarnings('PMD')
@isTest
public with sharing class SDP_Test_Helper {

    public static c2g__codaCompany__c company;
    public static c2g__codaGeneralLedgerAccount__c GLAcc;
    public static c2g__codaGeneralLedgerAccount__c GLAcc1;
    public static Pricebook2 pricebook;
    public static Product2 product;
    public static List<product2> pList ;

    public static void generateCustomSettings()
    {
        TriggerSettings__c config = new TriggerSettings__c(Direct_Debit_History_Trigger__c = true, 
                                                            Direct_Debit_Trigger__c = true,
                                                            Sale_Invoice_Trigger__c = true,
                                                            Transaction_Trigger__c = true);
        insert config;
    }

    public static void createFinancialForceData()
    {
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue ;

        System.runAs(new User(Id=UserInfo.getUserId())) {
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

        company = new c2g__codaCompany__c();
        company.Name = 'Citation Limited';       
        company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
        company.c2g__YearEndMode__c = 'Test Code';
        company.c2g__ExternalId__c = 'ABCDE1234567876';
        company.c2g__LogoURL__c ='ww.XYZ.com';
        company.c2g__ECCountryCode__c = 'GBP' ;
        company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
        company.c2g__Website__c = 'ww.xyz.com';
        company.c2g__Country__c ='UK';
        company.ownerid = testGroup.Id;
        company.Service_User_Number__c = '123456';        
        insert company;
        
        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
        userCompany.c2g__Company__c =company.id;
        userCompany.c2g__User__c = userInfo.getUserId();
        userCompany.c2g__ExternalId__c = 'ABCDE1234567876';
        userCompany.c2g__UnitOfWork__c = 111 ;
        insert  userCompany;
        
        c2g__codaYear__c yr = new c2g__codaYear__c();
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
        accCurrency.c2g__Home__c = true;
        accCurrency.c2g__Dual__c = true;
        insert accCurrency;    

        GLAcc = new c2g__codaGeneralLedgerAccount__c();
        GLAcc.Name = '10100 - Sales Revenue';
        GLAcc.c2g__BalanceSheet1__c ='Balance Sheet';
        GLAcc.c2g__ExternalId__c ='10100 - Sales Revenue';
        GLAcc.c2g__ReportingCode__c = '10100';
        GLAcc.c2g__UnitOfWork__c =123;
        GLAcc.c2g__TrialBalance1__c = 'Profit and Loss' ;
        GLAcc.c2g__Type__c = 'Profit and Loss' ;
        insert GLAcc;

        GLAcc1 = new c2g__codaGeneralLedgerAccount__c();
        GLAcc1.Name = 'test';
        GLAcc1.c2g__BalanceSheet1__c ='Balance Sheet';
        GLAcc1.c2g__ExternalId__c ='123324';
        GLAcc1.c2g__ReportingCode__c = '123324';
        GLAcc1.c2g__UnitOfWork__c =123;
        GLAcc1.c2g__TrialBalance1__c = 'Balance Sheet' ;
        GLAcc1.c2g__Type__c = 'Balance Sheet' ;
        insert GLAcc1;
        
        // custom settings
        c2g__codaAccountingSettings__c setting = new c2g__codaAccountingSettings__c();
        setting.SetupOwnerId = UserInfo.getOrganizationId();
        setting.c2g__EnableOverrideProductGLA__c = true;
        insert setting;

        pricebook = new Pricebook2(
    		Name = 'test 1',
    		Annual_Turnover_Maximum__c = 100000.0,
    		Annual_Turnover_Minimum__c = 0.0,
    		Term__c = '5',
            isActive = true
    	);

        insert pricebook;
		pList = new List<Product2>();
        product = new Product2();
        product.name='H&S Compliance Core';
        product.isactive=true;
        product.Business_Type__c = 'Citation';
        product.Family = 'Employment Law and HR';
        product.Org_Migration_Id__c = '1235x';
        product.SBQQ__Taxable__c = false;
        product.c2g__CODASalesRevenueAccount__c = GLAcc.Id;
        plist.add(product);
        
        Product2 productx = new Product2();
        productx.name='H&S Compliance Service';
        productx.isactive=true;
        productx.Business_Type__c = 'Citation';
        productx.Family = 'H&S Compliance Service';
        productx.Org_Migration_Id__c = '12356';
        productx.SBQQ__Taxable__c = false;
        productx.c2g__CODASalesRevenueAccount__c = GLAcc1.Id;
		plist.add(productx);
        insert plist; 
        
        c2g__codaBankAccount__c bankAccount = new c2g__codaBankAccount__c();
        bankAccount.Name = 'Citation Main';
        bankAccount.c2g__BankAccountCurrency__c = accCurrency.Id;
        bankAccount.c2g__AccountName__c = 'test';
        bankAccount.c2g__AccountNumber__c = '55779911';
        bankAccount.c2g__SortCode__c = '200000';
        bankAccount.c2g__BankName__c = 'test';
        bankAccount.c2g__ReportingCode__c = 'CURRGBP7175MIDLGB22';
        bankAccount.c2g__GeneralLedgerAccount__c = GLAcc.Id;
        insert bankAccount;

        company.Direct_Debit_Bank_Account__c = bankAccount.Id;
        update company;
    }

    public static Account createAccount(String name)
    {
        Account acc = new Account();
        acc.Name=name;
        acc.c2g__CODAAccountTradingCurrency__c = 'GBP' ;
        acc.CurrencyIsoCode='GBP';
        acc.c2g__CODAAccountsPayableControl__c = GLAcc.Id;
        acc.c2g__CODAAccountsReceivableControl__c = GLAcc.Id;
        insert acc;
        
            List<Site__c> siteList = new List<Site__c>();
    Site__c accSite1 = new Site__c(
      Account__c = acc.Id,
      Active__c = true,
      Site_Type__c = 'Main Site'
    );
    siteList.add(accSite1);
    Site__c accSite2 = new Site__c(
      Account__c = acc.Id,
      Active__c = true,
      Site_Type__c = 'Other Site'
    );
    siteList.add(accSite2);
      
  

    insert siteList;

        return acc;
    }

    public static c2g__codaInvoice__c createInvoice(Id companyId, Id accountId, Date dueDate, Decimal amount, Id ddID)
    {
        c2g__codaInvoice__c invoice = new c2g__codaInvoice__c();
        invoice.c2g__OwnerCompany__c = companyId;
        invoice.c2g__Account__c = accountId;
        invoice.c2g__InvoiceDate__c = dueDate;
        invoice.c2g__DueDate__c = dueDate;
        invoice.c2g__FirstDueDate__c = dueDate;
        invoice.c2g__DeriveDueDate__c = false;
        invoice.c2g__Interval__c = 'Monthly';
        invoice.CurrencyIsoCode = 'GBP';
      
        invoice.ownerid = [select id from group where Name='test group'].Id;
        invoice.c2g__GeneralLedgerAccount__c = GLAcc1.Id;
        insert invoice;

        c2g__codaInvoiceLineItem__c invoiceLine = new c2g__codaInvoiceLineItem__c();
        invoiceLine.c2g__Invoice__c = invoice.Id;
        invoiceLine.c2g__LineDescription__c = 'test';
        invoiceLine.c2g__OwnerCompany__c = companyId;
        invoiceLine.c2g__Product__c = plist[0].Id;
        invoiceLine.c2g__UnitPrice__c = amount;
        insert invoiceLine;
        
        c2g__codaInvoiceLineItem__c invoiceLine2 = new c2g__codaInvoiceLineItem__c();
        invoiceLine2.c2g__Invoice__c = invoice.Id;
        invoiceLine2.c2g__LineDescription__c = 'test2';
        invoiceLine2.c2g__OwnerCompany__c = companyId;
        invoiceLine2.c2g__Product__c = plist[1].Id;
        invoiceLine2.c2g__UnitPrice__c = amount;
        insert invoiceLine2;

        return invoice;
    }

    public static void postInvoice(Id invoiceId)
    {
        c2g.CODAAPICommon.Reference pRef = new c2g.CODAAPICommon.Reference();
        pRef.Id = invoiceId;

        c2g.CODAAPICommon_10_0.Context pContext = new c2g.CODAAPICommon_10_0.Context();
        c2g.CODAAPISalesInvoice_10_0.PostInvoice(pContext, pRef);
    }
}