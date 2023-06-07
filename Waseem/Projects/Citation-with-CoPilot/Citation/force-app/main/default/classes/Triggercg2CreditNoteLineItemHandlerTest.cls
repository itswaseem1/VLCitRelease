@isTest
private class Triggercg2CreditNoteLineItemHandlerTest {
	
    @TestSetup
    static void makeData(){
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
            queuesobject q7 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCreditNote__c'); 
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
        GLAcc.Name = '10100 - Sales Revenue';
        GLAcc.c2g__BalanceSheet1__c ='Balance Sheet';
        GLAcc.c2g__ExternalId__c ='10100 - Sales Revenue';
        GLAcc.c2g__ReportingCode__c = '10100';
        GLAcc.c2g__UnitOfWork__c =123;
        GLAcc.c2g__TrialBalance1__c = 'Profit and Loss' ;
        GLAcc.c2g__Type__c = 'Profit and Loss' ;
        insert GLAcc;

        c2g__codaGeneralLedgerAccount__c GLAcc1 = new c2g__codaGeneralLedgerAccount__c();
        GLAcc1.Name = 'test';
        GLAcc1.c2g__BalanceSheet1__c ='Balance Sheet';
        GLAcc1.c2g__ExternalId__c ='123324';
        GLAcc1.c2g__ReportingCode__c = '123324';
        GLAcc1.c2g__UnitOfWork__c =123;
        GLAcc1.c2g__TrialBalance1__c = 'Balance Sheet' ;
        GLAcc1.c2g__Type__c = 'Balance Sheet' ;
        insert GLAcc1;

        Account acc= new Account();
        acc.Name='Test Account';
        acc.c2g__CODAAccountTradingCurrency__c = 'GBP' ;
        acc.CurrencyIsoCode='GBP';
        acc.c2g__CODAAccountsPayableControl__c = GLAcc.Id;
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

        // custom settings
        c2g__codaAccountingSettings__c setting = new c2g__codaAccountingSettings__c();
        setting.SetupOwnerId = UserInfo.getOrganizationId();
        setting.c2g__EnableOverrideProductGLA__c = true;
		setting.c2g__EnableEditDimensionsafterposting__c = true;
        insert setting;

        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        insert pricebook;

        Product2 product = new Product2();
        product.name='tst';
        product.isactive=true;
        product.Business_Type__c = 'Citation';
        product.Family = 'Employment Law and HR';
        product.Org_Migration_Id__c = '1235';
        product.SBQQ__Taxable__c = false;
        insert product;

		c2g__codaInvoiceLineItem__c invoiceLine = new c2g__codaInvoiceLineItem__c();
		invoiceLine.c2g__Invoice__c = invoice.Id;
		invoiceLine.c2g__LineDescription__c = 'test';
		invoiceLine.c2g__OwnerCompany__c = company.Id;
		invoiceLine.c2g__Product__c = product.Id;
		invoiceLine.c2g__UnitPrice__c = 23;
		insert invoiceLine;
		
		c2g__codaTaxCode__c tc = new c2g__codaTaxCode__c();
		tc.c2g__ExternalId__c = 'GB-O-STD';
		tc.CurrencyIsoCode = 'GBP';
		tc.ffvat__NetBox__c = 'Box 6';
		tc.ffvat__TaxBox__c = 'Box 1';
		tc.c2g__Description__c = 'UK Output Standard Rated';
		tc.c2g__GeneralLedgerAccount__c = GLAcc.Id;
		insert tc;

        c2g__codaDimension1__c dim = new c2g__codaDimension1__c() ;
        dim.c2g__ExternalId__c = 'CP102' ;
        dim.Description__c = 'test' ;
        dim.name = 'CP102 - Corporate' ;
        dim.c2g__ReportingCode__c = 'CP102' ;
        insert dim;

    }

