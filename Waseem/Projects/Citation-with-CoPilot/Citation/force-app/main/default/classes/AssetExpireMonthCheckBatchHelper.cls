/**
 * @File Name          : AssetExpireMonthCheckBatchHelper.cls
 * @Description        : TO marck asset status obsolete.
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/09/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     26/7/2021      Initial Version
 **/
public without sharing class AssetExpireMonthCheckBatchHelper {
    
    public Static List<Asset> obsoleteAssetList = new List<Asset>();
    public static List<Case> assetCasesList = new List<Case>();
    public static List<Case> assetToCasesList = new List<Case>();
    public static List<WorkOrder> caseWorkOrderList = new List<WorkOrder>();
    public static List<WorkOrder> caseToWorkOrderList = new List<WorkOrder>();
    public static List<ServiceAppointment> woSerAppList = new List<ServiceAppointment>();
    public static List<ServiceAppointment> woToSerAppList = new List<ServiceAppointment>();
    public Static Set<Id> newAssetSet = new Set<Id>();
    
    public static void getDetailsOnAssetExpires(List<Asset> assetList){
        
        for(Asset asRec : assetList ){
            asRec.Status = 'Obsolete';
            obsoleteAssetList.add(asRec);
            date newDate = asRec.Service_Start_Date__c.addMonths(6);
            if(newDate < asRec.Service_End_date__c && asRec.Product2.Business_Type__c == 'Citation'){
                newAssetSet.add(asRec.id);
                	
            }
            
        }
        if(!obsoleteAssetList.isEmpty() && Asset.sObjectType.getDescribe().isUpdateable()){
            try{
                update obsoleteAssetList;
            }Catch(Exception ex){
                System.debug(' Exception in update Asset'+ ex);
            }
        }
        
        getAssetCasesToMarkMissed();
    }
    
    public static void getAssetCasesToMarkMissed(){
        assetToCasesList =  [ select Id,Asset_2__c, AssetId, Status from Case where Status Not IN( 'Completed', 'Skipped', 'Missed')
                             													AND (AssetId IN : newAssetSet OR Asset_2__c IN : newAssetSet)  ];
       
        for(Case casRec :assetToCasesList) {
            casRec.status = 'Missed';
            assetCasesList.add(casRec);
        }
        if(!assetCasesList.isEmpty() && Case.sObjectType.getDescribe().isUpdateable()){
            try{
                update assetCasesList;
            }Catch(Exception ex){
                System.debug(' Exception in update cases'+ ex);
            }
        }
        getCasesToWorkorderToMarkCC();
    }
    public static void getCasesToWorkorderToMarkCC(){
        caseToWorkOrderList =  [ select Id, CaseId, Status from WorkOrder where Status Not IN( 'Closed', 'Completed', 'Cannot complete', 'Canceled')
                            												AND CaseId IN :assetToCasesList  WITH SECURITY_ENFORCED ];
        
        for(WorkOrder woRec : caseToWorkOrderList) {
            woRec.status = 'Cannot complete';
            caseWorkOrderList.add(woRec);
        }
        if(!caseWorkOrderList.isEmpty() && WorkOrder.sObjectType.getDescribe().isUpdateable()){
            try{
                update caseWorkOrderList;
            }Catch(Exception ex){
                System.debug(' Exception in update WorkOrder'+ ex);
            }
        }
        getWorkOrderToSerAppToMarkCC();
        
    }
    public static void getWorkOrderToSerAppToMarkCC(){
        woToSerAppList =  [ select Id, ParentRecordId, Status from ServiceAppointment where Status Not IN('Closed', 'Completed', 'Cannot complete', 'Canceled')
                             												AND ParentRecordId IN :caseToWorkOrderList  WITH SECURITY_ENFORCED ];
         
        for(ServiceAppointment serAppRec :woToSerAppList) {
            serAppRec.status = 'Cannot complete';
            serAppRec.reason__c = 'Service Window Closed';
            woSerAppList.add(serAppRec);
        }
        if(!woSerAppList.isEmpty() && ServiceAppointment.sObjectType.getDescribe().isUpdateable()){
			try{
				update woSerAppList;
			}Catch(Exception ex){
				System.debug(' Exception in update ServiceAppointment'+ ex);
			}
        }
    }
}