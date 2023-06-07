/**
 * @File Name          : CaseTriggerCreateWorkOrders_Util.cls
 * @Description        :
 * @Author             : Maanas -Cognizant
 * @Group              :isRanFromBatch
 * @Last Modified By   :
 * @Last Modified On   : 2/22/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     2/22/2021      Initial Version
 **/
@SuppressWarnings('PMD')
public with sharing class CaseTriggerCreateWorkOrders_Util {
    public static Map<String, String> recordTypeLabelToName = new Map<String, String>{
        'Citation Standard' => 'Citation_Standard',
        'QMS Non-Visit Work' => 'QMS_Non_Visit_Work',
        'QMS Visit Work' => 'QMS_Visit_Work'
    };
    public static Set<Id> accountsWithnoActiveMainSite = new Set<Id>();
    public static Map<String, String> queueMappingWT = new Map<String, String>{
        'H&S Field Support' => 'H_S_Field_Support',
        'HR Field Support' => 'HR_Field_Support',
        'Atlas On-boarding & Support Line 1' => 'Atlas_On_boarding_Support_Line_1',
        'Atlas On-boarding & Support Line 2' => 'Atlas_On_boarding_Support_Line_2',
        'H&S Advice' => 'H_S_Advice',
        'Reception' => 'Reception_Team',
        'H&S Field Consultants' => 'H_S_Field_Support',
        'Onsite-HR Field' => 'Onsite_HR_Field',
        'Atlas On-boarding' => 'Atlas_On_boarding_Support_Line_1',
        'Client Operations' => 'EL_and_HR_Admin',
        'Client Relations' => 'Citation_Complaints',
        'EL&HR Field Consultants' => 'EL_HR_Field_Consultants',
        'ELT&HR Advice' => 'ELT_Advice',
        'Tribunals'=>'Tribunals',
        'HR Support'=>'HR_Support',
        'Fire Operations'=>'Fire_Operations'
    };
    public static Map<Id, List<Site__c>> getAccountSites(
        Map<Id, Id> caseAccountMap
    ) {
        Map<Id, List<Site__c>> accountSiteMap = new Map<Id, List<Site__c>>();
        for (Account accObj : [
            SELECT
                Id,
                (SELECT Id, Site_Type__c FROM Sites__r WHERE Active__c = TRUE)
            FROM Account
            WHERE ID IN :caseAccountMap.values()
        ]) {
            for(Site__c sObj : accObj.Sites__r){
                if(!accountSiteMap.containskey(accObj.Id)){
                    accountSiteMap.put(accObj.Id, new List<Site__c>{sObj});
                }    
                else{
                    accountSiteMap.get(accObj.Id).add(sObj);
                }
          //  accountSiteMap.put(accObj.Id, accObj.Sites__r);
        	}
        }
        checkInactiveMainSite(caseAccountMap);

        return accountSiteMap;
    }

    public static void checkInactiveMainSite(Map<Id, Id> caseAccountMap) {
        for (Account accObj : [
            SELECT
                Id,
                (
                    SELECT Id, Site_Type__c, Active__c
                    FROM Sites__r
                    WHERE Site_Type__c = 'Main Site' AND Active__c = TRUE
                )
            FROM Account
            WHERE ID IN :caseAccountMap.values()
        ]) {
            if (accObj.Sites__r.size() == 0) {
                accountsWithnoActiveMainSite.add(accObj.Id);
            }
        }
    }

    public static List<WorkOrder> populateRepeatRuleNoneDataUtil( //NOPMD
        CaseTriggerCreateWorkOrders.DataWrapper repeatRuleNoneDataWrapper,
        Set<String> repeatRule
    ) {
        List<WorkOrder> returnWorkOrderList = new List<WorkOrder>();

        Id milestoneWorkTypeId = repeatRuleNoneDataWrapper.milestoneWorkTypeId;
        case caseObj = repeatRuleNoneDataWrapper.caseObj;
        Map<Id, Milestone_Work_Type__c> milestoneWorkTypeIdMap = repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap;
        Map<Id, List<Site__c>> accountSiteMap = repeatRuleNoneDataWrapper.accountSiteMap;
        Map<Id, Case> filteredCaseMap = repeatRuleNoneDataWrapper.filteredCaseMap;
        Map<String, Id> queueMap = repeatRuleNoneDataWrapper.queueMap; //owning team

        Milestone_Work_Type__c mWorkTypeObj = milestoneWorkTypeIdMap.get(
            milestoneWorkTypeId
        );
        if (accountsWithnoActiveMainSite.contains(caseObj.AccountId)) {
            workOrder singleWorkOrder = populateForAllMainInactive(
                repeatRuleNoneDataWrapper
            );
            returnWorkOrderList.add(singleWorkOrder);
        }

        Milestone_Work_Type__c parentMworkTypeObj = new Milestone_Work_Type__c();
        List<Site__c> accountSiteList = new List<Site__c>();
        Id caseId = caseObj.Id;
        Boolean executedependencyLogic = false;
        Integer startDays;
        Integer endDays;
        Integer parentstartDays = 0;
        Integer parentEndDays = 0;
        
        if (null != mWorkTypeObj.Dependency__c) {
            parentMworkTypeObj = milestoneWorkTypeIdMap.get(
                mWorkTypeObj.Dependency__c
            );
            executedependencyLogic = true;
            parentstartDays = getParentStartDays(ParentMworkTypeObj);
            parentEndDays = getParentEndDays(ParentMworkTypeObj);
        } 

        for (Site__c accSite : accountSiteMap?.get(caseObj.AccountId)) {
            if (repeatRule.contains(accSite.Site_Type__c)) {
                workOrder siteWorkOrder = new workOrder();
                siteWorkOrder.CaseId = caseId;
                siteWorkOrder.OwnerId = queueMap.get(
                        queueMappingWT.get(mWorkTypeObj.Owning_Team__c)
                    ) != null
                    ? queueMap.get(
                          queueMappingWT.get(mWorkTypeObj.Owning_Team__c)
                      )
                    : userinfo.getUserId(); //owning team. DeveloperNAME
                siteWorkOrder.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                    .get(
                        recordTypeLabelToName.get(
                            mWorkTypeObj?.WorkOrder_Record_Type__c
                        )
                    )
                    .getRecordTypeId();
                siteWorkOrder.Description = mWorkTypeObj?.Description__c;
                siteWorkOrder.AssetId = caseObj.AssetId;
                siteWorkOrder.Subject = mWorkTypeObj?.Subject__c;
                siteWorkOrder.ServiceTerritoryId = mWorkTypeObj
                    ?.ServiceTerritory__c;
                siteWorkOrder.AccountId = filteredCaseMap.get(caseId)
                    ?.AccountId;
                siteWorkOrder.WorkTypeId = mWorkTypeObj.Work_Type__c;
                siteWorkOrder.BusinessHoursId = mWorkTypeObj?.Business_Hours__c;
                siteWorkOrder.Visit_Type__c = mWorkTypeObj?.Visit_Type__c;
                siteWorkOrder.EntitlementId = mWorkTypeObj?.Entitlement__c;
                siteWorkOrder.Milestone_Work_Type__c = milestoneWorkTypeId;
                siteWorkOrder.AccountSite__c = accSite.Id;

                siteWorkOrder.Dependent_WorkType__c = executedependencyLogic
                    ? ParentMworkTypeObj.Work_Type__c
                    : null;
                startDays = (mWorkTypeObj.Start_Days__c) != null
                    ? Integer.valueof(mWorkTypeObj.Start_Days__c)
                    : 0;
                endDays = (mWorkTypeObj.End_Days__c) != null
                    ? Integer.valueof(mWorkTypeObj.End_Days__c)
                    : 0;
                siteWorkOrder.StartDate = date.today()
                    .addDays(startDays + parentstartDays);
                siteWorkOrder.EndDate = siteWorkOrder.StartDate.addDays(
                    endDays
                );

                returnWorkOrderList.add(siteWorkOrder);
            }
        }

        return returnWorkOrderList;
    }

    public static List<WorkOrder> populateNoSiteDataUtil(
        CaseTriggerCreateWorkOrders.DataWrapper repeatRuleNoneDataWrapper
    ) {
        List<WorkOrder> returnWorkOrderList = new List<WorkOrder>();
        Id milestoneWorkTypeId = repeatRuleNoneDataWrapper.milestoneWorkTypeId;
        case caseObj = repeatRuleNoneDataWrapper.caseObj;
        Map<Id, Milestone_Work_Type__c> milestoneWorkTypeIdMap = repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap;
        Map<Id, List<Site__c>> accountSiteMap = repeatRuleNoneDataWrapper.accountSiteMap;
        Map<Id, Case> filteredCaseMap = repeatRuleNoneDataWrapper.filteredCaseMap;
        Map<String, Id> queueMap = repeatRuleNoneDataWrapper.queueMap; //owning team

        Milestone_Work_Type__c mWorkTypeObj = milestoneWorkTypeIdMap.get(
            milestoneWorkTypeId
        );
        Milestone_Work_Type__c parentMworkTypeObj = new Milestone_Work_Type__c();
        List<Site__c> accountSiteList = new List<Site__c>();
        Id caseId = caseObj.Id;
        Boolean executedependencyLogic = false;
        Integer startDays;
        Integer endDays;
        Integer parentstartDays = 0;
        Integer parentEndDays = 0;

        if (null != mWorkTypeObj.Dependency__c) {
            parentMworkTypeObj = milestoneWorkTypeIdMap.get(
                mWorkTypeObj.Dependency__c
            );
            executedependencyLogic = true;
        }

        workOrder noSiteWorkOrder = new workOrder();

        noSiteWorkOrder.CaseId = caseId;
        nositeWorkOrder.OwnerId = queueMap.get(
                queueMappingWT.get(mWorkTypeObj.Owning_Team__c)
            ) != null
            ? queueMap.get(queueMappingWT.get(mWorkTypeObj.Owning_Team__c))
            : userinfo.getUserId();
        noSiteWorkOrder.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(
                recordTypeLabelToName.get(
                    mWorkTypeObj?.WorkOrder_Record_Type__c
                )
            )
            .getRecordTypeId();
        noSiteWorkOrder.StartDate = filteredCaseMap.get(caseId)?.Start_Date__c;
        noSiteWorkOrder.EndDate = filteredCaseMap.get(caseId)?.Due_Date__c;
        noSiteWorkOrder.Description = mWorkTypeObj?.Description__c;
        noSiteWorkOrder.Subject = mWorkTypeObj?.Subject__c;
        noSiteWorkOrder.ServiceTerritoryId = mWorkTypeObj?.ServiceTerritory__c;
        noSiteWorkOrder.AccountId = filteredCaseMap.get(caseId)?.AccountId;
        noSiteWorkOrder.AssetId = filteredCaseMap.get(caseId)?.AssetId;
        noSiteWorkOrder.WorkTypeId = mWorkTypeObj.Work_Type__c;
        noSiteWorkOrder.BusinessHoursId = mWorkTypeObj?.Business_Hours__c;
        noSiteWorkOrder.Visit_Type__c = mWorkTypeObj?.Visit_Type__c;
        noSiteWorkOrder.EntitlementId = mWorkTypeObj?.Entitlement__c;
        noSiteWorkOrder.Milestone_Work_Type__c = milestoneWorkTypeId;

        if (executedependencyLogic) {
            parentstartDays = (ParentMworkTypeObj.Start_Days__c) != null
                ? Integer.valueof(ParentMworkTypeObj.Start_Days__c)
                : 0;
            parentEndDays = (mWorkTypeObj.End_Days__c) != null
                ? Integer.valueof(mWorkTypeObj.End_Days__c)
                : 0;
            noSiteWorkOrder.Dependent_WorkType__c = ParentMworkTypeObj.Work_Type__c;
        }
        startDays = (mWorkTypeObj.Start_Days__c) != null
            ? Integer.valueof(mWorkTypeObj.Start_Days__c)
            : 0;
        endDays = (mWorkTypeObj.End_Days__c) != null
            ? Integer.valueof(mWorkTypeObj.End_Days__c)
            : 0;

        returnWorkOrderList.add(noSiteWorkOrder);

        return returnWorkOrderList;
    }

    public static Integer getParentStartDays(
        Milestone_Work_type__c parentMworkTypeObj
    ) {
        return (parentMworkTypeObj.Start_Days__c != null
            ? Integer.valueof(parentMworkTypeObj.Start_Days__c)
            : 0);
    }

    public static Integer getParentEndDays(
        Milestone_Work_type__c parentMworkTypeObj
    ) {
        return (parentMworkTypeObj.End_Days__c != null
            ? Integer.valueof(parentMworkTypeObj.End_Days__c)
            : 0);
    }

    public static WorkOrder populateForAllMainInactive(
        CaseTriggerCreateWorkOrders.DataWrapper repeatRuleNoneDataWrapper
    ) {
        Id milestoneWorkTypeId = repeatRuleNoneDataWrapper.milestoneWorkTypeId;
        case caseObj = repeatRuleNoneDataWrapper.caseObj;
        Map<Id, Milestone_Work_Type__c> milestoneWorkTypeIdMap = repeatRuleNoneDataWrapper.milestoneWorkTypeIdMap;
        Map<Id, List<Site__c>> accountSiteMap = repeatRuleNoneDataWrapper.accountSiteMap;
        Map<Id, Case> filteredCaseMap = repeatRuleNoneDataWrapper.filteredCaseMap;
        Map<String, Id> queueMap = repeatRuleNoneDataWrapper.queueMap; //owning team

        Milestone_Work_Type__c mWorkTypeObj = milestoneWorkTypeIdMap.get(
            milestoneWorkTypeId
        );
        Milestone_Work_Type__c parentMworkTypeObj = new Milestone_Work_Type__c();

        Id caseId = caseObj.Id;
        Boolean executedependencyLogic = false;
        Integer startDays;
        Integer endDays;
        Integer parentstartDays = 0;
        Integer parentEndDays = 0;

        if (null != mWorkTypeObj.Dependency__c) {
            parentMworkTypeObj = milestoneWorkTypeIdMap.get(
                mWorkTypeObj.Dependency__c
            );
            executedependencyLogic = true;
            parentstartDays = getParentStartDays(ParentMworkTypeObj);
            parentEndDays = getParentEndDays(ParentMworkTypeObj);
        }
        workOrder siteWorkOrder = new workOrder();
        siteWorkOrder.CaseId = caseId;
        siteWorkOrder.ownerId = queueMap.get(
                queueMappingWT.get(mWorkTypeObj.Owning_Team__c)
            ) != null
            ? queueMap.get(queueMappingWT.get(mWorkTypeObj.Owning_Team__c))
            : userinfo.getUserId();
        siteWorkOrder.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(
                recordTypeLabelToName.get(
                    mWorkTypeObj?.WorkOrder_Record_Type__c
                )
            )
            .getRecordTypeId();
        siteWorkOrder.Description = mWorkTypeObj?.Description__c;
        siteWorkOrder.Subject = mWorkTypeObj?.Subject__c;
        siteWorkOrder.ServiceTerritoryId = mWorkTypeObj?.ServiceTerritory__c;
        siteWorkOrder.AccountId = filteredCaseMap.get(caseId)?.AccountId;
        siteWorkOrder.WorkTypeId = mWorkTypeObj.Work_Type__c;
        siteWorkOrder.AssetId = caseObj?.AssetId;
        siteWorkOrder.BusinessHoursId = mWorkTypeObj?.Business_Hours__c;
        siteWorkOrder.Visit_Type__c = mWorkTypeObj?.Visit_Type__c;
        siteWorkOrder.EntitlementId = mWorkTypeObj?.Entitlement__c;
        siteWorkOrder.Milestone_Work_Type__c = milestoneWorkTypeId;

        siteWorkOrder.Dependent_WorkType__c = executedependencyLogic
            ? ParentMworkTypeObj.Work_Type__c
            : null;
        startDays = (mWorkTypeObj.Start_Days__c) != null
            ? Integer.valueof(mWorkTypeObj.Start_Days__c)
            : 0;
        endDays = (mWorkTypeObj.End_Days__c) != null
            ? Integer.valueof(mWorkTypeObj.End_Days__c)
            : 0;
        siteWorkOrder.StartDate = date.today()
            .addDays(startDays + parentstartDays);
        siteWorkOrder.EndDate = siteWorkOrder.StartDate.addDays(endDays);

        return siteWorkOrder;
    }
    public static Map<String, Id> getQueues() {
        //owning team
        Map<String, Id> queueMap = new Map<String, Id>();
        for (Group queObj : [
            SELECT Id, developerName
            FROM Group
            WHERE Type = 'Queue'
            LIMIT 1000
        ]) {
            queueMap.put(queObj.developerName, queObj.Id);
        }
        return queueMap;
    }
}