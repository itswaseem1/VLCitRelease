/**
 * @File Name          : SDP_BatchToActivateMilestones.cls
 * @Description        :
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 2/22/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     2/22/2021      Initial Version
 **/
public class SDP_BatchToActivateMilestones implements Database.Batchable<sObject> {
  public Set<Id> caseIdSet;
  public Boolean startDateParam;
  public SDP_BatchToActivateMilestones(Set<Id> caseIdSet,Boolean startDateParam) {
    this.caseIdSet = caseIdSet;
      this.startDateParam = startDateParam;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    List<String> recordTypeNames = Label.SDPRecordTypes.split(',');
    List<String> recordTypeIds = new List<String>();

    for (String recordTypeName : recordTypeNames) {
      recordTypeIds.add(
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get(recordTypeName)
          .getRecordTypeId()
      );
    }

    Date dateToConsider = System.today();
    String query = '';
    if (test.isRunningTest()) {
      query = 'Select Id, Status, Start_Date__c FROM Case';
    } else if (null != caseIdSet && caseIdSet.size() > 0) {
      query = 'Select Id, Status, Start_Date__c FROM Case WHERE ID IN:caseIdSet';
    } else {
      query = 'Select Id, Status, Start_Date__c FROM Case where Origin = \'Service Delivery Milestone\' AND Status=\'Pending Start\' AND Start_Date__c <= :dateToConsider';
    }
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<Case> scope) {
    List<Case> casesToUpdate = new List<Case>();
      
      if(startDateParam){
          SDP_BillingContractConstants.useCaseStartDate = true;
      }
    for (Case caseInScope : scope) {
      casesToUpdate.add(new case(Id = caseInScope.Id, Status = 'Active'));
    }

    if (null != casesToUpdate && casesToUpdate.size() > 0) {
      try {
        update casesToUpdate;
      } catch (Exception error) {
        system.debug(error.getMessage());
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    system.debug('after finish logic to send error emails');
  }
}