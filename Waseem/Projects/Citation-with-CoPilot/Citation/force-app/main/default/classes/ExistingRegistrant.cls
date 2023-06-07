/**
 * @File Name          : ExistingRegistrant.cls
 * @Description        : Schema for sending the existing registrant updates to IRQAO 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class ExistingRegistrant {
	public String name{get; set;}
    public String address1{get; set;}
    public String address2{get; set;}
    public String address3{get; set;}
    public String town{get; set;}
    public String region{get; set;}
    public String postcode{get; set;}
    public Integer country{get; set;}
    public Boolean suppressEmail{get; set;}
    public String notes{get; set;}
    public Integer registrantId{get; set;}
    public String recordId{get; set;}
    public Integer flag{get; set;}
    
    public ExistingRegistrant(Certificate__c cert,Integer certStandard,Certificate__c fetchedCert){
        IRQAO_Certificate_Defaults__c irqao = IRQAO_Certificate_Defaults__c.getValues('NewCertificate');
        this.name = fetchedCert.Account__r.Name;
        this.address1 = cert.Address1__c;
        this.address2 = cert.Address2__c;
        this.address3 = cert.Address3__c;
        this.town = cert.Town__c;
        this.region = cert.Region__c;
        this.postcode = cert.Postcode__c;
        this.country = Integer.valueOf(IRQAO_Country_Code__c.getValues(cert.Country__c)?.Country_Id__c);
        this.suppressEmail = irqao.SuppressEmail__c;
        this.notes = cert.Notes__c;
        this.registrantId = Integer.valueOf(fetchedCert.Account__r.IRQAO_Registrant_ID__c);
        this.recordId = cert.Id;
        this.flag = 4;
    }
    
    public override String toString() {
        return JSON.serialize(this);
    }
}