public class ContractTriggerHandler {
    
    public void updateiHascoRecordType(List<Contract> newList){
        System.debug('contract Ihasco'+newList);
        set<id> oppIds = new Set<id>();
        Integer accLengthAllowed;
        for(Contract contr:newList){
            oppIds.add(contr.SBQQ__Opportunity__c);
        }
        Map<id,opportunity> oppMap = new Map<id,opportunity>([Select id,Recordtype.DeveloperName,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.License_Model__c,Account.Name from Opportunity where id in:oppIds and Recordtype.Name='Default IHASCO']);
        Id iHascoRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(DataConstants.Contract_iHASCO_RECORDTYPENAME).getRecordTypeId();
        Id oppiHascoRecTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByDeveloperName().get(DataConstants.OPPORTUNITY_iHASCO_RECORDTYPENAME).getRecordTypeId();
        Id quoteiHascoRecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get(DataConstants.Quote_iHASCO_RECORDTYPENAME).getRecordTypeId();
        Id iHascoRenewalRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(DataConstants.Contract_iHASCO_RECORDTYPENAME).getRecordTypeId();
         Id iHASCOPBId = [Select id From  PriceBook2 where Name=:DataConstants.Quote_iHASCO_PRICEBOOKNAME].id;
        if(oppMap.values().size()>0){
            for(Contract contr:newList){
                if(oppMap.get(contr.SBQQ__Opportunity__c).Recordtype.DeveloperName==DataConstants.OPPORTUNITY_iHASCO_RECORDTYPENAME){
                    contr.RecordtypeId= iHascoRecTypeId;
                    contr.SBQQ__RenewalOpportunityRecordTypeId__c =oppiHascoRecTypeId;
                   contr.SBQQ__RenewalOpportunityStage__c ='Genuine interest' ;
                    contr.SBQQ__RenewalPricebookId__c =iHASCOPBId;
                    contr.SBQQ__Quote__c = oppMap.get(contr.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__c;
                    accLengthAllowed= 79-oppMap.get(contr.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.License_Model__c.length();                   
                    if(oppMap.get(contr.SBQQ__Opportunity__c).Account.Name.length()>accLengthAllowed)
                    contr.Name = oppMap.get(contr.SBQQ__Opportunity__c).Account.Name.subString(0,accLengthAllowed)+'-'+oppMap.get(contr.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.License_Model__c ; 
                    else
                    contr.Name = oppMap.get(contr.SBQQ__Opportunity__c).Account.Name +'-'+oppMap.get(contr.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.License_Model__c ;                         
                }
            }
        }
        
    }
    public void validateContractActivation(Map <id,Contract> newMap, Map <id,Contract> oldMap){
        List<id> signedContracts = new List<id>  ();
        Boolean hasPermission = checkIfUserHasAssignedPermissionSet(userinfo.getUserId(),'iHASCO_Contract_Activate_Special_Access');
        system.debug('hasPermission'+hasPermission);
        for(echosign_dev1__SIGN_Agreement__c Agree:
            [SELECT id,echosign_dev1__Contract__c,echosign_dev1__DateSigned__c FROM echosign_dev1__SIGN_Agreement__c 
             WHERE echosign_dev1__Contract__c in:Trigger.newMap.keySet() AND  echosign_dev1__Contract__r.Recordtype.Name=:DataConstants.Contract_iHASCO_RECORDTYPENAME
             ]){
                 if(Agree.echosign_dev1__DateSigned__c !=NULL)      
                 signedContracts.add(Agree.echosign_dev1__Contract__c);
             }
        for(Contract contr:newMap.Values()){
            if(((! signedContracts.Contains(contr.id)) && (!hasPermission)) && contr.Status != oldMap.get(contr.id).status &&
              contr.Status==Dataconstants.CONTRACT_STATUS_ACTIVE && contr.Annual_Contract_Value__c >=Dataconstants.CONTRACT_SINGREQ_ACV_Value){
                contr.addError(Label.iHASCO_ACV_10K_Error);

            }
        }
    }
    public void calliHascoContractSendEmail(List<Contract> newContracts, Map<id,Contract> oldContractMap){
        set<id> contractIds =new set<id>();
        set<id> amendedContractIds =new set<id>();
        Id iHASCOContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(DataConstants.Contract_iHASCO_RECORDTYPENAME).getRecordTypeId();
        for(Contract con: newContracts){
            if(con.RecordTypeId == iHASCOContractRecordTypeId){
                if( (con.Status == 'Active') && (oldContractMap.get(con.id).Status == 'In Amendment')){
                    amendedContractIds.add(con.id);
                }
                else if( (con.Status == 'Active') && (oldContractMap.get(con.id).Status != 'Active')){
                    contractIds.add(con.id);
                }
            }
        }
        if(contractIds.size()>0 && contractIds !=NULL)        
            ihascoContractHandler.SendAccountsTeamEmail(contractIds);
        if(amendedContractIds.size()>0 && amendedContractIds !=NULL)        
            ihascoContractHandler.getAmendContractToBuildEmailBody(amendedContractIds, true);
    }
    Private static Boolean checkIfUserHasAssignedPermissionSet(String userId, String permissionSetName) {
        List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = :permissionSetName) and AssigneeId =: userId ];
        return psas.size() > 0;
    }
}