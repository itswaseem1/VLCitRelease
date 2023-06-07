@isTest
public with sharing class SMP_DirectDebitSetup_ControllerTest
{
    @isTest
    private static void test_getCustomMetaType() {
                
        SmarterPay_Direct_Debit_Setting__mdt response = SMP_DirectDebitSetup_Controller.getCustomMetaType();
    }

    @isTest
    private static void modulusCheckDirectDebitDateTest() {
        
        String responseBody = '{"Modulus_Check":{"AccountCodeOK":true,"Error":"","Telephone":"0345 7345345","account_number":"55779911","bank_address1":"","bank_address2":"","bank_address3":"","bank_address4":"","bank_addressPostCode":"LE87 2BB","bank_addressTown":"Leicester","bank_name":"BARCLAYS BANK PLC","branch_title":"1 CHURCHILL  PLACE","credits_allowed":true,"direct_debit_Instruction_ok":true,"direct_debits":true,"sort_code":"200000","sort_code_ok":true}}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        String sortCode = '074456';
        String accountNumber = '11104102';

        Income_Direct_Debit__c dd = new Income_Direct_Debit__c();

        dd.DD_Bank_Sort_Code__c = sortCode;
        dd.DD_Bank_Account_Number__c = accountNumber;
        
        Income_Direct_Debit__c response = SMP_DirectDebitSetup_Controller.modulusCheckDirectDebit(dd);

        System.assertEquals(true, response.DD_Account_Number_OK__c);
        System.assertEquals(true, response.DD_Sort_Code_OK__c);
    }

    @isTest
    private static void modulusCheckDirectDebitDateTest_ErrorReturned() {
        
        String responseBody = '{"Modulus_Check":{"AccountCodeOK":true,"Error":"Test Error","Telephone":"0345 7345345","account_number":"55779911","bank_address1":"","bank_address2":"","bank_address3":"","bank_address4":"","bank_addressPostCode":"LE87 2BB","bank_addressTown":"Leicester","bank_name":"BARCLAYS BANK PLC","branch_title":"1 CHURCHILL  PLACE","credits_allowed":true,"direct_debit_Instruction_ok":true,"direct_debits":true,"sort_code":"200000","sort_code_ok":true}}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        String sortCode = '074456';
        String accountNumber = '11104102';

        Income_Direct_Debit__c dd = new Income_Direct_Debit__c();

        dd.DD_Bank_Sort_Code__c = sortCode;
        dd.DD_Bank_Account_Number__c = accountNumber;
        
        try {
            Income_Direct_Debit__c response = SMP_DirectDebitSetup_Controller.modulusCheckDirectDebit(dd);
        } catch (SMP_Exception smpe) {
            System.assert(smpe.getMessage().contains('Test Error'));
        }
    }

    @isTest
    private static void fieldsTest() 
    {
        System.assertNotEquals(null, SMP_DirectDebitSetup_Controller.getFields('New_Direct_Debit_Form_Additional_Fields'));
    }

    @isTest
    private static void testcreateDirectDebit() {       

        String responseBody = '{"CollectionDatesResult":[{"Error":"","CollectionDate":"2022-05-07", "request_collectionday":"7"},{"Error":"","CollectionDate":"2022-11-14", "request_collectionday":"14"},{"Error":"","CollectionDate":"2022-05-21", "request_collectionday":"21"},{"Error":"","CollectionDate":"2022-11-28", "request_collectionday":"28"}]}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock (200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        SMP_Citation_Test_Helper.generateCustomSettings();
        SMP_Citation_Test_Helper.createFinancialForceData();

        Contact member = new Contact();//TestDataCreator.generateMember();
        member.FirstName = 'testFirst';
        member.LastName = 'testLast';
        member.Email = 'test@test.com';
        insert member;

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(Contact__c = member.Id, 
                                                                            DD_Bank_Account_Number__c = '00000000', 
                                                                            DD_Bank_Sort_Code__c = '000000', 
                                                                            DD_Collection_Day__c='7',
                                                                            Company__c = SMP_Citation_Test_Helper.company.Id);
        // insert testDirectDebit;
        Test.startTest();
        SMP_DirectDebitSetup_Controller.createDirectDebit('1', 'Monthly', '5', '2020-09-01', testDirectDebit);
        Test.stopTest();
    }
 }