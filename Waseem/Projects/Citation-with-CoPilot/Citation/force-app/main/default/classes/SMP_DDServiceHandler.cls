global with sharing class SMP_DDServiceHandler {

    global static final String MESSAGE_CALLOUTERROR = 'Error Calling SmarterPay Service.';    
    global static SmarterPay_Direct_Debit_Setting__mdt  directDebitConfig = [SELECT Bank_Account_Checker_Endpoint__c, Calculate_Next_Collection_Date_Endpoint__c, 
                                                                                List_Next_Collection_Date_Endpoint__c, User_Id__c, SmarterPay_Cloud_API_Key__c 
                                                                            FROM SmarterPay_Direct_Debit_Setting__mdt 
                                                                            WHERE Active__c = true LIMIT 1];

    global static SMP_DDServiceNextCollectionModel getNextCollectionDate(SingleCollectionDateWrapper dateWrapper)
    {
        System.debug('#### getNextCollectionDate Started');
        System.debug('#### collectionDayIn: ' + dateWrapper.CollectionDay);
        System.debug('#### startDateIn: ' + dateWrapper.StartDate);
        System.debug('#### collectionPeriodIn: ' + dateWrapper.CollectionPeriod);
        System.debug('#### numberOfDaysToWaitFromNewInstructionIn: ' + dateWrapper.NumberOfDaysToWaitFromNewInstruction);

        SMP_DDServiceNextCollectionModel parsedResponse;
        String endpointURL = '';
       
        try{
            endpointURL = string.valueOf(directDebitConfig.Calculate_Next_Collection_Date_Endpoint__c);
            
        }catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }

        String dateString = '';

        System.debug('startDate' + dateString);

        String jsonString = JSON.serialize(dateWrapper);
        System.Debug('#### jsonString: ' + jsonString);

        jsonString = jsonString.replaceAll('DateWrapper', 'Date');     
        jsonString = jsonString.replaceAll('(\\s+)', ' ');        
        
        endpointURL = endpointURL + EncodingUtil.urlEncode(jsonString, 'UTF-8');
        
        System.debug('#### endpointURL: ' + endpointURL);

        try{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET'); 
            req.setEndPoint(endpointURL);      
            HttpResponse resp;
            resp = http.send(req);
            
            System.debug('#### Response Body: ' + resp.getBody());
            System.debug('#### Response Status: ' + resp.getStatus());
            System.debug('#### Response Status Code: ' + resp.getStatusCode());
            
            if(resp.getStatusCode() == 200)
            {
                parsedResponse =  SMP_DDServiceNextCollectionModel.parse(resp.getBody());
                System.debug(parsedResponse);
            }
            else
            {
                parsedResponse = new  SMP_DDServiceNextCollectionModel();
                parsedResponse.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();
            }

            System.debug('#### parsedResponse: ' + parsedResponse);

            return parsedResponse;
        }
        catch(Exception e)
        {
            parsedResponse = new  SMP_DDServiceNextCollectionModel();
            parsedResponse.Error = MESSAGE_CALLOUTERROR + ' ' + e.getMessage();

            System.debug('#### parsedResponse: ' + parsedResponse);
            System.debug('#### debug e: ' + e);

            return parsedResponse;
        }                
    }

    global static SMP_DDServiceNextCollectionModelList getNextCollectionDate(List<SingleCollectionDateWrapper> dateWrapper)
    {
        System.debug('#### getNextCollectionDate Started');
        System.debug('#### dateWrapper: ' + dateWrapper);

        SMP_DDServiceNextCollectionModelList parsedResponse;
        String endpointURL = '';
       
        try{
            endpointURL = string.valueOf(directDebitConfig.List_Next_Collection_Date_Endpoint__c);
            
        }catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }

        String jsonString = JSON.serialize(dateWrapper);
        System.debug('#### jsonString before replace: ' + jsonString);
     
        jsonString = jsonString.replaceAll('(\\s+)', ' ');      

        System.debug('#### jsonString after replace: ' + jsonString);
        
        endpointURL = endpointURL + EncodingUtil.urlEncode(jsonString, 'UTF-8');
        
        System.debug('#### endpointURL: ' + endpointURL);

        try{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET'); 
            req.setEndPoint(endpointURL);      
            HttpResponse resp;
            resp = http.send(req);
            
            System.debug('#### Response Body: ' + resp.getBody());
            System.debug('#### Response Status: ' + resp.getStatus());
            System.debug('#### Response Status Code: ' + resp.getStatusCode());
            
            if(resp.getStatusCode() == 200)
            {
                parsedResponse =  SMP_DDServiceNextCollectionModelList.parse(resp.getBody());
                System.debug(parsedResponse);
            }
            else
            {
                parsedResponse = new  SMP_DDServiceNextCollectionModelList();
                parsedResponse.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();
            }

            System.debug('#### parsedResponse: ' + parsedResponse);

            return parsedResponse;
        }
        catch(Exception e)
        {            
            System.debug('#### parsedResponse: ' + parsedResponse);
            System.debug('#### debug e: ' + e);
            parsedResponse = new  SMP_DDServiceNextCollectionModelList();
            parsedResponse.Error = MESSAGE_CALLOUTERROR + ' ' + e.getMessage();

            return parsedResponse;
        }                
    }

    global static SMP_DDServiceNextCollectionModel getNextCollectionDate(String collectionDayIn, Date startDateIn, String collectionPeriodIn, String numberOfDaysToWaitFromNewInstructionIn)
    {
        System.debug('#### getNextCollectionDate Started');
        System.debug('#### collectionDayIn: ' + collectionDayIn);
        System.debug('#### startDateIn: ' + startDateIn);
        System.debug('#### collectionPeriodIn: ' + collectionPeriodIn);
        System.debug('#### numberOfDaysToWaitFromNewInstructionIn: ' + numberOfDaysToWaitFromNewInstructionIn);

        String dateString = '';

        if(startDateIn != null){
            dateString = startDateIn.year() + '-' + startDateIn.month() + '-' + startDateIn.day();
        }
        System.debug('startDate' + dateString);

        SingleCollectionDateWrapper dateWrapper = new SingleCollectionDateWrapper();
        dateWrapper.CollectionDay = collectionDayIn;
        dateWrapper.StartDate = dateString;
        dateWrapper.CollectionPeriod = collectionPeriodIn;
        dateWrapper.NumberOfDaysToWaitFromNewInstruction = numberOfDaysToWaitFromNewInstructionIn;

        return getNextCollectionDate(dateWrapper);
    }    

    global static SMP_DDServiceBankAccountModel getBankDetails(Modulus_Check_Request bankDetailsWrapper)
    {
        System.debug('#### getBankDetails');
        System.debug('#### bankDetailsWrapper: ' + bankDetailsWrapper);

        SMP_DDServiceBankAccountModel parsedResponse;    
        String endpointURL = '';
        String APIKey = '';

        try{
            endpointURL = string.valueOf(directDebitConfig.Bank_Account_Checker_Endpoint__c);
            APIKey = string.valueOf(directDebitConfig.SmarterPay_Cloud_API_Key__c);            
        }
        catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }        
        
        try{
            String jsonString = JSON.serialize(bankDetailsWrapper);
            //jsonString = jsonString.replaceAll('(\\s+)', ' ');

            System.debug('#### jsonString: ' + jsonString);        
            System.debug('#### endpointURL: ' + endpointURL);

            HttpRequest req = new HttpRequest();

            Http http = new Http();
            req.setTimeout(60000);
            req.setHeader('Authorization', 'Bearer ' + APIKey);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST'); 
            req.setEndPoint(endpointURL);
            req.setBody(jsonString);

            HttpResponse resp;
            resp = http.send(req);

            System.debug('#### Response Body: ' + resp.getBody());
            System.debug('#### Response Status: ' + resp.getStatus());
            System.debug('#### Response Status Code: ' + resp.getStatusCode());
                    
            if(resp.getStatusCode() == 200)
            {        
                parsedResponse =  SMP_DDServiceBankAccountModel.parse(resp.getBody());            
            }
            else
            {
                parsedResponse = new SMP_DDServiceBankAccountModel();
                parsedResponse.Modulus_Check.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();    
            }
            
            System.debug('#### Result: ' + parsedResponse);
            return parsedResponse; 
        }
        catch(Exception e)
        {
            parsedResponse = new SMP_DDServiceBankAccountModel();
            parsedResponse.Modulus_Check.Error = MESSAGE_CALLOUTERROR + ' ' + e.getMessage();

            return parsedResponse; 
        }
    }

    /**
    * @description Handles calling the Income Systems Bank Account Checker service.
    * @param sortCode Bank account sort code.
    * @param accountNo Bank account number.
    * @return SMP_DDServiceBankAccountModel Model/Wrapper that encapsulates the response from the Income Systems Bank Account Checker.
    */
    global static SMP_DDServiceBankAccountModel getBankDetails(String sortCode, String accountNo)
    {        
        System.debug('#### getBankDetailsWebservice Started');
        System.debug('#### sortCode: ' + sortCode);
        System.debug('#### accountNo: ' + accountNo);

        Modulus_Check_Request accountWrapper = new Modulus_Check_Request();
        accountWrapper.Modulus_Check.sort_code = sortCode;
        accountWrapper.Modulus_Check.account_number = accountNo;

        return getBankDetails(accountWrapper);
    }    

    global class SingleCollectionDateWrapper{
        global String CollectionDay {get; set;}
        global String StartDate {get; set;}
        global String CollectionPeriod {get; set;}
        global String NumberOfDaysToWaitFromNewInstruction{get; set;}
    }

    global class Modulus_Check_Request {
        global Modulus_Check Modulus_Check;

        public Modulus_Check_Request(){
            Modulus_Check = new Modulus_Check();
        }
    }

	global class Modulus_Check {
		global String account_number;
		global String sort_code;
	}

    // To Deprecate
    global class AccountCheckerWrapper{
        global String SortCode {get; set;}
        global String AccountNo {get; set;}
        global String UserID {get; set;}        
    }

    global static SMP_DDServiceBankAccountModel getBankDetails(AccountCheckerWrapper bankDetailsWrapper)
    {
        return null;
    }
}