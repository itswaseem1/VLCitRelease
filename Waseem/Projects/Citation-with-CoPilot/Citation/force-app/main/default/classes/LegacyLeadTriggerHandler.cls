public without sharing class LegacyLeadTriggerHandler implements ITriggerHandler
{
    private static Set<String> marketingFields = new Set<String>{'MADE_Criteria__c', 
                                                                'LeadSource', 
                                                                'Source_Campaign__c', 
                                                                'Sales_Criterion__c', 
                                                                'ReferredByCompanyInternal__c', 
                                                                'Source__c',
                                                                'Data_Supplier__c', 
                                                                'Partner_CC_Exclusion__c'};
    public void beforeInsert(List<SObject> newRecords)
    {
        List<Lead> leads = (List<Lead>)newRecords;

        TriggerLeadHandler handler = TriggerLeadHandler.getInstance();
        handler.onBeforeInsert(leads);

        LeadTriggerHandler.setDialListFields(leads);
            LeadTriggerHandler.processSector(Trigger.New, null);

        List<Lead> marketLeads = new List<Lead>();
        for(Lead lead: leads)
        {
            if(leadRequiresMarketingUpdate(lead, null))
            {
                marketLeads.add(lead);
            }
        }

        if(!marketLeads.isEmpty()){
            LeadTriggerHandler.updateSalesMarketingChannel(marketLeads, null, null, true);
        }
    }

    public void afterInsert(List<SObject> newRecords)
    {
        List<Lead> leads = (List<Lead>)newRecords;

        RefferalAccessHandler.enableLeadRecsAccess(leads, null);

        TriggerLeadHandler handler = TriggerLeadHandler.getInstance();
        handler.onAfterInsert(leads, null);
        
        audit(null, leads);
    }

    public void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {       
        List<Lead> leads = (List<Lead>)newRecords.values();
        Map<ID, Lead> leadMap = (Map<ID, Lead>)oldRecords;
        
        LeadTriggerHandler.processSector(leads, leadMap);
        
        TriggerLeadHandler handler = TriggerLeadHandler.getInstance();
        handler.onBeforeUpdate(null, leadMap, leads, null);
        
        LeadOptimizationHandler.CloseBasedOnOutcome(leads) ;
        
        List<Lead> marketLeads = new List<Lead>();
        List<Lead> updateDialListLeads = new List<Lead>();
        for(Lead lead: leads)
        {
            Lead oldLead = leadMap.get(lead.id);

            if(leadRequiresMarketingUpdate(lead, oldLead))
            {
                marketLeads.add(lead);
            }

            if( lead.RecordTypeId != oldLead.RecordTypeId || 
                lead.CitationSector__c != oldLead.CitationSector__c || 
                lead.SIC2007_Code__c != oldLead.SIC2007_Code__c || 
                lead.SIC2007_Code3__c != oldLead.SIC2007_Code3__c || 
                lead.status != oldLead.status ||
                lead.IsTPS__c != oldLead.IsTPS__c || 
                lead.Phone != oldLead.Phone ||
                lead.Assigned_BDC__c != oldLead.Assigned_BDC__c || 
                lead.BDC__c != oldLead.BDC__c || 
                lead.Source__c != oldLead.Source__c ||
                lead.OutCode__c != oldLead.OutCode__c ||
                lead.Data_Supplier__c != oldLead.Data_Supplier__c ||
                lead.FT_Employees__c != oldLead.FT_Employees__c ||
                lead.Ownerid != oldLead.Ownerid ||
                lead.Partner_CC_Exclusion__c != oldLead.Partner_CC_Exclusion__c || 
                lead.LeadSource != oldLead.LeadSource)
            {
               updateDialListLeads.add(lead);     
            }
        }

        if(!marketLeads.isEmpty()){
            LeadTriggerHandler.updateSalesMarketingChannel(marketLeads,null,leadMap,false);
        }

        if(!updateDialListLeads.isEmpty()){
            LeadTriggerHandler.setDialListFields(updateDialListLeads);
        }
    }

    public void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        List<Lead> leads = (List<Lead>)newRecords.values();
        Map<ID, Lead> leadMap = (Map<ID, Lead>)oldRecords;
        
        RefferalAccessHandler.enableLeadRecsAccess(leads, leadMap);

        List<id> bdcClL = new List<id>(); 
        for(lead ld: leads)
        {
            if(ld.bdc__c != leadMap.get(ld.id).bdc__c)
            {
                bdcClL.add(ld.id);
            }
        }

        if(bdcClL.size() > 0)
        {
            List<Task> tasks = [SELECT id, WhoId, ownerid, status FROM task WHERE whoid IN:bdcClL];
            TaskTriggerHandler.BDCCallCount(tasks) ;    
        }

        audit(leadMap.values(), leads);
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

    private void audit(List<Lead> oldLeads, List<Lead> leads)
    {
        Audit_Trace__c audit = Audit_Trace__c.getvalues(userinfo.getuserid());
        if (audit != null)
        {
            AuditUtils.CheckLeadchanges(oldLeads, leads) ;
        }
    }

    private Boolean leadRequiresMarketingUpdate(Lead lead, Lead oldLead)
    {
        if((lead.status != 'Approved' &&
            lead.status != 'Callback Requested' &&
            lead.status != 'Data Quality' && 
            lead.status != 'Pended' ))
        {
            return false;
        }

        Id leadRTID = new RecordTypeSelector().getRecordTypeId(lead.getSObjectType(), 'Default_Citation_Record_Type');
        if(lead.RecordTypeId != leadRTID)
        {
            return false;
        }
        
        return marketingFieldsChanged(lead, oldLead);
    }

    private Boolean marketingFieldsChanged(Lead lead, Lead oldLead)
    {
        for(String fld: marketingFields)
        {
            Boolean change = oldLead == null ? lead.get(fld) != null : lead.get(fld) != oldLead.get(fld);
            if(change)
            {
                return true;
            }
        }

        return false;
    }   
}