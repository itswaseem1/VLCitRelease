/**
 * @File Name          : AccountOffHoldHelper.cls
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
public with sharing class AccountOffHoldHelper {

    private List<Service_Delivery_Plan__c> sdpList ;
    private List<Case> sdpCases =null;
    private List<Case> sdpCasesUpdated = new List<Case>();
    private String newStatus = 'New';
    private String noneStatus = 'None';
    private List<WorkOrder> workOrderForCases;
    private List<WorkOrder> workOrderForCasesupdated=new List<WorkOrder>();
    private List<ServiceAppointment> saForWorkOrders;
    private List<ServiceAppointment> saForWorkOrdersUpdated = new List<ServiceAppointment>();
    private List<Entitlement> entitlementForAccounts;
    private List<Entitlement> entitlementForAccountsupdated = new List<Entitlement>();
    private List<Entitlement> entitlementForWorkOrders;
    private String queueName = 'On-Hold';
    private Map<String,String> queueNameToId = new Map<String,String>();
    private List<Group> queueList;
    private List<Milestone_Work_Type__c> milestoneWorkTypeList=null;
    private Map<String,Milestone_Work_Type__c> workOrderToMilestoneTemplate = new Map<String,Milestone_Work_Type__c>();
    private Set<String> queuenamelist = new Set<String>();
    private Set<id> milestoneWorkTypeTemplateIds = new Set<id>();
    Map<String, String> queueMapping = new Map<String,String>{
            													 'H&S Field Support' => 'H_S_Field_Support', 
            													 'HR Field Support' => 'HR_Field_Support', 
            													 'Atlas On-boarding & Support Line 1' => 'Atlas_On_boarding_Support_Line_1', 
            													 'Atlas On-boarding & Support Line 2' => 'Atlas_On_boarding_Support_Line_2',
            													 'H&S Advice' => 'H_S_Advice', 
            													 'Reception'=> 'Reception_Team',
            													 'H&S Field Consultants'=> 'H_S_Field_Support',
            													 'Onsite-HR' => 'Onsite_HR_Field',
                                                                  'Atlas On-boarding' => 'Atlas_On_boarding_Support_Line_1',
                                                                  'Client Operations'=> 'EL_and_HR_Admin',
                                                                   'Client Relations' => 'Citation_Complaints',
                                                                     'EL&HR Field Consultants' => 'EL_HR_Field_Consultants',
                                                                     'ELT&HR Advice'=>'ELT_Advice'
            													 };


    
    public void getServiceDeliveryPlanForOffHold(List<Account> onholdaccountlist)
    {

        sdpList = [select id,name,Account__c from Service_Delivery_Plan__c where Account__c IN :onholdaccountlist];
        if(sdpList.size()>0 && sdpList!=null){
        getEntitlementsForOffHold(onholdaccountlist);
        getSdpCasesForOffHold(sdpList);
        }
    }

    public void getQueueNameForCases(List<Case> caseList)
    {
       Schema.DescribeFieldResult fieldResult = Milestone_Template__c.Owning_Team__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
              queuenamelist.add(f.getLabel()); 
       }  
       Schema.DescribeFieldResult fieldResult1 = Milestone_Work_Type__c.Owning_Team__c.getDescribe();
       List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
       for( Schema.PicklistEntry f : ple1)
       {
              queuenamelist.add(f.getLabel()); 
       } 
        getQueueIdForCases(queuenamelist);
    }
    public void getQueueIdForCases(Set<String> caseQueueList)
    {
        
        queueList = [select Id,Name,DeveloperName from Group WHERE Type = 'Queue' WITH SECURITY_ENFORCED];
        
        for(Group grouploop : queueList)
        {
            queueNameToId.put(grouploop.DeveloperName,grouploop.id);
        }
    }
    public void getSdpCasesForOffHold(List<Service_Delivery_Plan__c> sdplist)
    {
        sdpCases = [select id,Previous_Status__c,Milestone_Template__c,toLabel(case.Milestone_Template__r.Owning_Team__c),Service_Delivery_Plan__c,status,OwnerId from Case where Service_Delivery_Plan__c IN :sdplist AND status = 'On Hold'];
        
        if(sdpCases.size()>0)
        {
            getQueueNameForCases(sdpCases);
            system.debug('queueNameToId'+queueNameToId);
            for(Case caseloop :sdpCases)
            {
                  caseloop.status = caseloop.Previous_Status__c;
                  caseloop.ownerId = queueNameToId.get(queueMapping.get(caseloop.Milestone_Template__r.Owning_Team__c))!=null
                  ?queueNameToId.get(queueMapping.get(caseloop.Milestone_Template__r.Owning_Team__c)):userinfo.getUserId();
                  sdpCasesUpdated.add(caseloop);
            }
            if(Case.sObjectType.getDescribe().isUpdateable())
            {
                update sdpCasesUpdated;
            }
           getWorkOrdersForOffHold(sdpCases);
        }
    }

    public void getWorkOrdersForOffHold(List<Case> caseList)
    {
        workOrderForCases = [select id,WorkTypeId,Previous_Status__c,Milestone_Work_Type__c,toLabel(Milestone_Work_Type__r.Owning_Team__c),CaseId,status,OwnerId,Workorder.case.Milestone_Template__c from WorkOrder where CaseId IN :caseList AND status='On Hold'];

        if(workOrderForCases.size()>0)
        {
            for(WorkOrder woloop :workOrderForCases)
            {
                if(woloop.Milestone_Work_Type__r.Owning_Team__c!=null)
                {
                 woloop.ownerId = queueNameToId.get(queueMapping.get(woloop.Milestone_Work_Type__r.Owning_Team__c))!=null?
                 queueNameToId.get(queueMapping.get(woloop.Milestone_Work_Type__r.Owning_Team__c)):userinfo.getUserId();
                 milestoneWorkTypeTemplateIds.add(woloop.Milestone_Work_Type__c);
                }
                else{
                     woloop.ownerId = userInfo.getUserId();
                }                   
                woloop.status = woloop.Previous_Status__c!=null?woloop.Previous_Status__c:newStatus;
                woloop.IsStopped = false;
                workOrderForCasesupdated.add(woloop);
            }
            if(WorkOrder.sObjectType.getDescribe().isUpdateable())
            {
            update workOrderForCasesupdated;
            }
            getMilestoneWorkTempaltes(milestoneWorkTypeTemplateIds,workOrderForCases);
        }
        
    }
    
       public void getMilestoneWorkTempaltes(Set<id> milestoneWorkTypeIds,List<WorkOrder> woList)
       {
        milestoneWorkTypeList = [select id,name,Subject__c,Description__c,Owning_Team__c from Milestone_Work_Type__c where id IN :milestoneWorkTypeIds];
           
        for(WorkOrder woloop : woList)
        {
            for(Milestone_Work_Type__c mwloop : milestoneWorkTypeList )
            {
                if(woloop.Milestone_Work_Type__c != Null && woloop.Milestone_Work_Type__c == mwloop.id)
                {
                    workOrderToMilestoneTemplate.put(woloop.id, mwloop);
                }
            }
        }
           getServiceAppointmentsForOffHold(workOrderForCases);
       }

        public void getServiceAppointmentsForOffHold(List<WorkOrder> woList)
    {
        
        SaForWorkOrders = [select id,ParentRecordId,DueDate,EarliestStartTime,status,Reason__c from ServiceAppointment where ParentRecordId IN :WoList];
        
        if(SaForWorkOrders.size()>0)
        {
                 String saCanceledStatus = 'Canceled';
                 String saOnHoldReason = 'Service On-Hold';
            for(ServiceAppointment saloop :saForWorkOrders)
            {
                if(saloop.Status==saCanceledStatus && saloop.Reason__c==saOnHoldReason)
                {
                ServiceAppointment sa = new ServiceAppointment();
                sa.EarliestStartTime=saloop.EarliestStartTime;
                sa.DueDate = saloop.DueDate;
                sa.status=noneStatus;
                sa.ParentRecordId=saloop.ParentRecordId;
                   
                    if(workOrderToMilestoneTemplate.containsKey(saloop.ParentRecordId) && workOrderToMilestoneTemplate.get(saloop.ParentRecordId) != Null){
                        
                sa.OwnerId = queueNameToId.get(workOrderToMilestoneTemplate.get(saloop.ParentRecordId).Owning_Team__c)!=null
                ?queueNameToId.get(workOrderToMilestoneTemplate.get(saloop.ParentRecordId).Owning_Team__c):userinfo.getUserId();
                        
                sa.Subject = workOrderToMilestoneTemplate.get(saloop.ParentRecordId).Subject__c;
                sa.Description = workOrderToMilestoneTemplate.get(saloop.ParentRecordId).Description__c;
                    }
                        
                saForWorkOrdersUpdated.add(sa);
                }
            }
            
            if(ServiceAppointment.sObjectType.getDescribe().isCreateable()){
            insert saForWorkOrdersUpdated;
            }
        }
        
    }
    public void getEntitlementsForOffHold(List<Account> accountEntitleList)
    {
        entitlementForAccounts = [select id,AccountId,startdate,enddate,EndDate_SDP__c,Start_DateSDP__c from Entitlement where AccountId IN :accountEntitleList];

        if(entitlementForAccounts.size()>0)
        {
            for(Entitlement entitleloop : entitlementForAccounts)
            {
                entitleloop.EndDate = entitleloop.EndDate_SDP__c;
                entitleloop.StartDate=entitleloop.Start_DateSDP__c;
                entitlementForAccountsupdated.add(entitleloop);
            }

            if(Entitlement.sObjectType.getDescribe().isUpdateable()){
                update entitlementForAccountsupdated;
                }
            
        }

}
}