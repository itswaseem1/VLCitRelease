global with sharing class QuickQuoteHandler {
	@AuraEnabled
    webservice static Id send(Id oppoId){
      Opportunity Opp=[Select id,Recordtype.DeveloperName,Type,AccountId From Opportunity Where id =: oppoId];
        Id quoteQMSRecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(DataConstants.Quote_QMS_RECORDTYPENAME).getRecordTypeId();
        Id quoteIhascoRecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get(DataConstants.Quote_iHASCO_RECORDTYPENAME).getRecordTypeId();
        SBQQ__Quote__c sb = new SBQQ__Quote__c();
        sb.SBQQ__Opportunity2__c=oppoId;
        if(Opp.Recordtype.DeveloperName == DataConstants.OPPORTUNITY_QMS_RECORDTYPE_NAME){
          sb.RecordTypeId =  quoteQMSRecordtypeId;
          sb.SBQQ__Account__c = Opp.accountId ;
          sb.SBQQ__StartDate__c = system.today();
          sb.SBQQ__Primary__c = true;
        }

        if(Opp.Recordtype.DeveloperName == DataConstants.OPPORTUNITY_iHASCO_RECORDTYPENAME){
          sb.RecordTypeId =  quoteIhascoRecordtypeId;
          sb.SBQQ__Account__c = Opp.accountId ;
           sb.Quote_type__c=Opp.Type;
          System.debug('iHasco');
 	        sb.SBQQ__StartDate__c = system.today();
        }
        insert sb;
        return sb.Id;
    }
}