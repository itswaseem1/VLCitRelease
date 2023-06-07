@isTest
public class SDP_ScheduleBundleBatchTest {
    @testSetup
    static void setup() {
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.put('Name', '$$$$$$$Product Services$$$$$$$');
        acc.put('CurrencyIsoCode', 'USD');
        acc.put('AccountNumber', 'CD656092');
        acc.put('Type', 'Customer - Direct');
        acc.put('Industry', 'Apparel');
        acc.put('AnnualRevenue', 350000000);
        acc.put('Ownership', 'Public');
        acc.put('Rating', 'Warm');
        acc.put('Phone', '(336) 222-7000');
        acc.put('Fax', '(336) 222-8000');
        acc.put('Website', 'http://www.financialforce.com');
        acc.put('TickerSymbol', 'BTXT');
        acc.put('NumberOfEmployees', 9000);
        acc.put('SIC', '546732');

        insert acc;

        Account acc2 = new Account();
        acc2.put('Name', 'test123');
        acc2.put('CurrencyIsoCode', 'USD');
        acc2.put('AccountNumber', 'CD656092');
        acc2.put('Type', 'Customer - Direct');
        acc2.put('Industry', 'Apparel');
        acc2.put('AnnualRevenue', 350000000);
        acc2.put('Ownership', 'Public');
        acc2.put('Rating', 'Warm');
        acc2.put('Phone', '(336) 222-7000');
        acc2.put('Fax', '(336) 222-8000');
        acc2.put('Website', 'http://www.financialforce.com');
        acc2.put('TickerSymbol', 'BTXT');
        acc2.put('NumberOfEmployees', 9000);
        acc2.put('SIC', '546732');

        insert acc2;

        List<Site__c> siteList = new List<Site__c>();
        Site__c accSite1 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Main Site'
        );
        siteList.add(accSite1);
        Site__c accSite2 = new Site__c(
            Account__c = acc2.Id,
            Active__c = true,
            Site_Type__c = 'Other Site'
        );
        siteList.add(accSite2);

