@SuppressWarnings('PMD')
public with sharing class SDP_Invoice_Util {

    public static boolean isAlreadyRun = false;
    public static boolean isRanFromBatch = false; 
    
    

    public static List<Asset> populateNewAsset(Map<Id, c2g__codaInvoiceLineItem__c> newinvoiceliMap) {
        List<Asset> assetList = new List<Asset>();
        Set<Id> liToExclude = new Set<Id>();
        for(Asset assetObj :[SELECT Id, Sales_Invoice_Line_Item__c from Asset WHERE Sales_Invoice_Line_Item__c IN: newinvoiceliMap.keyset()]){
            liToExclude.add(assetObj.Sales_Invoice_Line_Item__c);
        }
        
        for (c2g__codaInvoiceLineItem__c invoiceLIObj : newinvoiceliMap.values()) {
            if(!liToExclude.contains(invoiceLIObj.Id)){
                List<Asset> assetObjList = fetchAsset(invoiceLIObj);
                assetList.addall(assetObjList);
            }
        }

        return assetList;
    }
    
    
    public static List<Asset> fetchAsset(c2g__codaInvoiceLineItem__c invoiceLIObj) {
        List<Asset> asstList = new List<Asset>();
        for (Integer count = 0;count < Integer.valueof(invoiceLIObj.c2g__Quantity__c);count++) {
            Asset assetObj = new Asset();
            assetObj.Service_Start_Date__c = Date.today();
            assetObj.Service_End_Date__c =  Date.today().addDays(60);
            assetObj.Product2Id = invoiceLIObj?.c2g__Product__c;
            assetObj.Business_Area__c = 'Citation';
            assetObj.Name ='SDP_Asset:' +string.valueof(count + 1) + invoiceLIObj?.Name;
            assetObj.AccountId = invoiceLIObj?.c2g__Invoice__r?.c2g__Account__c;
            assetObj.Sales_Invoice__c = invoiceLIObj?.c2g__Invoice__c;
            assetObj.Sales_Invoice_Line_Item__c = invoiceLIObj?.Id;
            //assetObj.Contract__c = invoiceLIObj?.ffbc__Contract__r?.SF_Contract__c;
            asstList.add(assetObj);
        }

        return asstList;
    }
    
    public static Map<Id, List<Asset>> createLIAssetMap(List<Asset> assetList) {
        Map<Id, List<Asset>> liAsssetMap = new Map<Id, List<Asset>>();
        for (asset assetObj : assetList) {
            if (!liAsssetMap.containsKey(assetObj.Sales_Invoice_Line_Item__c )) {
                liAsssetMap.put(assetObj.Sales_Invoice_Line_Item__c,new List<Asset>{ assetObj});
            } else {
                liAsssetMap.get(assetObj.Sales_Invoice_Line_Item__c).add(assetObj);
            }
        }
        return liAsssetMap;
    }
    
    public static Map<String, Id> createUniqueInvoiceSDPMapping(Map<String, Id> invoiceUniqueIdentifier) {
        Map<String, Id> invoicesdpMap = new Map<String, Id>();
        Map<Id,String> businessTypeMap = new Map<Id,String>();
        Map<Id,String> accountMap = new Map<Id,String>();
        List<Service_Delivery_Plan__c> sdpInsertList = new List<Service_Delivery_Plan__c>();
        for (Service_Delivery_Plan__c serviceObj : [
            SELECT Id, Account__c, SDP_Unique__c, Business__c
            FROM Service_Delivery_Plan__c
            WHERE Account__c IN :invoiceUniqueIdentifier.keyset() 
            AND Business__c ='Citation'
            WITH SECURITY_ENFORCED
        ]) {
            invoicesdpMap.put(serviceObj.Account__c + serviceObj.Business__c,serviceObj.Id);
        }
        
        if (invoicesdpMap.isEmpty() || invoicesdpMap.size() == 0) {
            
            for (c2g__codaInvoiceLineItem__c liObj : [
                SELECT Id,c2g__Invoice__c,c2g__Invoice__r.c2g__Account__c,c2g__Invoice__r.c2g__Account__r.Name
                FROM c2g__codaInvoiceLineItem__c 
                WHERE c2g__Invoice__c IN:invoiceUniqueIdentifier.values()
            ]) {
                businessTypeMap.put(liObj.c2g__Invoice__c, 'New');
                accountMap.put(liObj.c2g__Invoice__c, liObj.c2g__Invoice__r.c2g__Account__r.Name);
            }
            for (String accId : invoiceUniqueIdentifier.keyset()) {
                String nameVal = 'Citation SDP ' + accountMap.get(invoiceUniqueIdentifier.get(accId));
                if(nameVal.length() > 80 ){
                    nameVal = nameVal.substring(0, 79);
                }
                Service_Delivery_Plan__c sObj = new Service_Delivery_Plan__c(Name = nameVal, Account__c = accId,Business__c = 'Citation');
                sdpInsertList.add(sObj);
            }
        }
        
        if (null != sdpInsertList && sdpInsertList.size() > 0) {
            insert sdpInsertList;
        }
        
        for (Service_Delivery_Plan__c sObj : sdpInsertList) {
            invoicesdpMap.put(sObj.Account__c + sObj.Business__c, sObj.Id);
        }
        
        return invoicesdpMap;
    }
    
    
    public static List<Case> generateSingleCasesPopulator(SDP_SalesInvoiceHelper.MilestoneWrapper mWrap) {
        
        List<Case> caseListItems = new List<Case>();
        Milestone_Template__c mObj = mWrap.mObj;
        c2g__codaInvoiceLineItem__c liObj = mWrap.liObj;
        Integer quantityCount = mWrap.quantityCount;
        Map<Id, c2g__codaInvoice__c> liInvoiceObjMap = mWrap?.liInvoiceObjMapWrap;
        Map<Id, c2g__codaInvoiceLineItem__c> liObjMap = mWrap?.liObjMapWrap;
        Id reqOwnerId = mWrap?.milestoneOwnerId;
        Map<String, Id> invoicesdpMap = mWrap?.invoicesdpMapWrap;
        Map<Id, List<Asset>> liAsssetMap = mWrap?.liAsssetMapWrap;
        
        Id liId = liObj?.Id;
        List<Asset> assetList = liAsssetMap.get(liId);
        Date invoiceEndRefDate = assetList[0]?.Service_End_Date__c != null ? assetList[0]?.Service_End_Date__c : date.today();
        case mileStoneCase = new Case();
        mileStoneCase.AccountId = liInvoiceObjMap.get(liId)?.c2g__Account__c;
        mileStoneCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(mObj.Case_Type__c).getRecordTypeId(); //Case Type on ML Matches Case Record Tyoe
        mileStoneCase.Origin = 'Service Delivery Milestone';
        mileStoneCase.Priority = 'Normal';
        mileStoneCase.Service_Delivery_Plan__c = invoicesdpMap.get(String.valueof(liInvoiceObjMap.get(liId)?.c2g__Account__c +'Citation'));
        mileStoneCase.Milestone_Template__c = mObj.Id; // Related Milestone Id;
        mileStoneCase.Sales_Invoice__c = liInvoiceObjMap.get(liId)?.Id;
        mileStoneCase.Sales_Invoice_Line_Item__c = liId;
        mileStoneCase.Subject = mObj.Milestone_Subject__c;
        mileStoneCase.EntitlementId = mObj.Entitlement__c;
        mileStoneCase.Description = mObj.Milestone_Description__c;
        mileStoneCase.ownerId = reqOwnerId;
        mileStoneCase.Status = 'Pending Start';
        List<Asset> assetIdList = new List<Asset>();
        assetIdList = liAsssetMap?.get(liId);
        milestoneCase.AssetId = assetIdList.size() > 0 ? assetIdList[quantityCount]?.Id : null ;
        Date invoiceStartRefDate = getInvoiceStartReferenceDate(mObj, liObj, assetIdList);
        
        Integer startDaysNum = mObj.Start_Date_Days__c != null ? (-1 * Integer.valueOf(mObj.Start_Date_Days__c)) : 0;
        Integer dueDaysNum = mObj.Due_Date_Days__c != null ? Integer.valueOf(mObj.Due_Date_Days__c) : 0;
        
        mileStoneCase.Start_Date__c = mObj.Anniversary_Date_Months__c != null ? invoiceStartRefDate.addMonths(Integer.valueOf(mObj.Anniversary_Date_Months__c)).addDays(startDaysNum) : null;
        mileStoneCase.Due_Date__c = mObj.Anniversary_Date_Months__c != null? (invoiceStartRefDate.addMonths(Integer.valueOf(mObj.Anniversary_Date_Months__c))).addDays(dueDaysNum) : null;
        mileStoneCase.Anniversary_Date__c = mObj.Anniversary_Date_Months__c != null? invoiceStartRefDate.addMonths(Integer.valueOf(mObj.Anniversary_Date_Months__c)) : null;
        if (mileStoneCase.Due_Date__c <= invoiceEndRefDate) {
            if( milestoneCase.AssetId != null ){
                caseListItems.add(mileStoneCase);
            }
        }
        return caseListItems;
    }
    
    public static Date getInvoiceStartReferenceDate(Milestone_Template__c mObj,c2g__codaInvoiceLineItem__c liObj, List<Asset> assetIdList) {
        date dateToreturn;
        if (mObj.Reference_Date_field__c == 'Contract Activated Date') {
            dateToreturn = date.Today();
        } else {
            dateToreturn = assetIdList[0].Service_Start_Date__c != null ? assetIdList[0].Service_Start_Date__c : date.today();
        }
        return dateToreturn;
    }
    
    public class CaseWrapper {
        public List<Case> caseListWrap;
        public Integer recurrenceWrap;
        
        public CaseWrapper() {
            caseListWrap = new List<Case>();
        }
    }
    
    
    public static CaseWrapper generateRecurrenceCasesPopulator(SDP_SalesInvoiceHelper.MilestoneWrapper mWrap,Integer recurrence) {
        
        List<Case> caseListItems = new List<Case>();
        Integer term = 0;
        Milestone_Template__c mObj = mWrap.mObj;
        c2g__codaInvoiceLineItem__c liObj = mWrap.liObj;
        Integer quantityCount = mWrap.quantityCount;
        Map<Id, c2g__codaInvoice__c> liInvoiceObjMap = mWrap?.liInvoiceObjMapWrap;
        Map<Id, c2g__codaInvoiceLineItem__c> liObjMap = mWrap?.liObjMapWrap;
        Id reqOwnerId = mWrap?.milestoneOwnerId;
        Map<String, Id> invoicesdpMap = mWrap?.invoicesdpMapWrap;
        Map<Id, List<Asset>> liAsssetMap = mWrap?.liAsssetMapWrap;
        
        Id liId = liObj?.Id;
        List<Asset> assetIdList = new List<Asset>();
        assetIdList = liAsssetMap?.get(liId);
        
        Date invoiceStartRefDate = getInvoiceStartReferenceDate(mObj, liObj, assetIdList);
        Date invoiceEndRefDate = assetIdList[0]?.Service_End_Date__c != null ? assetIdList[0]?.Service_End_Date__c : date.today(); // Dynamic StartDate Field
        
        term = invoiceStartRefDate.monthsBetween(invoiceEndRefDate);
        
        for (integer caseCount = Integer.valueof(mObj.Start_after_x_months__c);caseCount < term;caseCount += Integer.valueof(mObj.Recurrence__c)) {
            case mileStoneCase = new Case();
            mileStoneCase.AccountId = liInvoiceObjMap.get(liId)?.c2g__Account__c;
            mileStoneCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(mObj.Case_Type__c).getRecordTypeId(); //Case Type on ML Matches Case Record Tyoe
            mileStoneCase.Origin = 'Service Delivery Milestone';
            mileStoneCase.Status = 'Pending Start';
            mileStoneCase.Priority = 'Normal';
            mileStoneCase.Service_Delivery_Plan__c = invoicesdpMap.get(String.valueof(liInvoiceObjMap.get(liId)?.c2g__Account__c + 'Citation'));
            mileStoneCase.Milestone_Template__c = mObj.Id; // Related Milestone Id;
            mileStoneCase.Sales_Invoice__c = liInvoiceObjMap.get(liId)?.Id;
            mileStoneCase.Sales_Invoice_Line_Item__c = liId;
            mileStoneCase.Subject = mObj.Milestone_Subject__c;
            mileStoneCase.Description = mObj.Milestone_Description__c;
            mileStoneCase.EntitlementId = mObj.Entitlement__c;
            milestoneCase.AssetId = assetIdList.size() > 0 ? assetIdList[quantityCount]?.Id : null ;
            
            mileStoneCase.ownerId = reqOwnerId;
            
            Integer startDaysNum = mObj.Start_Date_Days__c != null ? (-1 * Integer.valueOf(mObj.Start_Date_Days__c)) : 0;
            Integer dueDaysNum = mObj.Due_Date_Days__c != null ? Integer.valueOf(mObj.Due_Date_Days__c) : 0;
            
            mileStoneCase.Start_Date__c = mObj.Start_after_x_months__c != null ? (invoiceStartRefDate.addMonths(Integer.valueOf(mObj.Start_after_x_months__c)).addDays(startDaysNum)).addmonths(recurrence) : null;
            mileStoneCase.Due_Date__c = mObj.Start_after_x_months__c != null ? ((invoiceStartRefDate.addMonths(Integer.valueOf(mObj.Start_after_x_months__c))).addDays(dueDaysNum)).addmonths(recurrence): null;
            mileStoneCase.Anniversary_Date__c = mObj.Start_after_x_months__c != null ? (invoiceStartRefDate.addMonths(Integer.valueOf(mObj.Start_after_x_months__c))).addmonths(recurrence) : null;
            
            if (mileStoneCase.Due_Date__c <= invoiceEndRefDate) {
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
}