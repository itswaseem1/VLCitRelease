public with sharing class CaseTriggerWorkOrdersHelper {
  public static Map<String, WorkOrder> generateKeysHelper(WorkOrder workObj) {
    Map<String, WorkOrder> workOrderKeyMap = new Map<String, WorkOrder>();
    if (workObj.AccountSite__c != null) {
      workOrderKeyMap.put(
        String.valueof(workObj.CaseId) +
        String.valueof(workObj.AccountSite__c) +
        String.valueof(workObj.WorkTypeId),
        workObj
      );
    } else {
      workOrderKeyMap.put(
        String.valueof(workObj.CaseId) +
        String.valueof(workObj.AccountId) +
        String.valueof(workObj.WorkTypeId),
        workObj
      );
    }

    return workOrderKeyMap;
  }

  public static void updateDependentRecords(
    List<WorkOrder> workOrdersToUpdate
  ) {
    if (null != workOrdersToUpdate && workOrdersToUpdate.size() > 0) {
      workOrderFutureHandler(workOrdersToUpdate);
    }
  }

  public static void workOrderFutureHandler(
    List<WOrkOrder> workOrdersToUpdate
  ) {
    try {
      update workOrdersToUpdate;
    } catch (Exception error) {
      system.debug(error.getMessage());
    }
  }
}