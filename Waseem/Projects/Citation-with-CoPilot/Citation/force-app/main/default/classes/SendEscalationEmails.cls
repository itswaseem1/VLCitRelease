public class SendEscalationEmails { 
    
    public void sendEmails(List<Case> cases){
        Map<String,Set<String>> caseOwnerToCaseNumber = new Map<String,Set<String>>();
        Map<String,String> caseNumberToCaseID = new Map<String,String>();
        for(Case cs : cases){
            caseNumberToCaseID.put(cs.CaseNumber, cs.id);
            if(!caseOwnerToCaseNumber.containsKey(cs.OwnerId)){
                caseOwnerToCaseNumber.put(cs.OwnerId, new Set<String>{cs.CaseNumber});
                
            }else{
                caseOwnerToCaseNumber.get(cs.OwnerId).add(cs.CaseNumber);
            }
        }
        
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Citation Task').getRecordTypeId();
        List<Task> tsks = new List<Task>();
        for(User usr : [select id ,ManagerId from user where id in :caseOwnerToCaseNumber.keySet() and ManagerId != null]){
            for(String caseNumber : caseOwnerToCaseNumber.get(usr.id)){
                Task tsk = new Task();
                tsk.WhatId=caseNumberToCaseID.get(caseNumber);
                tsk.OwnerId=usr.ManagerId;
                tsk.recordtypeId=taskRecordTypeId;
                tsk.IsReminderSet=true;
                tsk.ReminderDateTime =System.now()+1;
                tsk.Subject='Client Query Case Escalation';
                tsks.add(tsk);
             
            }
        }

        Database.DMLOptions notifyOption = new Database.DMLOptions();
        notifyOption.EmailHeader.triggerUserEmail = true;
        Database.insert(tsks, notifyOption);
    }
}