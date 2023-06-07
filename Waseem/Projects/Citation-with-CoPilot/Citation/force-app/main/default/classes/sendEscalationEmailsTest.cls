@isTest
public class sendEscalationEmailsTest {
    @testSetup static void setupmethod(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String orgId1=UserInfo.getOrganizationId(); 
        String dateString1=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId1=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName1=orgId1+dateString1+RandomId1; 
        User u1 = new User(Alias = 'standt1', Email=uniqueName1+'@citation.co.uk', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName1+'@testorg.com');
		insert u1;
		    
        String orgId2=UserInfo.getOrganizationId(); 
        String dateString2=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId2=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName2=orgId2+dateString2+RandomId2; 
        
        User u2 = new User(Alias = 'standt2', Email=uniqueName2+'@citation.co.uk', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', ManagerId=u1.id,
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName2+'@testorg.com');
        insert u2;
        
        Id queueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Query').getRecordTypeId();
        List<Case> cases = new List<Case>();
        for(integer i=7;i<=8;i++){
            Case cs = New Case();
            cs.Subject='Case to test email : '+i;
            cs.Department__c='ELT';
            cs.Company__c='EPM';
            cs.Description='Case to test email';
            cs.RecordTypeId=queueRecordTypeId;
            cs.createddate=System.now().addDays(-i);
            cs.ownerID=u2.id;
            cases.add(cs);
        }
        insert cases;
    }
    @istest 
    public static void sendEmail(){
       
        Test.startTest();
        Integer emailInvocationsStart = Limits.getEmailInvocations();
        Id batchId = Database.executeBatch(new QueriesEscalationBatch(),200);
        Integer emailInvocationsEnd = Limits.getEmailInvocations();
        Test.stopTest();
        List<case> cases=[select id from case];
        List<task> tsks=[select id from task];
        System.assertEquals(2, cases.size());
        System.assertEquals(1, tsks.size());
       
        
    }
    
    public static testMethod void testschedule() {
        
        Test.StartTest();
        ClientQueriesEscalationScheduler sh1 = new ClientQueriesEscalationScheduler();
        
        String sch = '0 0 23 * * ?'; 
        String jobId=system.schedule('Test Territory Check', sch, sh1); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, 
                            ct.CronExpression);
        Test.stopTest();
        
    }
    
    
}