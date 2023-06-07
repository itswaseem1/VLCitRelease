public class PartnerLogoToAtlas {
	public String Name;
	public String SalesForceId;
	public String LogoUrl;
	public Boolean IsDeleted;
	public String Description;
    public String ImageBase64String;
    
    @AuraEnabled
	public static Account accountDetails(Id accId){
        System.debug('Inside accountDetails Method');
        return [Select Id,Name,Partner_Logo_Link__c,Description from Account where Id=: accId];
    }
    @AuraEnabled
    public static void sendPartnerLogo(Id accId){
        System.debug('Inside sendPartnerLogo Method');
        Account acc = [Select Id,Name,Partner_Logo_Link__c,Description from Account where Id=: accId];
        String contentDocId = acc.Partner_Logo_Link__c.substringBetween('ContentDocument/','/view');
        System.debug('contentDocId---'+contentDocId);
        if(acc.Partner_Logo_Link__c.contains('069') && contentDocId!=null){
            ContentVersion cn = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocId AND IsLatest = true];
            PartnerLogoToAtlas partLogo = new PartnerLogoToAtlas();
            partLogo.Name = acc.Name;
            partLogo.SalesForceId = acc.Id;
            partLogo.LogoUrl = acc.Partner_Logo_Link__c;
            partLogo.Description = acc.Description;
            partLogo.ImageBase64String = EncodingUtil.base64Encode(cn.VersionData);
            partLogo.IsDeleted = false;
            Http shttp = new Http();
            HttpRequest partnerLogoRequest = new HttpRequest();
            
            partnerLogoRequest.setEndpoint(System.Label.PartnerLogoRequestEndpoint);
            partnerLogoRequest.setBody(json.serializepretty(partLogo));
            system.debug('Body---'+partnerLogoRequest.getBody());
            partnerLogoRequest.setMethod('POST');
            partnerLogoRequest.setHeader('Content-Type','application/json');
            partnerLogoRequest.setHeader('x-functions-key',System.Label.PartnerLogoRequestHeaderKey);
	    partnerLogoRequest.setTimeout(30000);
            HttpResponse partnerLogoResponse = shttp.send(partnerLogoRequest);
            System.debug(partnerLogoResponse.getStatusCode()+'----'+partnerLogoResponse.getStatus()+'---'+partnerLogoResponse.getBody());
            if(partnerLogoResponse.getStatusCode()!=200){
                throw new AuraHandledException('Error response from Atlas');
            }
        }else{
            throw new AuraHandledException('Logo link doesnt have valid Document Id');
        }
    }
}