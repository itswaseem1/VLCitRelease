/**
 * @File Name          : MapContactOnWorkOrderQueuableHandler.cls
 * @Description        : TO map contactId on workorder creation.
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/09/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     06/06/2021      Initial Version
 **/
public with sharing class MapContactOnWorkOrderQueuableHandler {

     public static Map<Id,Id> mainSiteAccContMap = new Map<Id,Id>();
    public static Map<Id, Id> accAssetMap = new Map<Id, Id>();	
    public static Map<Id, Id> juncContMainSitConMap = new Map<Id, Id>();
    public static Map<Id, Id> juncContMainHSConMap = new Map <Id, Id>();
    public static Map<Id, Id> juncContMainPELConMap = new Map<Id, Id>();
    public static Map<Id, Id> juncContMainQMSConMap = new Map<Id, Id>();
    public static Map<Id, Id> juncContSecHSConMap = new Map <Id, Id>();
    public static Map<Id, Id> juncContSecPELConMap = new Map<Id, Id>();
    public static Map<Id, Id> juncContSecQMSConMap = new Map<Id, Id>();
    public static Set<Id> aSitJucsiteSet = new Set<Id>();
    public static Set<Id> workOrderAccountIDSet = new Set<Id>();
    public static Map<Id, Id> workOrderASMWTMap = new Map<Id, Id>();
    public static List<WorkOrder> contactOnWorkOrderList = new List<WorkOrder>();
    public static List<WorkOrder> newWOList = new List<WorkOrder>();
    public static Id conId = null;

	public static List<WorkOrder> populateContactOnWO(List<WorkOrder> newWOList1){
		newWOList =  [Select Id,AccountId,ContactId, AccountSite__c,Milestone_Work_Type__c,Milestone_Work_Type__r.Service_Contact__c from WorkOrder where Id IN : newWOList1];
		for(WorkOrder woRec : newWOList ){
			workOrderAccountIDSet.add(woRec.AccountId);
			workOrderASMWTMap.put(woRec.AccountSite__c,woRec.Milestone_Work_Type__c);
		}
		for(Account acc : [Select Id,(Select Id From Contacts Where Main_User__c = 'Yes' Limit 1) 
											From Account Where Id IN : workOrderAccountIDSet WITH SECURITY_ENFORCED]){
			for(Contact con : acc.Contacts){
				mainSiteAccContMap.put(acc.Id,con.Id);
			}
		}
		for(Asset astRec: [Select Id, AccountId, Billing_Contract__r.SF_Contract__r.CustomerSignedId From Asset Where AccountId IN : workOrderAccountIDSet WITH SECURITY_ENFORCED]){
				if(astRec.Billing_Contract__r.SF_Contract__r.CustomerSignedId != Null){
					accAssetMap.put(astRec.AccountId,astRec.Billing_Contract__r.SF_Contract__r.CustomerSignedId);
				}
		}
        getSiteContact();
        contactOnWorkOrderList =  populateSiteContactOnWO(newWOList);
        return contactOnWorkOrderList;
        
    }
        
    public static void  getSiteContact(){ 
		for(Site_Junction__c siteJuncRec : [Select Id, Account__c,Site_Junction__c,Contact_Junction__c, Main_H_S_Contact__c,Main_PEL_Contact__c,Main_Site_Contact__c,
																					Secondary_H_S_Contact__c,Secondary_PEL_Contact__c,Main_QMS_Contact__c,Secondary_QMS_Contact__c,
																					Secondary_Site_Contact__c From Site_Junction__c Where Contact_Junction__c != null 
																					AND Site_Junction__c IN :workOrderASMWTMap.keySet() WITH SECURITY_ENFORCED]){
					  
																					 
						if(siteJuncRec.Main_Site_Contact__c){
								   juncContMainSitConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
									 
                        }else if(siteJuncRec.Main_H_S_Contact__c ){
                            		juncContMainHSConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
                        }
                        else if(siteJuncRec.Secondary_H_S_Contact__c){
									juncContSecHSConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
                        }
											
                        getSiteContact2( siteJuncRec);
               }
    }
    public static void getSiteContact2(Site_Junction__c siteJuncRec){
                                                                                       
                          if(siteJuncRec.Main_PEL_Contact__c){
                              juncContMainPELConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
                          }
                          else if(siteJuncRec.Secondary_PEL_Contact__c){
							  juncContSecPELConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
                          }		
								
                          else if(siteJuncRec.Main_QMS_Contact__c){
                              juncContMainQMSConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
                          }
                          else if(siteJuncRec.Secondary_QMS_Contact__c){
                              juncContSecQMSConMap.put(siteJuncRec.Site_Junction__c,siteJuncRec.Contact_Junction__c);
                          }
                 
		          
    }
    public static List<WorkOrder> populateSiteContactOnWO(List<WorkOrder> newWOList){
		   
		 for(WorkOrder woRec : newWOList){
			if(woRec.Milestone_Work_Type__r.Service_Contact__c == 'Main Site Contact'){
				woRec.ContactId = (juncContMainSitConMap.get(woRec.AccountSite__c) != null ? juncContMainSitConMap.get(woRec.AccountSite__c) : mainSiteAccContMap.get(woRec.AccountId));
			}
            else if(woRec.Milestone_Work_Type__r.Service_Contact__c == 'Contract Signatory'){
				woRec.ContactId = (accAssetMap.get(woRec.AccountId) != null ? accAssetMap.get(woRec.AccountId) : mainSiteAccContMap.get(woRec.AccountId));
			}
			else if(woRec.Milestone_Work_Type__r.Service_Contact__c == 'Main User'){
				woRec.ContactId = mainSiteAccContMap.get(woRec.AccountId);
			}
			
            contactOnWorkOrderList =  populateSiteContactOnWO2(woRec);
        	
         }return contactOnWorkOrderList;
    }
   public static List<WorkOrder> populateSiteContactOnWO2(WorkOrder woRec){
       
			if(woRec.Milestone_Work_Type__r.Service_Contact__c == 'QMS Service Contact'){
				Id conId = (juncContMainQMSConMap.get(woRec.AccountSite__c) != null ? juncContMainQMSConMap.get(woRec.AccountSite__c) : juncContSecQMSConMap.get(woRec.AccountSite__c));
                woRec.ContactId = (ConId != null ? ConId : mainSiteAccContMap.get(woRec.AccountId));
			}
			else if(woRec.Milestone_Work_Type__r.Service_Contact__c == 'H&S Service Contact'){
				Id conId  = (juncContMainHSConMap.get(woRec.AccountSite__c) != null ? juncContMainHSConMap.get(woRec.AccountSite__c) : juncContSecHSConMap.get(woRec.AccountSite__c));
                woRec.ContactId = (ConId != null ? ConId : mainSiteAccContMap.get(woRec.AccountId) );
			}
			
         contactOnWorkOrderList = populateSiteContactOnWO3(woRec);
		
       	 return contactOnWorkOrderList;
    }
     public static List<WorkOrder> populateSiteContactOnWO3(WorkOrder woRec){
       
			 if(woRec.Milestone_Work_Type__r.Service_Contact__c == 'PEL Service Contact'){
				Id conId  = (juncContMainPELConMap.get(woRec.AccountSite__c) != null ? juncContMainPELConMap.get(woRec.AccountSite__c) :juncContSecPELConMap.get(woRec.AccountSite__c));
                woRec.ContactId = (ConId != null ? ConId : mainSiteAccContMap.get(woRec.AccountId) );
			}
             contactOnWorkOrderList.add(woRec);
		
       	 return contactOnWorkOrderList;
    }
	
}