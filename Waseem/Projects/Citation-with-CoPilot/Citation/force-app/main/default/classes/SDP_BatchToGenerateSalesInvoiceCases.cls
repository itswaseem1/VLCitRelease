/**
 * @File Name          : SDP_BatchToGenerateSalesInvoiceCases.cls
 * @Description        :
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 3/11/2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     3/11/2021      Initial Version
 **/
@SuppressWarnings('PMD')
public class SDP_BatchToGenerateSalesInvoiceCases implements Database.Batchable<sObject>, Database.Stateful {
	
  public String queryString;
  public Boolean useCaseStartDate;

  public SDP_BatchToGenerateSalesInvoiceCases(String queryString, Boolean useCaseStartDate) {
    this.queryString = queryString;
    this.useCaseStartDate = useCaseStartDate;
  }

  public Date dateToConsider = Date.Today();
  public Set<Id> caseIdToActivate = new Set<Id>();
  public Set<Id> sdpIdSet = new Set<Id>();
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query = '';
	
    if (queryString != '') {
      query = queryString;
    }else{
          query = 'SELECT Id FROM c2g__codaInvoice__c WHERE c2g__InvoiceStatus__c=\'Complete\' AND c2g__GeneralLedgerAccount__r.Name =\'10100 - Sales Revenue\' AND c2g__CompanyReference__c =\'Citation Limited\' AND c2g__Dimension3__c = \'\'';
    }
     if(test.isRunningTest()) {
         query= 'SELECT Id FROM c2g__codaInvoice__c';
      }   
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<c2g__codaInvoice__c> scope) {
    Set<Id> invoiceIdSet = new Set<Id>();
    try {
      for (c2g__codaInvoice__c bObj : scope) {
        invoiceIdSet.add(bObj.Id); //
      }

      SDP_Invoice_Util.isRanFromBatch = true;
      SDP_SalesInvoiceHelper.createCasefromInvoiceForMilestone(scope, null);

      for (Case caseObj : [SELECT Id, Start_Date__c, Service_Delivery_Plan__c FROM Case WHERE Status = 'Pending Start' AND Origin = 'Service Delivery Milestone' AND Status = 'Pending Start' AND Sales_Invoice__c IN :invoiceIdSet]) {
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
      SDP_BundleBatch batchInstance = new SDP_BundleBatch(sdpIdSet, caseIdToActivate, true);
      if (Test.isRunningTest()) {
        return;
      }
      database.executeBatch(batchInstance, 1);
    }
  }
}