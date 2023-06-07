@isTest
global with sharing class SMP_DDServiceHandlerTest
{
    @isTest
    global static void GetNextCollectionDate() {
        SMP_DDServiceNextCollectionModel model = new SMP_DDServiceNextCollectionModel();
        String responseBody = '{"CollectionDateResult":{"CollectionDate":"2017-05-11","Error":""}}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModel response = SMP_DDServiceHandler.getNextCollectionDate('1', Date.Today(), 'Monthly', '5');
        Test.stopTest();
        System.assertEquals('2017-05-11', response.CollectionDateResult.CollectionDate);
    }
    @isTest
    global static void GetNextCollectionDateWrapper() {
        SMP_DDServiceNextCollectionModel model = new SMP_DDServiceNextCollectionModel();
        String responseBody = '{"CollectionDateResult":{"CollectionDate":"2017-05-11","Error":""}}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock (200, responseBody);
        SMP_DDServiceHandler.SingleCollectionDateWrapper collectionWrapper = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        collectionWrapper.CollectionDay = '1';
        collectionWrapper.StartDate = string.valueOf(Date.today());
        collectionWrapper.CollectionPeriod = 'Monthly';
        collectionWrapper.NumberOfDaysToWaitFromNewInstruction = '5';
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModel response = SMP_DDServiceHandler.getNextCollectionDate(collectionWrapper);
        Test.stopTest();
        System.assertEquals('2017-05-11', response.CollectionDateResult.CollectionDate);
    }
    @isTest
    global static void GetNextCollectionDateList() {
        SMP_DDServiceNextCollectionModelList model = new SMP_DDServiceNextCollectionModelList();
        String responseBody = '{"CollectionDatesResult":[{"Error":"","CollectionDate":"2017-05-11"},{"Error":"","CollectionDate":"2017-05-11"}]}';
        
        List<SMP_DDServiceHandler.SingleCollectionDateWrapper> cdWrapperList = new List<SMP_DDServiceHandler.SingleCollectionDateWrapper>();
        SMP_DDServiceHandler.SingleCollectionDateWrapper collectionWrapper = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        collectionWrapper.CollectionDay = '1';
        collectionWrapper.StartDate = string.valueOf(Date.today());
        collectionWrapper.CollectionPeriod = 'Monthly';
        collectionWrapper.NumberOfDaysToWaitFromNewInstruction = '5';
        cdWrapperList.add(collectionWrapper);

        SMP_DDServiceHandler.SingleCollectionDateWrapper collectionWrapper2 = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        collectionWrapper2.CollectionDay = '1';
        collectionWrapper2.StartDate = string.valueOf(Date.today());
        collectionWrapper2.CollectionPeriod = 'Monthly';
        collectionWrapper2.NumberOfDaysToWaitFromNewInstruction = '5';
        cdWrapperList.add(collectionWrapper2);

        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModelList response = SMP_DDServiceHandler.getNextCollectionDate(cdWrapperList);
        Test.stopTest();
        System.assertEquals('2017-05-11', response.CollectionDatesResult[0].CollectionDate);
    }
    @isTest
    global static void GetNextCollectionDate_ErrorInCallout() {
        String responseBody = '{"CollectionDateResult":{"CollectionDate":"2017-05-11","Error":""}}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock (300, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModel response = SMP_DDServiceHandler.getNextCollectionDate('1', Date.Today(), 'Monthly', '5');
        Test.stopTest();
        System.assertEquals('Error Calling SmarterPay Service. 300 null', response.Error);
    }
    @isTest
    global static void GetBankDetails() {

        String responseBody = '{"Modulus_Check":{"AccountCodeOK":true,"Error":"","Telephone":"0345 7345345","account_number":"55779911","bank_address1":"","bank_address2":"","bank_address3":"","bank_address4":"","bank_addressPostCode":"LE87 2BB","bank_addressTown":"Leicester","bank_name":"BARCLAYS BANK PLC","branch_title":"1 CHURCHILL  PLACE","credits_allowed":true,"direct_debit_Instruction_ok":true,"direct_debits":true,"sort_code":"200000","sort_code_ok":true}}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceBankAccountModel response = SMP_DDServiceHandler.getBankDetails('110011', '12345678');
        Test.stopTest();
        System.assertEquals('BARCLAYS BANK PLC', response.Modulus_Check.bank_name);
    }
    @isTest
    global static void testListParse() {
        String json = '{\"CollectionDatesResult\":[{\"Error\":\"\",\"CollectionDate\":\"2019-12-02\"},{\"Error\":\"\",\"CollectionDate\":\"2020-01-02\"},{\"Error\":\"\",\"CollectionDate\":\"2020-02-03\"},{\"Error\":\"\",\"CollectionDate\":\"2020-03-02\"},{\"Error\":\"\",\"CollectionDate\":\"2020-04-01\"},{\"Error\":\"\",\"CollectionDate\":\"2020-05-01\"},{\"Error\":\"\",\"CollectionDate\":\"2020-06-01\"},{\"Error\":\"\",\"CollectionDate\":\"2020-07-01\"},{\"Error\":\"\",\"CollectionDate\":\"2020-08-03\"},{\"Error\":\"\",\"CollectionDate\":\"2020-09-01\"},{\"Error\":\"\",\"CollectionDate\":\"2020-10-01\"},{\"Error\":\"\",\"CollectionDate\":\"2020-11-02\"},{\"Error\":\"\",\"CollectionDate\":\"2020-12-01\"},{\"Error\":\"\",\"CollectionDate\":\"2021-01-01\"}]}';
        SMP_DDServiceNextCollectionModelList obj = SMP_DDServiceNextCollectionModelList.parse(json);
        System.assert(obj != null);
    }
}