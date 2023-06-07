/**********************************************************************
* bg_FmIntHttpQueueableCallout:
*
* Class to send a json message to the FileMaker Web Service
* Created By: SA
* Created Date: 09-02-2016
*
* Changes: 
***********************************************************************/


public class bg_FmIntHttpQueueableCallout {

    static Map<String, String> cntId2ExtIdMap = new Map<String, String>();

    static void ifId2ExtIdMappingExistsThenCopy(List<Contact> cntList) {
        for(Contact c : cntList) {
            if(c.FM_Contact_External_Id__c == null && cntId2ExtIdMap.containsKey(c.Id)) {
                c.FM_Contact_External_Id__c = cntId2ExtIdMap.get(c.Id);
                System.debug('ifId2ExtIdMappingExistsThenCopy hit# id:' + c.Id + ' ext_id:' + c.FM_Contact_External_Id__c);
           }
        }
    }


    /**
     * Invoke with: ID jobId = System.enqueueJob(new HttpQueueableClass()); 
     */
    public class HttpQueueableClass implements Queueable,  Database.AllowsCallouts {
        String type;
        String action;
        List<Opportunity> oppList;
        List<Contact> cntList;

        public HttpQueueableClass(String type, String action, List<Contact> cntList) {
            this.type = type;
            this.action = action;
            this.cntList = cntList;
        }

        public HttpQueueableClass(String type, String action, List<Opportunity> oppList) {
            this.type = type;
            this.action = action;
            this.oppList = oppList;
        }

        public void execute(QueueableContext context) {

            List<Contact> resCntList;
            List<Opportunity> resOppList;
            List<OpportunityLineItem> resOppLineList;

            Map<Id,Opportunity> oppMapWithLines;

            if(oppList != null) {
                cntList = bg_FmIntOpportunity.getContactsWithoutExtIds(oppList);

                oppMapWithLines = bg_FmIntOpportunity.getOppMap(new Map<Id, Opportunity>(oppList).keySet());
                system.debug('**oppMapWithLines**: ' + oppMapWithLines);
            }

            if(cntList != null && cntList.size()>0) {
                ifId2ExtIdMappingExistsThenCopy(cntList);
                List<String> stringList = bg_FmIntContact.serialize(cntList);
                String resCnt = bg_FmIntHttpQueueableCallout.send('Contact', action, stringlist);
                if(resCnt != null) {
                    resCntList = bg_FmIntHttpQueueableCallout.responseHandlerCnt(resCnt);
                }
            }

            if(oppMapWithLines != null) {

                List<String> stringList;
                if(resCntList != null && resCntList.size()>0) {
                    ifId2ExtIdMappingExistsThenCopy(cntList);
                    stringList = bg_FmIntOpportunity.serialize(resCntList, oppMapWithLines.values());   
                }
                else {
                    stringList = bg_FmIntOpportunity.serialize(oppMapWithLines.values());   
                }
                
                String resOpp = bg_FmIntHttpQueueableCallout.send(type, action, stringlist);
                if(resOpp != null) {
                    resOppList = bg_FmIntHttpQueueableCallout.responseHandlerOpp(resOpp);
                    resOppLineList = bg_FmIntHttpQueueableCallout.responseHandlerOppLine(resOpp);
                }
            }

            if(resCntList != null && resCntList.size() > 0) {
                update resCntList;
            }

            if(resOppList != null && resOppList.size() > 0) {
                update resOppList;
            }

            if(resOppLineList != null && resOppLineList.size() > 0)
            {
                update resOppLineList;
            }

        }
    }   

    class ResponseWrapper {
        public String id;
        public String ext_id;
        public boolean success;
        public String auditLineId;
        public String certLineId;
    }

