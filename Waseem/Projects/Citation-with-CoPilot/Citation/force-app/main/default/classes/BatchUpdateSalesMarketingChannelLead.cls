global with sharing class BatchUpdateSalesMarketingChannelLead implements Database.Batchable<sObject>{
	global Database.queryLocator start (Database.BatchableContext bc){
		 String query='SELECT LeadSource,Marketing_Channel__c,Sales_Channel__c,Sales_Criterion__c,Source_Campaign__c,Source_Campaign__r.Name from Lead WHERE isConverted=false and (Sales_Channel__c=null OR Marketing_Channel__c=null) and CreatedDate>=2018-01-01T00:00:00Z and RecordType.Name=\'Default Citation Record Type\'';
		 return Database.getQueryLocator(query); 
    }
	global void execute (Database.BatchableContext bc ,List<Lead> scope){
		Map<String,String> prospectToMarketingChannel=new Map<String,String>();
		Map<String,String> ProspectToSalesChannel=new Map<String,String>();
		Set<String> channels=new Set<String>();
		List<Prospect_Source_Data__mdt> prospectSourceMDT=new List<Prospect_Source_Data__mdt>();
		prospectSourceMDT=[SELECT Label,Marketing_Channel__c,Sales_Channel__c from Prospect_Source_Data__mdt];
		for(Prospect_Source_Data__mdt pmdt:prospectSourceMDT){
			prospectToMarketingChannel.put(pmdt.Label,pmdt.Marketing_Channel__c);
			ProspectToSalesChannel.put(pmdt.Label,pmdt.Sales_Channel__c);
			channels.add(pmdt.Sales_Channel__c);
		}
		List<Lead> leads=new List<Lead>();
		for(Lead l:scope){
			boolean scupdated=false;
			if(l.LeadSource!=null && prospectToMarketingChannel.containsKey(l.LeadSource)){
				l.Marketing_Channel__c=prospectToMarketingChannel.get(l.LeadSource);
			}
			if(l.LeadSource==null || l.LeadSource==''|| (l.LeadSource!=null && !prospectToMarketingChannel.containsKey(l.LeadSource))){
				l.Marketing_Channel__c='';
			}
			if(l.Source_Campaign__c!=null){
				if(l.Source_Campaign__r.Name.contains('EPM') || l.Source_Campaign__r.Name.contains('QMS') || l.Source_Campaign__r.Name.contains('SMAS')){
					l.Sales_Channel__c='Cross Sell';
					scupdated=true;
				}
			}
			if(l.LeadSource!=null && l.LeadSource.contains('SEM') && !scupdated){
				l.Sales_Channel__c='Seminar';
				scupdated=true;
			}
			if(l.LeadSource!=null && l.Sales_Criterion__c!=null 
					&& ProspectToSalesChannel.containsKey(l.LeadSource) 
					&& ProspectToSalesChannel.get(l.LeadSource).equals('Outbound or Inbound') && !scupdated){
						l.Sales_Channel__c=l.Sales_Criterion__c;
				scupdated=true;
			 }
			if(l.LeadSource!=null && ProspectToSalesChannel.containsKey(l.LeadSource) && !scupdated){
				l.Sales_Channel__c=ProspectToSalesChannel.get(l.LeadSource);
				scupdated=true;
			}
			if(!scupdated) {
				l.Sales_Channel__c='Data Incomplete';
			}
			leads.add(l);
		}
		if(!leads.isEmpty())
		database.update(leads, false);
	}
 global void finish (Database.BatchableContext bc){
 
 }
}