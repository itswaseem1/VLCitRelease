public with sharing class ContractActivateJob implements Queueable
{
    private ID contractId;

    public ContractActivateJob(Id contractId)
    {
        this.contractId = contractId;
    }

    public void execute(QueueableContext qtx)
    {
        String result = ActivateContractController.Activate(contractId);

        System.debug(' ** ContractActivateJob : ' + result );
    }
}