    @isTest static void updateDimension1Test(){

        Account account = [select Id from Account limit 1];
        c2g__codaAccountingCurrency__c accountCurrency = [select Id from c2g__codaAccountingCurrency__c limit 1];
        c2g__codaInvoice__c salesInvoice = [select Id from c2g__codaInvoice__c limit 1];
        c2g__codaCompany__c company = [select Id from c2g__codaCompany__c limit 1];
		Product2 product = [select Id from Product2 limit 1];
		c2g__codaGeneralLedgerAccount__c gla = [select Id from c2g__codaGeneralLedgerAccount__c limit 1];
        c2g__codaTaxCode__c tc = [select Id from c2g__codaTaxCode__c limit 1];
        c2g__codaDimension1__c dim = [select Id from c2g__codaDimension1__c limit 1];

        // credit note
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__Account__c = account.Id;
        creditNote.c2g__OwnerCompany__c = company.Id;
        creditNote.c2g__Invoice__c = salesInvoice.Id;
        creditNote.c2g__CreditNoteCurrency__c = accountCurrency.Id;
        insert creditNote;

		// credit note line item
		c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
		creditNoteLineItem.c2g__CreditNote__c = creditNote.Id;
		creditNoteLineItem.c2g__Product__c = product.Id;
		creditNoteLineItem.c2g__GeneralLedgerAccount__c = gla.Id;
		creditNoteLineItem.c2g__LineDescription__c = 'test';
		creditNoteLineItem.c2g__UnitPrice__c = 50;
		creditNoteLineItem.c2g__Quantity__c = 1;
		creditNoteLineItem.c2g__TaxCode1__c = tc.Id;
		creditNoteLineItem.c2g__TaxRate1__c = 20;
		creditNoteLineItem.c2g__TaxValue1__c = 10;

		System.assertEquals(null, creditNoteLineItem.c2g__Dimension1__c);
        Test.startTest();
		insert creditNoteLineItem;
        Test.stopTest();
        System.assertEquals(dim.Id, [select Id, c2g__Dimension1__c from c2g__codaCreditNoteLineItem__c where Id =: creditNoteLineItem.Id limit 1].c2g__Dimension1__c);
        
    }

     @isTest static void updateDimension1FalseTest(){

        Account account = [select Id from Account limit 1];
        c2g__codaAccountingCurrency__c accountCurrency = [select Id from c2g__codaAccountingCurrency__c limit 1];
        c2g__codaInvoice__c salesInvoice = [select Id from c2g__codaInvoice__c limit 1];
        c2g__codaCompany__c company = [select Id from c2g__codaCompany__c limit 1];
		Product2 product = [select Id from Product2 limit 1];
		c2g__codaGeneralLedgerAccount__c gla = [select Id from c2g__codaGeneralLedgerAccount__c limit 1];
        c2g__codaTaxCode__c tc = [select Id from c2g__codaTaxCode__c limit 1];
        c2g__codaDimension1__c dim = [select Id from c2g__codaDimension1__c limit 1];
        
        dim.name = 'AC101 - Payroll recharges' ;
        dim.c2g__ReportingCode__c = 'AC101' ;
        dim.c2g__ExternalId__c = 'AC101' ;
        update dim;

        // credit note
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__Account__c = account.Id;
        creditNote.c2g__OwnerCompany__c = company.Id;
        creditNote.c2g__Invoice__c = salesInvoice.Id;
        creditNote.c2g__CreditNoteCurrency__c = accountCurrency.Id;
        insert creditNote;

		// credit note line item
		c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
		creditNoteLineItem.c2g__CreditNote__c = creditNote.Id;
		creditNoteLineItem.c2g__Product__c = product.Id;
		creditNoteLineItem.c2g__GeneralLedgerAccount__c = gla.Id;
		creditNoteLineItem.c2g__LineDescription__c = 'test';
		creditNoteLineItem.c2g__UnitPrice__c = 50;
		creditNoteLineItem.c2g__Quantity__c = 1;
		creditNoteLineItem.c2g__TaxCode1__c = tc.Id;
		creditNoteLineItem.c2g__TaxRate1__c = 20;
		creditNoteLineItem.c2g__TaxValue1__c = 10;

        System.assertEquals(null, creditNoteLineItem.c2g__Dimension1__c);
        Test.startTest();
		insert creditNoteLineItem;
        Test.stopTest();
        System.assertEquals(null, [select Id, c2g__Dimension1__c from c2g__codaCreditNoteLineItem__c where Id =: creditNoteLineItem.Id limit 1].c2g__Dimension1__c);
        
    }

