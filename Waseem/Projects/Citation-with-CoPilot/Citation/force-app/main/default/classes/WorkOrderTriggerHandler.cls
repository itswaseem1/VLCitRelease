/*
Name of Class:WorkOrderTriggerHandler
Purpose:Class for workOrderTrigger
Creation Date and Consultant Name: 09March21 by Atul Chougule
---------------------------------------------------------------------------------------
Update History:
*/
public with sharing class WorkOrderTriggerHandler {
  public static Map<WorkOrder, Id> accountWorkOrderMap = new Map<WorkOrder, Id>();
  public static Map<Id, Account> accountMap = new Map<Id, Account>();
  public static Map<WorkOrder, Id> workOrderMap = new Map<WorkOrder, Id>();
  public static Map<Id, WorkType> workTypeMap = new Map<Id, WorkType>();
  public static Map<String, Id> serviceTerritoryMap = new Map<String, Id>();
  public static Map<String, Id> queueMap = new Map<String, Id>();
  public static Map<Id, Site__c> workorderAccountSiteMap = new Map<Id, Site__c>();
  public static Set<Id> workIdSet = new Set<Id>();
  public static Map<WorkOrder, Id> accountSiteWorkOrderMap = new Map<WorkOrder, Id>();
  public static Map<Id, Account> workOrderAccountObjMap = new Map<Id, Account>();

  //The Work order cannot be marked as completed without the Service Appointment being marked as Completed / Cannot Complete / Cancelled
  public static void updateWorkOrder(List<WorkOrder> workOrderUpdated) {
    Set<Id> workRecordId = new Set<Id>();
    for (WorkOrder workOrdertoCheck : workOrderUpdated) {
      workRecordId.add(workOrdertoCheck.Id);
    }
    Set<Id> wOrderNotCompleted = new Set<Id>();
    list<ServiceAppointment> sAList = [
      SELECT Id, Status, ParentRecordId
      FROM ServiceAppointment
      WHERE ParentRecordId IN :workRecordId
    ];
    for (ServiceAppointment sAtoCheck : sAList) {
      if (
        sAtoCheck.Status != 'Completed' &&
        sAtoCheck.Status != 'Canceled' &&
        sAtoCheck.Status != 'Cannot Complete'
      ) {
        wOrderNotCompleted.add(sAtoCheck.ParentRecordId);
      }
    }
    for (WorkOrder workOrdertoCheck : workOrderUpdated) {
      if (
        wOrderNotCompleted.contains(workOrdertoCheck.Id) &&
        workOrdertoCheck.Status == 'Completed'
      ) {
        workOrdertoCheck.addError(
          'You can not set this Work order to Completed due to one or more related Service Appointments are not in status:Completed / Cannot Complete / Cancelled'
        );
      }
    }
  }

  public static void updateWorkOrderDetailsSDP(List<WorkOrder> workOrderList) {
    //Create Map with Accoutn Site and Parent Account
    for (WorkOrder workObj : workOrderList) {
      if (workObj.AccountSite__c != null) {
        accountSiteWorkOrderMap.put(workObj, workObj.AccountSite__c);
      } else if (workObj.AccountId != null) {
        accountWorkOrderMap.put(workObj, workObj.AccountId);
      }
    }

    //Get Address corresponding to Site Accounts
      getAccountSiteAddresses(workOrderList);

    //Get Address corresponding to MKain Accounts
      getAccountAddresses(workOrderList);

    populateAddressOnWorkOrder(workOrderList);
  }

  public static void getAccountSiteAddresses(List<WorkOrder> workOrderList) {
      
    for (Site__c accSiteObj : [
      SELECT
        Id,
        Account__c,
        City__c,
        Country__c,
        Postcode__c,
        County__c,
        Street__c
      FROM SIte__c
      WHERE Id IN :accountSiteWorkOrderMap.values() AND Active__c = TRUE
    ]) {
      generateWorkorderAccountSiteMap(accSiteObj, workOrderList);
    }
  }

  public static void getAccountAddresses(List<WorkOrder> workOrderList) {
    for (Account accObj : [
      SELECT
        Id,
        BillingCity,
        BillingCountry,
        BillingPostalCode,
        BillingState,
        BillingStreet
      FROM Account
      WHERE ID IN :accountWorkOrderMap.values()
    ]) {
      for (workOrder wobj : workOrderList) {
        if (wobj.AccountSite__c == null && wobj.AccountId == accObj.Id) {
          workOrderAccountObjMap.put(wobj.AccountId, accObj);
        }
      }
    }
  }

  public static void populateAddressOnWorkOrder(
    List<WorkOrder> workOrderItems
  ) {
    for (WorkOrder workObj : workOrderItems) {
      getAddressWorkOrderMapping(workObj);
    }
  }

  public static void updateDefaultsFromWorkType(List<WorkOrder> workOrderList) {
    for (WorkOrder workObj : workOrderList) {
      if (workObj.WorkTypeId != null) {
        workOrderMap.put(workObj, workObj.WorkTypeId);
        workIdSet.add(workObj.WorkTypeId);
      }
    }

    if (
      null != workOrderMap &&
      workOrderMap.size() > 0 &&
      workIdSet != null &&
      workIdSet.size() > 0
    ) {
      populateDefaultsFromWorkType(workOrderMap);
    }
  }

  public static void populateDefaultsFromWorkType(
    Map<WorkOrder, Id> workOrderMap
  ) {
    final String SERVICE_TER_ATLAS_ONBOARDING = 'Atlas On-Boarding';
    final String QUEUE_ATLAS_ONBOARDING = 'Atlas_On_boarding_Support_Line_1';

    getWorkTypeMap();
    getServiceTerritoryMap();
    getQueueMap();

    for (WorkOrder wObj : workOrderMap.keyset()) {
      if (workTypeMap.containskey(wObj.WorkTypeId)) {
        wObj.ServiceTerritoryId = serviceTerritoryMap.get(
            SERVICE_TER_ATLAS_ONBOARDING
          ) != null
          ? serviceTerritoryMap.get(SERVICE_TER_ATLAS_ONBOARDING)
          : null;
        wObj.OwnerId = queueMap.get(QUEUE_ATLAS_ONBOARDING) != null
          ? queueMap.get(QUEUE_ATLAS_ONBOARDING)
          : userinfo.getUserId();
      }
    }
  }

  public static void getWorkTypeMap() {
    final String WORK_TYPE_NAME_ATLAS_ONBOARDING = 'Atlas Onboarding Meeting';

    for (workType workTypeObj : [
      SELECT Id, Name
      FROM WorkType
      WHERE Id IN :workIdSet AND Name = :WORK_TYPE_NAME_ATLAS_ONBOARDING
    ]) {
      workTypeMap.put(workTypeObj.Id, workTypeObj);
    }
  }

  public static void getServiceTerritoryMap() {
    for (ServiceTerritory terObj : [
      SELECT Id, Name
      FROM ServiceTerritory
      WHERE isActive = TRUE
    ]) {
      serviceTerritoryMap.put(terObj.Name, terObj.Id);
    }
  }

  public static void getQueueMap() {
    for (Group groupObj : [
      SELECT Id, DeveloperName
      FROM GROUP
      WHERE Type = 'QUEUE'
      LIMIT 100
    ]) {
      queueMap.put(groupObj.DeveloperName, groupObj.Id);
    }
  }

  public static void generateWorkorderAccountSiteMap(Site__c accSiteObj, List<WorkOrder> workOrderList) {
    for (workOrder wobj : workOrderList) {
      if (wobj.AccountSite__c != null && wobj.AccountSite__c == accSiteObj.Id) {
        workorderAccountSiteMap.put(wobj.AccountSite__c, accSiteObj);
      }
    }
  }

  public static void getAddressWorkOrderMapping(workOrder workObj) {
    if (workObj.AccountSite__c != null) {
      workObj.City = workorderAccountSiteMap.get(workObj.AccountSite__c)
        ?.City__c;
      workObj.PostalCode = workorderAccountSiteMap.get(workObj.AccountSite__c)
        ?.Postcode__c;
      workObj.Country = workorderAccountSiteMap.get(workObj.AccountSite__c)
        ?.Country__c;
      workObj.State = workorderAccountSiteMap.get(workObj.AccountSite__c)
        ?.County__c;
      workObj.Street = workorderAccountSiteMap.get(workObj.AccountSite__c)
        ?.Street__c;
    } else {
      workObj.City = workOrderAccountObjMap.get(workObj.AccountId)?.BillingCity;
      workObj.PostalCode = workOrderAccountObjMap.get(workObj.AccountId)
        ?.BillingPostalCode;
      workObj.Country = workOrderAccountObjMap.get(workObj.AccountId)
        ?.BillingCountry;
      workObj.State = workOrderAccountObjMap.get(workObj.AccountId)
        ?.BillingState;
      workObj.Street = workOrderAccountObjMap.get(workObj.AccountId)
        ?.BillingStreet;
    }
  }
    public static void addSkillRequirementInWO(List<WorkOrder> workOrders) {
        
        Skill skl = [SELECT DeveloperName, MasterLabel, Id FROM Skill where DeveloperName='Fire_Risk_Assessment' limit 1];
        List<WorkOrder> workorderWithST = [select id from workOrder where id in :workOrders and ServiceTerritory.Name =: Label.FRA_Territory];
        List<SkillRequirement> skillre = new List<SkillRequirement>();
        for(WorkOrder wo:workorderWithST){
            SkillRequirement sr = new SkillRequirement();
            sr.SkillId=skl.id;
            sr.RelatedRecordId=wo.id;
            skillre.add(sr);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            insert skillre;
        } catch(DmlException e) {
            Database.rollback(sp);
        }
    }
}