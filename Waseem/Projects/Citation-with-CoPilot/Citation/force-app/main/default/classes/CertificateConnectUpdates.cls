/**
 * @File Name          : CertificateConnectUpdates.cls
 * @Description        : Schema for sending the Certificate updates to Connect 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 19/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     19/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class CertificateConnectUpdates {
	public String refNumber{get; set;}
    public String status{get; set;}
    public Integer flag{get; set;}
    public String connectRefId{get; set;}
    
    public CertificateConnectUpdates(Certificate__c cert){
        this.refNumber = cert.Name;
        this.status = cert.Status__c;
        this.flag = 5;
        this.connectRefId = cert.Connect_Reference_ID__c;
    }
     
    public override String toString() {
        return JSON.serialize(this);
    }
}