    public static Id enqueueJob(HttpQueueableClass job) {
        String username = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Username__c'));
        String password = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Password__c'));

        if(String.isEmpty(username) || String.isEmpty(password))
            return null;
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
            return System.enqueueJob(job);
        }
        return null;
    }

    private static void unescapeResponse(String response) {
        response = response.unescapeEcmaScript();
    }

    private static List<ResponseWrapper> parseResponse(String response) {

        unescapeResponse(response);

        List<ResponseWrapper> resList = new List<ResponseWrapper>();

        // Parse entire JSON response.
        JSONParser parser = JSON.createParser(response);
        System.debug('Json parsed response: ' + response);
        while (parser.nextToken() != null) {
            // Start at the array of responses.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
//                System.debug('Parser: ' + parser.getCurrentToken());
                while (parser.nextToken() != JSONToken.END_ARRAY) {

                    // Advance to the start object marker to
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
//                        System.debug('Parser: ' + parser.getCurrentToken());

                        // Read response
                        ResponseWrapper resw = new ResponseWrapper();
                        System.debug('Creating resw: ' + resw);
                        
                        while (parser.nextToken() != JSONToken.END_OBJECT) {
                            
//                            System.debug('Parser: ' + parser.getCurrentToken() + ':' + parser.getText());
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                (parser.getText() == 'id')) {
                                    parser.nextToken();
                                    resw.id = parser.getText();
                                }
                            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                (parser.getText() == 'ext_id')) {
                                    parser.nextToken();
                                    resw.ext_id = parser.getText() == 'null' ? null : parser.getText();
                                }
                            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                (parser.getText() == 'success')) {
                                    parser.nextToken();
                                    resw.success = Boolean.valueOf(parser.getText());
                                }
                            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                (parser.getText() == 'auditLineId')) {
                                    parser.nextToken();
                                    resw.auditLineId = parser.getText() == 'null' ? null : parser.getText();
                                }
                            else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                (parser.getText() == 'certLineId')) {
                                    parser.nextToken();
                                    resw.certLineId = parser.getText() == 'null' ? null : parser.getText();
                                }
                            
                        } 
                        
                        if(resw.success) {
                            System.debug('Adding resw: ' + resw);
                            resList.add(resw);
                        }
                        
                    }
               } 
            }
        }

        system.debug('res: ' + resList);
        return resList;
    } 

    private static List<Contact> responseHandlerCnt(String response) {

        List<Contact> resCntList = new List<Contact>();
        try {

            List<ResponseWrapper> resList = parseResponse(response);
            List<String> idList = new List<String>();
            List<String> extIdList = new List<String>();
            for(ResponseWrapper resw : resList) {
              if(resw.id != null && resw.ext_id != null) {
                    idList.add(resw.id);
                    extIdList.add(resw.ext_id);
                }
            }

            Map<Id, Contact> cntMap = new Map<Id, Contact>([Select Id, FM_Contact_External_Id__c from Contact 
                           where Id in : extIdList
                           and FM_Contact_External_Id__c not in : idList]);

            if(cntMap.values().size()>0) {
                for(ResponseWrapper resw : resList) {
                  if(resw.id != null && resw.ext_id != null) {

                        Contact cnt = cntMap.get(resw.ext_id);
                        cnt.FM_Contact_External_Id__c = resw.id;

                        System.debug('update target cnt id: ' + resw.ext_id + ' ext_id: ' + resw.id);
                        resCntList.add(cnt.clone(true, false));

                        // cache recent id->ext_id mappings
                        cntId2ExtIdMap.put(resw.ext_id, resw.id);

                  }
                }
            }
        }catch (Exception e){
          System.debug('responseHandlerCnt fail: ' + e.getMessage());
        }

        return resCntList;
    }

    private static List<Opportunity> responseHandlerOpp(String response) {

        List<Opportunity> resOppList = new List<Opportunity>();
        try {

            List<ResponseWrapper> resList = parseResponse(response);
            List<String> idList = new List<String>();
            List<String> extIdList = new List<String>();
            Set<Id> oppLineIds = new Set<Id>();
            for(ResponseWrapper resw : resList) 
            {
                /*System.debug(resw);
                System.debug('resw.Id : '+resw.Id);
                System.debug('resw.ext_Id : '+resw.ext_Id);
                System.debug('resw.AuditLineId : '+resw.AuditLineId);
                System.debug('resw.CertLineId : '+resw.CertLineId);

                if(resw.Id != null)
                {
                    System.debug('INSIDE IF : resw.Id : '+resw.Id);
                }
                if(resw.ext_Id != null)
                {
                    System.debug('INSIDE IF : resw.ext_Id : '+resw.ext_Id);
                }
                if(resw.AuditLineId == 'null')
                {
                    System.debug('INSIDE IF : resw.AuditLineId : '+resw.AuditLineId);
                }
                if(resw.CertLineId == 'null')
                {
                    System.debug('INSIDE IF : resw.CertLineId : '+resw.CertLineId);
                }*/


                if(resw.id != null && resw.ext_id != null && resw.auditLineId == null && resw.certLineId == null) 
                {
                    System.debug('Adding to list : '+resw.Id);
                    idList.add(resw.id);
                    extIdList.add(resw.ext_id);
                }
            }


            System.debug('idList : '+ idList.size() + '   +  fmIdList : '+extIdList.size());
            Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([Select Id, FM_Opportunity_External_Id__c 
                               from Opportunity 
                               where Id  in : extIdList
                               and FM_Opportunity_External_Id__c not in : idList]);

            

            if(oppMap.values().size()>0) {
                for(ResponseWrapper resw : resList) 
                {
                    if(resw.id != null && resw.ext_id != null &&
                        resw.auditLineId == null &&
                        resw.certLineId == null) 
                    {
            
                        Opportunity opp = oppMap.get(resw.ext_id);
                        opp.FM_Opportunity_External_Id__c = resw.id;
                        

                        System.debug('update target opp id: ' + resw.ext_id + ' ext_id: ' + resw.id);
                        resOppList.add(opp.clone(true, false));
                    }
                }
            }
        }catch (Exception e){
          System.debug('responseHandlerOpp fail: ' + e.getMessage()+' at '+e.getStackTraceString() + ' at line '+e.getLineNumber());
        }

        return resOppList;
    }

    private static List<OpportunityLineItem> responseHandlerOppLine(String response) {

        Map<Id,OpportunityLineItem> resOppLineMap = new Map<Id,OpportunityLineItem>();
        try {

            List<ResponseWrapper> resList = parseResponse(response);

            Set<Id> oppLineIds = new Set<Id>();
            for(ResponseWrapper resw : resList) {
                if(resw.id != null && resw.auditLineId != null)
                {
                    oppLineIds.add(resw.auditLineId);
                }
                if(resw.id != null && resw.certLineId != null)
                {
                    oppLineIds.add(resw.certLineId);
                }
            }

            if(oppLineIds.size() > 0)
            {
                Map<Id, OpportunityLineItem> oppLineMap = new Map<Id, OpportunityLineItem>([Select Id, Name, OpportunityId, FM_Enquiry_Id__c From OpportunityLineItem Where Id IN :oppLineIds]);


                if(oppLineMap.size()>0) {
                    for(ResponseWrapper resw : resList) 
                    {
                        if(resw.id != null && resw.auditLineId != null && oppLineMap.containsKey(resw.auditLineId))
                        {
                            oppLineMap.get(resw.auditLineId).FM_Enquiry_Id__c = resw.Id;
                            resOppLineMap.put(resw.auditLineId, oppLineMap.get(resw.auditLineId));
                        }
                        if(resw.id != null && resw.certLineId != null && oppLineMap.containsKey(resw.certLineId))
                        {
                            oppLineMap.get(resw.certLineId).FM_Enquiry_Id__c = resw.Id;
                            resOppLineMap.put(resw.certLineId, oppLineMap.get(resw.certLineId));
                        }
                    }
                }
            }
        }catch (Exception e){
          System.debug('responseHandlerOppLine fail: ' + e.getMessage()+' at '+e.getStackTraceString() + ' at line '+e.getLineNumber());
        }

        return resOppLineMap.values();
    }

    public static String send(String type, String action,  List<String> stringList) {

        System.debug('send type: ' + type + ' action: ' + action + ' stringList: ' + stringList);

        // Auth
        String username = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Username__c'));
        String password = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Password__c'));

        Http http = new Http();
        String endpoint = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Endpoint__c'));
        String query = String.valueOf(FM_Integration__c.getValues('Host').get('Http_Callout_Query__c'));
        HttpRequest req = getHttpRequest(endpoint+query, 'POST', username, password);
        String jsonStr;
        if(stringList.size() > 0 || stringlist != null){
            jsonStr = buildJsonString(stringList);
        }
        req.setBody(getRequestBody(type, action, jsonStr));
        try{
            System.debug('send json: ' + req.getBody());
            HttpResponse res = http.send(req);
            System.debug('send resp: ' + res.getBody());

            return res.getBody();

        }catch (Exception e){
            System.debug('send fail: ' + e.getMessage());
        }

        return null;
    }

    private static HttpRequest getHttpRequest(String endpoint, String method, String username, String password){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setTimeout(60000);

        return req;
    }

    private static String buildJsonString(List<String> stringList){
        String jsonList =  '['; //Create jsonObject String
        if(stringList != null){
            boolean first = true;
            for(String eachString : stringList){
                if(first) {
                  first = false;
                }
                else {
                  jsonList += ',';
                }
                jsonList += eachString;
            }
        }

        jsonList += ']'; //Close jsonObject String

        return jsonList;
    }

    private static String getRequestBody(String type, String action, String jsonList){
        return '{"Type":"'+type+'", "Action":"'+action+'", "JSONRecord":'+jsonList+'}'; 
    }

}