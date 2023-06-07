public class DuplicateiHASCOProspectBatch implements Database.Batchable<sObject>, Schedulable{
	RecordTypeSelector selector=new RecordTypeSelector();
	ILeadService leadService= new LeadService(new LeadService.DefaultSelector(),NULL);
	Id iHASCOLeadRecordType=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(DataConstants.LEAD_iHASCO_RECORDTYPENAME).getRecordTypeId();
	DateTime cutOff;
	String leadStatusDuplicateFound;
	String leadStatusConverted;
	String websiteLeads='Website';
    String webLeadCondition;
	
	public  DuplicateiHASCOProspectBatch()
	{
		webLeadCondition = 'AND  leadsource =: websiteLeads';
		DateTime currentTime = System.now();
		cutOff = currentTime.addHours(-1);
		leadStatusDuplicateFound= DataConstants.LEAD_STATUS_DUPLICATE_FOUND;
		leadStatusConverted=DataConstants.LEAD_STATUS_CONVERTED;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		String query='SELECT Id,Email,Email_Domain__c FROM Lead WHERE CreatedDate >= :cutOff';
		query = query +' AND RecordTypeId=:iHASCOLeadRecordType AND Status !=:leadStatusDuplicateFound AND Status !=:leadStatusConverted ';            
        query = query + webLeadCondition ;
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, List<Lead> leadList)
	{
		leadService.updateDuplicateLead(leadList, iHASCOLeadRecordType);
	}
	
	public void finish(Database.BatchableContext BC)
	{
	}
	
	public void execute(SchedulableContext SC) {
		database.executebatch(new DuplicateiHASCOProspectBatch());
	}
}