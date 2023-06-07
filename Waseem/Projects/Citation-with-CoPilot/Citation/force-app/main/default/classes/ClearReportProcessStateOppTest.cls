@isTest
public class ClearReportProcessStateOppTest {
    
    static testmethod void testScheduleExecution_CustomSize()
    {
        id rid = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        Automation_Configuration__c    act = new Automation_Configuration__c();
        act.Report_Name__c = 'Test Report 1';
        act.Processed__c = 'Yes';
        act.Run_Duplicate_Rules__c = True; 
        act.Distribution_List__c = 'srikanthragi@citation.co.uk,';
        act.recordtypeid =rid;
        insert act;
        
        Automation_Configuration__c  acrec = [select id,Report_Name__c,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid from Automation_Configuration__c limit 1] ;

        String CRON_EXP = '0 0 12 1/1 * ? *';
        String jobID = '';
        Test.startTest();
        ClearReportProcessStateOpp schjob = new ClearReportProcessStateOpp();
        jobID = System.schedule('CoreRemainingDays Job', CRON_EXP, schjob);
        
        CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        // Assert that the expressions are the same
        System.assertEquals(CRON_EXP, cronTrigger1.CronExpression);          
        // Assert that the cron job has not started
        System.assertEquals(0, cronTrigger1.TimesTriggered);
        Test.StopTest();
    }
    
    static testmethod void SelfServeReportResultsFetchOpp()
    {
        id rid = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        Automation_Configuration__c    act = new Automation_Configuration__c();
        act.Report_Name__c = 'Test Report 1';
        act.Processed__c = 'Yes';
        act.Run_Duplicate_Rules__c = True; 
        act.Distribution_List__c = 'srikanthragi@citation.co.uk,';
        act.recordtypeid =rid;
        insert act;
        Automation_Configuration__c  acrec = [select id,Report_Name__c,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid from Automation_Configuration__c limit 1] ;

        String CRON_EXP = '0 0 12 1/1 * ? *';
        String jobID = '';
        Test.startTest();
        String QueryString = 'SELECT Id,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c where Processed__c In: stp and recordtypeid =:lareI limit 1';
        SelfServeReportResultsFetchOpp schjob = new SelfServeReportResultsFetchOpp(QueryString);
        	Database.executeBatch(schjob,250);
        Test.StopTest();
    }
    
