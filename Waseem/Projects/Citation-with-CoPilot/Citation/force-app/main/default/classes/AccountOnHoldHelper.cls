/**
 * @File Name          : AccountOnHoldHelper.cls
 * @Description        :
 * @Author             : Mukul -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 21/04/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     4/6/2021      Initial Version
 **/
public with sharing class AccountOnHoldHelper {
    private List<Service_Delivery_Plan__c> sdpList ;
    private List<Case> sdpCases;
    private List<Case> sdpCasesUpdated = new List<Case>();
    private String onHoldStatus = 'On Hold';
    //private String activeStatus = 'Active';
    private List<String> caseStatusList=new List<String>{'Active','Pending Start'};
    private List<String> statusList = new List<String>{'New','In Progress'};
    private List<String> saStatusList = new List<String>{'None','Scheduled','Dispatched','In Progress'};
    private List<WorkOrder> workOrderForCases;
    private List<WorkOrder> workOrderForCasesupdated=new List<WorkOrder>();
    private List<ServiceAppointment> saForWorkOrders;
    private List<ServiceAppointment> saForWorkOrdersUpdated = new List<ServiceAppointment>();
    private List<Entitlement> entitlementForAccounts;
    private List<Entitlement> entitlementForAccountsupdated = new List<Entitlement>();
    private List<Entitlement> entitlementForWorkOrders;
    private id queueId;
    private String queueName = 'On-Hold';
    private String woOnHoldStatus='	On Hold';
    private String saCanceledStatus = 'Canceled';
    private String saOnHoldReason = 'Service On-Hold';
    private Map<id,String> caseToQueue = new Map<id,String>();

    public AccountOnHoldHelper() {

        queueid = [select Id from Group where  Type = 'Queue' AND NAME=:queueName].id;
    }

    public void getServiceDeliveryPlanForOnHold(List<Account> onholdaccountlist)
    {

        sdpList = [select id,name,Account__c from Service_Delivery_Plan__c where Account__c IN :onholdaccountlist];
        getEntitlementsForOnHold(onholdaccountlist);
        getSdpCasesForOnHold(sdpList);
    }

    public void getSdpCasesForOnHold(List<Service_Delivery_Plan__c> sdplist)
    {
        sdpCases = [select id,Service_Delivery_Plan__c,status,OwnerId from Case where Service_Delivery_Plan__c IN :sdplist AND status=:caseStatusList];
        
        if(sdpCases.size()>0)
        {
            for(Case caseloop :sdpCases)
            {
                  caseloop.Previous_Status__c=caseloop.status;
                  caseloop.status=onHoldStatus;
                  caseloop.ownerId = queueId;
                  sdpCasesUpdated.add(caseloop);
            }
            if(Case.sObjectType.getDescribe().isUpdateable())
            {
                update sdpCasesUpdated;
            }
        
        }
        getWorkOrdersForOnHold(sdpCases);
    }

    public void getWorkOrdersForOnHold(List<Case> caseList)
    {
        workOrderForCases = [select id,CaseId,status,Previous_Status__c,OwnerId from WorkOrder where CaseId IN :caseList AND StatusCategory IN :statusList];

        if(workOrderForCases.size()>0)
        {
            for(WorkOrder woloop :workOrderForCases)
            {
                 woloop.Previous_Status__c=woloop.Status;
                 woloop.status = woOnHoldStatus;
                 woloop.IsStopped = true;
                 woloop.ownerId = queueId;
                 workOrderForCasesupdated.add(woloop);
            }
            if(WorkOrder.sObjectType.getDescribe().isUpdateable())
            {
            update workOrderForCasesupdated;
            }
        }
        getServiceAppointmentsForOnHold(workOrderForCases);
    }

    public void getServiceAppointmentsForOnHold(List<WorkOrder> woList)
    {
        SaForWorkOrders = [select id,ParentRecordId,status,Reason__c from ServiceAppointment where ParentRecordId IN :WoList AND StatusCategory IN :saStatusList];
        
        if(SaForWorkOrders.size()>0)
        {
            for(ServiceAppointment saloop :saForWorkOrders)
            {
                saloop.status = saCanceledStatus;
                saloop.Reason__c = saOnHoldReason;
                saForWorkOrdersUpdated.add(saloop);
            }
            
            if(ServiceAppointment.sObjectType.getDescribe().isUpdateable()){
            update saForWorkOrdersUpdated;
            }
        }
        
    }
    public void getEntitlementsForOnHold(List<Account> accountEntitleList)
    {
        entitlementForAccounts = [select id,AccountId,startdate,enddate from Entitlement where AccountId IN :accountEntitleList];

        if(entitlementForAccounts.size()>0)
        {
            for(Entitlement entitleloop : entitlementForAccounts)
            {
                entitleloop.EndDate_SDP__c = entitleloop.enddate;
                entitleloop.Start_DateSDP__c = entitleloop.StartDate;
                entitleloop.StartDate=system.today()-10;
                entitleloop.enddate=system.today()-1;
                entitlementForAccountsupdated.add(entitleloop);
            }

            if(Entitlement.sObjectType.getDescribe().isUpdateable()){
                update entitlementForAccountsupdated;
                }
            
        }
	
    }

    
    }