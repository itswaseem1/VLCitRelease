public with sharing class CIT_PH1_EmailHandler {
	/**
    * @description mail - used to store and send any Errors
    */
    public static Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
	public static void sendMail(String Message, String jsonList){
		// Who you are sending the email to
   		List<String> toAddresses = new List<String>();
   		String messageBody = '';
   		toAddresses.add(String.valueOf(CWS_Integration__c.getValues('Host').get('Error_Email__c')));
   		//toAddresses.add('nimil.christopher@makepositive.com');
		mail.setToAddresses(toAddresses);
		// The email template ID used for the email
		//mail.setTemplateId('00X30000001GLJj');
		mail.setSubject('CWS Exception');    
		mail.setBccSender(false);
		mail.setUseSignature(false);
		//mail.setReplyTo('recruiting@acme.com');
		//mail.setSenderDisplayName('HR Recruiting');
		mail.setSaveAsActivity(false);
		messageBody += 'Error message : ' + message + ' <br/> The Failed JSON : ' + jsonList;
 		mail.setHtmlBody(messageBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}