    static testmethod void SelfServeReportResultsFetchOppCoverage()
    {
        id rid = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        List<Automation_Configuration__c> acstoInsert=new List<Automation_Configuration__c>();
        Automation_Configuration__c    act = new Automation_Configuration__c();
        act.Report_Name__c = 'Test Report 1';
        act.Processed__c = 'No';
        act.Run_Duplicate_Rules__c = True; 
        act.Distribution_List__c = 'srikanthragi@citation.co.uk,';
        act.recordtypeid =rid;
        acstoInsert.add(act);
        Automation_Configuration__c    act1 = new Automation_Configuration__c();
        act1.Report_Name__c = 'Test Report 1';
        act1.Processed__c = 'Yes';
        act1.Run_Duplicate_Rules__c = True; 
        act1.Distribution_List__c = 'srikanthragi@citation.co.uk,';
        act1.recordtypeid =rid;
        acstoInsert.add(act1);
        insert acstoInsert;
        DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = 'Closed_lost_Opportunity_id__c';
                doc.Outcome__c = '{Opportunity.'+ 'SalesforceID18char__c' + '}';
                doc.Operator__c = 'Equals';
         insert doc;
        Automation_Configuration__c  acrec = [select id,Report_Name__c,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid from Automation_Configuration__c limit 1] ;

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobID = '';
        Test.startTest();
        String QueryString = 'SELECT Id,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c where Processed__c In: stp and recordtypeid =:lareI limit 1';
        SelfServeReportResultsFetchOpp schjob = new SelfServeReportResultsFetchOpp(QueryString);
        	Database.executeBatch(schjob,250);
        Test.StopTest();
    }
    static testmethod void SelfServeReportResultsUpdateOpp()
    {
        id rid = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        Automation_Configuration__c    act = new Automation_Configuration__c();
        act.Report_Name__c = 'Test Report 1';
        act.Processed__c = 'Yes';
        act.Run_Duplicate_Rules__c = True; 
        act.Distribution_List__c = 'srikanthragi@citation.co.uk,';
        act.recordtypeid =rid;
        insert act;
        
        List<DML_Outcome__c> docs = new List<DML_Outcome__c>();
        
        	List<String> contactFields = new List<String>{'FirstName','LastName','Email','MailingStreet','MailingCity','MailingPostalCode','Salutation','Company__c','Phone'};
            For(String fname: contactFields){
                DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = fname;
                if(fname == 'MailingStreet'){
                   doc.Field_API_Name__c=  'Street';
                }
                if(fname == 'MailingCity'){
                    doc.Field_API_Name__c=  'City';
                }
                if(fname == 'MailingPostalCode'){
                    doc.Field_API_Name__c=  'PostalCode';
                }
                if(fname == 'Company__c'){
                    doc.Field_API_Name__c=  'Company';
                }
                doc.Outcome__c = '{Contact.'+ fname + '}';
                doc.Operator__c = 'Equals';
                docs.add(doc);
            }
        	List<String> opportunityFields = new List<String>{'CurrencyIsoCode'};
            For(String fname: opportunityFields){
                DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = fname;
                doc.Outcome__c = '{Opportunity.'+ fname + '}';
                doc.Operator__c = 'Equals';
                docs.add(doc);
            }
        	List<String> accountFields = new List<String>{'Website'};
            For(String fname: accountFields){
                DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = fname;
                doc.Outcome__c = '{Account.'+ fname + '}';
                doc.Operator__c = 'Equals';
                docs.add(doc);
            }     
       
        	insert docs;
        
        map<id,List<DML_Outcome__c>> acl = new map<id,List<DML_Outcome__c>>();
        for(Automation_Configuration__c ac : [SELECT Id,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c]){
        	acl.put(ac.id,ac.DML_Outcomes__r);
        }
        
        
        Account acc = new Account(name='Test2');
        acc.AnnualRevenue = 75000;
        insert acc;
        List<Opportunity> oppList=TestDataFactory.generateOppsForAccount(acc.Id,3000,1,false);
        oppList[0].LeadSource='Cross Sell - Citation';
        oppList[0].RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Default Citation Opportunity').getRecordTypeId();
        insert oppList;
        
        List<contact> con = TestDataFactory.getContacts(1, 'firstName', 'lastName', acc.id, true);
        
        OpportunityContactRole oc = new OpportunityContactRole();
        oc.ContactId = con[0].id;
        oc.IsPrimary = true;
        oc.OpportunityId = oppList[0].id;
        oc.Role = 'Decision Maker';
        insert oc;
        
        
       // Automation_Configuration__c  acrec = [select id,Report_Name__c,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid from Automation_Configuration__c limit 1] ;

        String QueryString = '';
        List<id> oppIDs = new List<id>();
        oppIDs.add(oppList[0].id);
        Test.startTest();
        SelfServeReportResultsUpdateOpp schjob = new SelfServeReportResultsUpdateOpp(oppIDs,'Opportunity',acl ,'',1,'',false);
        schjob.recordIds = oppIDs; 
        Database.executeBatch(schjob, 250);
        Test.StopTest();
    }
     static testmethod void SelfServeReportResultsUpdateOppCoverage()
    {
        User u=[Select Id,Run_Duplicate_Rules__c From User where UserName Like 'salesforcesupport@citation.co.uk%' limit 1];
        u.Run_Duplicate_Rules__c=true;
        Update u;
        System.runAs(u){
        id rid = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        Automation_Configuration__c    act = new Automation_Configuration__c();
        act.Report_Name__c = 'Test Report 1';
        act.Processed__c = 'Yes';
        act.Run_Duplicate_Rules__c = True; 
        act.Distribution_List__c = 'srikanthragi@citation.co.uk,';
        act.recordtypeid =rid;
        insert act;
        
        List<DML_Outcome__c> docs = new List<DML_Outcome__c>();
        
        	List<String> contactFields = new List<String>{'FirstName','LastName','Email','MailingStreet','MailingCity','MailingPostalCode','Salutation','Company__c','Phone'};
            For(String fname: contactFields){
                DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = fname;
                if(fname == 'MailingStreet'){
                   doc.Field_API_Name__c=  'Street';
                }
                if(fname == 'MailingCity'){
                    doc.Field_API_Name__c=  'City';
                }
                if(fname == 'MailingPostalCode'){
                    doc.Field_API_Name__c=  'PostalCode';
                }
                if(fname == 'Company__c'){
                    doc.Field_API_Name__c=  'Company';
                }
                doc.Outcome__c = '{Contact.'+ fname + '}';
                doc.Operator__c = 'Equals';
                docs.add(doc);
            }
        	List<String> opportunityFields = new List<String>{'CurrencyIsoCode'};
            For(String fname: opportunityFields){
                DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = fname;
                doc.Outcome__c = '{Opportunity.'+ fname + '}';
                doc.Operator__c = 'Equals';
                docs.add(doc);
            }
        	List<String> accountFields = new List<String>{'Website'};
            For(String fname: accountFields){
                DML_Outcome__c doc = new DML_OutCome__c();
            	doc.DMLAutomationConfiguration__c = act.id;
                doc.Field_API_Name__c = fname;
                doc.Outcome__c = '{Account.'+ fname + '}';
                doc.Operator__c = 'Equals';
                docs.add(doc);
            }     
       
        	insert docs;
        
        map<id,List<DML_Outcome__c>> acl = new map<id,List<DML_Outcome__c>>();
        for(Automation_Configuration__c ac : [SELECT Id,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c]){
        	acl.put(ac.id,ac.DML_Outcomes__r);
        }
        
        
        Account acc = new Account(name='Test2');
        acc.AnnualRevenue = 75000;
        insert acc;
        List<Opportunity> oppList=TestDataFactory.generateOppsForAccount(acc.Id,3000,1,false);
        oppList[0].LeadSource='Cross Sell - Citation';
        oppList[0].RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Default Citation Opportunity').getRecordTypeId();
        insert oppList;
        
        contact con=new Contact();
        con.LastName='Preverify';
        con.FirstName='1';
        con.Salutation='Mr.';
        con.company__c='Citation';
        con.Email='verify@same.com';
        insert con;
            
        OpportunityContactRole oc = new OpportunityContactRole();
        oc.ContactId = con.id;
        oc.IsPrimary = true;
        oc.OpportunityId = oppList[0].id;
        oc.Role = 'Decision Maker';
        insert oc;
        //insert lead
        Id IhascoId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default IHASCO').getRecordTypeId();
        Lead l=new Lead();
        l.firstName='1';
        l.LastName='PreVerify';
        l.Salutation='Mr.';
        l.company='Citation';
        l.RecordTypeId=IhascoId;
        l.Email='verify@same.com';
        insert l;
            
        String QueryString = '';
        List<id> oppIDs = new List<id>();
        oppIDs.add(oppList[0].id);
        Test.startTest();
        SelfServeReportResultsUpdateOpp schjob = new SelfServeReportResultsUpdateOpp(oppIDs,'Opportunity',acl ,'',1,'',true);
        schjob.recordIds = oppIDs; 
        Database.executeBatch(schjob, 250);
        Test.StopTest();
    }
    }
    
}