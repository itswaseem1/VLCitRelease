/**********************************************************************
* bg_FmIntOpportunityWS:
*
* Class to serialise Opportunity object into a json message and 
* send via bg_FmIntHttpCallout, invoked from buttons DTR & SalesVisit
* on Opportunity; presents a web-service interface to send an opp.
* Created By: SA
* Created Date: 01-02-2016
*
* Changes: 
***********************************************************************/
global class bg_FmIntOpportunityWS {


    public static String sendEmail(String address, String subject, String body) {
        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        Messaging.reserveSingleEmailCapacity(2);

        // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.

        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Assign template and target object ids

        // Assign the addresses for the To lists to the mail object.
        mail.setToAddresses(new String[] {address});

        // Specify the subject line for your email address.
        mail.setSubject(subject);

        // Specify the text content of the email.
        mail.setPlainTextBody(body);

        // Send the email you have created.
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        if (!results.get(0).isSuccess()) {
            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
            String errorMessage = results.get(0).getErrors()[0].getMessage();
            System.debug('***** sendEmail Error: ' + errorMessage);           
            return errorMessage;
        }

        return null;
    }

    @AuraEnabled
    webservice static String send(Id oppId, Boolean DTR, Boolean SalesVisit, Boolean Proforma) {
        system.debug('**Proforma**: ' + DTR + Proforma+'salesvisit'+SalesVisit);
        String action = 'Booking';
        Set<Id> oppIdList = new Set<Id>();
        oppIdList.add(oppId);
        Map<Id, Opportunity> oppMap = bg_FmIntOpportunity.getOppMap(oppIdList);
        Opportunity opp = oppMap.get(oppId);

        if(DTR) {
            opp.DTR__c = DTR;
        }
        else if(SalesVisit) {
            opp.Sales_Visit__c = SalesVisit;
        }
        else if(Proforma)
        {
            action = 'Proforma';
            
            Opportunity oppUp = new Opportunity();
            oppUp.Id = oppId;
            oppUp.Generate_Proforma__c = Proforma;
            update oppUp;
            
            system.debug('**Proforma Inside**: ' + opp.Generate_Proforma__c);
            Opportunity oppDetails = [select Account.Name, Certification__c, Contact_Email__c, Contact_Phone__c
                from Opportunity where Id =: opp.Id];

            String emailBody = 'Please note a proforma has been requested from the following client:\n';
            emailBody += 'Client Name: ' + oppDetails.Account.Name + '\n';
            emailBody += 'Certification: ' + oppDetails.Certification__c + '\n';
            emailBody += 'Email: ' + oppDetails.Contact_Email__c + '\n';
            emailBody += 'Phone: ' + oppDetails.Contact_Phone__c + '\n';

            String emailTo = String.valueOf(FM_Integration__c.getValues('Host').get('FM_Proforma_Email_To__c'));
            if(String.isNotBlank(emailTo))
                sendEmail(emailTo, 'Please note a proforma has been requested', emailBody);
        }

    	System.debug('send opp ws: '+oppMap.values());
    	bg_FmIntOpportunity.send(action, oppMap.values());
    	return null;

    }

}