/**
 * @File Name          : CaseTriggerCreateWorkOrders.cls
 * @Description        :
 * @Author             : Maanas -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 4/14/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     2/22/2021      Initial Version
 **/
public with sharing class WorkOrderSDPDependencyHandler {
 
    
    private  List<ServiceAppointment> updateContactOnSAList = new List<ServiceAppointment>();
    private  Set<Id> woContactMapToSAIdSet = new Set<Id>();
   
    
    public  void updateSDPDependency( List<WorkOrder> newWorkOrderList,Map<Id, WorkOrder> oldWorkOrderMap)
    {
        findChangedWorkOrders(newWorkOrderList,oldWorkOrderMap);
        Savepoint sp = Database.setSavepoint();
        try
        {
            updateRelatedServiceAppointment();
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            throw e;
        }
    }
    
    private void  findChangedWorkOrders(List<WorkOrder> newWorkOrderList,Map<Id, WorkOrder> oldWorkOrderMap){
        
        for (WorkOrder workOrderObj : newWorkOrderList) {
            if(workOrderObj.ContactId != null && workOrderObj.Status == 'New'){
                woContactMapToSAIdSet.add(workOrderObj.id);
            }
            
        }
    }
    
    private  void updateRelatedServiceAppointment(){
        for(WorkOrder workRec : [ Select Id, ContactId, (Select Id, ContactId,EarliestStartTime from ServiceAppointments) from WorkOrder where Id IN :woContactMapToSAIdSet]){
            for(ServiceAppointment saRec : workRec.ServiceAppointments ){
                saRec.ContactId = workRec.ContactId;
                updateContactOnSAList.add(saRec);
            }
            
        }  
        if (null != updateContactOnSAList && updateContactOnSAList.size() > 0) {
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(updateContactOnSAList);
                       
        }
    }
}