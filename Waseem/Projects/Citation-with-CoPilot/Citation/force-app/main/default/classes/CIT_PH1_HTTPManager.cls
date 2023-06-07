/**
* @author Nimil Christopher
* @date 29 May 2013
* @description This class has the Rest Callouts to send records to CWS
*/
public with sharing class CIT_PH1_HTTPManager {
    /**
    * @description Http Variable
    */
    public static Http http;
    /**
    * @description httpRequest variable
    */
    public static HttpRequest httpRequest;
    /**
    * @description httpResponse variable
    */
    public static HttpResponse httpResponse;
    /**
    * @description isApexTest - set to true when running tests
    */
    public static boolean isApexTest = false;
    /**
    * @description jsonList - json string to send to server
    */
    public static String jsonList;
    /**
    * @description host - this is where the jsonList will be sent too
    */
    public static String host ;
    
    /**
    * @author Nimil Christopher
    * @date 29 May 2013
    * @description (Future method) - send a list of object records to CWS
    * @return void
    * @param stringList: List of object recordsz, Action: Type of db activity
    */  
    @future(callout=true)
    public static void sendJSONListToServer(String Action,  List<String> stringList) {
        if(!isApexTest && (stringList.size() > 0) && !System.isBatch() && !System.isFuture() && !System.isScheduled()) {
  /*          host = String.valueOf(CWS_Integration__c.getValues('Host').get('RemoteServer__c'));
            setHttpRequestParameters();
            if(stringList.size() > 0 || stringlist != null){
                buildJsonString(stringList);
            }
            setRequestBody(Action);
            try{
            	httpResponse = http.send(httpRequest);
            	checkResponse();
            }catch (Exception e){
            	checkExceptionResponse(e);
            } */
        } 
    }
    /**
    *
    */
 /*   private static void checkExceptionResponse(Exception e){
    	if( e !=null){
    		CIT_PH1_EmailHandler.sendMail(e.getMessage(), jsonList);
    	}
    } */
    
 /*   private static void checkResponse(){
    	if( httpResponse != null && httpResponse.getStatusCode() >= 300){
    		CIT_PH1_EmailHandler.sendMail(httpResponse.getStatus(), jsonList);	
    	}
    } */

    /**
    * @author Nimil Christopher
    * @date 29 May 2013
    * @description set the RequestParameters for the HTTP member
    * @return void
    */
 /*   private static void setHttpRequestParameters(){
        http = new Http();
        httpRequest = new HttpRequest();
        httpRequest.setEndpoint(host);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
    } */
    /**
    * @author Nimil Christopher
    * @date 29 May 2013
    * @description build a string to send as json
    * @return void
    * @param stringList: List of object records
    */
 /*   private static void buildJsonString(List<String> stringList){
        jsonList =  '['; //Create jsonObject String
        if(stringList != null){
            for(String eachString : stringList){
                jsonList += eachString + ',';
            }
        }
    } */
    /**
    * @author Nimil Christopher
    * @date 29 May 2013
    * @description set the request payload
    * @return void
    */
/*    private static void setRequestBody(String Action){
        if(jsonList.length() > 0){
          jsonList = jsonList.subString(0, jsonList.length() - 1);
          jsonList += ']'; //Close jsonObject String
        }
        httpRequest.setBody('{"Action":"'+Action+'", "JSONRecord":'+jsonList+'}'); 
        System.DEBUG('Nimil String : ' + jsonList);
        System.DEBUG('Nimil : ' + httpRequest.getBody());
    } */
}