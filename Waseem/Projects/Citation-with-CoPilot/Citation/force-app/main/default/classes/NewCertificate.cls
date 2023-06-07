/**
 * @File Name          : NewCertificate.cls
 * @Description        : Schema for sending the new certificate updates to IRQAO 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class NewCertificate {
    public String referenceNumber{get; set;}
    public Integer certificateStatus{get; set;}
    public Integer standard{get; set;}
    public String scope{get; set;}
    public Date issueDate{get; set;}
    public Integer expiryPeriod{get; set;}
    public Date customExpiryDate{get; set;}
    public Integer certificateTemplate{get; set;}
    public Boolean showInSearchResults{get; set;}
    public Boolean autoRenew{get; set;}
    public Boolean privateField{get; set;}
    public Boolean hideName{get; set;}
    public Boolean hideCertificateDetails{get; set;}
    public Boolean hideRegistrantAddress{get; set;}
    public Boolean hideRegistrantDetails{get; set;}
    public Integer registrantId{get; set;}
    public String recordId{get; set;}
    public String name{get; set;}
    public String town{get; set;}
    public Integer country{get; set;}
    public Boolean suppressEmail{get; set;}
    public Integer flag{get; set;}
    
    public NewCertificate(Certificate__c cert,Integer certStandard,Certificate__c fetchedCert){
        IRQAO_Certificate_Defaults__c irqao = IRQAO_Certificate_Defaults__c.getValues('NewCertificate');
        this.referenceNumber = cert.Certificate_Number__c;
        this.certificateStatus = Integer.valueOf(IRQAO_Status_Code__c.getValues(cert.Status__c)?.Status_Id__c);
        this.standard = certStandard;
        this.scope = cert.Scope__c;
        this.issueDate = cert.Original_Certificate_Date__c;
        this.expiryPeriod = Integer.valueOf(irqao.ExpiryPeriod__c);
        this.customExpiryDate = cert.Certificate_Expiry_Date__c;
        this.registrantId = Integer.valueOf(fetchedCert.Account__r.IRQAO_Registrant_ID__c);
        this.certificateTemplate = Integer.valueOf(irqao.CertificateTemplate__c);
        this.showInSearchResults = irqao.ShowInSearchResults__c;
        this.autoRenew = irqao.AutoRenew__c;
        this.privateField = irqao.Private__c;
        this.hideName = irqao.HideName__c;
        this.hideCertificateDetails = irqao.HideCertificateDetails__c;
        this.hideRegistrantAddress = irqao.HideRegistrantAddress__c;
        this.hideRegistrantDetails = irqao.HideRegistrantDetails__c;
        this.recordId = cert.Id;
        this.name = fetchedCert.Account__r.Name;
        this.town = cert.Town__c;
        this.country = Integer.valueOf(IRQAO_Country_Code__c.getValues(cert.Country__c)?.Country_Id__c);
        this.suppressEmail = irqao.SuppressEmail__c;
        this.flag = 2;
    }
    
    public override String toString() {
        return JSON.serialize(this);
    }
}