public class QueriesEscalationBatch implements Database.Batchable<sObject> {
    
    group clientQueryGroup;
    Date endDate;
    
    public  QueriesEscalationBatch(){
        clientQueryGroup = [select OwnerId,Id from Group where Name='Client Query' AND Type = 'Queue'];
        endDate = System.today().addDays(-7);
    }
    public Database.QueryLocator start( Database.BatchableContext bc ) {
        String query;
        query = 'SELECT Id,OwnerId,CaseNumber FROM  Case WHERE OwnerId!=\'' + clientQueryGroup.id + '\'' +
            ' and Day_Only(CreatedDate) =: endDate '+
            ' and RecordType.developerName=\'Client_Query\''+
            ' and status!=\'Closed\'' ; 
        //query = 'SELECT Id,OwnerId,CaseNumber FROM  Case WHERE OwnerId !=: clientQueryGroup and Day_Only(CreatedDate) =: endDate and RecordType.id =: CaseRecordType and status !=: Status ' ;     
        return Database.getQueryLocator( query );
    }
    
    public void execute( Database.BatchableContext bc, List< Case> scope ) {
        new sendEscalationEmails().sendEmails(scope);
    }   
    
    public void finish( Database.BatchableContext bc ) {
    }
}