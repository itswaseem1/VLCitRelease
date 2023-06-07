/********************************************************************
 * bg_Unit_Test_Helper
 *
 * Unit Test Helper Utility Class
 * 
 * Author: James Garford
 * Created: 17-12-2014
 *
 * Changes: 
 
 ********************************************************************/
public class bg_Unit_Test_Helper {
    
    public static final string OPPORTUNITY_STAGE_PROVISIONAL_APPROVAL = 'Provisional Approval';
    public static final string OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY = 'Default Citation Opportunity';
    public static final string OPPORTUNITY_RT_SMALL_BUSINESS_PACKAGE = 'Small Business Package';    
    private static final String CONTRACT_RT_SMALL_BUSINESS_NAME = 'Small Business Package';
    private static final String CONTRACT_RT_STANDARD_NAME = 'Standard Contract';

    public static void createEchosignCustomSettings () {
        
        EchoSign_Configuration__c echoSignConfiguration = new EchoSign_Configuration__c();
        echoSignConfiguration.Name = 'Create Agreement';
        echoSignConfiguration.Opportunity_Stage_Required__c = 'Provisional Agreement';
        echoSignConfiguration.EchoSign_URL__c = '/apex/echosign_dev1__AgreementTemplateProcess?masterid=';
        
        insert echoSignConfiguration;
        
        bg_RecordTypeMap contractRecordTypeMap = new bg_RecordTypeMap('Contract'); 
        
        String contractStandardRTId = contractRecordTypeMap.getIdFromName(CONTRACT_RT_STANDARD_NAME);
        String contractSmallBusinessPackageRTId = contractRecordTypeMap.getIdFromName(CONTRACT_RT_SMALL_BUSINESS_NAME);   
   
        list<EchoSign_Agreement_Criteria__c> echoSignAgreementCriteriaList = new list<EchoSign_Agreement_Criteria__c>();

        /****************************************** Small Business *******************************************/
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria1 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria1.Name = 'Create Agreement SBP - 1a';
        echoSignAgreementCriteria1.Template_ID__c = 'sbp001';
        echoSignAgreementCriteria1.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria1.Criteria_Value__c = 'No';        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria1);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria2 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria2.Name = 'Create Agreement SBP - 1b';
        echoSignAgreementCriteria2.Template_ID__c = 'sbp001';
        echoSignAgreementCriteria2.Criteria_Field__c = 'affinity__c';    
        echoSignAgreementCriteria2.Criteria_Value__c = 'NAFD';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria2);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria3 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria3.Name = 'Create Agreement SBP - 1c';
        echoSignAgreementCriteria3.Template_ID__c = 'sbp001';
        echoSignAgreementCriteria3.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria3.Criteria_Value__c = contractSmallBusinessPackageRTId;        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria3);

        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria4 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria4.Name = 'Create Agreement SBP - 2a';
        echoSignAgreementCriteria4.Template_ID__c = 'sbp002';
        echoSignAgreementCriteria4.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria4.Criteria_Value__c = 'Yes';       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria4);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria5 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria5.Name = 'Create Agreement SBP - 2b';
        echoSignAgreementCriteria5.Template_ID__c = 'sbp002';
        echoSignAgreementCriteria5.Criteria_Field__c = 'affinity__c';    
        echoSignAgreementCriteria5.Criteria_Value__c = 'NAFD';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria5);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria6 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria6.Name = 'Create Agreement SBP - 2c';
        echoSignAgreementCriteria6.Template_ID__c = 'sbp002';
        echoSignAgreementCriteria6.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria6.Criteria_Value__c = contractSmallBusinessPackageRTId;        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria6);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria7 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria7.Name = 'Create Agreement SBP - 3a';
        echoSignAgreementCriteria7.Template_ID__c = 'sbp003';
        echoSignAgreementCriteria7.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria7.Criteria_Value__c = 'No';        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria7);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria8 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria8.Name = 'Create Agreement SBP - 3b';
        echoSignAgreementCriteria8.Template_ID__c = 'sbp003';
        echoSignAgreementCriteria8.Criteria_Field__c = 'affinity__c';    
        echoSignAgreementCriteria8.Criteria_Value__c = '--';        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria8);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria9 = new EchoSign_Agreement_Criteria__c();       
        echoSignAgreementCriteria9.Name = 'Create Agreement SBP - 3c';
        echoSignAgreementCriteria9.Template_ID__c = 'sbp003';
        echoSignAgreementCriteria9.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria9.Criteria_Value__c = contractSmallBusinessPackageRTId;        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria9);
            
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria10 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria10.Name = 'Create Agreement SBP - Default a';
        echoSignAgreementCriteria10.Template_ID__c = 'sbp004';
        echoSignAgreementCriteria10.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria10.Criteria_Value__c = ' ';        
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria10);
                
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria11 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria11.Name = 'Create Agreement SBP - Default b';
        echoSignAgreementCriteria11.Template_ID__c = 'sbp004';
        echoSignAgreementCriteria11.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria11.Criteria_Value__c = contractSmallBusinessPackageRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria11);

        /****************************************** Standard *******************************************/
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria12 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria12.Name = 'Create Agreement Standard - 1a';
        echoSignAgreementCriteria12.Template_ID__c = 'std001';
        echoSignAgreementCriteria12.Criteria_Field__c = 'agreement_template_type__c';    
        echoSignAgreementCriteria12.Criteria_Value__c = 'Combined';     
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria12);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria13 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria13.Name = 'Create Agreement Standard - 1b';
        echoSignAgreementCriteria13.Template_ID__c = 'std001';
        echoSignAgreementCriteria13.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria13.Criteria_Value__c = 'No';       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria13);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria14 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria14.Name = 'Create Agreement Standard - 1c';
        echoSignAgreementCriteria14.Template_ID__c = 'std001';
        echoSignAgreementCriteria14.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria14.Criteria_Value__c = contractStandardRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria14);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria15 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria15.Name = 'Create Agreement Standard - 2a';
        echoSignAgreementCriteria15.Template_ID__c = 'std002';
        echoSignAgreementCriteria15.Criteria_Field__c = 'agreement_template_type__c';    
        echoSignAgreementCriteria15.Criteria_Value__c = 'Combined';     
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria15);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria16 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria16.Name = 'Create Agreement Standard - 2b';
        echoSignAgreementCriteria16.Template_ID__c = 'std002';
        echoSignAgreementCriteria16.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria16.Criteria_Value__c = 'Yes';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria16);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria17 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria17.Name = 'Create Agreement Standard - 2c';
        echoSignAgreementCriteria17.Template_ID__c = 'std002';
        echoSignAgreementCriteria17.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria17.Criteria_Value__c = contractStandardRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria17);

        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria18 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria18.Name = 'Create Agreement Standard - 3a';
        echoSignAgreementCriteria18.Template_ID__c = 'std003';
        echoSignAgreementCriteria18.Criteria_Field__c = 'agreement_template_type__c';    
        echoSignAgreementCriteria18.Criteria_Value__c = 'PEL';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria18);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria19 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria19.Name = 'Create Agreement Standard - 3b';
        echoSignAgreementCriteria19.Template_ID__c = 'std003';
        echoSignAgreementCriteria19.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria19.Criteria_Value__c = 'No';       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria19);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria20 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria20.Name = 'Create Agreement Standard - 3c';
        echoSignAgreementCriteria20.Template_ID__c = 'std003';
        echoSignAgreementCriteria20.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria20.Criteria_Value__c = contractStandardRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria20);

        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria21 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria21.Name = 'Create Agreement Standard - 4a';
        echoSignAgreementCriteria21.Template_ID__c = 'std004';
        echoSignAgreementCriteria21.Criteria_Field__c = 'agreement_template_type__c';    
        echoSignAgreementCriteria21.Criteria_Value__c = 'PEL';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria21);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria22 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria22.Name = 'Create Agreement Standard - 4b';
        echoSignAgreementCriteria22.Template_ID__c = 'std004';
        echoSignAgreementCriteria22.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria22.Criteria_Value__c = 'Yes';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria22);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria23 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria23.Name = 'Create Agreement Standard - 4c';
        echoSignAgreementCriteria23.Template_ID__c = 'std004';
        echoSignAgreementCriteria23.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria23.Criteria_Value__c = contractStandardRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria23);

        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria24 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria24.Name = 'Create Agreement Standard - 5a';
        echoSignAgreementCriteria24.Template_ID__c = 'std005';
        echoSignAgreementCriteria24.Criteria_Field__c = 'agreement_template_type__c';    
        echoSignAgreementCriteria24.Criteria_Value__c = 'H&S';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria24);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria25 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria25.Name = 'Create Agreement Standard - 5b';
        echoSignAgreementCriteria25.Template_ID__c = 'std005';
        echoSignAgreementCriteria25.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria25.Criteria_Value__c = 'No';       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria25);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria26 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria26.Name = 'Create Agreement Standard - 5c';
        echoSignAgreementCriteria26.Template_ID__c = 'std005';
        echoSignAgreementCriteria26.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria26.Criteria_Value__c = contractStandardRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria26);

        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria27 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria27.Name = 'Create Agreement Standard - 6a';
        echoSignAgreementCriteria27.Template_ID__c = 'std006';
        echoSignAgreementCriteria27.Criteria_Field__c = 'agreement_template_type__c';    
        echoSignAgreementCriteria27.Criteria_Value__c = 'H&S';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria27);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria28 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria28.Name = 'Create Agreement Standard - 6b';
        echoSignAgreementCriteria28.Template_ID__c = 'std006';
        echoSignAgreementCriteria28.Criteria_Field__c = 'second_signatory_required__c';    
        echoSignAgreementCriteria28.Criteria_Value__c = 'Yes';      
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria28);
        
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria29 = new EchoSign_Agreement_Criteria__c();      
        echoSignAgreementCriteria29.Name = 'Create Agreement Standard - 6c';
        echoSignAgreementCriteria29.Template_ID__c = 'std006';
        echoSignAgreementCriteria29.Criteria_Field__c = 'recordtypeid';    
        echoSignAgreementCriteria29.Criteria_Value__c = contractStandardRTId;       
        echoSignAgreementCriteriaList.add(echoSignAgreementCriteria29);

        insert echoSignAgreementCriteriaList;
         
    } 
    
    public static void updateEchosignCustomSettingsFieldName (String name, String criteriaFieldName) {
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria = [Select Name, Template_ID__c, Criteria_Field__c, Criteria_Value__c from EchoSign_Agreement_Criteria__c where Name = : name limit 1];
        echoSignAgreementCriteria.Criteria_Field__c = criteriaFieldName; 
        update echoSignAgreementCriteria; 
    }
    
    public static void updateEchosignCustomSettingsFieldValue (String name, String criteriaFieldValue) {
        EchoSign_Agreement_Criteria__c echoSignAgreementCriteria = [Select Name, Template_ID__c, Criteria_Field__c, Criteria_Value__c from EchoSign_Agreement_Criteria__c where Name = : name limit 1];
        echoSignAgreementCriteria.Criteria_Value__c = criteriaFieldValue; 
        update echoSignAgreementCriteria; 
    }

    public static Opportunity createOpportunity(string opportunityName, string recordtype, Account acc, Contact con)
    {

        bg_RecordTypeMap opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');         
        Opportunity o = new Opportunity();
        o.Name = opportunityName;
        if (recordtype == OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY) {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName(OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY); 
        } else {
            o.RecordTypeId =  opportunityRecordTypeMap.getIdFromName(OPPORTUNITY_RT_SMALL_BUSINESS_PACKAGE);
        } 
        o.AccountId = acc.id;
        o.Type = 'New Business';
        o.CloseDate = system.now().addMonths(1).date();
        o.Deal_Type__c = 'Combined';
        o.Payroll_Amt__c = 1000;
        o.Contract_Length_Mths__c = '12';
        o.Payment_Period__c = 'Monthly';
        o.Deal_Start_Date__c = system.now().addDays(3).date();
        o.SAT_Date__c = system.now().addDays(2).date();  
        o.Amount = 10000;
        o.Deposit__c = 100;
        o.Original_1st_Visit_Date__c = system.now().addDays(2).date();
        o.Prospect_Channel__c = 'Call In';
        o.Event_Outcome__c = 'SAT';
        o.Affinity_Industry_Type__c = 'NAFD';         
        o.StageName = OPPORTUNITY_STAGE_PROVISIONAL_APPROVAL;//stageName;  
        o.Contract_Length_Years__c = 10;
        o.Deposit_Payment_Method__c = 'Credit Card';
        // FRA
        o.Amount = 1;
        o.FRA_Total_Amount__c = 1;

        insert(o);
        return o;
    }
 
    public static Account createAccount(String accName)
    {
        //RecordType rt = BG_recordTypeUtils.GetRecordTypeByObjectandName('Account', 'Business');
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        
        insert acc;
        return acc;     
    }
    
    public static Contact createContact(String firstName, String lastName, String AccId)
    {       
        Contact con = new Contact();
        con.AccountId = AccId;
        con.FirstName = firstName;
        con.LastName = lastName;
        con.Phone = '0113 8000 300';
        
        insert con;
        return con;     
    }
    
    
    public static Opportunity createDefaultCitationOpportunity(string stageName)
    {
        Account acc = bg_Unit_Test_Helper.createAccount('DCOTestAccount1001');
        Contact con = bg_Unit_Test_Helper.createContact('DCOTest', 'User1', acc.id);                
        Opportunity opp = bg_Unit_Test_Helper.createOpportunity('Test DC Opportunity', 'Default Citation Opportunity', acc, con);
        
        // couldn't set the stage on create so do it now
        opp.StageName = stageName;
        update(opp);
        return opp;
    }
    
    public static Opportunity createSmallBusinessPackageOpportunity(string stageName)
    {
        Account acc = bg_Unit_Test_Helper.createAccount('SMPTestAccount2001');
        Contact con = bg_Unit_Test_Helper.createContact('SBPTest', 'User1',  acc.id);            
        Opportunity opp = bg_Unit_Test_Helper.createOpportunity('Test SBP Opportunity', 'Small Business Package', acc, con);
        
        // couldn't set the stage on create so do it now
        
        opp.StageName = stageName;
        update(opp);
        return opp;
    }        
}