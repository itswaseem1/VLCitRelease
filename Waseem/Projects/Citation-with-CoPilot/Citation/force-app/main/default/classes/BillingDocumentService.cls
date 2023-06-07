public inherited sharing class BillingDocumentService extends DefaultService
{
    /*
    *   This implementation of the service will require a selector to handle loading
    *   records that it will need to perform its job.
    */
    public interface ISelector
    {
        /*
        *   Load the contracts related to the documents, and return mapped by the contract Id
        */
        Map<Id, ffbc__Contract__c> loadRelatedContracts(List<fferpcore__BillingDocument__c> documents);
    }

    /*
    *   Our selector that we were provided by what ever created us.
    */
    private ISelector selector;

    public BillingDocumentService(ISelector selector) 
    {
        this.selector = selector;
    }

    /*
    *   Implementation of service interface
    */
    public override void setDefaults(List<SObject> objects)
    {
        List<fferpcore__BillingDocument__c> documents = (List<fferpcore__BillingDocument__c>)objects;
        defaultCustomerReference(documents);
    }

    public override List<ValidationError> validate(List<SObject> objects)
    {
        // put this redundant line here, as Copado haveing major issues 
        // with a conflict resolution, this to force it to rethink.
        return super.validate(objects);
    }

    /*
    *   Copies over customer reference from billing contract if we don't have one.
    */
    private void defaultCustomerReference(List<fferpcore__BillingDocument__c> documents)
    {
        Map<Id, ffbc__Contract__c> contracts = selector.loadRelatedContracts(documents);

        for(fferpcore__BillingDocument__c document: documents)
        {
            if(document.fferpcore__CustomerReference__c != null)
                continue;

            ffbc__Contract__c contract = contracts.get(document.ffbc__Contract__c);

            if(contract == null)
                continue;

            document.fferpcore__CustomerReference__c = contract.CustomerReference__c;
        }
    }

    public inherited sharing class BillingDocumentServiceSelector implements BillingDocumentService.ISelector
    {
        public Map<Id, ffbc__Contract__c> loadRelatedContracts(List<fferpcore__BillingDocument__c> documents)
        {
            Set<Id> contractIds = new Set<ID>();
            for(fferpcore__BillingDocument__c document: documents)
            {
                contractIds.add(document.ffbc__Contract__c);
            }

            List<ffbc__Contract__c> objs = [SELECT CustomerReference__c FROM ffbc__Contract__c WHERE ID IN :contractIds];
            return new Map<ID, ffbc__Contract__c>(objs);
        }
    }
}