/**
 * @File Name          : SDP_BillingContractHelper.cls
 * @Description        :
 * @Author             : Maanas -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 4/6/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     4/6/2021      Initial Version 
 **/
@SuppressWarnings('PMD') 
public with sharing class SDP_BillingContractHelper {
  static Map<String, Id> queueMap = new Map<String, Id>();
  static Set<id> productIdSet = new Set<Id>();
  static Map<Id, Set<Id>> contractwithListOfProducts = new Map<Id, Set<Id>>();
  static Map<Id, List<Product_Milestone__c>> milestoneWithMilestoneProdMap = new Map<Id, List<Product_Milestone__c>>();
  static Map<Id, Set<Id>> milestoneWithProdSetMap = new Map<Id, Set<Id>>();
  static Map<Id, Map<Id, Id>> contractwithLineItemProductMap = new Map<Id, Map<Id, Id>>();
  static Map<Id, Id> allMatchMilestoneContractMap = new Map<Id, Id>();
  static Map<Id, Id> cliMilestoneMap = new Map<Id, Id>();
  static Map<Id, Map<Id, set<Id>>> contractCLIMilestoneMap = new Map<Id, Map<Id, Set<Id>>>();
  static Map<Id, List<ffbc__ContractLineItem__c>> contractCLIListMap = new Map<Id, List<ffbc__ContractLineItem__c>>();
  static Map<Id, ffbc__ContractLineItem__c> cliObjMap = new Map<Id, ffbc__ContractLineItem__c>();
  static Map<Id, Id> cliContractMap = new Map<Id, Id>();
  static Map<Id, Milestone_Template__c> milestoneTemplateMap = new Map<Id, Milestone_Template__c>();
  static Map<Id, ffbc__Contract__c> cliContractObjMap = new Map<Id, ffbc__Contract__c>();
  static Map<String, Id> contractUniqueIdentifier = new Map<String, Id>();
  static Map<String, Id> contractsdpMap = new Map<String, Id>();
  static List<case> caseListItems = new List<Case>();
  static Map<Id, String> contractTypeMap = new Map<Id, String>();
  static Map<Id, Set<Id>> cliMilestoneToAppySetMap = new Map<Id, Set<Id>>();
  static Map<Id, List<Id>> cliAsssetMap = new Map<Id, List<Id>>();
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
                                        'HR Support'=>'HR_Support',
                                        'Fire Operations'=>'Fire_Operations'
                                                                 };

  public static void createCaseformContractForMilestone(
    List<ffbc__Contract__c> lstContract,
    Map<Id, ffbc__Contract__c> oldMap
  ) {
    List<Asset> assetList = new List<Asset>();
    Set<Id> contractIdSet = new Set<Id>();
    Set<Id> newIdSet = new Set<Id>();
      List<Case> caseList = new List<Case>();
    if (SDP_Util.isAlreadyRun) {
      return;
    }
      for(ffbc__Contract__c cObj : lstContract){
          newIdSet.add(cObj.Id);
      }
      Set<Id> nonQMSContractIdSet = new Set<Id>();
      for( ffbc__Contract__c conObj : [SELECT Id FROM ffbc__Contract__c WHERE ffbc__Company__r.Name != 'QMS International Limited' AND ID IN:newIdSet]){
          nonQMSContractIdSet.add(conObj.Id);
      }
    if(!SDP_Util.isRanFromBatch){
        set<Id> allContractIds =new Set<Id>();
        allContractIds = SDP_Util.filterContractRecords(lstContract, oldMap);
        for( Id contractId : allContractIds){
            if( nonQMSContractIdSet.contains(contractId )){
                contractIdSet.add(contractId);
            }
        }
        
    }else{
        for( ffbc__Contract__c bContractObj : lstContract){
            if(nonQMSContractIdSet.contains(bContractObj.Id )){
                contractIdSet.add(bContractObj.Id);
            }
        }
      }

    if (null == contractIdSet || contractIdSet.size() == 0) {
      return;
    }

    queueMap = SDP_Util.getSDPQueues();
    getLineItemsProductMap(contractIdSet);
    assetList = SDP_Util.populateNewAsset(cliObjMap);
    upsertAssets(assetList);
    contractsdpMap = SDP_Util.createUniqueContractSDPMapping(
      contractUniqueIdentifier
    );
    getTemplates();
    compareOnlyIndividualProducts();
    generateContractCLIMilestoneMap();
    generateMilestones();
    caseList = SDP_Util.insertSDPCases(caseListItems); 
    SDP_Util.isAlreadyRun = true;
    SDP_Util.activateTodayMilestone(caseList);
      
  }

  public static void getLineItemsProductMap(Set<Id> contractIdSet) {
    for (ffbc__Contract__c contractObj : [
      SELECT
        Id,
        ffbc__Account__c,
        SF_Contract__c,
        Contract_Type__c,
        (
          SELECT
            Id,
            Name,
            Business_Type__c,
            Service_Start_Date__c,
            Service_End_Date__c,
            ffbc__ProductService__c,
            ffbc__Quantity__c,
            ffbc__Contract__c,
            ffbc__Contract__r.ffbc__Account__c,
            ffbc__Contract__r.SF_Contract__c
          FROM ffbc__ContractLineItems__r
        )
      FROM ffbc__Contract__c
      WHERE Id IN :contractIdSet
    ]) {
      Map<Id, Id> cliProductMap = new Map<Id, Id>();
      contractTypeMap.put(contractObj.Id, contractObj.Contract_Type__c);
      cliProductMap = populateCLIData(contractObj);
      contractCLIListMap.put(
        contractObj.Id,
        contractObj.ffbc__ContractLineItems__r
      );
      contractwithLineItemProductMap.put(contractObj.Id, cliProductMap);
    }
  }

  public static void getTemplates() {
    Set<Id> milestoneTemplateIdSet = new Set<Id>();
    Set<String> reqTypes = new Set<String>();

    reqTypes = populateReqTypes(contractTypeMap);

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
          WHERE Type__c IN :reqTypes
        )
      FROM Milestone_Template__c
      WHERE ID IN :milestoneTemplateIdSet
      AND Status__c ='Active'
      WITH SECURITY_ENFORCED
    ]) {
      milestoneWithMilestoneProdMap.put(
        milestoneTemObj.Id,
        milestoneTemObj.Milestone_Products__r
      );
      milestoneTemplateMap.put(milestoneTemObj.Id, milestoneTemObj);
      Set<Id> productIds = new Set<id>();
      productIds = populateProductIds(milestoneTemObj.Milestone_Products__r);
      milestoneWithProdSetMap.put(milestoneTemObj.Id, productIds);
    }
  }

  public static void compareOnlyIndividualProducts() {
    for (Id contractId : contractwithLineItemProductMap.keyset()) {
      Map<Id, Id> cliProductMap = contractwithLineItemProductMap
        ?.get(contractId);
      for (Id cliId : cliProductMap.keyset()) {
        productComparator(cliId, cliProductMap);
      }
    }
  }

  public static void generateContractCLIMilestoneMap() {
    for (Id cliId : cliMilestoneToAppySetMap.keyset()) {
      Id contracId = cliContractMap.get(cliId);
      Map<Id, Set<Id>> cliMilestoneSetMap = new Map<Id, Set<Id>>{
        cliId => cliMilestoneToAppySetMap?.get(cliId)
      };
      if (!contractCLIMilestoneMap.containsKey(contracId)) {
        contractCLIMilestoneMap.put(contracId, cliMilestoneSetMap);
      } else {
        contractCLIMilestoneMap.get(contracId)
          .put(cliId, cliMilestoneToAppySetMap?.get(cliId));
      }
    }
  }

  public static void generateMilestones() {
    for (Id contractId : contractCLIMilestoneMap.keyset()) {
      for (Id cliId : contractCLIMilestoneMap?.get(contractId)?.keyset()) {
        callMilestoneLogic(cliId, contractId);
      }
    }
  }

  public static void generateSingleMilestoneCases(
    Milestone_Template__c mObj,
    Id cliId
  ) {
    ffbc__ContractLineItem__c cliObj = cliObjMap.get(cliId);
    Date contratEndRefDate = cliObj?.Service_End_Date__c != null
      ? cliObj.Service_End_Date__c
      : date.today(); // Dynamic StartDate Field

    for (
      integer quantityCount = 0;
      quantityCount < cliObj?.ffbc__Quantity__c;
      quantityCount++
    ) {
      MilestoneWrapper mWrap = new MilestoneWrapper();
      mWrap.mObj = mObj;
      mWrap.cliObj = cliObj;
      mWrap.quantityCount = quantityCount;
      mWrap.cliContractObjMapWrap = cliContractObjMap;
      mWrap.cliObjMapWrap = cliObjMap;
        mWrap.milestoneOwnerId = getOwnerId(mObj);
        mWrap.contractsdpMapWrap = contractsdpMap;
        mWrap.cliAsssetMapWrap = cliAsssetMap;
        List<Case> caseList;
        
            caseList = SDP_Util.generateSingleCasesPopulator(mWrap);
       
        caseListItems.addAll(caseList);
    }
  }

  public static void generateRecurrenceCases(
    Milestone_Template__c mObj,
    Id cliId
  ) {
    integer recurrence;
    ffbc__ContractLineItem__c cliObj = cliObjMap.get(cliId);
    for (
      integer quantityCount = 0;
      quantityCount < cliObj?.ffbc__Quantity__c;
      quantityCount++
    ) {
      recurrence = 0;
      MilestoneWrapper mWrap = new MilestoneWrapper();
      mWrap.mObj = mObj;
      mWrap.cliObj = cliObj;
      mWrap.quantityCount = quantityCount;
      mWrap.cliContractObjMapWrap = cliContractObjMap;
      mWrap.cliObjMapWrap = cliObjMap;
      mWrap.milestoneOwnerId = getOwnerId(mObj);
      mWrap.contractsdpMapWrap = contractsdpMap;
      mWrap.cliAsssetMapWrap = cliAsssetMap;
      SDP_Util.CaseWrapper caseWrap = new SDP_Util.CaseWrapper();  
      caseWrap = SDP_Util.generateRecurrenceCasesPopulator(mWrap, recurrence);
      caseListItems.addAll(caseWrap.caseListWrap);
      recurrence = caseWrap.recurrenceWrap;
    }
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
      cliAsssetMap = SDP_util.createCLIAssetMap(decision.getRecords());
    } catch (Exception error) {
      system.debug(error.getMessage());
    }
  }

  public class MilestoneWrapper {
    public Milestone_template__c mobj;
    public ffbc__ContractLineItem__c cliObj;
    public Integer quantityCount;
    public Integer recurrence;
    public Id milestoneOwnerId;
    public Map<Id, ffbc__Contract__c> cliContractObjMapWrap;
    public Map<Id, ffbc__ContractLineItem__c> cliObjMapWrap;
    public Map<String, Id> contractsdpMapWrap;
    public Map<Id, List<Id>> cliAsssetMapWrap;

    public MilestoneWrapper() {
      mobj = new Milestone_template__c();
      cliObj = new ffbc__ContractLineItem__c();
      cliContractObjMapWrap = new Map<Id, ffbc__Contract__c>();
      cliObjMapWrap = new Map<Id, ffbc__ContractLineItem__c>();
      contractsdpMapWrap = new Map<String, Id>();
      cliAsssetMapWrap = new Map<Id, List<Id>>();
    }
  }

  private static Id getOwnerId(Milestone_Template__c mObj) {
    Id ownerId = queueMap.get(queueMapping.get(mObj.Owning_Team__c)) != null
      ? queueMap.get(queueMapping.get(mObj.Owning_Team__c))
      : userinfo.getUserId();
    return ownerId;
  }

  private static void callMilestoneLogic(Id cLiId, Id contractId) {
      
    for (
      Id mileStoneId : contractCLIMilestoneMap?.get(contractId)?.get(cliId)
    ) {
      Milestone_Template__c template = milestoneTemplateMap.get(mileStoneId);
        
      if (
        null != template.Anniversary_Date_Months__c &&
        template.Recurrence__c == null &&
        template.Start_after_x_months__c == null
      ) {
        generateSingleMilestoneCases(template, cliId);
      } else if (
        null == template.Anniversary_Date_Months__c &&
        template.Recurrence__c != null &&
        template.Start_after_x_months__c != null
      ) {
        generateRecurrenceCases(template, cliId);
      }
    }
  }

  private static void productComparator(Id cliId, Map<Id, Id> cliProductMap) {
    for (Id milestoneId : milestoneWithProdSetMap.keyset()) {
      if (
        milestoneWithProdSetMap
          ?.get(milestoneId)
          .contains(cliProductMap?.get(cliId))
      ) {
        //  cliMilestoneMap.put(cliId, milestoneId );
        if (!cliMilestoneToAppySetMap.containsKey(cliId)) {
          cliMilestoneToAppySetMap.put(cliId, new Set<id>{ milestoneId });
        } else {
          cliMilestoneToAppySetMap.get(cliId).add(milestoneId);
        }
      }
    }
  }

  public static Set<Id> populateProductIds(
    List<Product_Milestone__c> prodMilestoneList
  ) {
    Set<Id> prodIdsSet = new Set<Id>();
    for (Product_Milestone__c prodMilesObj : prodMilestoneList) {
      prodIdsSet.add(prodMilesObj.Product__c);
    }
    return prodIdsSet;
  }

  private static Set<String> populateReqTypes(Map<Id, String> contractTypeMap) {
    Set<String> returnReqTypes = new Set<String>();
    for (String conType : contractTypeMap.values()) {
        returnReqTypes.add(conType);
    }
    returnReqTypes.add('Both');
    returnReqTypes.remove('');
    returnReqTypes.remove(null);
    
    return returnReqTypes;
  }

  private static Map<Id, Id> populateCLIData(ffbc__Contract__c contractObj) {
    Map<Id, Id> cliProductMap = new Map<Id, Id>();
    for (
      ffbc__ContractLineItem__c cliObj : contractObj.ffbc__ContractLineItems__r
    ) {
      cliProductMap.put(cliObj.Id, cliObj.ffbc__ProductService__c);
      cliContractMap.put(cliObj.Id, contractObj.Id);
      productIdSet.add(cliObj.ffbc__ProductService__c);
      cliContractObjMap.put(cliObj.Id, contractObj);
      contractUniqueIdentifier.put(
        contractObj.ffbc__Account__c,
        contractObj.Id
      );
      cliObjMap.put(cliObj.Id, cliObj);

      if (!contractwithListOfProducts.containsKey(contractObj.Id)) {
        contractwithListOfProducts.put(
          contractObj.Id,
          new Set<Id>{ cliObj.ffbc__ProductService__c }
        );
      } else {
        contractwithListOfProducts.get(contractObj.Id)
          .add(cliObj.ffbc__ProductService__c);
      }
    }
    return cliProductMap;           
  }
    
    public static void createCaseformContractForMilestoneInBatch(List<ffbc__Contract__c> lstContract, Map<Id, ffbc__Contract__c> oldMap){

    Set<Id> contractIdSet = new Set<Id>();
    Set<Id> newIdSet = new Set<Id>();    
    if (SDP_Util.isAlreadyRun) {
      return;
    }
      for(ffbc__Contract__c cObj : lstContract){
          newIdSet.add(cObj.Id);
      }
      Set<Id> nonQMSContractIdSet = new Set<Id>();
      for( ffbc__Contract__c conObj : [SELECT Id FROM ffbc__Contract__c WHERE ffbc__Company__r.Name != 'QMS International Limited' AND ID IN:newIdSet]){
          nonQMSContractIdSet.add(conObj.Id);
      }
  
      for( ffbc__Contract__c bContractObj : lstContract){
            if(nonQMSContractIdSet.contains(bContractObj.Id )){
            if(bContractObj.ffbc__Status__c != oldMap.get(bContractObj.Id).ffbc__Status__c && bContractObj.ffbc__Status__c == 'Active'){
                contractIdSet.add(bContractObj.Id);
            }
            }
        }
      

    if (null == contractIdSet || contractIdSet.size() == 0) {
      return;
    }
    String contractIdString = '(\'';
    for (Id thisId : contractIdSet) {
        contractIdString += thisId + '\',\'';
        }
        contractIdString = contractIdString.substring(0,contractIdString.length()-2);
        contractIdString += ')';

        String queryParam = 'SELECT Id FROM ffbc__Contract__c WHERE Id IN ' + contractIdString; 
        
        SDP_BatchForHistoricBillingContracts batchInstance = new SDP_BatchForHistoricBillingContracts(queryParam, false);
        database.executebatch(batchInstance,1);
    }

}