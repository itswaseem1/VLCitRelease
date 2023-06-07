global with sharing class bg_GAMockInterface {
   
	global class bg_GAMockRespond implements HttpCalloutMock {

	    // Implement this interface method
	    global HTTPResponse respond(HTTPRequest req) {       
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{'+
						  '"hitParsingResult": [ {'+
						    '"valid": true,'+
						    '"parserMessage": [ ],'+
						    '"hit": "/debug/collect?v=1\\u0026tid=UA-59406007-4\\u0026t=event\\u0026ec=salesforce\\u0026ea=contract%20renewal\\u0026ni=1\\u0026pa=purchase?cid=1\\0026ti=00022088\\u0026tr=10000.00\\u0026tcc=0.00\\u0026pr1nm=Product\\u0026pr1pr=10000.00\\u0026pr1qt=1\\u0026pr1cc=0.00\\u0026z=921e94467bcb9bfc1064e18ea77e000b"'+
						  '} ],'+
						  '"parserMessage": [ {'+
						    '"messageType": "INFO",'+
						    '"description": "Found 1 hit in the request."'+
						  '} ]'+
						'}'
			);
	        res.setStatusCode(200);
	        return res;
	    }
	}

}