     @isTest static void updateDimension1BulkTest(){

        Account account = [select Id from Account limit 1];
        c2g__codaAccountingCurrency__c accountCurrency = [select Id from c2g__codaAccountingCurrency__c limit 1];
        c2g__codaInvoice__c salesInvoice = [select Id from c2g__codaInvoice__c limit 1];
        c2g__codaCompany__c company = [select Id from c2g__codaCompany__c limit 1];
		Product2 product = [select Id from Product2 limit 1];
		c2g__codaGeneralLedgerAccount__c gla = [select Id from c2g__codaGeneralLedgerAccount__c limit 1];
        c2g__codaTaxCode__c tc = [select Id from c2g__codaTaxCode__c limit 1];
        c2g__codaDimension1__c dim = [select Id from c2g__codaDimension1__c limit 1];

        List<c2g__codaCreditNote__c> creditNoteList = new List<c2g__codaCreditNote__c>();
        for(Integer i = 0; i < 10; i++){
            // credit note currency
            c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
            creditNote.c2g__Account__c = account.Id;
            creditNote.c2g__OwnerCompany__c = company.Id;
            creditNote.c2g__Invoice__c = salesInvoice.Id;
            creditNote.c2g__CreditNoteCurrency__c = accountCurrency.Id;

            creditNoteList.add(creditNote);
        }

        insert creditNoteList;
        
        List<c2g__codaCreditNoteLineItem__c> creditNoteLineItemList = new List<c2g__codaCreditNoteLineItem__c>();
        for(Integer i = 0; i < creditNoteList.size(); i++){
            // credit note line item
            c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
            creditNoteLineItem.c2g__CreditNote__c = creditNoteList[i].Id;
            creditNoteLineItem.c2g__Product__c = product.Id;
            creditNoteLineItem.c2g__GeneralLedgerAccount__c = gla.Id;
            creditNoteLineItem.c2g__LineDescription__c = 'test';
            creditNoteLineItem.c2g__UnitPrice__c = 50;
            creditNoteLineItem.c2g__Quantity__c = 1;
            creditNoteLineItem.c2g__TaxCode1__c = tc.Id;
            creditNoteLineItem.c2g__TaxRate1__c = 20;
            creditNoteLineItem.c2g__TaxValue1__c = 10;

            creditNoteLineItemList.add(creditNoteLineItem);
        }
        
        Integer size = creditNoteLineItemList.size();

        System.assertEquals(null, creditNoteList[size - 1].c2g__Dimension1__c);
        Test.startTest();
        insert creditNoteLineItemList;
        Test.stopTest();
        System.assertEquals(dim.Id, [select Id, c2g__Dimension1__c from c2g__codaCreditNoteLineItem__c where Id =: creditNoteLineItemList[size - 1].Id limit 1].c2g__Dimension1__c);
        
    }

