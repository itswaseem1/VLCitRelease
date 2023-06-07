public class PartnerMembersAmendmentBatchClass implements Database.Batchable<string>, Database.Stateful
{
    public final blob csvData;
    Integer totalCount=0;
    String partnerId;
    String title;
    List<Partner_Member_Relationship__c> pmrList = new List<Partner_Member_Relationship__c>();
    Map<String,String> csvRowErrorMessage = new Map<String,String>();
    public PartnerMembersAmendmentBatchClass (blob data,String partnerId,String title)
    {
        this.csvData = data;
        this.partnerId = partnerId;
        this.title = title;
    }
    
    public Iterable<string>  start(Database.BatchableContext BC)
    {
        return new CSVIterator(this.csvData.toString(), '\n');
    }
    public void execute(Database.BatchableContext BC,List<String> scope)
    {
        system.debug('scope---'+scope+'---'+scope.size());
        Partner_Member_Relationship__c pmrObj;
        for(String row : scope)
        { 
            List<String> csvRecordData = row.split(',');
            if(!csvRecordData[0].contains('Partner Member Relationship ID') && String.isNotBlank(csvRecordData[0])){
                try{
                    pmrObj = new Partner_Member_Relationship__c();
                    pmrObj.Id = csvRecordData[0];
                    pmrObj.Member_left_Partner_date__c = String.isNotBlank(csvRecordData[6]) ? Date.parse(csvRecordData[6].trim()) : NULL;
                    pmrList.add(pmrObj);
                }catch(Exception ex){
                    system.debug('Excep--'+ex);
                    csvRowErrorMessage.put(scope[0],ex.getMessage());
                }
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        system.debug('pmrList--'+pmrList);
        if(!pmrList.isEmpty()){
            Map<Id, Partner_Member_Relationship__c> pmrListMap = new Map<Id, Partner_Member_Relationship__c>(pmrList);
            system.debug(partnerId+'--'+title+'--'+pmrListMap);
            if(title.containsIgnoreCase('unassign')){
                Database.executeBatch(new unAssignAtlasAccessUnitsBatch(pmrList,partnerId,pmrListMap), 20);
            }else if(title.containsIgnoreCase('assign')){
                Account objAcc = [SELECT Id,Available_HR_Member_Atlas_Access_Units__c,Available_H_S_Member_Atlas_Access_Units__c FROM Account WHERE Id=:partnerId AND Is_Active_Partner__c=TRUE];
                if(objAcc.Available_HR_Member_Atlas_Access_Units__c > 0 || objAcc.Available_H_S_Member_Atlas_Access_Units__c > 0){
                    Database.executeBatch(new AssignAtlasAccessUnitsBatch(pmrList,Integer.valueOf(objAcc.Available_HR_Member_Atlas_Access_Units__c),Integer.valueOf(objAcc.Available_H_S_Member_Atlas_Access_Units__c),partnerId),Integer.valueOf(System.label.AssignAtlasAccessUnitsBatchSize));
                }
            }
        }
    }
}