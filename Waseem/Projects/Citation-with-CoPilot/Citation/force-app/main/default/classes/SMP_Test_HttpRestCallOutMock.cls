@isTest
global with sharing class SMP_Test_HttpRestCallOutMock implements HttpCalloutMock {
    protected Integer statusCode;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;

    global SMP_Test_HttpRestCallOutMock (Integer code, String body) {
        this.statusCode = code;
        this.bodyAsString = body;
    }

    global SMP_Test_HttpRestCallOutMock (Integer code, String status, Blob body,
                                     Map<String, String> responseHeaders) {
        this.statusCode = code;
        this.status = status;
        this.bodyAsBlob = body;
        this.bodyAsString = null;
        this.responseHeaders = responseHeaders;
    }

    global HTTPResponse respond(HTTPRequest req) {
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
        
    global static void setMock(HttpCalloutMock mock) {
        Test.setMock(HttpCalloutMock.class, mock);
    }
}