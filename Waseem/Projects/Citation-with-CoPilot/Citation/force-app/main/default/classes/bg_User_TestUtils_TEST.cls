@isTest
public class bg_User_TestUtils_TEST {
	@isTest static void testcreateQMSSalesUser(){
        String randomval = '98179986';
        User u;
        Test.startTest();
        u = bg_User_TestUtils.createQMSSalesUser(randomval);
        Test.stopTest();
        System.assertNotEquals(NULL, u);
    }
    
    @isTest static void testcreateBusinessSolutionsTeamUser(){
        String randomval = '9817998612';
        User u;
        Test.startTest();
        u = bg_User_TestUtils.createBusinessSolutionsTeamUser(randomval);
        Test.stopTest();
        System.assertNotEquals(NULL, u);
    }
    
    @isTest static void testcreateCitationContactCentreBDCUser(){
        String randomval = '981794486';
        User u;
        Test.startTest();
        u = bg_User_TestUtils.createCitationContactCentreBDCUser(randomval);
        Test.stopTest();
        System.assertNotEquals(NULL, u);
        
    }
}