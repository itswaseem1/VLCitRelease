/**
* @File Name          : AdviceBoxUIController.apxt
* @Description        : show the advice record created by user
* @Author             : Sarita Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 17/8/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     12/08/2021      Initial Version						SS-627/SS-1025
**/
public with sharing class AdviceBoxUIController {
    //To get all advice record
    //SPA-46-Siddhartha
    @AuraEnabled   
    public static List <Advice__c> fetchAdvice( String caseIds )  {  
        List<Advice__c> advicelist=new List<Advice__c>([SELECT id,case__r.recordtype.name,Matter_Type__c,Sub_Matter__c,Detail_Sub_Matter__c,Advice__c,Case__c,CreatedBy.Name,Advice_Guarantee__c,Advice_contact__c, CreatedDate,Sensitive_Case__c  
                                                        FROM Advice__c 
                                                        WHERE Case__c=:caseIds order by CreatedDate desc]);
        
        return advicelist;
    }
    
    //SPA-46
    @AuraEnabled(cacheable=true)
    public static Case getCaseData( Id caseId )  {  
        
        
        return [SELECT id,RecordTypeName__c FROM Case 
                WHERE id =:caseId limit 1];
    }
    
    @AuraEnabled  
    public static String getRecordTypeName (String caseIds)  {  
        List<Case> advicelist=new List<Case>([SELECT id,recordtype.name  FROM Case 
                                                        WHERE id=:caseIds WITH SECURITY_ENFORCED order by CreatedDate desc]);
        
        return advicelist[0].recordtype.name;
    }
    
    @AuraEnabled
    public static void adviceInsert(string fieldObj){ //NOPMD
        //Id eltAdvicerecordTypeId = Schema.SObjectType.Advice__c.getRecordTypeInfosByDeveloperName().get('ELT_Advice_Generic').getRecordTypeId();
   
        Advice__c adObj  =  (Advice__c) JSON.deserialize(fieldObj, Advice__c.class);
        
        String contactName = [SELECT Id,Contact.Name FROM Case WHERE Id=:adObj.Case__c]?.contact?.Name;
        adObj.Advice_contact__c = contactName;
        //adObj.RecordTypeId=eltAdvicerecordTypeId;
        
        case caseObj = new case(Id= adObj.Case__c, Latest_Advice_Date__c = Date.today());
        List<Case> caseList = new List<Case>();
        caseList.add(caseObj);
        
        try{
             if (Advice__c.SObjectType.getDescribe().isCreateable()) {
                insert adObj;	
             }

             if(Case.sObjectType.getDescribe().isUpdateable()){
                update caseList;
             }
        }catch(Exception error){
            system.debug(error.getmessage());
        }
    }
     //To delete advice record
    @AuraEnabled
    public static Boolean adviceDelete(string selectedId){
        Boolean isDeleted;
        Advice__c adviceRecord = [SELECT id,Advice__c,Case__c,CreatedBy.Name,Advice_Guarantee__c,Advice_contact__c, CreatedDate,Sensitive_Case__c  
                                  FROM Advice__c 
                                  WHERE Id=:selectedId WITH SECURITY_ENFORCED];
        try{
            if (Advice__c.SObjectType.getDescribe().isDeletable()) {delete adviceRecord;isDeleted=true;}
            else{isDeleted=false;}
        }catch(Exception error){
            system.debug(error.getmessage());
        }
        return isDeleted;
        
    }
        
}