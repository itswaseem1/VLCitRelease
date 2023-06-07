global class BDMAllocationTest implements HttpCalloutMock{
    
        global HTTPResponse respond(HTTPRequest request) {        
        string endpoint1 = request.getEndpoint();
        string method1 = request.getMethod();
        string endpoint = request.getEndpoint();
        string method = request.getMethod();
        HttpResponse response = new HttpResponse();
        string result1;
            if(endpoint1=='https://dsa49ipcik.execute-api.eu-west-2.amazonaws.com/dev/confirm-booking'){
                system.assertEquals('https://dsa49ipcik.execute-api.eu-west-2.amazonaws.com/dev/confirm-booking', endpoint1);
            system.assertEquals('POST', method1);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Hello from Lambda!');
            response.setStatusCode(200); 
            } 
            if(endpoint=='https://dsa49ipcik.execute-api.eu-west-2.amazonaws.com/dev/get-availability'){
                system.assertEquals('https://dsa49ipcik.execute-api.eu-west-2.amazonaws.com/dev/get-availability', endpoint);
            system.assertEquals('POST', method);            
            response.setHeader('Content-Type', 'application/json');            
            response.setStatusCode(200);
            }
        return response;
    }
}