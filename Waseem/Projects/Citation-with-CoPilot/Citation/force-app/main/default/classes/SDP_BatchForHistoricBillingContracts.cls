/**
 * @File Name          : SDP_BatchForHistoricBillingContracts.cls
 * @Description        :
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 5/14/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     2/22/2021      Initial Version
 **/
public class SDP_BatchForHistoricBillingContracts implements Database.Batchable<sObject>, Database.Stateful {
  public String queryString;
  public Boolean useCaseStartDate;

  public SDP_BatchForHistoricBillingContracts(String queryString, Boolean useCaseStartDate) {
    this.queryString = queryString;
    this.useCaseStartDate = useCaseStartDate;
  }

  public Date dateToConsider = Date.Today();
  public Set<Id> caseIdToActivate = new Set<Id>();
  public Set<Id> sdpIdSet = new Set<Id>();
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query = 'SELECT Id FROM ffbc__Contract__c WHERE ffbc__Status__c=\'Active\' AND ffbc__Status__c !=\'Cancelled\' AND ffbc__EndDate__c >=:dateToConsider';

    if (queryString != '') {
      query = queryString;
    }
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<ffbc__Contract__c> scope) {
    Set<Id> billingContractIdSet = new Set<Id>();
    try {
      for (ffbc__Contract__c bObj : scope) {
        billingContractIdSet.add(bObj.Id); //
      }

      SDP_Util.isRanFromBatch = true;
      SDP_BillingContractHelper.createCaseformContractForMilestone(scope, null);

      for (Case caseObj : [
        SELECT Id, Start_Date__c, Service_Delivery_Plan__c
        FROM Case
        WHERE
          Status = 'Pending Start'
          AND Origin = 'Service Delivery Milestone'
          AND Status = 'Pending Start'
          AND Billing_Contract__c IN :billingContractIdSet
      ]) {
        if (caseObj.Start_Date__c <= Date.today()) {
          caseIdToActivate.add(caseObj.Id);
          sdpIdSet.add(caseObj.Service_Delivery_Plan__c);
        }
      }
    } catch (Exception error) {
      system.debug(error.getMessage());
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (null != caseIdToActivate && caseIdToActivate.size() > 0) {
      //   SDP_BatchToActivateMilestones batchInstance = new SDP_BatchToActivateMilestones(caseIdToActivate,useCaseStartDate);
      SDP_BundleBatch batchInstance = new SDP_BundleBatch(sdpIdSet, caseIdToActivate, true);
      if (Test.isRunningTest()) {
        return;
      }
      database.executeBatch(batchInstance, 1);
    }
  }
}