public class iHASCOAccountServices {
    public static void updatePurgatoryStatus(Map<Id, Account> newObjectsMap,Map<Id, Account> oldObjectsMap)
        
    {
        List<Account> accounts = new List <Account>();
        for(Account act: newObjectsMap.values())
        {
            
            if(act.iHASCO_Client__c && act.iHASCO_Finance_Status__c == DataConstants.ACCOUNT_STATUS_INACTIVE 
               && act.Purgatory_Status__c != DataConstants.ACCOUNT_PSTATUS_PURGATORYAM && act.Purgatory_Status__c == NULL
			&& (act.iHASCO_Status_Reason__c ==DataConstants.ACCOUNT_STATUS_RESAON_NONRENEWAL || act.iHASCO_Status_Reason__c ==DataConstants.ACCOUNT_STATUS_RESAON_ONCLIENTREQUEST))
                
            {
                act.Purgatory_Status__c = DataConstants.ACCOUNT_PSTATUS_PURGATORYAM ;
            }
            
            if(act.iHASCO_Client__c && act.iHASCO_Status_Reason__c != DataConstants.ACCOUNT_STATUS_RESAON_ACCOUNT_OVERDUE 
               && act.Contract_End_Date__c>= system.today())
            {
                act.iHASCO_Finance_Status__c = DataConstants.ACCOUNT_STATUS_ACTIVE;
                act.iHASCO_Status_Reason__c = NULL;
                act.Purgatory_Status__c = NULL;
            }
        }
    }

    public static void updatePurgatoryStatusInactive(List<id> accIdList){
        List<Account> accListUpdated = new List<Account>();
        Date Today= system.today();
        for(Account act: [SELECT ID from Account WHERE ID in : accIdList AND iHASCO_Client__c = True AND Contract_End_Date__c != NULL
                          AND Contract_End_Date__c < Today AND iHASCO_Finance_Status__c =:DataConstants.ACCOUNT_STATUS_ACTIVE])
        {
            act.iHASCO_Finance_Status__c=DataConstants.ACCOUNT_STATUS_INACTIVE;
            act.iHASCO_Status_Reason__c=DataConstants.ACCOUNT_STATUS_RESAON_NONRENEWAL;
            accListUpdated.add(act);
        }
        
        if(accListUpdated != null && accListUpdated.size()>0) {
            DataBase.update(accListUpdated);  
        }
    }
}