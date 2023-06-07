@isTest
public class PaymentAgreementAccountUpdBatch_TEST {
       
    @isTest(SeeAllData = True) static void TestBatchExecution() {       
        Test.startTest();
        	PaymentAgreementAccountUpdBatch bat = new PaymentAgreementAccountUpdBatch();
        	Database.executeBatch(bat,200);
        Test.StopTest();
    }
    
    @isTest static void TestsendEmail() {       
        Test.startTest();
        	PaymentAgreementAccountUpdBatch bat = new PaymentAgreementAccountUpdBatch();
        	bat.sendEmail('TestClass');
        Test.StopTest();
    }
    
}