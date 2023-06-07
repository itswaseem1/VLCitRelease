@isTest
public class Contact_Test {
	@testSetUp
    public static void makeData(){
        List<Account> accList = TestDataFactory.getAccounts(2,'Citation Limited',true);
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0;i<10;i++){
            Contact con = new Contact();
            con.FirstName = 'Sai';
            con.LastName  = 'Karthik '+i;
            con.AccountId = accList[0].Id;
            con.Email = 'karthik@citation.co.uk';
            contactList.add(con);
        }
        if(!contactList.isEmpty()){
            insert contactList;
        }
    }
    public testMethod static void executeData(){
        Test.startTest();
        List<Contact> conList = [SELECT Id,IndividualId,Email FROM Contact];
        System.assertEquals(10,conList.size());
        Test.stopTest();
    }
     public testMethod static void DeleteContactTest(){
        Test.startTest();
        List<Contact> conList = [SELECT Id,IndividualId,Email FROM Contact];
         Delete conList;
        Test.stopTest();
    }
}