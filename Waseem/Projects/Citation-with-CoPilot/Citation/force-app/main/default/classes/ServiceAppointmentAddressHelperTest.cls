//test coverage for SAAddressUpdater.cls class
@isTest
public class ServiceAppointmentAddressHelperTest {
	class JitterbitServer implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"status":"success"}');
			response.setStatusCode(200);
			return response;
		}
	}

	@testsetup
	static void datacreation() {
		UserRole userRole = new UserRole(Name = 'System Admin');
		insert userRole;

		User serviceTestUser = new User();
		serviceTestUser.FirstName = 'test';
		serviceTestUser.LastName = 'user';
		serviceTestUser.Username = 'testusersa@citation.co.uk';
		serviceTestUser.ProfileId = [SELECT id FROM Profile WHERE name = 'Citation Data Admin'].id;
		serviceTestUser.Email = 'testusersa@citation.co.uk';
		serviceTestUser.Alias = 'tuser';
		serviceTestUser.TimeZoneSidKey = 'Europe/London';
		serviceTestUser.LocaleSidKey = 'en_GB';
		serviceTestUser.EmailEncodingKey = 'ISO-8859-1';
		serviceTestUser.LanguageLocaleKey = 'en_US';
		serviceTestUser.UserRoleId = userRole.id;

		insert serviceTestUser;

		Set<String> licenseNameSet = new Set<String>{ 'Salesforce CPQ License', 'Field Service Scheduling', 'Field Service Mobile', 'Field Service StandassignedResourced', 'Field Service Dispatcher', 'CRM User' };
		List<PermissionSetLicense> permissionSetLicenseList = [SELECT Id FROM PermissionSetLicense WHERE MasterLabel IN :licenseNameSet];
		Set<Id> licenseNameSetIds = new Set<Id>();

		for (PermissionSetLicense psl : permissionSetLicenseList) {
			licenseNameSetIds.add(psl.Id);
		}

		//Assign permission set license to u from licenseNameSetIds
		List<PermissionSetLicenseAssign> permissionSetLicenseAssignList = new List<PermissionSetLicenseAssign>();

		for (Id licenseId : licenseNameSetIds) {
			PermissionSetLicenseAssign permissionSetLicenseAssign = new PermissionSetLicenseAssign();
			permissionSetLicenseAssign.AssigneeId = serviceTestUser.Id;
			permissionSetLicenseAssign.PermissionSetLicenseId = licenseId;
			permissionSetLicenseAssignList.add(permissionSetLicenseAssign);
		}

		insert permissionSetLicenseAssignList;

		list<string> permissionSetStringList = new List<string>{ 'Citation_Support_Admin', 'FSL_Resource_Permissions', 'SDP_PermissionSet', 'FSL_Admin_Permissions' };

		list<PermissionSet> permissionSetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSetStringList];

		List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();

		for (PermissionSet permissionSet : permissionSetList) {
			PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
			permissionSetAssignment.PermissionSetId = permissionSet.Id;
			permissionSetAssignment.AssigneeId = serviceTestUser.Id;
			permissionSetAssignmentList.add(permissionSetAssignment);
		}

		insert permissionSetAssignmentList;

		System.runAs(serviceTestUser) {
			OperatingHours oh = new OperatingHours();
			oh.Name = 'testoperatinghours';
			oh.TimeZone = 'Europe/London';
			insert oh;

			ServiceTerritory st = new ServiceTerritory();
			st.Name = 'testterritory';
			st.OperatingHoursId = oh.id;
			st.IsActive = true;
			insert st;

			ServiceResource sr = new ServiceResource();
			sr.Name = 'testresource';
			sr.RelatedRecordId = serviceTestUser.id;
			sr.ResourceType = 'T';
			sr.IsActive = true;
			insert sr;

			ServiceTerritoryMember stm = new ServiceTerritoryMember();
			stm.ServiceResourceId = sr.id;
			stm.ServiceTerritoryId = st.id;
			stm.Street = 'teststreet';
			stm.City = 'testcity';
			stm.State = 'teststate';
			stm.Country = 'testcountry';
			stm.PostalCode = 'testcode';
			stm.TerritoryType = 'P';
			stm.EffectiveStartDate = system.now();
			insert stm;

			Account testAccount1 = new Account(Name = 'Test Account 1');
			insert testAccount1;
			Contact con = new Contact(LastName = 'test', AccountId = testAccount1.id, Main_User__c = 'yes', Email = 'abc@def.co.uk.invalid');
			insert con;

			WorkOrder workOrderObj = new WorkOrder();
			workOrderObj.StartDate = date.today();
			workOrderObj.Description = 'Test';
			workOrderObj.Subject = 'Test';
			insert workOrderObj;

			ServiceAppointment serviceAppointment = new ServiceAppointment();
			serviceAppointment.EarliestStartTime = system.today();
			serviceAppointment.DueDate = system.today() + 10;
			serviceAppointment.Visit_Type__c = 'Virtual';
			serviceAppointment.ParentRecordId = workOrderObj.id;
			serviceAppointment.Status = 'None';
			serviceAppointment.SchedStartTime = system.today() + 1;
			serviceAppointment.SchedEndTime = system.today() + 2;
			serviceAppointment.Meeting_ID__c = '23467';
			serviceAppointment.Business__c = 'Citation';
			serviceAppointment.ContactId = con.Id;
			insert serviceAppointment;

			Test.setMock(HttpCalloutMock.class, new JitterbitServer());

			AssignedResource assignedResource = new AssignedResource();
			ServiceAppointment saupdate = [SELECT id, Visit_Type__c, status FROM ServiceAppointment];
			assignedResource.ServiceResourceId = [SELECT id FROM ServiceResource].id;
			assignedResource.ServiceAppointmentId = saupdate.id;
			insert assignedResource;
		}
	}

	@istest
	static void given_serviceAppointment_And_AssignedResourceExist_When_ServiceAppintmentAddress_Called_Then_ServiceAppointment_Address_Is_Updated() {
		User serviceTestUser = [SELECT Id FROM User WHERE Username = 'testusersa@citation.co.uk'];
		//run the code as the serviceTestUser
		System.runAs(serviceTestUser) {
			test.startTest();

			List<id> serviceAppointmentId = new List<id>{ [SELECT id FROM ServiceAppointment].id };

            Assert.isNull([SELECT id, street FROM ServiceAppointment].street, 'success');

            SAAddressUpdater.updateServiceAppintmentAddress(serviceAppointmentId);

            System.assertEquals('teststreet', [SELECT id, street FROM ServiceAppointment].street, 'success');

			test.stopTest();
		}
	}

    @istest
    static void given_serviceAppointment_And_AssignedResourceExist_When_ServiceAppintmentAddress_For_QMS_Called_Then_ServiceAppointment_Address_Is_Updated() {
        User serviceTestUser = [SELECT Id FROM User WHERE Username = 'testusersa@citation.co.uk'];
		//run the code as the serviceTestUser
		System.runAs(serviceTestUser) {
			test.startTest();

			List<id> serviceAppointmentId = new List<id>{ [SELECT id FROM ServiceAppointment].id };

            Assert.isNull([SELECT id, street FROM ServiceAppointment].street, 'success');

            ServiceAppQMSAddressUpdate.updateServiceAppintmentAddress(serviceAppointmentId);

			System.assertEquals('teststreet', [SELECT id, street FROM ServiceAppointment].street, 'success');

			test.stopTest();
        }
    }
}