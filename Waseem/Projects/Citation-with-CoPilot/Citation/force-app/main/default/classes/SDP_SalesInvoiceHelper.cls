/**
 * @File Name          : SDP_BillingContractHelper.cls
 * @Description        :
 * @Author             : Noob-Cognizant
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
public with sharing class SDP_SalesInvoiceHelper {
    static Map<String, Id> queueMap = new Map<String, Id>();
    static Map<Id, String> invoiceTypeMap = new Map<Id, String>();
    static Map<Id, Id> liInvoiceMap = new Map<Id, Id>();
    static Set<id> productIdSet = new Set<Id>();
    static Map<Id, c2g__codaInvoice__c> liInvoiceObjMap = new Map<Id, c2g__codaInvoice__c>();
    static Map<String, Id> invoiceUniqueIdentifier = new Map<String, Id>();
    static Map<Id, c2g__codaInvoiceLineItem__c> liObjMap = new Map<Id, c2g__codaInvoiceLineItem__c>();
    static Map<Id, Set<Id>> invoicewithListOfProducts = new Map<Id, Set<Id>>();
    static Map<Id, List<c2g__codaInvoiceLineItem__c>> invoiceLIListMap = new Map<Id, List<c2g__codaInvoiceLineItem__c>>();
    static Map<Id, Map<Id, Id>> invoicewithLineItemProductMap = new Map<Id, Map<Id, Id>>();
    static Map<Id, List<Asset>> liAsssetMap = new Map<Id, List<Asset>>();
    static Map<String, Id> invoicesdpMap = new Map<String, Id>();
    static Map<Id, List<Product_Milestone__c>> milestoneWithMilestoneProdMap = new Map<Id, List<Product_Milestone__c>>();
    static Map<Id, Milestone_Template__c> milestoneTemplateMap = new Map<Id, Milestone_Template__c>();
    static Map<Id, Set<Id>> milestoneWithProdSetMap = new Map<Id, Set<Id>>();
    static Map<Id, Set<Id>> liMilestoneToAppySetMap = new Map<Id, Set<Id>>();
    static Map<Id, Map<Id, set<Id>>> invoiceLIMilestoneMap = new Map<Id, Map<Id, Set<Id>>>();
    static List<case> caseListItems = new List<Case>();
    static  Map<String, String> queueMapping = new Map<String,String>{
        'H_S_Field_Support' => 'H_S_Field_Support', 
            'HR_Field_Support' => 'HR_Field_Support', 
            'Atlas_On_boarding_Support_Line_1' => 'Atlas_On_boarding_Support_Line_1', 
            'Atlas_On_boarding_Support_Line_2' => 'Atlas_On_boarding_Support_Line_2',
            'H&S Advice' => 'H_S_Advice', 
            'Reception'=> 'Reception_Team',
            'H&S Field Consultants'=> 'H_S_Field_Support',
            'Onsite_HR_Field' => 'Onsite_HR_Field',
            'Atlas On-boarding' => 'Atlas_On_boarding_Support_Line_1',
            'Client Operations'=> 'EL_and_HR_Admin',
            'Client Relations' => 'Citation_Complaints',
            'EL&HR Field Consultants' => 'EL_HR_Field_Consultants',
            'ELT&HR Advice'=>'ELT_Advice',
            'Tribunals'=>'Tribunals',
            'HR Support'=>'HR_Support'
            };
    
    public static void createCasefromInvoiceForMilestone(List<c2g__codaInvoice__c> lstInvoice,Map<Id, c2g__codaInvoice__c> oldMap) {
    List<Asset> assetList = new List<Asset>();
    Set<Id> contractIdSet = new Set<Id>();
    Set<Id> invoiceIdSet = new Set<Id>();
    List<Case> caseList = new List<Case>();
        
    if (SDP_Invoice_Util.isAlreadyRun) {
      return;
    }
        
    for(c2g__codaInvoice__c cObj : lstInvoice){
          invoiceIdSet.add(cObj.Id);
    }

    if (null == invoiceIdSet || invoiceIdSet.size() == 0) {
      return;
    }

  	queueMap = SDP_Util.getSDPQueues();
    getLineItemsProductMap(invoiceIdSet);
    assetList = SDP_Invoice_Util.populateNewAsset(liObjMap);
    upsertAssets(assetList);
    invoicesdpMap = SDP_Invoice_Util.createUniqueInvoiceSDPMapping(invoiceUniqueIdentifier);
    getTemplates();
    compareOnlyIndividualProducts();
    generateInvoiceLIMilestoneMap();
    generateMilestones();
    caseList = SDP_Util.insertSDPCases(caseListItems); 
    SDP_Invoice_Util.isAlreadyRun = true;
    SDP_Util.activateTodayMilestone(caseList); //Check here
      
  }

 public static void createCasefromInvoices(List<c2g__codaInvoice__c> newList, Map<Id, c2g__codaInvoice__c> oldMap){

    Set<Id> invoiceIdSet = new Set<Id>();
    Set<Id> newIdSet = new Set<Id>();    
    if (SDP_Invoice_Util.isAlreadyRun) {
      return;
    }
      for(c2g__codaInvoice__c cObj : newList){
           if(cObj.c2g__InvoiceStatus__c != oldMap.get(cObj.Id).c2g__InvoiceStatus__c && 
              cObj.c2g__InvoiceStatus__c == 'Complete' && 
              cObj.c2g__CompanyReference__c =='Citation Limited' &&
              cObj.c2g__Dimension3__c == null && cObj.ffps_cita__BillingDocument__c==null){
			    invoiceIdSet.add(cObj.Id);
		    }
      }
     if (null == invoiceIdSet || invoiceIdSet.size() == 0) {
      return;
    } 
        
	String invoiceIdString = '(\'';
	for (Id thisId : invoiceIdSet) { 
    	invoiceIdString += thisId + '\',\'';
		}
		invoiceIdString = invoiceIdString.substring(0,invoiceIdString.length()-2);
		invoiceIdString += ')';

		String queryParam = 'SELECT Id FROM c2g__codaInvoice__c WHERE c2g__GeneralLedgerAccount__r.Name =\'10100 - Sales Revenue\' AND Id IN ' + invoiceIdString;	
		system.debug('queryParam'+queryParam);
     
     if(System.isBatch()){
          SDP_Queueable qJob = new  SDP_Queueable(queryParam);
         System.enqueueJob(qJob);
     }else{
         SDP_BatchToGenerateSalesInvoiceCases batchInstance = new SDP_BatchToGenerateSalesInvoiceCases(queryParam, false);
         database.executebatch(batchInstance,1);
     }
    }
	
     public static void getLineItemsProductMap(Set<Id> invoiceIdSet) {
         
           for (c2g__codaInvoice__c invoiceObj : [SELECT Id,c2g__Account__c,Name,(
          											SELECT
                                                    Id,
               										Name,
                                                    c2g__ProductReference__c,
                                                    c2g__Product__c,
                                                    c2g__Product__r.Name,
               										c2g__Quantity__c,
													c2g__Invoice__c,
               										c2g__Invoice__r.c2g__Account__c
                                                    FROM
                                                    c2g__InvoiceLineItems__r
                                                    WHERE c2g__Product__c != null   
        											)
                                                  FROM c2g__codaInvoice__c
                                                  WHERE Id IN :invoiceIdSet
    ]) {
      Map<Id, Id> liProductMap = new Map<Id, Id>();
      invoiceTypeMap.put(invoiceObj.Id, 'New');
      liProductMap = populateLIData(invoiceObj);
      invoiceLIListMap.put(invoiceObj.Id,invoiceObj.c2g__InvoiceLineItems__r);
      invoicewithLineItemProductMap.put(invoiceObj.Id, liProductMap);
    }
  
  }
    
    private static Map<Id, Id> populateLIData(c2g__codaInvoice__c invoiceObj) {
    Map<Id, Id> liProductMap = new Map<Id, Id>();
    for (c2g__codaInvoiceLineItem__c liObj : invoiceObj.c2g__InvoiceLineItems__r) {
      liProductMap.put(liObj.Id, liObj.c2g__Product__c);
      liInvoiceMap.put(liObj.Id, liObj.Id);
      productIdSet.add(liObj.c2g__Product__c);
      liInvoiceObjMap.put(liObj.Id, invoiceObj);
      invoiceUniqueIdentifier.put(invoiceObj.c2g__Account__c,invoiceObj.Id);
      liObjMap.put(liObj.Id, liObj);

      if (!invoicewithListOfProducts.containsKey(invoiceObj.Id)) {
        invoicewithListOfProducts.put(invoiceObj.Id,new Set<Id>{ liObj.c2g__Product__c });
      } else {
        invoicewithListOfProducts.get(invoiceObj.Id).add(liObj.c2g__Product__c);
      }
    }
    return liProductMap;           
  }  
    
    private static void upsertAssets(List<Asset> assetList) {
    if (null == assetList || assetList.size() == 0) {
      return;
    }
    try {
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.CREATABLE,
        assetList
      );
      insert decision.getRecords();
      liAsssetMap = SDP_Invoice_Util.createLIAssetMap(decision.getRecords());
    } catch (Exception error) {
      system.debug(error.getMessage());
    }
  }
    
    
    public static void getTemplates() {
    Set<Id> milestoneTemplateIdSet = new Set<Id>();
    Set<String> reqTypes = new Set<String>();

    reqTypes = populateReqTypes(invoiceTypeMap);

    for (Product_Milestone__c pmObj : [
      SELECT Id, Product__c, Milestone_Template__c, Type__c
      FROM Product_Milestone__c
      WHERE Product__c IN :productIdSet AND Type__c IN :reqTypes
      WITH SECURITY_ENFORCED
    ]) {
      milestoneTemplateIdSet.add(pmObj.Milestone_Template__c);
    }

    if (null == milestoneTemplateIdSet || milestoneTemplateIdSet.size() == 0) {
      return;
    }

    for (Milestone_Template__c milestoneTemObj : [
      SELECT
        Id,
        Case_Type__c,
        Anniversary_Date_Months__c,
        Business__c,
        Dependent_Milestone__c,
        Due_Date_Days__c,
        Recurrence__c,
        Start_after_x_months__c,
        Name,
        Start_Date_Days__c,
        Reference_Date_field__c,
        Owning_Team__c,
        Milestone_Description__c,
        Milestone_Subject__c,
        Entitlement__c,
        (
          SELECT Id, Product__c, Milestone_Template__c, Type__c
          FROM Milestone_Products__r
          WHERE Type__c IN : reqTypes
        )
      FROM Milestone_Template__c
      WHERE ID IN :milestoneTemplateIdSet
      AND Status__c ='Active'
      WITH SECURITY_ENFORCED
    ]) {
      milestoneWithMilestoneProdMap.put(milestoneTemObj.Id,milestoneTemObj.Milestone_Products__r);
      milestoneTemplateMap.put(milestoneTemObj.Id, milestoneTemObj);
      Set<Id> productIds = new Set<Id>();
      productIds = populateProductIds(milestoneTemObj.Milestone_Products__r);
      milestoneWithProdSetMap.put(milestoneTemObj.Id, productIds);
    }
  }
    
    private static Set<String> populateReqTypes(Map<Id, String> invoiceTypeMap) {
    Set<String> returnReqTypes = new Set<String>();
    for (String inType : invoiceTypeMap.values()) {
        returnReqTypes.add(inType);
    }
    returnReqTypes.add('Both');
    returnReqTypes.remove('');
    returnReqTypes.remove(null);
    
    return returnReqTypes;
  }
    
    public static Set<Id> populateProductIds(List<Product_Milestone__c> prodMilestoneList) {
        Set<Id> prodIdsSet = new Set<Id>();
        for (Product_Milestone__c prodMilesObj : prodMilestoneList) {
            prodIdsSet.add(prodMilesObj.Product__c);
        }
        return prodIdsSet;
    } 
    
    public static void compareOnlyIndividualProducts() {
        for (Id invoiceId : invoicewithLineItemProductMap.keyset()) {
            Map<Id, Id> liProductMap = invoicewithLineItemProductMap?.get(invoiceId);
            for (Id liId : liProductMap.keyset()) {
                productComparator(liId, liProductMap);
            }
        }
    }
    
    private static void productComparator(Id liId, Map<Id, Id> liProductMap) {
        for (Id milestoneId : milestoneWithProdSetMap.keyset()) {
            if (milestoneWithProdSetMap?.get(milestoneId).contains(liProductMap?.get(liId))) {
                if (!liMilestoneToAppySetMap.containsKey(liId)) {
                    liMilestoneToAppySetMap.put(liId, new Set<id>{ milestoneId });
                } else {
                    liMilestoneToAppySetMap.get(liId).add(milestoneId);
                }
            }
        }
    }
    
    public static void generateInvoiceLIMilestoneMap() {
        for (Id liId : liMilestoneToAppySetMap.keyset()) {
            Id invoiceId = liInvoiceMap.get(liId);
            Map<Id, Set<Id>> liMilestoneSetMap = new Map<Id, Set<Id>>{liId => liMilestoneToAppySetMap?.get(liId)};
                if (!invoiceLIMilestoneMap.containsKey(invoiceId)) {
                    invoiceLIMilestoneMap.put(invoiceId, liMilestoneSetMap);
                } else {
                    invoiceLIMilestoneMap.get(invoiceId).put(liId, liMilestoneToAppySetMap?.get(liId));
                }
        }
    }
    
    public static void generateMilestones() {
        for (Id invoiceId : invoiceLIMilestoneMap.keyset()) {
            for (Id liId : invoiceLIMilestoneMap?.get(invoiceId)?.keyset()) {
                callMilestoneLogic(liId, invoiceId);
            }
        }
    }
    
    
    private static void callMilestoneLogic(Id liId, Id invoiceId) {
        
        for (Id mileStoneId : invoiceLIMilestoneMap?.get(invoiceId)?.get(liId)) {
            Milestone_Template__c template = milestoneTemplateMap.get(mileStoneId);
            if (null != template.Anniversary_Date_Months__c && template.Recurrence__c == null && template.Start_after_x_months__c == null) {
                generateSingleMilestoneCases(template, liId);
            } else if ( null == template.Anniversary_Date_Months__c && template.Recurrence__c != null && template.Start_after_x_months__c != null) {
                generateRecurrenceCases(template, liId);
            }
        }
    }
    
    public static void generateSingleMilestoneCases(Milestone_Template__c mObj,Id liId) {
        c2g__codaInvoiceLineItem__c liObj = liObjMap.get(liId);

        for (integer quantityCount = 0;quantityCount < liObj?.c2g__Quantity__c;quantityCount++) {
            MilestoneWrapper mWrap = new MilestoneWrapper();
            mWrap.mObj = mObj;
            mWrap.liObj = liObj;
            mWrap.quantityCount = quantityCount;
            mWrap.liInvoiceObjMapWrap = liInvoiceObjMap;
            mWrap.liObjMapWrap = liObjMap;
            mWrap.milestoneOwnerId = getOwnerId(mObj);
            mWrap.invoicesdpMapWrap = invoicesdpMap;
            mWrap.liAsssetMapWrap = liAsssetMap;
           List<Case> caseList = SDP_Invoice_Util.generateSingleCasesPopulator(mWrap);
            caseListItems.addAll(caseList);
        }
    }

    public class MilestoneWrapper {
        public Milestone_template__c mobj;
        public c2g__codaInvoiceLineItem__c liObj;
        public Integer quantityCount;
        public Integer recurrence;
        public Id milestoneOwnerId;
        public Map<Id, c2g__codaInvoice__c> liInvoiceObjMapWrap;
        public Map<Id, c2g__codaInvoiceLineItem__c> liObjMapWrap;
        public Map<String, Id> invoicesdpMapWrap;
        public Map<Id, List<ASset>> liAsssetMapWrap;
        
        public MilestoneWrapper() {
            mobj = new Milestone_template__c();
            liObj = new c2g__codaInvoiceLineItem__c();
            liInvoiceObjMapWrap = new Map<Id, c2g__codaInvoice__c>();
            liObjMapWrap = new Map<Id, c2g__codaInvoiceLineItem__c>();
            invoicesdpMapWrap = new Map<String, Id>();
            liAsssetMapWrap = new Map<Id, List<Asset>>();
        }
    }
    
    private static Id getOwnerId(Milestone_Template__c mObj) {
        Id ownerId = queueMap.get(queueMapping.get(mObj.Owning_Team__c)) != null ? queueMap.get(queueMapping.get(mObj.Owning_Team__c)) : userinfo.getUserId();
        return ownerId;
  }
    
    public static void generateRecurrenceCases(Milestone_Template__c mObj,Id liId) {
        integer recurrence;
        c2g__codaInvoiceLineItem__c liObj = liObjMap.get(liId);
        for (integer quantityCount = 0;quantityCount < liObj?.c2g__Quantity__c;quantityCount++) {
            recurrence = 0;
            MilestoneWrapper mWrap = new MilestoneWrapper();
            mWrap.mObj = mObj;
            mWrap.liObj = liObj;
            mWrap.quantityCount = quantityCount;
            mWrap.liInvoiceObjMapWrap = liInvoiceObjMap;
            mWrap.liObjMapWrap = liObjMap;
            mWrap.milestoneOwnerId = getOwnerId(mObj);
            mWrap.invoicesdpMapWrap = invoicesdpMap;
            mWrap.liAsssetMapWrap = liAsssetMap;
            SDP_Invoice_Util.CaseWrapper caseWrap = new SDP_Invoice_Util.CaseWrapper();  
            caseWrap = SDP_Invoice_Util.generateRecurrenceCasesPopulator(mWrap, recurrence);
            caseListItems.addAll(caseWrap.caseListWrap);
            recurrence = caseWrap.recurrenceWrap;
        }
    }
}