	 @isTest static void updateProductGLATest(){

        Account account = [select Id from Account limit 1];
        c2g__codaAccountingCurrency__c accountCurrency = [select Id from c2g__codaAccountingCurrency__c limit 1];
        c2g__codaInvoice__c salesInvoice = [select Id from c2g__codaInvoice__c limit 1];
        c2g__codaCompany__c company = [select Id from c2g__codaCompany__c limit 1];
		Product2 product = [select Id from Product2 limit 1];
        c2g__codaTaxCode__c tc = [select Id from c2g__codaTaxCode__c limit 1];
		c2g__codaGeneralLedgerAccount__c gla = [select Id from c2g__codaGeneralLedgerAccount__c where Name = '10100 - Sales Revenue' limit 1];

        // credit note
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__Account__c = account.Id;
        creditNote.c2g__OwnerCompany__c = company.Id;
        creditNote.c2g__Invoice__c = salesInvoice.Id;
        creditNote.c2g__CreditNoteCurrency__c = accountCurrency.Id;
        insert creditNote;

		// credit note line item
		c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
		creditNoteLineItem.c2g__CreditNote__c = creditNote.Id;
		creditNoteLineItem.c2g__Product__c = product.Id;
		creditNoteLineItem.c2g__LineDescription__c = 'test';
		creditNoteLineItem.c2g__UnitPrice__c = 50;
		creditNoteLineItem.c2g__Quantity__c = 1;
		creditNoteLineItem.c2g__TaxCode1__c = tc.Id;
		creditNoteLineItem.c2g__TaxRate1__c = 20;
		creditNoteLineItem.c2g__TaxValue1__c = 10;

		System.assertEquals(null, creditNoteLineItem.c2g__GeneralLedgerAccount__c);
        Test.startTest();
		insert creditNoteLineItem;
        Test.stopTest();
        //System.assertEquals(gla.Id, [select Id, c2g__GeneralLedgerAccount__c from c2g__codaCreditNoteLineItem__c where Id =: creditNoteLineItem.Id limit 1].c2g__GeneralLedgerAccount__c);
        
    }

    
     @isTest static void updateGLAMissingDataTest(){

        Account account = [select Id from Account limit 1];
        c2g__codaAccountingCurrency__c accountCurrency = [select Id from c2g__codaAccountingCurrency__c limit 1];
        c2g__codaInvoice__c salesInvoice = [select Id from c2g__codaInvoice__c limit 1];
        c2g__codaCompany__c company = [select Id from c2g__codaCompany__c limit 1];
		Product2 product = [select Id from Product2 limit 1];
		c2g__codaGeneralLedgerAccount__c gla = [select Id from c2g__codaGeneralLedgerAccount__c where Name = '10100 - Sales Revenue' limit 1];
        c2g__codaTaxCode__c tc = [select Id from c2g__codaTaxCode__c limit 1];
        
        gla.name = 'AC101 - Payroll recharges' ;
        gla.c2g__ReportingCode__c = 'AC101' ;
        gla.c2g__ExternalId__c = 'AC101' ;
        update gla;

        // credit note
        c2g__codaCreditNote__c creditNote = new c2g__codaCreditNote__c();
        creditNote.c2g__Account__c = account.Id;
        creditNote.c2g__OwnerCompany__c = company.Id;
        creditNote.c2g__Invoice__c = salesInvoice.Id;
        creditNote.c2g__CreditNoteCurrency__c = accountCurrency.Id;
        insert creditNote;

		// credit note line item
		c2g__codaCreditNoteLineItem__c creditNoteLineItem = new c2g__codaCreditNoteLineItem__c();
		creditNoteLineItem.c2g__CreditNote__c = creditNote.Id;
		creditNoteLineItem.c2g__Product__c = product.Id;
		creditNoteLineItem.c2g__LineDescription__c = 'test';
		creditNoteLineItem.c2g__UnitPrice__c = 50;
		creditNoteLineItem.c2g__Quantity__c = 1;
		creditNoteLineItem.c2g__TaxCode1__c = tc.Id;
		creditNoteLineItem.c2g__TaxRate1__c = 20;
		creditNoteLineItem.c2g__TaxValue1__c = 10;

        System.assertEquals(null, creditNoteLineItem.c2g__GeneralLedgerAccount__c);
        Test.startTest();
		insert creditNoteLineItem;
        Test.stopTest();
        //System.assertEquals(null, [select Id, c2g__GeneralLedgerAccount__c from c2g__codaCreditNoteLineItem__c where Id =: creditNoteLineItem.Id limit 1].c2g__GeneralLedgerAccount__c);
        
    }
}