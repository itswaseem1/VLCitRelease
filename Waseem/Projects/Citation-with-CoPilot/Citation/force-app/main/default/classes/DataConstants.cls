public with sharing class DataConstants {
 
  //** ACCOUNT SEGMENT **
    public static final String ACCOUNT_SEGMENT_SILVER  = 'Silver';
    public static final String ACCOUNT_SEGMENT_GOLD  = 'Gold';
    public static final String ACCOUNT_SEGMENT_GOLD_PLUS = 'Glod+';
    public static final String ACCOUNT_SEGMENT_PLATINUM = 'Platinum';
    public static final String ACCOUNT_SEGMENT_BRONZE  = 'Bronze';
    public static final String ACCOUNT_STATUS_INACTIVE  = 'InActive';
    public static final String ACCOUNT_STATUS_ACTIVE  = 'Active';
    public static final String ACCOUNT_STATUS_RESAON_NONRENEWAL  = 'Non Renewal';
    public static final String ACCOUNT_STATUS_RESAON_ONCLIENTREQUEST='On Client Request';
    public static final String ACCOUNT_STATUS_RESAON_ACCOUNT_OVERDUE='Account Overdue';
    public static final String ACCOUNT_PSTATUS_PURGATORYAM ='Purgatory-AM';

    public static final String ACCOUNT_TYPE_CLIENT = 'Client';

    //** OPPORTUNITY **
    public static final String RENEWAL_AUTO_OPPORTUNITY_RECORDTYPE_NAME = 'Renewal / Retention Opportunity - Auto';
    public static final String RENEWAL_NON_AUTO_OPPORTUNITY_RECORDTYPE_NAME = 'Renewal / Retention Opportunity - Non-Auto';

    public static final String OPPORTUNITY_QMS_RECORDTYPE_NAME = 'QMS';
    public static final String OPPORTUNITY_QMS_RENEWAL_RECORDTYPE_NAME = 'QMS_Renewal';
    public static final String OPPORTUNITY_iHASCO_RECORDTYPENAME  = 'IHASCO';
    public static final String OPPORTUNITY_ELAS_RENEWAL_RECORDTYPE_NAME='ELAS Renewal / Retention Opportunity - Non-Auto';
    //** CONTRACT **
    public static final String NBS_CONTRACT_RECORDTYPE_NAME = 'NBS Contract';
    public static final String SBP_CONTRACT_RECORDTYPE_NAME = 'Small Business Package';
    public static final String STANDARD_CONTRACT_RECORDTYPE_NAME = 'Standard Contract';
    public static final String CONTRACT_QMS_RECORDTYPE_NAME = 'QMS';
    
    //** CONTRACT_RENEWAL_TYPE**
    public static final String AUTO_RENEWAL_TYPE_CONTRACT = 'Auto';
    public static final String NON_AUTO_RENEWAL_TYPE_CONTRACT = 'Non-Auto';

    //** CONTRACT_STATUS**
    public static final String CONTRACT_STATUS_ACTIVE= 'Active';
    public static final String CONTRACT_STATUS_PENDING_START= 'Pending Start';
    public static final String CONTRACT_STATUS_DRAFT= 'Draft';
    public static final Integer CONTRACT_SINGREQ_ACV_Value= 10000;
    public static final String CONTRACT_STATUS_PENDING_ECHOSIGN_PROCESS = 'In EchoSign Process';
    
    //** CONTRACT_AGREEMENT_TYPE**
    public static final String CONTRACT_AGREEMENT_TYPE_COMBINED = 'Combined';
    public static final String CONTRACT_AGREEMENT_TYPE_HS = 'H&S';
    public static final String CONTRACT_AGREEMENT_TYPE_PEL = 'PEL'; 
    public static final String CONTRACT_AGREEMENT_TYPE_ECOSIGN = 'EchoSign'; 

    // Opportunity StageNames
    public static final String OPPORUNITY_STAGE_RENEWALDUE = 'Renewal Contact Due';
    public static final String OPPORUNITY_STAGE_PROVISIONAL_AGREEMENT = 'Provisional Agreement';
    
    // Opportunity ForecastCategoryName
    public static final String OPPORUNITY_FORCAST_CATEGORY_NAME = 'Pipeline';

    // Opportunity Types
    public static final String RENEWAL_OPPORTUNITY_TYPE = 'Renewal';
    
    //CPQ Quote recordType
    public static final String Quote_QMS_RECORDTYPENAME = 'QMS Quote Standard';

    // OpportunityTeams
    public static final String OPPORTUNITY_ACCESS_LEVEL_READ_WRITE = 'Edit';

    // Citation Core products
    public static final String EL_AND_HR_COMPLIANCE_SERVICE = 'PEL';
    public static final String H_AND_S_COMPLIANCE_SERVICE = 'HS-Compliance';
    public static final String DUAL_SERVICE_H_AND_S_HR_COMPLIANCE_SERVICE = 'CB1';
    
    //Event Record Type Id's
    Public Static final Id E_CITATION_EVENT_RID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Citation Event').getRecordTypeId();
    
    public static final String AUTOMATION_CONFIGURATION_LIST_TYPE_ASSIGNMENT_RECORD_TYPE = 'List Type Assignment';
    public static final String AUTOMATION_CONFIGURATION_TOXIC_SIC_2007_CODE_RECORD_TYPE = 'Toxic SIC 2007 Code'; //Toxic SIC 2007 Code 3
    public static final String AUTOMATION_CONFIGURATION_TOXIC_SIC_2007_CODE_3_RECORD_TYPE = 'Toxic SIC 2007 Code 3';
    public static final String AUTOMATION_CONFIGURATION_FTECRIT_SECTOR_EXCLUSION_RECORD_TYPE = 'FTE Crit Sector Exclusion';
    public static final String AUTOMATION_CONFIGURATION_FTECRIT_SECTOR_LIMITS_RECORD_TYPE = 'FTE Crit Sector Limits';
    public static final String AUTOMATION_CONFIGURATION_FTECRIT_BDM_OVERRIDE_RECORD_TYPE = 'FTE Crit BDM Override';
    public static final String AUTOMATION_CONFIGURATION_FTECRIT_DAFAULT_THRESHOLD_RECORD_TYPE = 'FTE Crit Default Threshold';
    public static final String AUTOMATION_CONFIGURATION_BASICCRIT_SOURCE_EXCLUSION_RECORD_TYPE = 'Basic Crit Source Exclusion';
    public static final String AUTOMATION_CONFIGURATION_BASICCRIT_OUTCODE_EXCLUSION_RECORD_TYPE = 'Basic Crit Outcode Exclusion';
    public static final String AUTOMATION_CONFIGURATION_BASICCRIT_DS_EXCLUSION_RECORD_TYPE = 'Basic Crit Data Supplier Exclusion';
    //SDT-6992
    public static final String AUTOMATION_CONFIGURATION_BASICCRIT_PROSPECT_SOURCE_EXCLUSION_RECORD_TYPE = 'Basic Crit Prospect Source Exclusion';
    public static final String AUTOMATION_CONFIGURATION_BASICCRIT_PARTNER_CC_EXCLUSION_RECORD_TYPE = 'Basic Crit Partner CC Exclusion';

    public static final String LEAD_DEFAULT_CITATION_RECORD_TYPE = 'Default Citation Record Type';
    public static final String ClUSTER_ROLE_RENEWAL  = 'Renewal'; 
    public static final String ClUSTER_ROLE_CONTACT_STRATEGY  = 'Contact Strategy'; 

    //Pricebook
    public static final String PRICEBOOK_QMS_NAME = 'QMS CPQ';
    
    public static final String QUOTE_iHASCO_RECORDTYPENAME  = 'IHASCO';	
    public static final String QUOTE_iHASCO_RECORDTYPEDEVNAME  = 'IHASCO';	
    public static final String OPP_iHASCO_RECORDTYPEDEVNAME  = 'IHASCO';
    public static final String Contract_iHASCO_RECORDTYPENAME  = 'iHASCO Standard Contract'; 
    public static final String LEAD_iHASCO_RECORDTYPENAME  = 'Default_IHASCO'; 

    public static final String QUOTE_iHASCO_PRICEBOOKNAME  = 'iHASCO';
    public static final String QUOTE_iHASCORenewal_RECORDTYPENAME  = 'Renewal_iHasco';	
    public static final String QUOTE_USER_BASED  = 'User Based';
    public static final String QUOTE_OPEN_LICENSE  = 'Open License';
    public static final String QL_SUB_SCOPE_GROUP ='Group';
    public static final String OPEN_LICENSE_PRODUCT   ='Open License Pricing';
    public static final String USERBASED_PRODUCT   ='User based Pricing';
    public static final String OPENCREDITS_PRODUCT='Open License Credits';
    public static final String OPTION_TYPE_RELATED_PRODUCT ='Related Product';
    public static final Integer DEFAULT_SUB_TERM_12 =12;
    public static final String LEAD_STATUS_DUPLICATE_FOUND  = 'Duplicate Found';
    public static final String LEAD_STATUS_CONVERTED ='Convert';
    public static final String QUOTE_STATUS_AGREEMENT_ISSUED  = 'Agreement Issued';
    public static final String OPPORTUNITY_STAGE_PROVISIONAL_AGREEMENT = 'Provisional Agreement';
    public static final String QUOTE_CITATION_RECORDTYPENAME = 'Quote_Locked';

}