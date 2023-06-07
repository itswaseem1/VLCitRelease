@isTest
public with sharing class SDP_SalesInvoiceHelperTest {
    @testSetup
    static void testPrepareData() {
        TriggerSettings__c config = new TriggerSettings__c(
            Direct_Debit_History_Trigger__c = false,
            Direct_Debit_Trigger__c = false,
            Sale_Invoice_Trigger__c = false,
            Transaction_Trigger__c = false
        );
        insert config;
        SDP_Test_Helper.createFinancialForceData();

        Account acc = SDP_Test_Helper.createAccount('Test Account');

        Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(
            Name = 'Account 1 Citation Service Delivery Plan',
            Business__c = 'Citation',
            Account__c = acc.Id
        );

        insert servicedelPlanObj;

        List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
        Milestone_Template__c milestone1 = new Milestone_Template__c(
            Name = 'Welcome Call',
            Business__c = 'Citation',
            Start_Date_Days__c = 0,
            Due_Date_Days__c = 2,
            Reference_Date_field__c = 'StartDate',
            Anniversary_Date_Months__c = 0,
            Case_Type__c = 'Non Visits',
            Status__c = 'Active'
        );
        Milestone_Template__c milestone2 = new Milestone_Template__c(
            Name = 'Annual for each site + FRAr',
            Business__c = 'Citation',
            Start_Date_Days__c = 31,
            Due_Date_Days__c = 92,
            Reference_Date_field__c = 'StartDate',
            Recurrence__c = 3,
            Start_after_x_months__c = 1,
            Case_Type__c = 'Non Visits',
            Status__c = 'Active'
        );

        milestoneList.add(milestone1);
        milestoneList.add(milestone2);

        insert milestoneList;

        WorkType workTypeObj1 = new WorkType(
            Name = 'Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = true
        );
        insert workTypeObj1;

        WorkType workTypeObj2 = new WorkType(
            Name = 'Non Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = false
        );
        insert workTypeObj2;

        WorkType workTypeObj3 = new WorkType(
            Name = 'Nonf Documentation',
            EstimatedDuration = 2.00,
            DurationType = 'Hours',
            ShouldAutoCreateSvcAppt = false
        );
        insert workTypeObj3;

        operatingHours hObj = new Operatinghours(Name = 'Test');
        insert hObj;

        ServiceTerritory stObj = new ServiceTerritory(
            Name = 'Atlas On-Boarding',
            OperatingHoursId = hObj.Id,
            isActive = true
        );
        insert stObj;

        Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[0].Id,
            Work_Type__c = workTypeObj1.Id,
            subject__c = 'Test subject',
            Description__c = 'Test Description',
            ServiceTerritory__c = stObj.Id,
            WorkOrder_Record_Type__c = 'Citation Standard',
            Site_Repeat_Rule__c = 'All',
            Service_Contact__c = 'Main Site Contact',
            meeting_type__c = 'HR 1st New',
            Customer_Friendly_Meeting_Name__c = 'Test'
        );

        insert mwtObj;

        Milestone_Work_Type__c mwtObj1 = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[0].Id,
            Work_Type__c = workTypeObj2.Id,
            subject__c = 'Test subject2',
            Description__c = 'Test Description2',
            ServiceTerritory__c = stObj.Id,
            Dependency__c = mwtObj.Id,
            Service_Contact__c = 'PEL Service Contact'
        );

        Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[0].Id,
            Work_Type__c = workTypeObj1.Id,
            subject__c = 'Test subject2',
            Description__c = 'Test Description2',
            ServiceTerritory__c = stObj.Id,
            Service_Contact__c = 'Main User',
            meeting_type__c = 'HR 1st New',
            Customer_Friendly_Meeting_Name__c = 'Test'
        );
        Milestone_Work_Type__c mwtObj11 = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[1].Id,
            Work_Type__c = workTypeObj2.Id,
            subject__c = 'Test subject2',
            Description__c = 'Test Description2',
            ServiceTerritory__c = stObj.Id,
            Dependency__c = mwtObj.Id,
            Site_Repeat_Rule__c = '',
            Service_Contact__c = 'Contract Signatory'
        );

        List<Product_Milestone__c> pmList = new List<Product_Milestone__c>();
        Product_Milestone__c pmObj = new Product_Milestone__c(
            Milestone_Template__c = milestoneList[0].Id,
            Product__c = [
                SELECT id
                FROM product2
                WHERE name = 'H&S Compliance Core'
            ]
            .id,
            Type__c = 'New'
        );
        Product_Milestone__c pmObj2 = new Product_Milestone__c(
            Milestone_Template__c = milestoneList[1].Id,
            Product__c = [
                SELECT id
                FROM product2
                WHERE name = 'H&S Compliance Service'
            ]
            .id,
            Type__c = 'New'
        );
        pmList.add(pmObj);
        pmList.add(pmObj2);
        insert pmList;

        income_Direct_Debit__c iDD = new Income_Direct_Debit__c(
            Company__c = SDP_Test_Helper.company.Id,
            Default_Company_Direct_Debit__c = true,
            Name = 'DD00000001',
            DD_Status__c = 'First Collection',
            Account__c = acc.Id,
            DD_Collection_Day__c = '7',
            DD_Bank_Sort_Code__c = '200000',
            DD_Collection_Period__c = 'Monthly',
            DD_Bank_Account_Number__c = '55779911',
            DD_Collection_Stretch__c = '1',
            DD_Bank_Account_Name__c = 'Mr William Smith',
            DD_Collection_Type__c = 'Fixed',
            DD_First_Collection_Amount__c = 0.00,
            DD_Collection_Reference__c = 'Monthly Subscription',
            DD_Ongoing_Collection_Amount__c = 0.00,
            DD_Final_Collection_Amount__c = 0.00,
            DD_Start_Date__c = Date.today(),
            DD_First_Collection_Date__c = Date.today().addDays(8),
            DD_Next_Collection_Date__c = Date.today().addDays(8)
        );
        insert IDD;

        c2g__codaInvoice__c invoice = SDP_Test_Helper.createInvoice(
            SDP_Test_Helper.company.Id,
            acc.Id,
            System.today(),
            10.0,
            IDD.Id
        );

        income_Debit_History__c iDDH = new Income_Debit_History__c(
            Income_Direct_Debit__c = IDD.Id, // Income Direct Debit
            Amount__c = 10.00, // Amount
            DD_Status__c = 'First Collection', // DD Status
            DD_Collection_Date__c = Date.today(), // DD Collection Date
            DD_Stage__c = 'Submitted' // DD Stage
        );
        insert IDDH;

        Sales_Invoice_Direct_Debit_Payment__c junc = new Sales_Invoice_Direct_Debit_Payment__c();
        junc.Income_Debit_History__c = IDDH.Id;
        junc.Sales_Invoice__c = invoice.Id;
        insert junc;
    }
    @isTest
    private static void testExcuteBatch() {
        Test.startTest();
        c2g__codaInvoice__c x = [
            SELECT Id, c2g__InvoiceStatus__c
            FROM c2g__codaInvoice__c
            LIMIT 1
        ];
        SDP_Test_Helper.postInvoice(x.Id);
         SDP_Queueable qJob = new  SDP_Queueable('SELECT Id, c2g__InvoiceStatus__c FROM c2g__codaInvoice__c LIMIT 1');
         System.enqueueJob(qJob);
        System.assertEquals('In Progress', x.c2g__InvoiceStatus__c, 'success');
        Test.stopTest();
    }
}