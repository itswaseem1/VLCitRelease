global class SelfServeReportResultsFetchOpp implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    public list<id> leadRecordId = new list<id>();
    string repName = '';
    boolean firsttime = true;
    public integer totpr = 0;
    integer erroredSize = 0;
    public set<id> flSetId = new set<id>();
    integer prevProce = 0;
    public string reportId;
    list<id>  tlid = new list<id>();
    boolean runDup = true;
    public ID  atConfiId;
    public map<id,list<DML_Outcome__c>> AcList = new map<id,list<DML_Outcome__c>>();
    public SelfServeReportResultsFetchOpp(String queryString){
        query = queryString;
    }
    
    public SelfServeReportResultsFetchOpp(){
        firsttime = true;
        query = 'SELECT Id,Processed__c,Run_Duplicate_Rules__c,Distribution_List__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c where Processed__c In: stp and recordtypeid =:lareI limit 1';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // Get the report ID
        list<string> stP = new list<string>();
        stp.add('No');
        id lareI = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Automation_Configuration__c> scope){        
        try{
            for(Automation_Configuration__c acg: scope){
                atConfiId = acg.id;
                if(acg.Run_Duplicate_Rules__c != null){
                    runDup  = acg.Run_Duplicate_Rules__c;
                }
               for(DML_Outcome__c dou:acg.DML_Outcomes__r){
                    if(AcList.containsKey(acg.id)){
                        (AcList.get(acg.id)).add(dou); 
                    } 
                    else{
                        list<DML_Outcome__c> tdou = new list<DML_Outcome__c>();
                        tdou.add(dou);
                        AcList.put(acg.id,tdou);
                    }
                }
                repName = acg.Report_Name__c;
                // Get the report ID
                List <Report> reportList = [SELECT Id,name FROM Report where 
                                            name =:repName];
                reportId = ((String)reportList.get(0).get('Id')).left(15);
                if(reportId != null && reportId != ''){
                    FetchReportResults FRR = new FetchReportResults();
                    tlid = FRR.getRecordIdList(reportId,'Opportunity');                    
                }

                if(tlid.size()>0){
                    for(id lid: tlid){
                        leadRecordId.add(lid);
                    }
                }
                
            }

        }catch(Exception e){
            System.debug('SelfServeReportResultsFetchOpp Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
          system.debug('Printing the leadrecord'+leadRecordId);  
           if(leadRecordId.size()>0){
            Database.executeBatch(new SelfServeReportResultsUpdateOpp(leadRecordId,'Opportunity',AcList,repName,totpr,reportId,runDup), 10);
           }
           else{
                Automation_Configuration__c cd = new Automation_Configuration__c();
                if(atConfiId != null){
                    cd.id = atConfiId;
                    cd.Processed__c = 'Yes';
                    update cd;
                }
                
            
                id lareI = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Closed Lost Prospect Creator').getRecordTypeId();
                list<id> lsd = new list<id>();
                lsd.add(lareI);
                list<Automation_Configuration__c> lac = [SELECT Id,Processed__c,recordtypeid from Automation_Configuration__c where Processed__c = 'No' and recordtypeid =: lsd ];
                
                if(lac.size()>0){
                    Database.executeBatch(new SelfServeReportResultsFetchOpp(), 2000);
                }
        }                 
         

    }
    
    global void execute(SchedulableContext sc) {
        //Database.executeBatch(new SelfServeReportResultsFetchOpp(), 250);
    }

}