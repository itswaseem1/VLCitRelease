public class QueueableCPQliRollup {
     @future (callout=true)
     public static void execute(Set<id> pIds) {

         List<SBQQ__QuoteLine__c> pQuote = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c pQLineItem : [SELECT id, (select id, Total_Quote_Line__c from SBQQ__Quote_Lines__r where IsDeleted = false) from SBQQ__QuoteLine__c where id IN :pIds AND IsDeleted = false]){
                SBQQ__QuoteLine__c updatedQLineItem= new SBQQ__QuoteLine__c();
                updatedQLineItem.id = pQLineItem.id;
                updatedQLineItem.Sub_Line_Total__c = 0;
                for(SBQQ__QuoteLine__c cQlineItem : pQLineItem.SBQQ__Quote_Lines__r){
                    updatedQLineItem.Sub_Line_Total__c = updatedQLineItem.Sub_Line_Total__c + cQlineItem.Total_Quote_Line__c;
                }

				pQuote.add(updatedQLineItem);                
            }
            if(!pQuote.isEmpty()){

                update pQuote;
            }    
    }
}