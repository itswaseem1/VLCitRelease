@isTest
public class SDP_QMSAutoCloseMissedBatchTest {
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

		accList.add(acc);

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

		accList.add(acc2);

		insert accList;

		List<Site__c> siteList = new List<Site__c>();
		Site__c accSite1 = new Site__c(Account__c = acc2.Id, Active__c = true, Site_Type__c = 'Main Site');
		siteList.add(accSite1);
		Site__c accSite2 = new Site__c(Account__c = acc2.Id, Active__c = true, Site_Type__c = 'Other Site');
		siteList.add(accSite2);

		insert siteList;

		Contact con = new Contact();
		con.LastName = 'test';
		con.AccountId = acc2.id;
		con.Main_User__c = 'yes';
		insert con;

		List<Site_Junction__c> siteContactList = new List<Site_Junction__c>();
		Site_Junction__c siteContact1 = new Site_Junction__c();
		siteContact1.Site_Junction__c = siteList[1].id;
		siteContact1.Account__c = acc2.id;
		siteContact1.Contact_Junction__c = con.id;
		siteContact1.Main_H_S_Contact__c = true;
		siteContact1.IsActive__c = true;

		Site_Junction__c siteContact2 = new Site_Junction__c();
		siteContact2.Site_Junction__c = siteList[1].id;
		siteContact2.Account__c = acc2.id;
		siteContact2.Contact_Junction__c = con.id;
		siteContact2.Main_PEL_Contact__c = true;
		siteContact2.IsActive__c = true;

		Site_Junction__c siteContact4 = new Site_Junction__c();
		siteContact4.Site_Junction__c = siteList[1].id;
		siteContact4.Account__c = acc2.id;
		siteContact4.Contact_Junction__c = con.id;
		siteContact4.Main_QMS_Contact__c = true;
		siteContact4.IsActive__c = true;

		Site_Junction__c siteContact3 = new Site_Junction__c();
		siteContact3.Site_Junction__c = siteList[1].id;
		siteContact3.Account__c = acc2.id;
		siteContact3.Contact_Junction__c = con.id;
		siteContact3.Secondary_PEL_Contact__c = true;
		siteContact3.IsActive__c = true;

		Site_Junction__c siteContact5 = new Site_Junction__c();
		siteContact5.Site_Junction__c = siteList[1].id;
		siteContact5.Account__c = acc2.id;
		siteContact5.Contact_Junction__c = con.id;
		siteContact5.Secondary_QMS_Contact__c = true;
		siteContact5.IsActive__c = true;

		siteContactList.add(siteContact1);
		insert siteContactList;

		MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContactList[0]);
		MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact2);
		MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact3);
		MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact4);
		MapContactOnWorkOrderQueuableHandler.getSiteContact2(siteContact5);

		Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(Name = 'Account 1 Citation Service Delivery Plan', Business__c = 'QMS', Account__c = acc.Id);

		insert servicedelPlanObj;

		List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
		Milestone_Template__c milestone1 = new Milestone_Template__c(Name = 'Annual ok', Business__c = 'QMS', Start_Date_Days__c = 0, Due_Date_Days__c = 2, Reference_Date_field__c = 'StartDate', Anniversary_Date_Months__c = 0, Case_Type__c = 'Non Visits', Status__c = 'Active');
		Milestone_Template__c milestone2 = new Milestone_Template__c(Name = 'Annual for each site + FRAr', Business__c = 'QMS', Start_Date_Days__c = 31, Due_Date_Days__c = 92, Reference_Date_field__c = 'StartDate', Recurrence__c = 3, Start_after_x_months__c = 1, Case_Type__c = 'Non Visits', Status__c = 'Active');

		milestoneList.add(milestone1);
		milestoneList.add(milestone2);

		insert milestoneList;

		list<WorkType> workTypeList = new List<WorkType>();
		WorkType workTypeObj1 = new WorkType(Name = 'Documentation', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = true);
		workTypeList.add(workTypeObj1);

		WorkType workTypeObj2 = new WorkType(Name = 'Non Documentation', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = false);
		workTypeList.add(workTypeObj2);

		WorkType workTypeObj3 = new WorkType(Name = 'Nonf Documentation', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = false);
		workTypeList.add(workTypeObj3);

		insert workTypeList;

		operatingHours hObj = new Operatinghours(Name = 'Test');
		insert hObj;

		ServiceTerritory stObj = new ServiceTerritory(Name = 'Atlas On-Boarding', OperatingHoursId = hObj.Id, isActive = true);
		insert stObj;

		Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[0].Id, Work_Type__c = workTypeObj1.Id, subject__c = 'Test subject', Description__c = 'Test Description', ServiceTerritory__c = stObj.Id, WorkOrder_Record_Type__c = 'QMS Visit Work', Site_Repeat_Rule__c = 'All', Service_Contact__c = 'Main Site Contact', meeting_type__c = 'HR 1st New', Customer_Friendly_Meeting_Name__c = 'Test');

		insert mwtObj;

		Milestone_Work_Type__c mwtObj1 = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[0].Id, Work_Type__c = workTypeObj2.Id, subject__c = 'Test subject2', Description__c = 'Test Description2', ServiceTerritory__c = stObj.Id, Dependency__c = mwtObj.Id, Service_Contact__c = 'PEL Service Contact');

		Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[0].Id, Work_Type__c = workTypeObj1.Id, subject__c = 'Test subject2', Description__c = 'Test Description2', ServiceTerritory__c = stObj.Id, Service_Contact__c = 'Main User', meeting_type__c = 'HR 1st New', Customer_Friendly_Meeting_Name__c = 'Test');
		Milestone_Work_Type__c mwtObj11 = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[1].Id, Work_Type__c = workTypeObj2.Id, subject__c = 'Test subject2', Description__c = 'Test Description2', ServiceTerritory__c = stObj.Id, Dependency__c = mwtObj.Id, Site_Repeat_Rule__c = '', Service_Contact__c = 'Contract Signatory');

		List<Product2> prodList = new List<Product2>();
		Product2 prod = new Product2();
		prod.put('Name', 'H&S Compliance Core');
		prod.put('ProductCode', 'HS-Compliance');
		prod.put('IsActive', true);
		prod.put('Business_Type__c', 'QMS');
		prodList.add(prod);

		Product2 prod2 = new Product2();
		prod2.put('Name', 'H&S Compliance Service');
		prod2.put('ProductCode', 'HS-Compliance');
		prod2.put('IsActive', true);
		prod2.put('Business_Type__c', 'QMS');
		prodList.add(prod2);

		insert prodList;

		List<Product_Milestone__c> pmList = new List<Product_Milestone__c>();
		Product_Milestone__c pmObj = new Product_Milestone__c(Milestone_Template__c = milestoneList[0].Id, Product__c = prod.id, Type__c = 'New');
		Product_Milestone__c pmObj2 = new Product_Milestone__c(Milestone_Template__c = milestoneList[1].Id, Product__c = prod2.id, Type__c = 'New');
		pmList.add(pmObj);
		pmList.add(pmObj2);
		insert pmList;
	}

	static testMethod void testAutoClosedMissed() {
		User systemTestUser = TestHarness.createTestUser(false);
		systemTestUser.userRoleId = [SELECT Id FROM UserRole WHERE Name = 'System Admin'].Id;
		insert systemTestUser;

		PermissionSet ps = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = 'SDP_PermissionSet'
		];
		insert new PermissionSetAssignment(AssigneeId = systemTestUser.id, PermissionSetId = ps.Id);

		System.runAs(systemTestUser) {
			//ARRANGE

			Account testAccount = TestHarness.createAccount(true);

			WorkType workTypeObj1 = new WorkType(Name = 'Documentationw', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = true);
			insert workTypeObj1;

			Test.startTest();

			// ffbc.ContractsService.ActivationRequest activateReq = new ffbc.ContractsService.ActivationRequest();
			// activateReq.ContractIds = new Set<Id>{ billingContract.id };

			//ACT

			Milestone_Template__c mt = [SELECT Id FROM Milestone_Template__c LIMIT 1];
			Case caseObj = new Case();
			caseObj.STart_date__c = date.today();
			caseObj.Origin = 'Service Delivery Milestone';
			caseObj.Status = 'Pending Start';
			caseObj.Milestone_Template__c = mt.Id;
			//  caseObj.Billing_Contract__c = billingContract.Id;
			// caseObj.Billing_Contract_Line_Item__c = billingContractLine.Id;
			caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QMS Visits').getRecordTypeId();

			insert caseObj;

			List<Milestone_Work_Type__c> mwt = [SELECT Id FROM Milestone_Work_Type__c LIMIT 1];

			workOrder woObj = new workOrder();
			woObj.StartDate = date.today();
			woObj.caseId = caseObj.Id;
			woObj.EndDate = date.today().adddays(10);
			woObj.Description = 'test';
			woObj.Subject = 'test';
			woObj.AccountId = testAccount.Id;
			woObj.WorkTypeId = workTypeObj1.Id;

			woObj.Milestone_Work_Type__c = mwt[0].Id;
			mwt[0].Service_Contact__c = 'Main User';
			update mwt[0];
			insert woObj;

			// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
			String cronExp = '0 6 * * * ?';
			String jobId = System.schedule('Autoclosebatch', cronExp, new SDP_ScheduleQMSAutoCloseMissedBatch());
			CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
				WHERE id = :jobId
			];
			System.assertEquals(0, ct.TimesTriggered, 'success');
			System.assertEquals('Pending Start', caseObj.Status, 'success');
			Test.stopTest();
		}
	}

	public static void customSettings() {
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