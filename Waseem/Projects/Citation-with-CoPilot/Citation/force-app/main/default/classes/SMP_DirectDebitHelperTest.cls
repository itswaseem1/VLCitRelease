@isTest
global with sharing class SMP_DirectDebitHelperTest
{
    global static List<Income_Debit_History__c> createTestHistories()
    {
        List<Income_Debit_History__c> testHistories = new List<Income_Debit_History__c>();
        
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'New Instruction', DD_Stage__c = 'Submitted', DD_Code__c = 'ADDACS-01'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'New Instruction', DD_Stage__c = 'Successful', DD_Code__c = 'ADDACS-02'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'New Instruction', DD_Stage__c = 'Failed', DD_Code__c = 'ADDACS-03'));

        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Collection', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-01'));        
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Collection', DD_Stage__c = 'Successful', DD_Code__c = 'ARRUD-02'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Collection', DD_Stage__c = 'Failed', DD_Code__c = 'ARRUD-03'));

        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Ongoing Collection', DD_Stage__c = 'Successful', DD_Code__c = 'ARRUD-01'));

        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Final Collection', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-02'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Represent', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-03'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Second Represent', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-01'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Third Represent', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-02'));

        return testHistories;
    }
    
    global static List<Income_Direct_Debit__c> createTestDirectDebit()
    {
        List<Income_Direct_Debit__c> testDDs = new List<Income_Direct_Debit__c>();
        
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'New Instruction'));
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'New Instruction'));
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'New Instruction'));

        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'First Collection'));        
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'First Collection'));
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'First Collection'));

        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'Ongoing Collection'));

        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'Final Collection'));
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'First Represent'));
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'Second Represent'));
        testDDs.add(new Income_Direct_Debit__c(DD_Status__c = 'Third Represent'));

        return testDDs;
    }

    @isTest static void testGetParentDirectDebitsFromHistories() {
        Contact member = new Contact();
        member.FirstName = 'testFirst';
        member.LastName = 'testLast';
        member.Email = 'test@test.com';
        insert member;


        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(Contact__c = member.Id, DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert testDirectDebit;

        Income_Debit_History__c testDirectDebitHistory = new Income_Debit_History__c(Income_Direct_Debit__c = testDirectDebit.Id);

        Map<Id, Income_Direct_Debit__c> returnedDirectDebits = SMP_DirectDebitHelper.getParentDirectDebitsFromHistories(new List<Income_Debit_History__c>{testDirectDebitHistory});

        System.assertEquals(1, returnedDirectDebits.Size());
    }

    @isTest static void testGetNewInstructions() {
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getNewInstructions(testHistories, null);

        System.assertEquals(3, returnedHistories.Size());        
    }

    @isTest static void testGetNewInstructionsByStage() {
        List<Income_Debit_History__c> testHistories = createTestHistories();

        Set<String> submittedStages = new Set<String>();
        submittedStages.add('Submitted');

        Set<String> successfulStages = new Set<String>();
        successfulStages.add('Successful');

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getNewInstructionsByStage(testHistories, null, submittedStages);

        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('Submitted', returnedHistories[0].DD_Stage__c);

        returnedHistories = SMP_DirectDebitHelper.getNewInstructionsByStage(testHistories, null, successfulStages);
        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('Successful', returnedHistories[0].DD_Stage__c);
    }

    @isTest static void testGetCollections() {
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getCollections(testHistories,null);

        System.assertEquals(8, returnedHistories.Size());
    }

    @isTest static void testGetCollectionsByStage() {
        List<Income_Debit_History__c> testHistories = createTestHistories();

        Set<String> failedStages = new Set<String>();
        failedStages.add('Failed');

        Set<String> successfulStages = new Set<String>();
        successfulStages.add('Successful');

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getCollectionsByStage(testHistories, null, failedStages);

        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('Failed', returnedHistories[0].DD_Stage__c);

        returnedHistories = SMP_DirectDebitHelper.getCollectionsByStage(testHistories, null, successfulStages);
        System.assertEquals(2, returnedHistories.Size());
        System.assertEquals('Successful', returnedHistories[0].DD_Stage__c);
        System.assertEquals('Successful', returnedHistories[1].DD_Stage__c);
        System.assertEquals('First Collection', returnedHistories[0].DD_Status__c);
        System.assertEquals('Ongoing Collection', returnedHistories[1].DD_Status__c);
    }

    @isTest static void testGetHistoriesByReasonCode() {
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getHistoriesByReasonCode(testHistories, null, new Set<String>{'ADDACS-02'});

        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('ADDACS-02', returnedHistories[0].DD_Code__c);
    }

    @isTest static void testGetHistoriesByStage() {
        List<Income_Debit_History__c> testHistories = createTestHistories();

        Set<String> failedStages = new Set<String>();
        failedStages.add('Failed');

        Set<String> successfulStages = new Set<String>();
        successfulStages.add('Successful');

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getHistoriesByStage(testHistories, null, failedStages);

        System.assertEquals(2, returnedHistories.Size());
        System.assertEquals('Failed', returnedHistories[0].DD_Stage__c);
        System.assertEquals('Failed', returnedHistories[1].DD_Stage__c);

        returnedHistories = SMP_DirectDebitHelper.getHistoriesByStage(testHistories, null, successfulStages);
        System.assertEquals(3, returnedHistories.Size());
        System.assertEquals('Successful', returnedHistories[0].DD_Stage__c);
        System.assertEquals('Successful', returnedHistories[1].DD_Stage__c);
        System.assertEquals('New Instruction', returnedHistories[0].DD_Status__c);
        System.assertEquals('First Collection', returnedHistories[1].DD_Status__c);
        System.assertEquals('Ongoing Collection', returnedHistories[2].DD_Status__c);
    }
    @isTest static void testGetDirectDebitsByStatus() {
        List<Income_Direct_Debit__c> testDDs = createTestDirectDebit();

        Set<String> newInstructionStatus = new Set<String>();
        newInstructionStatus.add('New Instruction');

        Set<String> firstCollectionStatus = new Set<String>();
        firstCollectionStatus.add('First Collection');

        List<Income_Direct_Debit__c> returnedDirectDebits = SMP_DirectDebitHelper.getDirectDebitsByStatus(testDDs, null, newInstructionStatus);

        System.assertEquals(3, returnedDirectDebits.Size());
        System.assertEquals('New Instruction', returnedDirectDebits[0].DD_Status__c);
        System.assertEquals('New Instruction', returnedDirectDebits[1].DD_Status__c);
        System.assertEquals('New Instruction', returnedDirectDebits[2].DD_Status__c);

        returnedDirectDebits = SMP_DirectDebitHelper.getDirectDebitsByStatus(testDDs, null, firstCollectionStatus);
        System.assertEquals(3, returnedDirectDebits.Size());
        System.assertEquals('First Collection', returnedDirectDebits[0].DD_Status__c);
        System.assertEquals('First Collection', returnedDirectDebits[1].DD_Status__c);
        System.assertEquals('First Collection', returnedDirectDebits[2].DD_Status__c);

    }

    @isTest static void testCalculateDirectDebitSchedule() {
        String responseBody = '{"CollectionDateResult":{"CollectionDate":"2020-09-01","Error":""},"CollectionDatesResult": [{"CollectionDate":"2020-09-01","Error":""},{"CollectionDate":"2020-09-02","Error":""}]}';
        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock (200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<Date> scheduleDates = SMP_DirectDebitHelper.calculateDirectDebitSchedule('2', Date.today(), '1', 'Monthly', '1', '5');
    }    
}