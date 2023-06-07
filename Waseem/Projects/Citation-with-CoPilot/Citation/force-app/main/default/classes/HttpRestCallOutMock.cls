/**
 *	@author: Paul Harvie (Income Systems)
 *	@date: 2013-06-15  
 *	@description:
 *		Controller TEST for Direct Debit Sort Code Account code validation component
 *
 *	
 *	Version History :   
 *		
 */

@isTest
public with sharing class HttpRestCallOutMock implements HttpCalloutMock {
		protected Integer statusCode;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public HttpRestCalloutMock(Integer code, String body) {
			this.statusCode = code;
			this.bodyAsString = body;
		}

		public HttpRestCalloutMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.statusCode = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
	        
	        if (statusCode != null){
				resp.setStatusCode(statusCode);
	        }
	        
	        if (status != null){
	        	resp.setStatus(status);
	        }
	        
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}