/**
 * @File Name          : CaseTriggerCreateWorkOrders.cls
 * @Description        :
 * @Author             : Maanas -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 2/22/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     2/22/2021      Initial Version
 **/
@SuppressWarnings('PMD')
public with sharing class CaseTriggerCreateWorkOrders {
  public static Map<Id, Case> filteredCaseMap = new Map<Id, Case>();
  public static Map<Id, Id> milestoneCaseMap = new Map<Id, Id>();
  public static Map<Id, Map<Id, Id>> milestoneWorkTypeMap = new Map<Id, Map<Id, Id>>();
  public static Map<Id, Milestone_Work_Type__c> milestoneWorkTypeIdMap = new Map<Id, Milestone_Work_Type__c>();
  public static Map<Id, Id> milestoneWorkTypeDependencyMap = new Map<Id, Id>();
  public static Map<Id, Id> milestoneWTWithWorkTypeMap = new Map<Id, Id>();
  public static Map<WorkOrder, Id> workOrderCaseMap = new Map<WorkOrder, Id>();
  public static List<WorkOrder> dependentWorkOrders = new List<WorkOrder>();
  public static Map<String, WorkOrder> workOrderKeyMap = new Map<String, WorkOrder>();
  public static List<WorkOrder> workOrderList = new List<WorkOrder>();
  public static List<WorkOrder> workOrdersToUpdate = new List<WOrkOrder>();
  public static Map<Id, Id> caseAccountMap = new Map<Id, Id>();
  public static Map<Id, Milestone_Template__c> milestoneTemplateMap = new Map<Id, Milestone_Template__c>();
  public static Map<Id, List<Site__c>> accountSiteMap = new Map<Id, List<Site__c>>();
  public static Map<String, Id> queueMap = new Map<String, Id>();//owning team
  public static Set<Id> assetSet = new Set<Id>();
  public static Map<Id,Id> assetCertificateMap = new Map<Id, Id>();
  public static boolean byPassDependency = false;
    
  public static void createWorkOrders(
    List<Case> newcases,
    Map<Id, Case> oldCasesMap
  ) {
    for (Case caseObj : newcases) {
      checkCaseStatus(caseObj, oldCasesMap);
      assetSet.add(caseObj.assetId);
    }
    if (filteredCaseMap.isEmpty()) {
      return;
    }
    populateAssetCertificateMap(assetSet);
    accountSiteMap = CaseTriggerCreateWorkOrders_Util.getAccountSites(
      caseAccountMap
    );
    if(queueMap.isEmpty() || queueMap.size() == 0 ){//owning team
      queueMap = CaseTriggerCreateWorkOrders_Util.getQueues();
    }
    populateWorkTypeMap(milestoneCaseMap);
    createWorkOrdersMapping(filteredCaseMap);
  }
  public static void populateWorkTypeMap(Map<Id, Id> milestoneCaseMap) {
     
      
      
      
    for (Milestone_Template__c milestoneObj : [
      SELECT
        Id,
        Business__c,
        (
          SELECT
            Id,
            Work_Type__c,
            Work_Type__r.Name,
            Subject__c,
            Description__c,
            ServiceTerritory__c,
            Business_Hours__c,
            Owning_Team__c,//owning team
            Visit_Type__c,
            Entitlement__c,
            Start_Days__c,
            End_Days__c,
            Dependency__c,
            Dependency__r.Milestone_Template__c,
            Service_Contact__c,
            Site_Repeat_Rule__c,
            WorkOrder_Record_Type__c
          FROM Milestone_Work_Types__r
        )
      FROM Milestone_Template__c
      WHERE ID IN :milestoneCaseMap.values()
      WITH SECURITY_ENFORCED
    ]) {
            
      populateMilestoneWorkTypeData(milestoneObj);
    }
    byPassDependency = true;
    for (Milestone_Template__c milestoneObj : [
      SELECT
        Id,
        Business__c,
        (
          SELECT
            Id,
            Work_Type__c,
            Work_Type__r.Name,
            Subject__c,
            Description__c,
            ServiceTerritory__c,
            Business_Hours__c,
            Owning_Team__c,//owning team
            Visit_Type__c,
            Entitlement__c,
            Start_Days__c,
            End_Days__c,
            Dependency__c,
            Service_Contact__c,
            Site_Repeat_Rule__c,
            WorkOrder_Record_Type__c
          FROM Milestone_Work_Types__r
        )
      FROM Milestone_Template__c
      WHERE ID IN :milestoneWorkTypeDependencyMap.values()
      WITH SECURITY_ENFORCED
    ]) {
            
      populateMilestoneWorkTypeData(milestoneObj);
    }
    
  }
  public static void createWorkOrdersMapping(Map<Id, Case> filteredCaseMap) {
    Map<Id, Id> caseWorkTypeMap = new Map<Id, Id>();
    for (Id caseId : filteredCaseMap.keyset()) {
      if (
        milestoneWorkTypeMap.containsKey(
          filteredCaseMap.get(caseId).Milestone_Template__c
        )
      ) {
        for (
          Id milestoneWorkTypeId : milestoneWorkTypeMap.get(
              filteredCaseMap.get(caseId).Milestone_Template__c
            )
            .keyset()
        ) {
          WorkOrder workOrderObj = new WorkOrder();
          Map<Id, Id> milestoneWtypeMap = milestoneWorkTypeMap.get(
            filteredCaseMap.get(caseId).Milestone_Template__c
          );
          Id reqWorkTypeId = milestoneWtypeMap.get(milestoneWorkTypeId);
          populateSiteWorkOrders(caseId, milestoneWorkTypeId);
        }
      }
    }
		
    if (
      null != workOrderList &&
      workOrderList.size() > 0 &&
      Schema.sObjectType.WorkOrder.isCreateable()
    ) {
      try {
        populateCertificateOnWorkOrders();
        insert workOrderList;
        prepareWorkOrderkeys();
        prepareDependencyRecords();
	CaseTriggerWorkOrdersHelper.updateDependentRecords(workOrderList);
	ID jobID = System.enqueueJob(new MapContactOnWorkOrderQueuable(workOrderList));
        } catch (Exception error) {
        system.debug(error.getMessage());
      }
    }
  }
  
  public static void prepareWorkOrderkeys() {
    for (workOrder workObj : workOrderList) {
      generateKeys(workObj);
      if (String.isNotBlank(workObj.Dependent_WorkType__c)) {
        dependentWorkOrders.add(workObj);
      }
    }
  }
  public static void prepareDependencyRecords() {
    for (workOrder workObj : dependentWorkOrders) {
      String key = workObj.AccountSite__c != null
        ? String.valueof(workObj.CaseId) +
          String.valueof(workObj.AccountSite__c) +
          String.valueof(workObj.Dependent_WorkType__c)
        : String.valueof(workObj.CaseId) +
          String.valueof(workObj.AccountId) +
          String.valueof(workObj.Dependent_WorkType__c);
      workOrder parentWorkOrder = workOrderKeyMap?.get(key) != null
        ? workOrderKeyMap?.get(key)
        : workOrderKeyMap
            ?.get(
              String.valueof(workObj.CaseId) +
              String.valueof(workObj.AccountId) +
              String.valueof(workObj.Dependent_WorkType__c)
            );
      if (null != parentWorkOrder.Id) {
        workObj.Dependent_Work_Order__c = parentWorkOrder.Id;
        workOrdersToUpdate.add(workObj);
      }
    }
  }
  public static void populateSiteWorkOrders(Id caseId, Id milestoneWorkTypeId) {
    List<Site__c> accountSiteList = new List<Site__c>();
    Case caseObj = filteredCaseMap?.get(caseId);
    List<WorkOrder> noSitesWorkOrderList = new List<WorkOrder>();
    Milestone_Template__c requiredMilestoneTemplate = milestoneTemplateMap.get(
      caseObj?.Milestone_Template__c
    );
    Milestone_Work_Type__c requiredMilestWorkType = milestoneWorkTypeIdMap.get(
      milestoneWorkTypeId
    );
    accountSiteList = accountSiteMap?.get(caseObj.AccountId);
    if (accountSiteList == null || accountSiteList.isEmpty()) {
      populateNoSiteData(caseObj, milestoneWorkTypeId);
      return;
    }
    if (
     // requiredMilestoneTemplate.Business__c == 'Citation' &&
      requiredMilestWorkType.Site_Repeat_Rule__c == 'All'
    ) {
      populateRepeatRuleAllData(caseObj, milestoneWorkTypeId);
    } else if (
      //requiredMilestoneTemplate.Business__c == 'Citation' &&
      (requiredMilestWorkType.Site_Repeat_Rule__c == '' ||
      requiredMilestWorkType.Site_Repeat_Rule__c == null)
    ) {
      populateRepeatRuleNoneData(caseObj, milestoneWorkTypeId);
    }
  }
  public static void populateMilestoneWorkTypeData(
    Milestone_Template__c milestoneObj
  ) {
    List<Id> workTypeList = new List<Id>();
    
    milestoneTemplateMap.put(milestoneObj.Id, milestoneObj);
    for (
      Milestone_Work_Type__c milWorkTypeObj : milestoneObj.Milestone_Work_Types__r
    ) {
      workTypeList.add(milWorkTypeObj.Work_Type__c);
      milestoneWTWithWorkTypeMap.put(
        milWorkTypeObj.Id,
        milWorkTypeObj.Work_Type__c
      );
      milestoneWorkTypeIdMap.put(milWorkTypeObj.Id, milWorkTypeObj);
        if(!byPassDependency){
            checkDependency(milWorkTypeObj);
        }
    }
    if (
      null == milestoneWTWithWorkTypeMap || milestoneWTWithWorkTypeMap.isEmpty()
    ) {
      return;
    }
    milestoneWorkTypeMap.put(milestoneObj.Id, milestoneWTWithWorkTypeMap);
  }
  
  public static void generateKeys(WorkOrder workObj) {
    Map<String, Workorder> singleKeymap = new Map<String, WOrkOrder>();
    singleKeymap = CaseTriggerWorkOrdersHelper.generateKeysHelper(workObj);
    workOrderKeyMap.putAll(singleKeymap);
  }
  public static void populateRepeatRuleAllData(
    Case caseObj,
    Id milestoneWorkTypeId
  ) {
    List<WorkOrder> noneSiteWorkOrderList = new List<WorkOrder>();
    DataWrapper repeatRuleNoneDataWrapper = new DataWrapper();
    repeatRuleNoneDataWrapper.milestoneWorkTypeId = milestoneWorkTypeId;
    repeatRuleNoneDataWrapper.caseObj = caseObj;
    repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap = milestoneWorkTypeIdMap;
    repeatRuleNoneDataWrapper.accountSiteMap = accountSiteMap;
    repeatRuleNoneDataWrapper.filteredCaseMap = filteredCaseMap;
	repeatRuleNoneDataWrapper.queueMap = queueMap;//owning team
      
    noneSiteWorkOrderList = CaseTriggerCreateWorkOrders_Util.populateRepeatRuleNoneDataUtil(
      repeatRuleNoneDataWrapper,
      new Set<String>{ 'Main Site', 'Other Site' }
    );
    if (null == noneSiteWorkOrderList || noneSiteWorkOrderList.isEmpty()) {
      return;
    }
    workOrderList.addAll(noneSiteWorkOrderList);
  }
  public static void populateRepeatRuleNoneData(
    Case caseObj,
    Id milestoneWorkTypeId
  ) {
    List<WorkOrder> noneSiteWorkOrderList = new List<WorkOrder>();
    DataWrapper repeatRuleNoneDataWrapper = new DataWrapper();
    repeatRuleNoneDataWrapper.milestoneWorkTypeId = milestoneWorkTypeId;
    repeatRuleNoneDataWrapper.caseObj = caseObj;
    repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap = milestoneWorkTypeIdMap;
    repeatRuleNoneDataWrapper.accountSiteMap = accountSiteMap;
    repeatRuleNoneDataWrapper.filteredCaseMap = filteredCaseMap;
    repeatRuleNoneDataWrapper.queueMap = queueMap;//owning team
      
    noneSiteWorkOrderList = CaseTriggerCreateWorkOrders_Util.populateRepeatRuleNoneDataUtil(
      repeatRuleNoneDataWrapper,
      new Set<String>{ 'Main Site' }
    );
    if (null == noneSiteWorkOrderList || noneSiteWorkOrderList.isEmpty()) {
      return;
    }
    workOrderList.addAll(noneSiteWorkOrderList);
  }
  public static void populateNoSiteData(Case caseObj, Id milestoneWorkTypeId) {
    List<WorkOrder> noneSiteWorkOrderList = new List<WorkOrder>();
    DataWrapper repeatRuleNoneDataWrapper = new DataWrapper();
    repeatRuleNoneDataWrapper.milestoneWorkTypeId = milestoneWorkTypeId;
    repeatRuleNoneDataWrapper.caseObj = caseObj;
    repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap = milestoneWorkTypeIdMap;
    repeatRuleNoneDataWrapper.accountSiteMap = null;
    repeatRuleNoneDataWrapper.filteredCaseMap = filteredCaseMap;	
    repeatRuleNoneDataWrapper.queueMap = queueMap;//owning team
      
    noneSiteWorkOrderList = CaseTriggerCreateWorkOrders_Util.populateNoSiteDataUtil(
      repeatRuleNoneDataWrapper
    );
    if (null == noneSiteWorkOrderList || noneSiteWorkOrderList.isEmpty()) {
      return;
    }
    workOrderList.addAll(noneSiteWorkOrderList);
  }
  public class DataWrapper {
    public Id milestoneWorkTypeId;
    public case caseObj;
    public Map<Id, Milestone_Work_Type__c> milestoneWorkTypeIdMap;
    public Map<Id, List<Site__c>> accountSiteMap;
    public Map<Id, Case> filteredCaseMap;
    public Map<String, Id> queueMap;//owning team
    public DataWrapper() {
      caseObj = new Case();
      milestoneWorkTypeIdMap = new Map<Id, Milestone_Work_Type__c>();
      accountSiteMap = new Map<Id, List<Site__c>>();
      filteredCaseMap = new Map<Id, Case>();
      queueMap = new Map<String, Id>();//owning team
    }
  }
  public static void checkCaseStatus(Case caseObj, Map<Id, Case> oldCasesMap) {
    if (
      caseObj.Status != oldCasesMap.get(caseObj.Id).Status &&
      caseObj.Status == 'Active'  && oldCasesMap.get(caseObj.Id).Status == 'Pending Start'
    ) {
      filteredCaseMap.put(caseObj.Id, caseObj);
      milestoneCaseMap.put(caseObj.Id, caseObj.Milestone_Template__c);
      caseAccountMap.put(caseObj.Id, caseObj.AccountId);
    }
  }
  public static void checkDependency(Milestone_Work_Type__c milWorkTypeObj) {
    if (null != milWorkTypeObj.Dependency__c) {
      milestoneWorkTypeDependencyMap.put(
        milWorkTypeObj.Id,
        milWorkTypeObj.Dependency__r.Milestone_Template__c
      );
    }
  }
    
    public static void populateAssetCertificateMap(Set<Id> assetIdSet){
        for(Asset assetObj : [SELECT Id, Certificate__c FROM Asset WHERE ID IN:assetIdSet ]){
            assetCertificateMap.put(assetObj.Id,assetObj.Certificate__c );
        }
    }
    
    public static void populateCertificateOnWorkOrders(){
        for(WorkOrder wobj : workOrderList){
            wobj.Certificate__c = assetCertificateMap.get(wobj.AssetId) != null ? assetCertificateMap.get(wobj.AssetId) : null ;
        }
    }
}