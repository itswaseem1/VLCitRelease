/*
Name of Class:ServiceClass_Test
Purpose:Test Class for ServiceClass Class
Creation Date and Consultant Name: 11June2
---------------------------------------------------------------------------------------
Update History:

*/
@isTest
public class ServiceClass_Test {
    @isTest
    public static void serviceClassTest() {
	test.startTest();
    ServiceClass sCls = new ServiceClass();
    System.assertEquals(true, ServiceClass.runSALogic,'success');
    Test.StopTest();
    }
}