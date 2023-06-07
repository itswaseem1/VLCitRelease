/**
* @File Name          : ServiceAppointmentTriggerHandler.apx
* @Description        :
* @Author             : Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 3-12-2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     3/13/2021      Initial Version						SS-337
* 1.1     26/04/2021     Updated for Community Profiles
**/
public with sharing class ServiceAppointmentTriggerHandler {
    
    public static Map<Id, ServiceAppointment> workOrderServAppMap = new Map<Id, ServiceAppointment>();
    public static Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
    public static Map<Id, Id> workOrderAccSitMap = new Map<Id, Id>();
    public static Map<Id,Id> saWoMap = new Map<Id,Id>();
    public static Map<Id,ServiceAppointment> saMap = new Map<Id,ServiceAppointment>();
    public static List<ResourcePreference> resourcePreferenceList = new List<ResourcePreference>();
    
    public static void updateAppointmentDetails( List<ServiceAppointment> appointmentList ){
        
        for( ServiceAppointment serviceAppObj : appointmentList ){
            if ( serviceAppObj.ParentRecordId != NULL ){
                workOrderServAppMap.put( serviceAppObj.ParentRecordId, serviceAppObj );
            }
        }
        
        if( NULL != workOrderServAppMap && workOrderServAppMap.size() > 0  ){
            getWorkOrderDetails( workOrderServAppMap );
        }
        
        if ( NULL != workOrderMap && workOrderMap.size() > 0 ){
            populateServiceAppointmentDetails( workOrderServAppMap, workOrderMap );
            populateServiceAppointmentTerritory( workOrderServAppMap, workOrderMap );
        }
        
        
    }
    
    //Community FSL book appoinement error if user tries to create Service Appointment from Community
    public static void checkCommunityUser (list<ServiceAppointment> serviceAppointmentList){//NOPMD
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];//NOPMD
        String myProflieNamee = profile[0].Name;
        for(ServiceAppointment sAppt : serviceAppointmentList){
            If( myProflieNamee == 'Citation Customer Community Login User'){
                
                serviceclass.runSALogic=false;
                String erMessageCustLabel = Label.community_Service_Appt_Creation;
                sAppt.addError(erMessageCustLabel);
                return;
                
            }
        }
        
    }
    
    public static void getWorkOrderDetails ( Map<Id, ServiceAppointment>  workServiceMap ){
        
        for( WorkOrder workOrderObj : [ SELECT Id, AccountId, ContactId,AccountSite__c,AccountSite__r.Site_Type__c,
                                       Milestone_Work_Type__c,ServiceTerritory.name, 
                                       Visit_Type__c,milestone_work_type__r.Meeting_type__c,
                                       milestone_work_type__r.Customer_Friendly_Meeting_Name__c,
                                       createdDate, Case.Due_Date__c, Case.Start_Date__c, Duration,
                                       WorkTypeId,DurationType,ServiceTerritoryId,
                                       milestone_work_type__r.Milestone_Template__r.Business__c,milestone_work_type__r.subject__c,
                                       EndDate
                                       FROM WorkOrder 
                                       WHERE ID IN: workServiceMap.keyset()] ){
                                           workOrderMap.put( workOrderObj.Id, workOrderObj );
                                           workOrderAccSitMap.put(workOrderObj.Id,workOrderObj.AccountSite__c );
                                       }
    }
    
    public static void populateServiceAppointmentDetails ( Map<Id, ServiceAppointment> serviceMap, Map<Id, WorkOrder> workMap ){
        
        for( Id workId : serviceMap.keyset() ){
            
            ServiceAppointment appointmentObj = serviceMap.get(workId);
            appointmentObj.Business__c=workMap.get(workId).milestone_work_type__r.Milestone_Template__r.Business__c!=null?
                workMap.get(workId).milestone_work_type__r.Milestone_Template__r.Business__c:'Citation';
            //appointmentObj.ContactId = workMap.get(workId)?.ContactId;
            //System.debug('s360 workMap: '+workMap.get(workId));
            //System.debug('s360 AccountSite__r.Site_Type__c: '+workMap.get(workId).AccountSite__r.Site_Type__c);
            //System.debug('s360 milestone_work_type__r.subject__c: '+workMap.get(workId).milestone_work_type__r.subject__c);
            if(workMap.get(workId).AccountSite__r.Site_Type__c!=null && workMap.get(workId).milestone_work_type__r.subject__c!=null){
                if(workMap.get(workId).AccountSite__r.Site_Type__c.equals('Main Site') && workMap.get(workId).milestone_work_type__r.subject__c.equalsIgnoreCase(Label.s360_Scheduling_Priority_Subject))
                {
                    appointmentObj.Scheduling_Priority__c=1;
                }
                else if (!workMap.get(workId).AccountSite__r.Site_Type__c.equals('Main Site') && workMap.get(workId).milestone_work_type__r.subject__c.equalsIgnoreCase(Label.s360_Scheduling_Priority_Subject))
                {
                    appointmentObj.Scheduling_Priority__c=2;
                }
                else{
                    appointmentObj.Scheduling_Priority__c=3;
                }
                
            }
            else{
                appointmentObj.Scheduling_Priority__c=3;
            }
            appointmentObj.AccountSite__c = appointmentObj.AccountSite__c!=null?appointmentObj.AccountSite__c:workMap.get(workId)?.AccountSite__c;
            if(test.isRunningTest()){
                appointmentObj.DueDate = workMap.get(workId)?.Case.Due_Date__c;
            }
            appointmentObj.EarliestStartTime = SDP_BillingContractConstants.useCaseStartDate ? workMap.get(workId)?.Case.Start_Date__c : workMap.get(workId)?.CreatedDate;
            //appointmentObj.Duration = workMap.get(workId)?.Duration;
            appointmentObj.DurationType = workMap.get(workId)?.DurationType;
            appointmentObj.Milestone_Work_Type__c = appointmentObj.Milestone_Work_Type__c!=null?appointmentObj.Milestone_Work_Type__c:workMap.get(workId)?.Milestone_Work_Type__c;
            //appointmentObj.ServiceTerritoryId= appointmentObj.ServiceTerritoryId!=null?appointmentObj.ServiceTerritoryId:workMap.get(workId)?.ServiceTerritoryId;
            appointmentObj.Visit_Type__c=appointmentObj.Visit_Type__c!=null?appointmentObj.Visit_Type__c:workMap.get(workId)?.Visit_Type__c;
            appointmentObj.Meeting_type__c = workMap.get(appointmentObj.ParentRecordId).milestone_work_type__r.Meeting_type__c;//ss-676
            appointmentObj.Customer_Friendly_Meeting_Name__c = workMap.get(appointmentObj.ParentRecordId).milestone_work_type__r.Customer_Friendly_Meeting_Name__c;//ss-676
            appointmentObj.Target_Due_Date__c = workMap.get(appointmentObj.ParentRecordId).EndDate; //SS-928
            //System.debug('s360 appointmentObj: '+appointmentObj);
        }
    } 
    //ss-815
    public static void populateServiceAppointmentTerritory ( 
        Map<Id, ServiceAppointment> serviceMap, 
        Map<Id, WorkOrder> workMap ){
            List<ServiceTerritory> serTerriList = new List<ServiceTerritory>([Select Id, Name from ServiceTerritory where Name = 'Noviqa Territory' Limit 1]);
            
            List<Site__c> accSiteList = new list<Site__c>( [Select Id, Street__c, City__c, Country__c, Postcode__c from Site__c where 
                                                            Country__c != null AND  Country__c in ('Ireland', 'ROI', 'Republic of Ireland') AND Postcode__c != null and Postcode__c like 'BT%' AND Street__c != null AND City__c != null 
                                                            AND Id IN :workOrderAccSitMap.values()]);
            for( Id workId : serviceMap.keyset() ){
                ServiceAppointment appointmentObj = serviceMap.get(workId);
                
                if(workMap.get(workId)?.Visit_Type__c == 'Face-To-Face' && workMap.get(workId)?.ServiceTerritory.name == 'QMS Territory' 
                   && (appointmentObj.Status == 'None' || appointmentObj.Status == 'Scheduled')){
                       for(Site__c accSitRec : accSiteList){
                           appointmentObj.ServiceTerritoryId = serTerriList[0].Id;
                       }
                   }else{
                       appointmentObj.ServiceTerritoryId= appointmentObj.ServiceTerritoryId!=null?appointmentObj.ServiceTerritoryId:workMap.get(workId)?.ServiceTerritoryId;
                   }
            }
        }
    // SS-804
    public static void premiumConsultancyLogic(List<ServiceAppointment> newSerAppList, Map<Id, ServiceAppointment> oldSerAppMap){
        
        Map<Id,Id> serviceResourceSAMap = new Map<Id,Id>(); 
        Map<Id,Id> caseIdMap = new Map<Id,Id>();
        List<ResourcePreference> resourcePreferenceList = new List<ResourcePreference>();
        checkStatus(newSerAppList, oldSerAppMap);
        for( AssignedResource asObj : [SELECT Id, ServiceAppointmentId,ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId IN:saMap.keyset() ]){
            serviceResourceSAMap.put(asObj.ServiceAppointmentId, asObj.ServiceResourceId);
        }
        
        for( WorkOrder wObj : [SELECT Id,caseId FROM WorkOrder WHERE ID IN: saWoMap.keyset() AND subject Like '%Premium Consultancy%'  AND Milestone_Work_Type__r.Milestone_Template__r.Business__c ='QMS' ]){
            caseIdMap.put(wObj.caseId, wObj.Id);
        }
        
        resourcePreferenceList = generateResourcePreference(caseIdMap,serviceResourceSAMap);
        
        insertResourcePreferenceList(resourcePreferenceList);
        
    }
    
    public static void checkStatus(List<ServiceAppointment> newSerAppList, Map<Id, ServiceAppointment> oldSerAppMap){
        for(ServiceAppointment saObj : newSerAppList){           
            if( saObj.Status == 'Completed' && saObj.Status  != oldSerAppMap.get(saObj.Id).Status && saObj.parentRecordId != null){
                saMap.put(saObj.Id, saObj);
                saWoMap.put(saObj.parentRecordId, saObj.Id);
            }
        }
    }
    
    public static List<ResourcePreference> generateResourcePreference(Map<Id,Id> caseIdMap,Map<Id,Id> serviceResourceSAMap){
        
        for( WorkOrder wObj : [SELECT Id,caseId FROM WorkOrder WHERE caseId IN:caseIdMap.keyset() AND subject like '%Certification Audit Visit%' AND Milestone_Work_Type__r.Milestone_Template__r.Business__c ='QMS']){
            
            Id reqSRId = serviceResourceSAMap?.get(saWoMap?.get(caseIdMap?.get(wObj.caseId))) != null ?  serviceResourceSAMap?.get(saWoMap?.get(caseIdMap?.get(wObj.caseId))) : null;            
            mapResourcePref(reqSRId, wObj.Id);    
        }
        
        return resourcePreferenceList;
    }
    
    public static void insertResourcePreferenceList(List<ResourcePreference> resourcePreferenceList){
        if(null != resourcePreferenceList && resourcePreferenceList.size() > 0 && Schema.sObjectType.ResourcePreference.isCreateable()){
            insert resourcePreferenceList;
        }
    }
    
    public static void mapResourcePref(Id reqSRId, Id workOrderId){
        if(reqSRId != null){
            ResourcePreference raObj =new ResourcePreference(serviceresourceId = reqSRId, relatedrecordId = workOrderId, PreferenceType = 'Excluded');
            resourcePreferenceList.add(raObj);
        }
    }
    
    //Change by Siddhartha-ValueLabs
    public static void updateGanttColorAndResource(List<ServiceAppointment> newSerAppList, Map<Id, ServiceAppointment> oldSerAppMap){
        Set<Id> allScheduledIds = new Set<Id>();
        Map<Id,Id>SAvsAssignedResource=new Map<Id,Id>();
        if(Trigger.isInsert){
            for(ServiceAppointment s:newSerAppList){
                if(s.status=='Scheduled')
                    s.FSL__GanttColor__c=Label.FSL_SA_ScheduledColor;
                else if(s.status=='Confirmed')
                    s.FSL__GanttColor__c=Label.FSL_SA_ConfirmedColor;
            }
        }
        else{
            for(ServiceAppointment s:newSerAppList){
                if(s.Status!= oldSerAppMap.get(s.Id).Status){
                    if(s.status=='Scheduled')
                    {
                        s.FSL__GanttColor__c=Label.FSL_SA_ScheduledColor;
                        allScheduledIds.add(s.id);
                    }
                    else if(s.status=='Confirmed')
                        s.FSL__GanttColor__c=Label.FSL_SA_ConfirmedColor;
                    else if(s.FSL__GanttColor__c!=null && (s.FSL__GanttColor__c==Label.FSL_SA_ScheduledColor || s.FSL__GanttColor__c==Label.FSL_SA_ConfirmedColor))
                        s.FSL__GanttColor__c=null;
                }
                
            }    
            
            if(!allScheduledIds.isEmpty()){
                for (AssignedResource ar: [select id,ServiceAppointmentId,ServiceResourceId from AssignedResource where 
                                           ServiceAppointmentId in:allScheduledIds])
                {
                    SAvsAssignedResource.put(ar.ServiceAppointmentId,ar.ServiceResourceId);
                }
                for(ServiceAppointment s:newSerAppList){
                    if(s.Status!= oldSerAppMap.get(s.Id).Status && s.Status=='Scheduled'){
                        s.Service_Resource__c=SAvsAssignedResource.get(s.Id);
                    }
                }
            }
            
        }
        
    }    
    
    
    public static void updateCancelledData(List<ServiceAppointment> newSerAppList, Map<Id, ServiceAppointment> oldSerAppMap){
        Set<Id> allCancelledIds = new Set<Id>();
        
        for(ServiceAppointment s:newSerAppList){
            if(s.Status!= oldSerAppMap.get(s.Id).Status && s.Status=='Canceled'){
                allCancelledIds.add(s.id);
            }
        }
        Map<Id,Id>SAvsAssignedResource=new Map<Id,Id>();
        if(!allCancelledIds.isEmpty()){
            for (AssignedResource ar: [select id,ServiceAppointmentId,ServiceResourceId from AssignedResource where 
                                       ServiceAppointmentId in:allCancelledIds all rows ])
            {
                SAvsAssignedResource.put(ar.ServiceAppointmentId,ar.ServiceResourceId);
            }
            for(ServiceAppointment s:newSerAppList){
                if(s.Status!= oldSerAppMap.get(s.Id).Status && s.Status=='Canceled'){
                    s.Cancelled_Startdate__c=oldSerAppMap.get(s.Id).SchedStartTime;
                    s.Cancelled_Resource__c=SAvsAssignedResource.get(s.Id);
                    s.Service_Resource__c=null;
                }
            }
        }
        
    }
    
}