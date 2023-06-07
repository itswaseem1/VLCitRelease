/**********************************************************************
* bg_FmIntOpportunity:
*
* Class to serialise Opportunity object into a json message and 
* send via bg_FmIntHttpCallout
* Created By: SA
* Created Date: 01-02-2016
*
* Changes: 
***********************************************************************/
public with sharing class bg_FmIntOpportunity {

    public static List<Contact> getContactsWithoutExtIds(List<Opportunity> oppList) {
        Map<ID, Contact> cntMap = bg_FmIntContact.getCntMap(getCntIds(oppList));
        List<Contact> cntList = new List<Contact>();
        for(Contact cnt : cntMap.values()){
            if(cnt.FM_Contact_External_Id__c == null) {
                cntList.add(cnt);
            }
        }
        return cntList;
    }

    public static List<String> serialize(List<Contact> cntList, List<Opportunity> oppList) {
        Map<ID, Contact> cntMap = getCntMap(cntList);
        Map<ID, Account> accMap = bg_FmIntContact.getAccMap(getAccIds(oppList));

        return serialize(oppList, cntMap, accMap);
    }

    public static List<String> serialize(List<Opportunity> oppList) {
        Map<ID, Contact> cntMap = bg_FmIntContact.getCntMap(getCntIds(oppList));
        Map<ID, Account> accMap = bg_FmIntContact.getAccMap(getAccIds(oppList));

        return serialize(oppList, cntMap, accMap);
    }

    public static List<String> serialize(List<Opportunity> oppList, Map<ID, Contact> cntMap, Map<ID, Account> accMap) {
        List<String> jsonList = new List<String>();
        list<OpportunityLineItem> OpLine = new list<opportunityLineItem>();
        for(Opportunity opp : oppList){

            List<bg_FmIntOpportunityWrapper> wrappers = new List<bg_FmIntOpportunityWrapper>();

            //store each line within a map to link them to the grouping reference.
            Map<Id, Set<OpportunityLineItem>> oppLinesByGroupId = new Map<Id, Set<OpportunityLineItem>>();

            for(OpportunityLineItem oppLine : opp.OpportunityLineItems)
            {
                
                if(oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Family == 'Audit' ||
                    oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Family == 'Certification' || 
                    (oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == 'QMS') ||
                    (oppLine.SBQQ__QuoteLine__r.SBQQ__ProductFamily__c == 'QMS' && oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'One-Off'))
                    { 
                        if(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && !oppLinesByGroupId.containsKey(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c))
                        {    
                            oppLinesByGroupId.put(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c, new Set<OpportunityLineItem>());
                        }
                        if(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null)
                        {
                        	oppLinesByGroupId.get(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c).add(oppLine);                        
                        }
						
                        // To pass the one-off to the request for FM
                        if(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == null && oppLine.SBQQ__QuoteLine__r.SBQQ__ProductFamily__c == 'QMS' && oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'One-Off') {
                            oppLinesByGroupId.put(oppLine.SBQQ__QuoteLine__r.Id, new Set<OpportunityLineItem>());
                            oppLinesByGroupId.get(oppLine.SBQQ__QuoteLine__r.Id).add(oppLine);
                        }                        
                    }
                }
            if(oppLinesByGroupId.size() == 0)
            {
                //if(opp.Certification__c != null && opp.Certification__c != '')
                //{
                    wrappers.add(new bg_FmIntOpportunityWrapper(opp));
                //}
            }
            else
            {
                for(Id groupId : oppLinesByGroupId.keySet())
                {   
                    List<OpportunityLineItem> tempOppProducts = new List<OpportunityLineItem>();
                    tempOppProducts.addAll(oppLinesByGroupId.get(groupId));
                    wrappers.add(new bg_FmIntOpportunityWrapper(opp,tempOppProducts));
                }
            }

            jsonList.add( '[' + 
                JSON.serialize(cntMap.get(opp.Contact__c)) + ',' +  
                JSON.serialize(accMap.get(opp.AccountId)) + ',' +
                JSON.serialize(wrappers) +']');
        }
        system.debug('**JSONList**: ' + jsonList);
        return jsonList;
    }


    public static Map<ID, Opportunity> getOppMap(Set<Id> oppIdList) {
        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>([SELECT Id,Type,FM_Opportunity_External_Id__c,AccountId,Contact__c,
                                    Additional_Company_Reg_No__c,Additional_Company_VAT_No__c,Additional_Company__c,
                                    Additional_Company_Name__c, Audit_Days__c,Audit_Fee_FM__c,Contract_Signed__c,ECHO_Customer_Signed_Date__c,
                                    Cert_Reason__c,New_Service_Form_Returned_Date__c,New_Service_Form_Returned__c,
                                    Certification_Days__c,Contract_Length_Years__c,LeadSource,Certification_Fee__c,
                                    Sale_Approved__c,Office_Advisor__c,Presentation_Days__c,
                                    Certification__c,Field_Advisor__c,is_Reduction__c,Reduction_Amount__c,
                                    DTR__c,Sales_Visit__c,Contract_End_Date__c,Is_Contract_Cancelled__c, Deposit__c, Deposit_Received__c,Deposit_Received_Date__c,
                                    Generate_Proforma__c, Deposit_Proforma_Date__c, FM_Fixed_Notes__c, Reference_Number__c, 
                                    (Select 
                                        Id,
                                        Name,
                                        Audit_Days__c,
                                        Audit_Fee__c,
                                        Cert_Days__c,
                                        Cert_Fee__c,
                                        Consultancy_Fee__c,
                                        Contract_End_Date__c,
                                        Deposit__c,
                                        Deposit_Proforma_Date__c,
                                        Deposit_Received__c,
                                        Deposit_Received_Date__c,
                                        DTR__c,
                                        Field_Advisor__c,
                                        FM_Enquiry_Id__c,
                                        FM_Fixed_Notes__c,
                                        FM_Field_Advisor__c,
                                        Generate_Proforma__c,
                                        Is_Contract_Cancelled__c,
                                        is_Reduction__c,
                                        Lead_Source__c,
                                        Presentation_Days__c,
                                        Reduction_Amount__c,
                                        Sales_Visit__c,
                                        SBQQ__QuoteLine__r.SBQQ__Product__r.Family,
                                        SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
                                        SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,
                                        SBQQ__QuoteLine__r.Term__c,
                                        SBQQ__QuoteLine__r.Group_Term__c,
                                        SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.FM_Product_Name__c,
                                        SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Service_Type__c,
                                        SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c,
                                        SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__BillingFrequency__c,
                                        SBQQ__QuoteLine__r.SBQQ__Product__r.Service_Type__c,
                                        SBQQ__QuoteLine__r.Deposit__c,
                                        SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c,
                                        SBQQ__QuoteLine__r.SBQQ__CustomerPrice__c,
                                        Product2.QMS_Base_Product_Name__c,
                                        SBQQ__QuoteLine__r.SBQQ__ProductFamily__c,
                                        Certification__c,
                                        Product2.ProductCode,
                                        Gap_Analysis_Days__c
                                    From 
                                        OpportunityLineItems) 
                                FROM Opportunity where id in :oppIdList]);
        return oppMap;
    }

    public static Map<Id, Contact> getCntMap(List<Contact> cntList) {
        Map<Id, Contact> cntMap = new Map<Id, Contact>();
        for(Contact c: cntList) {
            cntMap.put(c.Id, c);
        }
        return cntMap;
    }

    public static List<Id> getAccIds(List<Opportunity> oppList) {
        List<Id> accIdList = new List<Id>();
        for(Opportunity opp : oppList){
            accIdList.add(opp.AccountId);
        }
        return accIdList;       
    }

    public static List<Id> getCntIds(List<Opportunity> oppList) {
        List<Id> cntIdList = new List<Id>();
        for(Opportunity opp : oppList){
            cntIdList.add(opp.Contact__c);
        }
        return cntIdList;       
    }

    public static Map<Id, Opportunity> getCntId2OppMap(List<Opportunity> oppList) {
        Map<Id, Opportunity> cntId2OppMap = new Map<Id, Opportunity>();
        for(Opportunity opp : oppList){
            cntId2OppMap.put(opp.Contact__c, opp);
        }
        return cntId2OppMap;        
    }

    public static void send(List<Opportunity> oppList) {
        send(bg_FmIntContact.getAction(), oppList);
    }

    public static void send(String action, List<Opportunity> oppList) {
        // if not SF API user
        String apiUsers = String.valueOf(FM_Integration__c.getValues('Host').get('SF_API_Username__c'));
        if(!apiUsers.contains(UserInfo.getUserName())) {
            ID jobIdOpp = bg_FmIntHttpQueueableCallout.enqueueJob(new bg_FmIntHttpQueueableCallout.HttpQueueableClass('Opportunity',action,oppList));
            System.debug('send opps: ' + action + ' # ' + oppList);

        }
    }

}