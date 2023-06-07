public class QMSCreateContracthelper {
    
    public Static contract createContract(opportunity oppty){
        Id contractQMSRecordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(DataConstants.CONTRACT_QMS_RECORDTYPE_NAME).getRecordTypeId();
        Contract cont=new Contract();      
        cont.Name='QMS - '+oppty.Account.Name;
        cont.AccountId=oppty.AccountId;
        cont.Source_Opportunity__c=oppty.Id;
        cont.SBQQ__Opportunity__c=oppty.Id;
        cont.CompanySignedId=oppty.OwnerId;
        cont.CompanySignedDate=oppty.Deal_Start_Date__c;
        Cont.StartDate=oppty.Deal_Start_Date__c;
        cont.RecordTypeId = contractQMSRecordtypeId;
       // if(oppty.Contact__c != null)
        //cont.CustomerSignedId=oppty.Contact__c;
        cont.CustomerSignedDate=oppty.Deal_Start_Date__c;
        //cont.CustomerSignedTitle=oppty.Contact__c.position;
        cont.Pricebook2Id=oppty.Pricebook2Id ;
        Cont.Status='Draft';
        cont.Renewal_Type__c = 'Auto';
        cont.Agreement_Type__c='Auto';                            
        //cont.Agreement_Template_Type__c='Add-On';
        cont.Business_Type__c='Existing Business';                  
        cont.FOC_Period_Mths__c=0;
        cont.FOC_Period_Mths_End__c=0;
        cont.CurrencyIsoCode=oppty.CurrencyIsoCode;                   
        //cont.Contract_Value__c=item.TotalPrice;
        cont.Total_Contract_Value__c=oppty.Total_Deal_Amount__c;
        cont.Payment_Period__c=oppty.Payment_Period__c;
        //cont.Initial_Payment2__c=(item.Quantity*item.UnitPrice)/cont.ContractTerm;                                    
        cont.OwnerId=oppty.OwnerId;
        cont.ContractTerm =(Integer)oppty.Contract_Length_Months__c;
        
        return cont;
    }
}