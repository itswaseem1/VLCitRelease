/****************************************************************************
*
*   Schedulable apex for the generation of NPX Survey records for every contract that has been signed 90 days ago.
*
*   Created By: Jamie Wooley
*   Created Date: 28-03-2017
*
*   Changes:
*
****************************************************************************/
global class bg_NPX90DaySurvey_Schedulable implements Schedulable {
    /*
        Method executed by the scheduled job.
    */
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
            system.debug('exception+++'+ex);
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
    private static List<Date> getAnniversaries(){
        List<Date> anniversaryDates = new List<Date>();
        Date referencePoint = Date.today().addDays(-90);
        anniversaryDates.add(referencePoint);
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
        set<id> accountIdSet = new set<id>();
        set<id> accForContr = new set<id>();
        map<string,string> qlineIdContIdMap = new map<string,string>();
        set<contract> setContract = new set<Contract>();
        Map<Id, SBQQ__QuoteLine__c> mapQuotelines = new Map<Id, SBQQ__QuoteLine__c>();
        set<string> cpqProductCodes = new set<string>(); //set of trimed CPQ Core Product Codes added from System.Label.CPQ_Core_Product_Codes
        List<String> listcoreProductCodes  = new List<String>();//list of all Productcodes added from System.Label.CPQ_Core_Product_Codes
        listcoreProductCodes.addAll(System.Label.CPQ_Core_Product_Codes.Split(','));
        
        if(!listcoreProductCodes.isEmpty()){
            for (String prouctcode : listcoreProductCodes) {
                  cpqProductCodes.add(prouctcode.trim());
            }
        }
        
        for(Account acc:[select Id from Account where Cluster_Start_Date__c IN :anniversaryDates AND Citation_Client__c = True AND IsActive__c = True]){
            accForContr.add(acc.id);
        }
        system.debug('accForContr'+accForContr);
        for (Contract c:[select accountid,CustomerSigned.Active__c,CustomerSignedId,CustomerSigned.HasOptedOutOfEmail,CustomerSigned.Email,Services_Taken_EL__c, Services_Taken_HS__c, Services_Taken_AI_Only__c, Services_Taken_AI_Only_HS__c, Services_Taken_Advice_Only__c,(select Id, name, SBQQ__QuoteLine__c,SBQQ__Contract__c from SBQQ__Subscriptions__r), Services_Taken_Advice_Only_HS__c from Contract where Status = 'Active' and accountid In: accForContr order by CustomerSignedDate ASC])
        {
            setContract.add(c);
            system.debug('Inside 112'+c.CustomerSigned.Active__c+'value of c'+c);
            if(!c.SBQQ__Subscriptions__r.isEmpty()){
                for(SBQQ__Subscription__c sSB: c.SBQQ__Subscriptions__r){
                    if (sSB.SBQQ__QuoteLine__c != Null) {
                        qlineIdContIdMap.put(sSB.SBQQ__QuoteLine__c, sSB.SBQQ__Contract__c);
                    }
                }
            }
            
        }
        
        for(SBQQ__QuoteLine__c qLine : [Select Id, Name, SBQQ__ProductCode__c  from SBQQ__QuoteLine__c where Id In : qlineIdContIdMap.keySet()]){
                if(qLine.SBQQ__ProductCode__c != Null && cpqProductCodes.contains(qLine.SBQQ__ProductCode__c)){
                    mapQuotelines.put(qlineIdContIdMap.get(qLine.Id), qLine);
                }
        }
        system.debug('mapQuotelines'+mapQuotelines);
        system.debug('setContract'+setContract);
        for (Contract contract : setContract)
            {
               
               if(mapQuotelines.containsKey(contract.Id) || (contract.Services_Taken_EL__c == True || contract.Services_Taken_HS__c == True || contract.Services_Taken_AI_Only__c == True 
                            || contract.Services_Taken_AI_Only_HS__c == True || contract.Services_Taken_Advice_Only__c == True  || contract.Services_Taken_Advice_Only_HS__c  == True)){
                   system.debug('Inside 138');
                   accountIdSet.add(contract.AccountId);
                   if(contract.CustomerSigned.Active__c != False && contract.CustomerSignedId != null && contract.CustomerSigned.HasOptedOutOfEmail != true && contract.CustomerSigned.Email != null){
                       system.debug('Inside 134');
                       contactsToSurvey.add(contract.CustomerSignedId);
                   }
                   
                }
            
            }
        for (Contact contact : [select Id from Contact where Email != null And HasOptedOutOfEmail = False And AccountId in (select Id from Account where Cluster_Start_Date__c IN :anniversaryDates AND Citation_Client__c = True and id In: accountIdSet) and Active__c = True and (Main_User__c = 'Yes' OR Online_Super_User__c = 'Yes' OR Helpline_PEL__c = 'Yes' OR Helpline_H_S__c = 'Yes' OR Service_Owner__c = True)])
        {
            contactsToSurvey.add(contact.Id);
        }
        system.debug('Inside 145'+contactsToSurvey);
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
        system.debug('bg_NPXRelationshipSurvey_Schedulable.getAnniversaryRecords(): ' + soqlQuery);
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