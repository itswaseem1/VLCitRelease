/**********************************************************************
 * Controller for the Create New Contact VisualForce page.
 * 
 * Creates the new Contact

 * Author: James Garford(BrightGen.com)
 * Created: 16-01-2015
 * Changes:
***********************************************************************/
public with sharing class bg_SaveAndCloseContactController {
    private ApexPages.StandardController controller;
	public Boolean closeWindow {get;set;}
	public String accountId {get;set;}
	public Contact contact {get;set;}

    public bg_SaveAndCloseContactController(ApexPages.StandardController controller){
        accountId = ApexPages.currentPage().getParameters().get('accid');
        this.contact = (Contact)controller.getRecord();        
		list<Account> theAccount = [Select id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where id = : accountId];
	    if(!theAccount.IsEmpty()) {
		    contact.AccountId = theAccount[0].id;
		    contact.MailingStreet = theAccount[0].BillingStreet;
		    contact.MailingCity = theAccount[0].BillingCity;
			contact.MailingState = theAccount[0].BillingState;
			contact.MailingCountry = theAccount[0].BillingCountry;
			contact.MailingPostalCode = theAccount[0].BillingPostalCode; 
	    }
    }

    public PageReference saveAndClose() {
        try{	          
	          upsert contact;	          
	          closeWindow = true;
	     }catch(Exception e){
	          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
	     }
	     return null;       
    }
    
    public PageReference cancel() {     
		closeWindow = true;
		return null; 
    }
}