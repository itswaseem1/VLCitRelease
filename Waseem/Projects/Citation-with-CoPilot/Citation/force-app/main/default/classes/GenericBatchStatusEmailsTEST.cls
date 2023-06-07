@isTest
public class GenericBatchStatusEmailsTEST {
          
    @isTest static void TestsendEmail() { 
	List<String> mailidsList = new List<String>();
	mailidsList.add('test@test.com');       
        Test.startTest();
        	GenericBatchStatusEmails.sendEmail('Test' , 'Test' , mailidsList);
        Test.StopTest();
    }
    
}