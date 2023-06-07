/**
* @author Nimil Christopher
* @date 12 August 2013
* @description This class contains unit tests for validating the behaviour of the HTTPHelper class
*  
*/
@isTest
public class CIT_PH1_HTTPManager_Test {

    /**
    * @author Nimil Christopher
    * @date 12 August 2013
    * @description Test to simulate a mock callout from HTTPHelper class
    * @return null
    * @param null
    */
    @isTest
    private static void HTTPManager_SendJSONList_isJSONSent() {
        
        String expectedResponseJson = '[{"attributes":{"type":"Account","url":"/services/data/v28.0/sobjects/Account/001c000000Q0qHyAAJ"},"Finance_Approved__c":false,"isConverted__c":false,"Account_External_Id__c":null,"Description":null,"Fax":null,"Website":null,"Town_City__c":null,"Total_Employees__c":null,"TickerSymbol":null,"SystemModstamp":"2013-08-15T15:22:38.000+0000","Subcontractors__c":null,"Street__c":null,"BillingStreet":null,"Sort_Code__c":null,"Signatory__c":null,"SicDesc":null,"Sic":null,"ShippingPostalCode":null,"ShippingStreet":null,"ShippingState":null,"ShippingCountry":null,"ShippingCity":null,"Sector__c":null,"Sage_Code__c":null,"Renewal_Date__c":null,"PT_Employees__c":null,"Post_Code__c":null,"BillingPostalCode":null,"Payroll_Amt__c":null,"PAYE_Notes__c":null,"ParentId":null,"Ownership":null,"OwnerId":"005D00000036sdJIAQ","Notes__c":null,"LastModifiedDate":"2013-08-15T15:22:38.000+0000","LastModifiedById":"005D00000036sdJIAQ","Industry":null,"Health_and_Safety_Overview__c":null,"FT_Employees__c":null,"NumberOfEmployees":null,"Directors__c":null,"IsDeleted":false,"DD_Mandate_Signature_Date__c":null,"Current_Third_Party_Product__c":null,"CreatedDate":"2013-08-15T15:22:38.000+0000","CreatedById":"005D00000036sdJIAQ","County__c":null,"BillingState":null,"BillingCountry":null,"BillingCity":null,"Bank_Building_Society__c":null,"AnnualRevenue":null,"Type":null,"AccountSource":null,"Site":null,"Rating":null,"Phone":null,"Account_Number__c":null,"AccountNumber":null,"Account_Holder_Name_1__c":null,"Account_Holder_Name_2__c":null,"Id":"001c000000Q0qHyAAJ","Contacts":null,"Opportunities":null}]';
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('jsonResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        List<String> listOFStrings = new List<String>();
        listOFStrings.add(expectedResponseJson);
        
        Test.startTest();
            CWS_Integration__c integrationSetting = CWS_Integration__c.getValues('Host');
  
            if(integrationSetting == null) {
                integrationSetting = new CWS_Integration__c(Name= 'Host');
                integrationSetting.RemoteServer__c = 'Test';
                insert integrationSetting;
            }
            CIT_PH1_HTTPManager.sendJSONListToServer('INSERT_ACCOUNT', listOFStrings);
        Test.stopTest();
        //assert that parser got the fake response
   //     System.assertEquals(200,CIT_PH1_HTTPManager.httpResponse.getStatusCode());
   //     System.assertEquals(expectedResponseJson, CIT_PH1_HTTPManager.httpResponse.getBody());
    }
    
     @isTest
    private static void HTTPManager_SendJSONList_UnsuccessfullSend() {
        
        String expectedResponseJson = '[{"attributes":{"type":"Account","url":"/services/data/v28.0/sobjects/Account/001c000000Q0qHyAAJ"},"Finance_Approved__c":false,"isConverted__c":false,"Account_External_Id__c":null,"Description":null,"Fax":null,"Website":null,"Town_City__c":null,"Total_Employees__c":null,"TickerSymbol":null,"SystemModstamp":"2013-08-15T15:22:38.000+0000","Subcontractors__c":null,"Street__c":null,"BillingStreet":null,"Sort_Code__c":null,"Signatory__c":null,"SicDesc":null,"Sic":null,"ShippingPostalCode":null,"ShippingStreet":null,"ShippingState":null,"ShippingCountry":null,"ShippingCity":null,"Sector__c":null,"Sage_Code__c":null,"Renewal_Date__c":null,"PT_Employees__c":null,"Post_Code__c":null,"BillingPostalCode":null,"Payroll_Amt__c":null,"PAYE_Notes__c":null,"ParentId":null,"Ownership":null,"OwnerId":"005D00000036sdJIAQ","Notes__c":null,"LastModifiedDate":"2013-08-15T15:22:38.000+0000","LastModifiedById":"005D00000036sdJIAQ","Industry":null,"Health_and_Safety_Overview__c":null,"FT_Employees__c":null,"NumberOfEmployees":null,"Directors__c":null,"IsDeleted":false,"DD_Mandate_Signature_Date__c":null,"Current_Third_Party_Product__c":null,"CreatedDate":"2013-08-15T15:22:38.000+0000","CreatedById":"005D00000036sdJIAQ","County__c":null,"BillingState":null,"BillingCountry":null,"BillingCity":null,"Bank_Building_Society__c":null,"AnnualRevenue":null,"Type":null,"AccountSource":null,"Site":null,"Rating":null,"Phone":null,"Account_Number__c":null,"AccountNumber":null,"Account_Holder_Name_1__c":null,"Account_Holder_Name_2__c":null,"Id":"001c000000Q0qHyAAJ","Contacts":null,"Opportunities":null}]';
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('jsonResponse');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        List<String> listOFStrings = new List<String>();
        listOFStrings.add(expectedResponseJson);
        
        Test.startTest();
            CWS_Integration__c integrationSetting = CWS_Integration__c.getValues('Host');
  
            if(integrationSetting == null) {
                integrationSetting = new CWS_Integration__c(Name= 'Host');
                integrationSetting.RemoteServer__c = 'Test';
                integrationSetting.Error_Email__c = 'test@test.co.uk';
                insert integrationSetting;
            }
            CIT_PH1_HTTPManager.sendJSONListToServer('INSERT_ACCOUNT', listOFStrings);
        Test.stopTest();
        //assert that parser got the fake response
   //     System.assertEquals(404,CIT_PH1_HTTPManager.httpResponse.getStatusCode());
       
    }
    
    @isTest
     private static void HTTPManager_SendJSONList_isJSONSent_Exception() {
         String exceptionMessage = '';
         String expectedResponseJson = '[{"attributes":{"type":"Account","url":"/services/data/v28.0/sobjects/Account/001c000000Q0qHyAAJ"},"Finance_Approved__c":false,"isConverted__c":false,"Account_External_Id__c":null,"Description":null,"Fax":null,"Website":null,"Town_City__c":null,"Total_Employees__c":null,"TickerSymbol":null,"SystemModstamp":"2013-08-15T15:22:38.000+0000","Subcontractors__c":null,"Street__c":null,"BillingStreet":null,"Sort_Code__c":null,"Signatory__c":null,"SicDesc":null,"Sic":null,"ShippingPostalCode":null,"ShippingStreet":null,"ShippingState":null,"ShippingCountry":null,"ShippingCity":null,"Sector__c":null,"Sage_Code__c":null,"Renewal_Date__c":null,"PT_Employees__c":null,"Post_Code__c":null,"BillingPostalCode":null,"Payroll_Amt__c":null,"PAYE_Notes__c":null,"ParentId":null,"Ownership":null,"OwnerId":"005D00000036sdJIAQ","Notes__c":null,"LastModifiedDate":"2013-08-15T15:22:38.000+0000","LastModifiedById":"005D00000036sdJIAQ","Industry":null,"Health_and_Safety_Overview__c":null,"FT_Employees__c":null,"NumberOfEmployees":null,"Directors__c":null,"IsDeleted":false,"DD_Mandate_Signature_Date__c":null,"Current_Third_Party_Product__c":null,"CreatedDate":"2013-08-15T15:22:38.000+0000","CreatedById":"005D00000036sdJIAQ","County__c":null,"BillingState":null,"BillingCountry":null,"BillingCity":null,"Bank_Building_Society__c":null,"AnnualRevenue":null,"Type":null,"AccountSource":null,"Site":null,"Rating":null,"Phone":null,"Account_Number__c":null,"AccountNumber":null,"Account_Holder_Name_1__c":null,"Account_Holder_Name_2__c":null,"Id":"001c000000Q0qHyAAJ","Contacts":null,"Opportunities":null}]';        
         Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());

        List<String> listOFStrings = new List<String>();
        listOFStrings.add(expectedResponseJson);
        
        Test.startTest();
            CWS_Integration__c integrationSetting = CWS_Integration__c.getValues('Host');
  
            if(integrationSetting == null) {
                integrationSetting = new CWS_Integration__c(Name= 'Host');
                integrationSetting.RemoteServer__c = 'Test';
                integrationSetting.Error_Email__c = 'test@test.co.uk';
                insert integrationSetting;
            }
         try{
            CIT_PH1_HTTPManager.sendJSONListToServer('INSERT_ACCOUNT', listOFStrings);
         }Catch (Exception e){
             system.debug(e.getMessage());
         }
         
        Test.stopTest();
        //assert that parser got the fake response
        System.assertEquals(NULL,CIT_PH1_HTTPManager.httpResponse);
        
    }
    
    @TestVisible class UnauthorizedEndpointResponse implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        throw e;
    }
}
    
    

}