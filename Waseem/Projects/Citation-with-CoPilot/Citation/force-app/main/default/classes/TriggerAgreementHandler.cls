public with sharing class TriggerAgreementHandler {


    
    public TriggerAgreementHandler() {}

	public static void onAfterInsert(final List<echosign_dev1__SIGN_Agreement__c> newObjects, final Map<Id, echosign_dev1__SIGN_Agreement__c> oldObjectsMap){
		updateContractHasAgreementField(newObjects);        
	}

	public static void onAfterDelete(final List<echosign_dev1__SIGN_Agreement__c> oldObjects, final Map<Id, echosign_dev1__SIGN_Agreement__c> oldObjectsMap){
		updateContractHasAgreementField(oldObjects);
	}


	// Helper methods

	/*
	* If there is an existing Agreement attached to a contract, then set the HasAgreement flag as true, else set as false.
	*/
	private static void updateContractHasAgreementField(List<echosign_dev1__SIGN_Agreement__c> newObjects){
		
		Set<Id> contractIdSet = new Set<Id>();
		for(echosign_dev1__SIGN_Agreement__c record: newObjects){
			if(record.echosign_dev1__Contract__c != null){
				contractIdSet.add(record.echosign_dev1__Contract__c);
			}
            
		}

		if(contractIdSet.isEmpty()) return;
		
		try{
			List<Contract> contractsToUpdate = new List<Contract>();

			Map<Id, Integer> mapAgreementContractCount = new Map<Id, Integer>();
			Map<Id, Contract> contractMap = new Map<Id, Contract>([select Id, HasAgreement__c from Contract where Id in: contractIdSet]);

			for(AggregateResult aggregate: [select count(Id), echosign_dev1__Contract__c from echosign_dev1__SIGN_Agreement__c where echosign_dev1__Contract__c in:contractIdSet Group by echosign_dev1__Contract__c]){
				mapAgreementContractCount.put((Id)aggregate.get('echosign_dev1__Contract__c') , (Integer)aggregate.get('expr0'));
			}

			for(Contract record: contractMap.values()){
				if( mapAgreementContractCount.get(record.Id) == null || mapAgreementContractCount.get(record.Id) == 0 ){
					record.HasAgreement__c = false;
				}else if( mapAgreementContractCount.get(record.Id) > 0 ){
					record.HasAgreement__c = true;
				}
				contractsToUpdate.add(record);
			}

			if(!contractsToUpdate.isEmpty()) update contractsToUpdate;
		}catch(Exception ex){
			System.debug(System.LoggingLevel.DEBUG, ex.getMessage());
		}
	}
    
    public static void onAfterUpdate(List<echosign_dev1__SIGN_Agreement__c> newObjects, Map<id,echosign_dev1__SIGN_Agreement__c> oldObjectMap){

        Set<id> qteDocumentids = new Set<id>();
        Map<String,String> QteDocToAgrmt = new Map<String,String>();
        
        for(echosign_dev1__SIGN_Agreement__c record: newObjects){
            if(record.SBES__Quote_Document__c != null && oldObjectMap.get(record.id).SBES__Quote_Document__c != record.SBES__Quote_Document__c){              
                qteDocumentids.add(record.SBES__Quote_Document__c);
                QteDocToAgrmt.put(record.SBES__Quote_Document__c,record.id);
            } 
        }
        
        Map<id,SBQQ__QuoteDocument__c> qteDocumentMap = new Map<id,SBQQ__QuoteDocument__c>();
        if(!qteDocumentids.isEmpty()){
            qteDocumentMap = new Map<id,SBQQ__QuoteDocument__c>([SELECT id , SBQQ__QuoteTemplate__r.name from SBQQ__QuoteDocument__c where id IN :qteDocumentids AND 	SBQQ__QuoteTemplate__r.name = :System.Label.QMS_CPQ_Quote_Template_Name]);
        }

        if(!qteDocumentMap.isEmpty()){
            
            List<Attachment> newattach= new List<Attachment>();
            for(Attachment att: [SELECT Id,Body,BodyLength,Description,ContentType,Name,OwnerId,ParentId from Attachment where parentid IN :qteDocumentMap.keySet() ]){
                if(QteDocToAgrmt.containsKey(att.parentId)){
                    Attachment nAt = att.clone(false,true,false,false);
                    nAt.ParentId = QteDocToAgrmt.get(att.parentId);
                    newattach.add(nAt);  
                }
            }
            
            if(!newattach.isEmpty()){
                insert newattach;
            }     
        } 
    }
    
}