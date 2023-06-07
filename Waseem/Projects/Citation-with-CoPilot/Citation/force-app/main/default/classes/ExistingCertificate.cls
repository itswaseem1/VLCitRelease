/**
 * @File Name          : ExistingCertificate.cls
 * @Description        : Schema for sending the existing certificate updates to IRQAO 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka              Initial Version
 **/
public without sharing class ExistingCertificate {
	public String referenceNumber{get; set;}
    public Integer certificateStatus{get; set;}
    public Integer standard{get; set;}
    public String scope{get; set;}
    public Date issueDate{get; set;}
    public Date lastCertificationDate{get; set;}
    public Integer expiryPeriod{get; set;}
    public Date customExpiryDate{get; set;}
    public Integer certificateId{get; set;}
    public String recordId{get; set;}
    public Integer flag{get; set;}
    
    public ExistingCertificate(Certificate__c cert,Integer certStandard){
        IRQAO_Certificate_Defaults__c irqao = IRQAO_Certificate_Defaults__c.getValues('NewCertificate');
        this.referenceNumber = cert.Certificate_Number__c;
        this.certificateStatus = Integer.valueOf(IRQAO_Status_Code__c.getValues(cert.Status__c)?.Status_Id__c);
        this.standard = certStandard;
        this.scope = cert.Scope__c;
        this.issueDate = cert.Original_Certificate_Date__c;
        this.lastCertificationDate = cert.Current_Certificate_Date__c;
        this.expiryPeriod = Integer.valueOf(irqao.ExpiryPeriod__c);
        this.customExpiryDate = cert.Certificate_Expiry_Date__c;
        this.certificateId = Integer.valueOf(cert.Certificate_ID__c);
        this.recordId = cert.Id;
        this.flag = 3;
    }
    
    public override String toString() {
       return JSON.serialize(this);
    }
}