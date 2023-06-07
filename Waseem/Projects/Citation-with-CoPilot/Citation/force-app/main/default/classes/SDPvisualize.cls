/**
 * @File Name          : SDPvisualize.cls
 * @Description        : 
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/06/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     07/06/2021      Initial Version
 **/
@SuppressWarnings('PMD')
public with sharing class SDPvisualize {
   
   public static List<CaseWrapperSort> caseResultWrap = new List<CaseWrapperSort>();
   
 @AuraEnabled
 public static List<CaseWrapperSort> fetchCase(Id sdpId) {
    set<Id> caseIdSet = new Set<Id>();
 
    for (case caseObj : [SELECT Id FROM Case WHERE Service_Delivery_Plan__r.Id = :sdpId WITH SECURITY_ENFORCED]) {
		caseIdSet.add(caseObj.Id);
    }

    Map<Id, WorkOrder> woApt = new Map<Id, WorkOrder>(
    [
        SELECT
         Id,
         WorkOrderNumber,
         Subject,
         AccountSite__r.Name,
         AccountSite__r.Postcode__c,
         Owner.Name,
         StartDate,
         EndDate,
         Status,
         (
           SELECT
             Id,
             AppointmentNumber,
             ParentRecordId,
             Subject,
             AccountSite__r.Name,
             Status,
             SchedStartTime,
             ActualStartTime
           FROM ServiceAppointments
         )
        FROM WorkOrder
        WHERE CaseId IN :caseIdSet
        WITH SECURITY_ENFORCED
    ]);
	
   Set<String> prodSet = new Set<String>();
   Integer year1 = 0000 ;
   List<CaseWrapperSort> casewrap = new List<CaseWrapperSort>();
 
    for (CASE caLsit : [
     SELECT
       Id,
       CaseNumber,
       Asset.Product2.Name,
       Billing_Contract__r.Name,
       Subject,
       Anniversary_Date__c,
       Start_Date__c,
       Due_Date__c,
       Status,
       Flag_For_SDP_Visualize__c,
       (SELECT Id, WorkOrderNumber, Subject, AccountSite__c,AccountSite__r.Name, Owner.Name, StartDate, EndDate, Status FROM WorkOrders)
     FROM Case
     WHERE Service_Delivery_Plan__r.Id = :sdpId
     WITH SECURITY_ENFORCED
    ]){
	    List<WorkOrder> wList = new List<WorkOrder>();
		Set<String> accSiteSet = new Set<String>();
		CaseWrapperSort aWraper = new CaseWrapperSort();
		aWraper.caseObj = caLsit;
		prodSet.add(caLsit.Asset.Product2.Name);
			   
		for (WorkOrder workObj : caLsit.WorkOrders){
			WorkOrder wOrderObj = woApt.get(workObj.Id);
			accSiteSet.add(woApt.get(workObj.Id).AccountSite__r.Name);
			wList.add(wOrderObj);
		}
		   aWraper.workList = wList;
		   aWraper.accSiteName = accSiteSet; 
		   
		   casewrap.add(aWraper);
    }

   casewrap.sort();
   return casewrap;
 }
 
 
 @AuraEnabled
 public static List<CaseWrapperSort> getFilteredRecordDetails(Id sdpId, Integer annyYearCase, String productName, String woAccSite) {
    set<Id> caseIdSet = new Set<Id>();
 
    for (case caseObj : [SELECT Id, Anniversary_Date__c, Asset.Product2.Name FROM Case WHERE 
                        Anniversary_Date__c != null AND Service_Delivery_Plan__r.Id = :sdpId WITH SECURITY_ENFORCED]) {
            
       Integer annYear = caseObj.Anniversary_Date__c.year();
    
        if( (productName == 'Allproduct' && annYear == annyYearCase) || (annYear == annyYearCase && caseObj.Asset.Product2.Name == productName) 
          || (productName == 'Allproduct' && annyYearCase == 0000) || (annyYearCase == 0000 && caseObj.Asset.Product2.Name == productName)  ){
         caseIdSet.add(caseObj.Id);
        }
    }
    caseResultWrap = getWorkorderDetails(woAccSite, caseIdSet);
     
        return caseResultWrap;
     
     
 }
   
public static List<CaseWrapperSort> getWorkorderDetails(String woAccSite, Set<Id> caseIdSet){

    Map<Id, WorkOrder> woApt = new Map<Id, WorkOrder>([
       SELECT
         Id,
         WorkOrderNumber,
         Subject,
         AccountSite__r.Name,
         AccountSite__r.Postcode__c,
         Owner.Name,
         StartDate,
         EndDate,
         Status,
         (
           SELECT
             Id,
             AppointmentNumber,
             ParentRecordId,
             Subject,
             AccountSite__r.Name,
             Status,
             SchedStartTime,
             ActualStartTime
           FROM ServiceAppointments 
         )
       FROM WorkOrder
       WHERE CaseId IN :caseIdSet 
       WITH SECURITY_ENFORCED
    ]);
	    Set<String> prodSet = new Set<String>();
	    List<CaseWrapperSort> casewrap = new List<CaseWrapperSort>();
		
	for (CASE caLsit : [
     SELECT
       Id,
       CaseNumber,
       Asset.Product2.Name,
       Billing_Contract__r.Name,
       Subject,
       Anniversary_Date__c,
       Start_Date__c,
       Due_Date__c,
       Status,
       Flag_For_SDP_Visualize__c,
       (SELECT Id, WorkOrderNumber, Subject, AccountSite__c, AccountSite__r.Name, Owner.Name, StartDate, EndDate, Status FROM WorkOrders )
     FROM Case
     WHERE Id = :caseIdSet
     WITH SECURITY_ENFORCED
    ]){
     
       CaseWrapperSort aWraper = new CaseWrapperSort();
       aWraper.caseObj = caLsit;
       List<WorkOrder> wList = new List<WorkOrder>();
       
		for (WorkOrder workObj : caLsit.WorkOrders) {
			if(workObj.AccountSite__r.Name == woAccSite || woAccSite == 'AllSite' ){
			   WorkOrder wOrderObj = woApt.get(workObj.Id);
			   wList.add(wOrderObj);
			 
			}
		}
        if(!wList.isEmpty() || woAccSite == 'AllSite'){
			aWraper.workList = wList;
			casewrap.add(aWraper);
        }
     }

	   casewrap.sort();
	   return casewrap;
	}
}