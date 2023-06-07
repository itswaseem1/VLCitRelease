@isTest
public class Generate_CheckEligibleRecommendationTest {
	@testSetup
	public static void setup() {
		List<Account> accList = new List<Account>();

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
		acc2.put('QMS_Sector__c', 'Construction');
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
		con.Email = 'test@citation.co.uk';
		con.Phone = '565656565656';
		con.MobilePhone = '6767676767676';
		con.Position__c = 'Manager';
		insert con;

		Service_Delivery_Plan__c servicedelPlanObj = new Service_Delivery_Plan__c(Name = 'Account 1 Citation Service Delivery Plan', Business__c = 'Citation', Account__c = acc2.Id);

		insert servicedelPlanObj;

		List<Milestone_Template__c> milestoneList = new List<Milestone_Template__c>();
		Milestone_Template__c milestone1 = new Milestone_Template__c(Name = 'Welcome Call', Business__c = 'Citation', Start_Date_Days__c = 0, Due_Date_Days__c = 2, Reference_Date_field__c = 'StartDate', Anniversary_Date_Months__c = 0, Case_Type__c = 'Non Visits', Status__c = 'Active');
		Milestone_Template__c milestone2 = new Milestone_Template__c(Name = 'Annual for each site + FRAr', Business__c = 'Citation', Start_Date_Days__c = 31, Due_Date_Days__c = 92, Reference_Date_field__c = 'StartDate', Recurrence__c = 3, Start_after_x_months__c = 1, Case_Type__c = 'Non Visits', Status__c = 'Active');

		milestoneList.add(milestone1);
		milestoneList.add(milestone2);

		insert milestoneList;

		WorkType workTypeObj1 = new WorkType(Name = 'Documentation', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = true);
		insert workTypeObj1;

		WorkType workTypeObj2 = new WorkType(Name = 'Non Documentation', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = false);
		insert workTypeObj2;

		WorkType workTypeObj3 = new WorkType(Name = 'Nonf Documentation', EstimatedDuration = 2.00, DurationType = 'Hours', ShouldAutoCreateSvcAppt = false);
		insert workTypeObj3;

		operatingHours hObj = new Operatinghours(Name = 'Test');
		insert hObj;

		ServiceTerritory stObj = new ServiceTerritory(Name = 'Atlas On-Boarding', OperatingHoursId = hObj.Id, isActive = true);
		insert stObj;

		Milestone_Work_Type__c mwtObj = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[0].Id, Work_Type__c = workTypeObj1.Id, subject__c = 'Test subject', Description__c = 'Test Description', ServiceTerritory__c = stObj.Id, WorkOrder_Record_Type__c = 'Citation Standard', Site_Repeat_Rule__c = 'All', Service_Contact__c = 'Main Site Contact', Customer_Friendly_Meeting_Name__c = 'Test', Meeting_Type__c = 'HR Review');

		insert mwtObj;

