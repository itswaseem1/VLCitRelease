global class CoreContractRenewalTypebatch implements Database.Batchable<sobject> {

    global Database.QueryLocator start(database.BatchableContext BC){
        string query = 'select id,status,Renewal_Type__c,EndDate,CALC_Segmentation_Monthly_Amount__c,Services_Taken_EL__c,Services_Taken_HS__c,Services_Taken_AI_Only__c,Services_Taken_AI_Only_HS__c,Services_Taken_Advice_Only__c,Services_Taken_Advice_Only_HS__c,Contract_Value__c,No_of_Payments__c,Account.CoreCitationContractMonths__c from contract';
        return database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,list<contract> scope){
      system.debug('scope.size()'+scope.size());
      list<contract> contList = new list<contract>();
      map<id,contract> oldcontmap = new map<id,contract>();
      for(contract ct: scope){
          if(ct.status == 'Active' || ct.status == 'In Approval Process' || ct.status == 'Pending Start' || ct.status == 'Expired'){
              contList.add(ct);
              oldcontmap.put(ct.id,ct);
          }
      }
      bg_Contract_Helper.checkAccountToUpdateCall(null,oldcontmap);
    }
    
    global void finish(database.BatchableContext BC){

    }
}