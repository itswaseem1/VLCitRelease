global class PaymentAgreementAccountUpdBatch  implements Database.Batchable<sobject> {
 
    private List<String> mailids;
    
    global Database.QueryLocator start(database.BatchableContext BC){
        String query = '';
        if(Test.isRunningTest()){
            query = 'select id, PAYREC2__Status__c, PAYREC2__Account__c from PAYREC2__Payment_Agreement__c LIMIT 200';
        } else{
            query = 'select id, PAYREC2__Status__c, PAYREC2__Account__c,PAYREC2__Account__r.Valid_Direct_Debit__c from PAYREC2__Payment_Agreement__c ';
        }
        return database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,list<PAYREC2__Payment_Agreement__c> scope){
      system.debug('scope.size()'+scope.size());
     
      map<id,PAYREC2__Payment_Agreement__c> newpagmap = new map<id,PAYREC2__Payment_Agreement__c>();
      for(PAYREC2__Payment_Agreement__c pag : scope){        
              newpagmap.put(pag.id,pag);
      }
      PaymentAgreementHandler.afterInsertQ(newpagmap);
    }
    
    global void finish(database.BatchableContext BC){
        
         AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        If(job.NumberOfErrors>0)
        {
            sendEmail('The PaymentAgreementAccountUpdBatch job processed ' + job.TotalJobItems +' batches with '+ job.NumberOfErrors + ' failures.');
        }
    }

     public void sendEmail(String body)
     {
                mailids = Label.PaymentAgreement_BatchEmails.split(',');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = mailids;
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batch Failure');
                mail.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
}