		Milestone_Work_Type__c mwtObj1 = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[0].Id, Work_Type__c = workTypeObj2.Id, subject__c = 'Test subject2', Description__c = 'Test Description2', ServiceTerritory__c = stObj.Id, Dependency__c = mwtObj.Id, Service_Contact__c = 'PEL Service Contact');

		Milestone_Work_Type__c mwtObj2 = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[0].Id, Work_Type__c = workTypeObj1.Id, subject__c = 'Test subject2', Description__c = 'Test Description2', ServiceTerritory__c = stObj.Id, Service_Contact__c = 'Main User');
		Milestone_Work_Type__c mwtObj11 = new Milestone_Work_Type__c(Milestone_Template__c = milestoneList[1].Id, Work_Type__c = workTypeObj2.Id, subject__c = 'Test subject2', Description__c = 'Test Description2', ServiceTerritory__c = stObj.Id, Dependency__c = mwtObj.Id, Site_Repeat_Rule__c = '', Service_Contact__c = 'Contract Signatory');

		List<Product2> prodList = new List<Product2>();

		Product2 prod = new Product2();
		prod.put('Name', 'Fire Risk Assessment - Tailored Package');
		prod.put('ProductCode', 'FRA-TP');
		prod.put('IsActive', true);
		insert prod;

		Product2 prod2 = new Product2();
		prod2.put('Name', 'On-Site HR – Training – Full Day');
		prod2.put('ProductCode', 'OSHR-TFD');
		prod2.put('IsActive', true);
		insert prod2;

		Product2 prod3 = new Product2();
		prod3.put('Name', 'ISO 45001');
		prod3.put('ProductCode', 'QMS-ISO45001-A');
		prod3.put('IsActive', true);
		prod3.put('Family', 'QMS');

		insert prod3;

		Product2 prod4 = new Product2();
		prod4.put('Name', 'HR Workplace Expert');
		prod4.put('ProductCode', 'HR-CSE');
		prod4.put('IsActive', true);
		insert prod4;

		insert prodList;

		List<Product_Milestone__c> pmList = new List<Product_Milestone__c>();
		Product_Milestone__c pmObj = new Product_Milestone__c(Milestone_Template__c = milestoneList[0].Id, Product__c = prod.id, Type__c = 'New');
		Product_Milestone__c pmObj2 = new Product_Milestone__c(Milestone_Template__c = milestoneList[1].Id, Product__c = prod2.id, Type__c = 'New');
		pmList.add(pmObj);
		pmList.add(pmObj2);

		insert pmList;

		Recommandation_Role_Category__mdt mdtsetting = new Recommandation_Role_Category__mdt();
		mdtsetting.DeveloperName = 'Citation_Client_Support_Executive';
		mdtsetting.Label = 'Citation Client Support Manager';
		mdtsetting.ATLAS__c = true;
		mdtsetting.EAP__c = true;
		mdtsetting.FRA__c = true;
		mdtsetting.H_S__c = false;
		mdtsetting.HR__c = false;

		QMS_Recommandation_List__mdt qmsMdt = new QMS_Recommandation_List__mdt();
		qmsMdt.DeveloperName = 'Construction';
		qmsMdt.Label = 'Construction';
		qmsMdt.SMAS_Referral__c = true;
		qmsMdt.Upsell_ISO14001__c = false;
		qmsMdt.Upsell_ISO27001__c = false;
		qmsMdt.Upsell_ISO45001__c = true;
		qmsMdt.Upsell_ISO9001__c = false;

		customSettings();
	}

	public static testMethod void activateContracts() {
		Profile pf = [SELECT Id FROM Profile WHERE Name = 'Citation Data Admin'];

		UserRole ur = new UserRole(Name = 'Citation Client Support Manager');
		insert ur;

		User u = new User(UserRoleId = ur.Id, ProfileId = pf.Id, Username = 'testtermsconditions1234423@citation.co.uk', Alias = 'batman', Email = 'testtermsconditions1234423@citation.co.uk', EmailEncodingKey = 'UTF-8', Firstname = 'Bruce1', Lastname = 'Wayne1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
		insert u;

		//Query Permission Set license
		PermissionSetLicense psLicense = [SELECT Id, MasterLabel FROM PermissionSetLicense WHERE MasterLabel = 'Salesforce CPQ License'];

		// Create a Permission Set License
		PermissionSetLicenseAssign psl = new PermissionSetLicenseAssign(PermissionSetLicenseId = psLicense.Id, AssigneeId = u.Id);
		insert psl;

		List<PermissionSetAssignment> psa1 = new List<PermissionSetAssignment>();
		List<PermissionSet> permissionList = [SELECT id FROM Permissionset WHERE name = 'General_S360_Permission_Set' OR name = 'SDP_PermissionSet' OR name = 'Citation_Support_Admin' OR name = 'S360_Deployment_Permissions'];

		for (PermissionSet p : permissionList) {
			psa1.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = p.id));
		}

		insert psa1;

		System.runAs(u) {
			//ARRANGE
			List<Product2> testProducts = [
				SELECT id, Name
				FROM product2
				WHERE NAME IN ('Fire Risk Assessment - Tailored Package', 'On-Site HR – Training – Full Day')
			];

			EntitlementTemplate eTobj = new EntitlementTemplate(Name = 'Test', Type = 'Web Support');

			insert eTobj;

			Productentitlementtemplate petObj = new Productentitlementtemplate(EntitlementTemplateId = eTobj.Id, Product2Id = testProducts[0].Id);
			insert petObj;

			pricebook2 pb = new pricebook2(name = 'tst', isactive = true, Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50);
			insert pb;
			account a = [SELECT ID FROM account LIMIT 1];

			fferpcore__Company__c c = new fferpcore__Company__c(name = 'test');
			insert c;
			ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id);
			insert cont;

			product2 p1 = new product2(name = 'ISO 45001', isactive = true);
			insert p1;

			ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c = 'MB');
			insert sd;

			date d = date.today().adddays(7);
			ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(service_start_date__c = date.today(), service_end_date__c = date.today(), ffbc__Quantity__c = 3, ffbc__SalesPriceOverride__c = 199.99, ffbc__Contract__c = cont.id, ffbc__ProductService__c = p1.id, ffbc__BillingTerm__c = sd.id, ffbc__FirstBillDate__c = d, ffbc__BillingType__c = 'Recurring Fixed');
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
			Milestone_Template__c mt = [
				SELECT Id, Case_Type__c, Anniversary_Date_Months__c, Business__c, Dependent_Milestone__c, Due_Date_Days__c, Recurrence__c, Start_after_x_months__c, Name, Start_Date_Days__c, Reference_Date_field__c, Owning_Team__c, Milestone_Description__c, Milestone_Subject__c, Entitlement__c
				FROM Milestone_Template__c
				LIMIT 1
			];

			List<Recommendation> recs = new List<Recommendation>();
			List<Recommendation> recs1 = new List<Recommendation>();
			Recommendation recommendations = new Recommendation();

			Test.startTest();
			Recommendation rec = new Recommendation(Name = 'Submit an ISO referral', Description = 'Is this client interested in an ISO certification?', Category__c = 'Upsell', ActionReference = 'Complete_the_referral_form', AcceptanceLabel = 'Client interested', RejectionLabel = 'Discussed not interested', Priority__c = '1');

			Recommendation rec2 = new Recommendation(Name = 'Verify the clients contact details', Description = 'Can you verify existing contact details and fill in missing gaps (email, phone, mobile; position)?', Category__c = 'Data Enrichment', ActionReference = 'Contact_page_pop_ups_up', AcceptanceLabel = 'Review Contact Details', RejectionLabel = 'Cancel', Priority__c = '1');
			Recommendation rec3 = new Recommendation(Name = 'Submit an EAP referral', Description = 'Is this client interested in an Employee Assistance Programme?', Category__c = 'Upsell', ActionReference = 'Complete_the_referral_form', AcceptanceLabel = 'Client interested', RejectionLabel = 'Discussed not interested', Priority__c = '2');
			Recommendation rec4 = new Recommendation(Name = 'Upsell ISO45001', Description = 'Would the client benefit from ISO45001 to help manage their H&S processes and to win new business?', Category__c = 'Lead Generation', ActionReference = 'Create_Lead_For_QMS_Case', AcceptanceLabel = 'Client interested', RejectionLabel = 'Discussed not interested', Priority__c = '1');
			Recommendation rec5 = new Recommendation(Name = 'Upsell ISO27001', Description = 'Would the client benefit from ISO27001 to help manage their data and information security requirements?', Category__c = 'Lead Generation', ActionReference = 'Create_Lead_For_QMS_Case', AcceptanceLabel = 'Client interested', RejectionLabel = 'Discussed not interested', Priority__c = '6');
			Recommendation rec6 = new Recommendation(Name = 'SMAS Referral', Description = 'SMAS Referral', Category__c = 'Lead Generation', ActionReference = 'Create_Lead_For_QMS_Case', AcceptanceLabel = 'Client interested', RejectionLabel = 'Discussed not interested', Priority__c = '6');
			Recommendation rec7 = new Recommendation(Name = 'Citation Referral', Description = 'Citation Referral', Category__c = 'Lead Generation', ActionReference = 'Create_Lead_For_QMS_Case', AcceptanceLabel = 'Client interested', RejectionLabel = 'Discussed not interested', Priority__c = '6');

			recs.add(rec);
			recs.add(rec2);
			recs.add(rec3);
			recs.add(rec4);
			recs.add(rec5);
			recs.add(rec6);
			recs.add(rec7);

			recs1.addAll(recs);
			insert recs1;

			Case caseObj = new Case();
			caseObj.STart_date__c = date.today();
			caseObj.ContactId = [SELECT Id FROM contact LIMIT 1].Id;
			caseObj.AccountId = a.id;
			caseObj.Origin = 'Field Support - Phone';
			caseObj.Status = 'New';
			caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Support').getRecordTypeId();

			insert caseObj;
			System.assertEquals('Active', billingContractObj.ffbc__Status__c, 'success');

			Recommandation_Role_Category__mdt objSample = new Recommandation_Role_Category__mdt();
			QMS_Recommandation_List__mdt records = new QMS_Recommandation_List__mdt();
			Generate_GetAccountsBillingContract.GenerateRequest g = new Generate_GetAccountsBillingContract.GenerateRequest();
			g.caseId = caseObj.id;
			g.recommendations = recs1;

			List<Generate_GetAccountsBillingContract.GenerateRequest> input = new List<Generate_GetAccountsBillingContract.GenerateRequest>();
			input.add(g);

			List<List<Recommendation>> listrec = Generate_GetAccountsBillingContract.getAccountsBillingContract(input);

			CheckEligibleQMSRecommendation.getRecommandation recQms = new CheckEligibleQMSRecommendation.getRecommandation();
			recQms.caseId = caseObj.id;
			recQms.recommendations = recs1;

			List<CheckEligibleQMSRecommendation.getRecommandation> inputs = new List<CheckEligibleQMSRecommendation.getRecommandation>();
			inputs.add(recQms);

			List<List<Recommendation>> listrecs = CheckEligibleQMSRecommendation.getEligibleRecommandation(inputs);

			List<Recommendation> listRecommendation = new List<Recommendation>();

			for (list<Recommendation> recomds : listrecs) {
				for (Recommendation recommendation : recomds) {
					listRecommendation.add(recommendation);
				}
			}

			system.assertEquals(2, listRecommendation.size(), 'success');
			system.assertEquals('SMAS Referral', listRecommendation[0].Name);
			system.assertEquals('Citation Referral', listRecommendation[1].Name);

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