@SuppressWarnings('PMD')
public with sharing class QmsReferralsController {
 @AuraEnabled
    public static List<String> fetchProducts(){
        try{
             List<String> prodList = new List<String>();
             Schema.DescribeFieldResult fieldResult = Lead.QMSProductInterest__c.getDescribe();
             List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
             for( Schema.PicklistEntry f : ple)
                {
              prodList.add(f.getLabel()); 
               }
            return prodList;
        }catch(Exception ex){
            system.debug('Exception occured in '+ex.getStackTraceString());
            throw new AuraHandledException('Some error occured while fetching Produucts ');
        }  
    }
    @AuraEnabled
    public static void createLead(String comments,Id accountId,Id contactId,List<String> selectedProdNames){
        Savepoint sp = Database.setSavepoint();
        try{
               Account acc = [Select name from Account where id=:accountId WITH SECURITY_ENFORCED];
               Contact con = [Select FirstName,LastName,Email,Phone from Contact where id=:contactId WITH SECURITY_ENFORCED];
               Id leadId =  Lead.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('QMS_Record_Type').getRecordTypeId();
               Lead referralLead = new Lead();
               referralLead.RecordTypeId=leadId;
               referralLead.LeadSource='Ref_Employee_QMS';
               referralLead.Notes__c='Service required: QMS Connect - Transition service';
               referralLead.ExistingQMSClient__c=true;
               referralLead.Referred_By_First_Name__c=userInfo.getFirstName();
               referralLead.Referred_By_Last_Name__c=userInfo.getLastName();
               referralLead.Referred_By_Email__c=userInfo.getUserEmail();
               referralLead.QMSProductInterest__c=String.join(selectedProdNames,';');
               referralLead.Prospect_Channel__c = 'S360_Referral';
               referralLead.FirstName=con.FirstName!=null?con.FirstName:'';
               referralLead.LastName=con.LastName!=null?con.LastName:'';
               referralLead.Email=con.Email!=null?con.Email:'';
               referralLead.Phone=con.Phone!=null?con.Phone:'';
               referralLead.Referral_Comments__c=comments;
               referralLead.Company=acc.Name;
               referralLead.Status='Open';
               AssignmentRule aR = new AssignmentRule();
               aR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true WITH SECURITY_ENFORCED limit 1 ];
               Database.DMLOptions dmlOpts = new Database.DMLOptions();
               dmlOpts.assignmentRuleHeader.assignmentRuleId= aR.id;
               referralLead.setOptions(dmlOpts);
               if(Lead.sObjectType.getDescribe().isCreateable()){
               insert referralLead;
               }
               
            
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+ex.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException('Some error occured in creating the opportunity.');
        }  
    }
}
//QMS_Record_Type