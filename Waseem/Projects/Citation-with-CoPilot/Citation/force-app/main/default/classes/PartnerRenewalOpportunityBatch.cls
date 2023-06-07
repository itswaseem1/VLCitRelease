public class PartnerRenewalOpportunityBatch implements Database.Batchable<SObject>, Schedulable{  
    
    private Date priorDate =Date.today().addDays(Integer.valueOf(System.Label.Partner_Contract_Expiry_Term)); 
    Id prRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partnership Renewal').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,AccountID,Account.Name,Account.OwnerId,ContractNumber,name,ContractTerm,EndDate,RecordTypeID,StartDate,Status,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Accountid,SBQQ__Quote__r.SBQQ__Opportunity2__r.name,SBQQ__Quote__r.SBQQ__Opportunity2__r.LeadSource,SBQQ__Quote__r.SBQQ__Opportunity2__r.Description,SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount,SBQQ__Quote__r.SBQQ__Opportunity2__r.Pricebook2Id From Contract Where RecordType.Name = \'Citation Partnership\' AND  EndDate =: priorDate';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Contract> scope) {
        System.debug('PartnerRenewalOpportunityBatch');        
        List<opportunity> oppList = new List<opportunity>();        
        Set<Id> oppSetId=new Set<Id>();
        List<OpportunityContactRole> oppContactList = new List<OpportunityContactRole>();
        Map<Id,OpportunityContactRole> mapOppToCont = new Map<Id,OpportunityContactRole>(); 
        Map<Id,Id> mapOpp = new Map<Id,Id>(); 
        Opportunity opp;
        
        try {            
            for(Contract contrct: scope){
                if(contrct.SBQQ__Quote__c != null && contrct.SBQQ__Quote__r.SBQQ__Opportunity2__c != null){
                    opp = new opportunity();
                    opp.RecordTypeid = prRecordTypeId;
                    opp.Accountid = contrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.Accountid;
                    opp.name =contrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.name;
                    opp.CloseDate = contrct.EndDate;
                    opp.Deal_Start_Date__c=contrct.EndDate.addDays(1);
                    opp.LeadSource = contrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.LeadSource;
                    opp.Description = contrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.Description;
                    opp.Amount = contrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount;
                    opp.Pricebook2Id = contrct.SBQQ__Quote__r.SBQQ__Opportunity2__r.Pricebook2Id;
                    opp.Type = 'Partner'; 
                    opp.StageName = 'Renewal Contact Due';
                    opp.Original_Contract__c = contrct.Id;
                    opp.OwnerId=contrct.Account.OwnerId;
                    oppList.add(opp);                       
                    
                    mapOpp.put(contrct.Id,contrct.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                    oppSetId.add(contrct.SBQQ__Quote__r.SBQQ__Opportunity2__c);                       
                    
                }
            }
            
            if(!oppList.isEmpty()){                    
                Database.insert(oppList,false);
            }
            
            if(!oppSetId.isEmpty()){
                for(OpportunityContactRole oppCon:[SELECT Id, OpportunityId, ContactId, Role, IsPrimary FROM OpportunityContactRole 
                                                   Where IsPrimary = true AND OpportunityId =: oppSetId]){                                                       
                                                       mapOppToCont.put(oppCon.OpportunityId,oppCon);
                                                   }
                
                for(opportunity oppt:oppList){
                    if(mapOpp.containsKey(oppt.Original_Contract__c) && mapOppToCont.containsKey(mapOpp.get(oppt.Original_Contract__c))){
                        OpportunityContactRole newOppcr = new OpportunityContactRole();
                        newOppcr.OpportunityId = oppt.id;
                        newOppcr.ContactId = mapOppToCont.get(mapOpp.get(oppt.Original_Contract__c)).ContactId;
                        newOppcr.Role = mapOppToCont.get(mapOpp.get(oppt.Original_Contract__c)).Role;
                        newOppcr.IsPrimary = mapOppToCont.get(mapOpp.get(oppt.Original_Contract__c)).IsPrimary;
                        oppContactList.add(newOppcr);
                    }
                    
                } 
                
                if(!oppContactList.isEmpty()){
                    insert oppContactList;
                }
            }
            
        }catch(Exception e){
            System.debug('ErrorMessage:'+e.getMessage());
        }
        
    }
    public void finish(Database.BatchableContext BC){  
        System.debug(' Finish method ');
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PartnerRenewalOpportunityBatch(),Integer.valueOf(System.Label.PartnerMemberUploadBatchSize));
    }
}