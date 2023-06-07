@isTest
public class TriggerAccountHandlerTest {

    public @TestSetup static void createTestData(){
        List<Account> acctList=new List<Account>();
        for(Integer i=0;i<100;i++){
            Account acct=new Account();
            acct.Name='Test Account'+i;
            acct.CurrencyIsoCode='GBP';
            acct.Reason_1__c='Auto Renewal';
            acct.Reason_2__c='HR Advice';
            acct.Reason_3__c='HS Advice';
            acctList.add(acct);
        }
        insert acctList;
        
        c2g__codaGeneralLedgerAccount__c gla1 = new c2g__codaGeneralLedgerAccount__c(name='test1',c2g__ExternalId__c=System.label.Supplier_Account_Payable_Control,c2g__ReportingCode__c='51100',c2g__Type__c='Balance Sheet') ;
        insert gla1 ;

        c2g__codaGeneralLedgerAccount__c gla2 = new c2g__codaGeneralLedgerAccount__c(name='test2',c2g__ExternalId__c='gla seed record1',c2g__ReportingCode__c='51100i',c2g__Type__c='Balance Sheet') ;
        insert gla2 ;

        c2g__codaGeneralLedgerAccount__c gla3 = new c2g__codaGeneralLedgerAccount__c(name='test3',c2g__ExternalId__c='gla seed record2',c2g__ReportingCode__c='51100o',c2g__Type__c='Balance Sheet') ;
        insert gla3 ;

        c2g__codaTaxCode__c inputTaxCode = new c2g__codaTaxCode__c(c2g__ExternalId__c=System.label.Input_Vat_Code,name='GB-I-STD',c2g__GeneralLedgerAccount__c=gla2.id) ;
        c2g__codaTaxCode__c outputTaxCode = new c2g__codaTaxCode__c(c2g__ExternalId__c=System.label.Output_Vat_Code,name='GB-O-STD',c2g__GeneralLedgerAccount__c=gla3.id) ;
        
        insert inputTaxCode ;
        insert outputTaxCode ;
    }

    public testMethod static void TestSupplierAccountFields() {
        RecordType supplierRecordType = [select id from recordType where sObjectType = 'Account' and name = 'Supplier'] ;
        Account supplierAccount = new Account(name='Test Account',recordTypeId = supplierRecordType.id) ;

        test.startTest() ;           
            insert supplierAccount ;  
        test.stoptest() ;

        account checkAccount = [select id,c2g__CODAAccountTradingCurrency__c, c2g__CODABillingMethod__c, c2g__CODAAccountsPayableControl__c,c2g__CODAInputVATCode__c,
                                c2g__CODAOutputVATCode__c, c2g__CODATaxCalculationMethod__c, c2g__CODAVATStatus__c, c2g__CODAECCountryCode__c from account where id = :supplierAccount.id] ;

        system.assertEquals(System.label.Billing_Method,checkAccount.c2g__CODABillingMethod__c) ;
        system.assertEquals(System.label.Account_Currency,checkAccount.c2g__CODAAccountTradingCurrency__c) ;
        system.assertEquals(System.label.Tax_Calculation_Method,checkAccount.c2g__CODATaxCalculationMethod__c) ;
        system.assertEquals(System.label.VAT_Status,checkAccount.c2g__CODAVATStatus__c) ;
        system.assertEquals(System.label.Country_Code,checkAccount.c2g__CODAECCountryCode__c) ;
        system.assertEquals([select id from c2g__codaTaxCode__c where c2g__ExternalId__c = :System.label.Input_Vat_Code].id, checkAccount.c2g__CODAInputVATCode__c ) ;
        system.assertEquals([select id from c2g__codaTaxCode__c where c2g__ExternalId__c = :System.label.Output_Vat_Code].id, checkAccount.c2g__CODAOutputVATCode__c ) ;
        system.assertEquals([select id from c2g__codaGeneralLedgerAccount__c where c2g__ExternalId__c=:System.label.Supplier_Account_Payable_Control].id,checkAccount.c2g__CODAAccountsPayableControl__c) ;
    }

    public testMethod static void TestDontCopySupplierAccountFields() {
        RecordType NotsupplierRecordType = [select id from recordType where sObjectType = 'Account' and name = 'Customer'] ;
        Account NotsupplierAccount = new Account(name='Test Account',recordTypeId = NotsupplierRecordType.id) ;

        test.startTest() ;           
            insert NotsupplierAccount ;           
        test.stoptest() ;

        account checkAccount = [select id,c2g__CODAAccountTradingCurrency__c, c2g__CODABillingMethod__c, c2g__CODAAccountsPayableControl__c,c2g__CODAInputVATCode__c,
                                c2g__CODAOutputVATCode__c, c2g__CODATaxCalculationMethod__c, c2g__CODAVATStatus__c, c2g__CODAECCountryCode__c from account where id = :NotsupplierAccount.id] ;

        system.assertEquals(System.label.Billing_Method,checkAccount.c2g__CODABillingMethod__c) ; 
        system.assertEquals(System.label.Tax_Calculation_Method,checkAccount.c2g__CODATaxCalculationMethod__c) ;
        system.assertEquals(System.label.VAT_Status,checkAccount.c2g__CODAVATStatus__c) ;

        system.assertNotEquals(System.label.Account_Currency,checkAccount.c2g__CODAAccountTradingCurrency__c) ;       
        system.assertNotEquals(System.label.Country_Code,checkAccount.c2g__CODAECCountryCode__c) ;
        system.assertNotEquals([select id from c2g__codaTaxCode__c where c2g__ExternalId__c = :System.label.Input_Vat_Code].id, checkAccount.c2g__CODAInputVATCode__c ) ;
        system.assertNotEquals([select id from c2g__codaTaxCode__c where c2g__ExternalId__c = :System.label.Output_Vat_Code].id, checkAccount.c2g__CODAOutputVATCode__c ) ;
        system.assertNotEquals([select id from c2g__codaGeneralLedgerAccount__c where c2g__ExternalId__c=:System.label.Supplier_Account_Payable_Control].id,checkAccount.c2g__CODAAccountsPayableControl__c) ;
    }
}