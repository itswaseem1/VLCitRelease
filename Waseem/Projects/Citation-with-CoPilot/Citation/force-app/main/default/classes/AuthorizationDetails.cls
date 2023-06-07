/**
 * @File Name          : AuthorizationDetails.cls
 * @Description        : Fields of Azure Active Directory Authorization
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 06/10/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     06/10/2021               Priyanka                 Initial Version
 **/
@SuppressWarnings('PMD')
public class AuthorizationDetails {
    public String tenantId{get; set;}
    public String clientId{get; set;}
    public String clientSecret{get; set;}
    public String resource{get; set;}
    public String grantType{get; set;}
    public String userId{get; set;}
    
    public AuthorizationDetails(String companyName){
        Teams_Integration__mdt teamsMdt = Teams_Integration__mdt.getInstance(companyName);
        this.tenantId = teamsMdt?.Tenant_ID__c;
        this.clientId = teamsMdt?.Client_ID__c;
        this.clientSecret = teamsMdt?.Client_Secret__c;
        this.resource = teamsMdt?.Resource__c;
        this.grantType = teamsMdt?.Grant_Type__c;
        this.userId = teamsMdt?.Host_ID__c;
    }
}