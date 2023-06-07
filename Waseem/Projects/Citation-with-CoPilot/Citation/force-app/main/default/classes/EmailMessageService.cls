public class EmailMessageService extends DefaultService{
	public interface ISelector {
		/*
		 *  Returns the Case Map of caseId with RecordType DeveloperName.
		 */
		Map<String, Case> getCasesbyCaseIds(List<id> caseIds);
        
        /** Return Custom setting Data related to Case Reply Emails 
		 * RecordTypeName Vs CaseSettings record
		 **/
        Map<String,EmailCasesReplySetting__c> getEmailCasesReplySetting();
	}

	/*For Custom Exception Handling created below class*/
	public virtual class CustomException extends Exception {
	}

	/*
	 *   Our selector that we were provided by what ever created us.
	 */
	private ISelector selector;

	public EmailMessageService(ISelector selector) {
		this.selector = selector;
	}
	
	/*
	 *   see IDomainService
	 */
	public override void setDefaults(List<SObject> newRecords) {
	}

	/*
	 *   see IDomainService
	 */
	public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords) {
	}

	/*
	 *   see IDomainService
	 */
	public override void processRelatedRecordsOnNew(List<SObject> newRecords) {
        new EmailCasesReply((List<EmailMessage>)newRecords, selector).process();
	}

	/*
	 *   see IDomainService
	 */
	public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords) {

	}

	/*
	 *   see IDomainService
	 */
	public override void processRelatedRecordsOnDelete(List<SObject> objs) {
	}

 	public class EmailCasesReply{
		List<id> caseIdToProcess = new List<id>();
		ISelector selector;
		Map<String,EmailCasesReplySetting__c> emailCaseReplySettingMap;
        EmailCasesReplySetting__c emailCaseReplySetting;
		
		EmailCasesReply(List<EmailMessage> emailMessages, ISelector selector){
			this.caseIdToProcess = findRecordsToProcess(emailMessages);
			this.selector = selector;
		}
		
		void process(){
			List<Case> updatedCases = new List<Case>();
			if(caseIdToProcess.isEmpty())
				return;
			
			emailCaseReplySettingMap = selector.getEmailCasesReplySetting();
			Map<String, Case> CasesMap = selector.getCasesbyCaseIds(caseIdToProcess);
           	updatedCases = processCases(CasesMap);			
			if(!updatedCases.isEmpty()) {
				IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
				uow.upsertRecords(updatedCases);
			}
		}
		
		List<Id> findRecordsToProcess(List<EmailMessage> emailMessages){
			List<Id> caseIdToProcess = new List<Id>();

			for (EmailMessage emailMessage : emailMessages) {
				if(emailMessage.ParentId != null ){
					if (emailMessage.ParentId.getSobjectType() == Case.SObjectType && emailMessage.Incoming) {
						caseIdToProcess.add(emailMessage.ParentId);
					}
				}
			}
			return caseIdToProcess;
		}
        
        List<Case> processCases(Map<String, Case>  casestoProcessMap ){
            List<Case> updatedCases = new List<Case>();
            Case caseRecord;
        	for(String caseRecordType : casestoProcessMap.keySet()){
                if(emailCaseReplySettingMap.containsKey(caseRecordType)){
					emailCaseReplySetting = emailCaseReplySettingMap.get(caseRecordType);
                    caseRecord = casestoProcessMap.get(caseRecordType);
                    if(emailCaseReplySetting.Case_Statuses_Open_NewCase__c.contains(caseRecord.Status)){
                        updatedCases.add(caseRecord.clone(false, false, false, false));
                    }
            		if(emailCaseReplySetting.Case_Statuses_Include__c.contains(caseRecord.Status)){
						updatedCases.add(updateCaseStatus(caseRecord));
                    }
				}
            }
            
            return updatedCases;
        }
	
		Case updateCaseStatus(Case caseRecord){
				caseRecord.Status = emailCaseReplySetting.Incoming_Email_Case_Status_update__c;
			
			return caseRecord;
		}
	}
 
	public without sharing class EmailMessageServiceSelector implements EmailMessageService.ISelector {

		public Map<String, Case> getCasesbyCaseIds(List<id> caseIds) {
            Map<String, Case> CasesMap = new Map<String, Case>();
			List<Case> cases = [SELECT id, ownerId, Status, RecordType.DeveloperName FROM Case WHERE Id IN :caseIds];
            
            for(Case caseRecord : cases){
                CasesMap.put(caseRecord.RecordType.DeveloperName,caseRecord); 
            }
            
            return CasesMap;
		}
        
		public Map<String,EmailCasesReplySetting__c> getEmailCasesReplySetting(){
			return EmailCasesReplySetting__c.getAll();
		}
	}
}