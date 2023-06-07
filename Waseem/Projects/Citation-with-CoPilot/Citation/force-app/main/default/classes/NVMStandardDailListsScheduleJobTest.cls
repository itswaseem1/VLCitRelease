@isTest
public class NVMStandardDailListsScheduleJobTest {
    @testSetUp
    public static void makeData(){
        List<Lead> leadList = new List<Lead>();
        List<Lead> leadListUpdate = new List<Lead>();
        List<Job_Execution_Status_Update__mdt> errorList = new List<Job_Execution_Status_Update__mdt>();
        //Inserting User
        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        u.FirstName       = 'Karthik';
        u.LastName        = 'Test';
        u.Email           = 'karthikanupojutest@citation.co.uk';
        u.Username        = 'karthikanupojutest@citation.co.uk';
       u.CompanyName     = 'Citation Company';
        u.Title           = 'Captian';
        u.Alias           = 'glem';
        u.TimeZoneSidKey  = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey    = 'en_US';
        insert u;
        //Inserting Automation Confiuration records
        List<Automation_Configuration__c> getListTypes      = TestDataFactory.getListType();
        List<Automation_Configuration__c> sourceExclRecords = TestDataFactory.getSourceExclList();
        List<Automation_Configuration__c> sectorExclRecords = TestDataFactory.getSectorExclList();
        List<Automation_Configuration__c> postCodeRecords   = TestDataFactory.getPostalCodeExclList();
        List<Automation_Configuration__c> getBDMLimits      = TestDataFactory.getBDMLimits();
        Id sectorRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Sector Exclusion').getRecordTypeId();
        Id bdmlimitsRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL BDM Limits').getRecordTypeId();       
        //Insert Automation_Configuration__c records
        List<Automation_Configuration__c> automationConfigurationRecords=new List<Automation_Configuration__c>();
        Automation_Configuration__c ac = new Automation_Configuration__c();
        ac.RecordTypeId = bdmlimitsRecTypeId;
        ac.BDM__c = 'Karthik Test';
        ac.List_Type__c = 'List 2a';
        ac.Maximum_Prospects__c=3;
        automationConfigurationRecords.add(ac);       
        Automation_Configuration__c ac1 = new Automation_Configuration__c();
        ac1.RecordTypeId = sectorRecTypeId;
        ac1.Data_Supplier__c = 'ALL';
        ac1.Citation_Sector__c = 'ALL';
        ac1.Release_Field__c = 'OutboundCallCount__c';
        ac1.Release_Threshold_Operator__c = '>';
        ac1.Release_Threshold__c = '4';
        //automationConfigurationRecords.add(ac1);
        Automation_Configuration__c ac2 = new Automation_Configuration__c();
        ac2.RecordTypeId = sectorRecTypeId;
        ac2.Data_Supplier__c = 'ML_Sweep';
        ac2.Citation_Sector__c = 'EDUCATION';
        ac2.Release_Field__c = 'OutboundCallCount__c';
        ac2.Release_Threshold_Operator__c = '<';
        ac2.Release_Threshold__c = '6';
        automationConfigurationRecords.add(ac2);
        Automation_Configuration__c ac3 = new Automation_Configuration__c();
        ac3.RecordTypeId = sectorRecTypeId;
        ac3.Data_Supplier__c = 'ML_Sweep';
        ac3.Citation_Sector__c = 'EDUCATION';
        ac3.Release_Field__c = 'OutboundCallCount__c';
        ac3.Release_Threshold_Operator__c = '=';
        ac3.Release_Threshold__c = '5';
        automationConfigurationRecords.add(ac3);
        Automation_Configuration__c ac5 = new Automation_Configuration__c();
        ac5.RecordTypeId = sectorRecTypeId;
        ac5.Data_Supplier__c = 'keysector';
        ac5.Citation_Sector__c = 'DAY NURSERY';
        ac5.Release_Field__c = 'OutboundCallCount__c';
        ac5.Release_Threshold_Operator__c = '<=';
        ac5.Release_Threshold__c = '5';
        automationConfigurationRecords.add(ac5);
        Automation_Configuration__c ac4 = new Automation_Configuration__c();
        ac4.RecordTypeId = sectorRecTypeId;
        ac4.Data_Supplier__c = 'keysector';
        ac4.Citation_Sector__c = 'DAY NURSERY';
        ac4.Release_Field__c = 'OutboundCallCount__c';
        ac4.Release_Threshold_Operator__c = '>=';
        ac4.Release_Threshold__c = '5';
        automationConfigurationRecords.add(ac4);
        Automation_Configuration__c ac7 = new Automation_Configuration__c();
        ac7.RecordTypeId = sectorRecTypeId;
        ac7.Data_Supplier__c = 'keysector';
        ac7.Citation_Sector__c = 'DAY NURSERY';
        ac7.Release_Field__c = 'OutboundCallCount__c';
        ac7.Release_Threshold_Operator__c = '=';
        ac7.Release_Threshold__c = '5';
        automationConfigurationRecords.add(ac7);
        Automation_Configuration__c ac8 = new Automation_Configuration__c();
        ac8.RecordTypeId = sectorRecTypeId;
        ac8.Data_Supplier__c = 'keysector';
        ac8.Citation_Sector__c = 'DAY NURSERY';
        ac8.Release_Field__c = 'OutboundCallCount__c';
        ac8.Release_Threshold_Operator__c = '<>';
        ac8.Release_Threshold__c = '6';
        automationConfigurationRecords.add(ac8);
        Automation_Configuration__c ac9 = new Automation_Configuration__c();
        ac9.RecordTypeId = sectorRecTypeId;
        ac9.Data_Supplier__c = 'keysector';
        ac9.Citation_Sector__c = 'DAY NURSERY';
        ac9.Release_Field__c = 'OutboundCallCount__c';
        ac9.Release_Threshold_Operator__c = '<';
        ac9.Release_Threshold__c = '6';
        automationConfigurationRecords.add(ac9);
        Id SIC2007_Code3ExcID = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL SIC2007 Code3 Exclusion').getRecordTypeId();
        Automation_Configuration__c ac6 = new Automation_Configuration__c();
        ac6.RecordTypeId = SIC2007_Code3ExcID;
        ac6.Data_Supplier__c = 'ML_Sweep';
        ac6.Citation_Sector__c = 'EDUCATION';
        ac6.Release_Field__c = 'OutboundCallCount__c';
        ac6.Release_Threshold_Operator__c = '<>';
        ac6.Release_Threshold__c = '3';
        automationConfigurationRecords.add(ac6);
        //   insert automationConfigurationRecords;
        //Inserting Leads
        System.runAs(u){
            for(Integer i=1;i<=5;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 1 '+i;
                l.Company = 'Citation Test 1 '+i;
                l.NVMConnect__NextContactTime__c = null;
                l.Phone = '9876543210';
                l.OwnerId = u.Id;
                l.Basic_Crit_New__c = true;
                l.CitationSector__c = 'CARE';
                l.FTE_Crit_New__c = true;
                leadList.add(l);
            }
            //Criteria's
            for(Integer i=1;i<=3;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 21 '+i;
                l.Company = 'Citation Test 21 '+i;
                l.PostalCode = 'BT92 BMP';
                l.Source__c = 'Closed Lost';
                l.CitationSector__c = 'EDUCATION';
                l.List_ID__c = 10;
                l.OwnerId = u.Id;
                leadList.add(l);
            }
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 22 '+i;
                l.Company = 'Citation Test 22 '+i;
                l.PostalCode = 'BT93 BMP';
                l.Source__c = 'Existing';
                l.Data_Supplier__c = 'ML_Sweep';
                l.CitationSector__c = 'EDUCATION';
                l.OutboundCallCount__c = 2;
                l.List_ID__c = 20;
                l.OwnerId = u.Id;
                l.List_Type_New__c= 'List 1b';    
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 23 '+i;
                l.Company = 'Citation Test 23 '+i;
                l.PostalCode = 'BT94 BMP';
                l.Source__c = 'Marketing Lost keySector';
                l.OutboundCallCount__c = 2;
                l.OwnerId = u.Id;
                leadList.add(l);
            }
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 24 '+i;
                l.Company = 'Citation Test 24 '+i;
                l.PostalCode = 'BT95 BMP';
                l.Source__c = 'Closed Won';
                l.OutboundCallCount__c = 5;
                l.OwnerId = u.Id;
                l.List_Type_New__c= 'List 2a';
                l.FT_Employees__c=6;
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 25 '+i;
                l.Company = 'Citation Test 25 '+i;
                l.PostalCode = 'BT96 BMP';
                l.Source__c = 'key Sector';
                l.Data_Supplier__c = 'keysector';
                l.CitationSector__c = 'DAY NURSERY';
                l.OutboundCallCount__c = 5;
                l.OwnerId = u.Id;
                l.List_Type_New__c= 'List 1a';
                l.LeadSource='Add on';
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 26 '+i;
                l.Company = 'Citation Test 26 '+i;
                l.PostalCode = 'BT97 BMP';
                l.Source__c = 'Industries Limited';
                l.OutboundCallCount__c = 1;
                l.OwnerId = u.Id;
                l.LeadSource='Add on';
                ///////
                if(i==2){
                l.Data_Supplier__c = 'keysector';
                l.CitationSector__c = 'DAY NURSERY';
                }
                l.Basic_Crit_New__c=true;
                l.List_Type_New__c= 'List 1b';                
                leadList.add(l);
            }
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 27 '+i;
                l.Company = 'Citation Test 27 '+i;
                l.PostalCode = 'BT98 BMP';
                l.Source__c = 'sector exclusion';
                l.OutboundCallCount__c = 5;
                l.OwnerId = u.Id;
                l.List_Type_New__c= 'List 2a';
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            for(Integer i=1;i<=4;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 30 '+i;
                l.Company = 'Citation Test 30 '+i;
                l.PostalCode = 'BT98 BMP';
                l.Source__c = 'sector exclusion';
                l.OutboundCallCount__c = 5;
                l.OwnerId = u.Id;
                l.List_Type_New__c= 'List 2a';
                l.Data_Supplier__c = 'keysector';
                l.CitationSector__c = 'DAY NURSERY';
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            for(Integer i=1;i<=2;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 31 '+i;
                l.Company = 'Citation Test 31 '+i;
                l.PostalCode = 'BT98 BMPP';
                l.Source__c = 'sector exclusion1';
                l.OutboundCallCount__c = 5;
                l.OwnerId = u.Id;
                l.NVMConnect__NextContactTime__c=null;
                l.List_Type_New__c= 'List 3';
                l.Data_Supplier__c = 'keysector1';
                l.CitationSector__c = 'DAY NURSERY';
                l.Partner_CC_Exclusion__c=true;
                if(i==2){
                l.Data_Supplier__c = 'keysector1';
                l.CitationSector__c = 'DAY NURSERY';
                l.List_Type_New__c= 'List 1b';
                }                
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                l.FTE_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            for(Integer i=1;i<=1;i++){
                Lead l = new Lead();
                l.LastName = 'Test Name 31 '+i;
                l.Company = 'Citation Test 31 '+i;
                l.OwnerId = u.Id;
                l.NVMConnect__NextContactTime__c=null;
                l.List_Type_New__c= 'List 3';
                l.LeadSource='Add on';
                leadList.add(l);
                l.Basic_Crit_New__c=true;
                l.FTE_Crit_New__c=true;
                leadListUpdate.add(l);
            }
            Lead l = new Lead();
            l.LastName = 'Test Name 26 Test ';
            l.Company = 'Citation Test 26 Test ';
            l.OutboundCallCount__c = 1;
            l.OwnerId = u.Id;
            leadList.add(l);
            l.Basic_Crit_New__c=true;
            l.FTE_Crit_New__c=true;
            leadListUpdate.add(l);
        }
        // List 3     
        Id sourceRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Source Exclusion').getRecordTypeId();
        Id outRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Outcode Exclusion').getRecordTypeId();  
        
        Automation_Configuration__c ac10 = new Automation_Configuration__c();
        ac10.RecordTypeId = sourceRecTypeId;
        ac10.Source__c = 'Test';
        ac10.Release_Field__c='ALL';
        automationConfigurationRecords.add(ac10);
        Automation_Configuration__c ac11 = new Automation_Configuration__c();
        ac11.RecordTypeId = sourceRecTypeId;
        ac11.Source__c = 'Test1';
        ac11.Release_Field__c='ALL1';
        ac11.Release_Threshold_Operator__c='<';
        ac11.Release_Threshold__c='7';
        automationConfigurationRecords.add(ac11);        
        Automation_Configuration__c ac12 = new Automation_Configuration__c();
        ac12.RecordTypeId = sourceRecTypeId;
        ac12.Source__c = 'Test2';
        ac12.Release_Field__c='ALL1';
        ac12.Release_Threshold_Operator__c='=';
        ac12.Release_Threshold__c='4';
        automationConfigurationRecords.add(ac12);
        Automation_Configuration__c ac13 = new Automation_Configuration__c();
        ac13.RecordTypeId = sourceRecTypeId;
        ac13.Source__c = 'Test3';
        ac13.Release_Field__c='ALL1';
        ac13.Release_Threshold_Operator__c='>';
        ac13.Release_Threshold__c='8';
        automationConfigurationRecords.add(ac13);        
        Automation_Configuration__c ac14 = new Automation_Configuration__c();
        ac14.RecordTypeId = sourceRecTypeId;
        ac14.Source__c = 'Test5';
        ac14.Release_Field__c='ALL1';
        ac14.Release_Threshold_Operator__c='<=';
        ac14.Release_Threshold__c='7';
        automationConfigurationRecords.add(ac14);
        Automation_Configuration__c ac15 = new Automation_Configuration__c();
        ac15.RecordTypeId = sourceRecTypeId;
        ac15.Source__c = 'Test6';
        ac15.Release_Field__c='ALL1';
        ac15.Release_Threshold_Operator__c='>=';
        ac15.Release_Threshold__c='1';
        automationConfigurationRecords.add(ac15);        
        
        Automation_Configuration__c ac16 = new Automation_Configuration__c();
        ac16.RecordTypeId = outRecTypeId;
        ac16.Outcode__c = 'BT98 BMP1';
        ac16.Release_Field__c='ALL';
        automationConfigurationRecords.add(ac16);          
        Automation_Configuration__c ac17 = new Automation_Configuration__c();
        ac17.RecordTypeId = outRecTypeId;
        ac17.Outcode__c = 'BT98 BMP2';
        ac17.Release_Field__c='ALL1';
        ac17.Release_Threshold_Operator__c='>';
        ac17.Release_Threshold__c='8';
        automationConfigurationRecords.add(ac17); 
        Automation_Configuration__c ac18 = new Automation_Configuration__c();
        ac18.RecordTypeId = outRecTypeId;
        ac18.Outcode__c = 'BT98 BMP3';
        ac18.Release_Field__c='ALL1';
        ac18.Release_Threshold_Operator__c='<=';
        ac18.Release_Threshold__c='7';
        automationConfigurationRecords.add(ac18);  
        insert automationConfigurationRecords;
        
        Lead l1 = new Lead();
        l1.LastName = 'Test Name 1';
        l1.Company = 'Citation Test 1 ';               
        l1.Source__c = 'Test';
        l1.PostalCode = 'BT98 BMP1';
        l1.NVMConnect__NextContactTime__c=null;
        l1.List_Type_New__c= 'List 3';
        leadList.add(l1);
        l1.Basic_Crit_New__c=true;
        l1.FTE_Crit_New__c=true;
        leadListUpdate.add(l1);
        
        Lead l2 = new Lead();
        l2.LastName = 'Test Name 2';
        l2.Company = 'Citation Test 2 ';               
        l2.Source__c = 'Test1';
        l2.OutboundCallCount__c=6;
        l2.NVMConnect__NextContactTime__c=null;
        l2.List_Type_New__c= 'List 3';
        leadList.add(l2);
        l2.Basic_Crit_New__c=true;
        l2.FTE_Crit_New__c=true;
        leadListUpdate.add(l2);
        
        Lead l3 = new Lead();
        l3.LastName = 'Test Name 4';
        l3.Company = 'Citation Test 4 ';               
        l3.Source__c = 'Test2';
        l3.OutboundCallCount__c=4;
        l3.NVMConnect__NextContactTime__c=null;
        l3.List_Type_New__c= 'List 3';
        leadList.add(l3);
        l3.Basic_Crit_New__c=true;
        l3.FTE_Crit_New__c=true;
        leadListUpdate.add(l3);
        
        Lead l4 = new Lead();
        l4.LastName = 'Test Name 3';
        l4.Company = 'Citation Test 3 ';               
        l4.Source__c = 'Test3';
        l4.PostalCode = 'BT98 BMP2';
        l4.OutboundCallCount__c=9;
        l4.NVMConnect__NextContactTime__c=null;
        l4.List_Type_New__c= 'List 3';
        leadList.add(l4);
        l4.Basic_Crit_New__c=true;
        l4.FTE_Crit_New__c=true;
        leadListUpdate.add(l4);
        
        Lead l5 = new Lead();
        l5.LastName = 'Test Name 5';
        l5.Company = 'Citation Test 5 ';               
        l5.Source__c = 'Test5';
        l5.PostalCode = 'BT98 BMP3'; 
        l5.OutboundCallCount__c=3;
        l5.NVMConnect__NextContactTime__c=null;
        l5.List_Type_New__c= 'List 3';
        leadList.add(l5);
        l5.Basic_Crit_New__c=true;
        l5.FTE_Crit_New__c=true;
        leadListUpdate.add(l5);        
        
        Lead l6 = new Lead();
        l6.LastName = 'Test Name 6';
        l6.Company = 'Citation Test 6 '; 
        l6.PostalCode=null;
        l6.Source__c=null;
        l6.NVMConnect__NextContactTime__c=null;
        leadList.add(l6);
        l6.PostalCode=null;
        l6.Source__c=null;
        l6.Basic_Crit_New__c=true;
        l6.FTE_Crit_New__c=true;
        leadListUpdate.add(l6);
        //List1a
        Lead l7 = new Lead();
        l7.LastName = 'Test Name 1';
        l7.Company = 'Citation Test 1 ';               
        l7.Source__c = 'Test';
        l7.PostalCode = 'BT98 BMP1';
        l7.NVMConnect__NextContactTime__c=null;
        l7.List_Type_New__c= 'List 1a';
        leadList.add(l7);
        l7.Basic_Crit_New__c=true;
        l7.FTE_Crit_New__c=true;
        leadListUpdate.add(l7);
        
        Lead l8 = new Lead();
        l8.LastName = 'Test Name 2';
        l8.Company = 'Citation Test 2 ';               
        l8.Source__c = 'Test1';
        l8.OutboundCallCount__c=6;
        l8.NVMConnect__NextContactTime__c=null;
        l8.List_Type_New__c= 'List 1a';
        leadList.add(l8);
        l8.Basic_Crit_New__c=true;
        l8.FTE_Crit_New__c=true;
        leadListUpdate.add(l8);
        
        Lead l9 = new Lead();
        l9.LastName = 'Test Name 4';
        l9.Company = 'Citation Test 4 ';               
        l9.Source__c = 'Test2';
        l9.OutboundCallCount__c=4;
        l9.NVMConnect__NextContactTime__c=null;
        l9.List_Type_New__c= 'List 1a';
        leadList.add(l9);
        l9.Basic_Crit_New__c=true;
        l9.FTE_Crit_New__c=true;
        leadListUpdate.add(l9);
        
        
        Lead l10 = new Lead();
        l10.LastName = 'Test Name 3';
        l10.Company = 'Citation Test 3 ';               
        l10.Source__c = 'Test3';
        l10.PostalCode = 'BT98 BMP2';
        l10.OutboundCallCount__c=9;
        l10.NVMConnect__NextContactTime__c=null;
        l10.List_Type_New__c= 'List 1a';
        leadList.add(l10);
        l10.Basic_Crit_New__c=true;
        l10.FTE_Crit_New__c=true;
        leadListUpdate.add(l10);
        
        Lead l11 = new Lead();
        l11.LastName = 'Test Name 5';
        l11.Company = 'Citation Test 5 ';               
        l11.Source__c = 'Test5';
        l11.PostalCode = 'BT98 BMP3'; 
        l11.OutboundCallCount__c=3;
        l11.NVMConnect__NextContactTime__c=null;
        l11.List_Type_New__c= 'List 1a';
        leadList.add(l11);
        l11.Basic_Crit_New__c=true;
        l11.FTE_Crit_New__c=true;
        leadListUpdate.add(l11);
        
        Lead l12 = new Lead();
        l12.LastName = 'Test Name 6';
        l12.Company = 'Citation Test 6 ';               
        l12.Source__c = 'Test6';
        l12.OutboundCallCount__c=10;
        l12.NVMConnect__NextContactTime__c=null;
        l12.List_Type_New__c= 'List 1a';
        leadList.add(l12);
        l12.Basic_Crit_New__c=true;
        l12.FTE_Crit_New__c=true;
        leadListUpdate.add(l12);          
        //List1b                  
        Lead l13 = new Lead();
        l13.LastName = 'Test Name 1';
        l13.Company = 'Citation Test 1 ';               
        l13.Source__c = 'Test';
        l13.PostalCode = 'BT98 BMP1';
        l13.NVMConnect__NextContactTime__c=null;
        l13.List_Type_New__c= 'List 1b';
        leadList.add(l13);
        l13.Basic_Crit_New__c=true;
        l13.FTE_Crit_New__c=true;
        leadListUpdate.add(l13);
        
        Lead l14 = new Lead();
        l14.LastName = 'Test Name 2';
        l14.Company = 'Citation Test 2 ';               
        l14.Source__c = 'Test1';
        l14.PostalCode='BT98 BMP4';
        l14.OutboundCallCount__c=6;
        l14.NVMConnect__NextContactTime__c=null;
        l14.List_Type_New__c= 'List 1b';
        leadList.add(l14);
        l14.Basic_Crit_New__c=true;
        l14.FTE_Crit_New__c=true;
        leadListUpdate.add(l14);
        
        Lead l15 = new Lead();
        l15.LastName = 'Test Name 4';
        l15.Company = 'Citation Test 4 ';               
        l15.Source__c = 'Test2';
        l15.PostalCode='BT98 BMPP';
        l15.OutboundCallCount__c=4;
        l15.NVMConnect__NextContactTime__c=null;
        l15.List_Type_New__c= 'List 1b';
        leadList.add(l15);
        l15.Basic_Crit_New__c=true;
        l15.FTE_Crit_New__c=true;
        leadListUpdate.add(l15);
        
        Lead l16 = new Lead();
        l16.LastName = 'Test Name 3';
        l16.Company = 'Citation Test 3 ';               
        l16.Source__c = 'Test3';
        l16.PostalCode = 'BT98 BMP2';
        l16.OutboundCallCount__c=9;
        l16.NVMConnect__NextContactTime__c=null;
        l16.List_Type_New__c= 'List 1b';
        leadList.add(l16);
        l16.Basic_Crit_New__c=true;
        l16.FTE_Crit_New__c=true;
        leadListUpdate.add(l16);
        
        Lead l17 = new Lead();
        l17.LastName = 'Test Name 5';
        l17.Company = 'Citation Test 5 ';               
        l17.Source__c = 'Test5';
        l17.PostalCode = 'BT98 BMP3'; 
        l17.OutboundCallCount__c=3;
        l17.NVMConnect__NextContactTime__c=null;
        l17.List_Type_New__c= 'List 1b';
        leadList.add(l17);
        l17.Basic_Crit_New__c=true;
        l17.FTE_Crit_New__c=true;
        leadListUpdate.add(l17);
        
        Lead l18 = new Lead();
        l18.LastName = 'Test Name 6';
        l18.Company = 'Citation Test 6 ';               
        l18.Source__c = 'Test6';
        l18.PostalCode='BT98 BMP5';
        l18.OutboundCallCount__c=10;
        l18.NVMConnect__NextContactTime__c=null;
        l18.List_Type_New__c= 'List 1b';
        leadList.add(l18);
        l18.Basic_Crit_New__c=true;
        l18.FTE_Crit_New__c=true;
        leadListUpdate.add(l18);
        
        if(leadList.size()>0 && leadList!=null){
            insert leadList;
        }
        if(leadListUpdate.size()>0 && leadListUpdate!=null){
            Update leadListUpdate;
        }
        
        //Getting Metadata
        for(Job_Execution_Status_Update__mdt jes : [SELECT Id,Result_Message_1__c,Result_Message_2__c,Result_Message_3__c,Result_Message_4__c FROM Job_Execution_Status_Update__mdt]){
            errorList.add(jes);
        }
    }
    
    @isTest
    public static void executeData(){  
        Id dcProspectRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Prospect Source Exclusion').getRecordTypeId();
        Id dcPartnerRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Partner CC Exclusion').getRecordTypeId();
        List<Automation_Configuration__c> automationConfigurationRecords=new List<Automation_Configuration__c>();
        Automation_Configuration__c ac11 = new Automation_Configuration__c();
        ac11.RecordTypeId = dcProspectRecTypeId;
        ac11.Prospect_Source__c='Advert';
        automationConfigurationRecords.add(ac11);
        Automation_Configuration__c ac12 = new Automation_Configuration__c();
        ac12.RecordTypeId = dcPartnerRecTypeId;
        ac12.Partner_CC_Exclusion__c='true';
        automationConfigurationRecords.add(ac12);        
        insert automationConfigurationRecords;
        
        String cronExp = '00 00 22 12 12 ? 2025';
        Test.startTest();
        NVMStandardDailListsScheduleJob nmr = new NVMStandardDailListsScheduleJob();
        database.executeBatch(nmr,2000);         
        Test.stopTest();
        
    }
}