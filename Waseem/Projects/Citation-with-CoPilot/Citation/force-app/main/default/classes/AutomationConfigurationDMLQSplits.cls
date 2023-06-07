public with sharing class AutomationConfigurationDMLQSplits {
    public AutomationConfigurationDMLQSplits() {

    }

    public static map<string,list<string>> closedLostOutSplit(string dmlOutString){
        string                          outSplitQuery               = dmlOutString;
		list<string>                    str1                        = new list<string>();
        list<string>                    str2                        = new list<string>();
        list<string>                    str3                        = new list<string>();
        string                          qString                     = '';
        map<string,list<string>>        mapOutcDec                  = new map<string,list<string>>();    
        if(outSplitQuery.contains('{') || outSplitQuery.contains('}') || outSplitQuery.contains('.')){
		    str1 = outSplitQuery.split('\\{');
            system.debug(str1[1]);
            if(str1[1].contains('.')){
                str2 = str1[1].split('\\.');
                str3 = str2[1].split('\\}');
                system.debug(str2[0]);
                system.debug(str2[1]);
                system.debug(str3[0]);
                if(str2[0] == 'Account')
                {
                    qString = 'account.'+str3[0];
                }

                if(str2[0] == 'Contact'){
                    qString  = 'contact.'+str3[0];
                }

                if(str2[0] == 'Opportunity'){
                    qString  = str3[0];
                }
                list<string>        temString   = new list<string>();
                temString.add(qString);
                if(str3.size() > 1){
                    temString.add(str3[1]);
                }
                mapOutcDec.put(outSplitQuery,temString);
            }
        }
        system.debug('qString'+qString);
        return mapOutcDec;
    }

    @InvocableMethod
    public static void emailT0DomainSplitContact(list<id> contactid){
        try{
                boolean isContact = false;
                for(id recId: contactid){
                    string rid = ((string) recId).left(3);
                    if(rid == '003'){
                        isContact = true;
                    }
                }
                if(isContact){
                    list<contact>                 ctList = [select id,email from contact where id In: contactid];
                    list<contact>                 ctFinalLIst = new list<contact>();
                    for(contact ct: ctList){
                            list<string> domainS   = (ct.email).split('\\@');
                            if(domainS.size()>1){
                                ct.Email_Domain__c = domainS[1];
                                ctFinalLIst.add(ct);
                            }
                    }
                    if(ctFinalLIst.size()>0){
                        update   ctFinalLIst;      
                    }        
                }
                else{
                    emailT0DomainSplitLead(contactid);
                }

            }

            catch(Exception e){
                system.debug('The following exception has occurred: ' + e.getMessage());
            }

    }

    public static void emailT0DomainSplitLead(list<id> leadId){
        try{
            list<lead>                 ctList = [select id,email from lead where id In: leadId];
            list<lead>                 ctFinalLIst = new list<lead>();
            for(lead ct: ctList){
                list<string> domainS   = (ct.email).split('\\@');
                if(domainS.size()>1){
                    ct.Email_Domain__c = domainS[1];
                    ctFinalLIst.add(ct);
                }
            }
            if(ctFinalLIst.size()>0){
                update   ctFinalLIst;      
            }
    
        }
        catch(Exception e){
            system.debug('The following exception has occurred: ' + e.getMessage());
        }
    }


}