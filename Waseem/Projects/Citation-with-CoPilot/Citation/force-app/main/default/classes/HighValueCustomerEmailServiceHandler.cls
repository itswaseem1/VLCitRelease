public without sharing class HighValueCustomerEmailServiceHandler implements Messaging.InboundEmailHandler {
	private static final String DEFAULTQUEUENAME = System.Label.HvcELTadviceGenericQueueName;

	public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		EmailService.EmailServiceSelector selector = new EmailService.EmailServiceSelector();
		EmailService service = new EmailService(selector);
		Messaging.InboundEmailResult result = service.emailMessageHandlerForHighValueCustomer(email, envelope, DEFAULTQUEUENAME);
		return result;  
	}
}