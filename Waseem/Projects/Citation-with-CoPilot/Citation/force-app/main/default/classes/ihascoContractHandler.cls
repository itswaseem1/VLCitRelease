public class ihascoContractHandler {
    
    @TestVisible
    private static String emailMessage;
    
    public static string getDiscountInfo(Decimal CustomDiscountAmount,string discount,string subsLinesStart){
        if(CustomDiscountAmount==null)
        {
            subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td>';
        }
        else if(CustomDiscountAmount!=null)
        {subsLinesStart=subsLinesStart+ '<td width="15%">'+'£'+CustomDiscountAmount+'</td>';}
        if(discount==null || discount==' ')
        {
            subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td>';
        }
        else if(discount!=null || discount!=' ')
        {subsLinesStart=subsLinesStart+ '<td width="15%">'+discount + '%'+'</td>';}
        return subsLinesStart ;
    }
    public static void SendAccountsTeamEmail(Set<Id> newContracts){
        Set<Id> quoteIds = new Set<Id>();
        String userEmail=OrgInstanceCheck.runningInASandbox() ? label.iHASCO_Order_Team_Email : label.iHASCO_Finance_Prod_Email;
        String license, linezero, lineone, linetwo, subsLinesStart, subsLinesEnd, baseURL;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Map<string,List<SBQQ__QuoteLine__c>> quoteLinesMap = new Map<string,List<SBQQ__QuoteLine__c>>();
        Set<id> userbasedpricingqt = new Set<id>();
        List<Contract> contractValues = new List<Contract>();
        list<SBQQ__QuoteLine__c> quoteLines = new list<SBQQ__QuoteLine__c> ();
        contractValues = [SELECT Id, Account.Id,Account.Owner.Name,EndDate, Account.Name,Renewal_Date__c,ContractTerm,
                          Account.Company_VAT_Number__c, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode,Account.LMS_ID__c, 
                          Account.BillingCountry, Source_Opportunity__r.Id, SBQQ__Opportunity__r.BDC_Manager__c,SBQQ__Quote__r.License_Model__c,
                          SBQQ__Opportunity__r.Deposit_Payment_Method__c, StartDate, ContractNumber, recordType.Name, 
                          SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,SBQQ__Quote__r.Name, 
                          SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone,SBQQ__Quote__r.Quote_Type__c,Account.iHASCO_Account_Manager__r.Email,
                          SBQQ__Quote__r.PO_reference__c,Total_Contract_Value__c,Annual_Contract_Value__c,SBQQ__Quote__r.Payment_Method__C,SBQQ__Opportunity__r.Notes_to_Finance__c,SBQQ__Opportunity__r.New_Business_Customer__c
                          FROM Contract WHERE Id IN:newContracts AND RecordType.Name='iHASCO Standard Contract'];
        for(Contract con : contractValues){
            quoteIds.add(con.SBQQ__Quote__r.Id);
        }
         quoteLines = [SELECT Id, Annual_Price__c,SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Name, Custom_Discount_Percentage__c, SBQQ__Quote__r.Id,iHasco_Number_of_Users__c, SBQQ__NetTotal__c,Ihasco_Number_of_Credits__c,SBQQ__ListPrice__c,Custom_Discount_Amount__c From SBQQ__QuoteLine__c where SBQQ__Quote__r.Id In :quoteIds];
        for(SBQQ__QuoteLine__c ql : quoteLines){
            if(ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name == 'User based Pricing'){
                userbasedpricingqt.add(ql.SBQQ__Quote__r.Id);
            }
            if(quoteLinesMap != null && quoteLinesMap.containsKey(ql.SBQQ__Quote__r.Id)){
                List<SBQQ__QuoteLine__c> lines = quoteLinesMap.get(ql.SBQQ__Quote__r.Id);
                lines.add(ql);
                quoteLinesMap.put(ql.SBQQ__Quote__r.Id,lines);
            } else {
                List<SBQQ__QuoteLine__c> lines= new List<SBQQ__QuoteLine__c>();
                lines.add(ql);
                quoteLinesMap.put(ql.SBQQ__Quote__r.Id,lines);
            }
        }
        for(Contract con : contractValues){
            linezero = null;
            lineone = null;
            linetwo = null;
            subsLinesStart = null;
            license = null;
            subsLinesEnd = null;
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String PoRef, manager;
            String paymentMethod = '';
            license= con.SBQQ__Quote__r.License_Model__c;
                PoRef = con.SBQQ__Quote__r.PO_reference__c != Null ? con.SBQQ__Quote__r.PO_reference__c : ' ';
            manager = con.Account.Owner.Name != Null ? con.Account.Owner.Name : ' ';
            paymentMethod = con.SBQQ__Quote__r.Payment_Method__c;
            linezero = '<html><body><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%">'
                +con.Account.Name+ '</td><td width="50%">Contact: '+con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name+ '</td></tr>'
                +'<tr><td width="50%">'+con.Account.BillingStreet+ '<br>'+con.Account.BillingCity+'<br>'+con.Account.BillingCountry+'<br>'
                +con.Account.BillingPostalCode+'</td><td width="50%">Phone: '+con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone+ '<br><br>Mobile:'
                +con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone+'<br><br>Email: '+con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email+'</td></tr>'
                +'<tr><td width="50%">Client Id: '
                +System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+con.Source_Opportunity__r.Id+'</td></tr>';
            lineone = '<html><body><a href="'+baseURL+'/'+con.Account.Id+'">See Client In CRM</a><br></body></html>';
            linetwo = '<html><body><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%"><b>Contract Number:</b> '+con.ContractNumber+'</td><td width="50%"><b>PO Reference: </b>'+PoRef+'</td></tr>'
                +'<tr><td width="50%"><b>Contract Date:</b> '+con.StartDate.format()+'</td></tr>'
                +'<tr><td width="50%"><b>Payment Method:</b> '+paymentMethod+'</td></tr>'
                +'<tr><td width="50%"><b>Manager: </b>'+manager+'</td></tr>'
                +'<tr><td width="50%"><b>Contract End Date:</b> '+con.EndDate+'</td></tr>'
                +'<tr><td width="50%"><b>Renewal Date: </b>'+(con.EndDate - 90)+'</td></tr>'
                +'<tr><td><b>Total Order Amount:'+'£'+con.Annual_Contract_Value__c+'</b></td></tr>'
                +'<tr><td><b>Notes To Finance: '+con.SBQQ__Opportunity__r.Notes_to_Finance__c+'</b></td></tr>'
                +'<tr><td><b>'+con.SBQQ__Opportunity__r.New_Business_Customer__c+'</b></td></tr>'
                +'<tr><td><b>Quote Type: '+con.SBQQ__Quote__r.Quote_Type__c+'</b></td></tr>'
                +'<tr><td><b>LMS ID: '+con.Account.LMS_ID__c+'</b></td></tr>'
                +'<tr><td><b>Contract Term: '+con.ContractTerm+'</b></td></tr>'
                +'<tr><td><b>Quote Number: '+con.SBQQ__Quote__r.Name+'</b></td></tr></table><br></body></html>';
            if(userbasedpricingqt!= null && userbasedpricingqt.contains(con.SBQQ__Quote__r.Id)){
                subsLinesStart = '<html><body><br><table width="100%"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="15%">Quantity</th><th style="text-align:left" width="15%">No.of Users</th><th style="text-align:left" width="15%">Discount(£)</th><th style="text-align:left" width="15%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
            } else {
                subsLinesStart = '<html><body><br><table width="120%"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="15%">Quantity</th><th style="text-align:left" width="15%">No.of Credits</th><th style="text-align:left" width="15%">Discount(£)</th><th style="text-align:left" width="15%">Discount(%)</th><th style="text-align:left" width="20%">Amt before Disc</th><th style="text-align:left" width="20%">Amount</th></tr>';
            }
            if(quoteLinesMap.containsKey(con.SBQQ__Quote__r.Id) && quoteLinesMap.get(con.SBQQ__Quote__r.Id)!=null){
                for(SBQQ__QuoteLine__c ql : quoteLinesMap.get(con.SBQQ__Quote__r.Id)){
                    String discount;
                    discount = ql.Custom_Discount_Percentage__c != Null ? String.valueOf(ql.Custom_Discount_Percentage__c) : ' ';
                    if(ql.SBQQ__Quote__r.Id == con.SBQQ__Quote__r.Id){
                        if(userbasedpricingqt!= null && userbasedpricingqt.contains(con.SBQQ__Quote__r.Id)){
                             subsLinesStart = subsLinesStart + '<tr><td width="25%">'+ql.SBQQ__Product__r.Name+'</td><td width="20%">'+ql.SBQQ__Quantity__c+'</td>';
                             if(ql.iHasco_Number_of_Users__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td>';
                            }
                            else if(ql.iHasco_Number_of_Users__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+ql.iHasco_Number_of_Users__c+'</td>';}
                            subsLinesStart=+getDiscountInfo(ql.Custom_Discount_Amount__c,discount,subsLinesStart);
                       if(ql.SBQQ__NetTotal__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="20%">'+ +'</td></tr>';
                            }
                            else if(ql.SBQQ__NetTotal__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="20%">'+'£'+ql.Annual_Price__c+'</td></tr>';}
                        } 
                        else {
                            subsLinesStart = subsLinesStart + '<tr><td width="25%">'+ql.SBQQ__Product__r.Name+'</td><td width="15%">'+ql.SBQQ__Quantity__c+'</td>'; 
                        if(ql.Ihasco_Number_of_Credits__c==null)
                        {
                           subsLinesStart=subsLinesStart + '<td width="15%">'+ +'</td>';
                        }
                            else if(ql.Ihasco_Number_of_Credits__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+ql.Ihasco_Number_of_Credits__c+'</td>';}
                           subsLinesStart=+getDiscountInfo(ql.Custom_Discount_Amount__c,discount,subsLinesStart);
                         if(ql.SBQQ__ListPrice__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td  width="25%">'+ +'</td>';
                            }
                        else if(ql.SBQQ__ListPrice__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td  width="25%">'+'£'+ql.SBQQ__ListPrice__c+'</td>';}
                          if(ql.SBQQ__NetTotal__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td></tr>';
                            }
                            else if(ql.SBQQ__NetTotal__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+'£'+ql.Annual_Price__c+'</td><tr>';}
                        }
                    }
                }
            }
            subsLinesEnd = '</table></body></html>';
            Messaging.SingleEmailMessage message= new Messaging.SingleEmailMessage();
            list<String> recepientId = new list<String>();
            list<String> ccAddress = new list<String>();
            recepientId.add(userEmail);
			ccAddress.add(con.Account.iHASCO_Account_Manager__r.Email);
            recepientId.add(userEmail);
            //recepientId.add('ruchikaputtoo@gmail.com');
            message.toAddresses = recepientId;
            message.ccaddresses = ccAddress;
            message.subject = 'iHasco Contract Created';
            emailMessage = linezero + '<tr><td width="50%">License Model: '+license+'</td></tr></table><br><br></body></html>' + lineone + linetwo + subsLinesStart + subsLinesEnd+'<br/> <b>Total Order Amount: '+'£'+con.Annual_Contract_Value__c+'</b>';
            message.HtmlBody = emailMessage;
            messages.add(message);
        }
        //SBQQ__Subscription__c[] subscriptions = [SELECT Id, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__OptionDiscount__c From SBQQ__Subscription__c where SBQQ__Contract__c IN :newContracts];
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if(!results.isEmpty()){
            Boolean success;
            String errorMessage;
            for(Messaging.SendEmailResult result :results){
                success=result.success;
                if (success)
                    System.debug('The email was sent successfully.');
            } 
        }
                    }
                   
    public static void getAmendContractToBuildEmailBody(Set<Id> newContracts, Boolean amendmentContract){
        Set<Id> quoteIds = new Set<Id>();
        String userEmail=OrgInstanceCheck.runningInASandbox() ? label.iHASCO_Order_Team_Email : label.iHASCO_Finance_Prod_Email;
        String license,ClientId, linezero,lineone, baseURL, amendLineOne, amendLineTwo,amendsubLineTwo, amendLineThree, amendedSubTable, finalAmendTable, amendedHTMLBody,originalSubTable;
        Map<string,List<SBQQ__QuoteLine__c>> quoteLinesMap = new Map<string,List<SBQQ__QuoteLine__c>>();
        Set<id> userbasedpricingqt = new Set<id>();
        map<String,String> EmailbodyMap=new map<String,String>();
        for(Contract con :  getContractDetails(newContracts)){
            ClientId=null;
            linezero = null;
            lineone = null;
            license = null;
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String PoRef,manager;
            String paymentMethod = '';
            quoteIds.add(con.SBQQ__Quote__r.Id);
            license= con.SBQQ__Quote__r.License_Model__c;
            PoRef = con.SBQQ__Quote__r.PO_reference__c != Null ? con.SBQQ__Quote__r.PO_reference__c : ' ';
            manager = con.Account.Owner.Name != Null ? con.Account.Owner.Name : ' ';
            paymentMethod = con.SBQQ__Quote__r.Payment_Method__c;
            linezero = '<html><body><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%">'
                +con.Account.Name+ '</td><td width="50%">Contact: '+con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name+ '</td></tr>'
                +'<tr><td width="50%">'+con.Account.BillingStreet+ '<br>'+con.Account.BillingCity+'<br>'+con.Account.BillingCountry+'<br>'
                +con.Account.BillingPostalCode+'</td><td width="50%">Phone: '+con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone+ '<br><br>Mobile:'
                +con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone+'<br><br>Email: <u>'+con.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email+'</u></td></tr>';
            ClientId='<html><body><table><td style="text-align:left" width="100%">Client Id: <u><a href="'+baseURL+'/'+con.Source_Opportunity__r.Id+'">Client Record Page</a></u></td></table></body></html>';
            lineone = '<html><body><a href="'+baseURL+'/'+con.Account.Id+'">See Client In CRM</a><br></body></html>';
            EmailbodyMap.put('userEmail',userEmail);
            EmailbodyMap.put('linezero',linezero);
            EmailbodyMap.put('lineone',lineone);
            EmailbodyMap.put('ClientId',ClientId);
            EmailbodyMap.put('paymentMethod',paymentMethod);
            EmailbodyMap.put('manager',manager);
            EmailbodyMap.put('PoRef',PoRef);
            EmailbodyMap.put('license',license);
        }
         List<SBQQ__Quote__c> amendQuotelist = new List<SBQQ__Quote__c>();
        map<id,string> amendquotemap=new map<id,string>();
        amendQuotelist=[select id,name,SBQQ__MasterContract__c from SBQQ__Quote__c where SBQQ__MasterContract__c in :newContracts];
        for(SBQQ__Quote__c quote:amendQuotelist)
        {
            amendquotemap.put(quote.SBQQ__MasterContract__c, quote.name);
        }
        list<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Name, Custom_Discount_Percentage__c, SBQQ__Quote__r.Id,iHasco_Number_of_Users__c, SBQQ__NetTotal__c,Ihasco_Number_of_Credits__c,SBQQ__ListPrice__c,Custom_Discount_Amount__c From SBQQ__QuoteLine__c where SBQQ__Quote__r.Id In :quoteIds];
        for(SBQQ__QuoteLine__c ql : quoteLines){
            if(ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name == 'User based Pricing'){
                userbasedpricingqt.add(ql.SBQQ__Quote__r.Id);
            }}
        if(amendmentContract) {
            SendAccountsTeamAmendmentEmail(EmailbodyMap, getContractDetails(newContracts),userbasedpricingqt,getSubscriptionDetails(newContracts),amendquotemap);
        }
        
    }
    public static list<Contract> getContractDetails(Set<Id> newContracts){
        List<Contract> contractValues = new List<Contract>();
        contractValues = [SELECT Id, Annual_Contract_Value__c,SBQQ__Quote__r.SBQQ__SalesRep__r.name,SBQQ__AmendmentOwner__r.Name, Account.Id,Account.Owner.Name,EndDate, Account.Name,Renewal_Date__c,ContractTerm,
                          Account.Company_VAT_Number__c, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode,Account.LMS_ID__c, 
                          Account.BillingCountry, Source_Opportunity__r.Id, SBQQ__Opportunity__r.BDC_Manager__c,SBQQ__Quote__r.License_Model__c,
                          SBQQ__Opportunity__r.Deposit_Payment_Method__c, StartDate, ContractNumber, recordType.Name, 
                          SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,SBQQ__Quote__r.Name, 
                          SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone,Account.iHASCO_Account_Manager__r.Email,
                          SBQQ__Quote__r.PO_reference__c,Total_Contract_Value__c,SBQQ__Quote__r.Payment_Method__C,SBQQ__Opportunity__r.Notes_to_Finance__c,SBQQ__Opportunity__r.New_Business_Customer__c
                          FROM Contract WHERE Id IN:newContracts AND RecordType.Name='iHASCO Standard Contract'];
        return contractValues;
    }
    public static Map<Id, List<SBQQ__Subscription__c>> getSubscriptionDetails(Set<Id> newContracts){
        Map<Id, List<SBQQ__Subscription__c>> contractSubListMap = new Map<Id, List<SBQQ__Subscription__c>>();
        for(SBQQ__Subscription__c objSub : [select id, SBQQ__QuoteLine__r.Annual_Price__c,Subscription_Term__c,SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c,SBQQ__Contract__r.Id, SBQQ__Contract__r.StartDate, SBQQ__Contract__r.EndDate, SBQQ__Contract__r.Contract_Term_Years__c, 
                                            SBQQ__QuoteLine__r.SBQQ__Group__c, SBQQ__QuoteLine__r.SBQQ__Group__r.createdDate,
                                            SBQQ__RevisedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c,SBQQ__ProductName__c,
                                            SBQQ__RevisedSubscription__r.Id,SBQQ__QuoteLine__r.SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c, 
                                            iHasco_Number_of_Users__c,Ihasco_Number_of_Credits__c,SBQQ__BillingFrequency__c, Regular_Payment__c,
                                            SBQQ__RevisedSubscription__c, SBQQ__Quantity__c,SBQQ__BundledQuantity__c,SBQQ__QuoteLine__r.SBQQ__Quote__c,
                                            SBQQ__Contract__r.SBQQ__Quote__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__r.Custom_Discount_Amount__c,SBQQ__QuoteLine__r.Custom_Discount_Percentage__c from SBQQ__Subscription__c  where SBQQ__Contract__c  IN: newContracts order by Name DESC]) 
        {
            if(contractSubListMap.containsKey(objSub.SBQQ__Contract__r.Id)) {
                List<SBQQ__Subscription__c> tempList = contractSubListMap.get(objSub.SBQQ__Contract__r.Id);
                tempList.add(objSub);
                contractSubListMap.put(objSub.SBQQ__Contract__r.Id, tempList);
            }
            else {
                contractSubListMap.put(objSub.SBQQ__Contract__r.Id, new List<SBQQ__Subscription__c>{objSub});
            }     
        }
        return contractSubListMap;
        
    }
    public static void SendAccountsTeamAmendmentEmail(map<String,String> EmailbodyMap,list<contract> ContractValues,set<id> userbasedpricingqt,Map<Id, List<SBQQ__Subscription__c>> contractSubListMap,map<id,string> amendquotemap){
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        String amendLineOne, amendLineTwo,amendsubLineTwo, amendLineThree, amendedSubTable, finalAmendTable, amendedHTMLBody,originalSubTable;
        amendLineOne=null;
        amendLineTwo=null;
        originalSubTable=null;
        amendedSubTable=null;
        for(Contract con:ContractValues){
            amendLineOne = '<html><body><h4>Contract Amendment</h4></body></html>';
            amendLineTwo = '<html><body><h4>Original Contract Details</h4></body></html>' + 
                '<html><body><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%"><b>Contract Number:</b> '+con.ContractNumber+'</td><td width="50%"><b>PO Reference: </b>'+EmailbodyMap.get('PoRef')+'</td></tr>'
                +'<tr><td width="50%"><b>Contract Date:</b> '+con.StartDate.format()+'</td></tr>'
                +'<tr><td width="50%"><b>Payment Method:</b> '+EmailbodyMap.get('paymentMethod')+'</td></tr>'
                +'<tr><td width="50%"><b>Manager: </b>'+EmailbodyMap.get('manager')+'</td></tr>'
                +'<tr><td width="50%"><b>Contract End Date:</b> '+con.EndDate+'</td></tr>'
                +'<tr><td width="50%"><b>Renewal Date: </b>'+(con.EndDate - 90)+'</td></tr>';
            if(userbasedpricingqt!= null && userbasedpricingqt.contains(con.SBQQ__Quote__r.Id)){
                originalSubTable = '<html><body><br><table width="100%" style="border: 1px solid black;"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="20%">Quantity</th><th style="text-align:left" width="20%">No.of Users</th><th style="text-align:left" width="20%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
                amendedSubTable = '<html><body><br><table width="100%" style="border: 1px solid black;"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="20%">Quantity</th><th style="text-align:left" width="20%">No.of Users</th><th style="text-align:left" width="20%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
                } else {
                originalSubTable = '<html><body><br><table width="100%" style="border: 1px solid black;"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="20%">Quantity</th><th style="text-align:left" width="20%">No.of Credits</th><th style="text-align:left" width="20%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
                amendedSubTable = '<html><body><br><table width="100%" style="border: 1px solid black;"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="20%">Quantity</th><th style="text-align:left" width="20%">No.of Credits</th><th style="text-align:left" width="20%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
        }
            if(contractSubListMap.containsKey(con.Id)) {
                //getRecentQuoteId(con.Id)                    
                iHascoContractAmendmentHelper.subWrapper objsubWrapper;
                objsubWrapper = iHascoContractAmendmentHelper.processSubcriptions(contractSubListMap.get(con.Id));
                amendsubLineTwo ='<tr><td><b>Total Order Amount:'+'£ '+objsubWrapper.originalAnnualPrice+'</b></td></tr>'
                    +'<tr><td><b>LMS ID: '+con.Account.LMS_ID__c+'</b></td></tr>'
                    +'<tr><td><b>Contract Term: '+con.ContractTerm+' months'+'</b></td></tr>'
                      +'<tr><td><b>Quote Number: '+con.SBQQ__Quote__r.Name+'</b></td></tr></table><br></body></html>';
                for(SBQQ__Subscription__c objSub : objsubWrapper.originalList) {
                    if(userbasedpricingqt!= null && userbasedpricingqt.contains(con.SBQQ__Quote__r.Id)){
                        originalSubTable += '<tr><td>'+objSub.SBQQ__ProductName__c+'</td><td>'+objSub.SBQQ__Quantity__c+'</td><td>'+ objSub.iHasco_Number_of_Users__c+'</td><td>'+objSub.SBQQ__QuoteLine__r.Custom_Discount_Percentage__c+'</td><td>'+'£'+objSub.SBQQ__QuoteLine__r.Annual_Price__c+'</td></tr>';
                    }else{
                        originalSubTable += '<tr><td>'+objSub.SBQQ__ProductName__c+'</td><td>'+objSub.SBQQ__Quantity__c+'</td><td>'+ objSub.Ihasco_Number_of_Credits__c+'</td><td>'+objSub.SBQQ__QuoteLine__r.Custom_Discount_Percentage__c+'</td><td>'+'£'+objSub.SBQQ__QuoteLine__r.Annual_Price__c+'</td></tr>';
                    }}
                amendLineThree = '<html><body><h4>Amended Contract Details</h4><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%"><b>Sales Rep:</b> '+con.SBQQ__Quote__r.SBQQ__SalesRep__r.name+'</td></tr>'
                    +'<tr><td width="50%"><b>New Order Amount:</b> '+'£'+objsubWrapper.amendAnnualPrice+'</td></tr>'+'<tr><td><b>Contract Term: '+objsubWrapper.ContractTerm+' months'+'</b></td></tr>';
         if(amendquotemap.containsKey(con.id)){
                    amendLineThree+='<tr><td width="50%"><b>Amend Quote Number:</b>'+amendquotemap.get(con.id)+'</td></tr></table><br></body></html>';
                }  
                originalSubTable+='<tr><td width="50%"><b>Original Order Amount: '+'£'+objsubWrapper.originalAnnualPrice+'</b></td></tr>';
                for(SBQQ__Subscription__c objSub1 : objsubWrapper.amendedList) {
                    if(userbasedpricingqt!= null && userbasedpricingqt.contains(con.SBQQ__Quote__r.Id)){
                        amendedSubTable += '<tr><td>'+objSub1.SBQQ__ProductName__c+'</td><td>'+objSub1.SBQQ__Quantity__c+'</td><td>'+ objSub1.iHasco_Number_of_Users__c+'</td><td>'+objSub1.SBQQ__QuoteLine__r.Custom_Discount_Percentage__c+'</td><td>'+'£'+objSub1.SBQQ__QuoteLine__r.Annual_Price__c+'</td></tr>';
                    }else{
                        amendedSubTable += '<tr><td>'+objSub1.SBQQ__ProductName__c+'</td><td>'+objSub1.SBQQ__Quantity__c+'</td><td>'+objSub1.Ihasco_Number_of_Credits__c+'</td><td>'+objSub1.SBQQ__QuoteLine__r.Custom_Discount_Percentage__c+'</td><td>'+'£'+objSub1.SBQQ__QuoteLine__r.Annual_Price__c+'</td></tr>';
                    }
                }
                amendedSubTable+='<tr><td width="50%"><b>New Order Amount: '+'£'+objsubWrapper.amendAnnualPrice+'</b></td></tr>';
                finalAmendTable = '<html><body><br><table width="100%"><tr><td><b>Amount Paid to Date: £'+objsubWrapper.originalAnnualPrice+'</b></td></tr><tr><td><b>Outstanding Amount Due: £'+objsubWrapper.amendDifference+'</b></td></tr><tr><td><b>Notes To Finance: '+con.SBQQ__Opportunity__r.Notes_to_Finance__c+'</b></td></tr></table></body></html>';
            }
        originalSubTable += '</table></body></html>';
        amendedSubTable += '</table></body></html>'; 
        Messaging.SingleEmailMessage message= new Messaging.SingleEmailMessage();
        list<String> recepientId = new list<String>();
        recepientId.add(EmailbodyMap.get('userEmail'));
        //recepientId.add('priyankamanda@citation.co.uk');
		list<String> ccAddress = new list<String>();
        ccAddress.add(con.Account.iHASCO_Account_Manager__r.Email);
        message.toAddresses = recepientId;
        message.ccaddresses = ccAddress;
        message.subject = 'iHasco Contract Amendment';
        amendedHTMLBody = EmailbodyMap.get('linezero')+EmailbodyMap.get('ClientId') + '<tr><td width="50%">License Model: '+EmailbodyMap.get('license')+'</td></tr></table><br><br></body></html>' + amendLineOne + EmailbodyMap.get('lineone') + amendLineTwo+amendsubLineTwo + originalSubTable + amendLineThree + amendedSubTable + finalAmendTable;
        amendedHTMLBody = amendedHTMLBody.replace('null', '');
        message.HtmlBody = amendedHTMLBody;
        messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if(!results.isEmpty()){
            Boolean success;
            String errorMessage;
            for(Messaging.SendEmailResult result :results){
                success=result.success;
                if (success) {  System.debug('The email was sent successfully.'); }
            }
        }   
    }
}