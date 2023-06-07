public without sharing class LegacyOpportunityTriggerHandler implements ITriggerHandler
{
    private boolean isIHasco()
    {
        return iHASCOUtility.userDivison == 'iHASCO';
    }

    public void beforeInsert(List<SObject> newRecords)
    {
        if(isIHasco())
            return;

        List<Opportunity> newOpps = (List<Opportunity>)newRecords;

        // old triggers - bg_Opportunity_bi
        bg_Opportunity_Helper.setPricebook(newOpps);

        // old triggers - OpportunityTrigger  
        String oppRTID = new RecordTypeSelector().getRecordTypeId(Opportunity.SObjectType, 'Default_Citation_Opportunity'); 
        
        List<Opportunity> oppties=new List<Opportunity>();

        for(Opportunity opp: newOpps)
        {
           if( opp.RecordTypeId==oppRTID 
                && (opp.MADE_Criteria__c!=null 
                    || opp.CampaignId!=null
                    || opp.LeadSource!=null
                    || opp.Source__c!=null
                    || opp.Data_Supplier__c!=null
                    || opp.Sales_Criterion__c!=null))
            {
                oppties.add(opp);
            }
        }

        if(!oppties.isEmpty()){
            TriggerOpportunityHandler.updateSalesMarketingChannel(oppties,null,null,true);
        }
    }

    public void afterInsert(List<SObject> newRecords)
    {
        if(isIHasco())
            return;

        List<Opportunity> newOpps = (List<Opportunity>)newRecords;

        // old triggers - bg_Opportunity_ai
        bg_Opportunity_Helper.sortMultiSelectPicklistValues(newOpps);
        bg_Opportunity_Helper.checkReadyForRenewal(newOpps);
        
        List<Opportunity> oppList= new List<Opportunity>();
        Id elasRenewalOppRecordTypeId = new RecordTypeSelector().getRecordTypeId(Opportunity.SObjectType, 'ELAS_Renewal_Retention_Opportunity_Non_Auto'); 
        
        for(Opportunity opp: newOpps)
        {
            if(opp.RecordTypeId == elasRenewalOppRecordTypeId && opp.StageName=='Closed Won'){            
                oppList.add(opp);
            }
        }
        if(!oppList.isEmpty())
        {      
            bg_FmInt_Opportunity_Helper.opportunityELASEmail(oppList);   
        }

        // old triggers - OpportunityReferralAccess
        RefferalAccessHandler.enableOppRecsAccess(newOpps, null);

        // old triggers - OpportunityTrigger  
        List<Opportunity> renewalOpp = new List<Opportunity>();
        Audit_Trace__c audit = Audit_Trace__c.getvalues(UserInfo.getUserid()) ;
        if (audit != null)
        {
            AuditUtils.LogOpportunityInsert( newOpps) ;
        }

        String opprenewalRTIDNonAuto = new RecordTypeSelector().getRecordTypeId(Opportunity.SObjectType, 'Renewal_Retention_Opportunity_NA'); 

        for(Opportunity opp: newOpps)
        {
            if(opp.RecordTypeId == opprenewalRTIDNonAuto)
            {
                renewalOpp.add(opp);
            }
        }
        if(!renewalOpp.isEmpty()){
            TriggerOpportunityHandler.createQuotes(renewalOpp);
        }
    }

    public void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {       
        if(isIHasco())
            return;

        Map<Id, Opportunity> newOpps =  (Map<Id, Opportunity>)newRecords;
        Map<Id, Opportunity> oldOpps = (Map<Id, Opportunity>)oldRecords;

        // old triggers - OpportunityTrigger  
        String oppRTID = new RecordTypeSelector().getRecordTypeId(Opportunity.SObjectType, 'Default_Citation_Opportunity'); 

        List<Opportunity> oppties=new List<Opportunity>();
        for(Opportunity opp: newOpps.values())
        {
            Opportunity oldOpp = oldOpps.get(opp.Id);

            if(opp.RecordTypeId == oppRTID 
                &&(opp.MADE_Criteria__c != oldOpp.MADE_Criteria__c
                || (opp.CampaignId != oldOpp.CampaignId)
                || (opp.LeadSource != oldOpp.LeadSource)
                || (opp.Sales_Criterion__c != oldOpp.Sales_Criterion__c)
                || (opp.Source__c != oldOpp.Source__c)
                || (opp.Data_Supplier__c != oldOpp.Data_Supplier__c)
                || (opp.Referred_By_Citation_Company__c != oldOpp.Referred_By_Citation_Company__c)))
            {
                    oppties.add(opp);
            }         
        }
        if(!oppties.isEmpty()){
            TriggerOpportunityHandler.updateSalesMarketingChannel(oppties, newOpps, oldOpps, false);
        }
        //Call updateContractedonQMSOpp to Update Contracted Checkbox upon New Service form returned checkbox is turned on for QMS Opportunities
        TriggerOpportunityHandler.updateContractedonQMSOpp(newOpps.values(), oldOpps);
    }

    public void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        if(isIHasco())
            return;

        Map<Id, Opportunity> newOpps =  (Map<Id, Opportunity>)newRecords;
        Map<Id, Opportunity> oldOpps = (Map<Id, Opportunity>)oldRecords;

        // old triggers - bg_Opportunity_au
        bg_Opportunity_Helper.sortMultiSelectPicklistValues(newOpps.values(), oldOpps);
        bg_Opportunity_Helper.checkOpportunitiesForApproval(newOpps.values(), oldOpps);
        bg_Opportunity_Helper.checkReadyForRenewal(newOpps.values(), oldOpps);
        bg_Opportunity_Helper.checkForReduction(newOpps.values(), oldOpps);
        bg_FmInt_Opportunity_Helper.synchronise(newOpps.values(), oldOpps);
        
        List<Opportunity> oppList= new List<Opportunity>();
        Id elasRenewalOppRecordTypeId = new RecordTypeSelector().getRecordTypeId(Opportunity.SObjectType, 'ELAS_Renewal_Retention_Opportunity_Non_Auto'); 
        
        for(Opportunity opp: newOpps.values())
        {
            if((opp.StageName != oldOpps.get(opp.Id).StageName || 
                opp.RecordTypeId != oldOpps.get(opp.Id).RecordTypeId) 
                && (opp.StageName == 'Closed Won' && opp.RecordTypeId == elasRenewalOppRecordTypeId)){
                oppList.add(opp);
            }
        }
        if(!oppList.isEmpty())
        {      
            bg_FmInt_Opportunity_Helper.opportunityELASEmail(oppList);   
        }

        // old triggers - OpportunityReferralAccess
        RefferalAccessHandler.enableOppRecsAccess(newOpps.values(), oldOpps);

        // old triggers - OpportunityTrigger  
        Audit_Trace__c audit = new audit_trace__c() ;
        audit = Audit_Trace__c.getvalues(UserInfo.getUserId()) ;
        if (audit != null)
        {
            AuditUtils.CheckOpportunitychanges(oldOpps.values(), newOpps.values()) ;
        }

        List<id> idList = new List<id>() ;
        idList.addAll(newOpps.keyset()) ;  
        TriggerOpportunityHandler.DoReferralChecks(idList) ;
    }

    public void beforeDelete(List<SObject> oldRecords)
    {
    }
    public void afterDelete(List<SObject> oldRecords)
    {
    }

    public void afterUnDelete(List<SObject> newRecords)
    {
    }
}