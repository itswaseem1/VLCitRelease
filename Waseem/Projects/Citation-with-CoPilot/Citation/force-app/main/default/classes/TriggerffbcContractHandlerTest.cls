@isTest
private class TriggerffbcContractHandlerTest{

    @testSetup
    static void setup(){
        Id CustomerrecordTypeId;
        Schema.RecordTypeInfo rti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer');
        if(rti != null){
            CustomerrecordTypeId = rti.getRecordTypeId();
            }
        
        account a = new account(name='test', recordTypeId = CustomerrecordTypeId) ;
        insert a;

        fferpcore__Company__c c = new fferpcore__Company__c(name='test') ;
        insert c ;

        Contact contact = new Contact(AccountId = a.Id, LastName = 'Test', Email='test@test.com');
        insert contact;

        contract sCon = new contract(AccountId=a.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, startdate = date.today() , Agreement_Type__c = 'Auto', CustomerSignedId = contact.Id) ;
        insert sCon ;

        ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id, SF_Contract__c = sCon.Id) ;
        insert cont ;
        
        product2  p1 = new product2(name = 'a',isactive = true) ;
        insert p1 ;


        ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c='MB') ;
        insert sd ;
        
        date d = date.today().adddays(7) ;
        ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(service_start_date__c = date.today(), service_end_date__c = date.today(),ffbc__Quantity__c  =3,ffbc__SalesPriceOverride__c=199.99,ffbc__Contract__c = cont.id, ffbc__ProductService__c = p1.id,ffbc__BillingTerm__c=sd.id,ffbc__FirstBillDate__c=d , ffbc__BillingType__c= 'Recurring Fixed')  ;
        insert l ;

        c2g__codaGeneralLedgerAccount__c gl = new c2g__codaGeneralLedgerAccount__c();
        gl.Name = '45100 - Trade Debtors Control';
        gl.Account_Description__c = 'Trade Debtors Control';
        gl.c2g__ReportingCode__c = '45100';
        gl.c2g__ExternalId__c = '45100 - Trade Debtors Control';
        gl.Sub_Ledger_Required__c = 'Tax';
        gl.c2g__TrialBalance1__c = 'Balance Sheet';
        gl.c2g__Type__c = 'Balance Sheet';
        gl.c2g__TrialBalance2__c = 'Current Assets';
        gl.c2g__TrialBalance3__c = 'Trade debtors';
        insert gl;

        c2g__codaTaxCode__c tc = new c2g__codaTaxCode__c();
        tc.c2g__ExternalId__c = 'GB-O-STD';
        tc.CurrencyIsoCode = 'GBP';
        tc.ffvat__NetBox__c = 'Box 6';
        tc.ffvat__TaxBox__c = 'Box 1';
        tc.c2g__Description__c = 'UK Output Standard Rated';
        tc.c2g__GeneralLedgerAccount__c = gl.Id;
        insert tc;

        c2g__codaTaxCode__c tc1 = new c2g__codaTaxCode__c();
        tc1.c2g__ExternalId__c = 'GB-I-STD';
        tc1.CurrencyIsoCode = 'GBP';
        tc1.ffvat__NetBox__c = 'Box 7';
        tc1.ffvat__TaxBox__c = 'Box 4';
        tc1.c2g__Description__c = 'UK Input Standard Rated';
        tc1.c2g__GeneralLedgerAccount__c = gl.Id;
        insert tc1;
        
        
    }
    
    @isTest static void populateFinancialForceFieldsOnAccountTest() {
        // Implement test code
        System.assertEquals([select count() from ffbc__contract__c], 1);

        Test.startTest();
        ffbc__contract__c contract = [select Id, ffbc__Status__c from ffbc__contract__c limit 1];
        ffbc__ContractLineItem__c l = [select Id from ffbc__ContractLineItem__c limit 1];

        System.assertEquals(contract.ffbc__Status__c, 'Draft');

        ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
        request.ContractIds = new Set<Id>{contract.id};
        request.MonthsToGenerate = 0;
        
        ffbc.ContractsService.activation(request);

        System.assertEquals([select Id, ffbc__Status__c from ffbc__Contract__c limit 1].ffbc__Status__c, 'Active');

        ffbc__billingSchedule__c bs1 = new ffbc__billingSchedule__c(ffbc__ContractLineItem__c = l.id,ffbc__BillingDate__c=date.today(),ffbc__BillingPeriodEndDate__c=date.today().adddays(365),ffbc__BillingPeriodStartDate__c=date.today()) ;
        insert bs1 ;

        System.assertNotEquals([select Id, c2g__CODAAccountTradingCurrency__c from Account limit 1].c2g__CODAAccountTradingCurrency__c, null);
        Test.stopTest();
    }

    @isTest static void populateInvoiceEmailTest(){
        System.assertEquals([select count() from ffbc__contract__c], 1);

        Test.startTest();
        ffbc__contract__c contract = [select Id, ffbc__Status__c from ffbc__contract__c limit 1];
        ffbc__ContractLineItem__c l = [select Id from ffbc__ContractLineItem__c limit 1];

        System.assertEquals([select Id, c2g__CODAInvoiceEmail__c from Account limit 1].c2g__CODAInvoiceEmail__c, null);
        System.assertEquals(contract.ffbc__Status__c, 'Draft');

        ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
        request.ContractIds = new Set<Id>{contract.id};
        request.MonthsToGenerate = 0;
        
        ffbc.ContractsService.activation(request);

        System.assertEquals([select Id, ffbc__Status__c from ffbc__Contract__c limit 1].ffbc__Status__c, 'Active');
        System.assertEquals([select Id, c2g__CODAInvoiceEmail__c from Account limit 1 ].c2g__CODAInvoiceEmail__c, 'test@test.com');
    }

    @isTest static void populateInvoiceEmailTestFalse(){
        System.assertEquals([select count() from ffbc__contract__c], 1);

        Test.startTest();
        ffbc__contract__c contract = [select Id, ffbc__Status__c from ffbc__contract__c limit 1];
        ffbc__ContractLineItem__c l = [select Id from ffbc__ContractLineItem__c limit 1];
        Account account = [select Id, c2g__CODAInvoiceEmail__c from Account limit 1];
        account.c2g__CODAInvoiceEmail__c = 'test@test1.com';
        update account;

        System.assertEquals([select Id, c2g__CODAInvoiceEmail__c from Account limit 1].c2g__CODAInvoiceEmail__c, 'test@test1.com');
        System.assertEquals(contract.ffbc__Status__c, 'Draft');

        ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
        request.ContractIds = new Set<Id>{contract.id};
        request.MonthsToGenerate = 0;
        
        ffbc.ContractsService.activation(request);

        System.assertEquals([select Id, ffbc__Status__c from ffbc__Contract__c limit 1].ffbc__Status__c, 'Active');
        System.assertEquals([select Id, c2g__CODAInvoiceEmail__c from Account limit 1 ].c2g__CODAInvoiceEmail__c, 'test@test1.com');
    }
    
    @isTest static void testBillingContracts(){
        Account acc = new Account(name='Test2');
        acc.AnnualRevenue = 75000;
        insert acc;
        Contact con=new Contact();
        con.LastName='Test Con';
        con.AccountId=acc.Id;
        con.CurrencyIsoCode='GBP';
        con.Email='test@test.com';
        Test.startTest();
        insert con;
        ffbc__SoftDate__c softdate=new ffbc__SoftDate__c();
        softdate.Name='Monthly';
        softdate.ffbc__Definition__c='+1M';
        insert softdate;
        //List<Product2> prodPAT = TestDataFactory.getProducts('Atlas UpSkill','Monthly Flat Phased - Contract');
        Product2 pro1 = new Product2();
            pro1.Name = 'Atlas UpSkill';
            pro1.Product_Grouping__c = 'Monthly Flat Phased - Contract';
            pro1.ProductCode='AUS';
            pro1.isActive=true;
            insert pro1;
        
        Contract contract=new Contract();
        contract.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E-Commerce').getRecordTypeId();
        contract.Name='Test Contract';
        contract.AccountId=acc.Id;
        contract.Status='Draft';
        contract.Renewal_Type__c='Auto';
        contract.Agreement_Type__c='E-Commerce';
        contract.Business_Type__c='New Business';
        contract.StartDate=System.today();
        contract.ContractTerm=12;
        contract.FOC_Period_Mths__c=0;
        contract.FOC_Period_Mths_End__c=0;
        contract.Contract_Value__c=900;
        contract.Payment_Period__c='monthly';
        contract.Preferred_Payment_Date__c='7';
        contract.CustomerSignedId=con.Id;
        contract.Initial_Payment_Date__c=System.today();
        contract.Initial_Payment2__c=75;
        
        insert contract;
        contract.status='Active';
        update contract;
        Test.stopTest();
    }
    
}