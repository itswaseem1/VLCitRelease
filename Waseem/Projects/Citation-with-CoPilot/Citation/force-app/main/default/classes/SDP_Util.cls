@SuppressWarnings('PMD')
public with sharing class SDP_Util {
    public static Boolean isAlreadyRun = false;
    public static Map<String, Id> queueMap = new Map<String, Id>();
    public static Boolean isRanFromBatch = false;
    // This method checks if contract is activated and returns set of Ids
    public static Set<Id> filterContractRecords(
        List<ffbc__Contract__c> lstContract,
        Map<Id, ffbc__Contract__c> oldMap
    ) {
        Set<Id> cIdSet = new Set<Id>();
        final String ACTIVE_STATUS = 'Active';
        for (ffbc__Contract__c cont : lstContract) {
            if (
                cont.ffbc__Status__c == ACTIVE_STATUS &&
                cont.ffbc__Status__c != oldMap.get(cont.id).ffbc__Status__c &&
                cont.ffbc__Account__c != null
            ) {
                cIdSet.add(cont.Id);
            }
        }

        return cIdSet;
    }

    public static List<Case> generateSingleCasesPopulator(
        SDP_BillingContractHelper.MilestoneWrapper mWrap
    ) {
        List<Case> caseListItems = new List<Case>();
        Milestone_Template__c mObj = mWrap.mObj;
        ffbc__ContractLineItem__c cliObj = mWrap.cliObj;
        Integer quantityCount = mWrap.quantityCount;
        Map<Id, ffbc__Contract__c> cliContractObjMap = mWrap
            ?.cliContractObjMapWrap;
        Map<Id, ffbc__ContractLineItem__c> cliObjMap = mWrap?.cliObjMapWrap;
        Id reqOwnerId = mWrap?.milestoneOwnerId;
        Map<String, Id> contractsdpMap = mWrap?.contractsdpMapWrap;
        Map<Id, List<Id>> cliAsssetMap = mWrap?.cliAsssetMapWrap;

        Id cliId = cliObj?.Id;
        Date contratEndRefDate = cliObj.Service_End_Date__c != null
            ? cliObj.Service_End_Date__c
            : date.today();
        case mileStoneCase = new Case();
        mileStoneCase.AccountId = cliContractObjMap.get(cliId)
            ?.ffbc__Account__c;
        mileStoneCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get(mObj.Case_Type__c)
            .getRecordTypeId(); //Case Type on ML Matches Case Record Tyoe
        mileStoneCase.Origin = 'Service Delivery Milestone';
        mileStoneCase.Priority = 'Normal';
        mileStoneCase.Contract__c = cliContractObjMap.get(cliId)
            ?.SF_Contract__c; // related contractId
        system.debug(
            String.valueof(
                cliContractObjMap.get(cliId)?.ffbc__Account__c +
                cliObjMap.get(cliId)?.Business_Type__c
            )
        );
        mileStoneCase.Service_Delivery_Plan__c = contractsdpMap.get(
            String.valueof(
                cliContractObjMap.get(cliId)?.ffbc__Account__c +
                'Citation'
            )
        );
        mileStoneCase.Milestone_Template__c = mObj.Id; // Related Milestone Id;
        //mileStoneCase.Order__c = sdtmObj.Order__c;
        mileStoneCase.Billing_Contract__c = cliContractObjMap.get(cliId)?.Id;
        mileStoneCase.Billing_Contract_Line_Item__c = cliId;
        mileStoneCase.Subject = mObj.Milestone_Subject__c;
        mileStoneCase.EntitlementId = mObj.Entitlement__c;
        mileStoneCase.Description = mObj.Milestone_Description__c;
        mileStoneCase.ownerId = reqOwnerId;
        mileStoneCase.Status = 'Pending Start';
        List<Id> assetIdList = new List<Id>();
        assetIdList = cliAsssetMap?.get(cliId);
        milestoneCase.AssetId = assetIdList.size() > 0 ? assetIdList[quantityCount] : null ;

        Date contratStartRefDate = getContractStartReferenceDate(mObj, cliObj);

        Integer startDaysNum = mObj.Start_Date_Days__c != null
            ? (-1 * Integer.valueOf(mObj.Start_Date_Days__c))
            : 0;
        Integer dueDaysNum = mObj.Due_Date_Days__c != null
            ? Integer.valueOf(mObj.Due_Date_Days__c)
            : 0;

        mileStoneCase.Start_Date__c = mObj.Anniversary_Date_Months__c != null
            ? contratStartRefDate.addMonths(
                      Integer.valueOf(mObj.Anniversary_Date_Months__c)
                  )
                  .addDays(startDaysNum)
            : null;
        mileStoneCase.Due_Date__c = mObj.Anniversary_Date_Months__c != null
            ? (contratStartRefDate.addMonths(
                      Integer.valueOf(mObj.Anniversary_Date_Months__c)
                  ))
                  .addDays(dueDaysNum)
            : null;
        mileStoneCase.Anniversary_Date__c = mObj.Anniversary_Date_Months__c !=
            null
            ? contratStartRefDate.addMonths(
                  Integer.valueOf(mObj.Anniversary_Date_Months__c)
              )
            : null;
        if (mileStoneCase.Due_Date__c <= contratEndRefDate) {
            if( milestoneCase.AssetId != null ){
            caseListItems.add(mileStoneCase);
            }
        }
        return caseListItems;
    }

    public static Date getContractStartReferenceDate(
        Milestone_Template__c mObj,
        ffbc__ContractLineItem__c cliObj
    ) {
        date dateToreturn;
        if (mObj.Reference_Date_field__c == 'Contract Activated Date') {
            dateToreturn = date.Today();
        } else {
            dateToreturn = cliObj.Service_Start_Date__c != null
                ? cliObj.Service_Start_Date__c
                : date.today();
        }
        return dateToreturn;
    }

    public static CaseWrapper generateRecurrenceCasesPopulator(
        SDP_BillingContractHelper.MilestoneWrapper mWrap,
        Integer recurrence
    ) {
        List<Case> caseListItems = new List<Case>();
        Integer term = 0;
        Milestone_Template__c mObj = mWrap.mObj;
        ffbc__ContractLineItem__c cliObj = mWrap.cliObj;
        Integer quantityCount = mWrap.quantityCount;
        Map<Id, ffbc__Contract__c> cliContractObjMap = mWrap
            ?.cliContractObjMapWrap;
        Map<Id, ffbc__ContractLineItem__c> cliObjMap = mWrap?.cliObjMapWrap;
        Id reqOwnerId = mWrap?.milestoneOwnerId;
        Map<String, Id> contractsdpMap = mWrap?.contractsdpMapWrap;
        Map<Id, List<Id>> cliAsssetMap = mWrap?.cliAsssetMapWrap;

        Id cliId = cliObj?.Id;
        Date contratStartRefDate = getContractStartReferenceDate(mObj, cliObj);
        Date contratEndRefDate = cliObj.Service_End_Date__c != null
            ? cliObj.Service_End_Date__c
            : date.today(); // Dynamic StartDate Field

        term = contratStartRefDate.monthsBetween(contratEndRefDate);

        for (
            integer caseCount = Integer.valueof(mObj.Start_after_x_months__c);
            caseCount < term;
            caseCount += Integer.valueof(mObj.Recurrence__c)
        ) {
            case mileStoneCase = new Case();
            mileStoneCase.AccountId = cliContractObjMap.get(cliId)
                ?.ffbc__Account__c;
            mileStoneCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(mObj.Case_Type__c)
                .getRecordTypeId(); //Case Type on ML Matches Case Record Tyoe
            mileStoneCase.Origin = 'Service Delivery Milestone';
            mileStoneCase.Status = 'Pending Start';
            mileStoneCase.Priority = 'Normal';
            mileStoneCase.Contract__c = cliContractObjMap.get(cliId)
                ?.SF_Contract__c; // related contractId
            mileStoneCase.Service_Delivery_Plan__c = contractsdpMap.get(
                String.valueof(
                    cliContractObjMap.get(cliId)?.ffbc__Account__c + 
                    'Citation'
                )
            );
            mileStoneCase.Milestone_Template__c = mObj.Id; // Related Milestone Id;
            // mileStoneCase.Order__c = sdtmObj.Order__c;
            mileStoneCase.Billing_Contract__c = cliContractObjMap.get(cliId)
                ?.Id;
            mileStoneCase.Billing_Contract_Line_Item__c = cliId;
            mileStoneCase.Subject = mObj.Milestone_Subject__c;
            mileStoneCase.Description = mObj.Milestone_Description__c;
            mileStoneCase.EntitlementId = mObj.Entitlement__c;
            List<Id> assetIdList = new List<Id>();
            assetIdList = cliAsssetMap?.get(cliId);
            milestoneCase.AssetId = assetIdList.size() > 0 ? assetIdList[quantityCount] : null ;

            mileStoneCase.ownerId = reqOwnerId;

            Integer startDaysNum = mObj.Start_Date_Days__c != null
                ? (-1 * Integer.valueOf(mObj.Start_Date_Days__c))
                : 0;
            Integer dueDaysNum = mObj.Due_Date_Days__c != null
                ? Integer.valueOf(mObj.Due_Date_Days__c)
                : 0;

            mileStoneCase.Start_Date__c = mObj.Start_after_x_months__c != null
                ? (contratStartRefDate.addMonths(
                              Integer.valueOf(mObj.Start_after_x_months__c)
                          )
                          .addDays(startDaysNum))
                      .addmonths(recurrence)
                : null;
            mileStoneCase.Due_Date__c = mObj.Start_after_x_months__c != null
                ? ((contratStartRefDate.addMonths(
                              Integer.valueOf(mObj.Start_after_x_months__c)
                          ))
                          .addDays(dueDaysNum))
                      .addmonths(recurrence)
                : null;
            mileStoneCase.Anniversary_Date__c = mObj.Start_after_x_months__c !=
                null
                ? (contratStartRefDate.addMonths(
                          Integer.valueOf(mObj.Start_after_x_months__c)
                      ))
                      .addmonths(recurrence)
                : null;
            if (mileStoneCase.Due_Date__c <= contratEndRefDate) {
                if(milestoneCase.AssetId != null ){
                caseListItems.add(mileStoneCase);
                }
            }
            recurrence = recurrence + integer.valueof(mObj.Recurrence__c);
        }
        CaseWrapper caseWrapObj = new CaseWrapper();
        caseWrapObj.caseListWrap = caseListItems;
        caseWrapObj.recurrenceWrap = recurrence;

        return caseWrapObj;
    }

    public class CaseWrapper {
        public List<Case> caseListWrap;
        public Integer recurrenceWrap;

        public CaseWrapper() {
            caseListWrap = new List<Case>();
        }
    }

    public static Map<Id, List<Id>> createCLIAssetMap(List<Asset> assetList) {
        Map<Id, List<Id>> cliAsssetMap = new Map<Id, List<Id>>();
        for (asset assetObj : assetList) {
            if (
                !cliAsssetMap.containsKey(
                    assetObj.Billing_Contract_Line_Item__c
                )
            ) {
                cliAsssetMap.put(
                    assetObj.Billing_Contract_Line_Item__c,
                    new List<Id>{ assetObj.Id }
                );
            } else {
                cliAsssetMap.get(assetObj.Billing_Contract_Line_Item__c)
                    .add(assetObj.Id);
            }
        }
        return cliAsssetMap;
    }

    public static List<Asset> populateNewAsset(
        Map<Id, ffbc__ContractLineItem__c> newbcliMap
    ) {
        List<Asset> assetList = new List<Asset>();
        Set<Id> cliToExclude = new Set<Id>();
        for(Asset assetObj :[SELECT Id, Billing_Contract_Line_Item__c from Asset WHERE Billing_Contract_Line_Item__c IN: newbcliMap.keyset()]){
            cliToExclude.add(assetObj.Billing_Contract_Line_Item__c);
        }
        
        for (ffbc__ContractLineItem__c contractLIObj : newbcliMap.values()) {
            if(!cliToExclude.contains(contractLIObj.Id)){
                List<Asset> assetObjList = fetchAsset(contractLIObj);
                assetList.addall(assetObjList);
            }
        }

        return assetList;
    }

    public static Map<String, Id> createUniqueContractSDPMapping( //NO PMD
        Map<String, Id> contractUniqueIdentifier
    ) {
        Map<String, Id> contractsdpMap = new Map<String, Id>();
        Map<Id,String> businessTypeMap = new Map<Id,String>();
        Map<Id,String> accountMap = new Map<Id,String>();
        List<Service_Delivery_Plan__c> sdpInsertList = new List<Service_Delivery_Plan__c>();
        for (Service_Delivery_Plan__c serviceObj : [
            SELECT Id, Account__c, SDP_Unique__c, Business__c
            FROM Service_Delivery_Plan__c
            WHERE Account__c IN :contractUniqueIdentifier.keyset() 
            AND Business__c ='Citation'
            WITH SECURITY_ENFORCED
        ]) {
            contractsdpMap.put(
                serviceObj.Account__c + serviceObj.Business__c,
                serviceObj.Id
            );
        }

        if (contractsdpMap.isEmpty() || contractsdpMap.size() == 0) {
            
            for (ffbc__ContractLineItem__c cliObj : [
                SELECT Id,Business_Type__c,ffbc__Contract__c,ffbc__Contract__r.ffbc__Account__c,ffbc__Contract__r.ffbc__Account__r.Name
                FROM ffbc__ContractLineItem__c 
                WHERE ffbc__Contract__c IN:contractUniqueIdentifier.values()
            ]) {
                businessTypeMap.put(cliObj.ffbc__Contract__c, cliObj.Business_Type__c);
                accountMap.put(cliObj.ffbc__Contract__c, cliObj.ffbc__Contract__r.ffbc__Account__r.Name);
            }
            for (String accId : contractUniqueIdentifier.keyset()) {
                String nameVal = 'Citation SDP ' + accountMap.get(contractUniqueIdentifier.get(accId));
                if(nameVal.length() > 80 ){
    					nameVal = nameVal.substring(0, 79);
					}
                Service_Delivery_Plan__c sObj = new Service_Delivery_Plan__c(
                    Name = nameVal, 
                    Account__c = accId,
                    Business__c = 'Citation'
                );
                sdpInsertList.add(sObj);
            }
        }

        if (null != sdpInsertList && sdpInsertList.size() > 0) {
            insert sdpInsertList;
        }

        for (Service_Delivery_Plan__c sObj : sdpInsertList) {
            contractsdpMap.put(sObj.Account__c + sObj.Business__c, sObj.Id);
        }

        return contractsdpMap;
    }

    // Perform DML for cases
    public static List<case> insertSDPCases(List<Case> lstCase) {
        try {
            if (null != lstCase && lstCase.size() > 0) {
                insert lstCase;
                return lstCase;
            }
        } catch (Exception error) {
            system.debug(error.getMessage());
        }
        return null;
    }

    public static List<Asset> fetchAsset(
        ffbc__ContractLineItem__c contractLIObj
    ) {
        List<Asset> asstList = new List<Asset>();
        for (
            Integer count = 0;
            count < Integer.valueof(contractLIObj.ffbc__Quantity__c);
            count++
        ) {
            Asset assetObj = new Asset();
            assetObj.Service_Start_Date__c = contractLIObj
                ?.Service_Start_Date__c;
            assetObj.Service_End_Date__c = contractLIObj?.Service_End_Date__c;
            assetObj.Product2Id = contractLIObj?.ffbc__ProductService__c;
            assetObj.Business_Area__c = contractLIObj?.Business_Type__c;
            assetObj.Name =
                'SDP_Asset:' +
                string.valueof(count + 1) +
                contractLIObj?.Name;
            assetObj.AccountId = contractLIObj
                ?.ffbc__Contract__r
                ?.ffbc__Account__c;
            assetObj.Billing_Contract__c = contractLIObj?.ffbc__Contract__c;
            assetObj.Billing_Contract_Line_Item__c = contractLIObj?.Id;
            assetObj.Contract__c = contractLIObj
                ?.ffbc__Contract__r
                ?.SF_Contract__c;
            asstList.add(assetObj);
        }

        return asstList;
    }

    //This method will fetch the all the necessary SDP Queues
    public static Map<String, Id> getSDPQueues() {
        Map<String, Id> queueMap = new Map<String, Id>();
        List<String> sdpQueues = system.label.SDPQueues?.split(',');
        for (Group queObj : [
            SELECT Id, DeveloperName
            FROM Group
            WHERE Type = 'Queue' WITH SECURITY_ENFORCED
        ]) {
            queueMap.put(queObj.DeveloperName, queObj.Id);
        }
        return queueMap;
    }

    public static void activateTodayMilestone(List<Case> caseList) {
        if (caseList == null || caseList.isEmpty()) {
            return;
        }
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> sdpIdSet = new Set<Id>();
        for (Case caseObj : caseList) {
            if (caseObj.Start_Date__c <= Date.today()) {
                caseIdSet.add(caseObj.Id);
                sdpIdSet.add(caseObj.Service_Delivery_Plan__c);
            }
        }

        if (caseIdSet.isEmpty()) {
            return;
        }

        //  SDP_BatchToActivateMilestones batchInstance = new SDP_BatchToActivateMilestones(caseIdSet);
        SDP_BundleBatch batchInstance = new SDP_BundleBatch(
            sdpIdSet,
            caseIdSet,
            true
        );
        if (Test.isRunningTest() || System.isBatch()) {
            return;
        }
        database.executeBatch(batchInstance, 1);
    }
}