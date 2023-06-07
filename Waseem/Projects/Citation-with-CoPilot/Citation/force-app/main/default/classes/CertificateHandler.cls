/**
 * @File Name          : CertificateHandler.cls
 * @Description        : Updates the Certificate Details to IRQAO via Jitterbit 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka                 Initial Version
 **/
public without sharing class CertificateHandler {
    private static final String JITTERBIT_SETTINGS_NAME = 'IRQAO';
    private static final Set<Integer> OK_STATUS_CODES = new Set<Integer>{200,201,202};
    private static QMS_Intgeration__mdt irqaoMdt{
        get{
            return (irqaoMdt==null) ? (irqaoMdt = getJitterbitSettingsItem()) : irqaoMdt;
        }
        set;
    }
    
    //Fetches the Jitterbit Endpoint details for IRQAO Integration
    private static QMS_Intgeration__mdt getJitterbitSettingsItem(){
        List<QMS_Intgeration__mdt> jbItems=[Select Endpoint__c,Username__c,Password__c From QMS_Intgeration__mdt
                                            where DeveloperName =: JITTERBIT_SETTINGS_NAME Limit 1];
        return (!jbItems.isEmpty()) ? jbItems.get(0) : null;
    }
    
    //Checks for the updates on the Certificate record
    public static void checkForCertficateUpdates(List<Certificate__c> certs, Map<Id,Certificate__c> oldCerts){
        Map<Id,Certificate__c> updatedCerts = new Map<Id,Certificate__c>();
        for(Certificate__c cert1 : certs){
            if(cert1.Status__c !=null && cert1.Status__c !='In-Progress' && (cert1.Status__c != oldCerts.get(cert1.Id).Status__c || cert1.Current_Certificate_Date__c != oldCerts.get(cert1.Id).Current_Certificate_Date__c || 
               cert1.Certificate_Expiry_Date__c != oldCerts.get(cert1.Id).Certificate_Expiry_Date__c || cert1.Scope__c != oldCerts.get(cert1.Id).Scope__c || 
               cert1.Notes__c != oldCerts.get(cert1.Id).Notes__c || cert1.Address1__c != oldCerts.get(cert1.Id).Address1__c || cert1.Address2__c != oldCerts.get(cert1.Id).Address2__c || 
               cert1.Address3__c != oldCerts.get(cert1.Id).Address3__c || cert1.Town__c != oldCerts.get(cert1.Id).Town__c || cert1.Region__c != oldCerts.get(cert1.Id).Region__c || 
               cert1.Postcode__c != oldCerts.get(cert1.Id).Postcode__c || cert1.Country__c != oldCerts.get(cert1.Id).Country__c)){
                    updatedCerts.put(cert1.Id,cert1);
             }
        }
        if(!updatedCerts.isEmpty()){
            Map<Id,Certificate__c> certData = new Map<ID, Certificate__c>([Select Id,Account__r.Name,Account__r.IRQAO_Registrant_ID__c from Certificate__c where Id IN: updatedCerts.keySet()]);
            for(Id certId : certData.keySet()){
                postData(certData.get(certId),updatedCerts.get(certId),oldCerts.get(certId));
            }
        }
    }
    
    //Creates Json structure for posting details to IRQAO based on scenarios
    public static void postData(Certificate__c fetchedCert, Certificate__c cert, Certificate__c oldCert){
        String stand = [SELECT Name, Standard_Name__c from IRQAO_Standard_Code__c where Standard_Name__c =: cert.Standard__c Limit 1]?.Name;
        Integer standard = (stand == null) ? null : Integer.valueOf(stand);
        Boolean validCodes = checkForCodes(cert,standard);
        if(validCodes){
            if(fetchedCert.Account__r.IRQAO_Registrant_ID__c == null){
                sendToServer( new NewRegistrantCertificate(cert,standard,fetchedCert.Account__r.Name).toString());
            }
            else if(fetchedCert.Account__r.IRQAO_Registrant_ID__c != null && cert.Certificate_ID__c == null){
                sendToServer( new NewCertificate(cert,standard,fetchedCert).toString());
            }else if(fetchedCert.Account__r.IRQAO_Registrant_ID__c != null && cert.Certificate_ID__c != null){
                checkForExistingCert(fetchedCert,cert,oldCert,standard);
            }
        }
    }
    
    public static void checkForExistingCert(Certificate__c fetchedCert, Certificate__c cert, Certificate__c oldCert,Integer standard){
        if(cert.Status__c != oldCert.Status__c || cert.Current_Certificate_Date__c != oldCert.Current_Certificate_Date__c || 
           cert.Certificate_Expiry_Date__c != oldCert.Certificate_Expiry_Date__c || cert.Scope__c != oldCert.Scope__c){
               sendToServer( new ExistingCertificate(cert,standard).toString());
           }
        if(cert.Notes__c != oldCert.Notes__c || cert.Address1__c != oldCert.Address1__c || cert.Address2__c != oldCert.Address2__c || 
           cert.Address3__c != oldCert.Address3__c || cert.Town__c != oldCert.Town__c || cert.Region__c != oldCert.Region__c || 
           cert.Postcode__c != oldCert.Postcode__c || cert.Country__c != oldCert.Country__c){
               sendToServer( new ExistingRegistrant(cert,standard,fetchedCert).toString());
           }
    } 
    
    //Checks for valid Standard, Country and Status codes
    public static Boolean checkForCodes(Certificate__c cf,Integer standard){
        try{
            if(standard ==null){
                cf.Response_Status_Code__c = 400;
                cf.Error_Msg__c  = 'Standard not listed in IRQAO';
                return false;
            }else if(cf.Country__c != null && !String.isBlank(cf.Country__c) && (IRQAO_Country_Code__c.getValues(cf.Country__c)?.Country_Id__c) == null){
                cf.Response_Status_Code__c = 400;
                cf.Error_Msg__c  = 'Country not listed in IRQAO';
                return false;
            }else if(cf.Status__c != null && !String.isBlank(cf.Status__c) && (IRQAO_Status_Code__c.getValues(cf.Status__c)?.Status_Id__c) == null){
                cf.Response_Status_Code__c = 400;
                cf.Error_Msg__c  = 'Status not listed in IRQAO';
                return false;
            }
            return true;
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+ex.getMessage()); 
            return false;
        }
    }
    
    //Callout to Jitterbit for posting Certificate Details to IRQAO
    @future (callout=true)
    private static void sendToServer(String body) {
        if(irqaoMdt != null) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(irqaoMdt.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Authorization', getAuthorizationHeader()); //NOPMD
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            HttpResponse response = (new Http()).send(request);
        }
    }
    
    //Authorization Method for API
    private static String getAuthorizationHeader(){
        return 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(irqaoMdt.UserName__c + ':' + irqaoMdt.Password__c));
    }
    
    //When there is status change in Salesforce send the updates to Connect
    public static void sendUpdatesToConnect(List<Certificate__c> certs, Map<Id,Certificate__c> oldCerts){
        Profile pf = [Select Id,Name from Profile where Name='IRQAO Integration' WITH SECURITY_ENFORCED LIMIT 1];
        List<Certificate__c> certUpdates = new List<Certificate__c>();
        for(Certificate__c cert1 : certs){
            if(cert1.Status__c !=null && cert1.Status__c !='In-Progress' && cert1.Status__c != oldCerts.get(cert1.Id).Status__c
              && cert1.Connect_Reference_ID__c != null && !String.isBlank(cert1.Connect_Reference_ID__c) && userInfo.getProfileId() != pf.Id){
                    sendToServer(new CertificateConnectUpdates(cert1).toString());
             }
        }
    }
}