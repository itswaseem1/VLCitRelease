@isTest
public class bg_Account_Helper_Test {
    @testsetup static void setUp()
    {
         User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
      insert iHASCOUser;
      User iHASCOUser1 = bg_User_TestUtils.createQMSSalesUser('2');
        iHASCOUser1.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser1.Division ='iHASCO';
      insert iHASCOUser1;
        system.runAs(iHASCOUser){
            list<Account> accList=new list<Account>();
         Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.BillingStreet = 'Harvey street';
        acc.BillingCity = 'Manchester';
        acc.BillingCountry = 'England';
        acc.BillingPostalCode = 'NXJ001';
        acc.Sites__c = 5.0;
        acc.FT_Employees__c = 20.0;
        acc.PT_Employees__c = 10.0;
        acc.iHASCO_Finance_Status__c = 'Active';
        acc.SBQQ__RenewalModel__c = 'Contract Based';
        acc.OwnerId=iHASCOUser.Id;
        acc.iHASCO_Account_Manager__c=iHASCOUser.Id;
            acc.iHASCO_Client__c=true;
        accList.add(acc);
        insert accList;
              Site__c acs = new Site__c();
        acs.Account__c = acc.id;
        acs.City__c = 'test';
        acs.Name = 'test';
        insert acs;
        }}
    //Positive Test scenario
  @isTest static void iHASCOAccManagerChangeEmailAlertPostiveTest() {
     Account acc=[select id,name,iHASCO_Client__c,iHASCO_Account_Manager__c,iHASCO_Account_Manager__r.FirstName from account limit 1];
      list<user> userlist=[select id,firstname,email,name from user where Firstname='test2'];
        list<Account> accList=new list<Account>();
        map<id,account> oldacc=new map<id,account>();
        oldacc.put(acc.id, acc);
        test.startTest();
            acc.iHASCO_Account_Manager__c=userlist[0].Id;
            update acc;
             accList.add(acc);
           string subject='Notification about change in account ownership - '+acc.Name;
           String htmlBody='Dear '+acc.iHASCO_Account_Manager__r.FirstName+',<br/><br/>';
            htmlBody+='This is to notify you that you have been assigned as an account manager for the below account. </br>';
            htmlBody+='Here is the link to the account - '+'<html><body><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+acc.Id+'">Link</a><br></body></html>';
            htmlBody+='Account Name - '+acc.Name +'<br/><br/>';
            htmlBody+='Thank you.';
            List<String> sendToaddress=new List<string>();
            sendToaddress.add(userlist[0].email);
           list<Messaging.SingleEmailMessage> emails=bg_Account_Helper.buildEmailContent(accList,oldacc);
            system.assertEquals(True,  acc.iHASCO_Client__c);
            system.assertEquals('Test Acc', acc.Name);
            system.assertEquals('test2', userlist[0].FirstName);
      if(emails.size()>=1){
            system.assertEquals(sendToaddress, emails[0].ToAddresses);
            system.assertEquals(subject, emails[0].subject);
            system.assertEquals(htmlBody, emails[0].htmlBody);
            bg_Account_Helper.sendEmail(emails);
           system.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
      }
            test.stopTest();
        }
    //Negative test scenario
     @isTest static void iHASCOAccManagerChangeEmailAlertNegativeTest() {
     Account acc=[select id,name,iHASCO_Client__c,iHASCO_Account_Manager__c,iHASCO_Account_Manager__r.FirstName from account limit 1];
      list<user> userlist=[select id,name,email,FirstName from user where Firstname='test1'];
        list<Account> accList=new list<Account>();
        map<id,account> oldacc=new map<id,account>();
        oldacc.put(acc.id, acc);
        test.startTest();
            acc.iHASCO_Account_Manager__c=userlist[0].Id;
            update acc;
             accList.add(acc);
           string subject='Notification about change in account ownership - '+acc.Name;
           String htmlBody='Dear '+acc.iHASCO_Account_Manager__r.FirstName+',<br/><br/>';
            htmlBody+='This is to notify you that you have been assigned as an account manager for the below account. </br>';
            htmlBody+='Here is the link to the account - '+'<html><body><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+acc.Id+'">Link</a><br></body></html>';
            htmlBody+='Account Name - '+acc.Name +'<br/><br/>';
            htmlBody+='Thank you.';
            List<String> sendToaddress=new List<string>();
            sendToaddress.add(userlist[0].email);
           list<Messaging.SingleEmailMessage> emails=bg_Account_Helper.buildEmailContent(accList,oldacc);
            system.assertEquals(True,  acc.iHASCO_Client__c);
            system.assertEquals('Test Acc', acc.Name);
            system.assertEquals('test1', userlist[0].FirstName);
          if(emails.size()>=1){
            system.assertEquals(sendToaddress, emails[0].ToAddresses);
            system.assertEquals(subject, emails[0].subject);
            system.assertEquals(htmlBody, emails[0].htmlBody);
            bg_Account_Helper.sendEmail(emails);
           system.assertEquals(0, Limits.getEmailInvocations(), 'Emails should not sent');
          }
            test.stopTest();
        }
}