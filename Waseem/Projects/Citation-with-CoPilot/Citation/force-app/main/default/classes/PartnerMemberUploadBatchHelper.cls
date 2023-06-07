public class PartnerMemberUploadBatchHelper {

    public static Lead createLeadInstance(Partner_Member_Upload__c pmuobj2,Boolean OppCheck){
        Lead objLead = new Lead();
        objLead.Partner_Member_Upload_Id__c = pmuobj2.Id;
        objLead.City = pmuobj2.City__c;
        objLead.Company = pmuobj2.Member_Company_Name__c;
        objLead.Email = pmuobj2.Email__c;
        objLead.Salutation = pmuobj2.Salutation__c;
        objLead.CitationSector__c = pmuobj2.CitationSector__c;
        objLead.FT_Employees__c= pmuobj2.FT_Employees__c;
        objLead.Website = pmuobj2.Website__c;
        objLead.FirstName = pmuobj2.First_Name__c;
        objLead.LastName = pmuobj2.Last_Name__c;
        objLead.Phone = pmuobj2.Phone__c;
        objLead.MobilePhone = pmuobj2.Mobile__c;
        objLead.PostalCode = pmuobj2.Postcode__c;
        objLead.Street = pmuobj2.Street__c;
        objLead.Co_Reg__c = pmuobj2.Company_Registration_Number__c;
        objLead.Email_Domain__c = pmuobj2.Email_Domain__c;
        objLead.Affinity_Partner__c = pmuobj2.Partner__c;
        objLead.Session_Notes__c = 'Member of '+pmuobj2.Partner__r.Name;
        objLead.LeadSource = 'Partnership';
        Date dt = system.today();
        objLead.Source__c = pmuobj2.Partner__r.Name+'_'+dt.month()+'_'+dt.year();
        objLead.Data_Supplier__c = OppCheck ? 'PartnershipsMU_'+pmuobj2.Partner__r.Name+'_ClsdLst' : 'PartnershipsMU_'+pmuobj2.Partner__r.Name;
        objLead.Partner_CC_Exclusion__c = pmuobj2.Branch_Bad_Company_Bad_Domain__c;
        objLead.How_To_Hub_Member__c = pmuobj2.Assign_How_to_Access_Units__c;
        return objLead;
    }
    public static void failureEmailNotification(Set<Id> activeClientPmrIdSet,boolean activeClientCheck){
        List<String> memberCompanyNames = new List<String>();
        String memberValues = '';
        String tableheader='<table style="width:75%"><tr><th>Partner Name</th><th>Partner Member Relationship Record Id</th><th>Member Company Name</th></tr>'; 
        String tableHead='<head><style>table, th, td {border: 1px solid black;border-collapse: collapse;text-align:left;}th, td {padding-left: 10px;}</style></head>';
        String text1 = '<html><body>Hi All,<br><br></body></html>';
        String text2 = '<html><body>The below records for members have been uploaded and Partner Member relationship records created.<br></body></html>';
        String text3 = '<html><body>The upload file requested that the Company received free How-To Hub service paid for by the Partner.<br></body></html>';
        String footer1 = '<html><body>Regards<br><br></body></html>';
        String footer2 = '<html><body>Salesforce Support<br><br></body></html>';
        String footer3 = '<html><body>Registered Office: Kings Court, Water Lane, Wilmslow, Cheshire SK9 5AR, United Kingdom<br><br></body></html>';
        String text4 ='';
        String partnerNames = '';
        Set<String> partnerNameSet = new Set<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(system.label.PartnerMemberUploadBatchEmails.split(','));
        for(Partner_Member_Relationship__c objPartMemRel : [SELECT Id,Partner_Member_Upload_Id__r.Member_Company_Name__c,Partner__r.Name FROM Partner_Member_Relationship__c where Id=:activeClientPmrIdSet]){
            partnerNameSet.add(objPartMemRel.Partner__r.Name);
            memberCompanyNames.add('<tr><td>'+objPartMemRel.Partner__r.Name+'</td> <td>'+objPartMemRel.Id+'</td> <td>'+objPartMemRel.Partner_Member_Upload_Id__r.Member_Company_Name__c+'</td></tr>');
            memberValues=String.join(memberCompanyNames,'');
        }
        if(!partnerNameSet.isEmpty()){
            for(String str: partnerNameSet){
                partnerNames += str+',';
            }
        }
        partnerNames = partnerNames.removeEnd(',');
        if(activeClientCheck){
            email.setSubject('Contracts from Member Upload records for '+partnerNames+' did not create due to Active Account');
            text4 = '<html><body>As that member company has been identified as being an active client or has an account with an Opportunity and a potential Sale, this has not been actioned.<br><br><br></body></html>';
        }else{
            email.setSubject('Contracts from Member Upload records for '+partnerNames+' did not create due to Insufficient How-To Hub Access Units');
            text4 = '<html><body>As the number of requests for How-To Hub in the upload file exceeded the Partner’s available access units the following members have not been allocated services.<br><br><br></body></html>';
        }
        email.setHtmlBody(text1+text2+text3+text4+'<html>'+tableHead+'<body>'+tableheader+memberValues+' </table> <br><br></body></html>'+footer1+footer2+footer3);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    public static Lead updateLeadInstance(Partner_Member_Upload__c pmuobj2, Lead objLead,Lead oldLead){
        objLead.Partner_Member_Upload_Id__c = pmuobj2.Id;
        objLead.Session_Notes__c = 'Member of '+pmuobj2.Partner__r.Name;
        if(oldLead.Status=='Open' || oldLead.Status=='Closed' || oldLead.Status=='Suspended'){
            objLead.LeadSource = 'Partnership';
            objLead.Affinity_Partner__c = pmuobj2.Partner__c;
        }
        if(pmuobj2.Assign_How_to_Access_Units__c && (oldLead.Status=='Closed' || oldLead.Status=='Suspended')){
            oldLead.Status='Open';
        }
        objLead.Partner_CC_Exclusion__c = pmuobj2.Branch_Bad_Company_Bad_Domain__c;
        objLead.How_To_Hub_Member__c = pmuobj2.Assign_How_to_Access_Units__c;
        return objLead;
    }
}