global class SelfServeReportResultsUpdateOppAuto implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    public list<id> recordIds {get;set;}
    public map<id,list<DML_Outcome__c>> ACist;
    List<String> toAddresses                            = ((String)System.label.OppAutoDL).split(',');
    string reportName = '';
    integer recProcessed  = 0;
    boolean stpr = false;
    Integer totalLeadsUpdated = 0;
    public string reportId;
    List<Database.SaveResult> dbList                    = new List<Database.SaveResult>();
    
    public SelfServeReportResultsUpdateOppAuto(list<id> recordId,string objname,map<id,list<DML_Outcome__c>> acList,string rpna,integer totr,string rpid){
        
        system.debug('Al records'+recordIds);
        if(totr != null && totr != 0){
            totalLeadsUpdated = totr;
        }
        reportName = rpna;
        reportId = rpid;
        ACist = acList;
        recordIds = recordId;
        query = 'select id ';
        if(objname == 'Opportunity'){
            for(list<DML_Outcome__c> dll:ACist.values()) {
                for(DML_Outcome__c dla: dll){
                    if(dla.Field_API_Name__c != '' && dla.Field_API_Name__c != null && !query.contains(dla.Field_API_Name__c)){
                        query += ', ' + dla.Field_API_Name__c;
                    }
                }
            }
            query += ' from opportunity where id in:recordIds';   
        }
        
    }
    
    public SelfServeReportResultsUpdateOppAuto(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sobject> scope){        
        
            integer countl = 0;
            list<sobject>   lso = new list<sobject>();
            for(sobject sd: scope){
                opportunity soj = new opportunity();
                soj.put('id',sd.id);
                for(list<DML_Outcome__c> lsdou:ACist.values()){
                    for(DML_Outcome__c dou:lsdou){
                        string dlApi = dou.Field_API_Name__c;
                        if(dou.Operator__c == 'Equals'){
                            soj.put(dou.Field_API_Name__c,dou.Outcome__c);    
                        }
                        else if(dou.Operator__c == 'Appends'){
                            soj.put(dou.Field_API_Name__c,(String)sd.get(dlApi)!='' && (String)sd.get(dlApi)!=null ?(String)sd.get(dlApi)+' '+dou.Outcome__c:dou.Outcome__c);
                        }
                        
                    }
                } 
                lso.add(soj);
                system.debug('record list '+lso);
            }
        
            if(lso.size()>0){
                totalLeadsUpdated = totalLeadsUpdated + (integer)lso.size();
                recProcessed = recProcessed+(integer)lso.size();
                database.update(lso,false);
                system.debug(totalLeadsUpdated+'next ---'+recProcessed);
            }
        
    }
    
    global void finish(Database.BatchableContext bc){
       Automation_Configuration__c acLi = new Automation_Configuration__c();
       FetchReportResults FRR = new FetchReportResults();
       list<id>  tlid = new list<id>();
       tlid = FRR.getRecordIdList(reportId,'Opportunity');
       if(recProcessed <2000 && recProcessed != tlid.size() && (tlid.size()>0 || tlid.size() <2000)){
        totalLeadsUpdated = totalLeadsUpdated- tlid.size();
       }
        if(ACist.size()>0 && ((tlid.size() < 2000 && recProcessed == tlid.size()) ||  tlid.size() == 0)){
            for(id a: ACist.Keyset()){
                acLi.Processed__c = 'Yes';
                acLi.id = a;
            }
            update acLi;
            list<Automation_Configuration__c> lac = [SELECT Id,Processed__c,recordtypeid from Automation_Configuration__c where Processed__c = 'No'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(tlid.size() == 0){
                totalLeadsUpdated = totalLeadsUpdated;      
            }
            //totalLeadsUpdated = totalLeadsUpdated>0 && (recordIds.size()>0)?totalLeadsUpdated:totalLeadsUpdated - recProcessed;
            mail.setsubject('Opportunity Automation for Report '+reportName);
            mail.SetPlainTextbody(  'Total number of records Processed : '               +totalLeadsUpdated );
            mail.setToAddresses(toAddresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            totalLeadsUpdated = 0;
            if(lac.size()>0){
                Database.executeBatch(new SelfServeReportResultsFetchOppAutomation(), 2000);
            }
        }
        else Database.executeBatch(new SelfServeReportResultsFetchOppAutomation(totalLeadsUpdated,tlid), 2000);
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SelfServeReportResultsUpdateOppAuto(), 250);
    }

}