global class SelfServeReportResultsFetch implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    private String query;
    public list<id> leadRecordId = new list<id>();
    public boolean fire;
    string repName = '';
    boolean firsttime = true;
    public integer totpr = 0;
    integer erroredSize = 0;
    public set<id> flSetId = new set<id>();
    integer prevProce = 0;
    public string reportId;
    list<id>  tlid = new list<id>();
    public map<id,list<DML_Outcome__c>> AcList = new map<id,list<DML_Outcome__c>>();
    public SelfServeReportResultsFetch(String queryString){
        query = queryString;
    }
    
    public SelfServeReportResultsFetch(){
        firsttime = true;
        query = 'SELECT Id,Processed__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c where Processed__c In: stp and recordtypeid =:lareI limit 1';
    }
    public SelfServeReportResultsFetch(integer totrec,list<id> rlid){
        firsttime = false;
        if(totrec >0){
            totpr = totrec;
        }
        tlid = rlid;
        query = 'SELECT Id,Processed__c,recordtypeid,(select id,Field_API_Name__c,Operator__c,Outcome__c from DML_Outcomes__r),Report_Name__c FROM Automation_Configuration__c where Processed__c In: stp and recordtypeid =:lareI limit 1';
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        fire = false;
        // Get the report ID
        list<string> stP = new list<string>();
        stp.add('No');
        id lareI = Schema.getGlobalDescribe().get('Automation_Configuration__c').getDescribe().getRecordTypeInfosByName().get('Lead Automation').getRecordTypeId();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Automation_Configuration__c> scope){        
        try{
            for(Automation_Configuration__c acg: scope){
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
                if(!(tlid.size()>0)){
                    FetchReportResults FRR = new FetchReportResults();
                    tlid = FRR.getRecordIdList(reportId,'Lead');
                }
                if(tlid.size()>0){
                    for(id lid: tlid){
                        if(tlid.size() == erroredSize){

                        }
                        else if (tlid.size() != erroredSize){
                            leadRecordId.add(lid);
                        }
                    }
                }
                fire = true;
            }

        }catch(Exception e){
            System.debug('SelfServeReportResultsFetch Error Message:::'+e.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        if(fire){
          system.debug('Printing the leadrecord'+leadRecordId);  
          Database.executeBatch(new SelfServeReportResultsUpdate(leadRecordId,'Lead',AcList,repName,totpr,reportId), 350);
        }
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SelfServeReportResultsFetch(), 250);
    }

}