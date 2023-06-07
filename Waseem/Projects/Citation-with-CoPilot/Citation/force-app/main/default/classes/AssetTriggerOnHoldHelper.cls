/**
* @File Name          : AssetTriggerOnHoldHelper.apx
* @Description        : To mark Asset status as On Hold.
* @Author             : Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 4/29/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     4/26/2021      Initial Version            SS-518
**/
Public With Sharing Class AssetTriggerOnHoldHelper {
  
       Private Set<Id> onHoldAssetSet = new Set<Id>();
       Private List<Entitlement> onHoldentitlementList = new List<Entitlement>();
   	   Private List<Case> onHoldCasesList = new List<Case>();
       Private List<Case> assetToCasesList = new List<Case>();
       Private list<Group> onHoldQueueId = new list<Group>();
       Private List<WorkOrder> onHoldWOList = new List<WorkOrder>();
       Private List<WorkOrder> caseToWOList = new List<WorkOrder>();
       Private List<ServiceAppointment> onHoldSAList = new List<ServiceAppointment>();
       Private List<ServiceAppointment> woToSAList = new List<ServiceAppointment>();
        
        
        //entitlement related to assets 
		public void getAssetToEntitlement(List<Asset> onHoldAssetList){
				for(Entitlement entRec : [Select AssetId, id, EndDate, Start_DateSDP__c,StartDate From Entitlement 
                                          Where status = 'Active' AND AssetId IN :onHoldAssetList WITH SECURITY_ENFORCED]){
						entRec.EndDate_SDP__c = Date.valueof(entRec.EndDate); 
                        entRec.Start_DateSDP__c = Date.valueof(entRec.StartDate);
                        entRec.StartDate=system.today()-10;
						entRec.EndDate = system.today()-1 ;
						onHoldentitlementList.add(entRec);
					
				}
				if(!onHoldentitlementList.isEmpty() && Entitlement.sObjectType.getDescribe().isUpdateable()){
                    try{
						update onHoldentitlementList;
                    }catch(Exception ex){
                        system.debug('Exception recorded on Entitlement update:'+ex.getMessage());
                    }
				}
			
		}
		//cases related to assets
		public void getAssetToCases(List<Asset> onHoldAssetList){
			assetToCasesList = [select AssetId,Previous_Status__c, Status, ownerId From Case Where status = 'Active' AND AssetId In:onHoldAssetList WITH SECURITY_ENFORCED ];
			onHoldQueueId = [select id, Name, type from group where Name = 'On-Hold' AND type = 'queue'  WITH SECURITY_ENFORCED];
	   					
			if(!assetToCasesList.isEmpty()){
				for(Case caseRec : assetToCasesList ){
						  caseRec.Previous_Status__c=caseRec.status;
						  caseRec.status= 'On Hold';
						  caseRec.ownerId = onHoldQueueId[0].Id;
						  onHoldCasesList.add(caseRec) ;          
				}
				if(!onHoldCasesList.isEmpty() && Case.sObjectType.getDescribe().isUpdateable()){
                    try{
                    	update onHoldCasesList;
                    }catch(Exception ex){
                        system.debug('Exception recorded on Case update:'+ex.getMessage());
                    }
				}
			}
			getCaseToWorkOrder(assetToCasesList);
		}
		//workorders related to cases
		public void getCaseToWorkOrder(List<Case> onHoldCasesList ){
			caseToWOList = [Select CaseId, Status, ownerId, IsStopped From WorkOrder 
                            Where (Status != 'QMS Canceled' OR Status != 'Customer Canceled') And CaseId IN:onHoldCasesList WITH SECURITY_ENFORCED];
			if(!caseToWOList.isEmpty()){
				for(WorkOrder woRec : caseToWOList){
					woRec.status = 'On Hold';
					woRec.IsStopped = true;
					woRec.ownerId = onHoldQueueId[0].Id;
					onHoldWOList.add(woRec);
				}
				if(!onHoldWOList.isEmpty() && WorkOrder.sObjectType.getDescribe().isUpdateable()){
                    try{
                    	update onHoldWOList;
                    }catch(Exception ex){
                        system.debug('Exception recorded on WorkOrder update:'+ex.getMessage());
                    }
				}
			}
			getWorkOrderToSA(caseToWOList);
		}
		//ServiceAppointment related to workorders
		Public void getWorkOrderToSA(List<WorkOrder> onHoldWorkOrder){
			woToSAList = [Select ParentRecordId, Status, Reason__c from ServiceAppointment where (Status != ' Canceled' 
						  OR Status != 'Completed'	OR Status != ' cannot complete') AND ParentRecordId IN : onHoldWorkOrder WITH SECURITY_ENFORCED];
			if(!woToSAList.isEmpty()){
				for(ServiceAppointment saRec : woToSAList){
					saRec.Status = 'Canceled';
					saRec.Reason__c =  'Service On-hold';
					onHoldSAList.add(saRec);
				}
				if(!onHoldSAList.isEmpty() && ServiceAppointment.sObjectType.getDescribe().isUpdateable()){
                    try{
                    	update onHoldSAList;
                    }catch(Exception ex){
                        system.debug('Exception recorded on ServiceAppointment update:'+ex.getMessage());
                    }
				}
			}
		}
           
	}