public class QuoteGroupLineTriggerHandler {
    public static void handleAfterUpdate(List<SBQQ__QuotelineGroup__c> newList, Map<id,SBQQ__QuotelineGroup__c> oldMap){
        Set<id> quoteIds = new Set<id>();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        For(SBQQ__QuotelineGroup__c qlg: newList){
            if(qlg.SBQQ__Optional__c != oldMap.get(qlg.id).SBQQ__Optional__c){
                quoteIds.add(qlg.SBQQ__Quote__c);
            }
        }
        IF(!quoteIds.IsEmpty()){
            For(SBQQ__Quote__c quote : [SELECT id, recordTypeid,(SELECT Id,SBQQ__Quote__c from SBQQ__LineItems__r) FROM SBQQ__Quote__c where id IN :quoteIds AND RecordType.Name = 'QMS Quote Standard']){
                quoteLines.addAll(quote.SBQQ__LineItems__r);
            }
            if(!quoteLines.isEmpty()){
                QuoteLineItemHandler instance = new QuoteLineItemHandler();
                instance.qmsupdateQuoteDocSwitches(quoteLines);
            }
        }
        
    }
}