global with sharing class BatchUpdateSalesMarketingChannelOpp implements Database.Batchable<sObject>{
    global Database.queryLocator start (Database.BatchableContext bc){
         String query='SELECT Type,LeadSource,Marketing_Channel__c,Referred_By_Citation_Company__c,Sales_Channel__c,Sales_Criterion__c,CampaignId,Campaign.Name from Opportunity Where (((StageName = \'Closed Won\' OR StageName = \'Closed Won (Consolidated)\' OR StageName = \'Closed Lost\') and CloseDate >=2018-01-01) OR (StageName != \'Closed Won\' AND StageName != \'Closed Won (Consolidated)\' AND StageName != \'Closed Lost\')) and Type=\'New Business\' and  Recordtype.Name=\'Default Citation Opportunity\'';
         return Database.getQueryLocator(query); 
    }
    global void execute (Database.BatchableContext bc ,List<Opportunity> scope){
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
        List<Opportunity> oppties=new List<Opportunity>();
        for(Opportunity opp:scope){
            boolean scupdated=false;
            if(opp.Type==null){
                 opp.Type='Existing Business';
               }
            if(opp.LeadSource!=null && prospectToMarketingChannel.containsKey(opp.LeadSource)){
                    opp.Marketing_Channel__c=prospectToMarketingChannel.get(opp.LeadSource);
                }
                if(opp.LeadSource==null || opp.LeadSource==''|| (opp.LeadSource!=null && !prospectToMarketingChannel.containsKey(opp.LeadSource))){
                    opp.Marketing_Channel__c='';
                }
                if(opp.CampaignId!=null){
                    if(opp.Campaign.Name.Contains('EPM') || opp.Campaign.Name.Contains('QMS') || opp.Campaign.Name.Contains('SMAS') || opp.Campaign.Name.Contains('P&R') || opp.Campaign.Name.Contains('SM UK') || opp.Campaign.Name.Contains('HS Direct') || opp.Campaign.Name.Contains('EL Direct') || opp.Campaign.Name.Contains('Southalls') || opp.Campaign.Name.Contains('Avec') || opp.Campaign.Name.Contains('Food Alert')){
                        opp.Sales_Channel__c='Cross Sell';
                        scupdated=true;
                    }
                }
                if(opp.LeadSource!=null && (opp.LeadSource.contains('EPM') || opp.LeadSource.contains('QMS')|| opp.LeadSource.contains('P&R') || opp.LeadSource.contains('SMAS')|| opp.LeadSource.contains('SM UK')|| opp.LeadSource.contains('HS Direct')|| opp.LeadSource.contains('EL Direct')|| opp.LeadSource.contains('Southalls')|| opp.LeadSource.contains('Avec')|| opp.LeadSource.contains('Food Alert')) && !scupdated){
                    opp.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }
                if(opp.Referred_By_Citation_Company__c!=null && (opp.Referred_By_Citation_Company__c.contains('EPM') || opp.Referred_By_Citation_Company__c.contains('QMS')|| opp.Referred_By_Citation_Company__c.contains('P&R') || opp.Referred_By_Citation_Company__c.contains('SMAS')|| opp.Referred_By_Citation_Company__c.contains('SM UK')|| opp.Referred_By_Citation_Company__c.contains('HS Direct')|| opp.Referred_By_Citation_Company__c.contains('EL Direct')|| opp.Referred_By_Citation_Company__c.contains('Southalls')|| opp.Referred_By_Citation_Company__c.contains('Avec')|| opp.Referred_By_Citation_Company__c.contains('Food Alert')) && !scupdated){
                    opp.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }
                if(opp.LeadSource!=null && (opp.LeadSource.contains('SEM') || opp.LeadSource.contains('Seminar')) && !scupdated){
                    opp.Sales_Channel__c='Seminar';
                    scupdated=true;
                }
                if(opp.LeadSource!=null && opp.Sales_Criterion__c!=null && ProspectToSalesChannel.containsKey(opp.LeadSource) 
                    && ProspectToSalesChannel.get(opp.LeadSource).equals('Outbound or Inbound') && !scupdated){
                    opp.Sales_Channel__c=opp.Sales_Criterion__c;
                    scupdated=true;
                }
                if(opp.LeadSource!=null && ProspectToSalesChannel.containsKey(opp.LeadSource) && !scupdated){
                    opp.Sales_Channel__c=ProspectToSalesChannel.get(opp.LeadSource);
                    scupdated=true;
                }
                if(!scupdated){
                    opp.Sales_Channel__c='Data Incomplete';
                }
            oppties.add(opp);
        }
        if(!oppties.isEmpty())
        database.update(oppties,false);
    }
 global void finish (Database.BatchableContext bc){
 
 }
}