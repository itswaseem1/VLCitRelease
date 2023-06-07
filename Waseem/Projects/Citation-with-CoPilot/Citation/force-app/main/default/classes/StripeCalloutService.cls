/*
 * @Class Name: StripeCalloutService
 * @description: This class is used perfrom HTTP callout for Stripe 
 * @Author: Sahil Ravi and Waseem.
 * @Last Modified Date: 02/13/2021
 * @
 **/
public without sharing class StripeCalloutService {

    public static StripeAPI__mdt stripeKey { get; set; }
    static final Integer CENT_MULTIPLIER = 100;
    public String sKey  { get; set; }
    public CustomerAndBillingDetailsWrap customerBillingWrap { get; set; }
    public static Id contractOrderId { get; set; }
    public static Organization org { get; set; }

    static {
        org = getinstanceInfo();
        stripeKey = getStripeAPIDetails();
    }
    
    public StripeCalloutService ()
    {
        stripeKey = getStripeAPIDetails();
        sKey = stripeKey.PublishableKey__c;
    }

    // Method for getting the StrupeAPI values
    @TestVisible
    private static StripeAPI__mdt getStripeAPIDetails() {
        List<StripeAPI__mdt> stripeKeys = new List<StripeAPI__mdt>();
        if(org != null && org.isSandbox){
            stripeKeys = [
                SELECT Id, DeveloperNAme, AuthorizeUrl__c, PublishableKey__c, SecretKey__c,siteAddress__c 
                FROM StripeAPI__mdt 
                WHERE DeveloperName = 'StripeTest'
                LIMIT 1
            ];
            AzureVault.iHASCOStripeCreds stripecred =  AzureVault.getiHASCOStripeCreds(org.isSandbox);
            Blob SecretKeyBlob = Blob.valueOf(stripecred?.value);
            stripeKeys[0].SecretKey__c = EncodingUtil.base64Encode( SecretKeyBlob);
        } else if(org != null){
             stripeKeys = [
                SELECT Id, DeveloperNAme, AuthorizeUrl__c, PublishableKey__c, SecretKey__c,siteAddress__c 
                FROM StripeAPI__mdt 
                WHERE DeveloperName = 'Stripe'
                LIMIT 1
            ];
            AzureVault.iHASCOStripeCreds stripecred =  AzureVault.getiHASCOStripeCreds(org.isSandbox);
            Blob SecretKeyBlob = Blob.valueOf(stripecred?.value);
            stripeKeys[0].SecretKey__c = EncodingUtil.base64Encode(SecretKeyBlob);
        }

        if (stripeKeys.isEmpty()) {
            if (Test.isRunningTest()) {
                return new StripeAPI__mdt();
            }
            
            throw new AuraHandledException('Exception in StripeCalloutService class, AuthProvider has not been defined for Stripe');
        }

        return stripeKeys[0];
    }
    
    //get running instance
    @TestVisible
    private static Organization getinstanceInfo() {
        List<Organization> org = [SELECT InstanceName, isSandbox FROM Organization];
        if(!org.isEmpty()){
            return org[0];
        } else {
            throw new AuraHandledException('Unable to fetch oranisation Info');
        }
    }

    // Method which validates the page details
    public PageReference validateStripePayementDetails() {
        try {
            String encodedString = ApexPages.currentPage().getParameters().get('contractOrderId');
            Blob decodeBlob = EncodingUtil.base64Decode(encodedString);
            String decodedString;
            decodedString = decodeBlob.toString();
            System.debug('Decoded-String ' + decodedString);
            contractOrderId = decodedString.substringBefore('-');
            DateTime expiryDateTime = DateTime.valueOf(decodedString.substringAfter('-')); 
            System.debug('::contractOrderId '+contractOrderId );
            System.debug('::expiryDateTime '+expiryDateTime );
            String objName = contractOrderId.getsobjecttype().getDescribe().getName();
            if (String.isEmpty(contractOrderId) && (objName != 'Contract' || objName != 'Order')) {
                return redirectToErrorPage();
            }
            if  (objName == 'Contract') {
                Contract[] cont = [
                    SELECT Id, Name, Status, Source_Opportunity__c, SBQQ__Opportunity__c, 
                        Total_Contract_Value__c,Annual_Contract_Value__c, CustomerSignedId, CustomerSigned.Name, 
                        CustomerSigned.AccountId, CustomerSigned.Account.Name, Payment_Status__c, 
                        StripePaymentLinkExpiryDateTime__c,SBQQ__Quote__r.name,SBQQ__Quote__c,
                        Account.BillingStreet,Account.Billingcity,Account.BillingState,Account.BillingCountry,
                        CustomerSigned.email,CustomerSigned.phone,Amend_Delta_Price__c
                    FROM Contract 
                    WHERE Id = :contractOrderId AND StripePaymentLinkExpiryDateTime__c = :expiryDateTime
                    LIMIT 1
                ];
                
    
                if ((cont == null && cont.size() == 0) || 
                    (cont != null && cont.size() > 0 && ((cont[0].Payment_Status__c != 'Payment Link Sent') && (cont[0].Payment_Status__c != 'Payment Failed') ) 
                     || DateTime.now() > cont[0].StripePaymentLinkExpiryDateTime__c) ) {
                    return redirectToErrorPage();
                }
                // Populate CustomerBilling details
                customerBillingWrap = new CustomerAndBillingDetailsWrap(cont[0], true);
            } else if (objName == 'Order') {
                 Order[] ord = [
                    SELECT Id, Name, Status, 
                        TotalAmount, CustomerAuthorizedById, CustomerAuthorizedBy.Name, 
                        CustomerAuthorizedBy.AccountId, CustomerAuthorizedBy.Account.Name,  
                        StripePaymentLinkExpiryDateTime__c,Payment_Status__c,
                        SBQQ__Quote__r.name,Account.BillingStreet,Account.Billingcity,Account.BillingState,
                        Account.BillingCountry,CustomerAuthorizedBy.email,CustomerAuthorizedBy.phone
                    FROM Order 
                    WHERE Id = :contractOrderId AND StripePaymentLinkExpiryDateTime__c = :expiryDateTime
                    LIMIT 1
                ];

    
                if ((Ord == null && Ord.size() == 0) || 
                    (Ord != null && Ord.size() > 0 && ((Ord[0].Payment_Status__c != 'Payment Link Sent') && (Ord[0].Payment_Status__c != 'Payment Failed') ) 
                     || DateTime.now() > Ord[0].StripePaymentLinkExpiryDateTime__c) ) {
                    return redirectToErrorPage();
                }
                customerBillingWrap = new CustomerAndBillingDetailsWrap(ord[0], true);
            }
        } Catch(Exception ex) {
            return  redirectToErrorPage(); 
        }      
                    
        return null; 
    }

    // Method used for redirecting to error page
    public PageReference redirectToErrorPage() {
        PageReference retURL = new PageReference('/iHASCO/StripePaymentError');
        retURL.setRedirect(true);
        return retURL;
    }
    
    @RemoteAction
    public static PaymentIntentWrapper createPaymentIntent(id objId, String cardholderName) {
        String endPoint = stripeKey.AuthorizeUrl__c + '/payment_intents';
        String publishableKey = stripeKey.PublishableKey__c;
        Blob decodekeyBlob = EncodingUtil.base64Decode(stripeKey.SecretKey__c);
    String secretKey;
    if(Test.isRunningTest()){
            secretKey = stripeKey.SecretKey__c;
        }else{
            secretKey = decodekeyBlob.toString();    
        }
        String objName = objId.getsobjecttype().getDescribe().getName();
        Integer totalAmountToPay;
        String description;
        String shippingstreet;
        String shippingcity;
        String shippingpostalcode;
        CustomerAndBillingDetailsWrap customerBillingWrap;
        if(objName == 'Contract'){
            List<Contract> con= [SELECT Id, Total_Contract_Value__c,Annual_Contract_Value__c, CustomerSigned.Name, CustomerSigned.Account.Name,SBQQ__Quote__r.name,SBQQ__Quote__c,Payment_Status__c,
                                 Account.BillingStreet, Account.Billingcity, Account.Billingpostalcode,Amend_Delta_Price__c, 
                                 Account.BillingState,Account.BillingCountry,CustomerSigned.email,CustomerSigned.phone,Status
                                 from Contract where id = :objId ];
            customerBillingWrap = new CustomerAndBillingDetailsWrap(con[0], true); 
            totalAmountToPay = (Integer)(customerBillingWrap.totalAmount * CENT_MULTIPLIER);
            description = customerBillingWrap.description;
            shippingstreet = con[0].Account.BillingStreet;
            shippingcity = con[0].Account.Billingcity;
            shippingpostalcode = con[0].Account.Billingpostalcode;
        } else if(objName == 'Order'){
            List<Order> ord= [SELECT Id,  TotalAmount, CustomerAuthorizedBy.Name, CustomerAuthorizedBy.Account.Name,SBQQ__Quote__r.name,SBQQ__Quote__c,Payment_Status__c,
                              Account.BillingStreet, Account.Billingcity, Account.Billingpostalcode, 
                              Account.BillingState,Account.BillingCountry,CustomerAuthorizedBy.email,CustomerAuthorizedBy.phone
                              from Order where id = :objId ];
            customerBillingWrap = new CustomerAndBillingDetailsWrap(ord[0], true); 
            totalAmountToPay = (Integer)(customerBillingWrap.totalAmount * CENT_MULTIPLIER);
            description = customerBillingWrap.description;
            shippingstreet = ord[0].Account.BillingStreet;
            shippingcity = ord[0].Account.Billingcity;
            shippingpostalcode = ord[0].Account.Billingpostalcode;
        }
        String body = 'amount=' + totalAmountToPay + '&currency=GBP&payment_method_types[]=card&description=' + description ;
        body += '&shipping[name]=' + cardholderName + '&shipping[address][line1]='+shippingstreet+'&shipping[address][postal_code]='+shippingpostalcode+'&shipping[address][city]=' + shippingcity;

        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('content-type', 'application/x-www-form-urlencoded');
        headerMap.put('Authorization', 'Bearer ' + secretKey);

        HttpResponse payIntResp = httpCallout('POST', endPoint, body, headerMap);
        PaymentIntentWrapper payIntWrap = (PaymentIntentWrapper)JSON.deserialize(payIntResp.getBody(), PaymentIntentWrapper.class);
        return payIntWrap;
    }

    // Method used for performing the callouts
    private static HttpResponse httpCallout(String httpMethod, String endpoint, String httpBody, Map<String, String> headerMap) { 
        Http http = new Http();
        HttpResponse res;
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(endpoint);
        req.setMethod(httpMethod);

        // Set headers
        for (String each : headerMap.keySet()) { req.setHeader(each, headerMap.get(each)); }

        // Set body
        if (String.isNotEmpty(httpBody)) { req.setBody(httpBody); }
       
        try {
            res = http.send(req);
            if (res.getStatusCode() != 200 && res.getStatusCode() != 201 && res.getStatusCode() != 204) {
                throw new AuraHandledException('Exception in StripeCalloutService class, HttpCallout Failed with StatusCode: '+ res.getStatusCode() + ' Body: ' +res.getBody());
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        return res;
    }

    @RemoteAction
    public static Boolean processPaymentConfirmation(String paymentIntentJSON, Id objId, Boolean isSuccess) {
        if (String.isNotEmpty(objId)) {
            System.debug('orderid' + objId);
            String objName = objId.getsobjecttype().getDescribe().getName();
            String paymentStatus;
            if (String.isNotEmpty(paymentIntentJSON) && !paymentIntentJSON.contains('undefined')) {
                Map<String, Object> deserializedMap = (Map<String, Object>) JSON.deserializeUntyped(paymentIntentJSON);
                if (isSuccess && deserializedMap.get('status') != null && deserializedMap.get('status') == 'succeeded') { paymentStatus = 'Payment Completed'; }
            }

            if (!isSuccess) { paymentStatus = 'Payment Failed'; }
            
            if (objName == 'Contract') {
                Contract cont = new Contract();
                cont.Id = objId;
                cont.Payment_Status__c = paymentStatus;
                if(cont.Payment_Status__c == 'Payment Completed'){
                    cont.Status = 'Active';
                }
                //bg_Contract_Helper.iHASCOSiteUser = true;
                update cont;
            } else if (objName == 'Order') {
                Order ord = new Order();
                ord.Id = objId;
                 
                ord.Payment_Status__c = paymentStatus;
                update ord;
            } 
        }

        return true;
    }
    
    @AuraEnabled(cacheable = true)
    public static void sendEmail(string recId) {
        id whatId;
        id tObjId;
        id recordId = (Id)recId;
        id quoteId;
        String objName;
        String status = '';
        DateTime expiryDateTime;
        Decimal Amount=0;
        Decimal VAT =0;
        Decimal TotalAmount=0;
        String userName,SenderName;
        system.debug('recId' + recId);
         if (String.isNotEmpty(recId)) {
            objName =  recordId.getsobjecttype().getDescribe().getName();
         }
        if(recordId == NULL){
            throw new AuraHandledException('Unable to fetch record Id, Please contact admin');
        } else if (objName == 'Contract') {
            List<Contract> conList = new List<Contract>();
            conList = [SELECT Id, CustomerSigned.EMail,CustomerSigned.Name,Payment_Status__c, CustomerSignedId,SBQQ__Quote__c,
                       Total_Contract_Value__c,Annual_Contract_Value__c,Account.BillingStreet, Account.Billingcity, Account.Billingpostalcode,Account.BillingCountry,
                       StripePaymentLinkExpiryDateTime__c,SBQQ__Quote__r.SBQQ__SalesRep__r.Name,Amend_Delta_Price__c,Status
                                  FROM Contract WHERE Id = :recordId  LIMIT 1];
            if(!conList.isEmpty()){
                if(conList[0].CustomerSignedId == NULL){ throw new AuraHandledException('Customer Signatory field mandatory to send Email'); 
                } else if(conList[0].Payment_Status__c == 'Payment Completed'){ throw new AuraHandledException('Payment status aleady in completed status, Please correct status before resend'); 
                } else if(conList[0].CustomerSigned.EMail == NULL){ throw new AuraHandledException('Customer Signatory must have Email value to send Email'); 
                } else if(conList[0].Annual_Contract_Value__c == NULL || !(conList[0].Annual_Contract_Value__c >0) ){ throw new AuraHandledException('Contract Value must be a positive value'); 
                } else if(conList[0].Account.BillingStreet == NULL){ throw new AuraHandledException('Contract Account must have Billing Street to Send Payment Link'); 
                } else if(conList[0].Account.Billingcity == NULL){ throw new AuraHandledException('Contract Account must have Billing City to Send Payment Link'); 
                } else if(conList[0].Account.Billingpostalcode == NULL){ throw new AuraHandledException('Contract Account must have Billing PostCode to Send Payment Link'); 
                }else if(conList[0].Account.BillingCountry == NULL){ throw new AuraHandledException('Contract Account must have Billing Country to Send Payment Link'); 
                } else {
                    tObjId = conList[0].CustomerSignedId;
                    whatId = recordId;
                    quoteId = conList[0].SBQQ__Quote__c;
                    status = conList[0].Payment_Status__c;
                    expiryDateTime = System.now().AddDays(3);
                    Amount = conList[0].Status==label.iHASCOStatusInAmendment? conList[0].Amend_Delta_Price__c :conList[0].Annual_Contract_Value__c;
                    userName=conList[0].CustomerSigned.Name;
                    SenderName =conList[0].SBQQ__Quote__r.SBQQ__SalesRep__r.Name;
                    
                }
            } else {
                throw new AuraHandledException('Unable to process request, Please contact Salesforce Admin');
            }
        } else if (objName == 'Order') {
            List<Order> ordList = new List<Order>();
            ordList = [SELECT Id, CustomerAuthorizedBy.EMail,Payment_Status__c, CustomerAuthorizedById, SBQQ__Quote__c,TotalAmount, 
                       Account.BillingStreet, Account.Billingcity, Account.Billingpostalcode,Account.BillingCountry,StripePaymentLinkExpiryDateTime__c,
                     CustomerAuthorizedBy.Name,SBQQ__Quote__r.SBQQ__SalesRep__r.Name
                       FROM Order WHERE Id = :recordId  LIMIT 1];
            if(!ordList.isEmpty()){
                if(ordList[0].CustomerAuthorizedById == NULL){ throw new AuraHandledException('Customer Authorised By field mandatory to send Email'); 
                } else if(ordList[0].Payment_Status__c == 'Payment Completed'){ throw new AuraHandledException('Payment status aleady in completed status, Please correct status before resend'); 
                } else if(ordList[0].CustomerAuthorizedBy.EMail == NULL){ throw new AuraHandledException('Customer Authorised By Contact must have Email value to send Email'); 
                } else if(ordList[0].TotalAmount == NULL || ordList[0].TotalAmount <=0 ){ throw new AuraHandledException('Order Value must be a positive value'); 
                } else if(ordList[0].Account.BillingStreet == NULL){ throw new AuraHandledException('Order Account must have Billing Street to Send Payment Link'); 
                } else if(ordList[0].Account.Billingcity == NULL){ throw new AuraHandledException('Order Account must have Billing City to Send Payment Link'); 
                } else if(ordList[0].Account.Billingpostalcode == NULL){ throw new AuraHandledException('Order Account must have Billing PostCode to Send Payment Link'); 
                } else if(ordList[0].Account.BillingCountry == NULL){ throw new AuraHandledException('Order Account must have Billing Country to Send Payment Link'); 
                } else {
                    tObjId = ordList[0].CustomerAuthorizedById;
                    whatId = recordId;
                    quoteId = ordList[0].SBQQ__Quote__c;
                    status = ordList[0].Payment_Status__c;
                    expiryDateTime = System.now().AddDays(3);
                    Amount = ordList[0].TotalAmount;
                    userName=ordList[0].CustomerAuthorizedBy.Name;
                    SenderName =ordList[0].SBQQ__Quote__r.SBQQ__SalesRep__r.Name;
                }
            } else {
                throw new AuraHandledException('Unable to process request, Please contact Salesforce Admin');
            }
        } 
        
        if ( whatId != NULL && tObjId != NULL && status != 'Payment Completed') {
            String sourceLink = '';
            String param = whatId + '-' + expiryDateTime;
            Blob blobData=Blob.valueOf(String.valueof(param));
            String encodedString = EncodingUtil.base64Encode(blobData);
            if(org != null && org.isSandbox){
                
                sourceLink = 'https://';
                sourceLink = sourceLink + EnvironmentHelper.getSandboxName();
                sourceLink = sourceLink + '-citation.' + org.InstanceName + '.force.com/iHASCO/StripePayment?contractOrderId=' + encodedString; 
            }  else if(org != null) {
                sourceLink = stripeKey.siteAddress__c +  encodedString;
            }      
             if(Amount != NULL){
              	VAT = Amount == 0 ? 0 : ((Amount / 100) * 20);
            TotalAmount = Amount + VAT ;
             }
            else{
               Amount =0; 
               VAT = 0; 
               TotalAmount =0; 
            }

            
            String body = [SELECT Id, Subject, Description, HtmlValue, Body   FROM EmailTemplate WHERE Name =: Label.iHASCO_Stripe_Payment_Email LIMIT 1].HtmlValue;
            body =body.replace('UserReplace', userName);
            body = body.replace('RequesterReplace', SenderName);
            body =body.replace('PaymentReplace', sourceLink);
            body =body.replace('AmountReplace', String.valueOf(Amount) );
            body =body.replace('VATReplace', String.valueOf(VAT));
            body =body.replace('TotalReplace', String.valueOf(TotalAmount));
                String htmlBody = body;
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
       //             message.toAddresses = new String[] {customerEmail};
                    message.subject = 'Payment request';
                    message.htmlbody = htmlBody;
                    message.setTargetObjectId(tObjId);
                    message.setWhatId(whatId);
        //            message.setTemplateId(emailTemp.Id);
                    message.setSaveAsActivity(false);
                    message.setUseSignature(false);
                    
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                        if(quoteid != null){
                            updatepaymentexpiry(whatId,expiryDateTime);
                        }
                        
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                        throw new AuraHandledException('The email failed to send: ' + results[0].errors[0].message);
                    }
                 
        } else {
            throw new AuraHandledException('Unable to find the contact to send Email, Please contact admin');
        }
    } 
    
    @future(Callout=true)
    private static void updatepaymentexpiry(id whatId, DateTime expiryDateTime){
        
        string obj = whatId.getsobjecttype().getDescribe().getName();
        if(obj == 'Contract'){
            Contract c = new Contract();
            c.id = whatId;
            c.Payment_Status__c = 'Payment Link Sent';
            c.StripePaymentLinkExpiryDateTime__c = expiryDateTime;
            update c;
        } else if(obj == 'Order'){
            Order ord = new Order();
            ord.id = whatId;
            ord.Payment_Status__c = 'Payment Link Sent';
            ord.StripePaymentLinkExpiryDateTime__c = expiryDateTime;
            update ord;
        }
    }

    // Wrapper for PaymentIntent response
    public class PaymentIntentWrapper {
        public String id;
        public Double amount;
        public String canceled_at;
        public String cancellation_reason;
        public String capture_method;
        public String client_secret;
        public String confirmation_method;
        public String last_payment_error;
        public String status;
    }


    // Wrapper which holds customer and billing details
    public class CustomerAndBillingDetailsWrap {
        public Decimal amount { get; set; }
        public String customerName { get; set; }
        public String companyName { get; set; }
        public String description { get; set; }
        public Boolean hasVAT { get; set; }
        public Decimal vatAmount { get; set; }
        public Decimal totalAmount { get; set; }
        public String line1 { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String country { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        

        public CustomerAndBillingDetailsWrap(Contract cont, Boolean hasVAT) {
            this.amount = cont.Status==label.iHASCOStatusInAmendment? cont.Amend_Delta_Price__c :cont.Annual_Contract_Value__c;
            this.customerName = cont.CustomerSigned.Name;
            this.companyName = cont.CustomerSigned.Account.Name;
            this.description = 'iHASCO Quote Reference - ' + cont.SBQQ__Quote__r.name;
            this.hasVAT = hasVAT;
            this.vatAmount = (hasVAT ? ((amount / 100) * 20) : 0.00);
            this.totalAmount = amount + vatAmount;
            this.line1 = Cont.Account.BillingStreet;
            this.city = Cont.Account.Billingcity;
            this.state = Cont.Account.BillingState;
            string billCountry = Cont.Account.BillingCountry.replaceAll( '\\s+', '');
            iHASCOStripeCountryMapping__mdt cMap = iHASCOStripeCountryMapping__mdt.getInstance(billCountry.toUpperCase()); 
            this.country = cMap != null ? cMap.StripeCountryCode__c : Cont.Account.BillingCountry;
            this.email = Cont.CustomerSigned.email;
            this.phone = Cont.CustomerSigned.phone;
        }

         public CustomerAndBillingDetailsWrap(Order ord, Boolean hasVAT) {
            this.amount = ord.TotalAmount;
            this.customerName = ord.CustomerAuthorizedBy.Name;
            this.companyName = ord.CustomerAuthorizedBy.Account.Name;
            this.description = 'iHASCO Quote Reference - ' + ord.SBQQ__Quote__r.name;
            this.hasVAT = hasVAT;
            this.vatAmount = (hasVAT ? ((amount / 100) * 20) : 0.00);
            this.totalAmount = amount + vatAmount;
            this.line1 = ord.Account.BillingStreet;
            this.city = ord.Account.Billingcity;
            this.state = ord.Account.BillingState;
            string billCountry = ord.Account.BillingCountry.replaceAll( '\\s+', '');
            iHASCOStripeCountryMapping__mdt cMap = iHASCOStripeCountryMapping__mdt.getInstance(billCountry.toUpperCase());
            this.country = cMap != null ? cMap.StripeCountryCode__c : ord.Account.BillingCountry;
            this.email = ord.CustomerAuthorizedBy.email;
            this.phone = ord.CustomerAuthorizedBy.phone;
        } 
    }
}