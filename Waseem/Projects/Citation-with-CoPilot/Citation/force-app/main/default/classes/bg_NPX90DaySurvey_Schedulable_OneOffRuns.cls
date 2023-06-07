/****************************************************************************
*
*   Replica class of bg_NPX90DaySurvey_Schedulable - use this when the schedulable job failed so that you do not have to change that class
*	You must edit the AnniversaryDates list before scheduling this class
*	Remove the class from Production once done
*	
*   Created By: Oliver Slater
*   Created Date: 12-09-2017
*
*   Changes:
*
****************************************************************************/
global with sharing class bg_NPX90DaySurvey_Schedulable_OneOffRuns implements Schedulable {

    global void execute(SchedulableContext sc) {
        processAndGenerateSurveys();
    }

    /*
        Get all required information, then loop through contacts and create a new survey record for each.
    */
    public static void processAndGenerateSurveys(){
        try{
            List<Date> anniversaryDates = getAnniversaries();

            Set<String> surveyAccountFields = new Set<String>();
            Set<String> surveyContactFields = new Set<String>();
            Map<String, NPX_90_Day_Survey_Account_Mapping__c> surveyAccountMapping = getSurveyAccountMapping();
            for (NPX_90_Day_Survey_Account_Mapping__c surveryMapping : surveyAccountMapping.values())
            {
                surveyAccountFields.add(surveryMapping.SF_Field_Name__c.toUpperCase());
            }
            Map<String, NPX_90_Day_Survey_Contact_Mapping__c> surveyContactMapping = getSurveyContactMapping();
            for (NPX_90_Day_Survey_Contact_Mapping__c surveryMapping : surveyContactMapping.values())
            {
                surveyContactFields.add(surveryMapping.SF_Field_Name__c.toUpperCase());
            }

            List<Contact> contactRecords = getAnniversaryRecords(anniversaryDates, surveyAccountFields, surveyContactFields);

            List<NPX_Survey_Record__c> surveysToCreate = new List<NPX_Survey_Record__c>();
            for (Contact contactRecord : contactRecords)
            {
                surveysToCreate.add(generateSurveyRecord(contactRecord, surveyAccountMapping, surveyContactMapping));
            }
            if (!surveysToCreate.isEmpty())
            {
                insert surveysToCreate;
            }
        }
        catch (Exception ex)
        {
            Messaging.SingleEmailMessage emailToSend = generateErrorEmail(ex);
            if (!Test.isRunningTest())
            {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailToSend});
            }
        }
    }

    /*
        Generate a list of annivesaries - 90 days ago
    */
    @testVisible
    private static List<Date> getAnniversaries(){
        List<Date> anniversaryDates = new List<Date>();
        Date referencePoint1 = Date.today().addDays(-91);
        Date referencePoint2 = Date.today().addDays(-92);
        Date referencePoint3 = Date.today().addDays(-93);
        Date referencePoint4 = Date.today().addDays(-94);                        
        anniversaryDates.add(referencePoint1);
        anniversaryDates.add(referencePoint2);
        anniversaryDates.add(referencePoint3);
        anniversaryDates.add(referencePoint4);        
        system.debug('bg_NPX90DaySurvey_Schedulable.getAnniversaries(): ' + anniversaryDates);
        return anniversaryDates;
    }

    /*
        Get the list of account fields and the survey fields they need to map into
    */
    private static Map<String, NPX_90_Day_Survey_Account_Mapping__c> getSurveyAccountMapping(){
        return NPX_90_Day_Survey_Account_Mapping__c.getAll();
    }

    /*
        Get the list of contact fields and the survey fields they need to map into
    */
    private static Map<String, NPX_90_Day_Survey_Contact_Mapping__c> getSurveyContactMapping(){
        return NPX_90_Day_Survey_Contact_Mapping__c.getAll();
    }

    /*
        Get all of the records that have reached their anniversary.
    */
    private static List<Contact> getAnniversaryRecords(List<Date> anniversaryDates, Set<String> accountFields, Set<String> contactFields){
        Set<Id> contactsToSurvey = new Set<Id>();
        for (Account account : [select Id, (select CustomerSignedId from Contracts where CustomerSignedId != null and CustomerSigned.HasOptedOutOfEmail = False and CustomerSigned.Email != null and CustomerSignedDate IN :anniversaryDates) from Account where Citation_Client__c = True and Cluster_Start_Date__c IN :anniversaryDates])
        {
            for (Contract contract : account.Contracts)
            {
                contactsToSurvey.add(contract.CustomerSignedId);
            }
        }
        for (Contact contact : [select Id from Contact where Account.Citation_Client__c = True and Account.Cluster_Start_Date__c IN :anniversaryDates And Email != null And HasOptedOutOfEmail = False and (Main_User__c = 'Yes' OR Online_Super_User__c = 'Yes' OR Service_Owner__c = True)])
        {
            contactsToSurvey.add(contact.Id);
        }
        String soqlQuery = 'SELECT ';
        for (String accountField : accountFields)
        {
            soqlQuery += 'Account.'+accountField + ', ';
        }
        for (String contactField : contactFields)
        {
            soqlQuery += contactField + ', ';
        }
        soqlQuery += 'SystemModStamp FROM Contact WHERE Id IN :contactsToSurvey';
        system.debug('bg_NPX90DaySurvey_Schedulable.getAnniversaryRecords(): ' + soqlQuery);
        return Database.query(soqlQuery);
    }

    /*
        Generate a survey record, setting each field to the correct value based on the field mappings
    */
    private static NPX_Survey_Record__c generateSurveyRecord(Contact surveyContact, Map<String, NPX_90_Day_Survey_Account_Mapping__c> surveyAccountMapping, Map<String,NPX_90_Day_Survey_Contact_Mapping__c> surveyContactMapping){
        NPX_Survey_Record__c surveyRecord = new NPX_Survey_Record__c();
        surveyRecord.Survey_ID__c = 'CITATION_2947';
        surveyRecord.Status__c = 'Nominated';
        surveyRecord.Survey_Name__c = '90 Day Survey Review';
        surveyRecord.Name = '90 Day Survey Review';
        for (String field : surveyAccountMapping.keySet())
        {
            surveyRecord.put(field, surveyContact.getSObject('Account').get(surveyAccountMapping.get(field).SF_Field_Name__c));
        }
        for (String field : surveyContactMapping.keySet())
        {
            surveyRecord.put(field, surveyContact.get(surveyContactMapping.get(field).SF_Field_Name__c));
        }

        system.debug('bg_NPX90DaySurvey_Schedulable.generateSurveyRecord(): ' + surveyRecord);
        return surveyRecord;
    }

    private static Messaging.SingleEmailMessage generateErrorEmail(Exception ex){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(UserInfo.getUserEmail());
        mail.setToAddresses(sendTo);
        mail.setReplyTo('info@emea.salesforce.com');
        mail.setSenderDisplayName('Citation');
        mail.setSubject('Error: NPX 90 Day Survey Review ' + DateTime.Now());
        mail.setHtmlBody(String.valueOf(ex));
        system.debug('bg_NPX90DaySurvey_Schedulable.generateErrorEmail(): ' + mail);
        return mail;
    }
}