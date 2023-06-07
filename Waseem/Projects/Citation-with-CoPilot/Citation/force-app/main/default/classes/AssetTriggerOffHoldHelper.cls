/**
* @File Name          : AssetTriggerOffHoldHelper.apx
* @Description        : To mark Asset status as off hold.
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
Public with sharing Class AssetTriggerOffHoldHelper {
   	private	Set<Id> offHoldAssetSet = new Set<Id>();
    private List<Entitlement> offHoldentitlementList = new List<Entitlement>();
   	private List<Case> offHoldCasesList = new List<Case>();
    private List<Case> assetToCasesList = new List<Case>();
    private List<Group> queueId = new list<Group>();
    private List<WorkOrder> offHoldWOList = new List<WorkOrder>();
    private List<WorkOrder> caseToWOList = new List<WorkOrder>();
    private List<ServiceAppointment> woToNewSAList = new List<ServiceAppointment>();
    private List<ServiceAppointment> woToSAList = new List<ServiceAppointment>();
	private Map<String,Id> caseToQueueNameMap = New Map<String,Id>();
	private Set<String> caseToMTNameSet= new Set<String>();
    private Map<String,Id> woToMWTQueueNameMap = new Map<String,Id>();
	private Set<String> woToMWTQueueNameSet = new Set<String>();
    private Map<Id,Id> woToSAOwnerIdMap = new Map<Id,Id>();
        
     	//entitlement related to assets
		public void getAssetToEntitlement(List<Asset> offHoldAssetList){
			for(Entitlement entRec : [Select AssetId, id, Startdate, EndDate,Start_DateSDP__c, EndDate_SDP__c From Entitlement 
                                          Where status ='Expired' AND AssetId IN :offHoldAssetList WITH SECURITY_ENFORCED]){
                  	entRec.EndDate = Date.valueof(entRec.EndDate_SDP__c);
                    entRec.Startdate = Date.valueof(entRec.Start_DateSDP__c);
                    offHoldentitlementList.add(entRec); 
			}
			if(!offHoldentitlementList.isEmpty() && Entitlement.sObjectType.getDescribe().isUpdateable()){
               try{
                   	update offHoldentitlementList; 
               }catch(Exception ex){
                        system.debug('Exception recorded on Entitlement update:'+ex.getMessage());
               }
			}
		}
		  
		 //cases related to assets
		public  void getAssetToCases(List<Asset> offHoldAssetList){
			assetToCasesList=[select AssetId, Milestone_Template__r.Owning_Team__c, Previous_Status__c, Status from Case where status = 'On Hold' AND AssetId IN:offHoldAssetList WITH SECURITY_ENFORCED ];
			
			   for(Case casRec : assetToCasesList ){
                    if(casRec.Milestone_Template__r.Owning_Team__c != null){
						caseToMTNameSet.add(casRec.Milestone_Template__r.Owning_Team__c);
                    }
				}
			 	for(Group queRec :[select id, DeveloperName, name From group Where type = 'queue' and DeveloperName IN : caseToMTNameSet]){
					caseToQueueNameMap.put(queRec.DeveloperName,queRec.Id);
				}
			  	for(Case cRec : assetToCasesList){
                        cRec.Status = cRec.Previous_Status__c;
                        cRec.OwnerId = (caseToQueueNameMap.get(cRec.Milestone_Template__r.Owning_Team__c) != null ? caseToQueueNameMap.get(cRec.Milestone_Template__r.Owning_Team__c) : UserInfo.getUserId());
                        offHoldCasesList.add(cRec);
                } 
				if(!offHoldCasesList.isEmpty() && Case.sObjectType.getDescribe().isUpdateable()){
                    try{
						update offHoldCasesList; 
                    }catch(Exception ex){
                        system.debug('Exception recorded on Case update:'+ex.getMessage());
                    }
				}
            if(!assetToCasesList.isEmpty()){
				getCaseToWorkOrder(assetToCasesList);
            }
		}
		//workorders related to cases
		public void getCaseToWorkOrder(List<Case> offHoldCases){
		   caseToWOList = [Select CaseId, Milestone_Work_Type__r.Owning_Team__c from WorkOrder where Status = 'On Hold' And CaseId IN : offHoldCases WITH SECURITY_ENFORCED];
               for(WorkOrder woRec :caseToWOList){
                   if(woRec.Milestone_Work_Type__r.Owning_Team__c != Null){
                  		 woToMWTQueueNameSet.add(woRec.Milestone_Work_Type__r.Owning_Team__c);
                   }
                }
                for(Group grRec : [Select Id, Name From Group Where Type = 'Queue' AND Name IN : woToMWTQueueNameSet WITH SECURITY_ENFORCED ]){
                    woToMWTQueueNameMap.put(grRec.Name, grRec.Id);
                }
                For(WorkOrder woRec : caseToWOList){
                        woRec.status = 'New';
                        woRec.IsStopped = false;
                        woRec.ownerId = (woToMWTQueueNameMap.get(woRec.Milestone_Work_Type__r.Owning_Team__c) != null ? woToMWTQueueNameMap.get(woRec.Milestone_Work_Type__r.Owning_Team__c) : UserInfo.getUserId());
                        offHoldWOList.add(woRec);
                        woToSAOwnerIdMap.put(woRec.Id, woRec.ownerId);
                    
                }
                if(!offHoldWOList.isEmpty() && WorkOrder.sObjectType.getDescribe().isUpdateable()){
                    try{   
                     	update offHoldWOList;
                    }catch(Exception ex){
                        system.debug('Exception recorded on WorkOrder update:'+ex.getMessage());
                    }
                } 
            if(!caseToWOList.isEmpty()){
		    	getWorkOrderToSA(caseToWOList);
            }
		}
		  
			
		//ServiceAppointment related to workorders
		public void getWorkOrderToSA(List<WorkOrder> offHoldWorkOrder){
			woToSAList = [Select ParentRecordId, EarliestStartTime, DueDate, Status from ServiceAppointment where Status ='canceled'
									 AND ParentRecordId IN : offHoldWorkOrder WITH SECURITY_ENFORCED];
			
			if(!woToSAList.isEmpty()){
				for(ServiceAppointment saRec : woToSAList){
					ServiceAppointment cloneSARec = new ServiceAppointment();
					cloneSARec = saRec;
					cloneSARec.id = null;
					cloneSARec.Status = 'None';
                    cloneSARec.OwnerId =woToSAOwnerIdMap.get(saRec.ParentRecordId);
					woToNewSAList.add(cloneSARec);
				}
				if(!woToNewSAList.isEmpty() && ServiceAppointment.sObjectType.getDescribe().isCreateable()){
                    try{
                   		insert woToNewSAList;
                    }catch(Exception ex){ 
                        system.debug('Exception recorded on ServiceAppointment insert:'+ex.getMessage());
                    }
				}
			
			}
		}
		     
    }