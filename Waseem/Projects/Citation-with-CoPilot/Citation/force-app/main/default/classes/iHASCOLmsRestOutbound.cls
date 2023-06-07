public class iHASCOLmsRestOutbound {
	
    private iHASCOLms__mdt settings;
    private String Endpoint = '';
    private String bearerToken = '';
    private String authorizationHeader = 'Bearer ';
    private HttpResponse res;
    private Map<String,String> LmsData = new Map<String, String>();
    private Datetime dataTimestamp;       
    private static final Integer TIMEOUT_MS = 30000;   
    private Boolean successSoFar = true;
    private id recid;
    private set<id> credSub = new Set<id>();
    public static Boolean raiseExceptionTestClass1 = false;
    public static Boolean raiseExceptionTestClass2 = false;
    
    private static final Integer MAX_ERROR_LENGTH = 1000;
    @TestVisible private static final String ERROR_MSG_HTTP = 'Non 200 status code received at ';
    @TestVisible private static final String ERROR_MSG = 'Unable to process LMS Data';
    
    public iHASCOLmsRestOutbound() {
        getGeneralSettings();
    }
      
    private void getGeneralSettings() {  
        if(OrgInstanceCheck.runningInASandbox()){
            iHASCOLms__mdt settings = iHASCOLms__mdt.getInstance('Test');
			this.settings = settings;
        } else {
            iHASCOLms__mdt settings = iHASCOLms__mdt.getInstance('Prod');
        this.settings = settings;
        }
        this.Endpoint = settings.URL__c;
        this.bearerToken = settings.BearerToken__c;
    }
    
    private HttpRequest setupCall() {
        
        this.authorizationHeader += this.bearerToken;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.Endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json'); 
        req.setTimeout(TIMEOUT_MS);
        
        return req;
    }
     
    
    public void sendLMSData(id recordid, String eventType) {
        if(Label.iHascoLMSTriggerSwitch == 'true'){
            String objName = recordid.getsobjecttype().getDescribe().getName();
            List<Database.SaveResult> results;
            HttpRequest req;        
            if (successSofar) req = setupCall();
            if(objName == 'Order'){           
            if (successSofar) req = buildOrderRequest(req , recordId , eventType);
            } else if(objName == 'Contract'){
            if (successSofar) req = buildContractRequest(req , recordId , eventType);
            } else if(ObjName == 'Account'){
            if (successSofar) req = buildAccountRequest(req , recordId , eventType);    
            } 
            else {
                successSofar = false;
            }
            if (successSofar) sendRequest(req);
            if (successSofar) parseResponse(res,req);   
        }   
    }
    
    private HttpRequest buildContractRequest(HttpRequest req, id recordId, string eventType) {
        recid = recordId;
        List<Contract> records = [SELECT id,License_Model__c,ContractNumber,StartDate,EndDate,
                                  SBQQ__Opportunity__c,AccountId,Account.Name,Account.LMS_ID__c,SBQQ__Quote__r.SBQQ__PrimaryContact__c,
                                  SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName,
                                  SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone,
                                  Owner.FirstName,Owner.LastName,Owner.Email,Owner.Phone,Account.ParentId,Account.Parent.LMS_ID__c,
                                  (SELECT Id,CreatedDate,SBQQ__Quantity__c,Name,SBQQ__Contract__c,SBQQ__ContractNumber__c,
                                  SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__ProductName__c,ProductCode__c,Bespoke_products__c,
                                   ParentProductCode__c,Service_Start_Date__c,Service_End_Date__c,SBQQ__RequiredById__c,Purchase_Data_Time__c,
                                  Ihasco_Number_of_Credits__c,iHasco_Number_of_Users__c,SBQQ__RevisedSubscription__c,SBQQ__Contract__r.ActivatedDate
                                  FROM sbqq__Subscriptions__r)
                                  FROM Contract where id = :recordId];
        List<site__c> sites = new List<site__c>();
        For(Site__c site: [SELECT id,name,city__c, street__c,Active__c from Site__c where Account__c = :records[0].AccountId]){
            sites.add(site);
        }
        iHASCOLmsWrapper wrap = new iHASCOLmsWrapper(records[0] , sites,eventType);
        storeSubscriptionids(records[0]);
        String JSONString = (JSON.serializePretty(wrap));
        system.debug(JSONString);
        req.setBody(JSONString);
        return req;
    }
    
    private HttpRequest buildOrderRequest(HttpRequest req, Id recordId, string eventType) {
        recid = recordId;
        List<Order> records = [SELECT id,License_Model__c,OrderNumber,EffectiveDate,EndDate,OpportunityId,AccountId,
                               Account.Name,Account.LMS_ID__c,SBQQ__Quote__r.SBQQ__PrimaryContact__c,
                               SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName,
                               SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone,
                               Owner.FirstName,Owner.LastName,Owner.Email,Owner.Phone,SBQQ__Quote__r.SBQQ__Opportunity2__c,
                               Account.ParentId,Account.Parent.LMS_ID__c,
                               (SELECT Id, Product2.productCode, OrderItemNumber, Quantity,OrderId,Order.OrderNumber,ServiceDate,
                               EndDate,Product2.Name,ParentProductCode__c,iHasco_Number_of_Users__c,SBQQ__RequiredBy__c,Bespoke_products__c,
                               Order.ActivatedDate,Ihasco_Number_of_Credits__c FROM OrderItems)
                               FROM Order where id = :recordId];
        
        List<site__c> sites = new List<site__c>();
        For(Site__c site: [SELECT id,name,city__c, street__c,Active__c from Site__c where Account__c = :records[0].AccountId]){
            sites.add(site);
        }
        iHASCOLmsWrapper wrap = new iHASCOLmsWrapper(records[0] , sites, eventType);
        String JSONString = (JSON.serializePretty(wrap));
        req.setBody(JSONString);
        return req;
    }
    
    private HttpRequest buildAccountRequest(HttpRequest req, id recordId, string eventType) {
        recid = recordId;
        List<Account> records = [SELECT id,iHASCO_Finance_Status__c,LMS_ID__c,iHASCO_Account_Manager__r.FirstName,
                                 iHASCO_Account_Manager__r.LastName,iHASCO_Account_Manager__r.Email,
                               (SELECT Id  FROM Contracts)
                               FROM Account where id = :recordId];
        String JSONString ;
        if(eventType == System.Label.iHASCOAccountStatusChangeEvent){
            iHASCOLmsAccountStatus wrap = new iHASCOLmsAccountStatus(records[0] ,  eventType);
            JSONString = (JSON.serializePretty(wrap));
        } else if(eventType == Label.iHASCO_Account_Owner_change_Event_to_LMS ){
            iHASCOLmsAccountOwnerChangeWrapper wrap = new iHASCOLmsAccountOwnerChangeWrapper(records[0] ,  eventType);
            JSONString = (JSON.serializePretty(wrap));
        }
        req.setBody(JSONString);
        return req;
    }
    
    private void sendRequest(HttpRequest req) {
        
        Http http = new Http();
                
        try {           
            this.dataTimestamp = Datetime.now();
       	    res = http.send(req);
	    if(Test.isRunningTest() && raiseExceptionTestClass1){
                throw new AuraHandledException('Message');
            }
        }
        catch (Exception e) {
            System.debug('Exception message' + e.getMessage());
            String message = ERROR_MSG + e.getMessage();
            
            ApplicationLog__c apl = new ApplicationLog__c();
            apl.name = 'iHASCO LMS Request Failed' + Datetime.Now();
            apl.recordId__c = this.recId;
            apl.message__c = req.getBody();
            apl.Response__c = message;
            insert apl;
            successSofar = false;
            
            String objName = this.recId.getsobjecttype().getDescribe().getName();
            if(objName == 'Contract'){
            Contract con = new Contract();
            con.id = this.recid;
                con.LMS_payload_status__c = 'Failed';
            update con;
            } else if(objName == 'Order'){
                Order ord = new Order();
                ord.id = this.recid;
                ord.LMS_payload_status__c = 'Failed';
                update ord;
            } else if(objName == 'Account'){
                updateAccount('Failed');
            }
    }
    }
    
    private void parseResponse(HTTPResponse res, HTTPRequest req) {
        
        try {
            if(Test.isRunningTest() && raiseExceptionTestClass2){
                throw new AuraHandledException('Message');
            }
            if (res.getStatusCode() == 200) {        
                String objName = this.recId.getsobjecttype().getDescribe().getName();
                if(objName == 'Contract'){
                    Contract con = new Contract();
                    con.id = this.recid;
                    con.LMS_payload_status__c = 'Success';
                    update con;
                    
                    List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
                    for(id sId : credSub){
                        SBQQ__Subscription__c sc = new SBQQ__Subscription__c();
                        sc.id = sId;
                        sc.Purchase_Data_Time__c = System.now();
                        subs.add(sc);
                    }
                    if(!subs.isEmpty()){
                        update subs;
                    }
                        
                } else if(objName == 'Order'){
                    Order ord = new Order();
                    ord.id = this.recid;
                    ord.LMS_payload_status__c = 'Success';
                    update ord;
                } else if(objName == 'Account'){
                    updateAccount('Success');
                }
                if(System.Label.iHASCOLMSLogSuccess == 'Y'){
                    logLines(true,req,res.getBody());
                }
            }
            else {
                ApplicationLog__c apl = new ApplicationLog__c();
                apl.name = 'iHASCO LMS Request Failed' + Datetime.Now();
                apl.recordId__c = this.recId;
                apl.message__c = req.getBody();
                if(res != null){
                    apl.Response__c = res.getBody();
                }
                insert apl;
                String objName = this.recId.getsobjecttype().getDescribe().getName();
                if(objName == 'Contract'){
                Contract con = new Contract();
                con.id = this.recid;
                    con.LMS_payload_status__c = 'Failed';
                update con;
                } else if(objName == 'Order'){
                    Order ord = new Order();
                    ord.id = this.recid;
                    ord.LMS_payload_status__c = 'Failed';
                    update ord;
                } else if(objName == 'Account'){
                    updateAccount('Failed');
                }
                successSofar = false;
            }
	    
        }
        catch (Exception e) {
            
            String message = ERROR_MSG + e.getMessage();
            ApplicationLog__c apl = new ApplicationLog__c();
            apl.name = 'iHASCO LMS Request Failed' + Datetime.Now();
            apl.recordId__c = this.recId;
            apl.message__c = req.getBody();
            apl.Response__c = message;
            insert apl;
            String objName = this.recId.getsobjecttype().getDescribe().getName();
            if(objName == 'Contract'){
            Contract con = new Contract();
            con.id = this.recid;
                con.LMS_payload_status__c = 'Failed';
            update con;
            }  else if(objName == 'Order'){
                Order ord = new Order();
                ord.id = this.recid;
                ord.LMS_payload_status__c = 'Failed';
                update ord;
            } else if(objName == 'Account'){
                   updateAccount('Failed');
                }
			successSofar = false;
        } 
    }
    
    private void updateAccount(String Status){
                    Account acc = new Account();
                    acc.id = this.recid;
                    acc.LMS_payload_status__c = Status;
                    update acc;
    }
        
    private void logLines(Boolean success,Httprequest req, string message){
        ApplicationLog__c apl = new ApplicationLog__c();
        if(success){
            apl.name = 'iHASCO LMS Request Success' + Datetime.Now();
        } else {
            apl.name = 'iHASCO LMS Request Failed' + Datetime.Now();
        }
        apl.message__c = req.getBody();
        apl.Response__c = message;
        insert apl;
    }
    
    private void storeSubscriptionids(Contract contr){
        for(SBQQ__Subscription__c sc :Contr.SBQQ__Subscriptions__r){
            if( ((sc.ProductCode__c == System.Label.iHASCOCreditProductCode) || sc.ProductCode__c.Startswith('IH-RPM'))
               && (sc.Purchase_Data_Time__c == NULL)){
                this.credSub.add(sc.id);
            }
        }
    }
    
    private class iHASCOLmsRestOutboundException extends Exception {}
    
    //Need to cover code coverage for this class. This is just to increase the coverage tempoarily.
    
}