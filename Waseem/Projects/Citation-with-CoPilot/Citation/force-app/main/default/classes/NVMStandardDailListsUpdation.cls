global class NVMStandardDailListsUpdation implements Database.Batchable<SObject>,Database.Stateful {

    private String query;
    Map<Id,String> LeadBDMMap;
    List<Error_Log__c>  errorList;
    Integer totalNotConvertedLeads                      = 0;
    Integer totalLeadsMetCriteria                       = 0;
    Integer totalListIDPopulated                        = 0;
    Integer totalErroredRecords                         = 0;
    Set<Id> unquieSet                                   = new Set<Id>();
    Map<Id,Decimal> listIdList                          = new Map<Id,Decimal>();
    List<Database.SaveResult> srList                    = new List<Database.SaveResult>();
    Map<String,Automation_Configuration__c> MACList     = new Map<String,Automation_Configuration__c>();
    List<Job_Execution_Status_Update__mdt> recordStatus = new List<Job_Execution_Status_Update__mdt>();
    List<String> toAddresses                            = ((String)System.label.DialListTAddress).split(',');
    Public string   jobName                             =''; 
    public NVMStandardDailListsUpdation(Map<Id,Decimal> listIdList, Map<String,Automation_Configuration__c> MACList, Map<Id,String> LeadBDMMap, List<Job_Execution_Status_Update__mdt> recordStatus,Integer totalNotConvertedLeads,Integer totalLeadsMetCriteria,string jname){
        this.listIdList = listIdList;
        this.MACList = MACList;
        this.LeadBDMMap = LeadBDMMap;
        this.recordStatus = recordStatus;
        this.totalNotConvertedLeads = totalNotConvertedLeads;
        this.totalLeadsMetCriteria = totalLeadsMetCriteria;
        System.debug('listIdList size'+listIdList.size());
        unquieSet.addAll(listIdList.keySet());
        this.query = 'SELECT Id,List_ID__c FROM Lead WHERE IsConverted=false AND Id IN:unquieSet';
        jobName = jname;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope){        
        try{
            List<Lead> finalUpdateList = new List<Lead>();
            for(Lead l : scope){
                if(listIdList.containsKey(l.Id)){
                    l.List_ID__c = listIdList.get(l.Id);
                    if(Test.isRunningTest()){
                        l.Suspended_Closed_Reason__c='Under Criteria';
                    }
                    finalUpdateList.add(l);
                }
            }
            if(finalUpdateList.size()>0){
                srList = Database.update(finalUpdateList,false);
            }
            errorList = new List<Error_Log__c>();
            for(Integer i=0;i<srList.size();i++){
                if (srList.get(i).isSuccess()){
                    totalListIDPopulated+=1;
                }else if(!srList.get(i).isSuccess()){
                    integer tempselected = 0;
                    Database.Error error = srList.get(i).getErrors().get(0);
                    Automation_Configuration__c AcTemp = new Automation_Configuration__c();
                    totalErroredRecords+=1;
                    Error_Log__c errorLog = new Error_Log__c();
                    errorLog.Lead__c = finalUpdateList.get(i).Id;
                    AcTemp = MACList.get(LeadBDMMap.get(finalUpdateList.get(i).Id));
                    AcTemp.selected__c = AcTemp.selected__c - 1;
                    MACList.put(LeadBDMMap.get(finalUpdateList.get(i).Id),AcTemp);
                    errorLog.Error_Message__c = recordStatus[0].Result_Message_4__c + '\n' +error.getMessage();
                    errorLog.Error_Origin__c = 'NVMStandardDailListsScheduleJob Class';
                    errorLog.Name = errorLog.Error_Origin__c + ' - ' +finalUpdateList.get(i).Name;
                    errorList.add(errorLog);
                }
            }
            if(errorList.size()>0){
                insert errorList;
            }
            if(MACList.size()>0){
                update MACList.values();
            }
        }catch(Exception e){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setsubject('If any exceptions updation');
            mail.SetPlainTextbody(  'Errors '                                      +     '\n' +e.getLineNumber()+' '+e.getMessage());
            mail.setToAddresses(toAddresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            System.debug('NVMStandardDailListsUpdation Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
            String jobStatus;
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id=:bc.getJobId()];
            if(job.Status=='Completed' || job.Status=='Processing'){
                jobStatus = 'Completed';
            }else{
                jobStatus = job.Status;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setsubject('NVM Standard Dialler List Job Result');
            mail.SetPlainTextbody(  'Job Status : '+ jobName +          +jobStatus                 + '\n' +
                                    'Total number of Non-Converted Leads : '             +totalNotConvertedLeads    + '\n' +
                                    'Total number of Leads met the criteria : '          +totalLeadsMetCriteria     + '\n' +
                                    'Total number of records populated with List Id : '  +totalListIDPopulated      + '\n' +
                                    'Total number of records Errored   : '               +totalErroredRecords       + '\n' +
                                    'Report Link : ' +System.Label.DiallerReportLink    );
            mail.setToAddresses(toAddresses);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            if(jobName == 'List 3'){
                Database.executeBatch(new NVMStandardDailListsScheduleJobList1a(), 2000);
            }
            else if(jobName == 'List 1a'){
                Database.executeBatch(new NVMStandardDailListsScheduleJobList1b(), 2000);
            }
        else if(jobName == 'List 1b'){
            Set<String> listTypesSet = new Set<String>();
            for(Automation_Configuration__c autoCon: [SELECT Id, Name,RecordType.Name, List_Type__c FROM Automation_Configuration__c where List_Type__c!=null and RecordType.Name='DL BDM Limits' order by List_Type__c ASC ]){
                if(autoCon.List_Type__c!='List 1a' && autoCon.List_Type__c!='List 1b'){
                    listTypesSet.add(autoCon.List_Type__c);
                }   
            }
            system.debug(listTypesSet.size()+'-----'+listTypesSet);
            
            for(string str: listTypesSet){
                ID batchprocessid = Database.executeBatch(new NVMStandardDailListsScheduleJobList2(str),2000);
            }
        }
    }
}