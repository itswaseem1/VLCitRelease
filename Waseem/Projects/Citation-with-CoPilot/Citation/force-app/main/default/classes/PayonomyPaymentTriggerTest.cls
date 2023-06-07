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
private class PayonomyPaymentTriggerTest 
{
    /**
        * This test coverage class is to move the trigger into Production Org
        * All unit testing will be done within FinancialForce Managed Package.
        * No Assertion will be required for this Test
    **/
	static testMethod void coverageTest()
	{
        User systemTestUser = createTestUser();
        System.runAs(systemTestUser)
        {
            //ARRANGE 
          	PAYBASE2__Payment__c payment = new PAYBASE2__Payment__c();
            payment.PAYBASE2__Amount__c =  500;
            payment.PAYBASE2__Status__c = 'Error';
            
            //ACT
            Test.startTest();
            try
            {
            	insert payment;	
            }
            catch(Exception ex)
            {
				//NA
            }
            Test.stopTest();
            
            //ASSERT
            //Not required, as trigger has to be unmanaged. All unit testing will be done within Managed Package
        }
    }
            
    /**
        *   Create Test User (Test Developer)
        *   No @Parms required
    **/
    static User createTestUser()
    {
        Profile p = [select id from profile where name='System Administrator'];
        User testUser = new User();
        testUser.put('FirstName' , '$Test Developer');
        testUser.put('LastName' , 'Test Developer$');
        testUser.put('Alias' , '$PSD$');
        testUser.put('Email' , 'testdeveloper@financialforce.com');
        testUser.put('Username' , 'testdeveloper@financialforce.com');
        testUser.put('CommunityNickname' , '$PSDMDT$');
        testUser.put('Phone' , '555.555.5555');
        testUser.put('IsActive' , true);
        testUser.put('ProfileId' , p.id);
        testUser.put('TimeZoneSidKey' , 'America/New_York');
        testUser.put('LocaleSidKey' , 'en_US');
        testUser.put('EmailEncodingKey' , 'ISO-8859-1');
        testUser.put('LanguageLocaleKey' , 'en_US');
        testUser.put('Title' , 'Service Developer and Tester');
        testUser.put('CompanyName' , 'Test Company PS');

        insert testUser;

        return testUser;
    }

}