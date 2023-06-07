/**
 * @File Name          : SDP_BundleBatch.cls
 * @Description        :
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 5/29/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     5/29/2021      Initial Version Maanas
 **/
@SuppressWarnings('PMD')
public class SDP_BundleBatch implements Database.Batchable<sObject>, Database.Stateful {
  public Set<Id> sdpIdSet;
  public Set<Id> caseIdSet;
  public Set<Id> caseIdToActivate = new Set<Id>();
  public boolean isTrigger;

  public SDP_BundleBatch(Set<Id> sdpIdSet, set<Id> caseIdSet, Boolean isTrigger) {
    this.sdpIdSet = sdpIdSet;
    this.caseIdSet = caseIdSet;
    this.isTrigger = isTrigger;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    List<String> recordTypeNames = Label.SDPRecordTypes.split(',');
    List<String> recordTypeIds = new List<String>();

    for (String recordTypeName : recordTypeNames) {
      recordTypeIds.add(
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId()
      );
    }

    Date dateToConsider = System.today();
    String query = '';
    if (null != sdpIdSet && sdpIdSet.size() > 0) {
      query = 'SELECT Id,(SELECT Id,AccountId,Due_Date__c,Anniversary_Date__c,RecordTypeId,Service_Delivery_Plan__c,Status,Origin,Priority,Milestone_Template__c,Billing_Contract__c,Sales_Invoice__c,Sales_Invoice_2__c,Sales_Invoice_Line_Item__c,Sales_Invoice_Line_Item_2__c, Billing_Contract_Line_Item__c,Billing_Contract_Line_Item__r.Service_Start_Date__c, AssetId, Start_Date__c FROM Cases__r WHERE Origin = \'Service Delivery Milestone\' AND Status=\'Pending Start\' ) FROM Service_Delivery_Plan__c WHERE ID IN:sdpIdSet ';
    } else {
      query = 'SELECT Id,(SELECT Id,AccountId,Due_Date__c,Anniversary_Date__c,RecordTypeId,Service_Delivery_Plan__c,Status,Origin,Priority,Milestone_Template__c,Billing_Contract__c,Sales_Invoice__c,Sales_Invoice_Line_Item__c,Sales_Invoice_2__c,Sales_Invoice_Line_Item_2__c,Billing_Contract_Line_Item__c,Billing_Contract_Line_Item__r.Service_Start_Date__c, AssetId, Start_Date__c FROM Cases__r WHERE Origin = \'Service Delivery Milestone\' AND Status=\'Pending Start\' ) FROM Service_Delivery_Plan__c WHERE ID IN(SELECT Service_Delivery_Plan__c FROM Case WHERE Origin = \'Service Delivery Milestone\' AND Status=\'Pending Start\' AND Start_Date__c  <= :dateToConsider)';
    }
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<Service_Delivery_Plan__c> planRecords) {
    Map<Id, List<Case>> sdpCaseListMap = new Map<Id, List<Case>>();
    Map<String, String> queueMapping = new Map<String, String>{
      'H_S_Field_Support' => 'H_S_Field_Support',
      'HR_Field_Support' => 'HR_Field_Support',
      'Atlas_On_boarding_Support_Line_1' => 'Atlas_On_boarding_Support_Line_1',
      'Atlas_On_boarding_Support_Line_2' => 'Atlas_On_boarding_Support_Line_2',
      'H&S Advice' => 'H_S_Advice',
      'Reception' => 'Reception_Team',
      'H&S Field Consultants' => 'H_S_Field_Support',
      'Onsite_HR_Field' => 'Onsite_HR_Field',
      'Tribunals' => 'Tribunals',
      'HR Support' => 'HR_Support',
      'Client Operations'=> 'EL_and_HR_Admin',
      'Atlas On-boarding' => 'Atlas_On_boarding_Support_Line_1',
      'Client Relations' => 'Citation_Complaints',
      'EL&HR Field Consultants' => 'EL_HR_Field_Consultants',
      'ELT&HR Advice'=>'ELT_Advice',
      'Fire Operations'=>'Fire_Operations'
    };
    Map<Id, Case> caseMap = new Map<Id, Case>();
    Set<Id> milestoneTemplateIdSet = new Set<Id>();
    Map<Id, Set<Id>> milestoneCaseMap = new Map<id, Set<Id>>();
    Map<Id, Milestone_Bundle_Template__c> bundleMap = new Map<Id, Milestone_Bundle_Template__c>();
    Map<Id, Set<Id>> sdpMilestoneSetMap = new Map<Id, Set<Id>>();
    Map<String, List<Id>> bundledMilestoneCaseSetMap = new Map<String, List<Id>>();
    Set<Id> casesToDeleteIdSet = new Set<Id>();
    Map<String, Id> queueMap = new Map<String, Id>();
    List<Case> casesToInsert = new List<Case>();
    List<Case> casesToDelete = new List<Case>();
    Set<Id> resultBundledIdSet = new Set<Id>();
    Map<Id, Milestone_Template__c> bundledMilestoneMap = new Map<Id, Milestone_Template__c>();
    Map<Id, Case> combinedCaseMapping = new Map<Id, Case>();

    for (Service_Delivery_Plan__c sdpRec : planRecords) {
      sdpCaseListMap.put(sdpRec.Id, sdpRec.Cases__r);
      for (Case caseObj : sdpRec.Cases__r) {
        caseMap.put(caseObj.Id, caseObj);
        if (!milestoneCaseMap.containsKey(caseObj.Milestone_Template__c)) {
          milestoneCaseMap.put(caseObj.Milestone_Template__c, new Set<Id>{ caseObj.Id });
        } else {
          milestoneCaseMap.get(caseObj.Milestone_Template__c).add(caseObj.Id);
        }

        milestoneTemplateIdSet.add(caseObj.Milestone_Template__c);
        if (!sdpMilestoneSetMap.containsKey(sdpRec.id)) {
          sdpMilestoneSetMap.put(sdpRec.Id, new Set<Id>{ caseObj.Milestone_Template__c });
        } else {
          sdpMilestoneSetMap.get(sdpRec.Id).add(caseObj.Milestone_Template__c);
        }
      }
    }
    if (sdpCaseListMap.isEmpty() || sdpCaseListMap.size() == 0) {
      return;
    }
    Integer count = 0;
    queueMap = getSDPQueues();
    if (null != milestoneTemplateIdSet && milestoneTemplateIdSet.size() > 0) {
      for (Milestone_Bundle_Template__c bundleObj : [
        SELECT
          Id,
          Entry_Milestone_Template_1__c,
          Entry_Milestone_Template_2__c,
          Result_Milestone_Template__c,
          Vicinity__c
        FROM Milestone_Bundle_Template__c
        WHERE
          Entry_Milestone_Template_1__c IN :milestoneTemplateIdSet
          AND Entry_Milestone_Template_2__c IN :milestoneTemplateIdSet
      ]) {
        for (Service_Delivery_Plan__c sdpRec : planRecords) {
          for (case caseObj : sdpCaseListMap.get(sdpRec.Id)) {
            if (caseObj.Milestone_Template__c == bundleObj.Entry_Milestone_Template_1__c) {
              Set<Id> allrelatedMilestoneIdSet = sdpMilestoneSetMap.get(sdpRec.Id);

              if (allrelatedMilestoneIdSet.contains(bundleObj.Entry_Milestone_Template_2__c)) {
                Set<Id> reqCase0Ids = milestoneCaseMap.get(caseObj.Milestone_Template__c);

                Id main0Id = null;
                for (Id caseId : reqCase0Ids) {
                  if (caseId == caseObj.Id) {
                    main0Id = caseId;
                  }
                }
                if (reqCase0Ids.size() > 0) {
                  reqCase0Ids.remove(main0Id);
                  milestoneCaseMap.put(caseObj.Milestone_Template__c, reqCase0Ids);
                }
                case caseObj1 = new case();
                caseObj1 = caseMap.get(main0Id);

                Set<Id> reqCaseIds = milestoneCaseMap.get(bundleObj.Entry_Milestone_Template_2__c);
                Id mainId = null;
                for (Id caseId : reqCaseIds) {
                  mainId = caseId;
                }

                if (reqCaseIds.size() > 0) {
                  reqCaseIds.remove(mainId);
                  milestoneCaseMap.put(caseMap.get(mainId).Milestone_Template__c, reqCaseIds);
                }
                case caseObj2 = new case();
                caseObj2 = caseMap.get(mainId);

                if (caseObj2 != null && caseObj1 != null) {
                  Integer numberDaysDue = caseObj2.Anniversary_Date__c.daysBetween(caseObj2.Anniversary_Date__c);

                  if (
                    math.abs(numberDaysDue) <= bundleObj.Vicinity__c &&
                    !casesToDeleteIdSet.contains(caseObj1.Id) &&
                    !casesToDeleteIdSet.contains(caseObj2.Id)
                  ) {
                    bundledMilestoneCaseSetMap.put(
                      bundleObj.Result_Milestone_Template__c +
                      '-' +
                      caseObj1.Id +
                      caseObj2.Id,
                      new List<Id>{ caseObj1.Id, caseObj2.Id }
                    );
                    resultBundledIdSet.add(bundleObj.Result_Milestone_Template__c);
                    casesToDeleteIdSet.add(caseObj1.Id);
                    casesToDeleteIdSet.add(caseObj2.Id);
                    combinedCaseMapping.put(caseObj1.Id, caseObj2);
                  }
                }
              }
            } else if (caseObj.Milestone_Template__c == bundleObj.Entry_Milestone_Template_2__c) {
              Set<Id> allrelatedMilestoneIdSet = sdpMilestoneSetMap.get(sdpRec.Id);

              if (allrelatedMilestoneIdSet.contains(bundleObj.Entry_Milestone_Template_1__c)) {
                Set<Id> reqCase0Ids = milestoneCaseMap.get(caseObj.Milestone_Template__c);
                  
                Id main0Id = null;
                for (Id caseId : reqCase0Ids) {
                  if (caseId == caseObj.Id) {
                    main0Id = caseId;
                  }
                }
                if (reqCase0Ids.size() > 0) {
                  reqCase0Ids.remove(main0Id);
                  milestoneCaseMap.put(caseObj.Milestone_Template__c, reqCase0Ids);
                }
                case caseObj1 = new case();
                caseObj1 = caseMap.get(main0Id);
                Set<Id> reqCaseIds = milestoneCaseMap.get(bundleObj.Entry_Milestone_Template_1__c);
                Id mainId = null;
                for (Id caseId : reqCaseIds) {
                  mainId = caseId;
                }
                if (reqCaseIds.size() > 0) {
                  reqCaseIds.remove(mainId);
                  milestoneCaseMap.put(caseMap.get(mainId).Milestone_Template__c, reqCaseIds);
                }
                case caseObj2 = new case();
                caseObj2 = caseMap.get(mainId);
                if (caseObj2 != null && caseObj1 != null) {
                  Integer numberDaysDue = caseObj2.Anniversary_Date__c.daysBetween(caseObj2.Anniversary_Date__c);

                  if (
                    math.abs(numberDaysDue) <= bundleObj.Vicinity__c &&
                    !casesToDeleteIdSet.contains(caseObj1.Id) &&
                    !casesToDeleteIdSet.contains(caseObj2.Id)
                  ) {
                    bundledMilestoneCaseSetMap.put(
                      bundleObj.Result_Milestone_Template__c +
                      '-' +
                      caseObj1.Id +
                      caseObj2.Id,
                      new List<Id>{ caseObj1.Id, caseObj2.Id }
                    );
                    resultBundledIdSet.add(bundleObj.Result_Milestone_Template__c);
                    casesToDeleteIdSet.add(caseObj1.Id);
                    casesToDeleteIdSet.add(caseObj2.Id);
                    combinedCaseMapping.put(caseObj1.Id, caseObj2);
                  }
                }
              }
            }
          }
        }
      }
    }

    if (null != bundledMilestoneCaseSetMap && bundledMilestoneCaseSetMap.size() > 0) {
      for (Milestone_Template__c mObj : [
        SELECT
          Id,
          Milestone_Subject__c,
          Entitlement__c,
          Case_Type__c,
          Milestone_Description__c,
          Owning_Team__c,
          Reference_Date_field__c,
          Start_Date_Days__c,
          Due_Date_Days__c,
          Anniversary_Date_Months__c,
          Start_after_x_months__c
        FROM Milestone_Template__c
        WHERE ID IN :resultBundledIdSet
      ]) {
        bundledMilestoneMap.put(mObj.Id, mObj);
      }

      for (String bundleObj : bundledMilestoneCaseSetMap.keyset()) {
        String bundleId = bundleObj.split('-')[0];
        Milestone_Template__c mObj = bundledMilestoneMap.get(bundleId);
        Case parentCase = caseMap.get(bundledMilestoneCaseSetMap.get(bundleObj)[0]);
        case bundledCase = new case();
        bundledCase.AccountId = parentCase.AccountId;
        bundledCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
          .get(mObj.Case_Type__c)
          .getRecordTypeId(); //Case Type on ML Matches Case Record Tyoe
        bundledCase.Origin = 'Service Delivery Milestone';
        bundledCase.Priority = 'Normal';
        bundledCase.Service_Delivery_Plan__c = parentCase.Service_Delivery_Plan__c;
        bundledCase.Milestone_Template__c = mObj.Id; // Related Milestone Id;
        bundledCase.Billing_Contract__c = parentCase?.Billing_Contract__c;
        bundledCase.Billing_Contract_Line_Item__c = parentCase?.Billing_Contract_Line_Item__c;
        bundledCase.Sales_Invoice__c = parentCase?.Sales_Invoice__c;
        bundledCase.Sales_Invoice_Line_Item__c =   parentCase?.Sales_Invoice_Line_Item__c;
        bundledCase.Subject = bundledMilestoneMap.get(bundleId).Milestone_Subject__c;
        bundledCase.EntitlementId = mObj.Entitlement__c;
        bundledCase.Description = mObj.Milestone_Description__c;
        bundledCase.ownerId = queueMap.get(queueMapping.get(mObj.Owning_Team__c)) != null
          ? queueMap.get(queueMapping.get(mObj.Owning_Team__c))
          : userinfo.getUserId();
        bundledCase.Status = 'Pending Start';
        bundledCase.Billing_Contract_2__c = combinedCaseMapping?.get(parentCase.Id)?.Billing_Contract__c;
        bundledCase.Billing_Contract_Line_Item_2__c = combinedCaseMapping?.get(parentCase.Id)?.Billing_Contract_Line_Item__c;
        bundledCase.Sales_Invoice_Line_Item_2__c = combinedCaseMapping?.get(parentCase.Id)?.Sales_Invoice_Line_Item__c;
        bundledCase.Sales_Invoice_2__c = combinedCaseMapping?.get(parentCase.Id)?.Sales_Invoice__c;
        bundledCase.Asset_2__c = combinedCaseMapping.get(parentCase.Id).AssetId;
        bundledCase.AssetId = parentCase.AssetId;
        bundledCase.Start_Date__c = parentCase.Start_Date__c;
        bundledCase.Due_Date__c = parentCase.Due_Date__c;
        bundledCase.Anniversary_Date__c = parentCase.Anniversary_Date__c;
   
        casesToInsert.add(bundledCase);
      }
    }

    if (null != casesToInsert && casesToInsert.size() > 0) {
      try {
        insert casesToInsert;
        for (Id xcaseId : casesToDeleteIdSet) {
          casesToDelete.add(caseMap.get(xcaseId));
          caseMap.remove(xcaseId);
        }

        for (case caseObj : casesToInsert) {
          caseMap.put(caseObj.Id, caseObj);
        }

        for (case caseObj : casemap.values()) {
          if (caseObj.Start_Date__c <= Date.today()) {
            caseIdToActivate.add(caseObj.Id);
          }
        }

        if (null != casesToDelete && casesToDelete.size() > 0) {
          delete casesToDelete;
        }
      } catch (Exception error) {
        system.debug(error.getMessage());
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (!test.isRunningTest()) {
      if (isTrigger) {
        if (null != caseIdToActivate && caseIdToActivate.size() > 0) {
          SDP_BatchToActivateMilestones batchInstance = new SDP_BatchToActivateMilestones(caseIdToActivate, false);
          database.executeBatch(batchInstance, 1);
        } else {
          SDP_BatchToActivateMilestones batchInstance = new SDP_BatchToActivateMilestones(caseIdSet, false);
          database.executeBatch(batchInstance, 1);
        }
      } else {
        SDP_BatchToActivateMilestones batchInstance = new SDP_BatchToActivateMilestones(null, false);
        database.executeBatch(batchInstance, 1);
      }
    }
  }

  public static Date getContractStartReferenceDate(Milestone_Template__c mObj, ffbc__ContractLineItem__c cliObj) {
    date dateToreturn;
    if (mObj.Reference_Date_field__c == 'Contract Activated Date') {
      dateToreturn = date.Today();
    } else {
      dateToreturn = cliObj.Service_Start_Date__c != null ? cliObj.Service_Start_Date__c : date.today();
    }
    return dateToreturn;
  }

  //This method will fetch the all the necessary SDP Queues
  public static Map<String, Id> getSDPQueues() {
    Map<String, Id> queueMap = new Map<String, Id>();
    for (Group queObj : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
      queueMap.put(queObj.DeveloperName, queObj.Id);
    }
    return queueMap;
  }
}