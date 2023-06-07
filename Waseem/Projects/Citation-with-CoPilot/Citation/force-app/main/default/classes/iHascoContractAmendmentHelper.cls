public class iHascoContractAmendmentHelper {
    
    public SBQQ__Quote__c quote;
    public subWrapper objSubWrapper;
    public static subWrapper processSubcriptions(List<SBQQ__Subscription__c> allRelatedSubList) {
        List<SBQQ__Subscription__c> allAmendsubList = new List<SBQQ__Subscription__c>();
        List<SBQQ__QuoteLine__c> lastQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Subscription__c> allOriginalSubList = new List<SBQQ__Subscription__c>();
        Map<Id, List<SBQQ__Subscription__c>> originalGroupWiseSubListMap = new Map<Id, List<SBQQ__Subscription__c>>();
        Decimal originalCustomerPriceTemp = 0;
        Decimal originalAnnualPriceTemp=0;
        Decimal amendAnnualPriceTemp = 0;
        Decimal ContractTermTemp=0;
        if(allRelatedSubList.size() > 0) {
            for(SBQQ__Subscription__c objSub : allRelatedSubList) {
                if(originalGroupWiseSubListMap.containsKey(objSub.SBQQ__QuoteLine__r.SBQQ__Group__c)) {
                    List<SBQQ__Subscription__c> tempList = originalGroupWiseSubListMap.get(objSub.SBQQ__QuoteLine__r.SBQQ__Group__c);
                    tempList.add(objSub);
                    originalGroupWiseSubListMap.put(objSub.SBQQ__QuoteLine__r.SBQQ__Group__c, tempList);
                }
                else {
                    originalGroupWiseSubListMap.put(objSub.SBQQ__QuoteLine__r.SBQQ__Group__c, new List<SBQQ__Subscription__c>{objSub});
                }
            }
            List<Id> originalGroupWiseSubListMapKeyList = new List<Id>();
            originalGroupWiseSubListMapKeyList.addAll(originalGroupWiseSubListMap.keySet());
            List<SBQQ__Subscription__c> latestGroupSubList;
            List<SBQQ__Subscription__c> latestSecondGroupSubList;
            List<Id> latestSecondGroupSubExcludeList;
            List<SBQQ__Subscription__c> latestThirdGroupSubList;
            if(originalGroupWiseSubListMapKeyList.size() > 0)
                if(originalGroupWiseSubListMapKeyList[0] != null)
                latestGroupSubList = originalGroupWiseSubListMap.get(originalGroupWiseSubListMapKeyList[0]);
            if(originalGroupWiseSubListMapKeyList.size() > 1)
                if(originalGroupWiseSubListMapKeyList[1] != null)
                latestSecondGroupSubList = originalGroupWiseSubListMap.get(originalGroupWiseSubListMapKeyList[1]);
            if(originalGroupWiseSubListMapKeyList.size() > 2)
                if(originalGroupWiseSubListMapKeyList[2] != null)
                latestThirdGroupSubList = originalGroupWiseSubListMap.get(originalGroupWiseSubListMapKeyList[2]);
            latestSecondGroupSubExcludeList = new List<Id>();
            
            List<Id> newSubIdList = new List<Id>();
            List<Id> previousSubIdList = new List<Id>();
            if(latestGroupSubList != null && latestGroupSubList.size() > 0 ) {
                for(SBQQ__Subscription__c objSub : latestGroupSubList) {
                    if(objSub.SBQQ__RevisedSubscription__c != null) {
                        previousSubIdList.add(objSub.SBQQ__RevisedSubscription__c);
                        latestSecondGroupSubExcludeList.add(objSub.SBQQ__RevisedSubscription__c);
                    }
                    else {
                        newSubIdList.add(objSub.Id);
                    }}
                if(latestSecondGroupSubList != null && latestSecondGroupSubList.size() > 0) {
                    
                    for(SBQQ__Subscription__c objSub : latestSecondGroupSubList) {
                        if(objSub.SBQQ__RevisedSubscription__c == null && objSub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && latestSecondGroupSubExcludeList.size() > 0 && !latestSecondGroupSubExcludeList.contains(objSub.Id)) {
                            previousSubIdList.add(objSub.Id);
                            newSubIdList.add(objSub.Id);
                        }
                        if(objSub.SBQQ__RevisedSubscription__c != null) {
                            latestSecondGroupSubExcludeList.add(objSub.SBQQ__RevisedSubscription__c);
                        }
                    }
                }
                
                if(latestThirdGroupSubList != null && latestThirdGroupSubList.size() > 0) {
                    for(SBQQ__Subscription__c objSub : latestThirdGroupSubList) {
                        if(objSub.SBQQ__RevisedSubscription__c == null && objSub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && latestSecondGroupSubExcludeList.size() > 0 && !latestSecondGroupSubExcludeList.contains(objSub.Id)) {
                            previousSubIdList.add(objSub.Id);
                            newSubIdList.add(objSub.Id);
                        }
                    }
                }
                list<Decimal> contractTerm=new list<Decimal>();
                for(SBQQ__Subscription__c objSub : allRelatedSubList) {
                    if(previousSubIdList.contains(objSub.Id)) {
                        allOriginalSubList.add(objSub);
                      //  originalCustomerPriceTemp += objSub.SBQQ__CustomerPrice__c;
                        originalAnnualPriceTemp += objSub.SBQQ__QuoteLine__r.Annual_Price__c;
                        
                    }
                    if(newSubIdList.contains(objSub.Id)) {
                        allAmendsubList.add(objSub);
                        amendAnnualPriceTemp += objSub.SBQQ__QuoteLine__r.Annual_Price__c;
                        contractTerm.add(objSub.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c);
                    }
                    
                }
                contractTermTemp = contractTerm[0];
                for(Integer i=0;i<contractTerm.size();i++)
                {
                    if(contractTerm[i] > contractTermTemp)
                        contractTermTemp=contractTerm[i];
                }
                
            }
            subWrapper objSubWrapper = new subWrapper(allOriginalSubList, allAmendsubList, originalCustomerPriceTemp, originalAnnualPriceTemp,ContractTermTemp, amendAnnualPriceTemp);
            return objSubWrapper;
        }
        return null;
    }
    
    public class subWrapper {
        public List<SBQQ__Subscription__c> originalList;
        public List<SBQQ__Subscription__c> amendedList;
        public Decimal originalCustomerPrice ;
        public Decimal originalAnnualPrice ;
        public Decimal ContractTerm;
        public Decimal amendAnnualPrice ;
        public Decimal amendDifference;
        public subWrapper (List<SBQQ__Subscription__c> originalListTemp, List<SBQQ__Subscription__c> amendedListTemp, Decimal originalCustomerPriceTemp, Decimal originalAnnualPriceTemp,Decimal ContractTermTemp, Decimal amendAnnualPriceTemp ) {
            originalList = originalListTemp;
            amendedList = amendedListTemp;
            originalCustomerPrice = originalCustomerPriceTemp;
            originalAnnualPrice = originalAnnualPriceTemp;
            ContractTerm=ContractTermTemp;
            amendAnnualPrice = amendAnnualPriceTemp;
            amendDifference = 0;
            if(amendAnnualPriceTemp >= originalAnnualPriceTemp)
                amendDifference = amendAnnualPriceTemp - originalAnnualPriceTemp;
            
        }
    }
}