public class EmailTemplateToBillingContract {
    public void sendingEmail(List<ffbc__Contract__c> billContractList){
        try{
            List<EmailTemplate> et = [SELECT Id,Subject,HtmlValue FROM EmailTemplate WHERE Name='Atlas UpSkill Purchase Confirmation' LIMIT 1];
            List<Document> docList = [SELECT Id,Name,Body FROM Document WHERE Name='E-Commerce Terms and Conditions' LIMIT 1];
            List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
            List<String> toAddress = new List<String>();
            List<String> bccAddress = new List<String>();
            List<String> ccAddresses = new List<String>();
            List<Id> contractIdList = new List<Id>();
            List<Task> taskList = new List<Task>();
            List<Id> docIds = new List<Id>();
            String contractId = '';
            bccAddress.add('ecommerce@citation.co.uk');
            for(ffbc__Contract__c con : billContractList){
                System.debug('Inside sendingMail For Loop');
                contractIdList.add(con.SF_Contract__c);
            }
            if(docList.size()>0){
            	docIds.add(docList[0].Id);
            }
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address='ecommerce@citation.co.uk'];
            if(!et.isEmpty() && !contractIdList.isEmpty()){
                for(Contract c : [SELECT Id,Account.c2g__CODAInvoiceEmail__c,Customer_Signatory_Email_Address__c,CustomerSigned.Id,(SELECT Id FROM SBQQ__Subscriptions__r) FROM Contract WHERE Id IN:contractIdList]){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate((String)et[0].Id, null,c.SBQQ__Subscriptions__r[0].Id);
                    System.debug('Mail Data in For loop:::'+mail);
                    mail.setReplyTo('donotreply@do-not-reply.com');
                    mail.setBccAddresses(bccAddress);
                    if(c.Customer_Signatory_Email_Address__c!=null){
                        toAddress.add(c.Customer_Signatory_Email_Address__c);
                    }
                    if(c.Account.c2g__CODAInvoiceEmail__c!=null && c.Account.c2g__CODAInvoiceEmail__c!=c.Customer_Signatory_Email_Address__c){
                        ccAddresses.add(c.Account.c2g__CODAInvoiceEmail__c);
                    }
                    if(ccAddresses.size()>0){
                        mail.setCcAddresses(ccAddresses);
                    }
                    if(docList.size()>0){
                        mail.setEntityAttachments(docIds);
                    }
                    if(owea.size()>0){
                        mail.setOrgWideEmailAddressId(owea[0].Id);
                    }
                    mail.setToAddresses(toAddress);
                    allEmails.add(mail);
                    contractId = c.Id;
        	    }
                System.debug('allEmails:::'+allEmails);
                if(!allEmails.isEmpty()){
                    Messaging.sendEmail(allEmails,true);
                    System.debug('After sendEmail:::');
                    Task taskRecs = new Task();
                    taskRecs.WhatId = contractId;
                    taskRecs.Description = allEmails[0].getHtmlBody().replaceAll('<[^>]+>','').unescapeHtml4();
                    taskRecs.Subject = allEmails[0].getSubject();
                    taskRecs.Status = 'Completed';
                    taskRecs.Status__c = 'Closed';
                    taskList.add(taskRecs);
                    if(!taskList.isEmpty()){
                        System.debug('Task is inserted:::');
                        insert taskList;
                    }
	    			return;
                }
            }   
        }   
		catch(Exception e){
    		System.debug('Exception Name sendingEmail ::::'+e.getMessage());
		}
	}

    public void documentMapping(List<ffbc__Contract__c> billContractList){
        try{
            List<Document> doc = new List<Document>();
            List<Id> sfContractIdList = new List<Id>();
            List<Attachment> attachsList = new List<Attachment>();
            doc = [SELECT Id,Name,Body FROM Document WHERE Name='E-Commerce Terms and Conditions' LIMIT 1];
            System.debug('doc Method::::'+doc);
            for(ffbc__Contract__c con : billContractList){
                System.debug('Inside documentMapping For Loop');
                sfContractIdList.add(con.SF_Contract__c);
            }
            if(!doc.isEmpty() && !sfContractIdList.isEmpty()){
                for(Contract con:[SELECT Id FROM Contract WHERE Id IN:sfContractIdList]){
                    Attachment att = new Attachment();
                    att.Body = doc[0].Body;
                    att.ParentId = con.Id;
                    att.Name = 'E-Commerce Terms and Conditions.pdf';
                    attachsList.add(att);
                    System.debug('attachsList methods::::'+attachsList);
                }
            }
            if(!attachsList.isEmpty()){
                System.debug('Document T and C insertions');
                insert attachsList;
            }
        }
        catch(Exception e){
            System.debug('Exception Name documentMapping ::::'+e.getMessage());
        }
    }
}