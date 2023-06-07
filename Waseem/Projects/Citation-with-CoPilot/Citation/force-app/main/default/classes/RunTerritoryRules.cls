public class RunTerritoryRules implements Queueable, Database.AllowsCallouts  {
    public Set<String> accntIds = null;
    private String sessionId = null;    
    public void execute(QueueableContext context) {
	sessionId = Page.SessionIDHack.getContent().toString();     
        List<String> lstAccString = new List<String>();
        if(accntIds != null){
            for(String accId:accntIds){
                lstAccString.add(accountTag.replace('{ACCID}', accId)); 
            }
        } 
        requestTemplate = requestTemplate.replace('{ACCLISTS}', String.join(lstAccString, ' ')) ;
        requestTemplate = requestTemplate.replace('{SESSID}', sessionId) ;        
        HttpRequest request = new HttpRequest();
	request.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+
			    '/services/Soap/u/41.0/'+UserInfo.getOrganizationId());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
	request.setHeader('SOAPAction', '""');
        request.setBody(requestTemplate);
 	String s = String.valueOf(new Http().send(request).getBodyDocument());
        System.debug(s);
    }
    String accountTag = '<urn:sObjects> '+
                        	'<urn1:type>Account</urn1:type>  '+
        			'<urn1:Id>{ACCID}</urn1:Id>   '+
                    	'</urn:sObjects> ' ;    
    String requestTemplate = '<soapenv:Envelope '+
				'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+
				' xmlns:urn="urn:partner.soap.sforce.com"'+
				' xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
                                '<soapenv:Header> '+
                                  '<urn:AssignmentRuleHeader> '+ 
                                     '<urn:useDefaultRule>true</urn:useDefaultRule> '+
                                     '<urn:assignmentRuleId></urn:assignmentRuleId> '+
                                  '</urn:AssignmentRuleHeader>  '+
                                  '<urn:SessionHeader> '+
        				'<urn:sessionId>{SESSID}</urn:sessionId> '+
                                  '</urn:SessionHeader> '+
                               '</soapenv:Header> '+
                               '<soapenv:Body> '+
        			  '<urn:update> '+
        			   ' {ACCLISTS}'+ 
                                  '</urn:update> '+
                               '</soapenv:Body> '+
                            '</soapenv:Envelope>';

    public Static void TestCoverage( ) {
        Account acc = new Account();
        acc.Name = 'accName';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.FT_Employees__c = 10;
        acc.PT_Employees__c = 10;
        acc.BillingPostalCode = 'AZ1 ABC';
        acc.ShippingPostalCode = 'AZ1 ABC';
        ACC.MACV__c = 180;
      //acc.Number_of_Active_Sites__c = 1;
        acc.Sites__c = 1;
        
        Account acc2 = new Account();
        acc2.Name = 'accName';
        acc2.Phone = '09876543210';
        acc2.AnnualRevenue = 100000;
        acc2.FT_Employees__c = 10;
        acc2.PT_Employees__c = 10;
        acc2.BillingPostalCode = 'AZ1 ABC';
        acc2.ShippingPostalCode = 'AZ1 ABC';
        ACC2.MACV__c = 180;
      //acc.Number_of_Active_Sites__c = 1;
        acc2.Sites__c = 1;
        
        Account acc3 = new Account();
        acc3.Name = 'accName';
        acc3.Phone = '09876543210';
        acc3.AnnualRevenue = 100000;
        acc3.FT_Employees__c = 10;
        acc3.PT_Employees__c = 10;
        acc3.BillingPostalCode = 'AZ1 ABC';
        acc3.ShippingPostalCode = 'AZ1 ABC';
        ACC3.MACV__c = 180;
      //acc.Number_of_Active_Sites__c = 1;
        acc3.Sites__c = 1;
        
        Account acc4 = new Account();
        acc4.Name = 'accName';
        acc4.Phone = '09876543210';
        acc4.AnnualRevenue = 100000;
        acc4.FT_Employees__c = 10;
        acc4.PT_Employees__c = 10;
        acc4.BillingPostalCode = 'AZ1 ABC';
        acc4.ShippingPostalCode = 'AZ1 ABC';
        ACC4.MACV__c = 180;
      //acc.Number_of_Active_Sites__c = 1;
        acc4.Sites__c = 1;
        
        Account acc5 = new Account();
        acc5.Name = 'accName';
        acc5.Phone = '09876543210';
        acc5.AnnualRevenue = 100000;
        acc5.FT_Employees__c = 10;
        acc5.PT_Employees__c = 10;
        acc5.BillingPostalCode = 'AZ1 ABC';
        acc5.ShippingPostalCode = 'AZ1 ABC';
        ACC5.MACV__c = 180;
      //acc.Number_of_Active_Sites__c = 1;
        acc5.Sites__c = 1;
    }

}