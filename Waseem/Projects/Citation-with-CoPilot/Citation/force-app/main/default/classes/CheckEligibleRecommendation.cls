/**
* @File Name          : CheckEligibleRecommendation.apxt
* @Description        : get recommandation baseed on Role and Product
* @Author             : Sarita Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 10/8/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     06/08/2021      Initial Version						SS-878/SS-847
**/
public with sharing class CheckEligibleRecommendation {

 public static final Set<String> REFERAL_LIST = new Set<String>{'H&S Workplace Expert','HR Workplace Expert','HR Virtual Assistance','H&S Virtual Assistance','H&S Compliance Service','EL and HR Compliance Service'};
 public static final Set<String> HS_LIST = new Set<String>{'H&S Workplace Expert','H&S Virtual Assistance','H&S Compliance Service'};
 public static final Set<String> HR_LIST = new Set<String>{'HR Workplace Expert','EL and HR Compliance Service'};

    public static List<String> checkEligibleRecomm(List<String> filterString,string userRoleName ,List<String> productString,Boolean isActiveContract){

        List<Id> roleMatchingRecList=new List<Id>();
        Set<Id> recProductIds=new Set<Id>();
        List<Id> finalRecProductIds=new List<Id>();
        List<Id> finalRecIds=new List<Id>();
        
        List<Recommendation> reclist =[SELECT AcceptanceLabel,ActionReference,Category__c,Description,Id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where (NOT Name like :filterString) AND Category__c != 'Lead Generation' WITH SECURITY_ENFORCED ORDER BY Priority__c ];
        /*verify Current UserRole*/
        finalRecProductIds= checkEligibleRole(userRoleName,reclist);
        finalRecIds=checkActiveContractRec(finalRecProductIds,isActiveContract);
       
        /*get Lead Generation Recommndation*/
        recProductIds= checkProductRecommandation(filterString,productString);
        
        roleMatchingRecList.addAll(finalRecIds);
        roleMatchingRecList.addAll(recProductIds);
        
        return roleMatchingRecList;
    }
    public static List<Id> checkActiveContractRec(List<Id> finalRecProductIds,Boolean isActiveContract){
        Map<String,Id> reMap= new Map<String,Id>();
        List<Id> roleMatchingRecList=new List<Id>();
        List<Recommendation> reclist= [SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where id IN:finalRecProductIds  AND Category__c != 'Lead Generation' WITH SECURITY_ENFORCED ORDER BY Priority__c];
        for(Recommendation rec : reclist)
        {reMap.put(rec.Name, rec.Id);}
        if(isActiveContract){
            for(Recommendation rec : reclist) { roleMatchingRecList.add(rec.Id);}}
        else{roleMatchingRecList.add(reMap.get('Verify the clients contact details'));}

        return roleMatchingRecList;
    }
    
    public static List<Id> checkEligibleRole(string userRoleName,List<Recommendation> reclist){
        Map<String,Id> reMap= new Map<String,Id>();
        List<Id> roleMatchingRecList=new List<Id>();
        for(Recommendation rec : reclist)
        {reMap.put(rec.Name, rec.Id);}

        roleMatchingRecList.add(reMap.get('Submit an ISO referral'));
        roleMatchingRecList.add(reMap.get('Verify the clients contact details'));
        
        Recommandation_Role_Category__mdt[]  roleRecord = [select id ,label,H_S__c,FRA__c,HR__c,ATLAS__c,EAP__c from Recommandation_Role_Category__mdt where label=:userRoleName WITH SECURITY_ENFORCED LIMIT 1];

        if(roleRecord.size() > 0 ){
        if(roleRecord[0].H_S__c){roleMatchingRecList.add(reMap.get('Submit an On-Site H&S referral')); }
        if(roleRecord[0].FRA__c){roleMatchingRecList.add(reMap.get('Submit an FRA referral'));}
        if(roleRecord[0].HR__c){roleMatchingRecList.add(reMap.get('Submit an On-Site HR referral'));}
        if(roleRecord[0].ATLAS__c){roleMatchingRecList.add(reMap.get('Submit an Atlas certified elearning'));}
        if(roleRecord[0].EAP__c){roleMatchingRecList.add(reMap.get('Submit an EAP referral'));}
        }
       
        return roleMatchingRecList;
    }
    public static Set<Id> checkProductRecommandation(List<String> filterString,List<String> productString){
        Set<Id> recIds = new Set<Id>();
        Map<String,Id> reMap= new Map<String,Id>();
        
        List<Recommendation> reclist =[SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where (NOT Name like :filterString) AND Category__c != 'Upsell'  WITH SECURITY_ENFORCED ORDER BY Priority__c ];
        for(Recommendation rec : reclist){reMap.put(rec.Name, rec.Id);}
        recIds.add(reMap.get('Ask for an online client review'));

        for(string s :productString){
            if(REFERAL_LIST.contains(s)){recIds.add(reMap.get('Ask client for a referal'));}
            if(HS_LIST.contains(s)){recIds.add(reMap.get('Upgrade to combined_H&R'));}
            if(HR_LIST.contains(s)){recIds.add(reMap.get('Upgrade to combined_H&S'));}
            if(s =='HR Virtual Assistance'){recIds.add(reMap.get('Upgrade to HR Workplace Expert'));}
            if(s =='H&S Virtual Assistance'){recIds.add(reMap.get('Upgrade to H&S Workplace Expert'));}
            }

        return recIds;
    }
}