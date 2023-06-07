global class AccountCalContractUpdate implements Database.Batchable<SObject>,Database.Stateful,Schedulable {

    global final String Query;
    List<Database.SaveResult> srList                    = new List<Database.SaveResult>();
    List<String> toAddresses                            = new list<string>{'srikanthragi@citation.co.uk'};
        Set<Id> recordtypeIds=new set<Id>();    

    global AccountCalContractUpdate(string queryString){
 
       Query=queryString;
    }

    global AccountCalContractUpdate(){
        query = 'select id,(select id,status from contracts where status =:acst AND RecordtypeId IN :recordtypeIds),CALC_Citation_Contract__c from account';
     }
 
    global Database.QueryLocator start(Database.BatchableContext BC){
       string acst = 'Active';
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Contract.getRecordTypeInfosByName();            
       recordtypeIds.add(recordTypes.get('Client Relations Contract Record Type').getRecordTypeId());                   
        recordtypeIds.add(recordTypes.get('Client Relations Renewal Contract').getRecordTypeId());  
        recordtypeIds.add(recordTypes.get('E-Commerce').getRecordTypeId());                 
        recordtypeIds.add(recordTypes.get('One Off Sale').getRecordTypeId());                       
        recordtypeIds.add(recordTypes.get('Small Business Package').getRecordTypeId());                   
        recordtypeIds.add(recordTypes.get('Standard Contract').getRecordTypeId());
       return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Account> scope){
        map<id,account> acL = new map<id,Account>();
        for(account al: scope){
            if(al.contracts.isempty()){
                /* account tac = new account();
tac.id = al.id;
tac.CALC_Citation_Contract__c = 0;
acL.put(tac.id,tac);*/
            }else{
                System.debug('Contract records size:'+ al.contracts.Size());
                account tac = new account();
                tac.id = al.id;
                tac.CALC_Citation_Contract__c =al.contracts.Size();
                acL.put(tac.id,tac);
            }
        }
        system.debug(acL);
        srList = Database.Update(acL.values(),false);
        system.debug(srList);
     }
 
    global void finish(Database.BatchableContext BC){
            if(srList.size()>0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setsubject('Account Cal Contract Update Job');
                mail.SetPlainTextbody(  'Record Matched the Criteria '     +     '\n' +srList );
                mail.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
            
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountCalContractUpdate(), 50);
    }
 }