public class SMP_DirectDebitSetup_Controller
{
    @AuraEnabled
    public static SmarterPay_Direct_Debit_Setting__mdt getCustomMetaType(){
        return [SELECT Bank_Account_Checker_Endpoint__c, Calculate_Next_Collection_Date_Endpoint__c, List_Next_Collection_Date_Endpoint__c, User_Id__c, Mandate_Company_Name__c FROM SmarterPay_Direct_Debit_Setting__mdt WHERE Active__c = true LIMIT 1];
    }
    @AuraEnabled
    public static String getCompanyName(String DDID){
        return [SELECT Company__r.Name FROM Income_Direct_Debit__c WHERE Id = : DDID].Company__r.Name;
    }
    @AuraEnabled
    public static Income_Direct_Debit__c createDirectDebit(String collectionDay, String collectionPeriod, String numbersOfDaysBetweenNextInstruction, String startDate, Income_Direct_Debit__c IDD){

        System.debug('##### IDD ' + IDD );

        IDD.DD_Status__c = 'New Instruction';

        c2g__codaCompany__c company = [SELECT Id, Direct_Debit_Collection_Dates__c FROM c2g__codaCompany__c WHERE Id = :IDD.Company__c];
        IDD.Company__r = company;

        Map<Id,Income_Direct_Debit__c> ddMap = new Map<Id,Income_Direct_Debit__c>();
        ddMap.put(null, IDD);
        SMP_Direct_Debit_Citation_Helper.setNextCollection(ddMap, Date.valueOf(startDate), numbersOfDaysBetweenNextInstruction);

        insert IDD;

        System.debug('##### Returning IDD' + IDD);

        return IDD;
    }
    @AuraEnabled
    public static Income_Direct_Debit__c modulusCheckDirectDebit(Income_Direct_Debit__c directDebit)
    {
        SMP_DDServiceBankAccountModel response = SMP_DDServiceHandler.getBankDetails(directDebit.DD_Bank_Sort_Code__c, directDebit.DD_Bank_Account_Number__c);
        
        if(String.isNotBlank(response.Modulus_Check.Error))
        {
            throw new SMP_Exception(response.Modulus_Check.Error);
        }

        response.copyFieldsToDirectDebitRecord(directDebit);

        return directDebit;
    }
    @AuraEnabled
    public static List<Field> getFields(String fieldSetName) {
        Schema.SObjectType objectType = Income_Direct_Debit__c.getSobjectType();
        
        List<Field> fields = new List<Field>();
        try 
        {   
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
            Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
            List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

            for (Schema.FieldSetMember fsm : fieldSetMembers) 
            {
                Field f = new Field(fsm);
                fields.add(f);
            }
        } 
        catch (Exception e) 
        {       
            System.debug('#### No Values in field set');
        }

        return fields;
    }
    public class Field {

        public Field(Schema.FieldSetMember f) {
            this.DBRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Label = f.label;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
        }
        public Field(Boolean DBRequired) {
            this.DBRequired = DBRequired;
        }
        
        @AuraEnabled
        public Boolean DBRequired { get;set; }
        
        @AuraEnabled
        public String APIName { get;set; }
        
        @AuraEnabled
        public String Label { get;set; }
        
        @AuraEnabled
        public Boolean Required { get;set; }
        
        @AuraEnabled
        public String Type { get; set; }
    }
}