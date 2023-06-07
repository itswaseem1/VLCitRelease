public class iHASCOTopUpOrderSendMail { 
    
    public static void SendEmailToAccountsTeam(Set<Id> OrderId){
        Set<Id> quoteIds = new Set<Id>();
        //String userName = UserInfo.getName();
        String userEmail;
        if(OrgInstanceCheck.runningInASandbox()){
            userEmail = label.iHASCO_Order_Team_Email; }
        else{
            userEmail =label.iHASCO_Finance_Prod_Email;
        }
        String license, linezero, lineone, linetwo, subsLinesStart, subsLinesEnd, baseURL;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Map<string,List<SBQQ__QuoteLine__c>> quotetoLines = new Map<string,List<SBQQ__QuoteLine__c>>();
        Set<id> userbasedpricingqt = new Set<id>();
        Order[] orderValues=[SELECT Id,CreatedDate,TotalAmount, Account.Id,Account.Owner.Name,EndDate, Account.Name, Account.Company_VAT_Number__c,
                             Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry,Contract.ContractTerm,
                             Opportunity.BDC_Manager__c,OpportunityId, Opportunity.Deposit_Payment_Method__c,Opportunity.Notes_to_Finance__c,Opportunity.New_Business_Customer__c,Account.LMS_ID__c,EffectiveDate, 
                             OrderNumber,Type,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name, SBQQ__Quote__r.Payment_Method__c,
                             SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone,
                             SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone, SBQQ__Quote__r.PO_reference__c ,SBQQ__Quote__r.License_Model__c,SBQQ__Quote__r.Name,Account.iHASCO_Account_Manager__r.Email,
                             SBQQ__Quote__r.SBQQ__CustomerAmount__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.id,SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Name, SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Email,SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.MobilePhone,Opportunity.Type
                             FROM order WHERE Id IN:orderId AND  RecordType.Name='iHasco' AND Status ='Activated'];
        //Contract[] contractValues = [SELECT Id, Account.Id,Account.Owner.Name,EndDate, Account.Name,Renewal_Date__c, Account.Company_VAT_Number__c, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, Source_Opportunity__r.Id, SBQQ__Opportunity__r.BDC_Manager__c, SBQQ__Opportunity__r.Deposit_Payment_Method__c, StartDate, ContractNumber, recordType.Name, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone, SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone, SBQQ__Quote__r.PO_reference__c FROM Contract WHERE Id IN:newContracts AND RecordType.Name='iHasco'];
        
        for(Order Ord : orderValues){
            quoteIds.add(Ord.SBQQ__Quote__r.Id);
        }
        SBQQ__QuoteLine__c[] quoteLines = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Name, Custom_Discount_Percentage__c, SBQQ__Quote__r.Id,iHasco_Number_of_Users__c, SBQQ__NetTotal__c,Ihasco_Number_of_Credits__c,Custom_Discount_Amount__c From SBQQ__QuoteLine__c where SBQQ__Quote__r.Id In :quoteIds];
        System.debug('QuoteLines: '+quoteLines);
        for(SBQQ__QuoteLine__c ql : quoteLines){
            if(ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name == 'User based Pricing'){
                userbasedpricingqt.add(ql.SBQQ__Quote__r.Id);
            }
            if(quotetoLines != null && quotetoLines.containsKey(ql.SBQQ__Quote__r.Id)){
                List<SBQQ__QuoteLine__c> lines = quotetoLines.get(ql.SBQQ__Quote__r.Id);
                lines.add(ql);
                quotetoLines.put(ql.SBQQ__Quote__r.Id,lines);
            } else {
                List<SBQQ__QuoteLine__c> lines= new List<SBQQ__QuoteLine__c>();
                lines.add(ql);
                quotetoLines.put(ql.SBQQ__Quote__r.Id,lines);
            }
        }
        for(Order Ord : orderValues){
            linezero = null;
            lineone = null;
            linetwo = null;
            subsLinesStart = null;
            license = null;
            subsLinesEnd = null;
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String PoRef, paymentMethod = '';
            license= ord.SBQQ__Quote__r.License_Model__c;
            if(ord.SBQQ__Quote__r.PO_reference__c==Null){
                PoRef= ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name;                        
            }else{
                PoRef = ord.SBQQ__Quote__r.PO_reference__c != Null ? ord.SBQQ__Quote__r.PO_reference__c : ' ';
            }
            
            system.debug('po reference number'+PoRef);
            //orderTotal = ord.SBQQ__Quote__r.SBQQ__CustomerAmount__c;
            paymentMethod =ord.SBQQ__Quote__r.Payment_Method__c;
            linezero = '<html><body><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%">'+ord.Account.Name+ '</td><td width="50%">Contact: '+ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name+ '</td></tr>'
                +'<tr><td width="50%">'+ord.Account.BillingStreet+ '<br>'+ord.Account.BillingCity+'<br>'+ord.Account.BillingCountry+'<br>'+ord.Account.BillingPostalCode+'</td><td width="50%">Phone: '+ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone+ '<br><br>Mobile: '+ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.MobilePhone+'<br><br>Email: '+ord.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email+'</td></tr>'
                +'<tr><td width="50%">Opportunity Id: '+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ord.SBQQ__Quote__r.SBQQ__Opportunity2__r.id+'</td></tr>';
            
            lineone = '<html><body><a href="'+baseURL+'/'+ord.Account.Id+'">See Client In CRM</a><br></body></html>';
            linetwo = '<html><body><table width="100%" bgcolor="#FFFFFF"><tr><td width="50%"><b>Order Number</b>: '+ord.OrderNumber+'</td><td width="50%"><b>PO Reference</b>: '+PoRef+'</td></tr>'
                +'<tr><td width="50%"><b>Order Date: </b>'+ord.CreatedDate.format()+'</td><td width="50%">Account Manager Name: '+ord.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Name+'</td></tr>'
                +'<tr><td width="50%"><b>Payment Method:</b> '+paymentMethod+'</td><td width="50%">Account Manager Email: '+ord.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.Email+'</td></tr>'
                +'<tr><td width="50%"><b>Total Order Amount:'+'£'+ord.TotalAmount+'</b></td><td width="50%">Account Manager Phone: '+ord.SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner.MobilePhone+'</td></tr>'
                +'<tr><td width="50%"><b>Notes To Finance: '+ord.Opportunity.Notes_to_Finance__c+'</b></td><td width="50%"> New Business Customer: '+ord.Opportunity.New_Business_Customer__c+'</td></tr>'
                +'<tr><td width="50%"><b>LMS ID: '+ord.Account.LMS_ID__c+'</b></td><td width="50%">Order Type: '+ord.Opportunity.Type+'</td></tr>'
                +'<tr><td width="50%"><b>Quote Number: '+ord.SBQQ__Quote__r.Name+'</b></td>'+'</table><br></body></html>' ;
            if(userbasedpricingqt!= null && userbasedpricingqt.contains(ord.SBQQ__Quote__r.Id)){
                subsLinesStart = '<html><body><br><table width="100%"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="15%">Quantity</th><th style="text-align:left" width="15%">No.of Users</th><th style="text-align:left" width="15%">Discount(£)</th><th style="text-align:left" width="15%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
            } else {
                subsLinesStart = '<html><body><br><table width="100%"><tr><th style="text-align:left" width="20%">Product</th><th style="text-align:left" width="15%">Quantity</th><th style="text-align:left" width="15%">No.of Credits</th><th style="text-align:left" width="15%">Discount(£)</th><th style="text-align:left" width="15%">Discount(%)</th><th style="text-align:left" width="20%">Amount</th></tr>';
            }
            if(quotetoLines.containsKey(ord.SBQQ__Quote__r.Id) && quotetoLines.get(ord.SBQQ__Quote__r.Id)!=null){
                for(SBQQ__QuoteLine__c ql : quotetoLines.get(ord.SBQQ__Quote__r.Id)){
                    String discount = '';
                    discount = ql.Custom_Discount_Percentage__c != Null ? String.valueOf(ql.Custom_Discount_Percentage__c) : ' ';
                    if(ql.SBQQ__Quote__r.Id == ord.SBQQ__Quote__r.Id){
                        //parentChildMap.put(ql.Id, ql);
                        //SBQQ__QuoteLine__c parentQl = ql.SBQQ__RequiredBy__c;
                        /* if(ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name != Null){
if(Label.ihasco_pricing_model.contains(ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name))
license = ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name;
}*/
                        if(userbasedpricingqt!= null && userbasedpricingqt.contains(ord.SBQQ__Quote__r.Id)){
                                                       
                            subsLinesStart = subsLinesStart + '<tr><td width="25%">'+ql.SBQQ__Product__r.Name+'</td><td width="20%">'+ql.SBQQ__Quantity__c+'</td>'; 
                          
                            if(ql.iHasco_Number_of_Users__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td>';
                            }
                            else if(ql.iHasco_Number_of_Users__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+ql.iHasco_Number_of_Users__c+'</td>';}
                         
                             if(ql.Custom_Discount_Amount__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td>';
                            }
                            else if(ql.Custom_Discount_Amount__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+'£'+ql.Custom_Discount_Amount__c+'</td>';}
                         if(discount==null || discount==' ')
                            {
                               subsLinesStart=subsLinesStart+ '<td width="20%">'+ +'</td>';
                            }
                            else if(discount!=null || discount !=' ')
                                    {subsLinesStart=subsLinesStart+ '<td width="20%">'+discount + '%'+'</td>';}
                          if(ql.SBQQ__NetTotal__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="20%">'+ +'</td></tr>';
                            }
                            else if(ql.SBQQ__NetTotal__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="20%">'+'£'+ql.SBQQ__NetTotal__c+'</td></tr>';}
                        } 
                        
                        else {
                            subsLinesStart = subsLinesStart + '<tr><td width="25%">'+ql.SBQQ__Product__r.Name+'</td><td width="25%">'+ql.SBQQ__Quantity__c+'</td>'; 
                        if(ql.Ihasco_Number_of_Credits__c==null)
                        {
                           subsLinesStart=subsLinesStart + '<td width="15%">'+ +'</td>';
                        }
                            else if(ql.Ihasco_Number_of_Credits__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+ql.Ihasco_Number_of_Credits__c+'</td>';}

                        if(ql.Custom_Discount_Amount__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="15%">'+ +'</td>';
                            }
                            else if(ql.Custom_Discount_Amount__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="15%">'+'£'+ql.Custom_Discount_Amount__c+'</td>';}
                        if(discount==null || discount ==' ')
                            {
                               subsLinesStart=subsLinesStart+ '<td width="20%">'+ +'</td>';
                            }
                        else if(discount!=null || discount !=' ')
                                    {subsLinesStart=subsLinesStart+ '<td width="20%">'+discount + '%'+'</td>';}
                          if(ql.SBQQ__NetTotal__c==null)
                            {
                               subsLinesStart=subsLinesStart+ '<td width="20%">'+ +'</td></tr>';
                            }
                            else if(ql.SBQQ__NetTotal__c!=null)
                                    {subsLinesStart=subsLinesStart+ '<td width="20%">'+'£'+ql.SBQQ__NetTotal__c+'</td><tr>';}
                        }
                    }
                }
            }
            
            subsLinesEnd = '</table></body></html>';
            Messaging.SingleEmailMessage message= new Messaging.SingleEmailMessage();
            list<String> recepientId = new list<String>();
            list<String> ccAddress = new list<String>();
            ccAddress.add(ord.Account.iHASCO_Account_Manager__r.Email);
            message.ccaddresses = ccAddress;
            recepientId.add(userEmail);
            message.toAddresses = recepientId;
            message.subject = 'iHASCO  Order Created';
            message.HtmlBody = linezero + '<tr><td width="50%">License Model: '+license+'</td></tr></table><br><br></body></html>' + lineone + linetwo + subsLinesStart + subsLinesEnd+'<br/> <b>Total Order Amount: '+'£'+ord.TotalAmount+'</b></td>';
            System.debug('message.HtmlBody+++' + message.HtmlBody );
            messages.add(message);
        }
        //SBQQ__Subscription__c[] subscriptions = [SELECT Id, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__OptionDiscount__c From SBQQ__Subscription__c where SBQQ__Contract__c   IN :newContracts];
        
        
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if(!results.isEmpty()){
            Boolean success;
            String errorMessage;
            for(Messaging.SendEmailResult result :results){
                success=result.success;
                
                if (success) {     
                    if(test.isRunningTest()){
                        Boolean SuccessValue ;
                        SuccessValue = success;
                        integer successcount =0;
                        successcount++;}
                    System.debug('The email was sent successfully.'+success);
                } else {
                    System.debug('The email failed to send: ' + errorMessage);
                }
            }
        }
        
        
    }
}