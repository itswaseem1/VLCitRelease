public with sharing class BillingDocumentServiceSelector implements BillingDocumentService.ISelector
{
    public BillingDocumentServiceSelector() {

    }

    public Map<Id, ffbc__Contract__c> loadRelatedContracts(List<fferpcore__BillingDocument__c> documents)
    {
        Set<Id> contractIds = new Set<ID>();
        for(fferpcore__BillingDocument__c document: documents)
        {
            contractIds.add(document.ffbc__Contract__c);
        }

        List<ffbc__Contract__c> objs = [SELECT CustomerReference__c FROM ffbc__Contract__c WHERE ID IN :contractIds];
        Map<ID, ffbc__Contract__c> contMap = new Map<ID, ffbc__Contract__c>(objs);

        Map<ID, ffbc__Contract__c> returnMap = new Map<ID, ffbc__Contract__c>();

        for(fferpcore__BillingDocument__c document: documents)
        {
            returnMap.put(document.Id, contMap.get(document.ffbc__Contract__c));
        }

        return returnMap;
    }
}