        insert siteList;

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
            Dependency__c = mwtObj.Id
        );

        Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(
            Milestone_Template__c = milestoneList[0].Id,
            Work_Type__c = workTypeObj1.Id,
            subject__c = 'Test subject2',
            Description__c = 'Test Description2',
            ServiceTerritory__c = stObj.Id,
            meeting_type__c = 'HR 1st New',
     		Customer_Friendly_Meeting_Name__c = 'Test'
        );

        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.put('Name', 'H&S Compliance Core');
        prod.put('ProductCode', 'HS-Compliance');
        prod.put('IsActive', true);
        insert prod;

        Product2 prod2 = new Product2();
        prod2.put('Name', 'H&S Compliance Service');
        prod2.put('ProductCode', 'HS-Compliance');
        prod2.put('IsActive', true);
        insert prod2;

        insert prodList;

        List<Product_Milestone__c> pmList = new List<Product_Milestone__c>();
        Product_Milestone__c pmObj = new Product_Milestone__c(
            Milestone_Template__c = milestoneList[0].Id,
            Product__c = prod.id,
            Type__c = 'New'
        );
        Product_Milestone__c pmObj2 = new Product_Milestone__c(
            Milestone_Template__c = milestoneList[1].Id,
            Product__c = prod2.id,
            Type__c = 'New'
        );
        pmList.add(pmObj);
        pmList.add(pmObj2);
        insert pmList;

        Milestone_Bundle_Template__c mb = new Milestone_Bundle_Template__c(
            Entry_Milestone_Template_1__c = milestoneList[0].Id,
            Entry_Milestone_Template_2__c = milestoneList[1].Id,
            Vicinity__c = 2,
            Result_Milestone_Template__c = milestoneList[0].Id
        );

        insert mb;
    }

    static testMethod void activateContracts() {
        User systemTestUser = TestHarness.createTestUser();
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'SDP_PermissionSet'
        ];
        insert new PermissionSetAssignment(
            AssigneeId = systemTestUser.id,
            PermissionSetId = ps.Id
        );

        System.runAs(systemTestUser) {
            //ARRANGE
            List<Product2> testProducts = [
                SELECT id, Name
                FROM product2
                WHERE NAME IN ('H&S Compliance Service', 'H&S Compliance Core')
            ];
            EntitlementTemplate eTobj = new EntitlementTemplate(
                Name = 'Test',
                Type = 'Web Support'
            );

            insert eTobj;

            Productentitlementtemplate petObj = new Productentitlementtemplate(
                EntitlementTemplateId = eTobj.Id,
                Product2Id = testProducts[0].Id
            );
            insert petObj;
            customSettings();
           pricebook2 pb = new pricebook2(
        name = 'tst',
        isactive = true,
        Annual_Turnover_Minimum__c = 0,
        Annual_Turnover_Maximum__c = 50
      );
      insert pb;
      account a = new account(name = 'test', c2g__CODAInvoiceEmail__c = 'test@test.com');
      insert a;
      fferpcore__Company__c c = new fferpcore__Company__c(name = 'test');
      insert c;
      ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id);
      insert cont;

      product2 p1 = new product2(name = 'a', isactive = true);
      insert p1;

      ffbc__SoftDate__c sdf = new ffbc__SoftDate__c(ffbc__Definition__c = 'MB');
      insert sdf;

      date d = date.today().adddays(7);
      ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(
        service_start_date__c = date.today(),
        service_end_date__c = date.today(),
        ffbc__Quantity__c = 3,
        ffbc__SalesPriceOverride__c = 199.99,
        ffbc__Contract__c = cont.id,
        ffbc__ProductService__c = p1.id,
        ffbc__BillingTerm__c = sdf.id,
        ffbc__FirstBillDate__c = d,
        ffbc__BillingType__c = 'Recurring Fixed'
      );
      insert l;

      ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
      request.ContractIds = new Set<Id>{ cont.id };
      request.MonthsToGenerate = 0;

      ffbc.ContractsService.activation(request);
		 ffbc__Contract__c billingContractObj = [
        SELECT Id, ffbc__Status__c
        FROM ffbc__Contract__c
        LIMIT 1
      ];
            service_delivery_Plan__c sd = [
                SELECT Id
                FROM service_delivery_Plan__c
                LIMIT 1
            ];
            List<Milestone_Template__c> mt = [
                SELECT Id
                FROM Milestone_Template__c
            ];
            List<Case> cseList = new List<case>();
            Case caseObj = new Case();
            caseObj.STart_date__c = date.today();
            caseObj.Origin = 'Service Delivery Milestone';
            caseObj.Status = 'Pending Start';
            caseObj.Anniversary_Date__c = date.today();
            caseObj.Milestone_Template__c = mt[0].Id;
            caseObj.Billing_Contract__c = billingContractObj.Id;
            caseObj.Billing_Contract_Line_Item__c = l.Id;
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('H&S Visits')
                .getRecordTypeId();
            caseObj.Service_Delivery_Plan__c = sd.Id;
            cseList.add(caseObj);

            Case caseObj2 = new Case();
            caseObj2.STart_date__c = date.today();
            caseObj2.Origin = 'Service Delivery Milestone';
            caseObj2.Status = 'Pending Start';
            caseObj2.Milestone_Template__c = mt[1].Id;
            caseObj2.Billing_Contract__c = billingContractObj.Id;
            caseObj2.Billing_Contract_Line_Item__c = l.Id;
            caseObj2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('H&S Visits')
                .getRecordTypeId();
            caseObj2.Service_Delivery_Plan__c = sd.Id;
            caseObj2.Anniversary_Date__c = date.today().addDays(1);
            cseList.add(caseObj2);
            
            Case caseObj3 = new Case();
            caseObj3.STart_date__c = date.today();
            caseObj3.Origin = 'Service Delivery Milestone';
            caseObj3.Status = 'Pending Start';
            caseObj3.Milestone_Template__c = mt[1].Id;
            caseObj3.Billing_Contract__c = billingContractObj.Id;
            caseObj3.Billing_Contract_Line_Item__c = l.Id;
            caseObj3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('H&S Visits')
                .getRecordTypeId();
            caseObj3.Service_Delivery_Plan__c = sd.Id;
            caseObj3.Anniversary_Date__c = date.today().addDays(2);
            cseList.add(caseObj3);
            
            Case caseObj4 = new Case();
            caseObj4.STart_date__c = date.today();
            caseObj4.Origin = 'Service Delivery Milestone';
            caseObj4.Status = 'Pending Start';
            caseObj4.Anniversary_Date__c = date.today().addDays(2);
            caseObj4.Milestone_Template__c = mt[0].Id;
            caseObj4.Billing_Contract__c = billingContractObj.Id;
            caseObj4.Billing_Contract_Line_Item__c = l.Id;
            caseObj4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get('H&S Visits')
                .getRecordTypeId();
            caseObj4.Service_Delivery_Plan__c = sd.Id;
            cseList.add(caseObj4);
            test.startTest();
            insert cseList;

            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String cronExp = '0 6 * * * ?';
            String jobId = System.schedule(
                'bundlexghhj',
                cronExp,
                new SDP_ScheduleBundleBatch()
            );
            CronTrigger ct = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE id = :jobId
            ];
            System.assertEquals(0, ct.TimesTriggered, 'success');
            System.assertEquals(
                'Active',
                billingContractObj.ffbc__Status__c,
                'success'
            );
            Test.stopTest();
        }
    }

    private static void customSettings() {
        c2g__codaGeneralLedgerAccount__c gl = new c2g__codaGeneralLedgerAccount__c();
        gl.Name = '45100 - Trade Debtors Control';
        gl.Account_Description__c = 'Trade Debtors Control';
        gl.c2g__ReportingCode__c = '45100';
        gl.c2g__ExternalId__c = '45100 - Trade Debtors Control';
        gl.Sub_Ledger_Required__c = 'Tax';
        gl.c2g__TrialBalance1__c = 'Balance Sheet';
        gl.c2g__Type__c = 'Balance Sheet';
        gl.c2g__TrialBalance2__c = 'Current Assets';
        gl.c2g__TrialBalance3__c = 'Trade debtors';
        insert gl;

        c2g__codaTaxCode__c tc = new c2g__codaTaxCode__c();
        tc.c2g__ExternalId__c = 'GB-O-STD';
        tc.CurrencyIsoCode = 'GBP';
        tc.ffvat__NetBox__c = 'Box 6';
        tc.ffvat__TaxBox__c = 'Box 1';
        tc.c2g__Description__c = 'UK Output Standard Rated';
        tc.c2g__GeneralLedgerAccount__c = gl.Id;
        insert tc;

        c2g__codaTaxCode__c tc1 = new c2g__codaTaxCode__c();
        tc1.c2g__ExternalId__c = 'GB-I-STD';
        tc1.CurrencyIsoCode = 'GBP';
        tc1.ffvat__NetBox__c = 'Box 7';
        tc1.ffvat__TaxBox__c = 'Box 4';
        tc1.c2g__Description__c = 'UK Input Standard Rated';
        tc1.c2g__GeneralLedgerAccount__c = gl.Id;
        insert tc1;

        ffbc__BackgroundProcessSettings__c settings = new ffbc__BackgroundProcessSettings__c();
        settings.ffbc__GenerateSchedulesQueueSize__c = 5;
        settings.ffbc__GenerateSchedulesSchedulesPerLine__c = 100;
        settings.ffbc__GenerateSchedulesScopeSize__c = 5;

        insert settings;
    }
}