public with sharing class QmsContractHandler {
    
    public QmsContractHandler() {
        
    }
    
    @InvocableMethod
    public static void QmsContractCheck(list<id> oppid){   
        System.debug('QmsContractCheck method');
        set<id> opId = new set<id>();
        Set<Id> contractIds=new Set<Id>();
        List<Contract> qmsContractList=new List<Contract>();
        Map<String, List<OpportunityLineItem>> opportunityLineItemsMap = new Map<String, List<OpportunityLineItem>>();
        List<SBQQ__Subscription__c> subscriptionLines=new List<SBQQ__Subscription__c>();
        Map<String,Id> contractTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Contract.SObjectType);
        Id QMSRecordTypeId = contractTypes.get('QMS');
        for(id id1:oppid){
            opId.add(id1);
        }  
        List<Opportunity>  oppList=[SELECT Id, Name,AccountId,Account.Name,Term__c,Contact__c,Amount,OwnerId,(SELECT Id, Quantity,UnitPrice,TotalPrice,productCode,Product2Id,Product2.Name,Product2.Online_System__c,Product2.Online_System_Feature_Enabling__c FROM OpportunityLineItems) FROM Opportunity WHERE Id =: opId];
        
        for (Opportunity oppty :oppList)
        {
            opportunityLineItemsMap.put(oppty.Id, oppty.OpportunityLineItems);
            System.debug('opportunity' + oppty);           
            for(OpportunityLineItem item:oppty.OpportunityLineItems){                
                if(item.Product2.Online_System__c=='Atlas' && item.Product2.Online_System_Feature_Enabling__c == true){               
                    Contract cont=new Contract();      
                    cont.Name='QMS - '+oppty.Account.Name;
                    cont.AccountId=oppty.AccountId;
                    cont.Source_Opportunity__c=oppty.Id; 
                    cont.SBQQ__Opportunity__c=oppty.Id;
                    cont.CompanySignedId=oppty.OwnerId;
                    cont.CompanySignedDate=System.today();
                    Cont.StartDate=System.today();
                    cont.RecordTypeId=QMSRecordTypeId;
                    if(oppty.Term__c !=null){
                        cont.ContractTerm=Integer.ValueOf(oppty.Term__c)*12;
                    }else{
                        cont.ContractTerm=12;
                    }
                    cont.CustomerSignedId=oppty.Contact__c;
                    cont.CustomerSignedDate=System.today();
                    //cont.CustomerSignedTitle=oppty.Contact__c.position;
                    cont.Pricebook2Id='01sD0000000tHqv';
                    Cont.Status='Draft';
                    cont.Agreement_Type__c='EchoSign';                            
                    cont.Agreement_Template_Type__c='Add-On';
                    cont.Business_Type__c='Existing Business';                  
                    cont.FOC_Period_Mths__c=0;
                    cont.FOC_Period_Mths_End__c=0;
                    cont.CurrencyIsoCode='GBP';                   
                    cont.Contract_Value__c=item.TotalPrice;
                    cont.Total_Contract_Value__c=item.TotalPrice;
                    cont.Payment_Period__c='Monthly';
                    cont.Initial_Payment2__c=(item.Quantity*item.UnitPrice)/cont.ContractTerm;                                    
                    cont.OwnerId=oppty.OwnerId;                   
                    qmsContractList.add(cont);
                    
                }
            }
        }
        if(!qmsContractList.isEmpty()) {
            insert qmsContractList;
        }
        
        if(qmsContractList.size()>0){  
            for (Contract cont :qmsContractList)
            {
                System.debug('opportunity' + opportunityLineItemsMap.get(cont.Source_Opportunity__c));           
                for(OpportunityLineItem item:opportunityLineItemsMap.get(cont.Source_Opportunity__c)){
                    if(item.Product2.Online_System__c=='Atlas' && item.Product2.Online_System_Feature_Enabling__c == true){
                        SBQQ__Subscription__c subLine=new SBQQ__Subscription__c();
                        subLine.SBQQ__Contract__c=cont.Id;
                        subLine.SBQQ__BillingFrequency__c='Monthly';
                        subLine.SBQQ__BillingType__c='Arrears';
                        subLine.SBQQ__Bundle__c=false;
                        subLine.SBQQ__CustomerPrice__c=cont.Contract_Value__c;
                        subLine.SBQQ__NetPrice__c=cont.Contract_Value__c;
                        subLine.SBQQ__RegularPrice__c=cont.Contract_Value__c;
                        subLine.SBQQ__PricingMethod__c='Custom';
                        subLine.SBQQ__Product__c=item.Product2Id;
                        subLine.SBQQ__SpecialPrice__c=item.UnitPrice;
                        subLine.SBQQ__SubscriptionEndDate__c=system.today().addMonths(cont.ContractTerm);
                        subLine.SBQQ__SubscriptionStartDate__c=system.today();
                        subLine.SBQQ__Quantity__c=item.Quantity;
                        subLine.Initial_Payment_m__c=cont.Initial_Payment2__c;
                        subLine.Regular_Payment_m__c=cont.Initial_Payment2__c;
                        subLine.Service_Start_Date_m__c=cont.StartDate;
                        subLine.Service_End_Date_m__c=system.today().addMonths(cont.ContractTerm);
                        subLine.Subscription_Term_m__c=cont.ContractTerm;
                        subLine.Term_Type_m__c=cont.ContractTerm+' month';
                        subLine.FOC_Months_m__c=0;
                        subLine.FOC_Period_m__c='';
                        subLine.SBQQ__Account__c=cont.AccountId; 
                        subLine.OwnerId =cont.OwnerId;
                        subscriptionLines.add(subLine);
                    }
                }
                contractIds.add(cont.id);
            }
        }
        
        if(!subscriptionLines.isEmpty()){
            insert subscriptionLines;
        }     
        
        if(!contractIds.isEmpty()){
            sendDeactivation(contractIds);
        }
        
        /*
List<Contract> contractsToActivate=new List<Contract>();
// end of subscrption lines creation logic.

for(Contract c:[SELECT Id,status , (select Id,Name from SBQQ__Subscriptions__r) from Contract WHERE Id IN :contractIds]){
if(c.SBQQ__Subscriptions__r.size()>0){
c.status='Active';
contractsToActivate.add(c);
}
}
if(!contractsToActivate.isEmpty()){
update contractsToActivate;
}*/
        
        
    }
    
    @future (callout=true)
    public static void sendDeactivation(set<Id> contractIds){
        List<Contract> contractsToActivate=new List<Contract>();
        // end of subscrption lines creation logic.
        
        for(Contract c:[SELECT Id,status , (select Id,Name from SBQQ__Subscriptions__r) from Contract WHERE Id IN :contractIds]){
            if(c.SBQQ__Subscriptions__r.size()>0){
                c.status='Active';
                contractsToActivate.add(c);
            }
        }
        if(!contractsToActivate.isEmpty()){
            update contractsToActivate;
        } 
        
    }
    
}