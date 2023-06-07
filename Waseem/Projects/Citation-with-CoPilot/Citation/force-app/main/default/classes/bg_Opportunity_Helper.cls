public without sharing class bg_Opportunity_Helper
{
    public static void sortMultiSelectPicklistValues(List<sObject> recs)
    {
        sortMultiSelectPicklistValuesGeneric(recs);
    }

    public static void sortMultiSelectPicklistValues(List<sObject> recs, Map<Id, sObject> oldRecords)
    {
        List<sObject> sObjects = getListOfChangedRecords(recs, oldRecords);

        if(!sObjects.isEmpty())
        {
            sortMultiSelectPicklistValues(sObjects);
        }
    }

    public static void sortMultiSelectPicklistValuesGeneric(List<sObject> records)
    {
        SObjectType objectType = records[0].getSObjectType();
    
        List<String> multiSelectFields = getMultiSelectFieldNames(objectType);
        List<sObject> changedRecords = new List<sObject>();

        for(sObject opp : records)
        {
            for(String fieldName : multiSelectFields)
            {
                if(opp.get(fieldName) != null)
                {
                    changedRecords.add(opp);
                }
            }
        }

        if (!changedRecords.isEmpty() && !multiSelectFields.isEmpty())
        {
            String objectName = objectType.getDescribe().getName();
            // Check and remove existing MultiSelectPIcklist_delimit__c values for opportunities
            bg_MultiSelect_Delimit_Helper.removeNonRequiredMultiSelectPicklistDelimits(objectName, changedRecords);

            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            // Create new MultiSelectPIcklist_delimit__c values for opportunities 
            bg_MultiSelect_Delimit_Helper.insertRequiredMultiSelectPicklistDelimits(changedRecords, multiSelectFields, objectName, fieldMap);   
        }
    }

    

	// Given an object name this method checks to see if the object has any multi select picklist values
	private static List<String> getMultiSelectFieldNames(SObjectType objectType)
	{
		Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
		List<String> fieldNames = new List<String>();
		
		for (String fieldName: fieldMap.keySet()) 
		{
            DescribeFieldResult fldDescribe = fieldMap.get(fieldName).getDescribe();
			String fieldLabel = fldDescribe.getLabel();
			Schema.DisplayType fielddataType = fldDescribe.getType();
			
			// if its a multiselect picklist add it to the list
			if(fielddataType == Schema.DisplayType.MultiPicklist) 
			{
				fieldNames.add(fieldName);
			}
		
		}
		return fieldNames;
	}

    private static List<sObject> getListOfChangedRecords(List<sObject> recs, Map<Id, sObject> oldRecords)
    {
        // Look for the method that gets sObject type api name
        SObjectType objectType = recs[0].getSObjectType();

        List<sObject> recordsToUpdate = new List<sObject>();

        List<String> multiSelectFields = getMultiSelectFieldNames(objectType);

        for(sObject rec : recs)
        {
            Boolean oppFieldHasChanged = false;

            for(String multiSelectField : multiSelectFields)
            {
                if(rec.get(multiSelectField) != oldRecords.get(rec.Id).get(multiSelectField))
                {
                    oppFieldHasChanged = true;
                }
            }

            if(oppFieldHasChanged)
            {
                recordsToUpdate.add(rec);
            }
        }

        return recordsToUpdate;
    }

    // After insert trigger. Checking checkbox is ticked and stage is closed won and record type before creating the renewal opportunity
    
    public static void checkReadyForRenewal(List<Opportunity> opportunities)
    {
        List<Opportunity> renewalOpportunities = new List<Opportunity>();
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSRecordTypeId = opportunityTypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);
        
        for (Opportunity opp : opportunities)
        {
            if(opp.Ready_For_Renewal__c && opp.StageName == bg_Constants.OPPORUNITY_STAGE_CLOSED_WON && opp.RecordTypeId == QMSRecordTypeId)
            {
                renewalOpportunities.add(opp);
            }
        }

        if (!renewalOpportunities.isEmpty())
        {
            System.EnqueueJob(new bg_Opportunity_QueueableHelper(renewalOpportunities));
        }
    }

    // After update trigger. Checking old value of opportunity is not equal to the same value before the record was saved. Creating the renewal opportunity based on the criteria.
    
    public static void checkReadyForRenewal(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities)
    {
        List<Opportunity> renewalOpportunities = new List<Opportunity>();
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSRecordTypeId = opportunityTypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);

        for (Opportunity opp : opportunities)
        {   
            if(opp.Ready_For_Renewal__c && !oldOpportunities.get(opp.Id).Ready_For_Renewal__c && opp.StageName == bg_Constants.OPPORUNITY_STAGE_CLOSED_WON && opp.RecordTypeId == QMSRecordTypeId)
            {
                renewalOpportunities.add(opp);
            }
        }

        if (!renewalOpportunities.isEmpty())
        {
            System.EnqueueJob(new bg_Opportunity_QueueableHelper(renewalOpportunities));
        
        }
    }

    /*
        Called from after update trigger.
        Checks if an opportunity has been update to indicate it needs pricebook approval and submits it if it does.
    */
    public static void checkOpportunitiesForApproval(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities){
        List<Opportunity> oppsToSubmit = new List<Opportunity>();
        for (Opportunity opp : opportunities)
        {
            if(!Approval.isLocked(opp) && opp.Pricebook_Approval_Required__c && !oldOpportunities.get(opp.Id).Pricebook_Approval_Required__c)
            {
                oppsToSubmit.add(opp);
            }
        }
        if (!oppsToSubmit.isEmpty())
        {
            List<Approval.ProcessResult> result = submitOpportunitiesForApproval(oppsToSubmit);
        }
    }

    /*
        Create the approval process for each of the opportunities that need approving.
    */
    public static List<Approval.ProcessResult> submitOpportunitiesForApproval(List<Opportunity> opportunitiesForApproval){
        List<Approval.ProcessSubmitRequest> reqs = new List<Approval.ProcessSubmitRequest>();
        for (Opportunity oppToSubmit : opportunitiesForApproval)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('The related account\'s Pricebook has been changed. Please review this change, and this opportunity, and inform the Sales Person of how they should proceed with this sale.');
            req.setObjectId(oppToSubmit.Id);
            req.setProcessDefinitionNameOrId('Pricebook_Change_Approval');
            req.setSubmitterId(oppToSubmit.OwnerId);
            reqs.add(req);
            system.debug('reqs: ' + reqs);
        }
        return null;//Approval.process(reqs);
    }

    /*
        Called from after update trigger.
        If a redution has been received from FileMaker, create a reduction line item for the associated Opportunity.
    */
    public static void checkForReduction(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities){
        Map<String,Id> opportunityTypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSRecordTypeId = opportunityTypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);
        List<Opportunity> oppsToReduce = new List<Opportunity>();
        List<Id> pricebookIds = new List<Id>();
        for (Opportunity opp : opportunities)
        {
            Boolean isQMSRecordType = opp.RecordTypeId == QMSRecordTypeId;
            Boolean isChangedToReduction = opp.Is_Reduction__c && !oldOpportunities.get(opp.Id).Is_Reduction__c;

            if(isChangedToReduction && isQMSRecordType)
            {
                oppsToReduce.add(opp);
                pricebookIds.add(opp.Pricebook2Id);
            }
        }
        if (!oppsToReduce.isEmpty())
        {
            createReductionLineItems(oppsToReduce, pricebookIds);
        }
    }

    /*
        Create a reduction line item for the Opportunities
    */
    public static void createReductionLineItems(List<Opportunity> opportunities, List<Id> pricebookIds){
        List<OpportunityLineItem> reductionLineItems = new List<OpportunityLineItem>();
        List<Opportunity> oppsToReset = new List<Opportunity>();
        Map<Id, PricebookEntry> reductionMap = getReductionEntries(pricebookIds);
        for (Opportunity opp : opportunities)
        {
            Boolean isReductionBiggerThanZero = opp.Reduction_Amount__c != null && opp.Reduction_Amount__c > 0;
            Boolean isReductionPresent = reductionMap.containsKey(opp.Pricebook2Id);
            if(isReductionBiggerThanZero && isReductionPresent)
            {
                reductionLineItems.add(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = reductionMap.get(opp.Pricebook2Id).Id,
                                                                            UnitPrice = (0 - opp.Reduction_Amount__c), Quantity = 1));
            }
            
            oppsToReset.add(new Opportunity(Id = opp.Id, Is_Reduction__c = false, Reduction_Amount__C = 0));
        }

        if (!reductionLineItems.isEmpty())
        {
            insert reductionLineItems;
        }

        if(!oppsToReset.isEmpty())
        {
            update oppsToReset;
        }
    }

    /*
        Get all of the reduction price book entries for each of the required pricebooks.
    */
    public static Map<Id, PricebookEntry> getReductionEntries(List<Id> pricebookIds){
        Map<Id, PricebookEntry> reductionMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry reductionPBE : [select Id, Pricebook2Id, UnitPrice from PricebookEntry where Product2.Name = :bg_Constants.REDUCTION_PRODUCT_TYPE])
        {
            reductionMap.put(reductionPBE.Pricebook2Id, reductionPBE);
        }
        return reductionMap;
    }

    /*
        Check the account revenue is valid and that the opportunity has a term on insert
    */
    public static void setPricebook(List<Opportunity> opportunities){
        List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
        List<Opportunity> CitationOppsToProcess = new list<Opportunity>() ;
        Set<Id> accountIds = new Set<Id>();

        Map<String,Id> opptypes = bg_RecordType_Utils.GetRecordTypeIdsByDeveloperName(Opportunity.SObjectType);
        Id QMSOppRecordTypeId = opptypes.get(bg_Constants.QMS_OPPORTUNITY_RECORDTYPE);
        Id QMSRenewalOppRecordTypeId = opptypes.get(DataConstants.OPPORTUNITY_QMS_RENEWAL_RECORDTYPE_NAME);
        
        List<Pricebook2> pricebooks = [SELECT Id, Name, Annual_Turnover_Maximum__c, Annual_Turnover_Minimum__c, Term__c FROM Pricebook2 Where IsActive = true];
        
        //SPB-918
        //Pricebook2 referralsPricebook = new pricebook2() ;
        List<String> CitationRecTypeNames = new List<String>();
        CitationRecTypeNames.addAll(System.Label.Citation_Opportunity_Record_Types.Split(','));
        List<id> rt = new List<id>() ;

        try {
            for(recordtype rtl : [select id from recordtype where name IN :CitationRecTypeNames]){
               rt.add(rtl.id); 
            }
        }
        catch (Exception ex) {
            
        }

        for (Opportunity opportunity : opportunities)
        {
            /* build list of Citation Opportunities */
            if(rt != NULL && rt.contains(Opportunity.RecordTypeId)) {
                CitationOppsToProcess.add(opportunity) ;
            }
    
            //Check term has been entered upon insert for all QMS Opps
            if (opportunity.Term__c != null &&
            ( opportunity.RecordTypeId == QMSOppRecordTypeId || opportunity.RecordTypeId == QMSRenewalOppRecordTypeId ))
            {
                opportunitiesToProcess.add(opportunity);
                accountIds.add(opportunity.AccountId);
            }
            else if(opportunity.Term__c == null &&
                opportunity.RecordTypeId == QMSOppRecordTypeId)
            {
                opportunity.Term__c.addError(Label.QMS_Invalid_Term_For_Opportunity);
            }
        }

        if (!opportunitiesToProcess.isEmpty())
        {
            List<String> userdids = new List<String>();
            userdids = System.Label.QMSCPQUsers.split(',');
            
            if((System.Label.EnableQMSCPQ.toLowerCase() == 'true') || (!userdids.isEmpty() && userdids.contains(userInfo.getUserId())) ){
                UpdateOppWithQMSPB(opportunitiesToProcess);
            } else {
                setPricebookOnOpp(opportunitiesToProcess, accountIds);
            }
        }

        if(!CitationOppsToProcess.isEmpty()) {
            SetPricebookOnCitationOpps(CitationOppsToProcess) ;
        }
    }
    
    
    public static void SetPricebookOnCitationOpps(List<Opportunity> OpportunitiesToProcess) {
        List<Pricebook2> pricebooks = [SELECT Id, Name, Annual_Turnover_Maximum__c, Annual_Turnover_Minimum__c, Term__c FROM Pricebook2 Where IsActive = true AND name LIKE '%CPQ%' order by annual_turnover_maximum__c,  name];
        
        set<id> AccountIdSet = new set<id>() ;
        for(Opportunity o : OpportunitiesToProcess) {
            AccountIdSet.add(o.accountid) ;
        }
        list<account> AccountList = [select id,AnnualRevenue from account where id in :AccountIDSet] ;
        map<id,account> AccountMap = new map<id,account>(AccountList) ;
        for(Opportunity o : OpportunitiesToProcess) {
            try 
            {
                o.PriceBook2Id = GetPricebookForCitationOpp(Accountmap.get(o.accountid),pricebooks) ;
            }
            catch (Exception ex) {
                
            }
            
        }
    }
    
    public static decimal isNull(decimal amnt) {
        if(amnt == null) {
            return 0 ;
        }
        else
        {
            return amnt ;
        }
    }
    
    
     public static Id GetPricebookForCitationOpp(Account account, List<Pricebook2> pricebooks){
        Id PricebookID = null ;
       
        for (Pricebook2 pricebook : pricebooks)
        {
            Boolean revenueHigherThanMin = isnull(account.AnnualRevenue) >= pricebook.Annual_Turnover_Minimum__c;
            Boolean revenueLowerThanMax = isnull(account.AnnualRevenue) <= pricebook.Annual_Turnover_Maximum__c;
            if (revenueHigherThanMin && revenueLowerThanMax)
            {
                PricebookID = pricebook.Id;
               
            }
        }
        return PricebookID ;
    }

     

    /*
        set the pricebook to the correct value based on revenue and term.
    */
    public static void setPricebookOnOpp(List<Opportunity> opportunitiesToProcess,Set<Id> accountIds)
    {
        List<Pricebook2> pricebooks = [SELECT Id, Name, Annual_Turnover_Maximum__c, Annual_Turnover_Minimum__c, Term__c FROM Pricebook2 Where IsActive = true AND name LIKE '%Term%' ];
        
        //Query accounts and store in map to check that a valid Revenue is present.
        Map<Id, Account> accountsByIdMap = new Map<Id, Account>([Select Id, Name, AnnualRevenue From Account Where Id IN :accountIds]);
        Map<Id,Pricebook2> PricebookMap = new map<ID,Pricebook2>(pricebooks) ;


        for(Opportunity opportunity : opportunitiesToProcess)
        {
            if( Opportunity.Pricebook2Id != null && pricebookMap.values().size() > 0 && PricebookMap.get(opportunity.PriceBook2Id) != null &&   PricebookMap.get(opportunity.PriceBook2Id).Name.indexOf('Connect') != -1) 
                    { 
                    }
                 else {            
                        if(pricebooks.isEmpty())
                        {
                            opportunity.addError(Label.QMS_No_Valid_Pricebook);
                            continue;
                        } // end if pricebook empty
                        //Get account from map and check that the account has a valid revenue.
                        Account account = accountsByIdMap.get(opportunity.AccountId);
                        if (account == null || 
                                account.AnnualRevenue == null)
                            {
                                opportunity.addError(Label.QMS_No_Revenue_On_Account);
                            }
                            else
                            {
                            //if the account has a valid revenue, find the correct pricebook based on the term and revenue.
                                Boolean oppportunityProcessed = false;
                                for (Pricebook2 pricebook : pricebooks)
                                {
                                    Boolean revenueHigherThanMin = isnull(account.AnnualRevenue) >= pricebook.Annual_Turnover_Minimum__c;
                                    Boolean revenueLowerThanMax = isnull(account.AnnualRevenue) <= pricebook.Annual_Turnover_Maximum__c;
                                    Boolean termEqualsPricebook = opportunity.Term__c == pricebook.Term__c;
                
                                    if (revenueHigherThanMin && 
                                        revenueLowerThanMax && 
                                        termEqualsPricebook)
                                    {
                                        opportunity.PriceBook2Id = pricebook.Id;
                                        oppportunityProcessed = true;
                                    }
                                } // end for pricebook
                            
                                if (!oppportunityProcessed)
                                {
                                    opportunity.addError(Label.QMS_Invalid_Revenue);
                                } // end if             
                            
                            } // end else
                 }
                    
        } // end for opportunity
        
    } // end method

    public static void UpdateOppWithQMSPB(List<Opportunity> oppList){
         Id qmsPBId = [Select id From  PriceBook2 where Name=:DataConstants.PRICEBOOK_QMS_NAME].id;
             for(Opportunity opp:oppList){
                     system.debug(opp.Pricebook2Id+'pbid'+qmsPBId);
                     opp.Pricebook2Id =qmsPBId;
             }
    }  
}