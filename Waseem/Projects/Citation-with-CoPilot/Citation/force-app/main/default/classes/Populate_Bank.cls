global class Populate_Bank implements Database.Batchable<CSV_Bank_Recon__c>
{
	global List<CSV_Bank_Recon__c> start(Database.BatchableContext BC) 
    {
        //Getting the current company
        
       return [select id,name,Cash_Entry__c,Bank_Reconciliation__c from CSV_Bank_Recon__c where Processed__c=false];
    }

    global void execute(Database.BatchableContext BC, List<CSV_Bank_Recon__c> list_CSH)
    {
    	for(CSV_Bank_Recon__c csh : list_CSH)
    	{
    		c2g__codaBankReconciliationLineItem__c bank_line = new c2g__codaBankReconciliationLineItem__c();
    		c2g__codaTransactionLineItem__c tli = [select id,name,c2g__BankAccount__c,c2g__BankAccountValue__c from c2g__codaTransactionLineItem__c where c2g__Transaction__r.c2g__DocumentNumber__c=:csh.Cash_Entry__c and c2g__LineType__c='Analysis'];
    		bank_line.c2g__TransactionLineItem__c=tli.id;
    		bank_line.c2g__BankReconciliation__c=csh.Bank_Reconciliation__c;
    		bank_line.c2g__Value__c=tli.c2g__BankAccountValue__c;

    		insert bank_line;
    		csh.Processed__c=true;
    	}
    	update list_CSH;
    }

    global void finish(Database.BatchableContext BC) 
    {

    }
}