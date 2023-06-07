/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class PayonomyPaymentHandlerTest 
{
	static id parecid =  Schema.SObjectType.PAYREC2__Payment_Agreement__c.getRecordTypeInfosByName().get('Direct Debit').getRecordTypeId();
	static boolean baseDataCreated = false;
	static Group queueMemeber = null;
	static c2g__codaCompany__c testCompany = null; 
	static c2g__codaAccountingCurrency__c testCurrency = null; 
	static c2g__codaPeriod__c currentTestPeriod = null; 
	static c2g__codaGeneralLedgerAccount__c accountsPayableControl, accountsReceivableControl, grossRevenue, bankAccCurUK, bankCharges, bankInterest, deferredIncome, salesTaxA;
    
    @isTest(SeeAllData=true)
    static void testMethodOne()
    {
        User systemTestUser = createTestUser();
        System.runAs(systemTestUser)
        {
            // ACT
			setupFFABasedata();
            Account testAccount = createAccount();
            PAYREC2__Payment_Agreement__c testPaymentAgreement = createPaymentAgreement(testAccount);
            c2g__codaBankAccount__c testBankAccount = createBankAccount();
			c2g__codaCashEntry__c testCashEntryHeader = createCashEntry(testAccount.id, testBankAccount.id, 'Receipt', 'Cash', testPaymentAgreement);
            c2g__codaCashEntryLineItem__c testCashEntryLine = createCashEntryLine(testAccount.id, testCashEntryHeader.id, 'Cash');
         
            // ARRANGE
            Test.startTest();
            PAYBASE2__Payment__c testPayment = createPayment(testPaymentAgreement);
            Test.stopTest();
            
            // ASSERT
            system.assertEquals(true, [SELECT ffps_cita__LinkedToPayonomyPayment__c FROM c2g__codaCashEntry__c WHERE id = :testCashEntryHeader.id].ffps_cita__LinkedToPayonomyPayment__c);          
        }
    }
    /**
        *   Create Test User (Product Services)
        *   No @Parms required
        *   No Return
    **/
	static User createTestUser()
    {
        return createTestUser(true);
    }
    /**
        *   Create Test User (Product Services)
        *   No @Parms required
    **/
	static User createTestUser(Boolean doInsert)
    {
        Profile p = [select id from profile where name='System Administrator'];
        User testUser = new User();
        testUser.put('FirstName' , '$FinancialForce PS');
        testUser.put('LastName' , ' Developer$');
        testUser.put('Alias' , '$FFPSD$');
        testUser.put('Email' , 'productservices@financialforce.com');
        testUser.put('Username' , 'financialforceproductservicesdevloper@financialforce.com');
        testUser.put('CommunityNickname' , '$FFPSDMDT$');
        testUser.put('Phone' , '555.555.5555');
        testUser.put('IsActive' , true);
        testUser.put('ProfileId' , p.id);
        testUser.put('TimeZoneSidKey' , 'America/New_York');
        testUser.put('LocaleSidKey' , 'en_US');
        testUser.put('EmailEncodingKey' , 'ISO-8859-1');
        testUser.put('LanguageLocaleKey' , 'en_US');
        testUser.put('Title' , 'Product Service Developer and Tester');
        testUser.put('CompanyName' , 'FinancialForce Test Company PS');

        if (doInsert)
            insert testUser;

        return testUser;
    }
	static c2g__codaBankAccount__c createBankAccount()
    {
        c2g__codaBankAccount__c bankAccount = new c2g__codaBankAccount__c();
        bankAccount.put('Name' , 'Bank Of Ravat');
        bankAccount.put('c2g__ReportingCode__c' , 'UVESRAVAT');
        bankAccount.put('c2g__BankName__c' , 'Bank Of Ravats 2');
        bankAccount.put('c2g__AccountName__c' , 'ves Current Account 2');
        bankAccount.put('c2g__AccountNumber__c' , '12312345');
        bankAccount.put('c2g__SortCode__c' , '10-20-39');
        bankAccount.put('c2g__SWIFTNumber__c' , 'BARCUKTAMA2');
        bankAccount.put('c2g__IBANNumber__c' , 'GBkk BARC 1020 3012 3856 78');
        bankAccount.put('c2g__DirectDebitOriginatorReference__c' , '2222222');
        bankAccount.put('c2g__BankAccountCurrency__c' , testCurrency.id);
        bankAccount.put('c2g__GeneralLedgerAccount__c' , bankAccCurUK.Id);
        bankAccount.put('c2g__BankChargesGLA__c' , bankCharges.Id);
        bankAccount.put('c2g__InterestPaidGLA__c' , bankCharges.Id);
        bankAccount.put('c2g__InterestReceivedGLA__c' , bankInterest.Id);
        insert bankAccount;
        return bankAccount;
    }
    
	static c2g__codaCashEntry__c createCashEntry(Id accId, Id bankAccountId, String paymentType, String paymentMethod, PAYREC2__Payment_Agreement__c testPaymentAgreement)
    {
        c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
        cashEntry.put('c2g__Type__c' , paymentType);
        cashEntry.put('c2g__BankAccount__c' , bankAccountId);
        cashEntry.put('c2g__Account__c' , accId);
        cashEntry.put('c2g__PaymentMethod__c' , paymentMethod);
        cashEntry.put('c2g__Period__c' , currentTestPeriod.id);
        cashEntry.put('c2g__Date__c' , System.today());
        cashEntry.put('c2g__CashEntryCurrency__c' , testCurrency.id);
        cashEntry.put('CurrencyIsoCode' , 'USD');
        cashEntry.ffps_cita__PayonomyPaymentAgreementId__c = testPaymentAgreement.id;
        insert cashEntry;

        return cashEntry;
    }
	static c2g__codaCashEntryLineItem__c createCashEntryLine(Id accId, Id headerId, String accountPaymentMethod)
    {
        c2g__codaCashEntryLineItem__c cashEntryLine = new c2g__codaCashEntryLineItem__c();
        cashEntryLine.put('c2g__Account__c' , accId);
        cashEntryLine.put('c2g__AccountPaymentMethod__c' , accountPaymentMethod);
        cashEntryLine.put('c2g__CashEntry__c' , headerId);
        cashEntryLine.put('c2g__CashEntryValue__c' , 500);
        cashEntryLine.put('c2g__BankAccountValue__c' , 500);
        insert cashEntryLine;

        return cashEntryLine;
    }
    static PAYREC2__Payment_Agreement__c createPaymentAgreement(Account testAccount)
    {
        PAYREC2__Payment_Schedule__c ps = new PAYREC2__Payment_Schedule__c();
        ps.Name = 'testPS';
        ps.PAYREC2__Frequency__c = 'month';
        ps.PAYREC2__Day__c = '5';
        ps.PAYREC2__Interval__c = 3;
        ps.PAYREC2__Type__c = 'Ongoing';
        insert ps;
        
        PAYACCVAL1__Bank_Account__c pba = new PAYACCVAL1__Bank_Account__c();
        pba.PAYACCVAL1__Account_Number__c = '12345678';
        pba.PAYACCVAL1__Sort_Code__c = '124578';
        pba.PAYFISH3__Account_Name__c = testAccount.name;
        insert pba;
        
        PAYREC2__Payment_Agreement__c paymentAgreement = new PAYREC2__Payment_Agreement__c();
        paymentAgreement.PAYREC2__Account__c = testAccount.id;
        paymentAgreement.PAYREC2__Status__c = 'On going';
        paymentAgreement.PAYREC2__Payment_Schedule__c = ps.Id;
        paymentAgreement.PAYREC2__Ongoing_Collection_Amount__c = 200;
        paymentAgreement.PAYFISH3__FTA_Sub_Type__c = '768335';
        paymentAgreement.RecordTypeId = String.valueof(parecid).substring(0,15);
        paymentAgreement.PAYFISH3__Current_Bank_Account__c = pba.id;
        paymentAgreement.PAYFISH3__Fund_Transfer_Agent__c = 'New fund transfer';
        insert paymentAgreement;
        return paymentAgreement;
    }
    
    static PAYBASE2__Payment__c createPayment( PAYREC2__Payment_Agreement__c testPaymentAgreement)
    {
        PAYBASE2__Payment__c payment = new PAYBASE2__Payment__c();
        payment.PAYREC2__Payment_Agreement__c = testPaymentAgreement.id;
        payment.PAYBASE2__Amount__c = 500;
        payment.PAYBASE2__Status__c = 'Errored';
        insert payment;
        return payment;
    }
    public static void setupFFABasedata()
    {
        if (baseDataCreated)
            return;

        createFFAQueue();
        createFFACompany();
        createFFACurrency();
        createFFAPeriod();
        createGLAAccounts();
        baseDataCreated = true;
    }
    /**
        *   Create FFA Queue (FinancialForce)
        *   No @Parms required
    **/
    public static void createFFAQueue()
    {
        //Create queue
        queueMemeber = new Group(Type = 'Queue', Name = 'FinancialForce');
        insert queueMemeber;

        //Create list of all FinancialForce Objctes
        List<String> queueObjectNames =  getQueueObjectNames();

        //Assign Objects to Queue
        List<QueueSObject> newQueueObjects = new List<QueueSObject>();
        for (String queueObjectName : queueObjectNames)
        {
            newQueueObjects.add(new QueueSObject(QueueId = queueMemeber.id, SobjectType = queueObjectName));
        }
        insert newQueueObjects;

        //Assign group to a current user
        GroupMember queueMember = new GroupMember(GroupId = queueMemeber.id, UserOrGroupId = userInfo.getUserId());

        insert queueMember;
    }
    /**
        *   Create FFA Company (FinancialForce Test Company)
        *   No @Parms required
    **/
    public static void createFFACompany()
    {
        testCompany = new c2g__codaCompany__c();
        testCompany.put('Name', 'FinancialForce Test Company');
        testCompany.put('OwnerId', queueMemeber.id);
        testCompany.put('c2g__Street__c', 'Cardale Park');
        testCompany.put('c2g__StateProvince__c', 'Beckwith Head Road');
        testCompany.put('c2g__City__c', 'Harrogate');
        testCompany.put('c2g__ZipPostCode__c', 'HG3 1RY');
        testCompany.put('c2g__Country__c', 'United Kingdom');
        testCompany.put('c2g__Phone__c', '+44 (0)1423 537728)');

        insert  testCompany;

        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
        userCompany.put('c2g__Company__c', testCompany.id);
        userCompany.put('c2g__User__c', userInfo.getUserId());

        insert userCompany;
    }
    /**
        *   Create FFA Currency (USD)
        *   No @Parms required
    **/
    public static void createFFACurrency()
    {
        testCurrency = new c2g__codaAccountingCurrency__c();
        testCurrency.put('Name', 'USD');
        testCurrency.put('OwnerId', queueMemeber.id);
        testCurrency.put('c2g__OwnerCompany__c', testCompany.id);
        testCurrency.put('c2g__UnitOfWork__c', 1);
        testCurrency.put('c2g__DecimalPlaces__c', 2);
        testCurrency.put('c2g__Home__c', true);
        testCurrency.put('c2g__Dual__c', true);

        insert testCurrency;
    }
    /**
        *   Create FFA Year and FFA Period
        *   No @Parms required
    **/
    public static void createFFAPeriod()
    {
        createFFAPeriod('');
    }
    /**
        *   Create FFA Year and FFA Period
        *   One Param required
        *       - String Year - specifies which year to create year and period
    **/
    public static void createFFAPeriod(String year)
    {
        String currentYear;
        if(year == '')
            currentYear = String.valueOf(Date.today().year());      //Get Current Year
        else
            currentYear = year;

        c2g__codaYear__c yr = new c2g__codaYear__c();
        yr.put('Name', currentYear);
        yr.put('c2g__NumberOfPeriods__c', 12);
        yr.put('c2g__AutomaticPeriodList__c', true);
        yr.put('c2g__StartDate__c', Date.valueOf(currentYear + '-01-01 00:00:00'));
        yr.put('c2g__EndDate__c', Date.valueOf(currentYear + '-12-31 00:00:00'));
        yr.put('c2g__PeriodCalculationBasis__c', 'Month End');
        yr.put('OwnerId', queueMemeber.id);
        yr.put('c2g__OwnerCompany__c', testCompany.id);

        insert yr;

        String currentMth = String.valueOf(Date.today().month());
        if(currentMth.length() == 1)
            currentMth = '0' + currentMth;

        List<c2g__codaPeriod__c> periods = new List<c2g__codaPeriod__c>();

        List<String> monthNumbers = new List<String>{'01','02','03','04','05','06','07','08','09','10','11','12','01','12','12'};
        for (String monthNumber : monthNumbers)
        {
            c2g__codaPeriod__c period = new c2g__codaPeriod__c();
            period.put('Name', currentYear + '/' + '0' + monthNumber);
            period.put('c2g__YearName__c', yr.id);
            period.put('c2g__OwnerCompany__c', testCompany.id);
            period.put('c2g__PeriodNumber__c', '0' + monthNumber);
            period.put('c2g__Description__c', 'Trading Period');
            period.put('c2g__StartDate__c', Date.valueOf(currentYear + '-' + monthNumber + '-01 00:00:00'));
            period.put('c2g__EndDate__c', Date.valueOf(currentYear + '-' + monthNumber + '-01 00:00:00').addMonths(1).addDays(-1));
            periods.add(period);

            //returns current period
            if (('0' + monthNumber) == ('0' + currentMth) && currentTestPeriod == null)
                currentTestPeriod = period;
        }
        // fix the opening period
        periods[12].put('Name', currentYear + '/000');
        periods[12].put('c2g__PeriodNumber__c', '000');
        periods[12].put('c2g__Description__c', 'Opening (B/fwd)');
        periods[12].put('c2g__EndDate__c', periods[12].c2g__StartDate__c);

        // fix the closing period
        periods[13].put('Name' , currentYear + '/101');
        periods[13].put('c2g__PeriodNumber__c', '101');
        periods[13].put('c2g__Description__c', 'Closing (C/fwd)');
        periods[13].put('c2g__StartDate__c', periods[13].c2g__EndDate__c);

        // fix the adjustment period
        periods[14].put('Name' , currentYear + '/100');
        periods[14].put('c2g__PeriodNumber__c', '100');
        periods[14].put('c2g__Description__c', 'Adjustment Period');
        periods[14].put('c2g__StartDate__c', periods[14].c2g__EndDate__c);

        insert periods;
    }
    /**
    *   Create GLA Accounts
    *   No @Parms required
    **/
    public static void createGLAAccounts()
    {
        List<c2g__codaGeneralLedgerAccount__c> glaList;

        deferredIncome = new c2g__codaGeneralLedgerAccount__c();
        deferredIncome.put('Name' , '2200 - Deferred Income');
        deferredIncome.put('c2g__ReportingCode__c' , '2200t');
        deferredIncome.put('c2g__Type__c' , 'Balance Sheet');
        deferredIncome.put('c2g__TrialBalance1__c' , 'Balance Sheet');
        deferredIncome.put('c2g__TrialBalance2__c' , 'Current Liabilities');
        deferredIncome.put('c2g__TrialBalance3__c' , 'Accruals and Deferred Income');
        deferredIncome.put('c2g__TrialBalance4__c' , '-');
        deferredIncome.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        deferredIncome.put('c2g__BalanceSheet2__c' , 'Current Liabilities');
        deferredIncome.put('c2g__BalanceSheet3__c' , 'Accruals and Deferred Income');

        accountsPayableControl = new c2g__codaGeneralLedgerAccount__c();
        accountsPayableControl.put('Name' , '2000 - Accounts Payable Control');
        accountsPayableControl.put('c2g__ReportingCode__c' , '2000t');
        accountsPayableControl.put('c2g__Type__c' , 'Balance Sheet');
        accountsPayableControl.put('c2g__TrialBalance1__c' , 'Balance Sheet');
        accountsPayableControl.put('c2g__TrialBalance2__c' , 'Current Liabilities');
        accountsPayableControl.put('c2g__TrialBalance3__c' , 'Creditors');
        accountsPayableControl.put('c2g__TrialBalance4__c' , '-');
        accountsPayableControl.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        accountsPayableControl.put('c2g__BalanceSheet2__c' , 'Current Liabilities');
        accountsPayableControl.put('c2g__BalanceSheet3__c' , 'Creditors');

        accountsReceivableControl = new c2g__codaGeneralLedgerAccount__c();
        accountsReceivableControl.put('Name' , '1200 - Accounts Receivable Control');
        accountsReceivableControl.put('c2g__ReportingCode__c' , '1200t');
        accountsReceivableControl.put('c2g__Type__c' , 'Balance Sheet');
        accountsReceivableControl.put('c2g__TrialBalance1__c' , 'Balance Sheet');
        accountsReceivableControl.put('c2g__TrialBalance2__c' , 'Current Assets');
        accountsReceivableControl.put('c2g__TrialBalance3__c' , 'Debtors');
        accountsReceivableControl.put('c2g__TrialBalance4__c' , '-');
        accountsReceivableControl.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        accountsReceivableControl.put('c2g__BalanceSheet2__c' , 'Current Assets');
        accountsReceivableControl.put('c2g__BalanceSheet3__c' , 'Debtors');

        grossRevenue = new c2g__codaGeneralLedgerAccount__c();
        grossRevenue.put('Name' , '4000 - Gross revenue');
        grossRevenue.put('c2g__ReportingCode__c' , '4000t');
        grossRevenue.put('c2g__Type__c' , 'Profit and Loss');
        grossRevenue.put('c2g__TrialBalance1__c' , 'Profit and Loss');
        grossRevenue.put('c2g__TrialBalance2__c' , 'Gross Profit');
        grossRevenue.put('c2g__TrialBalance3__c' , 'Sales Revenue');
        grossRevenue.put('c2g__TrialBalance4__c' , 'Sales - Direct');
        grossRevenue.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        grossRevenue.put('c2g__BalanceSheet2__c' , 'Profit and Loss');
        grossRevenue.put('c2g__BalanceSheet3__c' , '-');

        //Bank Account - Current UK
        bankAccCurUK = new c2g__codaGeneralLedgerAccount__c();
        bankAccCurUK.put('Name' , 'Bank Account - Current UK');
        bankAccCurUK.put('c2g__ReportingCode__c' , 'BNK001 UKt');
        bankAccCurUK.put('c2g__Type__c' , 'Balance Sheet');
        bankAccCurUK.put('c2g__TrialBalance1__c' , 'Balance Sheet');
        bankAccCurUK.put('c2g__TrialBalance2__c' , 'Current Assets');
        bankAccCurUK.put('c2g__TrialBalance3__c' , 'Bank and Cash');
        bankAccCurUK.put('c2g__TrialBalance4__c' , '');
        bankAccCurUK.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        bankAccCurUK.put('c2g__BalanceSheet2__c' , 'Current Assets');
        bankAccCurUK.put('c2g__BalanceSheet3__c' , 'Bank and Cash');

        //Bank Charges
        bankCharges = new c2g__codaGeneralLedgerAccount__c();
        bankCharges.put('Name' , 'Bank Charges');
        bankCharges.put('c2g__ReportingCode__c' , 'ADM007t');
        bankCharges.put('c2g__Type__c' , 'Profit and Loss');
        bankCharges.put('c2g__TrialBalance1__c' , 'Profit and Loss');
        bankCharges.put('c2g__TrialBalance2__c' , 'Operating Expenses');
        bankCharges.put('c2g__TrialBalance3__c' , 'Administration Costs');
        bankCharges.put('c2g__TrialBalance4__c' , '');
        bankCharges.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        bankCharges.put('c2g__BalanceSheet2__c' , 'Current Assets');
        bankCharges.put('c2g__BalanceSheet3__c' , 'Profit and Loss');

        //Bank Charges
        bankInterest = new c2g__codaGeneralLedgerAccount__c();
        bankInterest.put('Name' , 'Bank Interest');
        bankInterest.put('c2g__ReportingCode__c' , 'FIN005t');
        bankInterest.put('c2g__Type__c' , 'Profit and Loss');
        bankInterest.put('c2g__TrialBalance1__c' , 'Profit and Loss');
        bankInterest.put('c2g__TrialBalance2__c' , 'Interest and Taxation');
        bankInterest.put('c2g__TrialBalance3__c' , 'Finance Costs');
        bankInterest.put('c2g__TrialBalance4__c' , '');
        bankInterest.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        bankInterest.put('c2g__BalanceSheet2__c' , 'Current Assets');
        bankInterest.put('c2g__BalanceSheet3__c' , 'Profit and Loss');

        //Tax Code
        salesTaxA = new c2g__codaGeneralLedgerAccount__c();
        salesTaxA.put('Name' , '2160 - Sales Tax A');
        salesTaxA.put('c2g__ReportingCode__c' , '2160t');
        salesTaxA.put('c2g__Type__c' , 'Balance Sheet');
        salesTaxA.put('c2g__TrialBalance1__c' , 'Balance Sheet');
        salesTaxA.put('c2g__TrialBalance2__c' , 'Current Liabilities');
        salesTaxA.put('c2g__TrialBalance3__c' , 'Tax Liability');
        salesTaxA.put('c2g__TrialBalance4__c' , '');
        salesTaxA.put('c2g__BalanceSheet1__c' , 'Balance Sheet');
        salesTaxA.put('c2g__BalanceSheet2__c' , 'Current Liabilities');
        salesTaxA.put('c2g__BalanceSheet3__c' , 'Tax Liability');

        glaList = new List<c2g__codaGeneralLedgerAccount__c>{accountsPayableControl, accountsReceivableControl, grossRevenue, bankAccCurUK, bankCharges, bankInterest, deferredIncome, salesTaxA};
        insert glaList;
    }
    /**
    *   Create or Insert Account
    *   No @Parms required
    **/
    public static Account createAccount()
    {
        Account productServices = new Account();
        productServices.put('Name', '$$$$$$$Product Services$$$$$$$');
        productServices.put('CurrencyIsoCode', 'USD');
        productServices.put('AccountNumber', 'CD656092');
        productServices.put('c2g__CODAAccountTradingCurrency__c', 'USD');
        productServices.put('Type', 'Customer - Direct');
        productServices.put('Industry', 'Apparel');
        productServices.put('AnnualRevenue', 350000000);
        productServices.put('Ownership', 'Public');
        productServices.put('Rating', 'Warm');
        productServices.put('Phone', '(336) 222-7000');
        productServices.put('Fax', '(336) 222-8000');
        productServices.put('Website', 'http://www.financialforce.com');
        productServices.put('TickerSymbol', 'BTXT');
        productServices.put('NumberOfEmployees', 9000);
        productServices.put('SIC', '546732');
        productServices.put('c2g__CODAReportingCode__c', 'ABC123t');
        productServices.put('c2g__CODAAccountsReceivableControl__c', accountsReceivableControl.Id);
        productServices.put('c2g__CODAAccountsPayableControl__c', accountsPayableControl.Id);
        productServices.put('c2g__CODASalesTaxStatus__c', 'Exempt');
        productServices.put('c2g__CODAVATStatus__c', 'EC Registered');
        productServices.put('c2g__CODAECCountryCode__c', 'FR');
        productServices.put('c2g__CODAVATRegistrationNumber__c', '123 43223 3');
        productServices.put('c2g__CODATaxCalculationMethod__c', 'Gross');
        productServices.put('c2g__CODAInvoiceEmail__c', 'productservices@financialforce.com');
        productServices.put('c2g__CODADescription1__c', 'Standard Terms');
        productServices.put('c2g__CODADaysOffset1__c', 30);
        productServices.put('c2g__CODABaseDate1__c', 'Invoice Date');
        productServices.put('c2g__CODADiscount1__c', 0);
        
            insert productServices;

        return productServices;
    }
    /**
        *   Create List of Object Queue Names
        *   No @Parms required
    **/
    private static List<String> getQueueObjectNames()
    {
        List<String> objectNames = new List<String>();

        //Financial Objects
        objectNames.add('c2g__codaCompany__c');
        objectNames.add('c2g__codaYear__c');
        objectNames.add('c2g__codaCurrencyRevaluation__c');
        objectNames.add('c2g__ReportingBalance__c');
        objectNames.add('c2g__codaBudget__c');
        objectNames.add('c2g__codaBankAccount__c');
        objectNames.add('c2g__codaBankStatement__c');
        objectNames.add('c2g__codaPaymentMediaControl__c');
        objectNames.add('c2g__codaBankReconciliation__c');
        objectNames.add('c2g__codaPaymentMediaSummary__c');
        objectNames.add('c2g__codaMatchingReference__c');
        objectNames.add('c2g__codaAccountingCurrency__c');
        objectNames.add('c2g__codaGroupingReference__c');
        objectNames.add('c2g__codaPaymentTemplate__c');

        //Document Objects
        objectNames.add('c2g__codaTransaction__c');
        objectNames.add('c2g__codaInvoice__c');
        objectNames.add('c2g__codaJournal__c');
        objectNames.add('c2g__codaCreditNote__c');
        objectNames.add('c2g__codaCashEntry__c');
        objectNames.add('c2g__codaPurchaseInvoice__c');
        objectNames.add('c2g__codaPurchaseCreditNote__c');
        objectNames.add('c2g__codaPayment__c');
        objectNames.add('c2g__CancelPayment__c');
        objectNames.add('c2g__codaCashMatchingHistory__c');

        //Random Objects
        objectNames.add('c2g__codaTextDefinition__c');
        objectNames.add('c2g__codaIntercompanyDefinition__c');
        objectNames.add('c2g__AsOfAging__c');
        objectNames.add('c2g__codaIntercompanyTransfer__c');
        objectNames.add('c2g__codaYear__c');
        
        return objectNames;
    }
}