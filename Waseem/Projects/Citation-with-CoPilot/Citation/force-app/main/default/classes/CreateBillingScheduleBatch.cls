/*
    * FinancialForce.com, inc. claims copyright in this software, its screen display designs and
    * supporting documentation. FinancialForce and FinancialForce.com are trademarks of FinancialForce.com, inc.
    * Any unauthorized use, copying or sale of the above may constitute an infringement of copyright and may
    * result in criminal or other legal proceedings.
    *
    * Copyright FinancialForce.com, inc. All rights reserved.
    * Uves Ravat
*/

public class CreateBillingScheduleBatch implements Database.Batchable<sObject>, Database.Stateful
{
    private List<String> errorMessages;
    private List<String> successMessages;
    private List<id> contractIds;

    // Constructor 
    public CreateBillingScheduleBatch(List<id> contractIds)
    {
        initialise(contractIds);
    }

    private void initialise(List<id> contractIds)
    {
        this.contractIds = contractIds;
        this.errorMessages = Test.isRunningTest() ? new List<String>{'Test Mode'} : new List<String>();
        this.successMessages = Test.isRunningTest() ? new List<String>{'Test Mode'} : new List<String>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query =
            'SELECT '+ 
            '   id, '+ 
            '   name, '+ 
            '   ffbc__Status__c, '+ 
            '   ffbc__StartDate__c, '+ 
            '   ffbc__EndDate__c '+ 
            'FROM '+ 
            '   ffbc__Contract__c '+ 
            'WHERE '+ 
            '   Id IN :contractIds ';

        return Database.getQueryLocator( query );
    }

    public void execute(Database.BatchableContext BC, List<sObject> unTypedScope)
    {
        System.Savepoint sp = Database.setSavepoint();
        // Map into a map
        Map<Id,ffbc__Contract__c> contracts = new Map<Id,ffbc__Contract__c>( (List<ffbc__Contract__c>) unTypedScope);
        try
        {
            // Contract Names
            Set<String> contractNames = new Set<String>();

            // Call Billing Schedules Service
            ffbc.BillingSchedulesService.GenerateRequest billingScheduleRequest = new ffbc.BillingSchedulesService.GenerateRequest();
            billingScheduleRequest.GenerationStartDate = system.today();
            billingScheduleRequest.GenerationEndDate = system.today();
            
            for(ffbc__Contract__c cont :contracts.values())
            {
                contractNames.add(cont.name);

                billingScheduleRequest.GenerationStartDate =  billingScheduleRequest.GenerationStartDate > cont.ffbc__StartDate__c ? cont.ffbc__StartDate__c : billingScheduleRequest.GenerationStartDate;
                billingScheduleRequest.GenerationEndDate = billingScheduleRequest.GenerationEndDate > cont.ffbc__EndDate__c ? billingScheduleRequest.GenerationEndDate : cont.ffbc__EndDate__c;
            }

            // Delete Unbilled Billing Schedules
            delete [SELECT id FROM ffbc__BillingSchedule__c WHERE ffbc__BillingDocumentLineItem__c = null AND ffbc__ContractGrouping__c IN :contractNames];

            // Call Service
            billingScheduleRequest.ContractIds = contracts.keyset();
            ffbc.BillingSchedulesService.GenerateResponse reply = ffbc.BillingSchedulesService.generate(billingScheduleRequest);
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            errorMessages.add( 'Error when Recalculating Billing Schedules: ' + unTypedScope + '; Exception: ' + e.getMessage() + '\n\n');
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        AsyncApexJob batchJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        String bodyMessage = 'Recalculate Billing Schedules Process:\n\n';
        String subjectMessage = 'Recalculate Billing Schedules Process (CreateBillingScheduleBatch)';
        sendEmail( batchJob.CreatedBy.Email, bodyMessage, subjectMessage );
    }

    public void sendEmail( String address, String bodyMessage, String subjectMessage)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses( new String[] { address } );

        String body = bodyMessage + '\n\n';

        if( errorMessages.size() > 0 )
        {
            body += 'Errors occurred.\n';
            for( String error : errorMessages )
            {
                body += error +'\n';
            }
            body += '\n';
        }
        else
        {
            body += 'No errors occurred.\n';
            body += '\n';
        }
        for( String success : successMessages )
        {
            body += success +'\n';
        }

        mail.setPlainTextBody( body );
        mail.setSubject( subjectMessage );

        //if(!Test.isRunningTest()) Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
    }
}