/**********************************************************************
 * Controller for the Create Agreement VisualForce page.
 * 
 * Updates the Account and Opportunity Object and creates the Contract
 * 
 * Generates a callout to the echosign application using the newly created 
 * Contract details.
 *
 * Author: James Garford(BrightGen.com)
 * Created: 15-12-2014
 * Changes:
***********************************************************************/
public with sharing class bg_CreateAgreement {
	
	public Opportunity opportunity {get; set;}
	public List<Account> accList{get;set;}
	public Account account {get; set;}
	public Contract contract {get; set;}
	public boolean smallBusinessPackage {get; set;}
	
	public list<String> templateIdsToUse = new list<String>();
	public map<String, Integer> templateIdsThatMatchCritera = new map<String, Integer>();
	
	private static final String PAGE_MESSAGE_NO_TEMPLATE_MATCH  = 'No EchoSign templates have been identified for the Contract criteria provided';
	private static final String PAGE_MESSAGE_MORE_THAN_ONE_TEMPLATE_MATCH  = 'More that one EchoSign template has been identified for the Contract criteria provided';
	private static final String OPPORTUNITY_RT_SMALL_BUSINESS_NAME = 'Small Business Package';
	private static final String OPPORTUNITY_RT_STANDARD_NAME = 'Default Citation Opportunity';
	private static final String CONTRACT_RT_SMALL_BUSINESS_NAME = 'Small Business Package';
	private static final String CONTRACT_RT_STANDARD_NAME = 'Standard Contract';
	private static final String ECHOSIGN_CONFIGURATION = 'Create Agreement';
	private static final String OPPORTUNITY_STATUS_ERROR = 'The Opportunity stage required must be';
	private static final String AGREEMENT_TYPE_TEMPLATE_COMBINED = 'Combined';
	private static final String AGREEMENT_TYPE_TEMPLATE_PEL = 'PEL';
	private static final String AGREEMENT_TYPE_TEMPLATE_HandS = 'H&S';
	
	private static final String RENEWAL_TYPE_AUTO = 'Auto';
	private static final String AGREEMENT_TYPE_ECHOSIGN = 'EchoSign';
	
	private bg_RecordTypeMap contractRecordTypeMap {get; set;}
	private bg_RecordTypeMap opportunityRecordTypeMap {get; set;}
	
	private map<String, EchoSign_Agreement_Criteria__c> echoSignAgreementCriteria = new map<String, EchoSign_Agreement_Criteria__c>();
	private EchoSign_Configuration__c echoSignConfiguration = new EchoSign_Configuration__c();  
	
	
	public bg_CreateAgreement(ApexPages.StandardController stdCtrl){
        
        system.debug('bg_CreateAgreement StandardController ['+ stdCtrl +']');
        
        //Get EchoSign configuration custom settings         
        echoSignConfiguration = EchoSign_Configuration__c.getInstance(ECHOSIGN_CONFIGURATION);
        
        echoSignAgreementCriteria = EchoSign_Agreement_Criteria__c.getAll();       
        
        contractRecordTypeMap = new bg_RecordTypeMap('Contract');
        opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');
        
        system.debug('Echo Sign Configuration Details ['+ echoSignAgreementCriteria +']');
        
        //Get Opportunity record that's passed in via the 'Create Agreement' button click 
        this.opportunity = (Opportunity)stdCtrl.getRecord();        
        system.debug('The Opportunity used for Agreement  ['+ this.opportunity+']');
        
        //Get Account information from the passed in Opportunity by creating a SOQL query string
        String queryString = 'select id';
        //Only get the Account Fields that we are interested in, defined by the Fields set
        for(Schema.FieldSetMember fld :SObjectType.Account.FieldSets.Create_Agreement.getFields()) {
        	queryString += ', ' + fld.getFieldPath();
        }
        
        system.debug('Opportunity Account ID for Agreement ['+opportunity.AccountId+']');
        queryString += ' from Account where ID = \'' + opportunity.AccountId +'\' limit 1';
        system.debug('Query String to select Account for Agreement ['+queryString+']');        
        
        //DML Call out to select the Account
        this.accList = Database.query(queryString);
        
        //Only interested in the first Account returned as limiting the select statement to 1 
        this.account = this.accList[0];        
        system.debug('The Account used for Agreement  ['+ this.account+']');
      
        //Create a new Contract record to be used later 
    	this.contract = new Contract();
    	system.debug('About to generate new Contract details ['+contract+']');  	
    	createContract();
    	system.debug('Contract details ['+contract+']');  	
    }
        
    public PageReference createAgreement() {
    	
    	system.debug('createAgreement Method');     	
    	
    	
    	if (validateAccountDetails() && updateAccountDetails() && validateOpportunityDetails() && updateOpportunityDetails() && validateContractDetails() && updateContractDetails()) {
	    	//callout to echo sign passing correct URL and template based on opportunity record type and other criteria.	    	
	    	
	    	system.debug('About to generate Callout'); 
	    	string echosignTemplateId = generateEchoSignCallOutURL();
	    	system.debug('echosign Callout TemplateId ['+echosignTemplateId+']');
	        
	        if (echosignTemplateId != null) {
	       		string echosignCalloutURL = echoSignConfiguration.EchoSign_URL__c + contract.Id + '&templateId=' + echosignTemplateId; 
	        	system.debug('echosign Callout CalloutURL ['+echosignCalloutURL+']');
		        PageReference echoSignPage = new PageReference(echosignCalloutURL);
		        echoSignPage.setRedirect(true);
		        return echoSignPage;
    		} else {   			
	        	return null;
	        }
	        	      	       
    	} else {
    		return null;
    	}
    }
    
    private boolean validateAccountDetails () {
    	//Have we got any specific create agreement validation that we want to impose when updating the account record  
    	return true;
    }
    
    private boolean validateOpportunityDetails () {
    	//Have we got any specific create agreement validation that we want to impose when updating the Opportunity record 
    	if (opportunity.StageName != echoSignConfiguration.Opportunity_Stage_Required__c) {    		
    		ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,OPPORTUNITY_STATUS_ERROR + ' ' + echoSignConfiguration.Opportunity_Stage_Required__c);
        	ApexPages.addMessage(pageMessage);
    		return false;
    	} else {
    		return true;
    	}
    }
    
    private boolean validateContractDetails () {
    	//Have we got any specific create agreement validation that we want to impose when creating the Contract record 
    	return true;
    }
    
    private boolean updateAccountDetails () {
	    //Lets try to update the account record
	    try{
	        system.debug('Account upsert details ['+account+']');
	        upsert account;
	        return true;
	    } catch(DmlException ex){
	        system.debug('Account upsert exception ['+ex+']');
	        ApexPages.addMessages(ex);
	        return false;
	    }
    }
    
    private boolean updateOpportunityDetails () {   
	    //Lets try to update the opporunity record
	    try{
	    	system.debug('Oppotrunity upsert details ['+opportunity+']');
	    	//If Contract details supercede opportunity details update with new values
	    	/*
	    	if (contract.StartDate != null) {
	    	  opportunity.Deal_Start_Date__c = contract.StartDate;	
	    	}
	    	*/		    	
	    	opportunity.Amount = contract.total_Contract_Value__c;
	    	if (contract.Agreement_Template_Type__c != null && OPPORTUNITY_RT_SMALL_BUSINESS_NAME != opportunityRecordTypeMap.getNameFromID(opportunity.RecordTypeId)) {
	    		opportunity.Deal_Type__c = contract.Agreement_Template_Type__c; 
	    	}
	    	//Make sure we haven't got a null value in the contract.ContractTerm field as we need to conver this to a number 
	    	if  (contract.ContractTerm != null) {
	    		opportunity.Contract_Length_Mths__c = String.ValueOf(contract.ContractTerm); 
	    	}
	    	opportunity.Payment_Period__c = contract.Payment_Period__c; 
	    	//Check to see if we are not dealing with a small business package. if so update the opportunity deposit with inital payment value. 
	    	if (OPPORTUNITY_RT_SMALL_BUSINESS_NAME != opportunityRecordTypeMap.getNameFromID(opportunity.RecordTypeId)) {
		    	opportunity.Deposit__c = contract.Initial_Payment2__c;
	    	}	    	 	
	        upsert opportunity;
	        return true;
	    } catch(DmlException ex){
	    	system.debug('Oppotrunity upsert exception ['+ex+']');
	        ApexPages.addMessages(ex);
	        return false;
	    } 	       	    	
    }
    
    private boolean updateContractDetails () {    	
	    //Lets try to update the contract record
	    try{
	    	system.debug('Contract Insert details ['+contract+']');
	    	contract.AccountId = account.id;	    	
	    	contract.BillingStreet = account.BillingStreet;
			contract.BillingCity = account.BillingCity;
			contract.BillingState = account.BillingState;
			contract.BillingCountry = account.BillingCountry;
			contract.BillingPostalCode = account.BillingPostalCode;

			Boolean fraTotalFieldsEqualZero = ( opportunity.FRA_Total_Amount__c != null && opportunity.FRA_Annual_Repeat_Total_Sites__c ==0 && opportunity.Total_Sites_FRA__c == 0 && opportunity.FRA_Total_Amount__c == 0 ) || ( opportunity.FRA_Total_Amount__c == null );
            // FRA Fields
			if(fraTotalFieldsEqualZero)
			{
				contract.Services_Taken_FRA__c = FALSE;
			}
			else
			{
				contract.Services_Taken_FRA__c = TRUE;
			}

			Boolean servicesTaken = contract.Services_Taken_FRA__c == TRUE || opportunity.XCD_HS_total__c != null || opportunity.XCD_HR_total__c != null ||
			(opportunity.Consultancy_Days_H_S_Days__c != null && opportunity.Consultancy_Days_H_S_Days__c != 0) ||
			(opportunity.Consultancy_Days_HR_Full_Days__c != null && opportunity.Consultancy_Days_HR_Full_Days__c != 0) ||
			(opportunity.Consultancy_Days_H_S_Full_Days__c != null && opportunity.Consultancy_Days_H_S_Full_Days__c != 0) ||
			(opportunity.Consultancy_Days_HR_Days__c != null && opportunity.Consultancy_Days_HR_Days__c != 0) ||
			opportunity.Care_Policies_and_Procedures__c != null || opportunity.XCD_PP_total__c != null;

			if(servicesTaken)
			{
				contract.Services_Taken_Add_On__c = TRUE;
			}
			else
			{
				contract.Services_Taken_Add_On__c = FALSE;	
			}

			contract.XCD_HS_total__c = opportunity.XCD_HS_total__c;
			contract.XCD_HR_total__c = opportunity.XCD_HR_total__c;
			contract.Consultancy_Days_H_S_Days__c = opportunity.Consultancy_Days_H_S_Days__c;
			contract.Consultancy_Days_HR_Full_Days__c = opportunity.Consultancy_Days_HR_Full_Days__c;
			contract.Consultancy_Days_H_S_Full_Days__c = opportunity.Consultancy_Days_H_S_Full_Days__c;
			contract.Consultancy_Days_HR_Days__c = opportunity.Consultancy_Days_HR_Days__c;
			contract.Care_Policies_and_Procedures__c = opportunity.Care_Policies_and_Procedures__c;
			contract.XCD_PP_total__c = opportunity.XCD_PP_total__c;

			// contract.Services_Taken_FRA__c = opportunity.FRA_Product_Interest__c;
			contract.FRA_Contract_Value__c = opportunity.FRA_Total_Amount__c;
			contract.FRA_Sites_Day__c = opportunity.FRA_Sites_Day__c;
			contract.FRA_Sites_Full_Day__c = opportunity.FRA_Sites_Full_Day__c;

			contract.FRA_Annual_Repeat_Sites_Day__c = opportunity.FRA_Annual_Repeat_Sites_Day__c;
			contract.FRA_Annual_Repeat_Sites_Full_Day__c = opportunity.FRA_Annual_Repeat_Sites_Full_Day__c;

	    	if (opportunity.Deal_Start_Date__c != null) {
	    	  contract.StartDate = opportunity.Deal_Start_Date__c;	
	    	}	    	
	    	upsert contract;
	    	return true;
	    } catch(DmlException ex){
	    	system.debug('Contract Insert exception ['+ex+']');
	        ApexPages.addMessages(ex);
	        return false;
	    }    	
    }
    
    
    
    private void createContract() {    	   	
    	//Now we can create the contract with the values passed through from the Opportunity and Account
    	system.debug('Opportunity record details to use for create contract ['+opportunity+']');
    	this.contract.RecordTypeId = contractRecordType();
    	this.contract.Name = opportunity.Name;
    	this.contract.StartDate = opportunity.Deal_Start_Date__c;
    	if  (opportunity.Contract_Length_Mths__c != null) {
    		this.contract.ContractTerm = Integer.valueOf(opportunity.Contract_Length_Mths__c);
    	}
    	this.contract.BillingStreet = account.BillingStreet;
		this.contract.BillingCity = account.BillingCity;
		this.contract.BillingState = account.BillingState;
		this.contract.BillingCountry = account.BillingCountry;
		this.contract.BillingPostalCode = account.BillingPostalCode;	
    	this.contract.AccountId = account.id;
    	this.contract.Source_Opportunity__c = opportunity.id; 
    	this.contract.Business_Type__c = opportunity.Type;
    	this.contract.Contract_Value__c = opportunity.Core_Compliance_TCV__c;
    	this.contract.Payment_Period__c = opportunity.Payment_Period__c;    	
    	this.contract.CompanySignedId = opportunity.OwnerId;

    	//FRA Fields
    	if(opportunity.amount  != null)
    	{
    		this.contract.Total_Contract_Value__c = opportunity.amount;
    	}
    	
    	//Check to seee if we are dealing with a Small Business Package or a Standard contract and set values accordingly 
    	if (OPPORTUNITY_RT_SMALL_BUSINESS_NAME == opportunityRecordTypeMap.getNameFromID(opportunity.RecordTypeId)) {
	    	this.contract.Services_Taken_HS__c = true;
	    	this.contract.Services_Taken_EL__c = true;
    	} else {
    		this.contract.Initial_Payment2__c = opportunity.Deposit__c; 
    	}
    	
    	if (opportunity.Deal_Type__c != null) {
    		this.contract.Agreement_Template_Type__c = opportunity.Deal_Type__c;
    	} else {
	    	if (this.contract.Services_Taken_HS__c & this.contract.Services_Taken_EL__c) {
	    		this.contract.Agreement_Template_Type__c = AGREEMENT_TYPE_TEMPLATE_COMBINED; 
	    	} else if (this.contract.Services_Taken_HS__c) {
	    		this.contract.Agreement_Template_Type__c = AGREEMENT_TYPE_TEMPLATE_HandS; 
	    	} else if (this.contract.Services_Taken_EL__c) {
	    		this.contract.Agreement_Template_Type__c = AGREEMENT_TYPE_TEMPLATE_PEL; 
	    	}
    	}
    	
    	this.contract.Affinity__c = opportunity.Affinity_Industry_Type__c;
    	
    	//All Echosign agreements will be created with the static values RENEWAL_TYPE_AUTO and AGREEMENT_TYPE_ECHOSIGN 
    	this.contract.Renewal_Type__c = RENEWAL_TYPE_AUTO;
    	this.contract.Agreement_Type__c = AGREEMENT_TYPE_ECHOSIGN;    	
    	  	
    }
        
    private id contractRecordType () {
    	//Lets decide what contract record type to create based on the opportunity
    	system.debug('opportunity record type name ['+opportunityRecordTypeMap.getNameFromID(opportunity.RecordTypeId)+']');
    	if (OPPORTUNITY_RT_SMALL_BUSINESS_NAME == opportunityRecordTypeMap.getNameFromID(opportunity.RecordTypeId)) {
    		system.debug('Contract small business recordtype ID ['+contractRecordTypeMap.getIdFromName(CONTRACT_RT_SMALL_BUSINESS_NAME)+']');
    		smallBusinessPackage = true;
    		return contractRecordTypeMap.getIdFromName(CONTRACT_RT_SMALL_BUSINESS_NAME);		
    	} else {
    		system.debug('Contract standard recordtype ID ['+contractRecordTypeMap.getIdFromName(CONTRACT_RT_STANDARD_NAME)+']');
    		smallBusinessPackage = false;
    		return contractRecordTypeMap.getIdFromName(CONTRACT_RT_STANDARD_NAME);   		
    	}
    }
    
    private String generateEchoSignCallOutURL () {
    	
    	list<Contract> contractList = new list<Contract>();
    	Contract agreementContract = new Contract(); 
    	
    	//select Contract values that can be used for the EchoSign Criteria    	
    	String queryString = 'select id';
        //Only get the Contract Fields that we are interested in, defined by the Fields set
        for(Schema.FieldSetMember echosignCriteriaFieldSet :SObjectType.Contract.FieldSets.EchoSign_Criteria.getFields())
        {
        	queryString += ', ' + echosignCriteriaFieldSet.getFieldPath();
        }
        
        // system.debug('Contract ID be submitted to EchoSign ['+contract.Id+']');
        queryString += ' from Contract where ID = \'' + contract.Id +'\' limit 1';
              
        system.debug('Query String to select Contract for submission to EchoSign ['+queryString+']');        
        
        //DML Call out to select the Contract
        contractList = Database.query(queryString);
                
        //Only interested in the first Contract returned as limiting the select statement to 1 
        agreementContract = contractList[0];
                
        // system.debug('The Contract used for submission to EchoSign  ['+ agreementContract+']');
        
        List<String> accessibleFields = new List<String>();
        
        Map<String, Schema.SobjectField> agreementContractFieldMap = agreementContract.getSObjectType().getDescribe().fields.getMap();

        Map<String, List<EchoSign_Agreement_Criteria__c>> echoMap = new Map<String, List<EchoSign_Agreement_Criteria__c>>();
		Map<String, Integer> templateIdCount = new Map<String, Integer>();
		
		for(EchoSign_Agreement_Criteria__c echoRecord : [Select Id, Criteria_Field__c, Template_ID__c, Criteria_Value__c From EchoSign_Agreement_Criteria__c] )
		{

			if(echoMap.containsKey(echoRecord.Criteria_Field__c))
			{
				List<EchoSign_Agreement_Criteria__c> echoSignConfiguration = echoMap.get(echoRecord.Criteria_Field__c);
				echoSignConfiguration.add(echoRecord);
				echoMap.put(echoRecord.Criteria_Field__c, echoSignConfiguration);
			}
			else
			{
				List<EchoSign_Agreement_Criteria__c> echoSignConfiguration = new List<EchoSign_Agreement_Criteria__c>();
				echoSignConfiguration.add(echoRecord);
				echoMap.put(echoRecord.Criteria_Field__c, echoSignConfiguration);
			}
			
			if(templateIdCount.containsKey(echoRecord.Template_ID__c))
			{
				Integer countValue = templateIdCount.get(echoRecord.Template_ID__c) + 1;
				templateIdCount.put(echoRecord.Template_ID__c, countValue);
			}
			else
			{
				templateIdCount.put(echoRecord.Template_ID__c, 1);
			}
		}
		system.debug('Brightgen agreementContract [' + agreementContract + ']');

		system.debug('Brightgen echoMap [' + echoMap + ']');
		
		system.debug('Brightgen templateIdCount [' + templateIdCount + ']');
		
		system.debug('field Name Value [' + echoMap.keyset() + ']');
		
		List<String> templateId = new List<String>();
		
		for(String fieldName : Contract.getSObjectType().getDescribe().fields.getMap().KeySet())
		{
			// system.debug('contract field Name  [' + fieldName + ']');	
			if(echoMap.containsKey(fieldName))
			{
				for(EchoSign_Agreement_Criteria__c value : echoMap.get(fieldName))
				{
					system.debug('Brightgen agreement contract field name [' + agreementContract.get(fieldName) + '] criteria value ['+value.Criteria_Value__c+']');					
					if(agreementContract.get(fieldName) != null && String.valueOf(agreementContract.get(fieldName)).equals(value.Criteria_Value__c))
					{
						templateId.add(value.Template_ID__c);						
					}
				}
			}
		}
				
		system.debug('Brightgen template Id [' + templateId + ']');
		
		Map<String, Integer> templateActualIdCount = new Map<String, Integer>();
		
		for(String templateIdRecord : templateId)
		{
			if(templateActualIdCount.containsKey(templateIdRecord))
			{
				Integer countOfIds = templateActualIdCount.get(templateIdRecord) + 1;
				templateActualIdCount.put(templateIdRecord, countOfIds);
			}
			else
			{
				templateActualIdCount.put(templateIdRecord, 1);
			}
		}
		
		system.debug('Brightgen template Actual Id Count [' + templateActualIdCount + ']');
		
		system.debug('Brightgen template template Id Count [' + templateIdCount + ']');
		
		templateIdsThatMatchCritera = new Map<String, Integer>();
		
		for(String templateIdRecord : templateActualIdCount.keySet())
		{
			if(templateIdCount.containsKey(templateIdRecord) && templateActualIdCount.get(templateIdRecord) == templateIdCount.get(templateIdRecord))
			{		
				templateIdsThatMatchCritera.put(templateIdRecord, templateActualIdCount.get(templateIdRecord));
			}
		}
		
		system.debug('Brightgen template Ids That Match Critera and count of criteria [' + templateIdsThatMatchCritera + ']');
		
		//Now we want to get the templates that have the highest amount of matches based on the number of criteria used in our custom settings
		Integer highestCoutOfMatches = 0;
		
		templateIdsToUse = new List<String>();
		
		for(String templateIdRecordMatching : templateIdsThatMatchCritera.keySet())
		{			
			//lets loop around the matched records and get the agreement that matches the most criteria values
			if(templateIdsThatMatchCritera.get(templateIdRecordMatching) == highestCoutOfMatches)
			{		
				//if the criteria count maches the previous highest count add the template id
				system.debug('Found a template that matches the highest total of criteria so far ['+templateIdRecordMatching+'] ');
				templateIdsToUse.add(templateIdRecordMatching);
			}
			else if (templateIdsThatMatchCritera.get(templateIdRecordMatching) > highestCoutOfMatches)
			{
				system.debug('About to add our new template leader that matches more criteria ['+templateIdRecordMatching+'] ');
				//if the criteria count is greater than the previous highest count wipe the list and add the best match template id
				templateIdsToUse = new List<String>();
				templateIdsToUse.add(templateIdRecordMatching);
				highestCoutOfMatches = templateIdsThatMatchCritera.get(templateIdRecordMatching);
			}
		}

		system.debug('Brightgen template Ids To Use [' + templateIdsToUse + ']');
        //Now we will decide what Echosign template to use
        if (templateIdsToUse.IsEmpty())
        {
        	//This means that the custom settings criteria has not been matched to an Echosign Agreement using the Contract details created
        	ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,PAGE_MESSAGE_NO_TEMPLATE_MATCH);
        	ApexPages.addMessage(pageMessage);
        	return null;
        } else if (templateIdsToUse.Size() > 1)
        {
        	//This means that the custom settings criteria has more than one Echosign Agreement using the Contract details created
        	ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,PAGE_MESSAGE_MORE_THAN_ONE_TEMPLATE_MATCH + ' [' + templateIdsToUse + ']');
        	ApexPages.addMessage(pageMessage);
        	return null;
        }
        else
        {  
    		return templateIdsToUse[0];
        }
    }

}