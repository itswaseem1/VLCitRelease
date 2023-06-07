public class UploadPMUBatch implements Database.Batchable<string>, Database.Stateful
{
    public final blob csvData;
    Id partnerId;
    Integer totalCount=0;
    Map<String,String> csvRowErrorMessage = new Map<String,String>();
    public UploadPMUBatch (blob data,Id partnerId)
    {
        system.debug('Inside constructor---'+partnerId);
        this.csvData=data;
        this.partnerId=partnerId;
    }
    
    public Iterable<string>  start(Database.BatchableContext BC)
    {
        return new CSVIterator(this.csvData.toString(), '\n');
    }
    public void execute(Database.BatchableContext BC,List<String> scope)
    {
        system.debug('scope---'+scope+'---'+scope.size());
        List<Partner_Member_Upload__c> pmuList = new List<Partner_Member_Upload__c>();
        Partner_Member_Upload__c pmuObj;
        try{
            for(String row : scope)
            { 
                List<String> csvRecordData = row.split(',');
                if(!csvRecordData[0].contains('Member Company Name') && String.isNotBlank(csvRecordData[0]) && String.isNotBlank(csvRecordData[1])){
                    totalCount++;
                    pmuObj = new Partner_Member_Upload__c();
                    pmuObj.Partner__c = partnerId;
                    pmuObj.Member_Company_Name__c = csvRecordData[0];
                    pmuObj.Street__c =  csvRecordData[1];
                    pmuObj.City__c =  csvRecordData[2];
                    pmuObj.Postcode__c = csvRecordData[3];
                    pmuObj.Salutation__c = csvRecordData[4];
                    pmuObj.First_Name__c = csvRecordData[5];
                    pmuObj.Last_Name__c = csvRecordData[6];
                    pmuObj.Phone__c = csvRecordData[7];
                    pmuObj.Mobile__c = csvRecordData[8];
                    pmuObj.Email__c = csvRecordData[9];
                    pmuObj.Website__c = csvRecordData[10];
                    pmuObj.FT_Employees__c = String.isNotBlank(csvRecordData[11]) ? Decimal.valueOf(csvRecordData[11]) : NULL;
                    pmuObj.Company_Registration_Number__c = csvRecordData[12];
                    pmuObj.Date_Joined_Partner__c = String.isNotBlank(csvRecordData[13]) ? Date.parse(csvRecordData[13].trim()) : NULL;
                    pmuObj.Member_id__c = csvRecordData[14];
                    pmuObj.Assign_How_to_Access_Units__c = csvRecordData[15].trim().equalsIgnoreCase('true')? TRUE : FALSE;
                    pmuObj.Branch_Bad_Company_Bad_Domain__c = csvRecordData[16].trim().equalsIgnoreCase('true')? TRUE : FALSE;
                    pmuObj.Email_Domain__c = String.isNotBlank(csvRecordData[9]) ? (csvRecordData[9].split('@').size() > 1 ? csvRecordData[9].split('@')?.get(1) : NULL ) : NULL;
                    pmuList.add(pmuObj);
                }
            }
            system.debug('pmuList--'+pmuList);
            if(!pmuList.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                Database.SaveResult[] srList = Database.insert(pmuList,dml);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.'+err.getStatusCode() + ': ' + err.getMessage()+': '+err.getFields());
                            csvRowErrorMessage.put(scope[0],err.getMessage());
                        }
                    }
                }
            }
        }catch(Exception ex){
            system.debug('catch exception---'+ex.getMessage());
            csvRowErrorMessage.put(scope[0],ex.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){
        String partnerName = [Select Id,Name from Account Where Id=:partnerId].Name;
        system.debug('Finish Method---'+totalCount);
        system.debug('csvRowErrorMessage---'+csvRowErrorMessage);
        String text1 = '<html><body>The csv file uploaded to the Salesforce Account '+partnerName+' has been processed.<br><br></body></html>';
        String text2 = '<html><body>This contained '+totalCount+' members.<br><br></body></html>';
        String text3 = '<html><body>The number of Partner Member Upload records created was '+(totalCount-csvRowErrorMessage.size())+'.<br><br></body></html>';
        String text4 = '<html><body>These will be processed overnight for matching to existing Salesforce records, creation of Partner Member Relationships and associated actions.<br><br><br><br></body></html>';
        String text5 = '<html><body>The number of members that did not create a Partner Member Upload Record was '+csvRowErrorMessage.size()+', these are detailed in the attached file.<br><br><br></body></html>';
        String footer1 = '<html><body>Regards<br><br></body></html>';
        String footer2 = '<html><body>Salesforce Support<br><br></body></html>';
        String footer3 = '<html><body>Registered Office: Kings Court, Water Lane, Wilmslow, Cheshire SK9 5AR, United Kingdom<br><br></body></html>';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(system.label.PartnerMemberUploadBatchEmails.split(','));
        if(!csvRowErrorMessage.isEmpty()){
            String generatedCSVFile ='Member Company Name,Street,City,Postcode,Salutation,First Name,Last Name,Phone,Mobile,Email,Website,FT Employees,Company Registration Number,Date Joined Partner,Member #/id,Assign How to Access Units,Branch /Bad Company /Bad Domain,Error Message\n';
            for(String strRow: csvRowErrorMessage.keySet()){
                generatedCSVFile = generatedCSVFile + strRow.trim()+','+csvRowErrorMessage.get(strRow).trim()+'\n';
            }
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(generatedCSVFile);
            csvAttachment.setFileName('Partner Member upload Failures.csv');
            csvAttachment.setBody(csvBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        }
        email.setSubject('Notification of Member Upload file records Processed for '+partnerName);
        email.setHtmlBody(text1+text2+text3+text4+text5+'<html><br><br></html>'+footer1+footer2+footer3);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}