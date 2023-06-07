public without sharing class qmsContractProcess {

    public static Id nbsOpportunityQMS = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS').getRecordTypeId();
    public static Id renewalOpportunityQMS = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QMS Renewal').getRecordTypeId();
    public static Id qmsContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('QMS').getRecordTypeId();
   
    public static void updateContractrecordTypeQMS(List<Contract> contr){
        
        Set<id> oppIdSet =  new Set<id>();
        set<id> qmsoppRecTypes = new Set<id>();
        qmsoppRecTypes.add(nbsOpportunityQMS);
        qmsoppRecTypes.add(renewalOpportunityQMS);
        For(Contract c: contr){
            oppIdSet.add(c.SBQQ__Opportunity__c);          
        } 
        Map<id,Opportunity> oppRecTypeMap = new Map<id,Opportunity>([SELECT Id, Recordtypeid from opportunity where Recordtypeid IN :qmsoppRecTypes AND Id IN :oppIdSet]);
        for(Contract c: contr){
            if(oppRecTypeMap.containskey(c.SBQQ__Opportunity__c)){
                c.RecordTypeid = qmsContractRecordTypeId;		
            }
        }
    }
}