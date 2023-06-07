public class QMS_Opportunity_ContractCreationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public  Integer recordsProcessed = 0;
    public Id opportunityQMSRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(DataConstants.OPPORTUNITY_QMS_RECORDTYPE_NAME).getRecordTypeId();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, CurrencyIsoCode, Pricebook2Id, OwnerId,Account.Name , Contract_Length_Years__c,Deal_Start_Date__c,Contact__c, ' +
            'Contract_Length_Months__c,Name,AccountId,Total_Deal_Amount__c,Payment_Period__c,Preferred_Payment_Date__c' +
            ' FROM Opportunity' +
            ' Where  RecordtypeId =: opportunityQMSRecordtypeId AND StageName = \'Closed Won\' '
        ); //id= \'0063L000002Rf05QAC\'
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> Opportunities){
        List<contract> contractList = new List<contract>();
        Contract Cont ;
        Date endDate;
        Integer lengthConversion;
        for (Opportunity oppty : Opportunities) {
            lengthConversion = (Integer)oppty.Contract_Length_Years__c;
            endDate = oppty.Deal_Start_Date__c.addYears(lengthConversion);
            if(System.today() < endDate ){
                Cont = QMSCreateContracthelper.createContract(oppty);                            
                contractList.add(Cont);
                recordsProcessed = recordsProcessed + 1;
            }
            
            
        }
        if(contractList.size() > 0 )
            Insert contractList;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug(recordsProcessed + ': Contracts Created');
    }
}