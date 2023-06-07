global class CertificationDisplayBatch implements Database.Batchable<SObject> {

    global final String Query;
    List<Database.SaveResult> srList                    = new List<Database.SaveResult>();
    
    global CertificationDisplayBatch(string queryString){
 
       Query=queryString;
    }

    global CertificationDisplayBatch(){
        
        query = 'select id,Certification__c,Certificate_Display_New__c from opportunity where StageName NOT IN: acst and Certificate_Display_New__c = null and Certification__c != null';
     }
 
    global Database.QueryLocator start(Database.BatchableContext BC){
       list<string> acst = new list<string>();
       acst.add('Closed Won');
       acst.add('Closed Won(Consolidated)');
       acst.add('Closed Lost');
       return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<opportunity> scope){
        OppCertificationTypeChanges.getOppChanges(scope);
     }
 
    global void finish(Database.BatchableContext BC){
    }
    
 }