global class DialListCriteriaFieldsBatch implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    /*****
*** @Param: queryString - query to run the batch class
****/
    //The code moved back to original state
    private String query;
    public Integer BatchSize = 500;
    public Set<CodeSkip__c> settings= new Set<CodeSkip__c>();
    public static String classname= 'DialListCriteriaFieldsBatch';
    public DialListCriteriaFieldsBatch(String queryString){
        query = queryString;
    }  
    
    public DialListCriteriaFieldsBatch(String queryString , Integer BatchSizevalue){
        query = queryString;
        BatchSize = BatchSizevalue;
        
    }  
    public DialListCriteriaFieldsBatch(Integer BatchSizevalue){
        query = 'SELECT ID ,Basic_Crit__c,Basic_Crit_New__c ,FTE_Crit__c,FTE_Crit_New__c , List_Type_New__c ,Toxic_SIC_New__c , RecordTypeId, CitationSector__c,SIC2007_Code__c,SIC2007_Code3__c,status,IsTPS__c,Phone,Assigned_BDC__c,BDC__c,Source__c, OutCode__c, Data_Supplier__c, FT_Employees__c,OwnerId,Owner.name,Toxic_SIC__c,List_Type__c,Partner_CC_Exclusion__c,LeadSource FROM Lead WHERE IsConverted = false';
        BatchSize = BatchSizevalue; 
        Map<String,BatchApexController__c> myCSList = BatchApexController__c.getall();
        if(myCSList != NULL && myCSList.containskey(Classname) && myCSList.get(className).queryfilter__c != NULL && myCSList.get(className).queryfilter__c != '' ){
          query = query + ' ' + myCSList.get(className).queryfilter__c;
        }
    }  
    
    /*****
*** Query all Contracts with criteria 
*****/
    
    public DialListCriteriaFieldsBatch(){
        query = 'SELECT ID ,Basic_Crit__c,Basic_Crit_New__c ,FTE_Crit__c,FTE_Crit_New__c , List_Type_New__c ,Toxic_SIC_New__c , RecordTypeId, CitationSector__c,SIC2007_Code__c,SIC2007_Code3__c,status,IsTPS__c,Phone,Assigned_BDC__c,BDC__c,Source__c, OutCode__c, Data_Supplier__c, FT_Employees__c,OwnerId,Owner.name,Toxic_SIC__c,List_Type__c,LeadSource,Partner_CC_Exclusion__c FROM Lead WHERE IsConverted = false';
        Map<String,BatchApexController__c> myCSList = BatchApexController__c.getall();
        if(myCSList != NULL && myCSList.containskey(Classname) && myCSList.get(className).queryfilter__c != NULL && myCSList.get(className).queryfilter__c != '' ){
          query = query + ' ' +  myCSList.get(className).queryfilter__c;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        system.debug('--->' + scope.size());
        if(!scope.isEmpty()){     
                id userId = userinfo.getUserId();
                CodeSkip__c userSetting= CodeSkip__c.getInstance(userId);
                CodeSkip__c orgSetting= CodeSkip__c.getOrgDefaults();
                if(userSetting != NULL && userSetting.SkipLead__c == false){
                    userSetting.SkipLead__c = true;
                    settings.add(userSetting);
                }
                if(orgSetting == NULL || orgSetting.SkipLead__c == false){
                    orgSetting.SkipLead__c = true;
                    settings.add(orgSetting);
                }
                List<Lead> bfupdateLeads = scope.deepclone(true,true,true);
                Map<id, Lead> mapbfupdateLeads = new Map<id, Lead>(bfupdateLeads);
                List<Lead> updatedLeads = new List<Lead>();
                DialListCriteriaFieldsHelper.setDialListFields(scope);
                
                for(Lead l : scope){
                    if(mapbfupdateLeads.containskey(l.id)){
                        Lead oldLead = mapbfupdateLeads.get(l.id);
                        if( (oldLead.Basic_Crit_New__c != l.Basic_Crit_New__c) 
                           || (oldLead.FTE_Crit_New__c != l.FTE_Crit_New__c) 
                           || (oldLead.List_Type_New__c != l.List_Type_New__c)
                           || (oldLead.Toxic_SIC_New__c != l.Toxic_SIC_New__c ) )
                        {
                            updatedLeads.add(l); 
                        }
                        
                    }
                } 
                list<Database.SaveResult> srList = new list<Database.SaveResult>();
                if(!updatedLeads.isEmpty() ){
                    if(!settings.isEmpty() ){
                        List<CodeSkip__c> settingslist= new List<CodeSkip__c>();
                        settingslist.addAll(settings);
                        upsert settingslist;
                    }
                    srList = Database.update(updatedLeads, false);
                }
                Map<String,BatchApexController__c> myCSList = BatchApexController__c.getall();
                if(myCSList != NULL && myCSList.containskey(Classname) && myCSList.get(className).EmailCustomHandledExceptions__c){
                    String subject = 'DialListCriteriaFieldsBatch-Error';
                    String records = '';
                    List<String> mailidsList = new List<String>();
                    if(myCSList.get(Classname).ExceptionEmailIds__c != null){
                        
                        for (Database.SaveResult sr : srList) {
                            if (!sr.isSuccess()) {
                                // Operation failed, so get all errors   
                                for(Database.Error err : sr.getErrors()) {
                                    mailidsList = myCSList.get(Classname).ExceptionEmailIds__c.split(',');
                                    records = records + 'Error Message'+'--'+err.getMessage()+ ',';
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Fields that affected this error: ' + err.getFields());
                                }
                            }
                        }  
                   
                        if (!mailidsList.isEmpty()){
                            GenericBatchStatusEmails.CustomExceptionMail(null, subject, records , mailidsList);
                        }
                    }
                }
            }
    }
    
    global void finish(Database.BatchableContext BC){
        for(CodeSkip__c cs: settings){
            cs.SkipLead__c = false;
        }
        if(!settings.isEmpty()){
            List<CodeSkip__c> settingslist= new List<CodeSkip__c>();
            settingslist.addAll(settings);
            upsert settingslist;
        }
        Map<String,BatchApexController__c> myCSList = BatchApexController__c.getall();
        if(myCSList != NULL && myCSList.containskey(Classname) && myCSList.get(className).BatchFinalEmail__c != NULL && myCSList.get(className).BatchFinalEmail__c != '' ){
        	List<String> emails = myCSList.get(className).BatchFinalEmail__c.split(',');
            List<AggregateResult> pendingLeads = [SELECT count(id) from Lead where processed__c = false and isconverted = false];
            String body = 'Number of Leads left to be processed are ';
 			body = body + pendingLeads[0].get('expr0');           
            GenericBatchStatusEmails.sendEmail(body, 'Batch' + classname + 'Processed', emails);
        }
    }
    
    /*****
*** Scheduler Interface method 
*****/
    global void execute(SchedulableContext SC) {
        Map<String,BatchApexController__c> myCSList = BatchApexController__c.getall();
        if(myCSList != NULL && myCSList.containskey(Classname) && myCSList.get(className).Batch_size__c != NULL  ){
        	BatchSize = (Integer)myCSList.get(className).Batch_size__c;
        }
        database.executeBatch(new DialListCriteriaFieldsBatch(), BatchSize);
    }
}