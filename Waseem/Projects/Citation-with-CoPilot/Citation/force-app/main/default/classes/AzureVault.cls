Public class AzureVault {
    public Static FINAL STRING azureStripeCredAppEndpoint = 'https://salesforce-stripe-azkv.vault.azure.net/secrets/RestrictedSecretKey?api-version=2016-10-01';
    public Static FINAL STRING azureTestStripeCredAppEndpoint = 'https://salesforce-stripe-azkv.vault.azure.net/secrets/TestRestrictedSecretKey?api-version=2016-10-01';
    public static iHASCOStripeCreds getiHASCOStripeCreds(Boolean isSandbox){
        AzureVault__mdt azureVault = [select id,azureEndpoint__c,clientid__c,clientSecret__c,scope__c,grantType__c,header__c,azureStripeCredAppEndpoint__c,azureStripeCredAppTestEndpoint__c from AzureVault__mdt where DeveloperName = 'AzureStripe']; 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(azureVault.azureEndpoint__c);
        request.setMethod('GET');
        
        String payload = 'client_id='+EncodingUtil.urlEncode(azureVault.clientId__c,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(azureVault.clientSecret__c,'UTF-8')+'&scope='+EncodingUtil.urlEncode(azureVault.scope__c,'UTF-8')+'&grant_type='+EncodingUtil.urlEncode(azureVault.grantType__c,'UTF-8');
        
        request.setBody(payload);
        request.setHeader('Content-Type',azureVault.header__c);
        HttpResponse response = http.send(request);
        String authCode;
        for(String x : response.getHeaderKeys()){
            System.debug('response--> ' + x + 'value:'  + response.getHeader(x) );
        }
        
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            System.JSONToken x = parser.getCurrentToken();
            System.debug('parser-CurrentToken' + x);
            System.debug('JSONToken.FIELD_NAME: ' + JSONToken.FIELD_NAME);
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'access_token')) {
                    // Get the value.
                    parser.nextToken();
                    authCode = parser.getText();
                }
        }
        
        if(response.getStatusCode() == 200) {
            Http http1 = new Http();
            HttpRequest request1 = new HttpRequest();
            if(isSandbox){
                request1.setEndpoint(azureVault.azureStripeCredAppTestEndpoint__c);
            } else {
                request1.setEndpoint(azureVault.azureStripeCredAppEndpoint__c);
            }
            request1.setMethod('GET');
            string token = 'Bearer ' + authCode; 
            request1.setHeader('Authorization',token);
            HttpResponse response1 = http.send(request1);
            If (response1.getStatusCode() == 200) {
                string rtext = response1.getBody();
                system.debug('---> response2:' + rtext);
                iHASCOStripeCreds s = (iHASCOStripeCreds)json.deserialize(rtext,iHASCOStripeCreds.class);
                system.debug('s' + s);
                return s;
            }
            
        }
        
        return null;
    }
    
    public class iHASCOStripeCreds{
        public string value;
        public string id;                      
    }
}