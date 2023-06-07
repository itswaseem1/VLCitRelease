public class SubscriptionHelper {
    public static void updatePartnerContract(List<SBQQ__Subscription__c> subList) {       
        Set<Id> contractIdSet = new Set<Id>() ;
        List<Contract> contList = new list<contract>() ;
        Decimal hrNum;
        Decimal hsNum; 
        
        for(SBQQ__Subscription__c subs : subList) {
            if(subs.SBQQ__Contract__c != null) {
                contractIdSet.add(subs.SBQQ__Contract__c)  ;
            }            
        }
        if(!contractIdSet.isEmpty()){
            for(Contract cont:[Select Id, HR_Member_Atlas_Access_Units__c,H_S_Member_Atlas_Access_Units__c,(Select Id,SBQQ__Quantity__c,sbqq__Product__c,sbqq__Product__r.ProductCode FROM SBQQ__Subscriptions__r) From Contract where Id in :contractIdSet]){ 
                hrNum=0;
                hsNum=0;
                for(SBQQ__Subscription__c subs:cont.SBQQ__Subscriptions__r){ 
                    if(subs.sbqq__Product__r.ProductCode =='HR-HtoH'){
                        hrNum += subs.SBQQ__Quantity__c;
                    }
                    if(subs.sbqq__Product__r.ProductCode =='H&S-HtoH'){
                        hsNum +=subs.SBQQ__Quantity__c;
                    }  
                }
                if(cont.HR_Member_Atlas_Access_Units__c !=hrNum || cont.H_S_Member_Atlas_Access_Units__c !=hsNum){
                    cont.HR_Member_Atlas_Access_Units__c =hrNum;
                    cont.H_S_Member_Atlas_Access_Units__c=hsNum;
                    contList.add(cont);
                }      
            }       
            if(!contList.isEmpty()) {
                Database.update(contList, false);
            } 
        }
    }        
}