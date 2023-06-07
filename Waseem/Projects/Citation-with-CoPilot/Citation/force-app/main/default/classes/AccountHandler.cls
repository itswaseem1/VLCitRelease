/**
 * @File Name          : AccountHandler.cls
 * @Description        :
 * @Author             : Mukul -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 21/04/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     4/6/2021      Initial Version
 **/
public with sharing class AccountHandler {
   
    public static List<Account> accountOnHoldList = new List<Account>();
    public static List<Account> accountOffHoldList = new List<Account>();
    public static void accountProcessor(Map<Id,Account> oldAccs,Map<Id,Account>newAccs)
    {
        Set<Id> accIds = newAccs.keySet();
        for(Id accid : accIds)
        {
            if(oldAccs.get(accid).HasContractOnHold__c!=newAccs.get(accid).HasContractOnHold__c && newAccs.get(accid).HasContractOnHold__c>0)
            {
                accountOnHoldList.add(newAccs.get(accid));
            }
        
            if(oldAccs.get(accid).HasContractOnHold__c!=newAccs.get(accid).HasContractOnHold__c && newAccs.get(accid).HasContractOnHold__c==0)
            {
                accountOffHoldList.add(newAccs.get(accid));
            }

        }

        if(accountOnHoldList.size()>0)
        {
            AccountOnHoldHelper helper = new AccountOnHoldHelper();
            helper.getServiceDeliveryPlanForOnHold(accountOnHoldList);
        }
        if(accountOffHoldList.size()>0)
        {
            AccountOffHoldHelper helper = new AccountOffHoldHelper();
            helper.getServiceDeliveryPlanForOffHold(accountOffHoldList);
        }
    }
}