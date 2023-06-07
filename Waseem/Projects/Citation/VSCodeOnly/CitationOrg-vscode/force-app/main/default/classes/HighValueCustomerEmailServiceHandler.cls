public without sharing class HighValueCustomerEmailServiceHandler implements Messaging.InboundEmailHandler {
	private static final String DEFAULTQUEUENAME = 'ELT_Advice_Generic';

	public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Id caseId = Cases.getCaseIdFromEmailHeaders(email.headers);
		EmailService.EmailServiceSelector selector=new EmailService.EmailServiceSelector();
		EmailService service= new EmailService(selector);
		Messaging.InboundEmailResult result = service.emailMessageHandlerForHighValueCustomer(email, envelope, caseId, DEFAULTQUEUENAME);
		return result;
	}
}