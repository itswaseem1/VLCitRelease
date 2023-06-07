public class PartnerHelper {
    
    public static void updatePartnerAccount(List<Partner_Member_Relationship__c> pmrList) {
        Set<Id> accList = new Set<Id>();
        List<Account> accountUpdateList = new List<Account>();
        Decimal hrNum;
        Decimal hsNum; 
        
        for(Partner_Member_Relationship__c partnerM : pmrList) {
            if(partnerM.Partner__c!=null){
                accList.add(partnerM.Partner__c);
            }
        }
        if(!accList.isEmpty()){  
            for(Account objAccount : [Select Id, Assigned_HR_Member_Atlas_Access_Units__c, Assigned_H_S_Member_Atlas_Access_Units__c,(Select Id,HR_Access_Unit_Assigned__c,H_S_Access_Unit_Assigned__c from Partner_Member_Relationships__r Where HR_Access_Unit_Assigned__c!=NULL OR H_S_Access_Unit_Assigned__c!=NULL ) from Account where Id in: accList]) {
                hrNum = 0;
                hsNum = 0;            
                for(Partner_Member_Relationship__c objPm : objAccount.Partner_Member_Relationships__r) {               
                    if(objPm.HR_Access_Unit_Assigned__c == 'HR How-To Hub') {
                        hrNum ++; 
                    }
                    if(objPm.H_S_Access_Unit_Assigned__c == 'H&S How-To Hub') {                   
                        hsNum ++;  
                    }
                }
                if(objAccount.Assigned_HR_Member_Atlas_Access_Units__c != hrNum || objAccount.Assigned_H_S_Member_Atlas_Access_Units__c !=hsNum){
                    objAccount.Assigned_HR_Member_Atlas_Access_Units__c = hrNum;
                    objAccount.Assigned_H_S_Member_Atlas_Access_Units__c=hsNum;
                    accountUpdateList.add(objAccount);
                }            
            }
            
            if(!accountUpdateList.isEmpty()) {
                Database.update (accountUpdateList, false);
            }
        }
    }
}